/**
 * @description This Batch job queries the `Account` SObject that match the countries selected from the `Country` picklist option on the 
 *              Master Data Analysis screen.
 * @author BASE Life Science
 * @since 2021.03.01
 */
public with sharing class VDT_MasterAnalysisCalculationBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    private VDT_Data_Calculation__c dataCalculationRecord;
    private Date startDate;
    private Date endDate;
    private final String DELIMITER_CHARACTER = ',';
    private VDT_MasterAnalysisCalculationBuilder builder;
    
    public VDT_MasterAnalysisCalculationBatch(VDT_Data_Calculation__c dataCalculationRecord) {
        this.dataCalculationRecord = dataCalculationRecord;
        this.startDate = dataCalculationRecord.Start_Date__c;
        this.endDate = dataCalculationRecord.End_Date__c;
    }

    /**
     * @description Builds a SOQL query for Accounts object, including all records that match the filter criterias selected by the user on the
     *              Search Form. Queries the package version and based on it, it gets all queries to calculate the metrics for all Active KPIs
     * @param bc 
     * @return  `Database.QueryLocator`
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        try {
            String packageVersion = VDT_CustomMetadataService.getPackageVersion();
            Map<String,String> queriesByName = VDT_CustomMetadataService.getQueriesByPackageVersionAndModule(packageVersion, 'Master Data Analysis');
            String countryField = VDT_CustomMetadataService.getCountryFieldForObject('Account');
            String specialtyField = VDT_CustomMetadataService.getAccountSpecialtyField();
            String classificationField = VDT_CustomMetadataService.getAccountClassificationField();
            List<VDT_OptionWrapper> activeSpecialties = VDT_ObjectService.getPicklistOptionsBySObjectName(SObjectType.Account, specialtyField);
            List<VDT_KPI_Configuration__mdt> activeKpis = VDT_CustomMetadataService.getActiveKpiConfigurations();
            Map<String, List<String>> accountRecordTypesByType = VDT_CustomMetadataService.getAccountRecordTypesByType();
            Map<String, List<String>> accountTypeByFieldValue = VDT_CustomMetadataService.getAccountClassificationByFieldValue();
            Map<String, Decimal> targetByCountryAndKpi = VDT_CustomMetadataService.getCountryKpiConfigurations();
            List<String> countries = this.dataCalculationRecord.VDT_Country__c.split(DELIMITER_CHARACTER);
            List<String> countryCriterias = new List<String>();
            String countryClause = '';
            if (!countries.contains('All')) {
                for (String countrycode : countries) {
                    countryCriterias.add(countryField + ' = \'' + countrycode + '\'');
                }
                countryClause = 'AND (' + String.join(countryCriterias, ' OR ') + ')';
            }
            String query = String.format(
                'SELECT Id, RecordType.DeveloperName, {0}, {1}, {2} FROM Account WHERE {0} != NULL {3}', 
                new List<String> {
                    countryField,
                    specialtyField,
                    classificationField,
                    countryClause
                }
            );

            this.builder = new VDT_MasterAnalysisCalculationBuilder(countryField, specialtyField, classificationField, this.startDate, this.endDate)
            .withValidOptions(activeSpecialties)
            .initKpis(activeKpis)
            .withRecordTypesByType(accountRecordTypesByType)
            .withAccountTypeByFieldValue(accountTypeByFieldValue)
            .withCustomTargets(targetByCountryAndKpi)
            .withCustomQueries(queriesByName);
            this.dataCalculationRecord.VDT_Job_Start_Date__c = Datetime.now();
            this.dataCalculationRecord.Batches_Number__c = 0;
            update this.dataCalculationRecord;
            return Database.getQueryLocator(query);
        } catch (Exception e) {
            handleException(e, this.dataCalculationRecord.Id);
            return null;
        }
    }

    /**
     * @description For each set of records, we call the builder's method, It uses an internal variable to keep track of all records
     * @param bc 
     * @param records records to be proccessed in the current execute method
     */
    public void execute(Database.BatchableContext bc, List<Account> records) {
        try {
            this.dataCalculationRecord.Batches_Number__c += 1;
            update this.dataCalculationRecord;
            this.builder.withRecords(records).withTerritories().calculate();
        } catch (Exception e) {
            handleException(e, this.dataCalculationRecord.Id);
        }
    }

    /**
     * @description Once all batches are completed, the VDT_Data_Calculation__c record status is updated to COMPLETED,
     *              Creates a new attachment record and links it to the VDT_Data_Calculation__c record, lastly,
     *              a new Email alert is sent letting the user who triggered the job know the job has been completed.
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
                VDT_DataCalculationService.MASTER_DATA_ANALYSIS_SUMMARY_FILE_NAME,
                VDT_AttachmentService.JSON_FORMAT,
                this.dataCalculationRecord.Id
            );
            VDT_EmailService.sendMasterAnalysisCalculationFinishedEmailNotification(this.dataCalculationRecord.VDT_Country__c);
        } catch (Exception e) {
            handleException(e, this.dataCalculationRecord.Id);
        }
    }

    private void handleException(Exception e, String recordId) {
        VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
        VDT_Log.get().publish();
        VDT_DataCalculationService.sendStatusUpdateEvent(recordId, VDT_DataCalculationService.STATUS_ERROR);
        throw e;
    }
}