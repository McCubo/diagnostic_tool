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

    @AuraEnabled(cacheable=true)
    public static String getAccountCountryFieldType() {
        try {
            String accountSObject = 'Account';
            String countryFieldName = VDT_CustomMetadataService.getCountryFieldForObject(accountSObject);
            return VDT_ObjectService.getFieldTypeBySObjectName(accountSObject, countryFieldName);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<VDT_OptionWrapper> getCountryOptions() {
        try {
            String accountSObject = 'Account';
            String countryFieldName = VDT_CustomMetadataService.getCountryFieldForObject(accountSObject);
            return VDT_ObjectService.getPicklistOptionsBySObjectName(SObjectType.Account, countryFieldName);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void recalculateMasterAnalysis(String jsonSearchParameters) {
        try {
            VDT_DataCalculationService.CalculationAnalysisParameters calculationParameters = (VDT_DataCalculationService.CalculationAnalysisParameters)JSON.deserialize(
                jsonSearchParameters, 
                VDT_DataCalculationService.CalculationAnalysisParameters.class
            );
            VDT_DataCalculationService.triggerMasterAnalysisCalculation(calculationParameters);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isTerritoryManagementActive(){
        try {
            return VDT_CustomMetadataService.isTerritoryManagementActive();
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
}
