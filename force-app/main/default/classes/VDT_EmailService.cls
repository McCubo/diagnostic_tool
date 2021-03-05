public inherited sharing class VDT_EmailService {
    public static final String TEMPLATE_CALCULATION_FINISHED = 'VDT_FieldCamparisonCalculationFinished';
    public static final String SENDER_DISPLAY_NAME = 'BASELife CRM [TBD]';
    public static final String REPLY_TO = 'no-reply@base-crm.com.TBD';

    public static void sendFieldCalculationFinishedEmailNotification(String objectName) {
        List<EmailTemplate> emailTemplates = new VDT_EmailTemplateSelector().getByName(TEMPLATE_CALCULATION_FINISHED);
        List<VDT_Data_Calculation__c> calculationObjects = new VDT_DataCalculationSelector().getByObjectName(objectName);

        if (emailTemplates.isEmpty()) {
            throw new EmailServiceException('Email Template Not Found');
        }
        if (calculationObjects.isEmpty()) {
            throw new EmailServiceException('Calculation For Notification Not Found');
        }

        Messaging.SingleEmailMessage message = 
            Messaging.renderStoredEmailTemplate(emailTemplates[0].Id, UserInfo.getUserId(), calculationObjects[0].Id);

        message.setTargetObjectId(UserInfo.getUserId()); 
        message.setSenderDisplayName(SENDER_DISPLAY_NAME); 
        message.setReplyTo(REPLY_TO);
        message.setUseSignature(false); 
        message.setBccSender(false); 
        message.setSaveAsActivity(false); 
        message.toAddresses = new String[] { UserInfo.getUserEmail() };


        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (!results[0].success) {
            throw new EmailServiceException('Email Failed To Send: ' +  results[0].errors[0].message);
        }
    }

    public class EmailServiceException extends Exception {}
}
