@IsTest
public with sharing class VDT_DateRangePickerTest {

    @IsTest
    static void shouldReturnIntegerValueFromMetadata(){
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"Start_Date_Year_Decrement__c": "3"}]', List<VDT_General_Setting__mdt>.class));
        Test.startTest();
        Integer startYearDecrement = VDT_DateRangePicker.getStartDateYearDecrement();
        Test.stopTest();
        System.assertEquals(3, startYearDecrement);
    }

    @IsTest
    static void shouldThrowException_WhenUserHasNoAccessToMetadata() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"Start_Date_Year_Decrement__c": "3"}]', List<VDT_General_Setting__mdt>.class));
        User contextuser = getUser();
        try {
            Test.startTest();
            System.runAs(contextuser){
                VDT_DateRangePicker.getStartDateYearDecrement();
            }
            Test.stopTest();
        } catch (Exception e) {
            System.assert(true);
            return;
        }
        System.assert(false, 'Exception should have been thrown');
    }

    private static User getUser() {
        User newUser = new VDT_UserDataFactory()
        .name('Test#')
        .username('base+user@testing.com')
        .alias('testU_')
        .email('base+user@testing.com')
        .profile('Standard User')
        .getRecord();
        insert newUser;
        return newUser;
    }
}
