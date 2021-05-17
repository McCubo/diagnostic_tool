public inherited sharing class VDT_EmailService {

    public static final String TEMPLATE_CALCULATION_FINISHED = 'VDT_FieldCamparisonCalculationFinished';
    public static final String TEMPLATE_MASTER_ANALYSIS_FINISHED = 'VDT_MasterAnalysisCalculationFinished';
    public static final String TEMPLATE_FIELDS_OCCURRENCES_FINISHED = 'VDT_FieldsOccurrencesFinished';
    public static final String TEMPLATE_TERRITORY_ANALYSIS_FINISHED = 'VDT_TerritoryAnalysisFinished';
    public static final String SENDER_DISPLAY_NAME = 'BASELife CRM [TBD]';
    public static final String REPLY_TO = 'no-reply@base-crm.com.TBD';

    public static void sendTerritoryAnalysisFinishedEmailNotification(String country) {
        List<EmailTemplate> emailTemplates = new VDT_EmailTemplateSelector().getByName(TEMPLATE_TERRITORY_ANALYSIS_FINISHED);
        List<VDT_Data_Calculation__c> calculationObjects = new VDT_DataCalculationSelector()
                                                            .withLimit(1)
                                                            .withAdditionalFields(new List<String>{'CreatedById'})
                                                            .withConditionals(new List<String> {
                                                                'VDT_Country__c = \'' + country + '\'',
                                                                'RecordType.DeveloperName = \'' + VDT_DataCalculationSelector.TERRITORY_ANALYSIS_RECORD_TYPE_DEV + '\''
                                                            })
                                                            .query();
        if (emailTemplates.isEmpty()) {
            throw new EmailServiceException('Email Template Not Found');
        }
        if (calculationObjects.isEmpty()) {
            throw new EmailServiceException('Calculation For Notification Not Found');
        }
        VDT_EmailService.sendEmail(emailTemplates[0].Id, calculationObjects[0].CreatedById, calculationObjects[0].Id);
    }

    public static void sendFieldValuesOccurrencesFinishedEmailNotification(String objectName) {
        List<EmailTemplate> emailTemplates = new VDT_EmailTemplateSelector().getByName(TEMPLATE_FIELDS_OCCURRENCES_FINISHED);
        List<VDT_Data_Calculation__c> calculationObjects = new VDT_DataCalculationSelector().withAdditionalFields(new List<String>{'CreatedById'}).getByObjectNameAndReocordType(objectName, VDT_DataCalculationSelector.FIELD_OCCURRENCE_RECORD_TYPE_DEV);
        if (emailTemplates.isEmpty()) {
            throw new EmailServiceException('Email Template Not Found');
        }
        if (calculationObjects.isEmpty()) {
            throw new EmailServiceException('Calculation For Notification Not Found');
        }
        VDT_EmailService.sendEmail(emailTemplates[0].Id, calculationObjects[0].CreatedById, calculationObjects[0].Id);
    }

    public static void sendMasterAnalysisCalculationFinishedEmailNotification(String countries) {

        List<VDT_Data_Calculation__c> calculationObjects = new VDT_DataCalculationSelector().withAdditionalFields(new List<String>{'CreatedById'}).withLimit(1).getByCountries(countries);
        List<EmailTemplate> emailTemplates = new VDT_EmailTemplateSelector().getByName(TEMPLATE_MASTER_ANALYSIS_FINISHED);
        if (emailTemplates.isEmpty()) {
            throw new EmailServiceException('Email Template Not Found');
        }
        if (calculationObjects.isEmpty()) {
            throw new EmailServiceException('Calculation For Notification Not Found');
        }
        VDT_EmailService.sendEmail(emailTemplates[0].Id, calculationObjects[0].CreatedById, calculationObjects[0].Id);
    }

    private static void sendEmail(String templateId, String userId, String sobjectId) {
        
        List<User> users = [SELECT Id, Email FROM User WHERE Id = :userId];
        Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(templateId, userId, sobjectId);

        message.setTargetObjectId(userId); 
        message.setSenderDisplayName(SENDER_DISPLAY_NAME); 
        message.setReplyTo(REPLY_TO);
        message.setUseSignature(false); 
        message.setBccSender(false); 
        message.setSaveAsActivity(false); 
        message.toAddresses = new String[] { users.get(0).Email };


        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (!results[0].success) {
            throw new EmailServiceException('Email Failed To Send: ' +  results[0].errors[0].message);
        } 
    }

    public static void sendFieldCalculationFinishedEmailNotification(String objectName) {
        List<EmailTemplate> emailTemplates = new VDT_EmailTemplateSelector().getByName(TEMPLATE_CALCULATION_FINISHED);
        List<VDT_Data_Calculation__c> calculationObjects = new VDT_DataCalculationSelector().withAdditionalFields(new List<String>{'CreatedById'}).getByObjectName(objectName);
        String userId = calculationObjects[0].CreatedById;
        if (emailTemplates.isEmpty()) {
            throw new EmailServiceException('Email Template Not Found');
        }
        if (calculationObjects.isEmpty()) {
            throw new EmailServiceException('Calculation For Notification Not Found');
        }

        Messaging.SingleEmailMessage message = 
            Messaging.renderStoredEmailTemplate(emailTemplates[0].Id, userId, calculationObjects[0].Id);

        
        List<User> users = [SELECT Id, Email FROM User WHERE Id = :userId];

        message.setTargetObjectId(userId); 
        message.setSenderDisplayName(SENDER_DISPLAY_NAME); 
        message.setReplyTo(REPLY_TO);
        message.setUseSignature(false); 
        message.setBccSender(false); 
        message.setSaveAsActivity(false); 
        message.toAddresses = new String[] { users.get(0).Email };


        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (!results[0].success) {
            throw new EmailServiceException('Email Failed To Send: ' +  results[0].errors[0].message);
        }
    }

    public class EmailServiceException extends Exception {}
}