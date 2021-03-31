trigger VDT_CalculationStatusUpdateTrigger on VDT_Calculation_Status_Update__e (after insert) {
    VDT_TriggerHandler.execute(new VDT_CalculationStatusTriggerHandler());
}