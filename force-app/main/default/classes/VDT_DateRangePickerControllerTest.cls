@isTest
public inherited sharing class VDT_DateRangePickerControllerTest {
    @isTest
    static void shouldGetStartDateYearDecrement() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"Start_Date_Year_Decrement__c": "4"}]', List<VDT_General_Setting__mdt>.class));
        
        Test.startTest();
        Integer decrement = VDT_DateRangePickerController.getStartDateYearDecrement();
        Test.stopTest();

        System.assertEquals(4, decrement);
    }

    @isTest
    static void shouldGetStartDateYearDecrementWithException() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', null);
        
        Boolean hasExc = false;

        try {
            Test.startTest();
            Integer decrement = VDT_DateRangePickerController.getStartDateYearDecrement();
            Test.stopTest();
        } catch (AuraHandledException e) {
            hasExc = true;
        }

        System.assert(hasExc);
    }
}
