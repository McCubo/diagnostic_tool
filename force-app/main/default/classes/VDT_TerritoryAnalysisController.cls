public inherited sharing class VDT_TerritoryAnalysisController {

    @AuraEnabled
    public static VDT_DataCalculationService.DataCalculation searchExistingCalculations(String jsonSearchParameters) {
        try {
            VDT_DataCalculationService.TerritoryAnalysisParameters calculationParameters = (VDT_DataCalculationService.TerritoryAnalysisParameters)JSON.deserialize(
                jsonSearchParameters, 
                VDT_DataCalculationService.TerritoryAnalysisParameters.class
                );
            return VDT_DataCalculationService.getExistingTerritoryAnalysisCalculation(calculationParameters);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void recalculateTerritoryAnalysis(String jsonSearchParameters) {
        try {
            VDT_DataCalculationService.TerritoryAnalysisParameters calculationParameters = (VDT_DataCalculationService.TerritoryAnalysisParameters)JSON.deserialize(
                jsonSearchParameters, 
                VDT_DataCalculationService.TerritoryAnalysisParameters.class
            );
            VDT_DataCalculationService.triggerTerritoryAnalysisCalculation(calculationParameters);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
}
