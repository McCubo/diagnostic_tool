/**
 * @description Provides Access to Apex Service Methods to LWC Javascript controllers
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_ObjectsCalculationFilterController {
    
    /**
     * @return  `List<VDT_OptionWrapper>` All SObjects the user has access To, used to populate the options on the `Entity/Object` select component on the
     *          Object-Field Analysis screen.
     */
    @AuraEnabled(cacheable=true)
    public static List<VDT_OptionWrapper> fetchObjectOptions(){
        List<VDT_OptionWrapper> objecOptions = new List<VDT_OptionWrapper>();

        for(Schema.SObjectType objType : VDT_ObjectService.getAllAccessibleObjects()) {
            objecOptions.add(new VDT_OptionWrapper(objType.getDescribe().getLabel(), objType.getDescribe().getName()));
            if (objType.getDescribe().getName() == 'Account') {
                objecOptions.add(new VDT_OptionWrapper('Person Account', 'PersonAccount'));                
                objecOptions.add(new VDT_OptionWrapper('Business Account', 'BusinessAccount'));                
            }
        }

        return objecOptions;
    }
}