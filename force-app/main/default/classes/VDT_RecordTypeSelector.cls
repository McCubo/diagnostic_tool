public inherited sharing class VDT_RecordTypeSelector {

    private Integer limitValue;

    public String getObjectName() {
        return 'RecordType';
    }

    public List<String> getFieldList() {
        return new List<String>{
            RecordType.Id.getDescribe().getName(),
            RecordType.Name.getDescribe().getName(),
            RecordType.Description.getDescribe().getName(),
            RecordType.DeveloperName.getDescribe().getName()
        };
    }

    public String getFieldListString() {
        return String.join(this.getFieldList(), ',');
    }
    
    public VDT_RecordTypeSelector withLimit(Integer limitValue) {
        this.limitValue = limitValue;
        return this;
    }

    public String getLimitString() {
        String limitString = '';
        if (this.limitValue != null) {
            limitString = 'LIMIT ' + this.limitValue;
        }
        return limitString;
    }

    public List<RecordType> getAllRecordTypesForSObject(String sobjectName) {
        String whereString = 'SobjectType = :sobjectName AND IsActive = TRUE';
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
}
