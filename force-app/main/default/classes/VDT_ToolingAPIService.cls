/**
 * @description Used to query objects using the TOOLING API
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_ToolingAPIService {

    /**
     * @param query SOQL Query
     * @return  `String` Response the Tooling API returns.
     */
    public static String toolingAPISOQL(string query) {
        String baseURL='callout:VDT_ToolingREST/';
        return VDT_HttpService.restGet( baseURL +'?q='+ (query.replace(' ', '+')), UserInfo.getSessionId());
    } 

    public static String toolingAPIQueryLocator(string queryLocator) {
        String baseURL='callout:VDT_ToolingREST/';
        return VDT_HttpService.restGet(baseURL + queryLocator, UserInfo.getSessionId());
    } 

    public static Id getCustomObjectId(string objectName) {
        string sql='SELECT Id FROM CustomObject WHERE DeveloperName=\'objectName\'';
        String body = toolingAPISOQL(sql.replace('objectName', objectName));
        String customObjectId;

        if(String.isNotBlank(body)) {
            VDT_ToolingCustomObjectResponse.Root toolingResponse = 
                (VDT_ToolingCustomObjectResponse.Root)JSON.deserialize(body, VDT_ToolingCustomObjectResponse.Root.class);
            String r = String.valueOf(toolingResponse.done) + toolingResponse.entityTypeName + String.valueOf(toolingResponse.size) + String.valueOf(toolingResponse.totalSize) + String.valueOf(toolingResponse.queryLocator);
            for(VDT_ToolingCustomObjectResponse.Record record : toolingResponse.records) {
                String key = record.attributes.type + record.attributes.url;
                if (record.Id != null) {
                    customObjectId = record.Id;
                    break;
                }
            }
        }

        return customObjectId;
    }

    /**
     * @param objectName SObject API Name
     * @return  `List<string>` All Page Layouts available for the given SObject
     */
    public static List<string> getLayoutNamesForObject(string objectName) {
        String enumOrId = objectName;
        if (objectName.indexOf('__c') >= 0) {
            enumOrId = getCustomObjectId(objectName.split('__c')[0]);
        }

        String sql='SELECT Layout.Name FROM ProfileLayout WHERE TableEnumOrId=\'enumOrId\'';
        if (enumOrId == 'Account') {
            sql='SELECT Layout.Name FROM ProfileLayout WHERE TableEnumOrId IN (\'Account\',\'PersonAccount\')';
        }
        if (enumOrId == 'BusinessAccount') {
            enumOrId = 'Account';
        }
        String body = toolingAPISOQL(sql.replace('enumOrId', enumOrId));
        Set<String> layouts = new Set<String>();

        if (String.isNotBlank(body)) {
            VDT_ToolingPageLayoutResponse.Root toolingResponse = (VDT_ToolingPageLayoutResponse.Root)JSON.deserialize(body, VDT_ToolingPageLayoutResponse.Root.class);
            for(VDT_ToolingPageLayoutResponse.Record record : toolingResponse.records) {
                layouts.add(String.valueOf(record.Layout.Name));
            }
            if (String.isNotBlank(toolingResponse.nextRecordsUrl)) {
                Set<String> pageLayouts = queryNextPage(toolingResponse.nextRecordsUrl);
                layouts.addAll(pageLayouts);
            }
        }
        return new List<String>(layouts);
    }

    /**
     * 
     * @param queryLocatorUrl queryLocatorURL property provided by Tooling response
     * @return  `Set<String>` Page Layouts returned by the tooling API
     */
    private static Set<String> queryNextPage(String queryLocatorUrl) {
        Set<String> layoutNames = new Set<String>();
        List<String> queryLocatorUrlParts = queryLocatorUrl.split('/');
        String queryLocatorResponse = toolingAPIQueryLocator(queryLocatorUrlParts.get(queryLocatorUrlParts.size() - 1));
        VDT_ToolingPageLayoutResponse.Root toolingResponse = (VDT_ToolingPageLayoutResponse.Root)JSON.deserialize(queryLocatorResponse, VDT_ToolingPageLayoutResponse.Root.class);
        for(VDT_ToolingPageLayoutResponse.Record record : toolingResponse.records) {
            layoutNames.add(String.valueOf(record.Layout.Name));
        }
        if (String.isNotBlank(toolingResponse.nextRecordsUrl)) {
            Set<String> pageLayouts = queryNextPage(toolingResponse.nextRecordsUrl);
            layoutNames.addAll(pageLayouts);
        }
        return layoutNames;
    }
}