/**
 * @description provides code coverage to apex methods on VDT_TerritoryAnalysisController aura controller
 * @author BASE Life Science
 * @since 2021.03.01
 */
@IsTest
public class VDT_TerritoryAnalysisControllerTest {

    @IsTest
    static void shouldThrowException() {
        
        Test.startTest();
        VDT_TerritoryAnalysisController.handleException(new AuraHandledException('TEST'));
        Test.stopTest();
        
    }

    @IsTest
    static void shouldDelete_DataCalculationRecords() {
        VDT_Data_Calculation__c r1 = new VDT_DataCalculationDataFactory().status(VDT_DataCalculationService.STATUS_IN_PROGRESS).insertRecord().getRecord();
        VDT_Data_Calculation__c r2 = new VDT_DataCalculationDataFactory().status(VDT_DataCalculationService.STATUS_IN_PROGRESS).insertRecord().getRecord();
        List<String> ids = new List<String>{r1.Id, r2.Id};
        Test.startTest();
        VDT_TerritoryAnalysisController.deleteCalculationRecords(ids);
        Test.stopTest();
        List<VDT_Data_Calculation__c> records = [SELECT Id FROM VDT_Data_Calculation__c];
        System.assert(records.isEmpty());
    }

    @IsTest
    static void shouldReturn_TerritoryHierarchyItems() {
        
        List<VDT_TerritoryAnalysisBuilder.TerritoryItem> items = new List<VDT_TerritoryAnalysisBuilder.TerritoryItem>();
        Test.startTest();
        items = VDT_TerritoryAnalysisController.getTerritoryHierarchy();
        Test.stopTest();   
    }

    @IsTest
    static void shouldReturn_FinishedTerritoryCalculations() {
        
        new VDT_DataCalculationDataFactory()
            .recordType(VDT_DataCalculationSelector.TERRITORY_ANALYSIS_RECORD_TYPE_DEV)
            .status(VDT_DataCalculationService.STATUS_COMPLETED)
            .insertRecord();
        List<VDT_DataCalculationService.DataCalculationLog> logs;
        Test.startTest();
        logs = VDT_TerritoryAnalysisController.fetchFinishedCalculations();
        Test.stopTest();
        System.assert(!logs.isEmpty());
    }

    @IsTest
    static void shouldReturnParentTerritoryOptions() {        
        List<VDT_OptionWrapper> options = new List<VDT_OptionWrapper>();
        Test.startTest();
        options = VDT_TerritoryAnalysisController.getAllTerritoryOptions();
        Test.stopTest();
    }

    @IsTest
    static void shouldReturnCalculation_CountryDE() {
        
        VDT_DataCalculationService.DataCalculation calculation;
        String jsonSearchParameters = '{"countries": ["DE"]}';
        new VDT_DataCalculationDataFactory()
        .country('DE')
        .status(VDT_DataCalculationService.STATUS_COMPLETED)
        .recordType(VDT_DataCalculationSelector.TERRITORY_ANALYSIS_RECORD_TYPE_DEV)
        .insertRecord()
        .addAttachment(VDT_DataCalculationService.TERRITORY_ANALYSIS_FILE_NAME, 'TEST_FILE_CONTENT', VDT_AttachmentService.JSON_FORMAT);        
        Test.startTest();
        calculation = VDT_TerritoryAnalysisController.searchExistingCalculations(jsonSearchParameters);
        Test.stopTest();        
    }

    @IsTest
    static void shouldReturnCalculation_Territory() {
        
        VDT_DataCalculationService.DataCalculation calculation;
        String jsonSearchParameters = '{"countries": [], "territory": "ALL"}';
        new VDT_DataCalculationDataFactory()
        .territory('ALL')
        .status(VDT_DataCalculationService.STATUS_COMPLETED)
        .recordType(VDT_DataCalculationSelector.TERRITORY_ANALYSIS_RECORD_TYPE_DEV)
        .insertRecord()
        .addAttachment(VDT_DataCalculationService.TERRITORY_ANALYSIS_FILE_NAME, 'TEST_FILE_CONTENT', VDT_AttachmentService.JSON_FORMAT);        
        Test.startTest();
        calculation = VDT_TerritoryAnalysisController.searchExistingCalculations(jsonSearchParameters);
        Test.stopTest();  
    }

    @IsTest
    static void shouldRunJob_CalculateTerritoryManagement() {
        
        String jsonSearchParameters = '{"countries": ["DE"]}';
        User contextuser = getUser();
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"Package_Version__c": "Veeva", "Batch_Size__c": 200, "VDT_Default_Specialty_Field__c": "Type", "Maximum_Running_Calculations__c": "2"}]', List<VDT_General_Setting__mdt>.class));
        
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Object_Country_Field_Mapping__mdt', 
            (List<VDT_Object_Country_Field_Mapping__mdt>) JSON.deserialize('[{"Country_Field_Reference__c": "CreatedBy.Country"}]', List<VDT_Object_Country_Field_Mapping__mdt>.class));
        System.runAs(contextuser) {
            Account a = new Account(Name = 'ORG Test');
            insert a;
            List<Territory2> terriroty = [SELECT Id FROM Territory2 WHERE ParentTerritory2Id = NULL LIMIT 1];
            ObjectTerritory2Association assoc = new ObjectTerritory2Association(
                ObjectId = a.Id,
                Territory2Id = terriroty.get(0).Id,
                AssociationCause = 'Territory2Manual'
            );
            insert assoc;
            Test.startTest();
            VDT_TerritoryAnalysisController.recalculateTerritoryAnalysis(jsonSearchParameters);
            Test.stopTest();
        }

        
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
