/**
 * @description Used to query objects using the TOOLING API
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_VeevaVaultService {
    
    private static String getSessionId() {
        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/x-www-form-urlencoded');
        headers.put('Accept', 'application/json');
        String body = 'username={!$Credential.UserName}&password={!$Credential.Password}';
        String endpoint = 'callout:VDT_Veeva_Vault/auth';
        return VDT_HttpService.restPost(endpoint, headers, body);
    }

    private static String executeVQL(String vql) {
        String response = getSessionId();
        Map<String, Object> sessionObject = (Map<String, Object>) JSON.deserializeUntyped(response);
        if (sessionObject.containsKey('responseStatus') && String.valueOf(sessionObject.get('responseStatus')) == 'SUCCESS') {
            String sessionId = (String) sessionObject.get('sessionId');
            Map<String, String> headers = new Map<String, String>();
            headers.put('Authorization', sessionId);
            headers.put('Accept', 'application/json');
            headers.put('Content-Type', 'application/x-www-form-urlencoded');
            String endpoint = 'callout:VDT_Veeva_Vault/query';
            String body = 'q=' + EncodingUtil.urlEncode(vql, 'UTF-8');
            return VDT_HttpService.restPost(endpoint, headers, body);
        }
        return null;
    }

    public static List<Object> parseResponse(String vql) {
        String response = executeVQL(vql);
        Map<String, Object> vqlResponse = (Map<String, Object>) JSON.deserializeUntyped(response);
        if (vqlResponse.containsKey('responseStatus') && String.valueOf(vqlResponse.get('responseStatus')) == 'SUCCESS') {
            return (List<Object>) vqlResponse.get('data');
        }
        return new List<Object>();
    }
}