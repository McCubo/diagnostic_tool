@IsTest
public with sharing class VDT_ProductAdoptionControllerTest {

    @IsTest
    static void shouldThrowException_WhenBadSearchInputParameters() {
        
        String jsonSearchParameters = '{"startYear": 01}';
        try {
            Test.startTest();
            VDT_ProductAdoptionController.searchExistingCalculations(jsonSearchParameters);
            Test.stopTest();
        } catch (Exception e) {
            System.assert(true);
            return;
        }
        System.assert(false, 'Exception should have been thrown');
        
    }

    @IsTest
    static void shouldReturnDataCalculationRecord() {
        String fileContent = '{"productTypes": [], "product_adoption": {}}';
        new VDT_DataCalculationDataFactory()
        .startYearAndMonth(2015, 1)
        .endYearAndMonth(2021, 1)
        .calculationDate(System.today())
        .status('Completed')
        .country('DE')
        .recordType(VDT_DataCalculationSelector.PRODUCT_ADOPTION_RECORD_TYPE_DEV)
        .insertRecord()
        .addAttachment(VDT_DataCalculationService.PRODUCT_ADOPTION_FILE_NAME, fileContent, VDT_AttachmentService.JSON_FORMAT);
        String jsonSearchParameters = '{"startYear": 2015, "startMonth": 1, "endYear": 2021, "endMonth": 1, "countries": ["DE"]}';
        Test.startTest();
        VDT_DataCalculationService.DataCalculation calculationRecord = VDT_ProductAdoptionController.searchExistingCalculations(jsonSearchParameters);
        Test.stopTest();
        System.assertEquals('Completed', calculationRecord.status);
        System.assertEquals(fileContent, calculationRecord.data);
    }

    @IsTest
    static void shouldReturnProductTree() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Object_Country_Field_Mapping__mdt', 
            (List<VDT_Object_Country_Field_Mapping__mdt>) JSON.deserialize('[{"Country_Field_Reference__c": "CreatedBy.Country"}]', List<VDT_Object_Country_Field_Mapping__mdt>.class));
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Custom_Objects_Field_Mapping__mdt', 
            (List<VDT_Custom_Objects_Field_Mapping__mdt>) JSON.deserialize('[{"Field_API_Name__c": "Name"}]', List<VDT_Custom_Objects_Field_Mapping__mdt>.class));
        User contextuser = getUser();
        VDT_ProductService.ProductAdoptionData adoptionData;
        Test.startTest();
        System.runAs(contextuser) {
            new VDT_ProductDataFactory('Product Onco')
            .setProperty('Country__c', 'DE')
            .setProperty('Product_Type_vod__c', 'Detail')
            .create()
            .addChildProduct(new VDT_ProductDataFactory('ONCO Lvl 1').setProperty('Country__c', 'DE').getRecord())
            .addChildProduct(new VDT_ProductDataFactory('Onco Level 2').setProperty('Country__c', 'DE').getRecord());
            adoptionData = VDT_ProductAdoptionController.getProductCatalogTree();
        }
        Test.stopTest();
    }

    @IsTest
    static void shouldReturnReferenceTypeForProduct() {
        
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Object_Country_Field_Mapping__mdt', 
        (List<VDT_Object_Country_Field_Mapping__mdt>) JSON.deserialize('[{"Country_Field_Reference__c": "Country__r.Name"}]', List<VDT_Object_Country_Field_Mapping__mdt>.class));
        Test.startTest();
        String fieldType = VDT_ProductAdoptionController.getProductCountryFieldType();
        Test.stopTest();
        System.assertEquals('REFERENCE', fieldType);
        
    }

    @IsTest
    static void shouldReturnStringTypeForProduct() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Object_Country_Field_Mapping__mdt', 
        (List<VDT_Object_Country_Field_Mapping__mdt>) JSON.deserialize('[{"Country_Field_Reference__c": "Name"}]', List<VDT_Object_Country_Field_Mapping__mdt>.class));
        Test.startTest();
        String fieldType = VDT_ProductAdoptionController.getProductCountryFieldType();
        Test.stopTest();
        System.assertEquals('STRING', fieldType);
    }

    @IsTest
    static void shouldThrowException_WhenFieldDoesNotExists() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Object_Country_Field_Mapping__mdt', 
        (List<VDT_Object_Country_Field_Mapping__mdt>) JSON.deserialize('[{"Country_Field_Reference__c": "Field_Does_Not_Exists__c"}]', List<VDT_Object_Country_Field_Mapping__mdt>.class));
        try {
            Test.startTest();
            String fieldType = VDT_ProductAdoptionController.getProductCountryFieldType();
            Test.stopTest();            
        } catch (Exception e) {
            System.assert(true);
            return;
        }
        System.assert(false, 'Exception should have been thrown');
    }

    @IsTest
    static void shouldThrowException_WhenFieldIsNotLookup() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Object_Country_Field_Mapping__mdt', 
        (List<VDT_Object_Country_Field_Mapping__mdt>) JSON.deserialize('[{"Country_Field_Reference__c": "Lookup_Field__r.Name"}]', List<VDT_Object_Country_Field_Mapping__mdt>.class));
        try {
            Test.startTest();
            VDT_ProductAdoptionController.getCountryOptionFromReference();
            Test.stopTest();
        } catch (Exception e) {
            System.assert(true);
            return;
        }
        System.assert(false, 'Exception should have been thrown');
    }

    @IsTest
    static void shouldReturnDefaultCountryOptions() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"VDT_Default_Countries__c": "BE,FR,DE"}]', List<VDT_General_Setting__mdt>.class));
        Test.startTest();
        List<VDT_OptionWrapper> options = VDT_ProductAdoptionController.getCountryCodeFromProductSetup();
        Test.stopTest();
        System.assertEquals('BE', options.get(0).value);
        System.assertEquals('FR', options.get(1).value);
        System.assertEquals('DE', options.get(2).value);
    }

    @IsTest
    static void shouldReturnInternationalCountryCode() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"International_Country__c": "INT"}]', List<VDT_General_Setting__mdt>.class));
        Test.startTest();
        String internationalCode = VDT_ProductAdoptionController.getInternationalCountryValue();
        Test.stopTest();
        System.assertEquals('INT', internationalCode);
    }

    @IsTest
    static void shouldThrowException_WhenBadInputParameters(){
        String jsonSearchParameters = '{"startYear": 01}';
        try {
            Test.startTest();
            VDT_ProductAdoptionController.recalculateProductAdoption(jsonSearchParameters);
            Test.stopTest();
        } catch (Exception e) {
            System.assert(true);
            return;
        }
        System.assert(false, 'Exception should have been thrown');
    }

    @IsTest
    static void shouldInsertDataCalculation_WhenTriggeredForFirstTime() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Object_Product_Field_Mapping__mdt', 
            (List<VDT_Object_Product_Field_Mapping__mdt>) JSON.deserialize('[{"Product_Field_Reference__c": "VDT_Product_Catalog__c"}]', List<VDT_Object_Product_Field_Mapping__mdt>.class));

        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Object_Country_Field_Mapping__mdt', 
            (List<VDT_Object_Country_Field_Mapping__mdt>) JSON.deserialize('[{"Country_Field_Reference__c": "CreatedBy.Country"}]', List<VDT_Object_Country_Field_Mapping__mdt>.class));

        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"Maximum_Running_Calculations__c": "2", "Batch_Size__c": 200}]', List<VDT_General_Setting__mdt>.class));

        User adminUser = getUser();
        String jsonSearchParameters = '{"startYear": 2015, "startMonth": 1, "endYear": 2021, "endMonth": 1, "countries": ["DE"]}';
        Test.startTest();
        System.runAs(adminUser) {
            /*
            Product_vod__c mainProduct = new VDT_ProductDataFactory('Product Onco')
            .setProperty('Country__c', 'DE')
            .setProperty('Product_Type_vod__c', 'Detail')
            .create()
            .addChildProduct(new VDT_ProductDataFactory('ONCO Lvl 1').setProperty('Country__c', 'DE').getRecord())
            .addChildProduct(new VDT_ProductDataFactory('Onco Level 2').setProperty('Country__c', 'DE').getRecord())
            .getRecord();

            Clm_Presentation_vod__c presentation = new Clm_Presentation_vod__c(
                Status_vod__c = 'Approved_vod',
                End_Date_vod__c = System.Today().addDays(15),
                Product_vod__c = mainProduct.Id
            );
            insert presentation;
            */
            VDT_ProductAdoptionController.recalculateProductAdoption(jsonSearchParameters);
        }
        Test.stopTest();
        List<VDT_Data_Calculation__c> records = [SELECT Id, Status__c FROM VDT_Data_Calculation__c];
        System.assertEquals(1, records.size());
        System.assertEquals(VDT_DataCalculationService.STATUS_COMPLETED, records.get(0).Status__c);
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