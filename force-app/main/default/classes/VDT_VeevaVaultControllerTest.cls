/**
 * @description provides code coverage for VDT_VeevaVaultController apex class
 * @author BASE Life Science
 * @since 2021.03.01
 */
@IsTest
public class VDT_VeevaVaultControllerTest {

    @IsTest
    static void shouldReturnApproved_StatusFieldAPI() {
        
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Vault_Document_Status_Map__mdt', 
            (List<VDT_Vault_Document_Status_Map__mdt>) JSON.deserialize('[{"Document_Status__c": "Approved_vod"}]', List<VDT_Vault_Document_Status_Map__mdt>.class));
        String statusField;
        Test.startTest();
        statusField = VDT_VeevaVaultController.getStatusValue('Approved');
        Test.stopTest();
        System.assertEquals('Approved_vod', statusField);

    }

    @IsTest
    static void shouldReturnStatusMap() {
        
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Vault_Document_Status_Map__mdt', 
            (List<VDT_Vault_Document_Status_Map__mdt>) JSON.deserialize('[{"Vault_Status__c": "Approved", "Document_Status__c": "Approved"}, {"Vault_Status__c": "Expired", "Document_Status__c": "Inactive"}]', 
            List<VDT_Vault_Document_Status_Map__mdt>.class));
        Test.startTest();
        Map<String, String> mapstatuses = VDT_VeevaVaultController.getStatusMap();
        Test.stopTest();
        System.assertEquals('Approved', mapstatuses.get('Approved'));
        System.assertEquals('Expired', mapstatuses.get('Inactive'));

    }

    @IsTest
    static void shouldReturn_CRMColumns() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_CRM_Document_Column__mdt', 
        (List<VDT_CRM_Document_Column__mdt>) JSON.deserialize('[{"MasterLabel": "CRM - Document Id", "Field_API_Name__c": "Document_ID_vod__c", "Vault_API_Field__c": "id"}]', 
        List<VDT_CRM_Document_Column__mdt>.class));        
        Test.startTest();
        List<VDT_CRM_Document_Column__mdt> columns = VDT_VeevaVaultController.getCRMColumns();
        Test.stopTest();
        System.assertEquals(1, columns.size());
        System.assertEquals('CRM - Document Id', columns.get(0).MasterLabel);
        System.assertEquals('Document_ID_vod__c', columns.get(0).Field_API_Name__c);
    }

    @IsTest
    static void shouldReturnFieldAPIByKey() {
        
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Custom_Objects_Field_Mapping__mdt', 
            (List<VDT_Custom_Objects_Field_Mapping__mdt>) JSON.deserialize('[{"Field_API_Name__c": "VDT_Custom_Id__c"}]', List<VDT_Custom_Objects_Field_Mapping__mdt>.class));
        Test.startTest();
        String fieldApiName = VDT_VeevaVaultController.getAPIFieldNameByMappingName('Testing ID');
        Test.stopTest();
        System.assertEquals('VDT_Custom_Id__c', fieldApiName);
    }

    @IsTest
    static void shouldReturn_VaultColumns() {
        
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Vault_Document_Column__mdt', 
            (List<VDT_Vault_Document_Column__mdt>) JSON.deserialize('[{"MasterLabel": "", "Vault_API_Name__c": "id"}]', List<VDT_Vault_Document_Column__mdt>.class));
        Test.startTest();
        List<VDT_Vault_Document_Column__mdt> columns = VDT_VeevaVaultController.getVaultColumns();
        Test.stopTest();
        System.assertEquals(1, columns.size());
        System.assertEquals('id', columns.get(0).Vault_API_Name__c);

    }

    @IsTest
    static void shouldReturn_VaultDcouments() {
        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Vault_Document_Column__mdt', 
            (List<VDT_Vault_Document_Column__mdt>) JSON.deserialize('[{"MasterLabel": "", "Vault_API_Name__c": "id"}]', List<VDT_Vault_Document_Column__mdt>.class));

        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        multimock.setStaticResource('callout:VDT_Veeva_Vault/auth', 'VDT_VaultAuthResponse');
        multimock.setStaticResource('callout:VDT_Veeva_Vault/query','VDT_VaultQueryResponse');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, multimock);

        Test.startTest();
        List<Object> vaultDocuments = VDT_VeevaVaultController.getDocumentsFromVault();
        Test.stopTest();
        System.assert(!vaultDocuments.isEmpty());
        System.assertEquals(5, vaultDocuments.size());
    }

    @IsTest
    static void shouldReturn_ApprovedDocuments() {

        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_CRM_Document_Column__mdt', 
        (List<VDT_CRM_Document_Column__mdt>) JSON.deserialize('[{"MasterLabel": "CRM - Document Id", "Field_API_Name__c": "Id", "Vault_API_Field__c": "id"}]', 
        List<VDT_CRM_Document_Column__mdt>.class));

        VDT_CustomMetadataService.customMetadataWithRecords.put('VDT_Query__mdt', 
        (List<VDT_Query__mdt>) JSON.deserialize('[{"Name__c": "Documents", "Query__c": "SELECT {0} FROM Approved_Document_vod__c"}]', 
        List<VDT_Query__mdt>.class));

        Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Approved_Document_vod__c' AND DeveloperName = 'Email_Fragment_vod'][0].Id;
        sObject aDocument = Schema.getGlobalDescribe().get('Approved_Document_vod__c').newSObject();
        aDocument.put('RecordTypeId', recordTypeId);
        aDocument.put('Name', 'TEST DOC');
        insert aDocument;

        Test.startTest();
        List<SObject> crmDocuments = VDT_VeevaVaultController.getApprovedDocuments(new List<String>());
        Test.stopTest();
        System.assert(!crmDocuments.isEmpty());
        System.assertEquals(1, crmDocuments.size());
        
    }

    @IsTest
    static void shouldHandleException() {
        try {
            Integer value = 1/0;
        } catch (Exception e) {
            VDT_VeevaVaultController.handleException(e);
        }
    }
}