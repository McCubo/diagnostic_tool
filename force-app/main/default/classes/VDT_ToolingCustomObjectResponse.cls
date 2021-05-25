/**
 * @description POJO Object to Map the Tooling API Response
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_ToolingCustomObjectResponse {
    public class Root {
        public Integer size {get;set;} 
        public Integer totalSize {get;set;} 
        public Boolean done {get;set;} 
        public Object queryLocator {get;set;} 
        public String entityTypeName {get;set;} 
        public List<Record> records {get;set;} 
    }

    public class Record {
        public Attributes attributes {get;set;} 
        public String Id {get;set;} 
    } 
    
    public class Attributes {
        public String type {get;set;}
        public String url {get;set;} 
    }
}