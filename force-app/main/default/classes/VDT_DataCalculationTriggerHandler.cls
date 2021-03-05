/**
 * Trigger Handler for Account object
 */
public with sharing class VDT_DataCalculationTriggerHandler extends VDT_TriggerHandler.DelegateBase {

    public VDT_DataCalculationTriggerHandler() {
    }
    public override void afterUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        validateRun();
        setAfterUpdate((Map<Id, VDT_Data_Calculation__c>) oldMap, (Map<Id, VDT_Data_Calculation__c>) newMap);
    }

    /**
     * setAfterUpdate update field values before inserting records
     * @param  accounts accounts to be updated
     */
    private void setAfterUpdate(Map<Id, VDT_Data_Calculation__c> oldMap, Map<Id, VDT_Data_Calculation__c> newMap) {
        Integer freeCalculationSlots = 0;
        for(VDT_Data_Calculation__c dataCalculation : newMap.values()) {
            VDT_Data_Calculation__c oldDataCalculation = oldMap.get(dataCalculation.Id);
            if (oldDataCalculation.Status__c == 'In Progress' && dataCalculation.Status__c == 'Completed' ||
                oldDataCalculation.Status__c == 'In Progress' && dataCalculation.Status__c == 'Error') {
                freeCalculationSlots++;
            }
        }

        
        if (freeCalculationSlots > 0) {
            List<VDT_Data_Calculation__c> queuedCalculations = 
            new VDT_DataCalculationSelector().withLimit(freeCalculationSlots)
                .getDataCalculationsByStatus(new List<String>{ VDT_DataCalculationService.STATUS_IN_QUEUE});
            
            for (VDT_Data_Calculation__c queuedCalculation : queuedCalculations) {
                queuedCalculation.Status__c = 'In Progress';
                Integer batchSize = 
                    VDT_CustomMetadataService.getBatchSizeForObject(queuedCalculation.VDT_Object_Name__c);
                VDT_FieldsSummaryCalculationBatch fieldSummaryBatch = 
                    new VDT_FieldsSummaryCalculationBatch(queuedCalculation);
                Database.executeBatch(fieldSummaryBatch, batchSize);
            }

            update queuedCalculations;
        }
    }
}
