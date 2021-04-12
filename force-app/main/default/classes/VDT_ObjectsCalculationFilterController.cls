public inherited sharing class VDT_ObjectsCalculationFilterController {
    
    @AuraEnabled(cacheable=true)
    public static List<VDT_OptionWrapper> fetchObjectOptions(){
        List<VDT_OptionWrapper> objecOptions = new List<VDT_OptionWrapper>();

        for(Schema.SObjectType objType : VDT_ObjectService.getAllAccessibleObjects()) {
            objecOptions.add(
                new VDT_OptionWrapper(objType.getDescribe().getLabel(), objType.getDescribe().getName())
            );
        }

        return objecOptions;
    }
}