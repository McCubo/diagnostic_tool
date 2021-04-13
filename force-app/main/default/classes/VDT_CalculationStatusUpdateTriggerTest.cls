@IsTest
public with sharing class VDT_CalculationStatusUpdateTriggerTest {

    @IsTest
    static void shouldSetStatusToError_WhenEventFired(){
        
        VDT_Data_Calculation__c calc = new VDT_DataCalculationDataFactory()
            .status('In Progress')
            .recordType(VDT_DataCalculationSelector.MASTER_ANALYSIS_RECORD_TYPE_DEV)
            .insertRecord()
            .getRecord();
        VDT_Calculation_Status_Update__e calculationUpdate = new VDT_Calculation_Status_Update__e(
            Calculation_Id__c = calc.Id,
            Status__c = 'Error'
        );

        Test.startTest();
        Database.SaveResult sr = Eventbus.publish(calculationUpdate);
        Test.stopTest();
        System.assert(sr.isSuccess());

        VDT_Data_Calculation__c calcUpdated = [SELECT Id, Status__c FROM VDT_Data_Calculation__c WHERE Id = :calc.Id];
        System.assertEquals('Error', calcUpdated.Status__c);
    }

    @IsTest
    static void shouldSetStatusToCompleted_WhenEventFired(){
        
        VDT_Data_Calculation__c calc = new VDT_DataCalculationDataFactory()
            .status('In Progress')
            .recordType(VDT_DataCalculationSelector.MASTER_ANALYSIS_RECORD_TYPE_DEV)
            .insertRecord()
            .getRecord();
        VDT_Calculation_Status_Update__e calculationUpdate = new VDT_Calculation_Status_Update__e(
            Calculation_Id__c = calc.Id,
            Status__c = 'Completed'
        );

        Test.startTest();
        Database.SaveResult sr = Eventbus.publish(calculationUpdate);
        Test.stopTest();
        System.assert(sr.isSuccess());

        VDT_Data_Calculation__c calcUpdated = [SELECT Id, Status__c FROM VDT_Data_Calculation__c WHERE Id = :calc.Id];
        System.assertEquals('Completed', calcUpdated.Status__c);
    }

}