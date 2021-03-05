public inherited sharing class VDT_ToolingAPICalloutMock {
    public class PageLayoutCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(
                '{' + 
                '   "size":579,' + 
                '   "totalSize":579,' + 
                '   "done":true,' + 
                '   "queryLocator":null,' + 
                '   "entityTypeName":"ProfileLayout",' + 
                '   "records":' + 
                '       [' + 
                '           {' + 
                '               "attributes":{' + 
                '                   "type":"ProfileLayout",' + 
                '                   "url":"/services/data/v51.0/tooling/sobjects/ProfileLayout/01G0v00000ZiDEzEAN"' + 
                '               },' + 
                '               "Layout":{' + 
                '                   "attributes":{' + 
                '                       "type":"Layout",' + 
                '                       "url":"/services/data/v51.0/tooling/sobjects/Layout/00h46000003WwoOAAS"' + 
                '                   }' +
                '               },' +
                '               "Name": "LAYOUT1"' + 
                '           },' + 
                '           {' + 
                '               "attributes":{' + 
                '                   "type":"ProfileLayout",' + 
                '                   "url":"/services/data/v51.0/tooling/sobjects/ProfileLayout/01G0v00000ZiDEzEAN"' + 
                '               },' + 
                '               "Layout":{' + 
                '                   "attributes":{' + 
                '                       "type":"Layout",' + 
                '                       "url":"/services/data/v51.0/tooling/sobjects/Layout/00h46000003WwoOAAS"' + 
                '                   }' +
                '               },' +
                '               "Name": "LAYOUT2"' + 
                '           },' + 
                '           {' + 
                '               "attributes":{' + 
                '                   "type":"ProfileLayout",' + 
                '                   "url":"/services/data/v51.0/tooling/sobjects/ProfileLayout/01G0v00000ZiDEzEAN"' + 
                '               },' + 
                '               "Layout":{' + 
                '                   "attributes":{' + 
                '                       "type":"Layout",' + 
                '                       "url":"/services/data/v51.0/tooling/sobjects/Layout/00h46000003WwoOAAS"' + 
                '                   }' +
                '               },' +
                '               "Name": "LAYOUT3"' + 
                '           }' + 
                '       ]' +
                '}');
            res.setStatusCode(200);
            return res;
        }
    } 
}
