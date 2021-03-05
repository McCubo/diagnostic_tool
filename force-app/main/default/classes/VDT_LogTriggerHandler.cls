/**
 * Trigger Handler for Account object
 */
public with sharing class VDT_LogTriggerHandler extends VDT_TriggerHandler.DelegateBase {

    public VDT_LogTriggerHandler() {}

    public override void afterInsert(Map<Id, sObject> newMap) {
        validateRun();
        setAfterInsert((Map<Id, VDT_Log__e>) newMap);
    }

    private void setAfterInsert(Map<Id, VDT_Log__e> newMap) {
        system.debug('newMap :: ' + newMap);
        List<VDT_Log_Event__c> events = new List<VDT_Log_Event__c>();

        for (VDT_Log__e event : newMap.values()) {
            events.add(
                new VDT_Log_Event__c(
                    Log_Data__c = event.Log_Message__c,
                    Quiddity__c = event.Quiddity__c,
                    Request_Id__c = event.Request_Id__c,
                    Severity__c = event.Severity__c
                )
            );
        }

        List<Database.SaveResult> res = Database.insert(events, false);
        for (Database.SaveResult saveRes : res) {
            if (!saveRes.isSuccess()) {
                System.debug(
                    LoggingLevel.ERROR,
                    'Failed to save log message: ' + saveRes
                );
            }
        }
    }
}
