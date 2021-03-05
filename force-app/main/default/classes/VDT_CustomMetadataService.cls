public inherited sharing class VDT_CustomMetadataService {
    public static final String DEFAULT_APP_SETTINGS = 'Default';
    public static final String VDT_GENERAL_SETTINGS = 'VDT_General_Setting__mdt';
    public static final String VDT_COUNTRY_FIELD_MAPPING = 'VDT_Object_Country_Field_Mapping__mdt';
    public static final String VDT_BATCH_SIZE_MAPPING = 'VDT_Object_Batch_Size_Mapping__mdt';
    @TestVisible
    private static Map<String, List<SObject>> customMetadataWithRecords = new Map<String, List<SObject>>();

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
        if (!customMetadataWithRecords.containsKey(VDT_BATCH_SIZE_MAPPING)) {        
            batchSizeMappings = [
                SELECT  Id,
                        Batch_Size__c
                FROM    VDT_Object_Batch_Size_Mapping__mdt
                WHERE   MasterLabel = :objectName
                WITH    SECURITY_ENFORCED
            ];
        } else {
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
        if (!customMetadataWithRecords.containsKey(VDT_GENERAL_SETTINGS)) {        
            defaultSettings = [
                SELECT  Batch_Size__c
                FROM    VDT_General_Setting__mdt
                WHERE   DeveloperName = :DEFAULT_APP_SETTINGS
                WITH    SECURITY_ENFORCED
            ];
        } else {
            defaultSettings = customMetadataWithRecords.get(VDT_GENERAL_SETTINGS);
        }

        if (defaultSettings.isEmpty() == false) {
            batchSize = Integer.valueOf(defaultSettings[0].Batch_Size__c);
        }

        return batchSize;
    }

    public static Integer getStartDateYearDecrement() {
        Integer yearDecrement;

        List<VDT_General_Setting__mdt> defaultSettings;
        if (!customMetadataWithRecords.containsKey(VDT_GENERAL_SETTINGS)) {
            defaultSettings = [
                SELECT  Start_Date_Year_Decrement__c
                FROM    VDT_General_Setting__mdt
                WHERE   DeveloperName = :DEFAULT_APP_SETTINGS
                WITH    SECURITY_ENFORCED
            ];
        } else {
            defaultSettings = customMetadataWithRecords.get(VDT_GENERAL_SETTINGS);
        }

        if (defaultSettings.isEmpty() == false) {
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
}
