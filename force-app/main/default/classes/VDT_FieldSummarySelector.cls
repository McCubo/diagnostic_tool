/**
 * @description Provides access to methods to retrieve records from VDT_Field_Summary__c custom object
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_FieldSummarySelector {

    private List<String> additionalFields = new List<String>();
    private List<String> whereClauses = new List<String>();
    private Integer limitValue;

    /**
     * @param additionalFields List of Field API Names to be added in the SELECT clause
     * @return  `VDT_FieldSummarySelector` instance of the class
     */
    public VDT_FieldSummarySelector withAdditionalFields(List<String> additionalFields) {
        this.additionalFields = additionalFields;
        return this;
    }

    /**
     * @param limitValue max number of records to be returned by the SOQL Query
     * @return  `VDT_FieldSummarySelector` instance of the class
     */
    public VDT_FieldSummarySelector withLimit(Integer limitValue) {
        this.limitValue = limitValue;
        return this;
    }

    /**
     * @param whereClause String containing a valid SOQL comparison to be added to the WHERE clause
     * @return  `VDT_FieldSummarySelector` instance of the class
     */
    public VDT_FieldSummarySelector addWhereClause(String whereClause) {
        this.whereClauses.add(whereClause);
        return this;
    }

    /**
     * @return  `String` SObject API Name that the query will be run against.
     */
    private String getObjectName() {
        return 'VDT_Field_Summary__c';
    }

    /**
     * @return  `Set<String>` Default fields to be added to the SELECT clause.
     */
    private Set<String> getFieldList() {
        return new Set<String> {
            VDT_Field_Summary__c.Id.getDescribe().getName(),
            VDT_Field_Summary__c.Name.getDescribe().getName(),
            VDT_Field_Summary__c.Label__c.getDescribe().getName(),
            VDT_Field_Summary__c.Name__c.getDescribe().getName(),
            VDT_Field_Summary__c.Page_Layouts__c.getDescribe().getName(),
            VDT_Field_Summary__c.Type__c.getDescribe().getName()
        };
    }

    /**
     * @return  `String` Comma separated field API names to be included in the SELECT clause (both default and additional)
     */
    private String getFieldListString() {
        Set<String> fields = this.getFieldList();
        if (!this.additionalFields.isEmpty()) {
            fields.addAll(this.additionalFields);
        }
        return String.join(new List<String>(fields), ',');
    }
    
    /**
     * @return  `String` if a limit has been set, this method returns a LIMIT clause, otherwise it returns EMPTY
     */
    private String getLimitString() {
        String limitString = '';
        if (this.limitValue != null) {
            limitString = 'LIMIT ' + this.limitValue;
        }
        return limitString;
    }

    /**
     * @return  `String` with all where conditions concatenated using and AND logical operator
     */
    private String getWhereClause() {
        String whereClause = '';
        if (!this.whereClauses.isEmpty()) {
            whereClause = 'WHERE ' + String.join(this.whereClauses, ' AND ');
        }
        return whereClause;
    }

    /**
     * @return  `List<VDT_Field_Summary__c>` executes the query with all conditions and limit
     */
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