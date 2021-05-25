/**
 * @description Helper Class to parse the JSON response for each Field when Field-Analysis is run
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_FieldSummary {

    public String id;

    public String label;
    
    public String name;
    
    public String type;
    
    public List<String> pageLayouts = new List<String>();

    public Map<String, CountryUsageSummary> countryUsageSummary =  new Map<String, CountryUsageSummary>();

    public VDT_FieldSummary(String label, String name, String type) {
        this.label = label;
        this.name = name;
        this.type = type;
    }

    public Boolean isNew() {
        return String.isBlank(this.id);
    }

    public static String getParsedObjects(List<VDT_Field_Summary__c> summaries, Map<String, String> attachmentsByParent) {
        List<String> jsonResponses = new List<String>();
        for (VDT_Field_Summary__c summary : summaries) {
            String jsonRow = String.format('"{0}":\'{\'"type":"{1}","pageLayouts":{2},"name":"{0}","label":"{3}","countryUsageSummary":{4}\'}\'', new List<String>{
                summary.Name__c,
                summary.Type__c,
                summary.Page_Layouts__c,
                summary.Label__c,
                attachmentsByParent.containsKey(summary.Id) ? attachmentsByParent.get(summary.Id) : '{}'
            });
            jsonResponses.add(jsonRow);
        }
        return '"fields":{' + String.join(jsonResponses, ',') + '}';
    }

    public class CountryUsageSummary {

        public Integer usageNumber = 0;
        
        public Integer totalRecords = 0;
        
        public Decimal usagePercentage = 0;
        
        public Map<String, Decimal> fieldValueOccurences = new Map<String, Decimal>();
    }

}