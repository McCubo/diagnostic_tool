@IsTest
public inherited sharing class VDT_CustomMetadataServiceTest {
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