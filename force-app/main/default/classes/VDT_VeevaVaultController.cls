/**
 * @description Used to query objects using the TOOLING API
 * @author BASE Life Science
 * @since 2021.03.01
 */
public with sharing class VDT_VeevaVaultController {

    @AuraEnabled
    public static List<VDT_Vault_Document_Column__mdt> getColumns(){
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
                selectFields.add(activeColumn.Veeva_API_Name__c);
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
    public static List<DocumentWrapper> getApprovedDocuments(List<String> vaultDocIds) {
        try {
            List<DocumentWrapper> documents = new List<DocumentWrapper>();
            
            String documentVaultIdField = VDT_CustomMetadataService.getFieldNameForCustomObject('DOCUMENT_VAULT_ID');
            String documentTypeField = VDT_CustomMetadataService.getFieldNameForCustomObject('DOCUMENT_TYPE');
            String documentStatusField = VDT_CustomMetadataService.getFieldNameForCustomObject('DOCUMENT_STATUS');

            String packageVersion = VDT_CustomMetadataService.getPackageVersion();
            Map<String,String> queriesByName = VDT_CustomMetadataService.getQueriesByPackageVersionAndModule(packageVersion, 'Vault Document');

            String approvedValue = [SELECT Status_Value__c FROM VDT_Vault_Document_Status__mdt WHERE Package_Version__c = :packageVersion AND Status__c = 'APPROVED' ][0].Status_Value__c;

            String approvedDocumentsQuery = queriesByName.get('Documents');
            List<SObject> records = Database.query(approvedDocumentsQuery);
            Map<String, String> vaultStatusMap = getVaultStatusMap();
            for (SObject record : records) {
                documents.add(new DocumentWrapper(
                    vaultStatusMap, 
                    String.valueOf(record.get(documentVaultIdField)), 
                    record.Id,
                    getPropertyValue(record, documentTypeField),
                    String.valueOf(record.get(documentStatusField)), 
                    approvedValue)
                );
            }
            return documents;
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Map<String, String> getVaultStatusMap() {
        Map<String, String> vaultStatusMap = new Map<String, String>();
        for (VDT_Vault_Document_Status_Map__mdt statusMap : [SELECT MasterLabel, Document_Status__c FROM VDT_Vault_Document_Status_Map__mdt]) {
            vaultStatusMap.put(statusMap.Document_Status__c, statusMap.MasterLabel);
        }
        return vaultStatusMap;
    }

    public class DocumentWrapper {

        @AuraEnabled
        public String vaultDocId;

        @AuraEnabled
        public String status;

        @AuraEnabled
        public String type;

        @AuraEnabled
        public Boolean isApproved;

        @AuraEnabled
        public String crmId;

        public DocumentWrapper(Map<String, String> vaultStatusMap, String vaultDocId, String crmId, String type, String status, String approvedValue) {
            this.vaultDocId = vaultDocId;
            this.status = vaultStatusMap.containsKey(status) ? vaultStatusMap.get(status) : status;
            this.isApproved = approvedValue == status;
            this.crmId = crmId;
            this.type = type;
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
