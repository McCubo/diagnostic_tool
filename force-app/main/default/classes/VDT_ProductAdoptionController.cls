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

    @AuraEnabled
    public static VDT_ProductService.ProductAdoptionData getProductCatalogTree() {
        try {
            return VDT_ProductService.getProductTreeInformation();
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getProductCountryFieldType() {
        try {
            String countryFieldName = VDT_CustomMetadataService.getCountryFieldForObject('Product_vod__c');
            return VDT_ObjectService.getFieldTypeBySObjectName('Product_vod__c', countryFieldName);
        } catch (Exception e) {
            System.debug('e: ' + e.getCause() + '  ' + e.getStackTraceString());
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<VDT_OptionWrapper> getCountryOptions() {
        try {
            String countryFieldName = VDT_CustomMetadataService.getCountryFieldForObject('Product_vod__c');
            return VDT_ObjectService.getPicklistOptionsBySObjectName(SObjectType.Product_vod__c, countryFieldName);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<VDT_OptionWrapper> getCountryOptionFromReference() {
        try {
            String countryFieldName = VDT_CustomMetadataService.getCountryFieldForObject('Product_vod__c');
            return VDT_ObjectService.getPicklistOptionsByReference('Product_vod__c', countryFieldName);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<VDT_OptionWrapper> getCountryCodeFromProductSetup(){
        try {
            return VDT_CustomMetadataService.getDefaultCountries();
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getInternationalCountryValue(){
        try {
            return VDT_CustomMetadataService.getInternationalCountryValue();
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
}