/**
 * @author      BASE Life Science
 * @since       2021.03.01
 * @description Provides methods to access congifuration records stored in Custom Metadata Type objects
 */
public inherited sharing class VDT_CustomMetadataService {
    
    public static final String DEFAULT_APP_SETTINGS = 'Default';
    public static final String VDT_GENERAL_SETTINGS = 'VDT_General_Setting__mdt';
    public static final String VDT_QUERIES = 'VDT_Query__mdt';
    public static final String VDT_TABS = 'VDT_Tab__mdt';
    public static final String VDT_DATE_FIELD_MAPPING = 'VDT_Object_Date_Field_Mapping__mdt';
    public static final String VDT_COUNTRY_FIELD_MAPPING = 'VDT_Object_Country_Field_Mapping__mdt';
    public static final String VDT_PRODUCT_FIELD_MAPPING = 'VDT_Object_Product_Field_Mapping__mdt';
    public static final String VDT_CUSTOM_OBJECT_FIELD_MAPPING = 'VDT_Custom_Objects_Field_Mapping__mdt';
    public static final String VDT_KPI_CONFIGURATIONS = 'VDT_KPI_Configuration__mdt';
    public static final String VDT_KPI_BY_COUNTRY_CONFIGURATIONS = 'VDT_KPI_by_Country__mdt';    
    public static final String VDT_ACCOUNT_RECORD_TYPE_CONFIGURATIONS = 'VDT_Account_Record_Type_Mapping__mdt';    
    public static final String VDT_BATCH_SIZE_MAPPING = 'VDT_Object_Batch_Size_Mapping__mdt';
    public static final String VDT_VAULT_STATUSES = 'VDT_Vault_Document_Status__mdt';
    public static final String VDT_VAULT_CRM_STATUSES_MAP = 'VDT_Vault_Document_Status_Map__mdt';
    public static final String VDT_CRM_COLUMNS = 'VDT_CRM_Document_Column__mdt';
    public static final String VDT_VAULT_COLUMNS = 'VDT_Vault_Document_Column__mdt';    

    @TestVisible
    private static Map<String, List<SObject>> customMetadataWithRecords = new Map<String, List<SObject>>();

    public static String getProductCatalogObjectAPI() {
        String productCatalogObjectAPI;
        List<VDT_General_Setting__mdt> defaultSettings = [SELECT Product_Catalog_Object__c
                                                          FROM VDT_General_Setting__mdt
                                                          WHERE DeveloperName = :DEFAULT_APP_SETTINGS
                                                          WITH SECURITY_ENFORCED];
        if (customMetadataWithRecords.containsKey(VDT_GENERAL_SETTINGS)) {
            defaultSettings = customMetadataWithRecords.get(VDT_GENERAL_SETTINGS);
        }

        if (!defaultSettings.isEmpty()) {
            productCatalogObjectAPI = defaultSettings[0].Product_Catalog_Object__c;
        }
        return productCatalogObjectAPI;
    }

    public static List<VDT_CRM_Document_Column__mdt> getCRMColumns() {
        String packageVersion = getPackageVersion();
        List<VDT_CRM_Document_Column__mdt> configurations = [SELECT MasterLabel, Field_API_Name__c, Vault_API_Field__c 
                                                      FROM VDT_CRM_Document_Column__mdt 
                                                      WHERE Package_Version__c = :packageVersion];
        if (customMetadataWithRecords.containsKey(VDT_CRM_COLUMNS)) {
            configurations = customMetadataWithRecords.get(VDT_CRM_COLUMNS);
        }
        return configurations;
    }

    public static String getStatusApiFieldName(String status) {
        String packageVersion = getPackageVersion();
        
        List<VDT_Vault_Document_Status__mdt> configurations = [SELECT Status_Value__c 
                                                                FROM VDT_Vault_Document_Status__mdt 
                                                                WHERE Package_Version__c = :packageVersion 
                                                                AND Status__c = :status];
        if (customMetadataWithRecords.containsKey(VDT_VAULT_STATUSES)) {
            configurations = customMetadataWithRecords.get(VDT_VAULT_STATUSES);
        }
        return configurations[0].Status_Value__c;
    }

    public static Map<String, String> getVaultCrmStatusesMap() {
        Map<String, String> statusMap = new Map<String, String>();
        String packageVersion = getPackageVersion();        
        List<VDT_Vault_Document_Status_Map__mdt> configurations = [SELECT Vault_Status__c, Document_Status__c 
                                                                    FROM VDT_Vault_Document_Status_Map__mdt 
                                                                    WHERE Package_Version__c = :packageVersion];
        if (customMetadataWithRecords.containsKey(VDT_VAULT_CRM_STATUSES_MAP)) {
            configurations = customMetadataWithRecords.get(VDT_VAULT_CRM_STATUSES_MAP);
        }
        for (VDT_Vault_Document_Status_Map__mdt statusMapCMT : configurations) {
            statusMap.put(statusMapCMT.Document_Status__c, statusMapCMT.Vault_Status__c);
        }        
        return statusMap;
    }

    public static List<VDT_Vault_Document_Column__mdt> getActiveDocumentColumns() {
        List<VDT_Vault_Document_Column__mdt> activeColumns = new List<VDT_Vault_Document_Column__mdt>();
        List<VDT_Vault_Document_Column__mdt> configurations = [SELECT MasterLabel, Display_Order__c, Vault_API_Name__c
                                                                FROM VDT_Vault_Document_Column__mdt 
                                                                WHERE Is_Active__c = TRUE 
                                                                ORDER BY Display_Order__c ASC];
        if (customMetadataWithRecords.containsKey(VDT_VAULT_COLUMNS)) {
            configurations = customMetadataWithRecords.get(VDT_VAULT_COLUMNS);
        }
        for (VDT_Vault_Document_Column__mdt column : configurations) {
            activeColumns.add(column);
        }
        return activeColumns;
    }

    /**
     * @description  returns the Field to be used to filter records based on date parameters, if none is found, the `Default_Date_Field__c` from `Default Settings` is returned
     * @param objectName SObject API Name
     * @return  `String` with the Field API name
     */
    public static String getDateFieldForObject(String objectName) {
        String dateField;
        List<VDT_Object_Date_Field_Mapping__mdt> dateFieldMappings = [SELECT Date_API_Field__c
                                                                         FROM VDT_Object_Date_Field_Mapping__mdt
                                                                         WHERE MasterLabel = :objectName
                                                                         WITH SECURITY_ENFORCED];
        if (customMetadataWithRecords.containsKey(VDT_DATE_FIELD_MAPPING)) {        
            dateFieldMappings = customMetadataWithRecords.get(VDT_DATE_FIELD_MAPPING);
        }

        if (dateFieldMappings.isEmpty()) {
            dateField = getDefaultDateField();
        } else {
            dateField = dateFieldMappings[0].Date_API_Field__c;
        }
        return dateField;
    }

    /**
     * @description returns the default Date field used for those objects with no mapping found on `VDT_Object_Date_Field_Mapping__mdt`
     * @return  `String` Default Date field API name
     */
    public static String getDefaultDateField() {
        String dateField;
        List<VDT_General_Setting__mdt> defaultSettings = [SELECT Default_Date_Field__c
                                                          FROM VDT_General_Setting__mdt
                                                          WHERE DeveloperName = :DEFAULT_APP_SETTINGS
                                                          WITH SECURITY_ENFORCED];
        if (customMetadataWithRecords.containsKey(VDT_GENERAL_SETTINGS)) {
            defaultSettings = customMetadataWithRecords.get(VDT_GENERAL_SETTINGS);
        }

        if (!defaultSettings.isEmpty()) {
            dateField = defaultSettings[0].Default_Date_Field__c;
        }

        return dateField;
    }

    /**
     * @description Only those options returned on this method will be shown as menu options on the UI to the User
     * @return  `String` of comma separated values with the names of the active options
     */
    public static String getActiveMenuOptions() {
        List<String> menuOptions = new List<String>();
        List<VDT_Tab__mdt> tabs  = [SELECT  DeveloperName 
                                    FROM VDT_Tab__mdt
                                    WHERE Is_Active__c = TRUE 
                                    WITH SECURITY_ENFORCED];
        if (customMetadataWithRecords.containsKey(VDT_TABS)) {
            tabs = customMetadataWithRecords.get(VDT_TABS);
        }

        if (!tabs.isEmpty()) {
            for (VDT_Tab__mdt tab : tabs) {
                menuOptions.add(tab.DeveloperName);
            }
        }        
        return String.join(menuOptions, ',');
    }

    /**
     * @description this method determines what SOBjects should be queried on the Calculation jobs.
     * @return  `String` the package version (it can be whether Veeva or OCE) 
     */
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

    /**
     * @param packageVersion What SObjects the jobs should run the queries based on the package version
     * @param moduleName name of the module we want to retrieve the queries for (Master Data Analysis or Product Adoption)
     * @return  `Map<String,String>` map of SOQL queries by their configuration name.
     */
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

    /**
     * @description returns the API name configured for the given search key
     * @param mappingName Custom Metadata Type record's developer name
     * @return  `String` Field API Name
     */
    public static String getFieldNameForCustomObject(String packageVersion, String mappingName) {
        String fieldName;
        List<VDT_Custom_Objects_Field_Mapping__mdt> objectFieldMappings;       
        objectFieldMappings = [
            SELECT  Id,
                    Field_API_Name__c
            FROM    VDT_Custom_Objects_Field_Mapping__mdt
            WHERE   Field_Map_Key__c = :mappingName AND Package_Version__c = :packageVersion
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

    /**
     * @description returns the field API name that references the Product Catalog object for any SOBject.
     * @param objectName Custom Metadata Type developer name
     * @return  `String` Field API Name
     */
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

    /**
     * @description returns a list of Options to be used in Picklist components when the configured `Country` field is a text field
     * @return  `List<VDT_OptionWrapper>` options with all countries
     */
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

    /**
     * @return  `String` International Product Code that identifies a Product Catalog record as International
     */
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

    /**
     * @return  `Boolean` whether the Manage Territory calculation should be performed or not.
     */
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

    /**
     * @description Only Active KPIs at the time the job is run are included in the calculations
     * @return  `List<VDT_KPI_Configuration__mdt>` List of KPIs that should be taken into account when running the `Master Data Analysis` job.
     */
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

    /**
     * @description Custom targets override default target values for a given Country and KPI
     * @return  `Map<String, Decimal>` Custom Target for each KPI and Country combination
     */
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

    /**
     * @description Used to categorize whether an Account record should be treated as Internal or External Customer
     * @return  `Map<String, List<String>>` with two keys: External_Customers and Internal_Customers, each has a List of Account Record Type names
     */
    public static Map<String, List<String>> getAccountClassificationByFieldValue() {
        List<VDT_Account_Record_Type_Mapping__mdt> accountClassifications = new List<VDT_Account_Record_Type_Mapping__mdt>();
        accountClassifications = [
            SELECT  DeveloperName, Classification_Value__c
            FROM    VDT_Account_Record_Type_Mapping__mdt
            WHERE Classification_Value__c != NULL
            WITH    SECURITY_ENFORCED
        ];
        if (customMetadataWithRecords.containsKey(VDT_ACCOUNT_RECORD_TYPE_CONFIGURATIONS)) {
            accountClassifications = customMetadataWithRecords.get(VDT_ACCOUNT_RECORD_TYPE_CONFIGURATIONS);
        }
        Map<String, List<String>> accountTypeByFieldValue = new Map<String, List<String>>();
        for (VDT_Account_Record_Type_Mapping__mdt recordTypeConfiguration : accountClassifications) {
            if (!String.isBlank(recordTypeConfiguration.Classification_Value__c)) {
                accountTypeByFieldValue.put(recordTypeConfiguration.DeveloperName, recordTypeConfiguration.Classification_Value__c.split(','));
            } else {
                accountTypeByFieldValue.put(recordTypeConfiguration.DeveloperName, new List<String>());
            }
        }
        return accountTypeByFieldValue;
    }

    /**
     * @description Used to categorize whether an Account record should be treated as Internal or External Customer
     * @return  `Map<String, List<String>>` with two keys: External_Customers and Internal_Customers, each has a List of Account Record Type names
     */
    public static Map<String, List<String>> getAccountRecordTypesByType() {
        List<VDT_Account_Record_Type_Mapping__mdt> recordTypeConfigurations = new List<VDT_Account_Record_Type_Mapping__mdt>();
        recordTypeConfigurations = [
            SELECT  DeveloperName, Account_Record_Types__c
            FROM    VDT_Account_Record_Type_Mapping__mdt
            WHERE Account_Record_Types__c != NULL
            WITH    SECURITY_ENFORCED
        ];
        if (customMetadataWithRecords.containsKey(VDT_ACCOUNT_RECORD_TYPE_CONFIGURATIONS)) {
            recordTypeConfigurations = customMetadataWithRecords.get(VDT_ACCOUNT_RECORD_TYPE_CONFIGURATIONS);
        }
        Map<String, List<String>> accountRecordTypesByType = new Map<String, List<String>>();
        for (VDT_Account_Record_Type_Mapping__mdt recordTypeConfiguration : recordTypeConfigurations) {
            if (!String.isBlank(recordTypeConfiguration.Account_Record_Types__c)) {
                accountRecordTypesByType.put(recordTypeConfiguration.DeveloperName, recordTypeConfiguration.Account_Record_Types__c.split(','));
            } else {
                accountRecordTypesByType.put(recordTypeConfiguration.DeveloperName, new List<String>());
            }
        }
        return accountRecordTypesByType;
    }

    /**
     * @description  returns the Field to be used to filter records based on Country, if none is found, the `Default_Country_Code_Field__c` from `Default Settings` is returned
     * @param objectName Object API Name
     * @return  `String` Field API Name that holds the Country value for the given object
     */
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

    /**
     * @return  `String` Field API Name used to Group and Filter account records based on Specialty values
     */
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

        /**
     * @return  `String` Field API Name used to Group and Filter account records based on Specialty values
     */
    public static String getAccountClassificationField() {
        String classificationField;
        List<VDT_General_Setting__mdt> defaultSettings;
        defaultSettings = [
            SELECT  Account_Classification_Field__c
            FROM    VDT_General_Setting__mdt
            WHERE   DeveloperName = :DEFAULT_APP_SETTINGS
            WITH    SECURITY_ENFORCED
        ];
        if (customMetadataWithRecords.containsKey(VDT_GENERAL_SETTINGS)) {
            defaultSettings = customMetadataWithRecords.get(VDT_GENERAL_SETTINGS);
        }

        if (!defaultSettings.isEmpty()) {
            classificationField = defaultSettings[0].Account_Classification_Field__c;
        }        
        return classificationField;
    }

    /**
     * @return  `String` Field API Name that holds the Country value for any SObject
     */
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
    
    /**
     * @param objectName SObject API Name
     * @return  `Integer` number of records to process on each batch for the given SObject
     */
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

    /**
     * @description If no mapping record is found for any SObject on `VDT_Object_Batch_Size_Mapping__mdt` then the default Batch size is used.
     * @return  `Integer` number of records to process on each batch for the given SObject
     */
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

    /**
     * @return  `Integer` number of years the Date Range component should list on the Start Year picklist
     */
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

    /**
     * @description Maximun number of jobs the app allows to be added to the queue, if the number is reached, a message wil be shown to the user letting them know no more jobs
     *              can be added.
     * @return  `Integer` number of jobs that can be added to the queue.
     */
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

    /**
     * @return  `Integer` number of max jobs running simultaneously
     */
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

    /**
     * @return  `String`
     */
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

    /**
     * @return  `Decimal` percentage of Daily Async Execution allowed to be used by the Appliaction.
     */
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