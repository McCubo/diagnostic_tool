public inherited sharing class VDT_ObjectsCalculationFilterController {
    @AuraEnabled(cacheable=true)
    public static List<VDT_OptionWrapper> fetchObjectOptions(){
        try {
            List<VDT_OptionWrapper> objecOptions = new List<VDT_OptionWrapper>();

            for(Schema.SObjectType objType : VDT_ObjectService.getAllAccessibleObjects()) {
                objecOptions.add(
                    new VDT_OptionWrapper(objType.getDescribe().getLabel(), objType.getDescribe().getName())
                );
            }

            return objecOptions;
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
}