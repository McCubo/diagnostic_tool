/**
 * @description Trigger Handler for VDT_Data_Calculation__c object
 * @author BASE Life Science
 * @since 2021.03.01
 */
public with sharing class VDT_DataCalculationTriggerHandler extends VDT_TriggerHandler.DelegateBase {

    public VDT_DataCalculationTriggerHandler() {
    }
    /**
     * 
     * @param oldMap A copy of all records before they were updated
     * @param newMap A list of new records
     */
    public override void afterUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        validateRun();
        setAfterUpdate((Map<Id, VDT_Data_Calculation__c>) oldMap, (Map<Id, VDT_Data_Calculation__c>) newMap);
    }

    /**
     * @description When a Calculation job completes, it updates the status of its VDT_Data_Calculation record to `COMPLETED`
     *              So, if there are records `IN QUEUE`, we need to trigger the appropiate job based on their record type.
     *              Once the job has been trigger, we set the VDT_Data_Calculation status to `IN PROGRESS`.
     *              This process will be repetead the same number of time as the number of records `IN QUEUE`
     * @param oldMap A copy of all records before they were updated
     * @param newMap 
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
            
            List<RecordType> dataCalculationRecordTypes = VDT_RecordTypeService.getAllRecordTypesByObject('VDT_Data_Calculation__c');
            Map<String, String> recordTypeNameById = new Map<String, String>();
            for (RecordType dataCalculationRecordType : dataCalculationRecordTypes) {
                recordTypeNameById.put(dataCalculationRecordType.Id, dataCalculationRecordType.DeveloperName);
            }
            for (VDT_Data_Calculation__c queuedCalculation : queuedCalculations) {
                if (recordTypeNameById.containsKey(queuedCalculation.RecordTypeId)) {
                    queuedCalculation.Status__c = 'In Progress';
                    if (recordTypeNameById.get(queuedCalculation.RecordTypeId) == VDT_DataCalculationSelector.OBJECT_ANALYSIS_RECORD_TYPE_DEV) {                        
                        Integer batchSize = VDT_CustomMetadataService.getBatchSizeForObject(queuedCalculation.VDT_Object_Name__c);
                        VDT_FieldsSummaryCalculationBatch fieldSummaryBatch = new VDT_FieldsSummaryCalculationBatch(queuedCalculation);
                        Database.executeBatch(fieldSummaryBatch, batchSize);
                    } else if (recordTypeNameById.get(queuedCalculation.RecordTypeId) == VDT_DataCalculationSelector.MASTER_ANALYSIS_RECORD_TYPE_DEV) {
                        Integer batchSize = VDT_CustomMetadataService.getBatchSizeForObject('Account');
                        VDT_MasterAnalysisCalculationBatch masterAnalysisBatch = new VDT_MasterAnalysisCalculationBatch(queuedCalculation);
                        Database.executeBatch(masterAnalysisBatch, batchSize);
                    } else if (recordTypeNameById.get(queuedCalculation.RecordTypeId) == VDT_DataCalculationSelector.FIELD_OCCURRENCE_RECORD_TYPE_DEV) {
                        Integer batchSize = VDT_CustomMetadataService.getBatchSizeForObject(queuedCalculation.VDT_Object_Name__c);
                        VDT_FieldValuesOccurrencesBatch fieldValueOccurrenceBatch = new VDT_FieldValuesOccurrencesBatch(queuedCalculation);
                        Database.executeBatch(fieldValueOccurrenceBatch, batchSize);
                    } else if (recordTypeNameById.get(queuedCalculation.RecordTypeId) == VDT_DataCalculationSelector.PRODUCT_ADOPTION_RECORD_TYPE_DEV) {
                        VDT_ProductAdoptionBatch productAdoptionBatch = new VDT_ProductAdoptionBatch(queuedCalculation);
                        Database.executeBatch(productAdoptionBatch);
                    } else if (recordTypeNameById.get(queuedCalculation.RecordTypeId) == VDT_DataCalculationSelector.TERRITORY_ANALYSIS_RECORD_TYPE_DEV) {
                        Integer batchSize = VDT_CustomMetadataService.getBatchSizeForObject('Account');
                        VDT_TerritoryManagementBatch territoryAnalysisBatch = new VDT_TerritoryManagementBatch(queuedCalculation);
                        Database.executeBatch(territoryAnalysisBatch, batchSize);
                    } else if (recordTypeNameById.get(queuedCalculation.RecordTypeId) == VDT_DataCalculationSelector.FIELD_LEVEL_SECURITY_RECORD_TYPE_DEV) {
                        Integer batchSize = VDT_CustomMetadataService.getBatchSizeForObject(queuedCalculation.VDT_Object_Name__c);
                        VDT_FieldLevelSecurityBatch fieldLevelSecurityBatch = new VDT_FieldLevelSecurityBatch(queuedCalculation);
                        Database.executeBatch(fieldLevelSecurityBatch, batchSize);
                    }
                }

            }

            update queuedCalculations;
        }
    }
}