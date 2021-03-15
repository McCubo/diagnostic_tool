/**
 * @author          m.caceres@polsource.com
 * @created_date:   2021-03-12
 * @description:    provide access to service layer methods to Lightning Web Components.
 */
public inherited sharing class VDT_MasterDataAnalysisController {

    @AuraEnabled
    public static VDT_DataCalculationService.DataCalculation searchExistingCalculations(String jsonSearchParameters) {
        try {
            VDT_DataCalculationService.CalculationAnalysisParameters calculationParameters = (VDT_DataCalculationService.CalculationAnalysisParameters)JSON.deserialize(
                jsonSearchParameters, 
                VDT_DataCalculationService.CalculationAnalysisParameters.class
                );

            return VDT_DataCalculationService.getExistingCalculationMasterAnalysis(calculationParameters);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

}
