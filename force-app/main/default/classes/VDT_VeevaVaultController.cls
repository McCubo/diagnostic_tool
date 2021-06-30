/**
 * @description Used to query objects using the TOOLING API
 * @author BASE Life Science
 * @since 2021.03.01
 */
public with sharing class VDT_VeevaVaultController {

    @AuraEnabled
    public static String getStatusValue(String status) {
        try {
            String packageVersion = VDT_CustomMetadataService.getPackageVersion();
            String approvedValue = [SELECT Status_Value__c 
                                    FROM VDT_Vault_Document_Status__mdt 
                                    WHERE Package_Version__c = :packageVersion AND Status__c = :status][0].Status_Value__c;
            return approvedValue;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Map<String, String> getStatusMap() {
        try {
            Map<String, String> statusMap = new Map<String, String>();
            for (VDT_Vault_Document_Status_Map__mdt statusMapCMT : [SELECT MasterLabel, Document_Status__c FROM VDT_Vault_Document_Status_Map__mdt]) {
                statusMap.put(statusMapCMT.Document_Status__c, statusMapCMT.MasterLabel);
            }
            return statusMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<VDT_CRM_Document_Column__mdt> getCRMColumns() {
        try {
            String packageVersion = VDT_CustomMetadataService.getPackageVersion();
            return [SELECT MasterLabel, Field_API_Name__c, Vault_API_Field__c FROM VDT_CRM_Document_Column__mdt WHERE Package_Version__c = :packageVersion];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getAPIFieldNameByMappingName(String mapName) {
        try {
            String packageVersion = VDT_CustomMetadataService.getPackageVersion();
            return VDT_CustomMetadataService.getFieldNameForCustomObject(packageVersion, mapName);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<VDT_Vault_Document_Column__mdt> getVaultColumns(){
        try {
            return VDT_CustomMetadataService.getActiveDocumentColumns();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Object> getDocumentsFromVault() {
        try {            
            List<String> selectFields = new List<String>();
            for (VDT_Vault_Document_Column__mdt activeColumn : VDT_CustomMetadataService.getActiveDocumentColumns()) {
                selectFields.add(activeColumn.Vault_API_Name__c);
            }

            String vql = String.format('SELECT {0} FROM documents', new List<String>{
                String.join(selectFields, ',')
            });
            return VDT_VeevaVaultService.parseResponse(vql);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<SObject> getApprovedDocuments(List<String> vaultDocIds) {
        try {
            List<SObject> documents = new List<SObject>();

            String packageVersion = VDT_CustomMetadataService.getPackageVersion();
            Map<String,String> queriesByName = VDT_CustomMetadataService.getQueriesByPackageVersionAndModule(packageVersion, 'Vault Document');

            List<String> columns = new List<String>();
            for (VDT_CRM_Document_Column__mdt crmColumn : [SELECT Field_API_Name__c FROM VDT_CRM_Document_Column__mdt WHERE Package_Version__c = :packageVersion]) {
                columns.add(crmColumn.Field_API_Name__c);
            }

            String approvedDocumentsQuery = queriesByName.get('Documents');
            List<SObject> records = Database.query(String.format(approvedDocumentsQuery, new List<String>{
                String.join(columns, ',')
            }));
            for (SObject record : records) {
                documents.add(record);
            }
            return documents;
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static String getPropertyValue(SObject record, String fieldName) {
        String value = '';
        if (fieldName.contains('.')) {
            String relationship = fieldName.split('\\.').get(0);
            String relatedField = fieldName.split('\\.').get(1);
            if (record.getSObject(relationship) != null) {
                value = record.getSObject(relationship).get(relatedField).toString();
            }
        } else {
            value = String.valueOf(record.get(fieldName));
        }
        return value;
    }
}
