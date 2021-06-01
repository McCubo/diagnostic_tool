/**
 * @description Provides methods to retrieve records from `Transaction Result` SObject
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_TransactionResultSelector {

    private Integer limitValue;
    private Integer offsetValue;
    private List<String> groupByFields = new List<String>();
    private List<String> additionalFields = new List<String>();
    private List<String> whereClauses = new List<String>();
    private List<String> havingClauses = new List<String>();

    /**
     * @return  `String` name of SObject the query will be run against
     */
    private String getObjectName() {
        return 'VDT_Transaction_Result__c';
    }

    /**
     * @return  `List<String>` Default fields to be added to the SELECT statement
     */
    private List<String> getFieldList() {
        return new List<String>{
            VDT_Transaction_Result__c.Id.getDescribe().getName(),
            VDT_Transaction_Result__c.RecordTypeId.getDescribe().getName()
        };
    }

    /**
     * 
     * @return  `String` all the default and additional fields (if there are any) to be included in the SELECT statement
     */
    private String getFieldListString() {
        List<String> fields = new List<String>();
        if (this.groupByFields.isEmpty()) {
            fields.addAll(this.getFieldList());
        }
        if (this.groupByFields.isEmpty() && !this.additionalFields.isEmpty()) {
            fields.addAll(this.additionalFields);
        }
        if (!this.groupByFields.isEmpty()) {
            fields.addAll(this.groupByFields);
        }
        return String.join(fields, ',');
    }

    private String getGroupByString() {
        return 'GROUP BY ' + String.join(this.groupByFields, ',');
    }

    /**
     * @return  `String` if a limit has been set, return the LIMIT clause
     */
    private String getLimitString() {
        String limitString = '';
        if (this.limitValue != null) {
            limitString = 'LIMIT ' + this.limitValue;
        }
        return limitString;
    }

    /**
     * @return  `String` if a limit has been set, return the LIMIT clause
     */
    private String getOffsetString() {
        String offsetString = '';
        if (this.offsetValue != null) {
            offsetString = 'OFFSET ' + this.offsetValue;
        }
        return offsetString;
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
     * @return  `String` with all HAVING conditions concatenated using and AND logical operator
    */
    private String getHavingClause() {
        String havingClause = '';
        if (!this.havingClauses.isEmpty()) {
            havingClause = 'HAVING ' + String.join(this.havingClauses, ' AND ');
        }
        return havingClause;
    }

    /**
     * @param limitValue Limit the number of max number of records to be returned by the query
     * @return  `VDT_TransactionResultSelector` instance
     */
    public VDT_TransactionResultSelector withLimit(Integer limitValue) {
        this.limitValue = limitValue;
        return this;
    }

    /**
     * @param limitValue Offset records
     * @return  `VDT_TransactionResultSelector` instance
     */
    public VDT_TransactionResultSelector withOffset(Integer offsetValue) {
        this.offsetValue = offsetValue;
        return this;
    }

    /**
     * @param whereClause List containing a valid SOQL comparison to be added to the WHERE clause
     * @return  `VDT_TransactionResultSelector` instance of the class
    */
    public VDT_TransactionResultSelector addWhereClauses(List<String> whereClauses) {
        this.whereClauses.addAll(whereClauses);
        return this;
    }

    /**
     * @param whereClause List containing a valid SOQL comparison to be added to the WHERE clause
     * @return  `VDT_TransactionResultSelector` instance of the class
    */
    public VDT_TransactionResultSelector addHavingClauses(List<String> havingClauses) {
        this.havingClauses.addAll(havingClauses);
        return this;
    }

    /**
     * 
     * @param additionalFields 
     * @return  `VDT_TransactionResultSelector`
     */
    public VDT_TransactionResultSelector withAdditionalFields(List<String> additionalFields) {        
        this.additionalFields.addAll(additionalFields);
        return this;
    }

    /**
     * 
     * @param groupByFields 
     * @return  `VDT_TransactionResultSelector`
     */
    public VDT_TransactionResultSelector withGroupByFields(List<String> groupByFields) {        
        this.groupByFields.addAll(groupByFields);
        return this;
    }

    /**
     * @return  `AggregateResult[]` executes the query with all conditions and limit
     */
    public AggregateResult[] queryAggregate() {
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            '{2} ' +
            'WITH SECURITY_ENFORCED ' +
            '{3} ' +
            '{4} ' + 
            '{5} ' +
            '{6} ', 
            new List<String>{
                getFieldListString(),
                getObjectName(),
                getWhereClause(),
                getGroupByString(),
                getHavingClause(),
                getLimitString(),
                getOffsetString()
            }
        );
        return (AggregateResult[]) Database.query(query);
    }

    /**
     * @return  `AggregateResult[]` executes the query with all conditions and limit
     */
    public AggregateResult[] queryCount() {
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            '{2} ' +
            // 'WITH SECURITY_ENFORCED ' +
            '{3} ' +
            '{4} ', 
            new List<String>{
                getFieldListString(),
                getObjectName(),
                getWhereClause(),
                getGroupByString(),
                getHavingClause()
            }
        );
        return (AggregateResult[]) Database.query(query);
    }    
    /**
     * @return  `AggregateResult[]` executes the query with all conditions and limit
     */
    public List<VDT_Transaction_Result__c> query() {
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            '{2} ' +
            'WITH SECURITY_ENFORCED ', 
            new List<String>{
                getFieldListString(),
                getObjectName(),
                getWhereClause()
            }
        );
        return Database.query(query);
    }

}
