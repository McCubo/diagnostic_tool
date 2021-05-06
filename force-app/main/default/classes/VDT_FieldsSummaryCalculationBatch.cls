public with sharing class VDT_FieldsSummaryCalculationBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    private VDT_ObjectCalculationBuilder calculationBuilder;
    private String countryField;
    private VDT_Data_Calculation__c dataCalculationRecord;
    private Integer batchSize = 0;
    private Integer recordCount = 0;
    private Integer batchCount = 0;
    private Date startDate;
    private Date endDate;

    public VDT_FieldsSummaryCalculationBatch(VDT_Data_Calculation__c dataCalculationRecord) {
        this.dataCalculationRecord = dataCalculationRecord;
        this.startDate = dataCalculationRecord.Start_Date__c;
        this.endDate = dataCalculationRecord.End_Date__c;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        try {
            String sobjectName = this.dataCalculationRecord.VDT_Object_Name__c;
            if (this.dataCalculationRecord.VDT_Object_Name__c == 'PersonAccount' || this.dataCalculationRecord.VDT_Object_Name__c == 'BusinessAccount') {
                sobjectName = 'Account';
            }
            Map<String, List<String>> layoutWithFields = VDT_PageLayoutService.getLayoutsWithFieldsForObject(sobjectName);
            List<String> typeFieldNames = new List<String>();

            for (Schema.SObjectField field : VDT_ObjectService.getAllAccessibleFieldsForObject(sobjectName)) {
                typeFieldNames.add(field.getDescribe().getName());
            }

            this.calculationBuilder = new VDT_ObjectCalculationBuilder(sobjectName, typeFieldNames)
                                        .withPageLayoutInformation(layoutWithFields);
            
            String query = 'SELECT ';
            query += String.join(typeFieldNames, ',');
            
            this.countryField = VDT_CustomMetadataService.getCountryFieldForObject(sobjectName);
            String dateField = VDT_CustomMetadataService.getDateFieldForObject(sobjectName);

            if (query.indexOf(countryField) < 0) {
                query += ',' + countryField;
            }

            query += ' FROM ' + sobjectName + ' WHERE ' + countryField + ' != NULL';

            if (this.dataCalculationRecord.VDT_Object_Name__c == 'PersonAccount') {
                query += ' AND IsPersonAccount = TRUE';
            }
            if (this.dataCalculationRecord.VDT_Object_Name__c == 'BusinessAccount') {
                query += ' AND IsPersonAccount = FALSE';
            }
            if (this.dataCalculationRecord.Start_Date__c != NULL && this.dataCalculationRecord.End_Date__c != NULL) {
                query += ' AND {0} >= :startDate AND {0} <= :endDate';
            }

            String queryFormatted = String.format(query, new List<String>{
                dateField
            });

            this.dataCalculationRecord.VDT_Job_Start_Date__c = Datetime.now();
            this.dataCalculationRecord.Batches_Number__c = 0;
            update this.dataCalculationRecord;
            
            return Database.getQueryLocator(queryFormatted);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            VDT_DataCalculationService.sendStatusUpdateEvent(this.dataCalculationRecord.Id, VDT_DataCalculationService.STATUS_ERROR);
            
            throw e;
        }
    }

    public void execute(Database.BatchableContext bc, List<SObject> records) {
        try {
            List<VDT_Field_Summary__c> summaries = new VDT_FieldSummarySelector().addWhereClause('Job_Id__c = \'' + bc.getJobId() + '\'').query();
            Set<String> summaryIds = (new Map<String, VDT_Field_Summary__c>(summaries)).keySet();
            Map<String, String> attachmentsByParent = VDT_AttachmentService.getAttachmentsByParentId(summaryIds, VDT_ObjectCalculationBuilder.COUNTRY_USAGE_FILE_NAME + VDT_AttachmentService.JSON_FORMAT);
            this.dataCalculationRecord.Batches_Number__c += 1;
            update this.dataCalculationRecord;
            this.calculationBuilder
                .withRecords(records)
                .withCountryUsageAttachments(attachmentsByParent)
                .withFieldSummaryRecords(summaries)                
                .calculate(bc.getJobId());
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

            VDT_AttachmentService.createAttachmentForRecord(
                this.calculationBuilder.build(bc.getJobId()),
                VDT_ObjectService.FIELD_SUMMARY_CALCULATION_FILE_NAME,
                VDT_AttachmentService.JSON_FORMAT,
                this.dataCalculationRecord.Id
            );            
            VDT_EmailService.sendFieldCalculationFinishedEmailNotification(this.dataCalculationRecord.VDT_Object_Name__c);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            VDT_DataCalculationService.sendStatusUpdateEvent(this.dataCalculationRecord.Id, VDT_DataCalculationService.STATUS_ERROR);
            
            throw e;
        }
    }
}