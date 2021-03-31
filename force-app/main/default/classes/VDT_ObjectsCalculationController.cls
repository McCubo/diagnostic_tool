public inherited sharing class VDT_ObjectsCalculationController {
    @AuraEnabled
    public static VDT_DataCalculationService.DataCalculation searchExistingCalculations(String calculationParametersString) {
        try {
            VDT_DataCalculationService.CalculationParameters calculationParameters = 
                (VDT_DataCalculationService.CalculationParameters)JSON.deserialize(
                    calculationParametersString, 
                    VDT_DataCalculationService.CalculationParameters.class
                );

            return VDT_DataCalculationService.getExistingCalculation(calculationParameters);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

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
}