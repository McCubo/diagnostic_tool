public inherited sharing class VDT_CalculationLogsController {
    @AuraEnabled
    public static List<VDT_Data_Calculation__c> fetchFinishedCalculations(){
        try {
            return VDT_DataCalculationService.getFinishedCalculations();
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
}
