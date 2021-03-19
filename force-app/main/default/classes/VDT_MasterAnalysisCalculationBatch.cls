/**
 * @author          m.caceres@polsource.com
 * @created_date:   2021-03-16
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

    public Database.QueryLocator start(Database.BatchableContext bc) {
        try {
            String countryField = VDT_CustomMetadataService.getCountryFieldForObject('Account');
            String specialtyField = VDT_CustomMetadataService.getAccountSpecialtyField();
            List<VDT_OptionWrapper> activeSpecialties = VDT_ObjectService.getPicklistOptionsBySObjectName(SObjectType.Account, specialtyField);
            List<VDT_KPI_Configuration__mdt> activeKpis = VDT_CustomMetadataService.getActiveKpiConfigurations();
            Map<String, List<String>> accountRecordTypesByType = VDT_CustomMetadataService.getAccountRecordTypesByType();
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
                'SELECT Id, RecordType.Name, {0}, {1}, {2}, {4}, {5} FROM Account WHERE {0} != NULL AND {1} != NULL {6} AND VDT_Is_Test_Data__c = TRUE', 
                new List<String> {
                    countryField,
                    specialtyField,
                    '(SELECT Id FROM Call2_vod__r WHERE Call_Date_vod__c >= :startDate AND Call_Date_vod__c <= :endDate)',
                    '(SELECT Id FROM MC_Cycle_Plan_Targets_vod__r WHERE Cycle_Plan_vod__r.Start_Date_vod__c >= :startDate AND Cycle_Plan_vod__r.End_Date_vod__c <= :endDate)',
                    '(SELECT Id FROM Product_Metrics_vod__r)',
                    '(SELECT Id FROM Address_vod__r)',
                    countryClause
                }
            );

            this.builder = new VDT_MasterAnalysisCalculationBuilder(countryField, specialtyField)
            .withValidOptions(activeSpecialties)
            .initKpis(activeKpis)
            .withRecordTypesByType(accountRecordTypesByType)
            .withCustomTargets(targetByCountryAndKpi);
            this.dataCalculationRecord.VDT_Job_Start_Date__c = Datetime.now();
            update this.dataCalculationRecord;
            return Database.getQueryLocator(query);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            VDT_DataCalculationService.sendStatusUpdateEvent(this.dataCalculationRecord.Id, VDT_DataCalculationService.STATUS_ERROR);
            throw e;
        }
    }

    public void execute(Database.BatchableContext bc, List<Account> records) {
        try {
            this.builder.withRecords(records).calculate();
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            VDT_DataCalculationService.sendStatusUpdateEvent(this.dataCalculationRecord.Id, VDT_DataCalculationService.STATUS_ERROR);
            throw e;
        }
    }

    public void finish(Database.BatchableContext bc) {
        try {
            this.dataCalculationRecord.VDT_Job_End_Date__c = Datetime.now();
            this.dataCalculationRecord.Status__c = VDT_DataCalculationService.STATUS_COMPLETED;
            this.dataCalculationRecord.VDT_Calculation_Date__c = Date.today();
            update this.dataCalculationRecord;

            Attachment currentAttachment = VDT_AttachmentService.getAttachmentForRecord(
                VDT_DataCalculationService.MASTER_DATA_ANALYSIS_SUMMARY_FILE_NAME,
                VDT_AttachmentService.JSON_FORMAT, 
                this.dataCalculationRecord.Id
            );
            if (currentAttachment == null) {
                VDT_AttachmentService.createAttachmentForRecord(
                    JSON.serialize(this.builder.build()), 
                    VDT_DataCalculationService.MASTER_DATA_ANALYSIS_SUMMARY_FILE_NAME,
                    VDT_AttachmentService.JSON_FORMAT,
                    this.dataCalculationRecord.Id
                );
            } else {
                VDT_AttachmentService.updateAttachmentForRecord(
                    JSON.serialize(this.builder.build()), 
                    VDT_DataCalculationService.MASTER_DATA_ANALYSIS_SUMMARY_FILE_NAME,
                    VDT_AttachmentService.JSON_FORMAT,
                    this.dataCalculationRecord.Id
                );
            }
            // VDT_EmailService.sendMasterAnalysisCalculationFinishedEmailNotification(this.dataCalculationRecord.VDT_Country__c);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            VDT_DataCalculationService.sendStatusUpdateEvent(this.dataCalculationRecord.Id, VDT_DataCalculationService.STATUS_ERROR);
            
            throw e;
        }
    }
}
