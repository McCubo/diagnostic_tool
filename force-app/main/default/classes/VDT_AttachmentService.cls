public inherited sharing class VDT_AttachmentService {
    
    public static final String JSON_FORMAT = '.json';

    public static void createAttachmentForRecord(String content, String name, String format, Id recordId) {
        Attachment att = new Attachment();
        att.Body = Blob.valueOf(content);
        att.Name = name + format;
        att.ParentId = recordId;
        insert att;
    }

    public static void updateAttachmentForRecord(String content, String name, String format, Id recordId) {
        List<Attachment> attachments = new VDT_AttachmentSelector().getByNameAndParentId(name+format, recordId);

        if (attachments.isEmpty()) {
            throw new AttachmentServiceException('Failed To Load Attachment::' + name + '::From Record::' + recordId);
        }

        attachments[0].Body = Blob.valueOf(content);
        update attachments[0];
    }

    public static Attachment getAttachmentForRecord(String name, String format, Id recordId) {
        List<Attachment> attachments = new VDT_AttachmentSelector().getByNameAndParentId(name+format, recordId);
        Attachment result;
        if (attachments.isEmpty() == false) {
            result = attachments[0];
        }

        return result;
    }

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