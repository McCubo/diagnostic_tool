public with sharing class VeevaMyInsightsStudioController {

    private final String openStudioMessage;
    private final String url;

    public String getOpenStudioMessage() {
        return VOD_VEEVA_MESSAGE.getMsgWithDefault('REDIRECT_TO_STUDIO', 'MI_STUDIO', 'Open MyInsights Studio');
    }

    public String getUrl() {
        return Veeva_Common_vod__c.getValues('Main').MyInsights_Studio_URL_vod__c;
    }
}