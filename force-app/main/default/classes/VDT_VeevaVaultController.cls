/**
 * @description Used to query objects using the TOOLING API
 * @author BASE Life Science
 * @since 2021.03.01
 */
public with sharing class VDT_VeevaVaultController {

    @AuraEnabled
    public static String getStatusValue(String status) {
        try {
            return VDT_CustomMetadataService.getStatusApiFieldName(status);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Map<String, String> getStatusMap() {
        try {
            return VDT_CustomMetadataService.getVaultCrmStatusesMap();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<VDT_CRM_Document_Column__mdt> getCRMColumns() {
        try {
            return VDT_CustomMetadataService.getCRMColumns();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getAPIFieldNameByMappingName(String mapName) {
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
            throw handleException(e);
        }
    }

    @AuraEnabled
    public static List<SObject> getApprovedDocuments(List<String> vaultDocIds) {
        try {
            List<SObject> documents = new List<SObject>();

            String packageVersion = VDT_CustomMetadataService.getPackageVersion();
            Map<String, String> queriesByName = VDT_CustomMetadataService.getQueriesByPackageVersionAndModule(packageVersion, 'Vault Document');

            List<String> columns = new List<String>();
            for (VDT_CRM_Document_Column__mdt crmColumn : VDT_CustomMetadataService.getCRMColumns()) {
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
            throw handleException(e);
        }
    }

    @TestVisible
    private static AuraHandledException handleException(Exception e) {
        VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
        VDT_Log.get().publish();
        return new AuraHandledException(e.getMessage());
    }
}