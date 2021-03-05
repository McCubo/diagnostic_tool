trigger VDT_LogTrigger on VDT_Log__e (after insert) {
    system.debug('VDT_LogTrigger');
    VDT_TriggerHandler.execute(new VDT_LogTriggerHandler());
}