@IsTest
public with sharing class VDT_ObjectsCalculationControllerTest {

    @IsTest
    static void shouldReturnAllAccesibleObjects() {
        
        User contextuser = getUser('Standard User');
        Test.startTest();
        List<VDT_OptionWrapper> objects = new List<VDT_OptionWrapper>();
        System.runAs(contextuser) {
            objects = VDT_ObjectsCalculationFilterController.fetchObjectOptions();
        }
        Test.stopTest();
        System.assert(!objects.isEmpty());
    }

    @IsTest
    static void shouldThrowException_WhenBadSearchParameters() {
        String jsonSearchParameters = '{"startYear": 01}';
        try {
            VDT_ObjectsCalculationController.searchExistingCalculations(jsonSearchParameters);
        } catch (Exception e) {
            System.assert(true);
            return;
        }
        System.assert(false, 'Exception should have been thrown');
    }

    @IsTest
    static void shouldReturnExistingDataCalculation() {
        String fileContent = '{"uniqueCountryCodes": [], "fields": {}, "countryCodes": []}';
        new VDT_DataCalculationDataFactory()
        .object('Account')
        .startYearAndMonth(2015, 1)
        .endYearAndMonth(2021, 1)
        .calculationDate(System.today())
        .status('Completed')
        .recordType(VDT_DataCalculationSelector.OBJECT_ANALYSIS_RECORD_TYPE_DEV)
        .insertRecord()
        .addAttachment(VDT_ObjectService.FIELD_SUMMARY_CALCULATION_FILE_NAME, fileContent, VDT_AttachmentService.JSON_FORMAT);
        String jsonSearchParameters = '{"startYear": 2015, "startMonth": 1, "endYear": 2021, "endMonth": 1, "objectName": "Account"}';
        Test.startTest();
        VDT_DataCalculationService.DataCalculation dataCalculation = VDT_ObjectsCalculationController.searchExistingCalculations(jsonSearchParameters);
        Test.stopTest();
        System.assertEquals(fileContent, dataCalculation.data);
    }

    @IsTest
    static void shouldReturnFalse_WhenRecordsInQueue() {
        new VDT_DataCalculationDataFactory().status(VDT_DataCalculationService.STATUS_IN_PROGRESS).insertRecord();
        new VDT_DataCalculationDataFactory().status(VDT_DataCalculationService.STATUS_IN_PROGRESS).insertRecord();
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"Maximum_Calculation_Requests__c": "1"}]', List<VDT_General_Setting__mdt>.class));
        Test.startTest();
        Boolean canRun = VDT_ObjectsCalculationController.validateCanRunCalculation();
        Test.stopTest();
        System.assert(!canRun);
    }

    @IsTest
    static void shouldReturnTrue_WhenNoRecordsFound() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"Maximum_Calculation_Requests__c": "3"}]', List<VDT_General_Setting__mdt>.class));
        Test.startTest();
        Boolean canRun = VDT_ObjectsCalculationController.validateCanRunCalculation();
        Test.stopTest();
        System.assert(canRun);
    }

    @IsTest
    static void shouldThrowException_WhenUserHasNoAccessToFields() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"Maximum_Calculation_Requests__c": "3"}]', List<VDT_General_Setting__mdt>.class));
        User contextuser = getUser('Standard User');
        try {
            System.runAs(contextuser) {
                Test.startTest();
                Boolean canRun = VDT_ObjectsCalculationController.validateCanRunCalculation();
                Test.stopTest();
            }            
        } catch (Exception e) {
            System.assert(true);
            return;
        }
        System.assert(false, 'Exception should have been thrown');
    }

    @IsTest
    static void shouldThrowException_WhenBadCalculationParameter() {
        
        String jsonSearchParameters = '{"startYear": 01}';
        try {
            VDT_ObjectsCalculationController.recalculateObjectFieldSummary(jsonSearchParameters);
        } catch (Exception e) {
            System.assert(true);
            return;
        }
        System.assert(false, 'Exception should have been thrown');
        
    }

    @IsTest
    static void shouldInsertDataCalculation_WhenTriggeredForFirstTime() {
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        multimock.setStaticResource('callout:VDT_ToolingREST/?q=SELECT+Layout.Name+FROM+ProfileLayout+WHERE+TableEnumOrId=\'01I0v000000c9wiEAA\'', 'VDT_ProfileToolingResponse');
        multimock.setStaticResource('callout:VDT_ToolingREST/?q=SELECT+Id+FROM+CustomObject+WHERE+DeveloperName=\'VDT_Log_Event\'', 'VDT_ObjectToolingResponse');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, multimock);

        String jsonSearchParameters = '{"startYear": 2015, "startMonth": 1, "endYear": 2021, "endMonth": 1, "objectName": "VDT_Log_Event__c"}';
        User contextuser = getUser('System Administrator');
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'BASE_CRM_Diagnostic_Tool_User']; 
        insert new PermissionSetAssignment(AssigneeId = contextuser.id, PermissionSetId = ps.Id);
        Test.startTest();
        System.runAs(contextuser) {
            VDT_Log_Event__c logEvent = new VDT_Log_Event__c(
                Severity__c = 'INFO',
                Request_Id__c = '1',
                Quiddity__c = 'Info',
                Log_Data__c = 'Info message'
            );
            insert logEvent;
            VDT_ObjectsCalculationController.recalculateObjectFieldSummary(jsonSearchParameters);   
        }        
        Test.stopTest();
        List<VDT_Data_Calculation__c> records = [SELECT Id, Status__c FROM VDT_Data_Calculation__c WHERE VDT_Object_Name__c = 'VDT_Log_Event__c'];
        System.assertEquals(1, records.size());
        System.assertEquals(VDT_DataCalculationService.STATUS_COMPLETED, records.get(0).Status__c);
    }

    private static User getUser(String profile) {
        User newUser = new VDT_UserDataFactory()
        .name('Test#')
        .username('base+user@testing.com')
        .alias('testU_')
        .email('base+user@testing.com')
        .profile(profile)
        .getRecord();
        insert newUser;
        return newUser;
    }
}
