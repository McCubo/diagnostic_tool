@IsTest
public inherited sharing class VDT_CalculationLogsControllerTest {
    @IsTest
    static void shouldFetchFinishedDataCalculations() {
        List<VDT_Data_Calculation__c> dataCalculations = new List<VDT_Data_Calculation__c>();
        for (Integer i = 0; i < 10; i++) {
            dataCalculations.add(new VDT_Data_Calculation__c(
                VDT_Object_Name__c = 'OBJ_' + i,
                Status__c = VDT_DataCalculationService.STATUS_IN_PROGRESS,
                VDT_Job_Start_Date__c = Datetime.now()
            ));
        }
        insert dataCalculations;
        dataCalculations[0].Status__c = VDT_DataCalculationService.STATUS_COMPLETED;
        dataCalculations[1].Status__c = VDT_DataCalculationService.STATUS_ERROR;
        update dataCalculations[0];
        update dataCalculations[1];

        Test.startTest();
        List<VDT_Data_Calculation__c> calculations = VDT_CalculationLogsController.fetchFinishedCalculations();
        Test.stopTest();

        System.assertEquals(2, calculations.size());
        System.assertEquals(VDT_DataCalculationService.STATUS_COMPLETED, calculations[0].Status__c);
        System.assertEquals(VDT_DataCalculationService.STATUS_ERROR, calculations[1].Status__c);
    }
    
    @IsTest
    static void shouldFetchFinishedDataCalculationsWithError() {
        Boolean hasExc = false;

        try {
            VDT_DataCalculationService.finishedCalculationStatuses = null;
            Test.startTest();
            VDT_CalculationLogsController.fetchFinishedCalculations();
            Test.stopTest();
        } catch (AuraHandledException e) {
            hasExc = true;
        }

        System.assert(hasExc);
    }
}
