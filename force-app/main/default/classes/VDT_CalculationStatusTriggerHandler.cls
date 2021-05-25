/**
 * @author      BASE Life Science
 * @since       2021.03.01
 * @description Whenever an exception is thrown, a new platform event (VDT_Calculation_Status_Update__e) is triggered and the Data Calculation record that caused the exception
 *              is updated accordingly
 */
public with sharing class VDT_CalculationStatusTriggerHandler extends VDT_TriggerHandler.DelegateBase {
    public VDT_CalculationStatusTriggerHandler() {}

    public override void afterInsert(Map<Id, sObject> newMap) {
        validateRun();
        setAfterInsert((Map<Id, VDT_Calculation_Status_Update__e>) newMap);
    }

    /**
     * 
     * @param newMap Data Calculation records' status is updated based on the event's status
     */
    private void setAfterInsert(Map<Id, VDT_Calculation_Status_Update__e> newMap) {
        List<VDT_Data_Calculation__c> calculations = new List<VDT_Data_Calculation__c>();

        for (VDT_Calculation_Status_Update__e event : newMap.values()) {
            calculations.add(
                new VDT_Data_Calculation__c(
                    Id = event.Calculation_Id__c,
                    Status__c = event.Status__c
                )
            );
        }

        List<Database.SaveResult> res = Database.update(calculations, false);
        for (Database.SaveResult saveRes : res) {
            if (!saveRes.isSuccess()) {
                VDT_Log.get().add('Failed to update calculation status: ' + saveRes, VDT_LogSeverity.ERROR);
                VDT_Log.get().publish();
            }
        }
    }
}