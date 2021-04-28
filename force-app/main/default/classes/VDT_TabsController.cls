public with sharing class VDT_TabsController {

    @AuraEnabled(cacheable=true)
    public static string getActiveMainMenuOptions() {
        try {
            System.debug('TEST:VDT_CustomMetadataService.getActiveMenuOptions(): ' + VDT_CustomMetadataService.getActiveMenuOptions());
            return VDT_CustomMetadataService.getActiveMenuOptions();
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
}