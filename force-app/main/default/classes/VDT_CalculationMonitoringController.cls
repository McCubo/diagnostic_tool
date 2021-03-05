public with sharing class VDT_CalculationMonitoringController {
    @AuraEnabled
    public static VDT_DataCalculationService.MonitoringData getCalculationsInProgress(){
        try {
            return VDT_DataCalculationService.getMonitoringData();
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
}
