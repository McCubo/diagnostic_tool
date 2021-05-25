/**
 * @author      BASE Life Science
 * @since       2021.03.01
 * @description Exposes apex methods to be used in LWC component's Javascript controller
 */
public inherited sharing class VDT_CalculationLogsController {

    /**
     * @return  `List<VDT_Data_Calculation__c>` List of Data Calculation records that have been completed (either their status is COMPLETED or ERROR)
     * @exception AuraHandledException
     */
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