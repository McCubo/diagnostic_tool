public with sharing class VDT_FieldsSummaryCalculationBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    private VDT_ObjectCalculationBuilder calculationBuilder;
    private String countryField;
    private VDT_Data_Calculation__c dataCalculationRecord;

    public VDT_FieldsSummaryCalculationBatch(VDT_Data_Calculation__c dataCalculationRecord) {
        this.dataCalculationRecord = dataCalculationRecord;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Map<String, List<String>> layoutWithFields = 
            VDT_PageLayoutService.getLayoutsWithFieldsForObject(this.dataCalculationRecord.VDT_Object_Name__c);
        List<String> typeFieldNames = new List<String>();

        for (Schema.SObjectField field : VDT_ObjectService.getAllAccessibleFieldsForObject(this.dataCalculationRecord.VDT_Object_Name__c)) {
            typeFieldNames.add(field.getDescribe().getName());
        }

        this.calculationBuilder = 
            new VDT_ObjectCalculationBuilder(this.dataCalculationRecord.VDT_Object_Name__c, typeFieldNames)
                .withPageLayoutInformation(layoutWithFields);
        
        String query = 'SELECT ';
        query += String.join(typeFieldNames, ',');
        
        this.countryField = 
            VDT_CustomMetadataService.getCountryFieldForObject(this.dataCalculationRecord.VDT_Object_Name__c);
        if (query.indexOf(countryField) < 0) {
            query += ',' + countryField;
        }

        query += ' FROM ' + this.dataCalculationRecord.VDT_Object_Name__c + ' WHERE ' + countryField + ' != NULL LIMIT 6000';

        this.dataCalculationRecord.VDT_Job_Start_Date__c = Datetime.now();
        update this.dataCalculationRecord;

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> records){
        this.calculationBuilder
            .withRecords(records)
            .calculate();
    }

    public void finish(Database.BatchableContext bc){
        this.dataCalculationRecord.VDT_Job_End_Date__c = Datetime.now();
        this.dataCalculationRecord.Status__c = VDT_DataCalculationService.STATUS_COMPLETED;
        this.dataCalculationRecord.VDT_Calculation_Date__c = Date.today();
        update this.dataCalculationRecord;

        Attachment currentAttachment = VDT_AttachmentService.getAttachmentForRecord(
            VDT_ObjectService.FIELD_SUMMARY_CALCULATION_FILE_NAME,
            VDT_AttachmentService.JSON_FORMAT, 
            this.dataCalculationRecord.Id
        );
        if (currentAttachment == null) {
            VDT_AttachmentService.createAttachmentForRecord(
                JSON.serialize(this.calculationBuilder.build()), 
                VDT_ObjectService.FIELD_SUMMARY_CALCULATION_FILE_NAME,
                VDT_AttachmentService.JSON_FORMAT,
                this.dataCalculationRecord.Id
            );
        } else {
            VDT_AttachmentService.updateAttachmentForRecord(
                JSON.serialize(this.calculationBuilder.build()), 
                VDT_ObjectService.FIELD_SUMMARY_CALCULATION_FILE_NAME,
                VDT_AttachmentService.JSON_FORMAT,
                this.dataCalculationRecord.Id
            );
        }
        VDT_EmailService.sendFieldCalculationFinishedEmailNotification(this.dataCalculationRecord.VDT_Object_Name__c);
    }
}