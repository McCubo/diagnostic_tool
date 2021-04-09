public with sharing class VDT_ProductSelector {

    private List<String> additionalFields = new List<String>();
    private List<String> whereClauses = new List<String>();
    private Integer limitValue;

    public VDT_ProductSelector withAdditionalFields(List<String> additionalFields) {
        this.additionalFields = additionalFields;
        return this;
    }

    public VDT_ProductSelector withLimit(Integer limitValue) {
        this.limitValue = limitValue;
        return this;
    }

    public VDT_ProductSelector addWhereClause(String whereClause) {
        this.whereClauses.add(whereClause);
        return this;
    }

    public String getObjectName() {
        return 'Product_vod__c';
    }

    public Set<String> getFieldList() {
        return new Set<String> {
            Product_vod__c.Id.getDescribe().getName(),
            Product_vod__c.Name.getDescribe().getName(),
            Product_vod__c.Product_Type_vod__c.getDescribe().getName()
        };
    }

    public String getFieldListString() {
        Set<String> fields = this.getFieldList();
        if (!this.additionalFields.isEmpty()) {
            fields.addAll(this.additionalFields);
        }
        return String.join(new List<String>(fields), ',');
    }
    
    public String getLimitString() {
        String limitString = '';
        if (this.limitValue != null) {
            limitString = 'LIMIT ' + this.limitValue;
        }
        return limitString;
    }

    public String getWhereClause() {
        String whereClause = '';
        if (!this.whereClauses.isEmpty()) {
            whereClause = 'WHERE ' + String.join(this.whereClauses, ' AND ');
        }
        return whereClause;
    }

    public List<Product_vod__c> query() {
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            '{2} '+
            'WITH SECURITY_ENFORCED ' +
            '{3}', 
            new List<String>{
                getFieldListString(),
                getObjectName(),
                getWhereClause(),
                getLimitString()
            }
        );
        System.debug('query: ' + query);
        return Database.query(query);
    }

}