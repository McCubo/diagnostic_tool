/**
 * @author      BASE Life Science
 * @since       2021.03.01
 * @description Exposes apex methods to be used in LWC component's Javascript controller
 */
public with sharing class VDT_CalculationMonitoringController {

    /**
     * @return  `VDT_DataCalculationService.MonitoringData` object containing all information regarding how many jobs are currently in 
     *          progress, in queue and how many jobs can still be added to the queue
     * @exception AuraHandledException exception to be handled on the LWC.
     */
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