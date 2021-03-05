public inherited sharing class VDT_ToolingAPIService {
    public static String toolingAPISOQL(string query) {
        String baseURL='callout:VDT_ToolingREST/';
        return VDT_HttpService.restGet( baseURL +'?q='+ (query.replace(' ', '+')), UserInfo.getSessionId());
    } 

    public static Id getCustomObjectId(string objectName) {
        string sql='SELECT Id FROM CustomObject WHERE DeveloperName=\'objectName\'';
        String body = toolingAPISOQL(sql.replace('objectName', objectName));
        String customObjectId;

        if(String.isNotBlank(body)) {
            VDT_ToolingCustomObjectResponse.Root toolingResponse = 
                (VDT_ToolingCustomObjectResponse.Root)JSON.deserialize(body, VDT_ToolingCustomObjectResponse.Root.class);
            for(VDT_ToolingCustomObjectResponse.Record record : toolingResponse.records) {
                if (record.Id != null) {
                    customObjectId = record.Id;
                    break;
                }
            }
        }

        return customObjectId;
    }

    public static List<string> getLayoutNamesForObject(string objectName) {
        String enumOrId = objectName;
        if (objectName.indexOf('__c') >= 0) {
            enumOrId = getCustomObjectId(objectName.split('__c')[0]);
        }

        String sql='SELECT Layout.Name FROM ProfileLayout WHERE TableEnumOrId=\'enumOrId\'';
        String body = toolingAPISOQL(sql.replace('enumOrId', objectName));
        Set<String> layouts = new Set<String>();

        if(String.isNotBlank(body)){
            VDT_ToolingPageLayoutResponse.Root toolingResponse = 
                (VDT_ToolingPageLayoutResponse.Root)JSON.deserialize(body, VDT_ToolingPageLayoutResponse.Root.class);
            
            for(VDT_ToolingPageLayoutResponse.Record record : toolingResponse.records) {
                layouts.add(String.valueOf(record.Layout.Name));
            }
        }
        return new List<String>(layouts);
    }
}
