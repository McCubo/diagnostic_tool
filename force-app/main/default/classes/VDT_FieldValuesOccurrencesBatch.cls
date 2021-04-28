public with sharing class VDT_FieldValuesOccurrencesBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    private VDT_Data_Calculation__c dataCalculationRecord;
    private VDT_FieldValuesOccurrencesBuilder builder;

    public VDT_FieldValuesOccurrencesBatch(VDT_Data_Calculation__c dataCalculationRecord) {
        this.dataCalculationRecord = dataCalculationRecord;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        try {
            List<String> fieldNames = new List<String>();

            for (Schema.SObjectField field : VDT_ObjectService.getAllAccessibleFieldsForObjectAndTypes(this.dataCalculationRecord.VDT_Object_Name__c, new List<DisplayType>{DisplayType.Picklist})) {
                fieldNames.add(field.getDescribe().getName());
            }
    
            this.builder = new VDT_FieldValuesOccurrencesBuilder(this.dataCalculationRecord.VDT_Object_Name__c, fieldNames);
            String query = 'SELECT ' + String.join(fieldNames, ',');
            
            String countryField = VDT_CustomMetadataService.getCountryFieldForObject(this.dataCalculationRecord.VDT_Object_Name__c);
            if (query.indexOf(countryField) < 0) {
                query += ',' + countryField;
            }
    
            query += ' FROM ' + this.dataCalculationRecord.VDT_Object_Name__c + ' WHERE ' + countryField + ' != NULL';
    
            this.dataCalculationRecord.VDT_Job_Start_Date__c = Datetime.now();
            this.dataCalculationRecord.Batches_Number__c = 0;
            update this.dataCalculationRecord;

            return Database.getQueryLocator(query);            
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            VDT_DataCalculationService.sendStatusUpdateEvent(this.dataCalculationRecord.Id, VDT_DataCalculationService.STATUS_ERROR);            
            throw e; 
        }
    }

    public void execute(Database.BatchableContext bc, List<SObject> records) {
        try {
            this.dataCalculationRecord.Batches_Number__c += 1;
            update this.dataCalculationRecord;
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

            VDT_AttachmentService.createAttachmentForRecord(
                this.builder.build(),
                VDT_ObjectService.FIELD_VALUES_OCCURRENCES_FILE_NAME,
                VDT_AttachmentService.JSON_FORMAT,
                this.dataCalculationRecord.Id
            );            
            VDT_EmailService.sendFieldValuesOccurrencesFinishedEmailNotification(this.dataCalculationRecord.VDT_Object_Name__c);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            VDT_DataCalculationService.sendStatusUpdateEvent(this.dataCalculationRecord.Id, VDT_DataCalculationService.STATUS_ERROR);            
            throw e;            
        }
    }

}
