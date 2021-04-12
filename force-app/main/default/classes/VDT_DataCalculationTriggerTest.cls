@IsTest
public inherited sharing class VDT_DataCalculationTriggerTest {

    @IsTest
    static void shouldSetNextCalculationToInProgress() {
        
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        multimock.setStaticResource('callout:VDT_ToolingREST/?q=SELECT+Layout.Name+FROM+ProfileLayout+WHERE+TableEnumOrId=\'01I0v000000c9wiEAA\'', 'VDT_ProfileToolingResponse');
        multimock.setStaticResource('callout:VDT_ToolingREST/?q=SELECT+Id+FROM+CustomObject+WHERE+DeveloperName=\'VDT_Log_Event\'', 'VDT_ObjectToolingResponse');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, multimock);

        User contextuser = getUser();
        System.runAs(contextuser){
            List<VDT_Data_Calculation__c> dataCalculations = new List<VDT_Data_Calculation__c>();
            dataCalculations.add(new VDT_Data_Calculation__c(
                VDT_Object_Name__c = 'Account',
                Status__c = VDT_DataCalculationService.STATUS_IN_QUEUE,
                VDT_Job_Start_Date__c = Datetime.now()
            ));
            dataCalculations.add(new VDT_Data_Calculation__c(
                VDT_Object_Name__c = 'VDT_Log_Event__c',
                Status__c = VDT_DataCalculationService.STATUS_IN_QUEUE,
                VDT_Job_Start_Date__c = Datetime.now()
            ));
            dataCalculations[0].Status__c = VDT_DataCalculationService.STATUS_IN_PROGRESS;
            insert dataCalculations;
    
            Test.startTest();
            dataCalculations[0].Status__c = VDT_DataCalculationService.STATUS_COMPLETED;
            update dataCalculations[0];
            Test.stopTest();            
        }

        List<VDT_Data_Calculation__c> queue = [ SELECT Id FROM VDT_Data_Calculation__c WHERE Status__c = :VDT_DataCalculationService.STATUS_IN_QUEUE ];
        List<VDT_Data_Calculation__c> processing = [ SELECT Id FROM VDT_Data_Calculation__c WHERE Status__c = :VDT_DataCalculationService.STATUS_COMPLETED ];

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