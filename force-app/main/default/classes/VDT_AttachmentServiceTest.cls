@IsTest
public inherited sharing class VDT_AttachmentServiceTest {
    @IsTest
    static void shouldCreateAttachmentForRecord() {
        Account acc = new Account(
            Name = 'Test Attachment Account'
        );
        insert acc;

        Test.startTest();
        VDT_AttachmentService.createAttachmentForRecord('Test Content For Attachment', 'TEST_ATT', VDT_AttachmentService.JSON_FORMAT, acc.Id);
        Test.stopTest();

        List<Attachment> attachments = [ SELECT Id, Name, Body FROM Attachment WHERE ParentId = :acc.Id ];
        System.assertEquals(1, attachments.size());
        System.assertEquals('TEST_ATT.json', attachments[0].Name);
        System.assertEquals('Test Content For Attachment', attachments[0].Body.toString());
    }

    @IsTest
    static void shouldUpdateAttachmentForRecord() {
        Account acc = new Account(
            Name = 'Test Attachment Account'
        );
        insert acc;

        VDT_AttachmentService.createAttachmentForRecord('Test Content For Attachment', 'TEST_ATT', VDT_AttachmentService.JSON_FORMAT, acc.Id);
        Test.startTest();
        VDT_AttachmentService.updateAttachmentForRecord('Updated Content', 'TEST_ATT', VDT_AttachmentService.JSON_FORMAT, acc.Id);
        Test.stopTest();

        List<Attachment> attachments = [ SELECT Id, Name, Body  FROM Attachment WHERE ParentId = :acc.Id ];
        System.assertEquals(1, attachments.size());
        System.assertEquals('TEST_ATT.json', attachments[0].Name);
        System.assertEquals('Updated Content', attachments[0].Body.toString());
    }

    @IsTest
    static void shouldGetAttachmentForRecord() {
        Account acc = new Account(
            Name = 'Test Attachment Account'
        );
        insert acc;

        VDT_AttachmentService.createAttachmentForRecord('Test Content For Attachment', 'TEST_ATT', VDT_AttachmentService.JSON_FORMAT, acc.Id);
        Test.startTest();
        Attachment att = VDT_AttachmentService.getAttachmentForRecord('TEST_ATT', VDT_AttachmentService.JSON_FORMAT, acc.Id);
        Test.stopTest();

        System.assertEquals('Test Content For Attachment', att.Body.toString());
    }
}
