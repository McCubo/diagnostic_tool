public inherited sharing class VDT_AnalysisDashboardFilterController {
    @AuraEnabled(cacheable=true)
    public static String getStandardFieldIdentifier() {
        try {
            return VDT_CustomMetadataService.getStandardFieldIdentifier();
        } catch (Exception e) { 
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
}