public without sharing class WechatAccountTriggerHandler {
    public WechatAccountTriggerHandler() {
    }

    public void onAfterInsert(List<Account> newAccounts) {
        Schema.RecordTypeInfo multiConsentRd = Schema.SObjectType.Multichannel_Consent_vod__c.getRecordTypeInfosByDeveloperName().get('WeChat_vod');
        if(multiConsentRd == null){
            return;
        }
        List<Consent_Type_vod__c> consentType = [SELECT Id FROM Consent_Type_vod__c 
                                                  WHERE RecordType.DeveloperName = 'WeChat_vod' 
                                                  ORDER BY LastModifiedDate DESC
                                                  LIMIT 1];
        if(consentType.size() == 0){
            return;
        }
        List<Content_Type_vod__c> contentType = [SELECT Id FROM Content_Type_vod__c 
                                                  WHERE RecordType.DeveloperName = 'WeChat_WeChatWork_vod' 
                                                    AND Service_Account_App_Id_vod__c!=null
                                                  ORDER BY LastModifiedDate DESC
                                                  LIMIT 1];
        if(contentType.size() == 0){
            return;
        }

        List<Multichannel_Consent_vod__c> multichannelConsents = new List<Multichannel_Consent_vod__c>();
        for (Account acct : newAccounts) {
            // create a pending consent line
            if(acct.Union_Id_vod__c != null){
                multichannelConsents.add(new Multichannel_Consent_vod__c(
                    Account_vod__c = acct.Id,
                    RecordTypeId = multiConsentRd.getRecordTypeId(),
                    Union_Id_vod__c = acct.Union_Id_vod__c,
                    Opt_Type_vod__c = 'Opt_In_Pending_vod',
                    Consent_Type_vod__c = consentType.get(0).Id,
                    Content_Type_vod__c = contentType.get(0).Id,
                    Captured_By_vod__c = acct.CreatedById,
                    Capture_Datetime_vod__c = System.now()
                ));
            }
        }

        if(multichannelConsents.size()>0){
            insert multichannelConsents;
        }
    }
}