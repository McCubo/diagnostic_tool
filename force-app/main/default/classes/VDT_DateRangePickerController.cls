/**
 * @description Exposes Apex Method to LWC Javascript controller
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_DateRangePickerController {

    /**
     * @return  `Integer` number of years to be added as options on the Start Year picklist component.
     * @exception AuraHandledException
     */
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