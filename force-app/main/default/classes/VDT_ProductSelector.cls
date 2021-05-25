/**
 * @description provides methods to retrieve records from the Product sobject.
 * @author BASE Life Science
 * @since 2021.03.01
 */
public with sharing class VDT_ProductSelector {

    private List<String> additionalFields = new List<String>();
    private List<String> whereClauses = new List<String>();
    private Integer limitValue;

    /**
     * @param additionalFields list of field API names to be added to the SELECT clause
     * @return  `VDT_ProductSelector`
     */
    public VDT_ProductSelector withAdditionalFields(List<String> additionalFields) {
        this.additionalFields = additionalFields;
        return this;
    }

    /**
     * @param limitValue max number of records to be returned by the SOQL query
     * @return  `VDT_ProductSelector`
     */
    public VDT_ProductSelector withLimit(Integer limitValue) {
        this.limitValue = limitValue;
        return this;
    }

    /**
     * @param whereClause where conditions to be added to the WHERE clause
     * @return  `VDT_ProductSelector`
     */
    public VDT_ProductSelector addWhereClause(String whereClause) {
        this.whereClauses.add(whereClause);
        return this;
    }

    /**
     * @return  `String` SObject API Name that will be used to run the SOQL query
     */
    public String getObjectName() {
        return 'Product_vod__c';
    }

    /**
     * @return  `Set<String>` default list of fields to be added in the SELECT clause
     */
    public Set<String> getFieldList() {
        return new Set<String> {
            Product_vod__c.Id.getDescribe().getName(),
            Product_vod__c.Name.getDescribe().getName(),
            Product_vod__c.Product_Type_vod__c.getDescribe().getName()
        };
    }

    /**
     * @return  `String` all default and additional fields (if any) to be used in the SELECT clause
     */
    public String getFieldListString() {
        Set<String> fields = this.getFieldList();
        if (!this.additionalFields.isEmpty()) {
            fields.addAll(this.additionalFields);
        }
        return String.join(new List<String>(fields), ',');
    }
    
    /**
     * @return  `String` LIMIT clause if a limit has been set, empty otherwise
     */
    public String getLimitString() {
        String limitString = '';
        if (this.limitValue != null) {
            limitString = 'LIMIT ' + this.limitValue;
        }
        return limitString;
    }

    /**
     * @return  `String` WHERE clause if WHERE CONDITIONS were added using the builder method
     */
    public String getWhereClause() {
        String whereClause = '';
        if (!this.whereClauses.isEmpty()) {
            whereClause = 'WHERE ' + String.join(this.whereClauses, ' AND ');
        }
        return whereClause;
    }

    /**
     * @description executes the SOQL query with limit and conditions defined.
     * @return  `List<Product_vod__c>`
     */
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