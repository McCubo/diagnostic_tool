@IsTest
public inherited sharing class VDT_CustomMetadataServiceTest {

    @IsTest
    static void methodName() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Tab__mdt', 
        (List<VDT_Tab__mdt>) JSON.deserialize('[{"DeveloperName": "home"}, {"DeveloperName": "master_data_analysis"}]', List<VDT_Tab__mdt>.class));
        List<String> menuOptions = new List<String>();
        Test.startTest();
        String csvOptions = VDT_CustomMetadataService.getActiveMenuOptions();
        menuOptions = csvOptions.split(',');
        Test.stopTest();
        System.assert(!menuOptions.isEmpty());
        System.assertEquals(2, menuOptions.size());
    }

    @IsTest
    static void shouldReturnFieldNameForObject() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Custom_Objects_Field_Mapping__mdt', 
            (List<VDT_Custom_Objects_Field_Mapping__mdt>) JSON.deserialize('[{"Field_API_Name__c": "VDT_Status__c"}]', List<VDT_Custom_Objects_Field_Mapping__mdt>.class));
        Test.startTest();
        String fieldAPI = VDT_CustomMetadataService.getFieldNameForCustomObject('Veeva', 'PRODUCT_VOD_STATUS');
        Test.stopTest();
        system.assertEquals('VDT_Status__c', fieldAPI);
    }

    @IsTest
    static void shouldReturnFieldApiNameForEvents() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Object_Product_Field_Mapping__mdt', 
            (List<VDT_Object_Product_Field_Mapping__mdt>) JSON.deserialize('[{"Product_Field_Reference__c": "VDT_Product_Catalog__c"}]', List<VDT_Object_Product_Field_Mapping__mdt>.class));
        Test.startTest();
        String productField = VDT_CustomMetadataService.getProductFieldForObject('EM_Event_vod__c');
        Test.stopTest();
        system.assertEquals('VDT_Product_Catalog__c', productField);
        
    }

    @IsTest
    static void shouldReturnListOfDefaultCountries() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"VDT_Default_Countries__c": "BE,FR,DE,UK"}]', List<VDT_General_Setting__mdt>.class));
        Test.startTest();
        List<VDT_OptionWrapper> countryOptions = VDT_CustomMetadataService.getDefaultCountries();
        Test.stopTest();
        System.assertEquals(4, countryOptions.size());
    }

    @IsTest
    static void shouldReturnInternationalCountryValue() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"International_Country__c": "INT"}]', List<VDT_General_Setting__mdt>.class));        
        Test.startTest();
        String internationalCountry = VDT_CustomMetadataService.getInternationalCountryValue();
        Test.stopTest();
        System.assertEquals('INT', internationalCountry);
    }

    @IsTest
    static void shouldReturnTerritoryActiveTrue() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"VDT_Is_Territory_Management_Active__c": true}]', List<VDT_General_Setting__mdt>.class));
        Test.startTest();
        Boolean isTerritoryActive = VDT_CustomMetadataService.isTerritoryManagementActive();
        Test.stopTest();
        System.assert(isTerritoryActive);
    }

    @IsTest
    static void shouldReturnActiveKPIConfigurations() {
        String jsonObjects = String.format('[{0}, {1}, {2}]', new List<String> {
            '{"MasterLabel": "Onekey vs Non One Key", "VDT_Type__c": "higher", "VDT_Is_Active__c": true}',
            '{"MasterLabel": "Onekey aligned to territories", "VDT_Type__c": "higher", "VDT_Is_Active__c": true}',
            '{"MasterLabel": "Onekey Without visit", "VDT_Type__c": "lower", "VDT_Is_Active__c": true}'
        });
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_KPI_Configuration__mdt', 
            (List<VDT_KPI_Configuration__mdt>) JSON.deserialize(jsonObjects, List<VDT_KPI_Configuration__mdt>.class));
        
        Test.startTest();
        List<VDT_KPI_Configuration__mdt> kpis = VDT_CustomMetadataService.getActiveKpiConfigurations();
        Test.stopTest();
        System.assertEquals(3, kpis.size());
    }

    @IsTest
    static void shouldReturnKpiConfigurationsByCountry() {
        String jsonObjects = String.format('[{0}]', new List<String> {
            '{"VDT_Country__c": "DE", "VDT_KPI_Configuration__r.DeveloperName": "Onekey_vs_Non_One_Key", "VDT_Target__c": 95}'
        });
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_KPI_by_Country__mdt', 
            (List<VDT_KPI_by_Country__mdt>) JSON.deserialize(jsonObjects, List<VDT_KPI_by_Country__mdt>.class));
        Test.startTest();
        Map<String, Decimal> kpiByCountry = VDT_CustomMetadataService.getCountryKpiConfigurations();
        Test.stopTest();
        System.assertEquals(1, kpiByCountry.size());
    }

    @IsTest
    static void shouldReturnAccountRecordTypesByType() {
        String jsonObjects = String.format('[{0}, {1}]', new List<String> {
            '{"DeveloperName": "External_Customers", "Account_Record_Types__c": "MCO_vod,Hospital_vod,Laboratory_vod"}',
            '{"DeveloperName": "Internal_Customers", "Account_Record_Types__c": "Institution_vod,Professional_vod"}'
        });
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Account_Record_Type_Mapping__mdt', 
            (List<VDT_Account_Record_Type_Mapping__mdt>) JSON.deserialize(jsonObjects, List<VDT_Account_Record_Type_Mapping__mdt>.class));        
        Test.startTest();
        Map<String, List<String>> accountRecordTypes = VDT_CustomMetadataService.getAccountRecordTypesByType();
        Test.stopTest();
        System.assertEquals(3, accountRecordTypes.get('External_Customers').size());
        System.assertEquals(2, accountRecordTypes.get('Internal_Customers').size());
    }

    @IsTest
    static void shouldReturnAccountSpecialtyField() {
        String jsonObjects = String.format('[{0}]', new List<String> {
            '{"VDT_Default_Specialty_Field__c": "VDT_Specialty_vod__c"}'
        });
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize(jsonObjects, List<VDT_General_Setting__mdt>.class));
        Test.startTest();
        String specialtyField = VDT_CustomMetadataService.getAccountSpecialtyField();
        Test.stopTest();
        System.assertEquals('VDT_Specialty_vod__c', specialtyField);
    }

    @IsTest
    static void shouldReturnBatchSizeForObject() {
        String jsonObjects = String.format('[{0}]', new List<String> {
            '{"Batch_Size__c": 200}'
        });
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Object_Batch_Size_Mapping__mdt', 
            (List<VDT_Object_Batch_Size_Mapping__mdt>) JSON.deserialize(jsonObjects, List<VDT_Object_Batch_Size_Mapping__mdt>.class));        
        Test.startTest();
        Integer batchSize = VDT_CustomMetadataService.getBatchSizeForObject('Account');
        Test.stopTest();
        System.assertEquals(200, batchSize);
    }

    @IsTest
    static void shouldReturnDefaultBatchSize() {
        String jsonObjects = String.format('[{0}]', new List<String> {
            '{"Batch_Size__c": 200}'
        });
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize(jsonObjects, List<VDT_General_Setting__mdt>.class));        
        Test.startTest();
        Integer defaultBatchSize = VDT_CustomMetadataService.getDefaultBatchSize();
        Test.stopTest();
        System.assertEquals(200, defaultBatchSize);
    }

    @IsTest
    static void shouldReturnDailyAllocationValue() {
        String jsonObjects = String.format('[{0}]', new List<String> {
            '{"Apex_Async_Execution_Daily_Allocation__c": 50.00}'
        });
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize(jsonObjects, List<VDT_General_Setting__mdt>.class));
        Test.startTest();
        Decimal dailyAllocation = VDT_CustomMetadataService.getDailyAsyncExecutionAllocation();
        Test.stopTest();
        System.assertEquals(50.00, dailyAllocation);
    }

    @IsTest
    static void shouldReturnCountryFieldForObject() {
        Test.startTest();
        String countryField = VDT_CustomMetadataService.getCountryFieldForObject(null);
        Test.stopTest();

        List<VDT_General_Setting__mdt> generalSettings = [
            SELECT  Default_Country_Code_Field__c
            FROM    VDT_General_Setting__mdt
            WHERE   DeveloperName = :VDT_CustomMetadataService.DEFAULT_APP_SETTINGS
        ];

        system.assertEquals(generalSettings[0].Default_Country_Code_Field__c, countryField);
    }

    @IsTest
    static void shouldReturnCountryFieldForObjectWithPreset() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Object_Country_Field_Mapping__mdt', 
            (List<VDT_Object_Country_Field_Mapping__mdt>) JSON.deserialize('[{"Country_Field_Reference__c": "Country_Field__c"}]', List<VDT_Object_Country_Field_Mapping__mdt>.class));
        
        Test.startTest();
        String countryField = VDT_CustomMetadataService.getCountryFieldForObject(null);
        Test.stopTest();
        
        system.assertEquals('Country_Field__c', countryField);
    }

    @IsTest
    static void shouldReturnDefaultCountryFieldForObject() {
        Test.startTest();
        String defaultLanguageField = VDT_CustomMetadataService.getDefaultCountryField();
        Test.stopTest();
        List<VDT_General_Setting__mdt> generalSettings = [
            SELECT  Default_Country_Code_Field__c
            FROM    VDT_General_Setting__mdt
            WHERE   DeveloperName = :VDT_CustomMetadataService.DEFAULT_APP_SETTINGS
        ];

        system.assertEquals(generalSettings[0].Default_Country_Code_Field__c, defaultLanguageField);
    }

    @IsTest
    static void shouldReturnDefaultCountryFieldForObjectWithPreset() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"Default_Country_Code_Field__c": "XX"}]', List<VDT_General_Setting__mdt>.class));
        
        Test.startTest();
        String defaultLanguageField = VDT_CustomMetadataService.getDefaultCountryField();
        Test.stopTest();

        system.assertEquals('XX', defaultLanguageField);
    }

    @IsTest
    static void shouldReturnStartDateYearDecrement() {
        Integer yearDecrement = VDT_CustomMetadataService.getStartDateYearDecrement();
        List<VDT_General_Setting__mdt> generalSettings = [
            SELECT  Start_Date_Year_Decrement__c
            FROM    VDT_General_Setting__mdt
            WHERE   DeveloperName = :VDT_CustomMetadataService.DEFAULT_APP_SETTINGS
        ];

        system.assertEquals(generalSettings[0].Start_Date_Year_Decrement__c, yearDecrement);
    }

    @IsTest
    static void shouldReturnStartDateYearDecrementWithPreset() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"Start_Date_Year_Decrement__c": "3"}]', List<VDT_General_Setting__mdt>.class));
        
        Test.startTest();
        Integer yearDecrement = VDT_CustomMetadataService.getStartDateYearDecrement();
        Test.stopTest();

        system.assertEquals(3, yearDecrement);
    }

    @IsTest
    static void shouldReturnMaxNumberOfCalculationRequests() {
        Integer maxRequestsNum = VDT_CustomMetadataService.getMaxNumberOfCalculationRequests();
        List<VDT_General_Setting__mdt> generalSettings = [
            SELECT  Maximum_Calculation_Requests__c
            FROM    VDT_General_Setting__mdt
            WHERE   DeveloperName = :VDT_CustomMetadataService.DEFAULT_APP_SETTINGS
        ];
        
        system.assertEquals(generalSettings[0].Maximum_Calculation_Requests__c, maxRequestsNum);
    }

    @IsTest
    static void shouldReturnMaxNumberOfCalculationRequestsWithPreset() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"Maximum_Calculation_Requests__c": "10"}]', List<VDT_General_Setting__mdt>.class));
        
        Test.startTest();
        Integer maxRequestsNum = VDT_CustomMetadataService.getMaxNumberOfCalculationRequests();
        Test.stopTest();

        system.assertEquals(10, maxRequestsNum);
    }

    @IsTest
    static void shouldReturnMaxNumberOfRunningCalculations() {
        Integer maxRunningCalc = VDT_CustomMetadataService.getMaxNumberOfRunningCalculations();
        List<VDT_General_Setting__mdt> generalSettings = [
            SELECT  Maximum_Running_Calculations__c
            FROM    VDT_General_Setting__mdt
            WHERE   DeveloperName = :VDT_CustomMetadataService.DEFAULT_APP_SETTINGS
        ];
        
        system.assertEquals(generalSettings[0].Maximum_Running_Calculations__c, maxRunningCalc);
    }

    @IsTest
    static void shouldReturnMaxNumberOfRunningCalculationsWithPreset() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"Maximum_Running_Calculations__c": "2"}]', List<VDT_General_Setting__mdt>.class));
        
        Test.startTest();
        Integer maxRunningCalc = VDT_CustomMetadataService.getMaxNumberOfRunningCalculations();
        Test.stopTest();

        system.assertEquals(2, maxRunningCalc);
    }

    @IsTest
    static void shouldReturnStandardFieldIdentifier() {
        String identifier = VDT_CustomMetadataService.getStandardFieldIdentifier();
        List<VDT_General_Setting__mdt> generalSettings = [
            SELECT  Standard_Field_Identifier__c
            FROM    VDT_General_Setting__mdt
            WHERE   DeveloperName = :VDT_CustomMetadataService.DEFAULT_APP_SETTINGS
        ];
        
        system.assertEquals(generalSettings[0].Standard_Field_Identifier__c, identifier);
    }

    @IsTest
    static void shouldReturnStandardFieldIdentifierWithPreset() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"Standard_Field_Identifier__c": "test"}]', List<VDT_General_Setting__mdt>.class));
        
        Test.startTest();
        String identifier = VDT_CustomMetadataService.getStandardFieldIdentifier();
        Test.stopTest();

        system.assertEquals('test', identifier);
    }
}