/**
 * @author      BASE Life Science
 * @since       2021.03.01
 * @description This Apex class provides code coverage for VDT_AttachmentService apex class
 */
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
    static void shouldThrowException_WhenUpdatingRecord() {
        Boolean exceptionThrown = false;        
        Test.startTest();
        try {
            VDT_AttachmentService.updateAttachmentForRecord('Updated Content', 'TEST_ATT', VDT_AttachmentService.JSON_FORMAT, null);            
        } catch (VDT_AttachmentService.AttachmentServiceException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assert(exceptionThrown);
    }

    @IsTest
    static void shouldUpsertAttachmentContent_WhenMultipleRecordsAreSent() {
        Account accWAttachments = new Account(Name = 'Account w Attachment');
        Account accWoAttachments = new Account(Name = 'Account wo Attachment');
        insert new List<Account>{accWAttachments, accWoAttachments};
        VDT_AttachmentService.createAttachmentForRecord('Test Content For Attachment', VDT_ObjectCalculationBuilder.COUNTRY_USAGE_FILE_NAME, VDT_AttachmentService.JSON_FORMAT, accWAttachments.Id);
        Test.startTest();
        Map<String, String> attachmentContentByParentId = new Map<String, String>();
        attachmentContentByParentId.put(accWAttachments.Id, 'New Content');
        attachmentContentByParentId.put(accWoAttachments.Id, 'New Content');
        VDT_AttachmentService.upsertAttachmentForRecords(attachmentContentByParentId, VDT_ObjectCalculationBuilder.COUNTRY_USAGE_FILE_NAME + VDT_AttachmentService.JSON_FORMAT);
        Test.stopTest();
    }

    @IsTest
    static void shouldInsertContentDocument() {
        Test.startTest();
        VDT_AttachmentService.insertDocument(VDT_ObjectCalculationBuilder.COUNTRY_USAGE_FILE_NAME, 'Test Content', VDT_AttachmentService.JSON_FORMAT);
        Test.stopTest();        
    }

    @IsTest
    static void shouldReturn_AllAttachmentsForTheGivenParents() {
        Account accWAttachments = new Account(Name = 'Account w Attachment');
        Account accWoAttachments = new Account(Name = 'Account wo Attachment');
        insert new List<Account>{accWAttachments, accWoAttachments};
        VDT_AttachmentService.createAttachmentForRecord('Test Content For Attachment', VDT_ObjectCalculationBuilder.COUNTRY_USAGE_FILE_NAME, VDT_AttachmentService.JSON_FORMAT, accWAttachments.Id);
        VDT_AttachmentService.createAttachmentForRecord('Test Content For Attachment', VDT_ObjectCalculationBuilder.COUNTRY_USAGE_FILE_NAME, VDT_AttachmentService.JSON_FORMAT, accWoAttachments.Id);
        Test.startTest();
        VDT_AttachmentService.getAttachmentsByParentId(new Set<String>{accWAttachments.Id, accWoAttachments.Id}, VDT_ObjectCalculationBuilder.COUNTRY_USAGE_FILE_NAME + VDT_AttachmentService.JSON_FORMAT);
        Test.stopTest();
        
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