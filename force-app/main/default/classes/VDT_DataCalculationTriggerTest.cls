@IsTest
public inherited sharing class VDT_DataCalculationTriggerTest {

    @IsTest
    static void shouldSetNextCalculationToInProgress() {
        
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        multimock.setStaticResource('callout:VDT_ToolingREST/?q=SELECT+Layout.Name+FROM+ProfileLayout+WHERE+TableEnumOrId=\'01I0v000000c9wiEAA\'', 'VDT_ProfileToolingResponse');
        multimock.setStaticResource('callout:VDT_ToolingREST/0000000000001','VDT_ProfileQueryLocator');
        multimock.setStaticResource('callout:VDT_ToolingREST/?q=SELECT+Id+FROM+CustomObject+WHERE+DeveloperName=\'VDT_Log_Event\'', 'VDT_ObjectToolingResponse');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, multimock);

        Id recTypeId = Schema.SObjectType.VDT_Data_Calculation__c.getRecordTypeInfosByDeveloperName().get('VDT_Object_Field_Analysis').getRecordTypeId();
        User contextuser = getUser();
        System.runAs(contextuser){
            List<VDT_Data_Calculation__c> dataCalculations = new List<VDT_Data_Calculation__c>();
            dataCalculations.add(new VDT_Data_Calculation__c(
                VDT_Object_Name__c = 'Account',
                Status__c = VDT_DataCalculationService.STATUS_IN_PROGRESS,
                VDT_Job_Start_Date__c = Datetime.now(),
                RecordTypeId = recTypeId
            ));
            dataCalculations.add(new VDT_Data_Calculation__c(
                VDT_Object_Name__c = 'VDT_Log_Event__c',
                Status__c = VDT_DataCalculationService.STATUS_IN_QUEUE,
                VDT_Job_Start_Date__c = Datetime.now(),
                RecordTypeId = recTypeId
            ));
            insert dataCalculations;
    
            Test.startTest();
            dataCalculations[0].Status__c = VDT_DataCalculationService.STATUS_COMPLETED;
            update dataCalculations[0];
            Test.stopTest();            
        }

        List<VDT_Data_Calculation__c> queue = [ SELECT Id FROM VDT_Data_Calculation__c WHERE Status__c = :VDT_DataCalculationService.STATUS_IN_QUEUE ];
        List<VDT_Data_Calculation__c> processing = [ SELECT Id FROM VDT_Data_Calculation__c WHERE Status__c = :VDT_DataCalculationService.STATUS_COMPLETED ];

    }

    @IsTest
    static void shouldTriggerJobFor_MasterDataAnalysis() {

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        multimock.setStaticResource('callout:VDT_ToolingREST/?q=SELECT+Layout.Name+FROM+ProfileLayout+WHERE+TableEnumOrId+IN+(\'Account\',\'PersonAccount\')','VDT_ProfileToolingResponse');
        multimock.setStaticResource('callout:VDT_ToolingREST/0000000000001','VDT_ProfileQueryLocator');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, multimock);

        Id recTypeId = Schema.SObjectType.VDT_Data_Calculation__c.getRecordTypeInfosByDeveloperName().get('VDT_Master_Data_Analysis').getRecordTypeId();
        Id fieldOccurrenceId = Schema.SObjectType.VDT_Data_Calculation__c.getRecordTypeInfosByDeveloperName().get('VDT_Object_Field_Value_Occurrence').getRecordTypeId();
        Id productAdoption = Schema.SObjectType.VDT_Data_Calculation__c.getRecordTypeInfosByDeveloperName().get('VDT_Product_Adoption').getRecordTypeId();
        Id territoryAnalysisId = Schema.SObjectType.VDT_Data_Calculation__c.getRecordTypeInfosByDeveloperName().get('VDT_Territory_Analysis').getRecordTypeId();
        Id flsId = Schema.SObjectType.VDT_Data_Calculation__c.getRecordTypeInfosByDeveloperName().get('VDT_Field_Level_Security_Analysis').getRecordTypeId();
        
        User contextuser = getUser();
        System.runAs(contextuser) {
            List<VDT_Data_Calculation__c> dataCalculations = new List<VDT_Data_Calculation__c>();
            dataCalculations.add(new VDT_Data_Calculation__c(
                VDT_Country__c = 'All',
                Status__c = VDT_DataCalculationService.STATUS_IN_PROGRESS,
                VDT_Job_Start_Date__c = Datetime.now(),
                RecordTypeId = recTypeId,
                Start_Year__c = 2017,
                End_Year__c = 2021
            ));
            dataCalculations.add(new VDT_Data_Calculation__c(
                VDT_Country__c = 'All',
                Status__c = VDT_DataCalculationService.STATUS_IN_QUEUE,
                VDT_Job_Start_Date__c = Datetime.now(),
                RecordTypeId = recTypeId,
                Start_Year__c = 2018,
                End_Year__c = 2019
            ));
            dataCalculations.add(new VDT_Data_Calculation__c(
                VDT_Object_Name__c = 'Account',
                Status__c = VDT_DataCalculationService.STATUS_IN_QUEUE,
                VDT_Job_Start_Date__c = Datetime.now(),
                RecordTypeId = fieldOccurrenceId
            ));
            dataCalculations.add(new VDT_Data_Calculation__c(
                VDT_Country__c = 'All',
                Status__c = VDT_DataCalculationService.STATUS_IN_QUEUE,
                VDT_Job_Start_Date__c = Datetime.now(),
                RecordTypeId = productAdoption,
                Start_Year__c = 2017,
                End_Year__c = 2021
            ));
            dataCalculations.add(new VDT_Data_Calculation__c(
                VDT_Country__c = 'All',
                Status__c = VDT_DataCalculationService.STATUS_IN_QUEUE,
                VDT_Job_Start_Date__c = Datetime.now(),
                RecordTypeId = territoryAnalysisId
            ));
            dataCalculations.add(new VDT_Data_Calculation__c(
                VDT_Object_Name__c = 'Account',
                Status__c = VDT_DataCalculationService.STATUS_IN_QUEUE,
                VDT_Job_Start_Date__c = Datetime.now(),
                RecordTypeId = flsId
            ));
            dataCalculations.add(new VDT_Data_Calculation__c(
                Permission_Set_Profile_Name__c = 'System Administrator',
                Status__c = VDT_DataCalculationService.STATUS_IN_QUEUE,
                VDT_Job_Start_Date__c = Datetime.now(),
                RecordTypeId = flsId
            )); 
            insert dataCalculations;
    
            Test.startTest();
            dataCalculations[0].Status__c = VDT_DataCalculationService.STATUS_COMPLETED;
            update dataCalculations[0];
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