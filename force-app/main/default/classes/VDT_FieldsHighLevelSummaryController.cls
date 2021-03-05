public with sharing class VDT_FieldsHighLevelSummaryController {
    private static final String HEAP_SIZE_LIMIT_MSG = 'Apex heap size too large';

    private class DataCalculation {
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String data;
    }
    @AuraEnabled
    public static DataCalculation getObjectFieldsSummaryData(String objectName) {
        try {
            List<VDT_Data_Calculation__c> calculations = [ 
                SELECT  Id, Status__c
                FROM    VDT_Data_Calculation__c 
                WHERE   VDT_Object_Name__c = :objectName 
                WITH    SECURITY_ENFORCED
            ];

            DataCalculation dc = new DataCalculation();

            if (calculations.isEmpty() == false) {
                dc.status = calculations[0].Status__c;
                Attachment att = VDT_AttachmentService.getAttachmentForRecord(
                    VDT_ObjectService.FIELD_SUMMARY_CALCULATION_FILE_NAME,
                    VDT_AttachmentService.JSON_FORMAT, 
                    calculations[0].Id
                );

                if (att != null) {
                    dc.data = att.Body.toString();
                }
            }
            
            return dc;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}