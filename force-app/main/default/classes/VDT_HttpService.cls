public inherited sharing class VDT_HttpService {
    private static final STRING METHOD_GET = 'GET';

    public static String restGet(String endpoint, String sessionId) {
        try
        {
            system.debug('endpoint :: ' + endpoint);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            // request.setHeader('Authorization', 'Bearer ' + sessionId);
            request.setTimeout(60000);
            request.setEndpoint(endPoint);
            request.setMethod(METHOD_GET);
            HttpResponse response = http.send(request);
            return response.getBody();
        }
        catch(Exception ex)
        {
            system.debug('Exception in tooling API Call:'+ ex.getMessage());
            return ex.getMessage();
        }
    }
}