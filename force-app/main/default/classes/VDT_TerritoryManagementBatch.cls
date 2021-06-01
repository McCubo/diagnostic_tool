/**
 * @description Batch job used to calculate all territory management information.
 * @author BASE Life Science
 * @since 2021.03.01
 */
public with sharing class VDT_TerritoryManagementBatch implements Database.Batchable<SObject>, Database.Stateful {

    private VDT_Data_Calculation__c territoryDataCalculation;
    private VDT_TerritoryAnalysisBuilder builder;
    private final String DELIMITER_CHARACTER = ',';

    public VDT_TerritoryManagementBatch(VDT_Data_Calculation__c territoryDataCalculation) {
        this.territoryDataCalculation = territoryDataCalculation;
    }

    /**
     * @description creates a SOQL query for all account and filter them based on the Countries selected from the Search form
     *              on the `Territory Management` search form screen.
     * @param bc 
     * @return  `Database.QueryLocator`
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String countryField = VDT_CustomMetadataService.getCountryFieldForObject('Account');
        String specialtyField = VDT_CustomMetadataService.getAccountSpecialtyField();
        builder = new VDT_TerritoryAnalysisBuilder(countryField, specialtyField, this.territoryDataCalculation.Id);
        List<String> countries = this.territoryDataCalculation.VDT_Country__c.split(DELIMITER_CHARACTER);
        List<String> countryCriterias = new List<String>();
        String countryClause = '';
        if (!countries.contains('All')) {
            for (String countrycode : countries) {
                countryCriterias.add(countryField + ' = \'' + countrycode + '\'');
            }
            countryClause = 'WHERE (' + String.join(countryCriterias, ' OR ') + ')';
        }
        String query = String.format(
            'SELECT Id, IsPersonAccount, {0}, {1} FROM Account {2}', 
            new List<String> {
                countryField,
                specialtyField,
                countryClause
            }
        );

        this.territoryDataCalculation.VDT_Job_Start_Date__c = Datetime.now();
        this.territoryDataCalculation.Batches_Number__c = 0;
        update this.territoryDataCalculation;
        return Database.getQueryLocator(query);
    }

    /**
     * @description using the builder object, calculate the territory management for the account records
     *              on the current batch's execution
     * @param bc 
     * @param accounts 
     */
    public void execute(Database.BatchableContext bc, List<Account> accounts) {
        this.territoryDataCalculation.Batches_Number__c += 1;
        update this.territoryDataCalculation;
        this.builder.withRecords(accounts).calculate();
    }

    /**
     * @description Once all batches are completed, the VDT_Data_Calculation__c record status is updated to COMPLETED,
     *              Creates a new attachment record and links it to the VDT_Data_Calculation__c record, lastly,
     *              a new Email alert is sent letting the user who triggered the job know the job has been completed.
     * @param bc 
     */
    public void finish(Database.BatchableContext bc) {
        try {
            this.territoryDataCalculation.VDT_Job_End_Date__c = Datetime.now();
            this.territoryDataCalculation.Status__c = VDT_DataCalculationService.STATUS_COMPLETED;
            this.territoryDataCalculation.VDT_Calculation_Date__c = Date.today();

            update this.territoryDataCalculation;

            VDT_AttachmentService.createAttachmentForRecord(
                this.builder.build(),
                VDT_ObjectService.TERRITORY_ANALYSIS_FILE_NAME,
                VDT_AttachmentService.JSON_FORMAT,
                this.territoryDataCalculation.Id
            );            
            VDT_EmailService.sendTerritoryAnalysisFinishedEmailNotification(this.territoryDataCalculation.VDT_Country__c);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            VDT_DataCalculationService.sendStatusUpdateEvent(this.territoryDataCalculation.Id, VDT_DataCalculationService.STATUS_ERROR);
            
            throw e;
        }
    }
}
