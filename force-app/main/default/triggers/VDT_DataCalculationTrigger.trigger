trigger VDT_DataCalculationTrigger on VDT_Data_Calculation__c (before insert, before update, after insert, after update) {
    VDT_TriggerHandler.execute(new VDT_DataCalculationTriggerHandler());
}