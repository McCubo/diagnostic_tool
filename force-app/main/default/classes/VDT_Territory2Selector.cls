/**
 * @description Provides methods to retrieve records from `Territory2` SObject
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_Territory2Selector {

    
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
        return 'Territory2';
    }

    /**
     * @return  `List<String>` Default fields to be added to the SELECT statement
     */
    private List<String> getFieldList() {
        return new List<String>{
            Territory2.Id.getDescribe().getName(),
            Territory2.Name.getDescribe().getName()
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
        String groupByClause = '';
        if (!this.groupByFields.isEmpty()) {
            return 'GROUP BY ' + String.join(this.groupByFields, ',');
        }
        return groupByClause;
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
     * @return  `VDT_Territory2Selector` instance
     */
    public VDT_Territory2Selector withLimit(Integer limitValue) {
        this.limitValue = limitValue;
        return this;
    }

    /**
     * @param limitValue Offset records
     * @return  `VDT_Territory2Selector` instance
     */
    public VDT_Territory2Selector withOffset(Integer offsetValue) {
        this.offsetValue = offsetValue;
        return this;
    }

    /**
     * @param whereClause List containing a valid SOQL comparison to be added to the WHERE clause
     * @return  `VDT_Territory2Selector` instance of the class
    */
    public VDT_Territory2Selector addWhereClauses(List<String> whereClauses) {
        this.whereClauses.addAll(whereClauses);
        return this;
    }

    /**
     * @param whereClause List containing a valid SOQL comparison to be added to the WHERE clause
     * @return  `VDT_Territory2Selector` instance of the class
    */
    public VDT_Territory2Selector addHavingClauses(List<String> havingClauses) {
        this.havingClauses.addAll(havingClauses);
        return this;
    }

    /**
     * 
     * @param additionalFields 
     * @return  `VDT_Territory2Selector`
     */
    public VDT_Territory2Selector withAdditionalFields(List<String> additionalFields) {        
        this.additionalFields.addAll(additionalFields);
        return this;
    }

    /**
     * 
     * @param groupByFields 
     * @return  `VDT_Territory2Selector`
     */
    public VDT_Territory2Selector withGroupByFields(List<String> groupByFields) {        
        this.groupByFields.addAll(groupByFields);
        return this;
    }
    
    /**
     * @return  `List<Territory2>` executes the query with all conditions and limit
     */
    public List<Territory2> query() {
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
        
        return Database.query(query);
    }
    
    public List<String> getAllTerritoryIdsInHierarchy(List<String> territoryDeveloperNames) {
        List<Territory2> allTerritories = this.withAdditionalFields(new List<String>{'DeveloperName', 'ParentTerritory2Id'}).query();
        List<String> territoriesInCalculation = new List<String>();
        for (Territory2 territory : allTerritories) {
            if (territoryDeveloperNames.contains(territory.DeveloperName)) {
                territoriesInCalculation.add(territory.Id);
                territoriesInCalculation.addAll(this.getChildIdsForParents(territory.Id, allTerritories));
            }
        }
        return territoriesInCalculation;
    }

    private List<String> getChildIdsForParents(String parentId, List<Territory2> allTerritories) {
        List<String> childIds = new List<String>();
        for (Territory2 territory : allTerritories) {
            if (territory.ParentTerritory2Id == parentId) {
                childIds.add(territory.Id);
                childIds.addAll(this.getChildIdsForParents(territory.Id, allTerritories));
            }
        }
        return childIds;
    }
}
