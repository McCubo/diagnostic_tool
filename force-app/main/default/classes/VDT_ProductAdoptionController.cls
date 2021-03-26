/**
 * @author          m.caceres@polsource.com
 * @created_date:   2021-03-25
 */
public inherited sharing class VDT_ProductAdoptionController {

    @AuraEnabled
    public static VDT_DataCalculationService.DataCalculation searchExistingCalculations(String jsonSearchParameters) {
        try {
            VDT_DataCalculationService.ProductAdoptionParameters searchParameters = (VDT_DataCalculationService.ProductAdoptionParameters)JSON.deserialize(
                jsonSearchParameters, 
                VDT_DataCalculationService.ProductAdoptionParameters.class
                );

            return VDT_DataCalculationService.getExistingCalculationProductAdoption(searchParameters);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void recalculateProductAdoption(String jsonSearchParameters){
        try {
            VDT_DataCalculationService.ProductAdoptionParameters calculationParameters = (VDT_DataCalculationService.ProductAdoptionParameters)JSON.deserialize(
                jsonSearchParameters, 
                VDT_DataCalculationService.ProductAdoptionParameters.class
            );
            VDT_DataCalculationService.triggerProductAdoptionCalculation(calculationParameters);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
}