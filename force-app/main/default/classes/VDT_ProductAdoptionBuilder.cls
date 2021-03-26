public with sharing class VDT_ProductAdoptionBuilder {

    private ProductAdoptionSummary adoptionData = new ProductAdoptionSummary();
    private List<Product_vod__c> records = new List<Product_vod__c>();
    private Set<String> productIds = new Set<String>();
    private Map<String, Integer> keyMessagesByProduct = new Map<String, Integer>();
    private Map<String, Integer> presentationsByProduct = new Map<String, Integer>();
    private Map<String, Integer> approvedDocumentsByProduct = new Map<String, Integer>();
    private Map<String, Integer> sentEmailsByProduct = new Map<String, Integer>();
    private Map<String, Integer> productMetricsByProduct = new Map<String, Integer>();
    private Map<String, Integer> callsByProduct = new Map<String, Integer>();
    private Map<String, String> countryFieldByObject = new Map<String, String>();
    private final String PRESENTATION_STATUS_APPROVED = 'Approved_vod';
    private final String APPROVED_DOCUMENT_STATUS_APPROVED = 'Approved_vod';
    private final String KEY_DELIMITER = '_';

    public VDT_ProductAdoptionBuilder addCountryForObject(String sobjectName, String countryField) {
        this.countryFieldByObject.put(sobjectName, countryField);
        return this;
    }

    public VDT_ProductAdoptionBuilder withRecords(List<Product_vod__c> records) {
        this.records = records;
        productIds.clear();
        for (Product_vod__c product : records) {
            productIds.add(product.Id);
        }
        return this;
    }

    public VDT_ProductAdoptionBuilder withKeyMessages() {
        keyMessagesByProduct.clear();
        String countryField = this.countryFieldByObject.get('Key_Message_vod__c');

        String query = String.format('SELECT Product_vod__c productid, {0} countryname, COUNT(Id) counter'
                     + ' FROM Key_Message_vod__c'
                     + ' WHERE Active_vod__c = TRUE AND Product_vod__c IN :productIds' 
                     + ' GROUP BY Product_vod__c, {0}', new List<String>{
                        countryField
                     });

        AggregateResult[] keyMessagesByProductCounts = (AggregateResult[]) Database.query(query);
        for (AggregateResult keyMessageProduct : keyMessagesByProductCounts)  {
            String key = keyMessageProduct.get('productid').toString() + KEY_DELIMITER + keyMessageProduct.get('countryname').toString();
            keyMessagesByProduct.put(key, Integer.valueOf(keyMessageProduct.get('counter')));
        }                                                  
        return this;
    }

    public VDT_ProductAdoptionBuilder withActiveCLMs() {
        presentationsByProduct.clear();
        String countryField = this.countryFieldByObject.get('Clm_Presentation_vod__c');

        String query = String.format('SELECT Product_vod__c productid, {0} countryname, COUNT(Id) counter'
                        + ' FROM Clm_Presentation_vod__c'
                        + ' WHERE Status_vod__c = {1} AND End_Date_vod__c > TODAY'
                        + ' AND Product_vod__c IN :productIds'
                        + ' GROUP BY Product_vod__c, {0}', new List<String>{
                            countryField,
                            PRESENTATION_STATUS_APPROVED
                        });

        AggregateResult[] CLMByProductCounts = (AggregateResult[]) Database.query(query);
        for (AggregateResult CLMProduct : CLMByProductCounts) {
            String key = CLMProduct.get('productid').toString() + KEY_DELIMITER + CLMProduct.get('countryname').toString();
            presentationsByProduct.put(key, Integer.valueOf(CLMProduct.get('counter')));
        }
        return this;
    }

    public VDT_ProductAdoptionBuilder withApprovedDocuments() {        
        approvedDocumentsByProduct.clear();
        String countryField = this.countryFieldByObject.get('Approved_Document_vod__c');

        String query = String.format('SELECT Product_vod__c productid, {0} countryname, COUNT(Id) counter'
                                + ' FROM Approved_Document_vod__c'
                                + ' WHERE Status_vod__c = {1}'
                                + ' AND Product_vod__c IN :productIds'
                                + ' GROUP BY Product_vod__c, {0}', new List<String>{
                                    countryField,
                                    APPROVED_DOCUMENT_STATUS_APPROVED
                                });

        AggregateResult[] approvedDocumentCounts = (AggregateResult[]) Database.query(query);
        for (AggregateResult approvedDocument : approvedDocumentCounts)  {
            String key = approvedDocument.get('productid').toString() + KEY_DELIMITER + approvedDocument.get('countryname').toString();
            approvedDocumentsByProduct.put(key, Integer.valueOf(approvedDocument.get('counter')));
        }
        return this;
    }

    public VDT_ProductAdoptionBuilder withSentEmails(Date startDate, Date endDate) {        
        sentEmailsByProduct.clear();
        String countryField = this.countryFieldByObject.get('Account');

        String query = String.format('SELECT Product_vod__c productid, {0} countryname, COUNT(Id) counter'
                                + ' FROM Sent_Email_vod__c'
                                + ' WHERE Email_Sent_Date_vod__c >= :startDate AND Email_Sent_Date_vod__c <= :endDate'
                                + ' AND Product_vod__c IN :productIds'
                                + ' GROUP BY Product_vod__c, {0}', new List<String>{
                                    'Account_vod__r.' + countryField
                                });
        
        AggregateResult[] sentEmailCounts = (AggregateResult[]) Database.query(query);
        for (AggregateResult sentEmail : sentEmailCounts)  {
            String key = sentEmail.get('productid').toString() + KEY_DELIMITER + sentEmail.get('countryname').toString();
            sentEmailsByProduct.put(key, Integer.valueOf(sentEmail.get('counter')));
        }                                                  
        return this;
    }    

    public VDT_ProductAdoptionBuilder withProductMetrics() {        
        productMetricsByProduct.clear();
        String countryField = this.countryFieldByObject.get('Account');

        String query = String.format('SELECT Products_vod__c productid, {0} countryname, COUNT(Id) counter'
                                + ' FROM Product_Metrics_vod__c '
                                + ' WHERE Products_vod__c IN :productIds'
                                + ' GROUP BY Products_vod__c, {0}', new List<String>{
                                    'Account_vod__r.' + countryField
                                });
        AggregateResult[] productMetricCounts = (AggregateResult[]) Database.query(query);
        for (AggregateResult productMetric : productMetricCounts) {
            String key = productMetric.get('productid').toString() + KEY_DELIMITER + productMetric.get('countryname').toString();
            productMetricsByProduct.put(key, Integer.valueOf(productMetric.get('counter')));
        }                                                  
        return this;
    }

    public VDT_ProductAdoptionBuilder withCallDetails(Date startDate, Date endDate) {        
        callsByProduct.clear();
        AggregateResult[] callCounts = [SELECT Product_vod__c, COUNT(Id) counter
                                               FROM Call2_Detail_vod__c 
                                               WHERE Call2_vod__r.Call_Date_vod__c >= :startDate AND Call2_vod__r.Call_Date_vod__c <= :endDate
                                               AND Product_vod__c IN :productIds 
                                               GROUP BY Product_vod__c];
        for (AggregateResult callDetail : callCounts)  {
            callsByProduct.put(callDetail.get('Product_vod__c').toString(), Integer.valueOf(callDetail.get('counter')));
        }                                                  
        return this;
    }

    public VDT_ProductAdoptionBuilder calculate() {
        String productCountryField = this.countryFieldByObject.get('Product_vod__c');
        for (Product_vod__c product : this.records) {
            if (this.adoptionData.product_adoption.containsKey(product.Name)) {

            }
        }
        return this;
    }

    public ProductAdoptionSummary build() {
        return this.adoptionData;
    }

    public class ProductAdoptionSummary {

        public Set<String> productTypes = new Set<String>();
        public Map<String, ProductSummary> product_adoption = new Map<String, ProductSummary>();
        
    }

    public class ProductSummary {
        
        public String name;
        public String type;
        public Map<String, CountryUsageSummary> countryUsageSummary = new Map<String, CountryUsageSummary>();

    }

    public class CountryUsageSummary {

        public Integer activeKeyMessages {get; set;}
        public Integer activeCLM {get; set;}
        public Integer approvedDocuments {get; set;}
        public Decimal sentEmail {get; set;}
        public Decimal productMetric {get; set;}
        public Decimal callsVisits {get; set;}
        public Decimal events {get; set;}

    }

}
