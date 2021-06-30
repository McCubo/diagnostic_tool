/**
 * @description Provides Code coverage for method on VDT_FieldLevelSecurityController apex class.
 * @author BASE Life Science
 * @since 2021.03.01
 */

 @IsTest
public with sharing class VDT_FieldLevelSecurityControllerTest {

    @IsTest
    static void shouldCreateProfileOrPermissionSetCalculation() {
        String jsonSearchParameters = '{"objectNames": ["System Administrator"]}';
        VDT_CustomMetadataService.customMetadataWithRecords.put(
            'VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"Maximum_Running_Calculations__c": "3", "Batch_Size__c": 200}]', List<VDT_General_Setting__mdt>.class)
        );        
        Test.startTest();
        VDT_FieldLevelSecurityController.recalculateFlsAndObjectPermissionAnalysis(jsonSearchParameters);
        Test.stopTest();
    }

    @IsTest
    static void shouldCreateNewCalculationRecord() {
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        multimock.setStaticResource('callout:VDT_ToolingREST/?q=SELECT+Layout.Name+FROM+ProfileLayout+WHERE+TableEnumOrId+IN+(\'Account\',\'PersonAccount\')', 'VDT_ProfileToolingResponse');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, multimock);

        String jsonSearchParameters = '{"objectNames": ["Account"]}';
        VDT_CustomMetadataService.customMetadataWithRecords.put(
            'VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"Maximum_Running_Calculations__c": "3", "Batch_Size__c": 200}]', List<VDT_General_Setting__mdt>.class)
        );
        Test.startTest();
        VDT_FieldLevelSecurityController.recalculateFieldLevelSecurityAnalysis(jsonSearchParameters);
        Test.stopTest();

        List<VDT_Data_Calculation__c> calculations = [SELECT Status__c FROM VDT_Data_Calculation__c WHERE VDT_Object_Name__c = 'Account'];
        System.assert(!calculations.isEmpty());
        System.assertEquals('Completed', calculations.get(0).Status__c);
    }

    @IsTest
    static void shouldReturn_AllAccessibleObjects() {
        List<VDT_OptionWrapper> options = new List<VDT_OptionWrapper>();
        Test.startTest();
        options = VDT_FieldLevelSecurityController.fetchObjectOptions();
        Test.stopTest();
        System.assert(!options.isEmpty());
    }

    @IsTest
    static void shouldReturnFieldCalculationRecord_WhenParametersMatches() {
        VDT_DataCalculationService.DataCalculation calculation;
        String jsonSearchParameters = '{"objectNames": ["Account"]}';
        new VDT_DataCalculationDataFactory()
        .object('Account')
        .status('Completed')
        .recordType(VDT_DataCalculationSelector.FIELD_LEVEL_SECURITY_RECORD_TYPE_DEV)
        .insertRecord()
        .addAttachment(VDT_DataCalculationService.FIELD_LEVEL_SECURITY_FILE_NAME, 'TEST_FILE_CONTENT', VDT_AttachmentService.JSON_FORMAT);
        Test.startTest();
        calculation = VDT_FieldLevelSecurityController.searchExistingCalculations(jsonSearchParameters);
        Test.stopTest();
        System.assertEquals('Completed', calculation.status);
    }

    @IsTest
    static void shouldReturnProfilePermissionSetCalculationRecord_WhenParametersMatches() {
        VDT_DataCalculationService.DataCalculation calculation;
        String jsonSearchParameters = '{"objectNames": ["System Administrator"]}';
        new VDT_DataCalculationDataFactory()
        .profileOrPermissionSet('System Administrator').status('Completed').recordType(VDT_DataCalculationSelector.FIELD_LEVEL_SECURITY_RECORD_TYPE_DEV).insertRecord()
        .addAttachment(VDT_DataCalculationService.FIELD_LEVEL_SECURITY_FILE_NAME, 'TEST_FILE_CONTENT', VDT_AttachmentService.JSON_FORMAT);
        Test.startTest();
        calculation = VDT_FieldLevelSecurityController.searchExistingProfilePermissionSetCalculations(jsonSearchParameters);
        Test.stopTest();
        System.assertEquals('Completed', calculation.status);
    }

    @IsTest
    static void shouldReturnDataCalculations_WhenStatusIsDone() {
        List<VDT_DataCalculationService.DataCalculationLog> logs = new List<VDT_DataCalculationService.DataCalculationLog>();        
        new VDT_DataCalculationDataFactory()
        .profileOrPermissionSet('System Administrator').status('Completed').recordType(VDT_DataCalculationSelector.FIELD_LEVEL_SECURITY_RECORD_TYPE_DEV).insertRecord()
        .addAttachment(VDT_DataCalculationService.FIELD_LEVEL_SECURITY_FILE_NAME, 'TEST_FILE_CONTENT', VDT_AttachmentService.JSON_FORMAT);
        new VDT_DataCalculationDataFactory().profileOrPermissionSet('System Administrator').status('In Progress').recordType(VDT_DataCalculationSelector.FIELD_LEVEL_SECURITY_RECORD_TYPE_DEV).insertRecord();
        Test.startTest();
        logs = VDT_FieldLevelSecurityController.fetchFinishedCalculations();
        Test.stopTest();
        System.assertEquals(1, logs.size());
    }

    @IsTest
    static void shouldReturnAll_ProfilesAndPermissionSets() {
        List<VDT_OptionWrapper> options = new List<VDT_OptionWrapper>();
        Test.startTest();
        options = VDT_FieldLevelSecurityController.getProfilesAndPermissionSets();
        Test.stopTest();
        System.assert(!options.isEmpty());
    }
}