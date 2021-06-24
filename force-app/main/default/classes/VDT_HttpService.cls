/**
 * @description Provides method to perform requests via HTTP methods
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_HttpService {
    private static final STRING METHOD_GET = 'GET';
    private static final STRING METHOD_POST = 'POST';

    /**
     * @description request a REST resource using the `GET` method
     * @param endpoint URL to perform the request to
     * @param sessionId User Session Id
     * @return  `String` response returned by the given endpoint
     */
    public static String restGet(String endpoint, String sessionId) {
        try
        {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('Authorization', 'Bearer ' + sessionId);
            request.setTimeout(60000);
            request.setEndpoint(endPoint);
            request.setMethod(METHOD_GET);
            HttpResponse response = http.send(request);
            return response.getBody();
        }
        catch(Exception ex) {
            VDT_Log.get().add('Exception in tooling API Call:'+ ex.getMessage() + '\n' + ex.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            return ex.getMessage();
        }
    }

    /**
     * @description request a REST resource using the `POST` method
     * @param endpoint URL to perform the request to
     * @param headers value/key pair of all headers to be included in the request
     * @param body request's body
     * @return  `String`
     */
    public static String restPost(String endpoint, Map<String, String> headers, String body) {
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod(METHOD_POST);
            for (String header : headers.keySet()) {
                request.setHeader(header, headers.get(header));
            }            
            request.setBody(body);
            Http http = new Http();
            HTTPResponse response = http.send(request);
            return response.getBody();
        } catch (Exception ex) {
            VDT_Log.get().add('Exception in REST API Call:'+ ex.getMessage() + '\n' + ex.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            return ex.getMessage();            
        }
    }
}