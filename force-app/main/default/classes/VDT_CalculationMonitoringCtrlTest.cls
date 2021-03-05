@IsTest
public inherited sharing class VDT_CalculationMonitoringCtrlTest {
    @isTest
    static void shouldGetMonitoringData() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"Maximum_Calculation_Requests__c": "4"}]', List<VDT_General_Setting__mdt>.class));

        List<VDT_Data_Calculation__c> dataCalculations = new List<VDT_Data_Calculation__c>();
        for (Integer i = 0; i < 2; i++) {
            dataCalculations.add(new VDT_Data_Calculation__c(
                VDT_Object_Name__c = 'OBJ_' + i,
                Status__c = VDT_DataCalculationService.STATUS_IN_PROGRESS,
                VDT_Job_Start_Date__c = Datetime.now()
            ));
        }
        dataCalculations.add(new VDT_Data_Calculation__c(
            VDT_Object_Name__c = 'OBJ_3',
            Status__c = VDT_DataCalculationService.STATUS_IN_QUEUE
        ));
        insert dataCalculations;
        
        Test.startTest();
        VDT_DataCalculationService.MonitoringData monitoringData = 
            VDT_CalculationMonitoringController.getCalculationsInProgress();
        Test.stopTest();

        system.assertEquals(2, monitoringData.inProgress);
        system.assertEquals(1, monitoringData.inQueue);
        system.assertEquals(1, monitoringData.remaining);
        system.assertEquals(4, monitoringData.capacity);
    }

    @isTest
    static void shouldGetMonitoringDataWithException() {
        Boolean hasExc = false;

        try {
            VDT_DataCalculationService.inProgressCalculationStatuses = null;
            Test.startTest();
            VDT_CalculationMonitoringController.getCalculationsInProgress();
            Test.stopTest();
        } catch (AuraHandledException e) {
            hasExc = true;
        }

        system.assert(hasExc);
    }
}
