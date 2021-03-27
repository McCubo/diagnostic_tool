public with sharing class VDT_ProductAdoptionBatch implements Database.Batchable<SObject>, Database.Stateful {

    private VDT_Data_Calculation__c dataCalculationRecord;
    private Date startDate;
    private Date endDate;
    private VDT_ProductAdoptionBuilder builder;

    public VDT_ProductAdoptionBatch(VDT_Data_Calculation__c dataCalculationRecord) {
        this.dataCalculationRecord = dataCalculationRecord;
        this.startDate = dataCalculationRecord.Start_Date__c;
        this.endDate = dataCalculationRecord.End_Date__c;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = String.format('SELECT Id, Name, Product_Type_vod__c FROM Product_vod__c', new List<String>{});
        String accountCountry = VDT_CustomMetadataService.getCountryFieldForObject('Account');
        String keyMessageCountry = VDT_CustomMetadataService.getCountryFieldForObject('Key_Message_vod__c');        
        String approvedDocumentCountry = VDT_CustomMetadataService.getCountryFieldForObject('Approved_Document_vod__c');
        String clmPresentationCountry = VDT_CustomMetadataService.getCountryFieldForObject('Clm_Presentation_vod__c');

        this.builder = new VDT_ProductAdoptionBuilder()
        .addCountryForObject('Account', accountCountry)
        .addCountryForObject('Key_Message_vod__c', keyMessageCountry)        
        .addCountryForObject('Approved_Document_vod__c', approvedDocumentCountry)
        .addCountryForObject('Clm_Presentation_vod__c', clmPresentationCountry);
        this.dataCalculationRecord.VDT_Job_Start_Date__c = Datetime.now();
        update this.dataCalculationRecord;
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Product_vod__c> records) {
        try {
            this.builder
            .withRecords(records)
            .withKeyMessages()
            .withActiveCLMs()
            .withApprovedDocuments()
            .withSentEmails(this.startDate, this.endDate)
            .withProductMetrics()
            .withCallDetails(this.startDate, this.endDate)
            .calculate();
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            VDT_DataCalculationService.sendStatusUpdateEvent(this.dataCalculationRecord.Id, VDT_DataCalculationService.STATUS_ERROR);
            throw e;
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug(JSON.serialize(this.builder.build()));
        try {
            this.dataCalculationRecord.VDT_Job_End_Date__c = Datetime.now();
            this.dataCalculationRecord.Status__c = VDT_DataCalculationService.STATUS_COMPLETED;
            this.dataCalculationRecord.VDT_Calculation_Date__c = Date.today();
            update this.dataCalculationRecord;

            Attachment currentAttachment = VDT_AttachmentService.getAttachmentForRecord(
                VDT_DataCalculationService.PRODUCT_ADOPTION_FILE_NAME,
                VDT_AttachmentService.JSON_FORMAT, 
                this.dataCalculationRecord.Id
            );
            if (currentAttachment == null) {
                VDT_AttachmentService.createAttachmentForRecord(
                    JSON.serialize('this.builder.build()'), 
                    VDT_DataCalculationService.PRODUCT_ADOPTION_FILE_NAME,
                    VDT_AttachmentService.JSON_FORMAT,
                    this.dataCalculationRecord.Id
                );
            } else {
                VDT_AttachmentService.updateAttachmentForRecord(
                    JSON.serialize('this.builder.build()'), 
                    VDT_DataCalculationService.PRODUCT_ADOPTION_FILE_NAME,
                    VDT_AttachmentService.JSON_FORMAT,
                    this.dataCalculationRecord.Id
                );
            }
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            VDT_DataCalculationService.sendStatusUpdateEvent(this.dataCalculationRecord.Id, VDT_DataCalculationService.STATUS_ERROR);
            throw e;
        }
    }
}