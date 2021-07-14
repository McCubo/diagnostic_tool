/**
 * @description provides access to apex service methods to LWC javascript controllers
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_ProductAdoptionController {

    /**
     * 
     * @param jsonSearchParameters Search parameters selected by the User on the Product Hierarchy and Adoption screen
     * @return  `VDT_DataCalculationService.DataCalculation` record with all information about the calculation job: Status, Completion Date and Output data generated
     * @exception AuraHandledException
     */    
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

    /**
     * @description If the queue has availability, a new job is triggered for the selected jobs.
     * @param jsonSearchParameters Search parameters selected by the User on the Master Data Analysis screen
     * @exception AuraHandledException
     */
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

    /**
     * 
     * @return  `VDT_ProductService.ProductAdoptionData`
     * @exception AuraHandledException
     */
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

    /**
     * @return  `String` Field Type of Country field for Product
     * @exception 
     */
    @AuraEnabled
    public static String getProductCountryFieldType() {
        try {
            String productSObjectAPIName = VDT_CustomMetadataService.getProductCatalogObjectAPI();
            String countryFieldName = VDT_CustomMetadataService.getCountryFieldForObject(productSObjectAPIName);
            return VDT_ObjectService.getFieldTypeBySObjectName(productSObjectAPIName, countryFieldName);
        } catch (Exception e) {
            System.debug('e: ' + e.getCause() + '  ' + e.getStackTraceString());
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
     * @description if country field for product is a `PICKLIST` field, the only active options from that field are elegible for user's selection
     * @return  `List<VDT_OptionWrapper>` country options
     * @exception AuraHandledException
     */
    @AuraEnabled
    public static List<VDT_OptionWrapper> getCountryOptions() {
        try {
            String productSObjectAPIName = VDT_CustomMetadataService.getProductCatalogObjectAPI();
            String countryFieldName = VDT_CustomMetadataService.getCountryFieldForObject(productSObjectAPIName);
            SObjectType sObjType = ((SObject) Type.forName(productSObjectAPIName).newInstance()).getSObjectType();
            return VDT_ObjectService.getPicklistOptionsBySObjectName(sObjType.getDescribe(), countryFieldName);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description if country field for Product is a `LOOKUP` field, then the options available for selection are taken from the
     *              list of related sobject records
     * @return  `List<VDT_OptionWrapper>` country options to be added to the select LWC component
     * @exception AuraHandledException
     */
    @AuraEnabled
    public static List<VDT_OptionWrapper> getCountryOptionFromReference() {
        try {
            String productSObjectAPIName = VDT_CustomMetadataService.getProductCatalogObjectAPI();
            String countryFieldName = VDT_CustomMetadataService.getCountryFieldForObject(productSObjectAPIName);
            return VDT_ObjectService.getPicklistOptionsByReference(productSObjectAPIName, countryFieldName);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description If country field for Product is a `TEXT` field, then the options shown on the select component will be taken
     *              from the getDefaultCountries from Default Settings
     * @return  `List<VDT_OptionWrapper>`
     */
    @AuraEnabled
    public static List<VDT_OptionWrapper> getCountryCodeFromProductSetup() {
        return VDT_CustomMetadataService.getDefaultCountries();
    }

    /**
     * @return  `String` Country field that identifies a product as an International product
     */
    @AuraEnabled(cacheable=true)
    public static String getInternationalCountryValue() {
        return VDT_CustomMetadataService.getInternationalCountryValue();
    }

    @AuraEnabled
    public static List<VDT_DataCalculationService.DataCalculationLog> fetchFinishedCalculations() {
        try {
            return VDT_DataCalculationService.getFinishedCalculationsWithDetailsByRecordType(
                VDT_DataCalculationSelector.PRODUCT_ADOPTION_RECORD_TYPE_DEV, 
                new List<String>{
                    'VDT_Country__c',
                    'Start_Month__c', 
                    'Start_Year__c', 
                    'Start_Date__c', 
                    'End_Year__c',
                    'End_Month__c',
                    'End_Date__c', 
                    'VDT_Job_Start_Date__c', 
                    'VDT_Job_End_Date__c', 
                    'CreatedBy.Name'
                });
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }    
}