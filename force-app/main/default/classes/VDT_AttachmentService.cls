/**
 * @author      BASE Life Science
 * @since       2021.03.01
 * @description This Apex class provides methods to perform CRUD operations on the Attachment SObject.
 */
public inherited sharing class VDT_AttachmentService {
    
    public static final String JSON_FORMAT = '.json';

    /**
     * @description     Create a new File and attaches it to an existing SObject record
     * @param content   content of the new file
     * @param name      Name the new attachment file will have
     * @param format    Extension the file wil use when saved
     * @param recordId  Parent Id (SObject Id) the new file will be linked to.
     */
    public static void createAttachmentForRecord(String content, String name, String format, Id recordId) {
        Attachment att = new Attachment();
        att.Body = Blob.valueOf(content);
        att.Name = name + format;
        att.ParentId = recordId;
        insert att;
    }

    /**
     * @description     Updates the content of an existing file.
     * @param content   New content for the file
     * @param name      Name of the existing file we want to update
     * @param format    Format of the existing file we want to update
     * @param recordId  Parent Id of the existing file
     * @exception AttachmentServiceException thrown if no file is found based on the given name and format
     */
    public static void updateAttachmentForRecord(String content, String name, String format, Id recordId) {
        List<Attachment> attachments = new VDT_AttachmentSelector().getByNameAndParentId(name+format, recordId);

        if (attachments.isEmpty()) {
            throw new AttachmentServiceException('Failed To Load Attachment::' + name + '::From Record::' + recordId);
        }

        attachments[0].Body = Blob.valueOf(content);
        update attachments[0];
    }

    /**
     * @description Given a file name,  file format and Parent Id returns the specified attachment record (if found)
     * @param name File's name we want to retrieve
     * @param format File's format
     * @param recordId Parent Id (SOBject) the attachment file is linked to.
     * @return  `Attachment` SObject
     */
    public static Attachment getAttachmentForRecord(String name, String format, Id recordId) {
        List<Attachment> attachments = new VDT_AttachmentSelector().getByNameAndParentId(name+format, recordId);
        Attachment result;
        if (attachments.isEmpty() == false) {
            result = attachments[0];
        }

        return result;
    }

    /**
     * @description Creates a new file if the parent Id from the recordMap does not have one already, updates it otherwise
     * @param recordMap A map of SObject Ids and File content
     * @param name Name of the new/updated attachment record
     */
    public static void upsertAttachmentForRecords(Map<String, String> recordMap, String name) {
        Set<String> recordIds = recordMap.keySet();
        List<Attachment> attachments = new VDT_AttachmentSelector().withAdditionalFields(new List<String>{'ParentId'}).getByParentIdsAndName(recordIds, name);
        Map<String, Attachment> existingAttachmentsByParentId = new Map<String, Attachment>();
        for (Attachment attachment : attachments) {
            existingAttachmentsByParentId.put(attachment.ParentId, attachment);
        }
        List<Attachment> upsertAttachments = new List<Attachment>();
        for(String parentId : recordMap.keySet()) {
            Attachment att = new Attachment();
            if (existingAttachmentsByParentId.containsKey(parentId)) {
                att = existingAttachmentsByParentId.get(parentId);
            } else {
                att.Name = name;
                att.ParentId = parentId;
            }
            att.Body = Blob.valueOf(recordMap.get(parentId));
            upsertAttachments.add(att);
        }
        upsert upsertAttachments;
    }

    /**
     * 
     * @param parentIds List of unique parent ids we want to retrieve their attachment file
     * @param name File name we want to retrieve
     * @return  `Map<String, String>` a Map with Parent Id as the key and with its file's content as value
     */
    public static Map<String, String> getAttachmentsByParentId(Set<String> parentIds, String name) {
        Map<String, String> contentByParentId = new Map<String, String>();
        List<Attachment> attachments = new VDT_AttachmentSelector()
            .withAdditionalFields(new List<String>{'ParentId'})
            .getByParentIdsAndName(parentIds, name);
        for (Attachment attachment : attachments) {
            contentByParentId.put(attachment.ParentId, attachment.Body.toString());
        }
        return contentByParentId;
    }

    public class AttachmentServiceException extends Exception {}
}