@isTest
public inherited sharing class VDT_DataCalculationTriggerTest {
    @isTest
    static void shouldSetNextCalculationToInProgress() {
        Test.setMock(VDT_ToolingAPICalloutMock.PageLayoutCallout.class, new VDT_ToolingAPICalloutMock.PageLayoutCallout());
        List<VDT_Data_Calculation__c> dataCalculations = new List<VDT_Data_Calculation__c>();
        dataCalculations.add(new VDT_Data_Calculation__c(
            VDT_Object_Name__c = 'Account',
            Status__c = VDT_DataCalculationService.STATUS_IN_QUEUE,
            VDT_Job_Start_Date__c = Datetime.now()
        ));
        dataCalculations.add(new VDT_Data_Calculation__c(
            VDT_Object_Name__c = 'Contact',
            Status__c = VDT_DataCalculationService.STATUS_IN_QUEUE,
            VDT_Job_Start_Date__c = Datetime.now()
        ));
        dataCalculations.add(new VDT_Data_Calculation__c(
            VDT_Object_Name__c = 'Product2',
            Status__c = VDT_DataCalculationService.STATUS_IN_QUEUE,
            VDT_Job_Start_Date__c = Datetime.now()
        ));
        dataCalculations.add(new VDT_Data_Calculation__c(
            VDT_Object_Name__c = 'Contract',
            Status__c = VDT_DataCalculationService.STATUS_IN_QUEUE,
            VDT_Job_Start_Date__c = Datetime.now()
        ));
        dataCalculations[0].Status__c = VDT_DataCalculationService.STATUS_IN_PROGRESS;
        insert dataCalculations;

        Test.startTest();
        dataCalculations[0].Status__c = VDT_DataCalculationService.STATUS_COMPLETED;
        update dataCalculations[0];
        Test.stopTest();

        List<VDT_Data_Calculation__c> queue = [ SELECT Id FROM VDT_Data_Calculation__c WHERE Status__c = :VDT_DataCalculationService.STATUS_IN_QUEUE ];
        List<VDT_Data_Calculation__c> processing = [ SELECT Id FROM VDT_Data_Calculation__c WHERE Status__c = :VDT_DataCalculationService.STATUS_COMPLETED ];
        
        system.assertEquals(2, queue.size());
        system.assertEquals(2, processing.size());
    }
}
