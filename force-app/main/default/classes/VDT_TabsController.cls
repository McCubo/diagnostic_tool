/**
 * @description Provides Service Apex methods to LWC javascript controllers
 * @author BASE Life Science
 * @since 2021.03.01
 */
public with sharing class VDT_TabsController {

    /**
     * @return  `string` of comma separated values of all active menu options. Only options returned in this string will be shown to the user
     * @exception AuraHandledException
     */
    @AuraEnabled(cacheable=true)
    public static string getActiveMainMenuOptions() {
        return VDT_CustomMetadataService.getActiveMenuOptions();
    }
}