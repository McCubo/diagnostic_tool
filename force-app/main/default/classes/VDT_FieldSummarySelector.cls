public inherited sharing class VDT_FieldSummarySelector {

    private List<String> additionalFields = new List<String>();
    private List<String> whereClauses = new List<String>();
    private Integer limitValue;

    public VDT_FieldSummarySelector withAdditionalFields(List<String> additionalFields) {
        this.additionalFields = additionalFields;
        return this;
    }

    public VDT_FieldSummarySelector withLimit(Integer limitValue) {
        this.limitValue = limitValue;
        return this;
    }

    public VDT_FieldSummarySelector addWhereClause(String whereClause) {
        this.whereClauses.add(whereClause);
        return this;
    }

    private String getObjectName() {
        return 'VDT_Field_Summary__c';
    }

    private Set<String> getFieldList() {
        return new Set<String> {
            VDT_Field_Summary__c.Id.getDescribe().getName(),
            VDT_Field_Summary__c.Name.getDescribe().getName(),
            VDT_Field_Summary__c.Label__c.getDescribe().getName(),
            VDT_Field_Summary__c.Name__c.getDescribe().getName(),
            VDT_Field_Summary__c.Page_Layouts__c.getDescribe().getName(),
            VDT_Field_Summary__c.Type__c.getDescribe().getName(),
            VDT_Field_Summary__c.Country_Usage_Summary__c.getDescribe().getName()
        };
    }

    private String getFieldListString() {
        Set<String> fields = this.getFieldList();
        if (!this.additionalFields.isEmpty()) {
            fields.addAll(this.additionalFields);
        }
        return String.join(new List<String>(fields), ',');
    }
    
    private String getLimitString() {
        String limitString = '';
        if (this.limitValue != null) {
            limitString = 'LIMIT ' + this.limitValue;
        }
        return limitString;
    }

    private String getWhereClause() {
        String whereClause = '';
        if (!this.whereClauses.isEmpty()) {
            whereClause = 'WHERE ' + String.join(this.whereClauses, ' AND ');
        }
        return whereClause;
    }

    public List<VDT_Field_Summary__c> query() {
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            '{2} ' +
            'WITH SECURITY_ENFORCED ' +
            '{3}', 
            new List<String>{
                getFieldListString(),
                getObjectName(),
                getWhereClause(),
                getLimitString()
            }
        );
        return Database.query(query);
    }

}
