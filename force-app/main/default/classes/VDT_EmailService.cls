/**
 * @description Provides methods to send Email Alerts when a job is completed.
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_EmailService {

    public static final String TEMPLATE_CALCULATION_FINISHED = 'VDT_FieldCamparisonCalculationFinished';
    public static final String TEMPLATE_MASTER_ANALYSIS_FINISHED = 'VDT_MasterAnalysisCalculationFinished';
    public static final String TEMPLATE_FIELDS_OCCURRENCES_FINISHED = 'VDT_FieldsOccurrencesFinished';
    public static final String TEMPLATE_TERRITORY_ANALYSIS_FINISHED = 'VDT_TerritoryAnalysisFinished';
    public static final String TEMPLATE_FLS_ANALYSIS_FINISHED = 'VDT_FieldLevelSecurityFinished';
    public static final String TEMPLATE_TERRITORY_EXPORT_FINISHED = 'VDT_TerritoryExportCompleted';
    public static final String SENDER_DISPLAY_NAME = 'BASELife CRM [TBD]';
    public static final String REPLY_TO = 'no-reply@base-crm.com.TBD';

    /**
     * @description Send an Email alert when the Field Level Security Job is completed
     * @param sobjects Comma Separated List of all objects included in the calculation
     * @exception EmailServiceException
     */
    public static void sendFLSAnalysisFinishedEmailNotification(String sobjects) {
        List<EmailTemplate> emailTemplates = new VDT_EmailTemplateSelector().getByName(TEMPLATE_FLS_ANALYSIS_FINISHED);
        List<VDT_Data_Calculation__c> calculationObjects = new VDT_DataCalculationSelector()
                                                            .withLimit(1)
                                                            .withAdditionalFields(new List<String>{'CreatedById'})
                                                            .withConditionals(new List<String> {
                                                                'VDT_Object_Name__c = \'' + sobjects + '\'',
                                                                'RecordType.DeveloperName = \'' + VDT_DataCalculationSelector.FIELD_LEVEL_SECURITY_RECORD_TYPE_DEV + '\''
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

    /**
     * @description Send an Email alert when the Territory Analysis Job is completed.
     * @param country Comma Separated List of all Countries included in the calculation
     * @exception EmailServiceException
     */
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

    /**
     * @description Send an Email alert when the Field Values Occurrences Job is completed
     * @param sobjects SObject API Name the calculation was run for.
     * @exception EmailServiceException
     */
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

    /**
     * @description Send an Email alert when the Master Data Analysis job is completed.
     * @param country Comma Separated List of all Countries included in the calculation
     * @exception EmailServiceException
     */
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

    /**
     * 
     * @param templateId An email template that exists in the database, such as text, HTML, custom, and Visualforce templates.
     * @param userId The identifier of an object in the database, typically a contact, lead, or user. The database record for that object is read and used in merge field processing.
     * @param sobjectId Identifies an object in the database (VDT_Data_Calculation__c). The record for that object is read and used in merge field processing.
     * @exception EmailServiceException
     */
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

    public static void sendTerritoryExportNotification() {
        List<EmailTemplate> emailTemplates = new VDT_EmailTemplateSelector().getByName(TEMPLATE_TERRITORY_EXPORT_FINISHED);
        if (emailTemplates.isEmpty()) {
            throw new EmailServiceException('Email Template Not Found');
        }
        sendEmail(emailTemplates.get(0).Id, UserInfo.getUserId(), null);
    }

    /**
     * @description Send an Email alert when the Field Calculation Job is completed
     * @param sobjects SObject API Name the calculation was run for.
     * @exception EmailServiceException
     */
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