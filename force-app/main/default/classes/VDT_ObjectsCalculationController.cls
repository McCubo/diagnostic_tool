/**
 * @description Provides Access to Apex Service Methods
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_ObjectsCalculationController {

    /**
     * 
     * @param jsonSearchParameters Search parameters selected by the User on the Object-Field Analysis screen
     * @return  `VDT_DataCalculationService.DataCalculation` record with all information about the calculation job: Status, Completion Date and Output data generated
     * @exception AuraHandledException
     */
    @AuraEnabled
    public static VDT_DataCalculationService.DataCalculation searchExistingCalculations(String calculationParametersString) {
        try {
            VDT_DataCalculationService.CalculationParameters calculationParameters = 
                (VDT_DataCalculationService.CalculationParameters)JSON.deserialize(
                    calculationParametersString, 
                    VDT_DataCalculationService.CalculationParameters.class
                );

            return VDT_DataCalculationService.getExistingCalculation(calculationParameters, VDT_DataCalculationSelector.OBJECT_ANALYSIS_RECORD_TYPE_DEV, VDT_ObjectService.FIELD_SUMMARY_CALCULATION_FILE_NAME);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 
     * @param jsonSearchParameters Search parameters selected by the User on the Object-Field Analysis screen
     * @return  `VDT_DataCalculationService.DataCalculation` record with all information about the calculation job: Status, Completion Date and Output data generated
     * @exception AuraHandledException
     */    
    @AuraEnabled
    public static VDT_DataCalculationService.DataCalculation searchExistingFieldOccurrenceCalculations(String calculationParametersString) {
        try {
            VDT_DataCalculationService.CalculationParameters calculationParameters = 
                (VDT_DataCalculationService.CalculationParameters)JSON.deserialize(
                    calculationParametersString, 
                    VDT_DataCalculationService.CalculationParameters.class
                );

            return VDT_DataCalculationService.getExistingCalculation(calculationParameters, VDT_DataCalculationSelector.FIELD_OCCURRENCE_RECORD_TYPE_DEV, VDT_ObjectService.FIELD_VALUES_OCCURRENCES_FILE_NAME);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @return  `Boolean` value that checks if the queue still has slots available to trigger a new job
     * @exception 
     */
    @AuraEnabled
    public static Boolean validateCanRunCalculation(){
        try {
            List<VDT_Data_Calculation__c> calculations = 
                new VDT_DataCalculationSelector().getDataCalculationsByStatus(
                    new List<String>{ 
                        VDT_DataCalculationService.STATUS_IN_PROGRESS, 
                        VDT_DataCalculationService.STATUS_IN_QUEUE 
                    }
                );

            Integer maxCalculationRequests = 
                VDT_CustomMetadataService.getMaxNumberOfCalculationRequests();

            return calculations.size() < maxCalculationRequests;
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description If the queue has availability, a new job is triggered for the selected jobs.
     * @param jsonSearchParameters Search parameters selected by the User on the Object-Field Analysis screen
     * @exception AuraHandledException
     */     
    @AuraEnabled
    public static void recalculateObjectFieldSummary(String calculationParametersString) {
        try {
            VDT_DataCalculationService.CalculationParameters calculationParameters = 
                (VDT_DataCalculationService.CalculationParameters)JSON.deserialize(
                    calculationParametersString, 
                    VDT_DataCalculationService.CalculationParameters.class
                );

            VDT_DataCalculationService.triggerCalculation(calculationParameters);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description If the queue has availability, a new job is triggered for the selected jobs.
     * @param jsonSearchParameters Search parameters selected by the User on the Object-Field Analysis screen
     * @exception AuraHandledException
     */      
    @AuraEnabled
    public static void recalculateFieldValuesOccurrences(String calculationParametersString) {
        try {
            VDT_DataCalculationService.CalculationParameters calculationParameters = 
                (VDT_DataCalculationService.CalculationParameters)JSON.deserialize(
                    calculationParametersString, 
                    VDT_DataCalculationService.CalculationParameters.class
                );

            VDT_DataCalculationService.triggerFieldValueOccurrenceCalculation(calculationParameters);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
}