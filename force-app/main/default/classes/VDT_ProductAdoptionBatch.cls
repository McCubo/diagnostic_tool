/**
 * @description Batch job used to calculate product adoption and product metrics for the records that meet the filter criterias on the
 *              `Product Hierarchy and Adoption` screen.
 * @author BASE Life Science
 * @since 2021.03.01
 */
public with sharing class VDT_ProductAdoptionBatch implements Database.Batchable<SObject>, Database.Stateful {

    private VDT_Data_Calculation__c dataCalculationRecord;
    private Date startDate;
    private Date endDate;
    private VDT_ProductAdoptionBuilder builder;
    private final String DELIMITER_CHARACTER = ',';

    public VDT_ProductAdoptionBatch(VDT_Data_Calculation__c dataCalculationRecord) {
        this.dataCalculationRecord = dataCalculationRecord;
        this.startDate = dataCalculationRecord.Start_Date__c;
        this.endDate = dataCalculationRecord.End_Date__c;
    }

    /**
     * @description creates a SOQL to retrieve Product records based on the filter parameters from the `Producy Adoption` search form.
     *              Set country reference for all SObjects related to Product object.
     *              Set product reference for all SObjects related to Product object
     * @param bc 
     * @return  `Database.QueryLocator`
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String productSObjectAPIName = VDT_CustomMetadataService.getProductCatalogObjectAPI();
        String productCountryField = VDT_CustomMetadataService.getCountryFieldForObject(productSObjectAPIName);
        List<String> countries = String.isNotBlank(this.dataCalculationRecord.VDT_Country__c) ? this.dataCalculationRecord.VDT_Country__c.split(DELIMITER_CHARACTER) : new List<String>(); 
        List<String> countryCriterias = new List<String>();
        String countryClause = '';
        if (!countries.isEmpty() && !countries.contains('All')) {
            for (String countrycode : countries) {
                countryCriterias.add(productCountryField + ' = \'' + countrycode + '\'');
            }
            countryClause = 'WHERE (' + String.join(countryCriterias, ' OR ') + ')';
        }

        String packageVersion = VDT_CustomMetadataService.getPackageVersion();
        Map<String, String> queries = VDT_CustomMetadataService.getQueriesByPackageVersionAndModule(packageVersion, 'Product Adoption');
        String query = String.format(queries.get('Product Adoption'), new List<String> { countryClause });
        String accountCountry = VDT_CustomMetadataService.getCountryFieldForObject('Account');
        String keyMessageCountry = VDT_CustomMetadataService.getCountryFieldForObject('Key_Message_vod__c');        
        String approvedDocumentCountry = VDT_CustomMetadataService.getCountryFieldForObject('Approved_Document_vod__c');
        String clmPresentationCountry = VDT_CustomMetadataService.getCountryFieldForObject('Clm_Presentation_vod__c');
        String eventCountry = VDT_CustomMetadataService.getCountryFieldForObject('EM_Event_vod__c');
        String eventProductField = VDT_CustomMetadataService.getProductFieldForObject('EM_Event_vod__c');

        this.builder = new VDT_ProductAdoptionBuilder()
        .addCountriesForObjects(new Map<String, String> {
            'Product_vod__c' => productCountryField,
            'Account' => accountCountry,
            'Key_Message_vod__c' => keyMessageCountry,
            'Approved_Document_vod__c' => approvedDocumentCountry,
            'EM_Event_vod__c' => eventCountry,
            'Clm_Presentation_vod__c' => clmPresentationCountry
        })
        .addProductFieldsByObject(new Map<String, String> { 
            'EM_Event_vod__c' => eventProductField
        });
        this.dataCalculationRecord.VDT_Job_Start_Date__c = Datetime.now();
        this.dataCalculationRecord.Batches_Number__c = 0;
        update this.dataCalculationRecord;
        return Database.getQueryLocator(query);
    }

    /**
     * @description aggregates KPI data for the current product records
     * @param bc 
     * @param records 
     */
    public void execute(Database.BatchableContext bc, List<SObject> records) {
        try {
            this.dataCalculationRecord.Batches_Number__c += 1;
            update this.dataCalculationRecord;
            this.builder
            .withRecords(records)
            .withKeyMessages()
            .withActiveCLMs()
            .withApprovedDocuments()
            .withSentEmails(this.startDate, this.endDate)
            .withProductMetrics()
            .withCallDetails(this.startDate, this.endDate)
            .withEvents(this.startDate, this.endDate)
            .calculate();
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            VDT_DataCalculationService.sendStatusUpdateEvent(this.dataCalculationRecord.Id, VDT_DataCalculationService.STATUS_ERROR);
            throw e;
        }
    }

    /**
     * @description Once all batches are completed, the VDT_Data_Calculation__c record status is updated to COMPLETED,
     *              Creates a new attachment record and links it to the VDT_Data_Calculation__c record.
     * @param bc 
     */
    public void finish(Database.BatchableContext bc) {
        try {
            this.dataCalculationRecord.VDT_Job_End_Date__c = Datetime.now();
            this.dataCalculationRecord.Status__c = VDT_DataCalculationService.STATUS_COMPLETED;
            this.dataCalculationRecord.VDT_Calculation_Date__c = Date.today();
            update this.dataCalculationRecord;

            VDT_AttachmentService.createAttachmentForRecord(
                JSON.serialize(this.builder.build()), 
                VDT_DataCalculationService.PRODUCT_ADOPTION_FILE_NAME,
                VDT_AttachmentService.JSON_FORMAT,
                this.dataCalculationRecord.Id
            );
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            VDT_DataCalculationService.sendStatusUpdateEvent(this.dataCalculationRecord.Id, VDT_DataCalculationService.STATUS_ERROR);
            throw e;
        }
    }
}