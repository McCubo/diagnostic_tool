/**
 * @description Used to query objects using the TOOLING API
 * @author BASE Life Science
 * @since 2021.03.01
 */
public with sharing class VDT_VeevaVaultController {

    @AuraEnabled
    public static String getStatusValue(String status, String section) {
        try {
            return VDT_CustomMetadataService.getStatusApiFieldName(status, section);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Map<String, String> getStatusMap(String section) {
        try {
            return VDT_CustomMetadataService.getVaultCrmStatusesMap(section);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<VDT_CRM_Document_Column__mdt> getCRMColumns(String section) {
        try {
            return VDT_CustomMetadataService.getCRMColumns(section);
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
    public static List<VDT_Vault_Document_Column__mdt> getVaultColumns(String section){
        try {
            return VDT_CustomMetadataService.getActiveDocumentColumns(section);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Object> getDocumentsFromVault(String section) {
        try {
            List<String> selectFields = new List<String>();
            for (VDT_Vault_Document_Column__mdt activeColumn : VDT_CustomMetadataService.getActiveDocumentColumns(section)) {
                selectFields.add(activeColumn.Vault_API_Name__c);
            }
            String whereClause = VDT_CustomMetadataService.getVaultDocumentTypes(section);
            String vql = String.format('SELECT {0} FROM documents {1}', new List<String>{
                String.join(selectFields, ','),
                whereClause
            });
            return VDT_VeevaVaultService.parseResponse(vql);
        } catch (Exception e) {
            throw handleException(e);
        }
    }

    @AuraEnabled
    public static List<SObject> getApprovedDocuments(List<String> vaultDocIds, String section) {
        try {
            List<SObject> documents = new List<SObject>();

            String packageVersion = VDT_CustomMetadataService.getPackageVersion();
            Map<String, String> queriesByName = VDT_CustomMetadataService.getQueriesByPackageVersionAndModule(packageVersion, 'Vault Document');

            List<String> columns = new List<String>();
            for (VDT_CRM_Document_Column__mdt crmColumn : VDT_CustomMetadataService.getCRMColumns(section)) {
                columns.add(crmColumn.Field_API_Name__c);
            }

            String approvedDocumentsQuery = queriesByName.get(section);
            List<SObject> records = Database.query(String.format(approvedDocumentsQuery, new List<String>{
                String.join(columns, ',')
            }));
            documents.addAll(records);
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