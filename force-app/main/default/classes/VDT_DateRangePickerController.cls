public inherited sharing class VDT_DateRangePickerController {
    @AuraEnabled(cacheable=true)
    public static Integer getStartDateYearDecrement(){
        try {
            return VDT_CustomMetadataService.getStartDateYearDecrement();
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
}
