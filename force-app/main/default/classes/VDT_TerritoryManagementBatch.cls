public with sharing class VDT_TerritoryManagementBatch implements Database.Batchable<SObject>, Database.Stateful {

    private VDT_Data_Calculation__c territoryDataCalculation;
    private VDT_TerritoryAnalysisBuilder builder;
    private final String DELIMITER_CHARACTER = ',';

    public VDT_TerritoryManagementBatch(VDT_Data_Calculation__c territoryDataCalculation) {
        this.territoryDataCalculation = territoryDataCalculation;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String countryField = VDT_CustomMetadataService.getCountryFieldForObject('Account');
        String specialtyField = VDT_CustomMetadataService.getAccountSpecialtyField();
        builder = new VDT_TerritoryAnalysisBuilder(countryField, specialtyField);
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

    public void execute(Database.BatchableContext bc, List<Account> accounts) {
        this.territoryDataCalculation.Batches_Number__c += 1;
        update this.territoryDataCalculation;
        this.builder.withRecords(accounts).calculate();
    }

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
