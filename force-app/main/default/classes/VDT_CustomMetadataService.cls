public inherited sharing class VDT_CustomMetadataService {
    public static final String DEFAULT_APP_SETTINGS = 'Default';
    public static final String VDT_GENERAL_SETTINGS = 'VDT_General_Setting__mdt';
    public static final String VDT_QUERIES = 'VDT_Query__mdt';
    public static final String VDT_COUNTRY_FIELD_MAPPING = 'VDT_Object_Country_Field_Mapping__mdt';
    public static final String VDT_PRODUCT_FIELD_MAPPING = 'VDT_Object_Product_Field_Mapping__mdt';
    public static final String VDT_CUSTOM_OBJECT_FIELD_MAPPING = 'VDT_Custom_Objects_Field_Mapping__mdt';
    public static final String VDT_KPI_CONFIGURATIONS = 'VDT_KPI_Configuration__mdt';
    public static final String VDT_KPI_BY_COUNTRY_CONFIGURATIONS = 'VDT_KPI_by_Country__mdt';    
    public static final String VDT_ACCOUNT_RECORD_TYPE_CONFIGURATIONS = 'VDT_Account_Record_Type_Mapping__mdt';    
    public static final String VDT_BATCH_SIZE_MAPPING = 'VDT_Object_Batch_Size_Mapping__mdt';
    @TestVisible
    private static Map<String, List<SObject>> customMetadataWithRecords = new Map<String, List<SObject>>();

    public static String getPackageVersion() {
        String packageVersion;
        List<VDT_General_Setting__mdt> defaultSettings  = [SELECT  Package_Version__c 
                                                           FROM VDT_General_Setting__mdt
                                                           WHERE DeveloperName = :DEFAULT_APP_SETTINGS 
                                                           WITH SECURITY_ENFORCED];
        if (customMetadataWithRecords.containsKey(VDT_GENERAL_SETTINGS)) {
            defaultSettings = customMetadataWithRecords.get(VDT_GENERAL_SETTINGS);
        }

        if (!defaultSettings.isEmpty()) {
            packageVersion = defaultSettings[0].Package_Version__c;
        }        
        return packageVersion;
    }

    public static Map<String,String> getQueriesByPackageVersionAndModule(String packageVersion, String moduleName) {
        Map<String,String> queriesByName = new Map<String,String>();
        List<VDT_Query__mdt> queries  = [SELECT  Name__c, Query__c 
                                                 FROM VDT_Query__mdt
                                                 WHERE Package_Version__c = :packageVersion
                                                 AND Module_Name__c = :moduleName
                                                 WITH SECURITY_ENFORCED];
        if (customMetadataWithRecords.containsKey(VDT_QUERIES)) {
            queries = customMetadataWithRecords.get(VDT_QUERIES);
        }
        for (VDT_Query__mdt query : queries) {
            queriesByName.put(query.Name__c, query.Query__c);
        }
        return queriesByName;
    }

    public static String getFieldNameForCustomObject(String mappingName) {
        String fieldName;
        List<VDT_Custom_Objects_Field_Mapping__mdt> objectFieldMappings;       
        objectFieldMappings = [
            SELECT  Id,
                    Field_API_Name__c
            FROM    VDT_Custom_Objects_Field_Mapping__mdt
            WHERE   DeveloperName = :mappingName
            WITH    SECURITY_ENFORCED
        ];
        if (customMetadataWithRecords.containsKey(VDT_CUSTOM_OBJECT_FIELD_MAPPING)) {
            objectFieldMappings = customMetadataWithRecords.get(VDT_CUSTOM_OBJECT_FIELD_MAPPING);
        }

        if (!objectFieldMappings.isEmpty()) {
            fieldName = objectFieldMappings[0].Field_API_Name__c;
        }        
        return fieldName;
    }

    public static String getProductFieldForObject(String objectName) {
        String productField;
        List<VDT_Object_Product_Field_Mapping__mdt> productFieldMappings;
        productFieldMappings = [
            SELECT  Id,
                    Product_Field_Reference__c
            FROM    VDT_Object_Product_Field_Mapping__mdt
            WHERE   MasterLabel = :objectName
            WITH    SECURITY_ENFORCED
        ];
        if (customMetadataWithRecords.containsKey(VDT_PRODUCT_FIELD_MAPPING)) {
            productFieldMappings = customMetadataWithRecords.get(VDT_PRODUCT_FIELD_MAPPING);
        }

        if (!productFieldMappings.isEmpty()) {
            productField = productFieldMappings[0].Product_Field_Reference__c;
        }

        return productField;
    }

    public static List<VDT_OptionWrapper> getDefaultCountries() {
        List<VDT_OptionWrapper> options = new List<VDT_OptionWrapper>();
        List<VDT_General_Setting__mdt> defaultSettings;
        defaultSettings = [
            SELECT  VDT_Default_Countries__c
            FROM    VDT_General_Setting__mdt
            WHERE   DeveloperName = :DEFAULT_APP_SETTINGS
            WITH    SECURITY_ENFORCED
        ];
        if (customMetadataWithRecords.containsKey(VDT_GENERAL_SETTINGS)) {
            defaultSettings = customMetadataWithRecords.get(VDT_GENERAL_SETTINGS);
        }
        if (!defaultSettings.isEmpty()) {
            String countriesCsv = defaultSettings[0].VDT_Default_Countries__c;
            for (String countryCode : countriesCsv.split(',')) {
                options.add(new VDT_OptionWrapper(countryCode, countryCode));
            }
        }
        return options;
    }

    public static String getInternationalCountryValue() {
        String intCountryVal;
        List<VDT_General_Setting__mdt> defaultSettings;
        
        defaultSettings = [
            SELECT  International_Country__c
            FROM    VDT_General_Setting__mdt
            WHERE   DeveloperName = :DEFAULT_APP_SETTINGS
            WITH    SECURITY_ENFORCED
        ];
        if (customMetadataWithRecords.containsKey(VDT_GENERAL_SETTINGS)) {
            defaultSettings = customMetadataWithRecords.get(VDT_GENERAL_SETTINGS);
        }

        if (!defaultSettings.isEmpty()) {
            intCountryVal = defaultSettings[0].International_Country__c;
        }        
        return intCountryVal;
    }

    public static Boolean isTerritoryManagementActive() {
        Boolean isActive = false;
        List<VDT_General_Setting__mdt> defaultSettings;        
        defaultSettings = [
            SELECT  VDT_Is_Territory_Management_Active__c
            FROM    VDT_General_Setting__mdt
            WHERE   DeveloperName = :DEFAULT_APP_SETTINGS
            WITH    SECURITY_ENFORCED
        ];
        if (customMetadataWithRecords.containsKey(VDT_GENERAL_SETTINGS)) {
            defaultSettings = customMetadataWithRecords.get(VDT_GENERAL_SETTINGS);
        }

        if (!defaultSettings.isEmpty()) {
            isActive = defaultSettings[0].VDT_Is_Territory_Management_Active__c;
        }        
        return isActive;
    }

    public static List<VDT_KPI_Configuration__mdt> getActiveKpiConfigurations() {
        List<VDT_KPI_Configuration__mdt> configurations = new List<VDT_KPI_Configuration__mdt>();        
        configurations = [
            SELECT  VDT_Display_Order__c, DeveloperName, VDT_Type__c, Description__c, VDT_Formula_Text__c, VDT_Help_Text__c, VDT_Default_Target__c
            FROM    VDT_KPI_Configuration__mdt
            WHERE   VDT_Is_Active__c = TRUE                
            WITH    SECURITY_ENFORCED
            ORDER BY VDT_Display_Order__c DESC
        ];
        if (customMetadataWithRecords.containsKey(VDT_KPI_CONFIGURATIONS)) {
            configurations = customMetadataWithRecords.get(VDT_KPI_CONFIGURATIONS);
        }
        return configurations;
    }

    public static Map<String, Decimal> getCountryKpiConfigurations() {
        List<VDT_KPI_by_Country__mdt> configurations = new List<VDT_KPI_by_Country__mdt>();
        configurations = [
            SELECT  VDT_Country__c, VDT_KPI_Configuration__r.DeveloperName, VDT_Target__c
            FROM    VDT_KPI_by_Country__mdt
            WITH    SECURITY_ENFORCED
        ];
        if (customMetadataWithRecords.containsKey(VDT_KPI_BY_COUNTRY_CONFIGURATIONS)) {
            configurations = customMetadataWithRecords.get(VDT_KPI_BY_COUNTRY_CONFIGURATIONS);
        }
        Map<String, Decimal> targetByCountryAndKpi = new Map<String, Decimal>();
        for (VDT_KPI_by_Country__mdt config : configurations) {
            targetByCountryAndKpi.put(config.VDT_Country__c + '_' + config.VDT_KPI_Configuration__r.DeveloperName, config.VDT_Target__c);
        }
        return targetByCountryAndKpi;
    }

    public static Map<String, List<String>> getAccountRecordTypesByType() {
        List<VDT_Account_Record_Type_Mapping__mdt> recordTypeConfigurations = new List<VDT_Account_Record_Type_Mapping__mdt>();
        recordTypeConfigurations = [
            SELECT  DeveloperName, Account_Record_Types__c
            FROM    VDT_Account_Record_Type_Mapping__mdt
            WITH    SECURITY_ENFORCED
        ];
        if (customMetadataWithRecords.containsKey(VDT_ACCOUNT_RECORD_TYPE_CONFIGURATIONS)) {
            recordTypeConfigurations = customMetadataWithRecords.get(VDT_ACCOUNT_RECORD_TYPE_CONFIGURATIONS);
        }
        Map<String, List<String>> accountRecordTypesByType = new Map<String, List<String>>();
        for (VDT_Account_Record_Type_Mapping__mdt recordTypeConfiguration : recordTypeConfigurations) {
            accountRecordTypesByType.put(recordTypeConfiguration.DeveloperName, recordTypeConfiguration.Account_Record_Types__c.split(','));
        }
        return accountRecordTypesByType;
    }

    public static String getCountryFieldForObject(String objectName) {
        String countryField;
        List<VDT_Object_Country_Field_Mapping__mdt> countryFieldMappings;
        if (!customMetadataWithRecords.containsKey(VDT_COUNTRY_FIELD_MAPPING)) {        
            countryFieldMappings = [
                SELECT  Id,
                        Country_Field_Reference__c
                FROM    VDT_Object_Country_Field_Mapping__mdt
                WHERE   MasterLabel = :objectName
                WITH    SECURITY_ENFORCED
            ];
        } else {
            countryFieldMappings = customMetadataWithRecords.get(VDT_COUNTRY_FIELD_MAPPING);
        }

        if (countryFieldMappings.isEmpty()) {
            countryField = getDefaultCountryField();
        } else {
            countryField = countryFieldMappings[0].Country_Field_Reference__c;
        }

        return countryField;
    }

    public static String getAccountSpecialtyField() {
        String specialtyField;
        List<VDT_General_Setting__mdt> defaultSettings;
        defaultSettings = [
            SELECT  VDT_Default_Specialty_Field__c
            FROM    VDT_General_Setting__mdt
            WHERE   DeveloperName = :DEFAULT_APP_SETTINGS
            WITH    SECURITY_ENFORCED
        ];
        if (customMetadataWithRecords.containsKey(VDT_GENERAL_SETTINGS)) {
            defaultSettings = customMetadataWithRecords.get(VDT_GENERAL_SETTINGS);
        }

        if (!defaultSettings.isEmpty()) {
            specialtyField = defaultSettings[0].VDT_Default_Specialty_Field__c;
        }        
        return specialtyField;
    }

    public static String getDefaultCountryField() {
        String countryField;

        List<VDT_General_Setting__mdt> defaultSettings;
        if (!customMetadataWithRecords.containsKey(VDT_GENERAL_SETTINGS)) {        
            defaultSettings = [
                SELECT  Default_Country_Code_Field__c
                FROM    VDT_General_Setting__mdt
                WHERE   DeveloperName = :DEFAULT_APP_SETTINGS
                WITH    SECURITY_ENFORCED
            ];
        } else {
            defaultSettings = customMetadataWithRecords.get(VDT_GENERAL_SETTINGS);
        }

        if (defaultSettings.isEmpty() == false) {
            countryField = defaultSettings[0].Default_Country_Code_Field__c;
        }

        return countryField;
    }
    
    public static Integer getBatchSizeForObject(String objectName) {
        Integer batchSize;
        List<VDT_Object_Batch_Size_Mapping__mdt> batchSizeMappings;
        batchSizeMappings = [
            SELECT  Id,
                    Batch_Size__c
            FROM    VDT_Object_Batch_Size_Mapping__mdt
            WHERE   MasterLabel = :objectName
            WITH    SECURITY_ENFORCED
        ];
        if (customMetadataWithRecords.containsKey(VDT_BATCH_SIZE_MAPPING)) {
            batchSizeMappings = customMetadataWithRecords.get(VDT_BATCH_SIZE_MAPPING);
        }

        if (batchSizeMappings.isEmpty()) {
            batchSize = getDefaultBatchSize();
        } else {
            batchSize = Integer.valueOf(batchSizeMappings[0].Batch_Size__c);
        }

        return batchSize;
    }

    public static Integer getDefaultBatchSize() {
        Integer batchSize;

        List<VDT_General_Setting__mdt> defaultSettings;
        defaultSettings = [
            SELECT  Batch_Size__c
            FROM    VDT_General_Setting__mdt
            WHERE   DeveloperName = :DEFAULT_APP_SETTINGS
            WITH    SECURITY_ENFORCED
        ];
        if (customMetadataWithRecords.containsKey(VDT_GENERAL_SETTINGS)) {
            defaultSettings = customMetadataWithRecords.get(VDT_GENERAL_SETTINGS);
        }

        if (!defaultSettings.isEmpty()) {
            batchSize = Integer.valueOf(defaultSettings[0].Batch_Size__c);
        }

        return batchSize;
    }

    public static Integer getStartDateYearDecrement() {
        Integer yearDecrement;

        List<VDT_General_Setting__mdt> defaultSettings;        
        defaultSettings = [
            SELECT  Start_Date_Year_Decrement__c
            FROM    VDT_General_Setting__mdt
            WHERE   DeveloperName = :DEFAULT_APP_SETTINGS
            WITH    SECURITY_ENFORCED
        ];
        if (customMetadataWithRecords.containsKey(VDT_GENERAL_SETTINGS)) {
            defaultSettings = customMetadataWithRecords.get(VDT_GENERAL_SETTINGS);
        }

        if (!defaultSettings.isEmpty()) {
            yearDecrement = Integer.valueOf(defaultSettings[0].Start_Date_Year_Decrement__c);
        }

        return yearDecrement;
    }

    public static Integer getMaxNumberOfCalculationRequests() {
        Integer maxCalcRequests;

        List<VDT_General_Setting__mdt> defaultSettings;
        if (!customMetadataWithRecords.containsKey(VDT_GENERAL_SETTINGS)) {
            defaultSettings = [
                SELECT  Maximum_Calculation_Requests__c
                FROM    VDT_General_Setting__mdt
                WHERE   DeveloperName = :DEFAULT_APP_SETTINGS
                WITH    SECURITY_ENFORCED
            ];
        } else {
            defaultSettings = customMetadataWithRecords.get(VDT_GENERAL_SETTINGS);
        }

        if (defaultSettings.isEmpty() == false) {
            maxCalcRequests = Integer.valueOf(defaultSettings[0].Maximum_Calculation_Requests__c);
        }

        return maxCalcRequests;
    }

    public static Integer getMaxNumberOfRunningCalculations() {
        Integer maxRunningCalc;

        List<VDT_General_Setting__mdt> defaultSettings;
        if (!customMetadataWithRecords.containsKey(VDT_GENERAL_SETTINGS)) {
            defaultSettings = [
                SELECT  Maximum_Running_Calculations__c
                FROM    VDT_General_Setting__mdt
                WHERE   DeveloperName = :DEFAULT_APP_SETTINGS
                WITH    SECURITY_ENFORCED
            ];
        } else {
            defaultSettings = customMetadataWithRecords.get(VDT_GENERAL_SETTINGS);
        }

        if (defaultSettings.isEmpty() == false) {
            maxRunningCalc = Integer.valueOf(defaultSettings[0].Maximum_Running_Calculations__c);
        }

        return maxRunningCalc;
    }

    public static String getStandardFieldIdentifier() {
        String identifier;

        List<VDT_General_Setting__mdt> defaultSettings;
        if (!customMetadataWithRecords.containsKey(VDT_GENERAL_SETTINGS)) {        
            defaultSettings = [
                SELECT  Standard_Field_Identifier__c
                FROM    VDT_General_Setting__mdt
                WHERE   DeveloperName = :DEFAULT_APP_SETTINGS
                WITH    SECURITY_ENFORCED
            ]; 
        } else {
            defaultSettings = customMetadataWithRecords.get(VDT_GENERAL_SETTINGS);
        }
        if (defaultSettings.isEmpty() == false) {
            identifier = defaultSettings[0].Standard_Field_Identifier__c;
        }

        return identifier;
    }

    public static Decimal getDailyAsyncExecutionAllocation() {
        Decimal allocation;

        List<VDT_General_Setting__mdt> defaultSettings;        
        defaultSettings = [
            SELECT  Apex_Async_Execution_Daily_Allocation__c
            FROM    VDT_General_Setting__mdt
            WHERE   DeveloperName = :DEFAULT_APP_SETTINGS
            WITH    SECURITY_ENFORCED
        ]; 
        if (customMetadataWithRecords.containsKey(VDT_GENERAL_SETTINGS)) {
            defaultSettings = customMetadataWithRecords.get(VDT_GENERAL_SETTINGS);
        }
        if (!defaultSettings.isEmpty()) {
            allocation = defaultSettings[0].Apex_Async_Execution_Daily_Allocation__c;
        }

        return allocation;
    }
}