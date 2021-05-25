/**
 * @description Provides Access to Apex Service Methods
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_MasterDataAnalysisController {

    private static final String ACCOUNT_SOBJECT = 'Account';

    /**
     * 
     * @param jsonSearchParameters Search parameters selected by the User on the Master Data Analysis screen
     * @return  `VDT_DataCalculationService.DataCalculation` record with all information about the calculation job: Status, Completion Date and Output data generated
     * @exception AuraHandledException
     */
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

    /**
     * @description Method is used to determine what values to use when populating the options on the Picklist component (Master Data Analysis)
     * @return  `String` Field Type of the configured Country field for Account.
     * @exception AuraHandledException
     */
    @AuraEnabled(cacheable=true)
    public static String getAccountCountryFieldType() {
        try {
            String countryFieldName = VDT_CustomMetadataService.getCountryFieldForObject(ACCOUNT_SOBJECT);
            return VDT_ObjectService.getFieldTypeBySObjectName(ACCOUNT_SOBJECT, countryFieldName);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description If Country field for Account is `Picklist` field, then the select component on Master Data Analysis will be populated with the active
     *              options that picklist has.
     * @return  `List<VDT_OptionWrapper>` List of valid Account countries
     * @exception AuraHandledException
     */
    @AuraEnabled
    public static List<VDT_OptionWrapper> getCountryOptions() {
        try {
            String countryFieldName = VDT_CustomMetadataService.getCountryFieldForObject(ACCOUNT_SOBJECT);
            return VDT_ObjectService.getPicklistOptionsBySObjectName(SObjectType.Account, countryFieldName);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description If the country field configured for Account is a `Lookup` field, then we need to query the related object and populate the options with all records
     *              returned by the query.
     * @return  `List<VDT_OptionWrapper>` List of valid Account countries
     * @exception AuraHandledException
     */
    @AuraEnabled
    public static List<VDT_OptionWrapper> getCountryOptionFromReference() {
        try {
            String countryFieldName = VDT_CustomMetadataService.getCountryFieldForObject(ACCOUNT_SOBJECT);
            return VDT_ObjectService.getPicklistOptionsByReference(ACCOUNT_SOBJECT, countryFieldName);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description If the queue has availability, a new job is triggered for the selected jobs.
     * @param jsonSearchParameters Search parameters selected by the User on the Master Data Analysis screen
     * @exception AuraHandledException
     */    
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

    /**
     * @return  `Boolean` value that determines whether the `Territory Management` column should be shown or not in the Details table on Master Data Analysis Screen
     */
    @AuraEnabled(cacheable=true)
    public static Boolean isTerritoryManagementActive(){
        return VDT_CustomMetadataService.isTerritoryManagementActive();
    }
}