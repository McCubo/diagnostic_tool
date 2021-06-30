/**
 * @description Provides Access to Apex Service Methods
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_PermissionSetSelector {

    private Integer limitValue;
    private Integer offsetValue;
    private List<String> additionalFields = new List<String>();
    private List<String> whereClauses = new List<String>();

    /**
     * @return  `String` name of SObject the query will be run against
     */
    private String getObjectName() {
        return 'PermissionSet';
    }

    /**
     * @return  `List<String>` Default fields to be added to the SELECT statement
     */
    private List<String> getFieldList() {
        return new List<String>{
            PermissionSet.Id.getDescribe().getName(),
            PermissionSet.Name.getDescribe().getName()
        };
    }

        /**
     * 
     * @return  `String` all the default and additional fields (if there are any) to be included in the SELECT statement
     */
    private String getFieldListString() {
        List<String> fields = new List<String>();
        fields.addAll(this.getFieldList());
        if (!this.additionalFields.isEmpty()) {
            fields.addAll(this.additionalFields);
        }
        return String.join(fields, ',');
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
     * @param limitValue Limit the number of max number of records to be returned by the query
     * @return  `VDT_PermissionSetSelector` instance
     */
    public VDT_PermissionSetSelector withLimit(Integer limitValue) {
        this.limitValue = limitValue;
        return this;
    }

    /**
     * @param limitValue Offset records
     * @return  `VDT_PermissionSetSelector` instance
     */
    public VDT_PermissionSetSelector withOffset(Integer offsetValue) {
        this.offsetValue = offsetValue;
        return this;
    }

    /**
     * @param whereClause List containing a valid SOQL comparison to be added to the WHERE clause
     * @return  `VDT_PermissionSetSelector` instance of the class
    */
    public VDT_PermissionSetSelector addWhereClauses(List<String> whereClauses) {
        this.whereClauses.addAll(whereClauses);
        return this;
    }

    /**
     * 
     * @param additionalFields 
     * @return  `VDT_PermissionSetSelector`
     */
    public VDT_PermissionSetSelector withAdditionalFields(List<String> additionalFields) {        
        this.additionalFields.addAll(additionalFields);
        return this;
    }
    
    /**
     * @return  `List<PermissionSet>` executes the query with all conditions and limit
     */
    public List<PermissionSet> query() {
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            '{2} ' +
            'WITH SECURITY_ENFORCED ' +
            '{3} ', 
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