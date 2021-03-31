@IsTest
public inherited sharing class VDT_AnalysisDashboardFilterCtrlTest {
    
    @IsTest
    static void shouldGetStandardFieldIdentifier() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', 
            (List<VDT_General_Setting__mdt>) JSON.deserialize('[{"Standard_Field_Identifier__c": "test_identifier"}]', List<VDT_General_Setting__mdt>.class));
        Test.startTest();
        String standardFieldIdentifier = VDT_AnalysisDashboardFilterController.getStandardFieldIdentifier();
        Test.stopTest();
        system.assertEquals('test_identifier', standardFieldIdentifier);
    }

    @IsTest
    static void shouldGetStandardFieldIdentifierWithException() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_General_Setting__mdt', null);
        Boolean hasExc = false;
        try {
            Test.startTest();
            VDT_AnalysisDashboardFilterController.getStandardFieldIdentifier();
            Test.stopTest();
        } catch (AuraHandledException e) {
            hasExc = true;
        }
        system.assert(hasExc);
    }
}