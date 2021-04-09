@IsTest
public with sharing class VDT_MasterDataAnalysisControllerTest {

    @IsTest
    static void shouldReturnReferenceTypeForAccount() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Object_Country_Field_Mapping__mdt', 
        (List<VDT_Object_Country_Field_Mapping__mdt>) JSON.deserialize('[{"Country_Field_Reference__c": "Country__r.Name"}]', List<VDT_Object_Country_Field_Mapping__mdt>.class));
        Test.startTest();
        String fieldType = VDT_MasterDataAnalysisController.getAccountCountryFieldType();
        Test.stopTest();
        System.assertEquals('REFERENCE', fieldType);
    }

    @IsTest
    static void shouldReturnPicklistTypeForAccount() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Object_Country_Field_Mapping__mdt', 
        (List<VDT_Object_Country_Field_Mapping__mdt>) JSON.deserialize('[{"Country_Field_Reference__c": "Type"}]', List<VDT_Object_Country_Field_Mapping__mdt>.class));
        Test.startTest();
        String fieldType = VDT_MasterDataAnalysisController.getAccountCountryFieldType();
        Test.stopTest();
        System.assertEquals('PICKLIST', fieldType);
    }

    
    @IsTest
    static void shouldReturnStringTypeForAccount() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Object_Country_Field_Mapping__mdt', 
        (List<VDT_Object_Country_Field_Mapping__mdt>) JSON.deserialize('[{"Country_Field_Reference__c": "Name"}]', List<VDT_Object_Country_Field_Mapping__mdt>.class));
        Test.startTest();
        String fieldType = VDT_MasterDataAnalysisController.getAccountCountryFieldType();
        Test.stopTest();
        System.assertEquals('STRING', fieldType);
    }

    @IsTest
    static void shouldThrowException_WhenFieldDoesNotExists() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Object_Country_Field_Mapping__mdt', 
        (List<VDT_Object_Country_Field_Mapping__mdt>) JSON.deserialize('[{"Country_Field_Reference__c": "Field_Does_Not_Exists__c"}]', List<VDT_Object_Country_Field_Mapping__mdt>.class));
        try {
            Test.startTest();
            String fieldType = VDT_MasterDataAnalysisController.getAccountCountryFieldType();
            Test.stopTest();            
        } catch (Exception e) {
            System.assert(true);
            return;
        }
        System.assert(false, 'Exception should have been thrown');
    }

    @IsTest
    static void shouldReturnListOfCountryOptionsFromPicklist() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Object_Country_Field_Mapping__mdt', 
        (List<VDT_Object_Country_Field_Mapping__mdt>) JSON.deserialize('[{"Country_Field_Reference__c": "Type"}]', List<VDT_Object_Country_Field_Mapping__mdt>.class));
        Test.startTest();
        List<VDT_OptionWrapper> countryOptions = VDT_MasterDataAnalysisController.getCountryOptions();
        Test.stopTest();
        System.assert(!countryOptions.isEmpty());
    }

    @IsTest
    static void shouldReturnEmpty_WhenFieldIsNotPicklistType() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Object_Country_Field_Mapping__mdt', 
        (List<VDT_Object_Country_Field_Mapping__mdt>) JSON.deserialize('[{"Country_Field_Reference__c": "Name"}]', List<VDT_Object_Country_Field_Mapping__mdt>.class));
        Test.startTest();
        List<VDT_OptionWrapper> countryOptions = VDT_MasterDataAnalysisController.getCountryOptions();
        Test.stopTest();
        System.assert(countryOptions.isEmpty());
    }

    @IsTest
    static void shouldReturnException_WhenFieldDoesNotExists() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Object_Country_Field_Mapping__mdt', 
        (List<VDT_Object_Country_Field_Mapping__mdt>) JSON.deserialize('[{"Country_Field_Reference__c": "Field_Does_Not_Exists__c"}]', List<VDT_Object_Country_Field_Mapping__mdt>.class));
        try {
            Test.startTest();
            VDT_MasterDataAnalysisController.getCountryOptions();
            Test.stopTest();            
        } catch (Exception e) {
            System.assert(true);
            return;
        }
        System.assert(false, 'Exception should have been thrown');
    }

    @IsTest
    static void shouldReturnTerritoryInactive() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
        (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"VDT_Is_Territory_Management_Active__c": false}]', List<VDT_General_Setting__mdt>.class));
        Test.startTest();
        Boolean isActive = VDT_MasterDataAnalysisController.isTerritoryManagementActive();
        Test.stopTest();
        System.assert(!isActive);
    }

    @IsTest
    static void shouldThrowException_WhenFieldIsNotLookup() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Object_Country_Field_Mapping__mdt', 
        (List<VDT_Object_Country_Field_Mapping__mdt>) JSON.deserialize('[{"Country_Field_Reference__c": "Lookup_Field__r.Name"}]', List<VDT_Object_Country_Field_Mapping__mdt>.class));
        try {
            Test.startTest();
            VDT_MasterDataAnalysisController.getCountryOptionFromReference();
            Test.stopTest();
        } catch (Exception e) {
            System.assert(true);
            return;
        }
        System.assert(false, 'Exception should have been thrown');
    }

    @IsTest
    static void shouldThrowException_WhenBadSearchInputParameters() {
        
        String jsonSearchParameters = '{"startYear": 01}';
        try {
            Test.startTest();
            VDT_MasterDataAnalysisController.searchExistingCalculations(jsonSearchParameters);
            Test.stopTest();
        } catch (Exception e) {
            System.assert(true);
            return;
        }
        System.assert(false, 'Exception should have been thrown');
        
    }

    @IsTest
    static void shouldReturnDataCalculationRecord() {
        String fileContent = '{"specialties": [], "recordTypes": [], "kpi_numbers": {}, "calculations": {}}';
        new VDT_DataCalculationDataFactory()
        .countries(new List<String>{'DE'})
        .startYearAndMonth(2015, 1)
        .endYearAndMonth(2021, 1)
        .calculationDate(System.today())
        .status('Completed')
        .recordType(VDT_DataCalculationSelector.MASTER_ANALYSIS_RECORD_TYPE_DEV)
        .insertRecord()
        .addAttachment(VDT_DataCalculationService.MASTER_DATA_ANALYSIS_SUMMARY_FILE_NAME, fileContent, VDT_AttachmentService.JSON_FORMAT);
        String jsonSearchParameters = '{"startYear": 2015, "startMonth": 1, "endYear": 2021, "endMonth": 1, "countries": ["DE"]}';
        Test.startTest();
        VDT_DataCalculationService.DataCalculation calculationRecord = VDT_MasterDataAnalysisController.searchExistingCalculations(jsonSearchParameters);
        Test.stopTest();
        System.assertEquals('Completed', calculationRecord.status);
        System.assertEquals(fileContent, calculationRecord.data);
    }

    @IsTest
    static void shouldInsertDataCalculation_WhenTriggeredForFirstTime() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Object_Country_Field_Mapping__mdt', 
            (List<VDT_Object_Country_Field_Mapping__mdt>) JSON.deserialize('[{"Country_Field_Reference__c": "CreatedBy.Country"}]', List<VDT_Object_Country_Field_Mapping__mdt>.class));

        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"VDT_Default_Specialty_Field__c": "Type", "Maximum_Running_Calculations__c": "2"}]', List<VDT_General_Setting__mdt>.class));

        User adminUser = getUser();
        String jsonSearchParameters = '{"startYear": 2015, "startMonth": 1, "endYear": 2021, "endMonth": 1, "countries": ["DE", "FR"]}';
        Test.startTest();
        System.runAs(adminUser) {
            Account ac = new Account(
                Type = 'Other',
                Name = 'Test'
            );
            insert ac;
            Account ac2 = new Account(
                Type = 'Other',
                Name = 'Test2'
            );
            insert ac2;
            VDT_MasterDataAnalysisController.recalculateMasterAnalysis(jsonSearchParameters);
        }
        Test.stopTest();
        List<VDT_Data_Calculation__c> records = [SELECT Id, Status__c FROM VDT_Data_Calculation__c WHERE VDT_Country__c = 'DE,FR'];
        System.assertEquals(1, records.size());
        System.assertEquals(VDT_DataCalculationService.STATUS_COMPLETED, records.get(0).Status__c);
    }

    @IsTest
    static void shouldThrowException_WhenBadInputParameters(){
        String jsonSearchParameters = '{"startYear": 01}';
        try {
            Test.startTest();
            VDT_MasterDataAnalysisController.recalculateMasterAnalysis(jsonSearchParameters);
            Test.stopTest();
        } catch (Exception e) {
            System.assert(true);
            return;
        }
        System.assert(false, 'Exception should have been thrown');
    }

    private static User getUser() {
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'BASE_CRM_Diagnostic_Tool_User'];        
        User newUser = new VDT_UserDataFactory()
        .name('Test#')
        .username('base+user@testing.com')
        .alias('testU_')
        .email('base+user@testing.com')
        .buildAdmin();
        insert newUser;
        insert new PermissionSetAssignment(AssigneeId = newUser.id, PermissionSetId = ps.Id);
        return newUser;
    }
}
