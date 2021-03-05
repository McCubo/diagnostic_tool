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

    public class AttachmentServiceException extends Exception {}
}
