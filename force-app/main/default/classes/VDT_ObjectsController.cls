public with sharing class VDT_ObjectsController {

    @AuraEnabled
    public static DataCalculation searchExistingCalculations(String objectName, Integer startYear, Integer startMonth, Integer endYear, Integer endMonth) {
        try {
            List<VDT_Data_Calculation__c> calculations = [ 
                SELECT  Id, Status__c, VDT_Calculation_Date__c
                FROM    VDT_Data_Calculation__c 
                WHERE   VDT_Object_Name__c = :objectName AND
                        Status__c = 'Completed' AND
                        Start_Year__c = :startYear AND
                        Start_Month__c = :startMonth AND
                        End_Year__c = :endYear AND
                        End_Month__c = :endMonth
                WITH    SECURITY_ENFORCED
            ];

            system.debug('calculations :: ' + calculations);

            DataCalculation calculation = null;

            if (calculations.isEmpty() == false) {
                calculation = new DataCalculation();
                calculation.status = calculations[0].Status__c;
                calculation.calculationDate = String.valueOf(calculations[0].VDT_Calculation_Date__c);
                Attachment att = VDT_AttachmentService.getAttachmentForRecord(
                    VDT_ObjectService.FIELD_SUMMARY_CALCULATION_FILE_NAME,
                    VDT_AttachmentService.JSON_FORMAT, 
                    calculations[0].Id
                );

                if (att != null) {
                    calculation.data = att.Body.toString();
                }
            }
            
            return calculation;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void recalculateObjectFieldSummary(String objectName, Date startDate, Date endDate) {
        try {
            // VDT_FieldsSummaryCalculationBatch fieldSummaryBatch = 
            //     new VDT_FieldsSummaryCalculationBatch(objectName, startDate, endDate); 
            // Database.executeBatch(fieldSummaryBatch);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    private class DataCalculation {
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String calculationDate;
        @AuraEnabled
        public String data;
    }
}