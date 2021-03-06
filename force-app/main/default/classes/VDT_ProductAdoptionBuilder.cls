public with sharing class VDT_ProductAdoptionBuilder {

    private ProductAdoptionSummary adoptionData = new ProductAdoptionSummary();
    private List<Product_vod__c> records = new List<Product_vod__c>();
    private Set<String> productIds = new Set<String>();
    private Set<String> countries = new Set<String>();
    private Map<String, Map<String, Integer>> keyMessagesByProduct = new Map<String, Map<String, Integer>>();
    private Map<String, Map<String, Integer>> presentationsByProduct = new Map<String, Map<String, Integer>>();
    private Map<String, Map<String, Integer>> approvedDocumentsByProduct = new Map<String, Map<String, Integer>>();
    private Map<String, Map<String, Integer>> sentEmailsByProduct = new Map<String, Map<String, Integer>>();
    private Map<String, Map<String, Integer>> productMetricsByProduct = new Map<String, Map<String, Integer>>();
    private Map<String, Map<String, Integer>> eventsByProduct = new Map<String, Map<String, Integer>>();
    private  Map<String, Map<String, Integer>> callsByProduct = new  Map<String, Map<String, Integer>>();
    private Map<String, String> countryFieldByObject = new Map<String, String>();
    private Map<String, String> productFieldByObject = new Map<String, String>();
    private final String PRESENTATION_STATUS_APPROVED = 'Approved_vod';
    private final String APPROVED_DOCUMENT_STATUS_APPROVED = 'Approved_vod';

    public VDT_ProductAdoptionBuilder addCountriesForObjects(Map<String, String> countryFieldByObject) {
        for (String objectName : countryFieldByObject.keySet()) {
            this.countryFieldByObject.put(objectName, countryFieldByObject.get(objectName));
        }
        return this;
    }

    public VDT_ProductAdoptionBuilder addProductFieldsByObject(Map<String, String> productFieldByObject) {
        for (String objectName : productFieldByObject.keySet()) {
            this.productFieldByObject.put(objectName, productFieldByObject.get(objectName));
        }
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
            addValueToProductAndCountry(keyMessagesByProduct, keyMessageProduct);
        }
        return this;
    }

    public VDT_ProductAdoptionBuilder withActiveCLMs() {
        presentationsByProduct.clear();
        String countryField = this.countryFieldByObject.get('Clm_Presentation_vod__c');

        String query = String.format('SELECT Product_vod__c productid, {0} countryname, COUNT(Id) counter'
                        + ' FROM Clm_Presentation_vod__c'
                        + ' WHERE Status_vod__c = :PRESENTATION_STATUS_APPROVED AND End_Date_vod__c > TODAY'
                        + ' AND Product_vod__c IN :productIds'
                        + ' GROUP BY Product_vod__c, {0}', new List<String>{
                            countryField                            
                        });

        AggregateResult[] CLMByProductCounts = (AggregateResult[]) Database.query(query);
        for (AggregateResult CLMProduct : CLMByProductCounts) {
            addValueToProductAndCountry(presentationsByProduct, CLMProduct);
        }
        return this;
    }

    public VDT_ProductAdoptionBuilder withApprovedDocuments() {        
        approvedDocumentsByProduct.clear();
        String countryField = this.countryFieldByObject.get('Approved_Document_vod__c');

        String query = String.format('SELECT Product_vod__c productid, {0} countryname, COUNT(Id) counter'
                                + ' FROM Approved_Document_vod__c'
                                + ' WHERE Status_vod__c = :APPROVED_DOCUMENT_STATUS_APPROVED'
                                + ' AND Product_vod__c IN :productIds'
                                + ' GROUP BY Product_vod__c, {0}', new List<String>{
                                    countryField                                    
                                });

        AggregateResult[] approvedDocumentCounts = (AggregateResult[]) Database.query(query);
        for (AggregateResult approvedDocument : approvedDocumentCounts)  {
            addValueToProductAndCountry(approvedDocumentsByProduct, approvedDocument);
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
            addValueToProductAndCountry(sentEmailsByProduct, sentEmail);
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
            addValueToProductAndCountry(productMetricsByProduct, productMetric);
        }
        return this;
    }

    public VDT_ProductAdoptionBuilder withEvents(Date startDate, Date endDate) {
        eventsByProduct.clear();
        DateTime startDatetime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day());
        DateTime endDatetime = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day());
        String countryField = this.countryFieldByObject.get('EM_Event_vod__c');
        String productField = this.productFieldByObject.get('EM_Event_vod__c');

        String query = String.format('SELECT {0} productid, {1} countryname, COUNT(Id) counter'
                                + ' FROM EM_Event_vod__c '
                                + ' WHERE {0} IN :productIds AND Start_Time_vod__c >= :startDatetime AND End_Time_vod__c  <= :endDatetime'
                                + ' GROUP BY {0}, {1}', new List<String>{
                                    productField,
                                    countryField
                                });
        AggregateResult[] eventsCount = (AggregateResult[]) Database.query(query);
        for (AggregateResult eventData : eventsCount) {
            addValueToProductAndCountry(eventsByProduct, eventData);
        }
        return this;
    }

    public VDT_ProductAdoptionBuilder withCallDetails(Date startDate, Date endDate) {
        callsByProduct.clear();
        String countryField = this.countryFieldByObject.get('Account');
        String query = String.format('SELECT Product_vod__c productid, {0} countryname, COUNT(Id) counter'
                                    + ' FROM Call2_Detail_vod__c'
                                    + ' WHERE Call2_vod__r.Call_Date_vod__c >= :startDate AND Call2_vod__r.Call_Date_vod__c <= :endDate'
                                    + ' AND Product_vod__c IN :productIds'
                                    + ' GROUP BY Product_vod__c, {0}', new List<String>{
                                        'Call2_vod__r.Account_vod__r.' + countryField
                                    });
        AggregateResult[] callCounts = (AggregateResult[]) Database.query(query);
        for (AggregateResult callDetail : callCounts)  {
            addValueToProductAndCountry(callsByProduct, callDetail);
        }
        return this;
    }

    private void addValueToProductAndCountry(Map<String, Map<String, Integer>> genericMap, AggregateResult aggregateResult) {
        String productId = aggregateResult.get('productid').toString();
        String country = aggregateResult.get('countryname').toString();
        Integer counter = Integer.valueOf(aggregateResult.get('counter'));
        this.countries.add(country);
        if (genericMap.containsKey(productId)) {
            Map<String, Integer> countryValue = genericMap.get(productId);
            countryValue.put(country, counter);
        } else {
            Map<String, Integer> countryValue = new Map<String, Integer>{ country => counter };
            genericMap.put(productId, countryValue);
        }
    }

    public VDT_ProductAdoptionBuilder calculate() {
        String productCountryField = this.countryFieldByObject.get('Product_vod__c');
        for (Product_vod__c product : this.records) {
            adoptionData.productTypes.add(product.Product_Type_vod__c);            
            String countryValue = getPropertyValue(product, productCountryField);
            ProductSummary prodSummary = new ProductSummary(product.Id, product.Name, countryValue, product.Product_Type_vod__c);            
            for (String country : this.countries) {
                CountryUsageSummary countryUsage = new CountryUsageSummary();
                Map<String, Integer> keyMessageCount = this.keyMessagesByProduct.get(product.Id);
                if (keyMessageCount != null && keyMessageCount.containsKey(country)) {
                    countryUsage.activeKeyMessages = keyMessageCount.get(country);
                }
                Map<String, Integer> activePresentationCount = this.presentationsByProduct.get(product.Id);
                if (activePresentationCount != null && activePresentationCount.containsKey(country)) {
                    countryUsage.activeCLM = activePresentationCount.get(country);
                }
                Map<String, Integer> approvedDocumentsCount = this.approvedDocumentsByProduct.get(product.Id);
                if (approvedDocumentsCount != null && approvedDocumentsCount.containsKey(country)) {
                    countryUsage.approvedDocuments = approvedDocumentsCount.get(country);
                }
                Map<String, Integer> sentEmailsCount = this.sentEmailsByProduct.get(product.Id);
                if (sentEmailsCount != null && sentEmailsCount.containsKey(country)) {
                    countryUsage.sentEmail = sentEmailsCount.get(country);
                }
                Map<String, Integer> productMetricsCount = this.productMetricsByProduct.get(product.Id);
                if (productMetricsCount != null && productMetricsCount.containsKey(country)) {
                    countryUsage.productMetric = productMetricsCount.get(country);
                }
                Map<String, Integer> productEventsCount = this.eventsByProduct.get(product.Id);
                if (productEventsCount != null && productEventsCount.containsKey(country)) {
                    countryUsage.events = productEventsCount.get(country);
                }
                Map<String, Integer> callDetailsCount = this.callsByProduct.get(product.Id);
                if (callDetailsCount != null && callDetailsCount.containsKey(country)) {
                    countryUsage.callsVisits = callDetailsCount.get(country);
                }
                if (countryUsage.isSet()) {
                    prodSummary.countryUsageSummary.put(country, countryUsage);
                }
            }
            this.adoptionData.product_adoption.put(product.Name, prodSummary);
        }
        return this;
    }

    public ProductAdoptionSummary build() {
        return this.adoptionData;
    }

    private static String getPropertyValue(Product_vod__c product, String fieldName) {
        String value = '';
        if (fieldName.contains('.')) {
            String relationship = fieldName.split('\\.').get(0);
            String relatedField = fieldName.split('\\.').get(1);
            if (product.getSObject(relationship) != null) {
                value = product.getSObject(relationship).get(relatedField).toString();
            }
        } else {
            value = String.valueOf(product.get(fieldName));
        }
        return value;
    }

    public class ProductAdoptionSummary {

        public Set<String> productTypes = new Set<String>();
        public Map<String, ProductSummary> product_adoption = new Map<String, ProductSummary>();
        
    }

    public class ProductSummary {

        public ProductSummary(String id, String name, String country, String type) {
            this.id = id;
            this.name = name;
            this.country = country;
            this.type = type;
        }

        public String id;
        public String name;
        public String type;
        public String country;
        public Map<String, CountryUsageSummary> countryUsageSummary = new Map<String, CountryUsageSummary>();

    }

    public class CountryUsageSummary {

        public Integer activeKeyMessages = 0;
        public Integer activeCLM = 0;
        public Integer approvedDocuments = 0;
        public Decimal sentEmail = 0;
        public Decimal productMetric = 0;
        public Decimal events = 0;
        public Decimal callsVisits = 0;

        public Boolean isSet() {
            return this.activeKeyMessages > 0 
                    || this.activeCLM > 0 
                    || this.approvedDocuments > 0 
                    || this.sentEmail > 0
                    || this.productMetric > 0
                    || this.events > 0
                    || this.callsVisits > 0;
        }
    }

}