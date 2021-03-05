public inherited sharing class VDT_FileService {
    public static final String JSON_FORMAT = '.json';
    public static Id createJSONFile(String jsonString) {
        Blob bodyBlob = Blob.valueOf(jsonString);
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = 'summary_calculation.json';
        conVer.Title = 'summary_calculation';
        conVer.VersionData = bodyBlob;
        insert conVer;
        return conVer.Id;
    }

    public static void createFileForRecord(String fileContent, String fileName, String fileFormat, Id recordId) {
        Blob bodyBlob = Blob.valueOf(fileContent);

        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = fileName + fileFormat;
        conVer.Title = fileName;
        conVer.VersionData = bodyBlob;
        insert conVer;

        List<ContentVersion> contentVersions = [
            SELECT  ContentDocumentId 
            FROM    ContentVersion 
            WHERE   Id = :conVer.Id
            WITH    SECURITY_ENFORCED
        ];

        if (contentVersions[0].ContentDocumentId != null) {
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = recordId;
            conDocLink.ContentDocumentId = contentVersions[0].ContentDocumentId;
            conDocLink.shareType = 'V';
            insert conDocLink;
        }
    }

    public static void updateFileForRecord(String fileContent, String fileName, Id recordId) {
        Blob bodyBlob = Blob.valueOf(fileContent);

        List<ContentDocumentLink> linkedDocuments = [ 
            SELECT  Id, 
                    ContentDocumentId 
            FROM    ContentDocumentLink 
            WHERE   LinkedEntityId = :recordId
            WITH    SECURITY_ENFORCED
        ];

        List<Id> contentDocumentIds = new List<Id>();
        for (ContentDocumentLink documentLink : linkedDocuments) {
            contentDocumentIds.add(documentLink.ContentDocumentId);
        }

        List<ContentVersion> contentVersions = [
            SELECT  Id,
                    VersionData
            FROM    ContentVersion
            WHERE   ContentDocumentId IN :contentDocumentIds AND 
                    Title = :fileName AND
                    IsLatest = TRUE
            WITH    SECURITY_ENFORCED
        ];

        if (contentVersions.isEmpty() == false) {
            contentVersions[0].VersionData = bodyBlob;
            update contentVersions[0];
        }
    }

    public static void relateFileWithRecord(Id contentVersionId, Id recordId) {
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersionId].ContentDocumentId;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = recordId;
        conDocLink.ContentDocumentId = conDoc;
        conDocLink.shareType = 'V';
        insert conDocLink;
    }

    public static ContentVersion getLatestFileVersionForRecord(String fileName, Id recordId) {
        ContentVersion file = null;

        List<ContentDocumentLink> contentDocumentLinks = [ 
            SELECT  Id, 
                    ContentDocumentId 
            FROM    ContentDocumentLink 
            WHERE   LinkedEntityId = :recordId
            WITH    SECURITY_ENFORCED
        ];

        List<Id> contentDocumentIds = new List<Id>();
        for (ContentDocumentLink documentLink : contentDocumentLinks) {
            contentDocumentIds.add(documentLink.ContentDocumentId);
        }

        List<ContentVersion> contentVersions = [
            SELECT  Id,
                    VersionData
            FROM    ContentVersion
            WHERE   ContentDocumentId IN :contentDocumentIds AND 
                    Title = :fileName AND
                    IsLatest = TRUE
            WITH    SECURITY_ENFORCED
        ];

        if (contentVersions.isEmpty() == false) {
            file = contentVersions[0];
        }

        return file;
    }
}