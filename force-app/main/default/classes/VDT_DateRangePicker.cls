public inherited sharing class VDT_DateRangePicker {
    @AuraEnabled(cacheable=true)
    public static Integer getStartDateYearDecrement(){
        try {
            return VDT_CustomMetadataService.getStartDateYearDecrement();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}