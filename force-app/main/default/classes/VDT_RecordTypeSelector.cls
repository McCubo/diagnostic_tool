/**
 * @description Provides methods to retrieve records from `RecordType` SObject
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_RecordTypeSelector {

    private Integer limitValue;

    /**
     * @return  `String` name of SObject the query will be run against
     */
    public String getObjectName() {
        return 'RecordType';
    }

    /**
     * @return  `List<String>` Default fields to be added to the SELECT statement
     */
    public List<String> getFieldList() {
        return new List<String>{
            RecordType.Id.getDescribe().getName(),
            RecordType.Name.getDescribe().getName(),
            RecordType.Description.getDescribe().getName(),
            RecordType.DeveloperName.getDescribe().getName()
        };
    }

    /**
     * @return  `String` Comma Separated names of all Fields
     */
    public String getFieldListString() {
        return String.join(this.getFieldList(), ',');
    }
    
    /**
     * @param limitValue Limit the number of max number of records to be returned by the query
     * @return  `VDT_RecordTypeSelector` instance
     */
    public VDT_RecordTypeSelector withLimit(Integer limitValue) {
        this.limitValue = limitValue;
        return this;
    }

    /**
     * @return  `String` if a limit has been set, return the LIMIT clause
     */
    public String getLimitString() {
        String limitString = '';
        if (this.limitValue != null) {
            limitString = 'LIMIT ' + this.limitValue;
        }
        return limitString;
    }

    /**
     * 
     * @param sobjectName SObject API Name
     * @param recordTypeDevName Record Type API Name
     * @return  `List<RecordType>` Record Type that match the filters
     */
    public List<RecordType> getRecordTypeByObjectAndName(String sobjectName, String recordTypeDevName) {
        String whereString = 'SObjectType = :sobjectName AND DeveloperName = :recordTypeDevName';
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            'WHERE {2} '+
            'WITH SECURITY_ENFORCED ' +
            '{3}', 
            new List<String>{
                getFieldListString(),
                getObjectName(),
                whereString,
                getLimitString()
            }
        );
        return Database.query(query);
    }

    /**
     * @param sobjectName SOBject API Name
     * @return  `List<RecordType>` all Record Types available for the given SObject
     */
    public List<RecordType> getAllRecordTypesByObject(String sobjectName) {
        String whereString = 'SObjectType = :sobjectName';
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            'WHERE {2} '+
            'WITH SECURITY_ENFORCED ' +
            '{3}', 
            new List<String>{
                getFieldListString(),
                getObjectName(),
                whereString,
                getLimitString()
            }
        );
        return Database.query(query);
    }
}