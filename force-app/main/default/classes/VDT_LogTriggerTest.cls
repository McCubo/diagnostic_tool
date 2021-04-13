@IsTest
public with sharing class VDT_LogTriggerTest {

    @IsTest
    static void shouldInsertLogRecord_WhenEventFired(){
        
        VDT_Log__e logEvent = new VDT_Log__e(
            Log_Message__c = 'Log From Apex Class',
            Quiddity__c = 'Test',
            Request_Id__c = '1',
            Severity__c = 'WARN'
        );

        Test.startTest();
        Database.SaveResult sr = Eventbus.publish(logEvent);
        Test.stopTest();
        System.assert(sr.isSuccess());

        List<VDT_Log_Event__c> newLogEvents = [SELECT Id, Severity__c FROM VDT_Log_Event__c];
        System.assert(!newLogEvents.isEmpty());
        System.assertEquals('WARN', newLogEvents.get(0).Severity__c);
    }
}