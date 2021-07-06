/**
 * @description Provides Service Apex code coverage for all methods found in VDT_TabsController apex class
 * @author BASE Life Science
 * @since 2021.03.01
 */
@IsTest
public with sharing class VDT_TabsControllerTest {

    @IsTest
    static void methodName() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Tab__mdt', 
        (List<VDT_Tab__mdt>) JSON.deserialize('[{"DeveloperName": "home"}, {"DeveloperName": "master_data_analysis"}]', List<VDT_Tab__mdt>.class));
        List<String> menuOptions = new List<String>();
        Test.startTest();
        String csvOptions = VDT_TabsController.getActiveMainMenuOptions();
        menuOptions = csvOptions.split(',');
        Test.stopTest();
        System.assert(!menuOptions.isEmpty());
        System.assertEquals(2, menuOptions.size());
    }
}