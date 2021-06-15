/**
 * @author      BASE Life Science
 * @since       2021.03.01
 * @description This Apex class provides methods to retrieve records from the VDT_Data_Calculation__c SObject.
 */
public inherited sharing class VDT_DataCalculationSelector {
    
    private Integer limitValue;
    private List<String> additionalFields = new List<String>();
    private List<String> conditionals = new List<String>();
    public static final String MASTER_ANALYSIS_RECORD_TYPE_DEV = 'VDT_Master_Data_Analysis';
    public static final String PRODUCT_ADOPTION_RECORD_TYPE_DEV = 'VDT_Product_Adoption';
    public static final String OBJECT_ANALYSIS_RECORD_TYPE_DEV = 'VDT_Object_Field_Analysis';
    public static final String FIELD_OCCURRENCE_RECORD_TYPE_DEV = 'VDT_Object_Field_Value_Occurrence';
    public static final String TERRITORY_ANALYSIS_RECORD_TYPE_DEV = 'VDT_Territory_Analysis';
    public static final String FIELD_LEVEL_SECURITY_RECORD_TYPE_DEV = 'VDT_Field_Level_Security_Analysis';

    /**
     * @return  `String` SObject API Name that queries will be run on.
     */
    public String getObjectName() {
        return 'VDT_Data_Calculation__c';
    }

    /**
     * @return  `List<String>` default field API names to be included on the SELECT statement
     */
    public List<String> getFieldList() {
        return new List<String>{
            VDT_Data_Calculation__c.Id.getDescribe().getName(),
            VDT_Data_Calculation__c.VDT_Object_Name__c.getDescribe().getName(),
            VDT_Data_Calculation__c.Status__c.getDescribe().getName(),
            VDT_Data_Calculation__c.VDT_Calculation_Date__c.getDescribe().getName()
        };
    }

    /**
     * @return  `String` all default and additional fields (if there are any) to be included in the SELECT statement
     */
    public String getFieldListString() {
        List<String> fields = this.getFieldList();
        if (!this.additionalFields.isEmpty()) {
            fields.addAll(this.additionalFields);
        }
        return String.join(fields, ',');
    }

    /**
     * @param limitValue Integer value to specify the max number of records the query can return.
     * @return  `VDT_DataCalculationSelector` the same instance of the class
     */
    public VDT_DataCalculationSelector withLimit(Integer limitValue) {
        this.limitValue = limitValue;
        return this;
    }

    /**
     * 
     * @param additionalFields List of additional field API names to be added to the SELECT statement
     * @return  `VDT_DataCalculationSelector` the same instance of the class
     */
    public VDT_DataCalculationSelector withAdditionalFields(List<String> additionalFields) {
        this.additionalFields = additionalFields;
        return this;
    }

    /**
     * @param conditionals List of Filter Clauses to be added to the SOQL query
     * @return  `VDT_DataCalculationSelector` the same instance of the class
     */
    public VDT_DataCalculationSelector withConditionals(List<String> conditionals) {
        this.conditionals = conditionals;
        return this;
    }

    /**
     * @return  `String` if filter clauses are added using the `withConditionals` method, this method returns a formatted String to be used on the SOQL query
     */
    public String getWhereClause() {
        String whereClause = '';
        if (!this.conditionals.isEmpty()) {
            whereClause = 'WHERE ' + String.join(this.conditionals, ' AND ');
        }
        return whereClause;
    }

    /**
     * @return  `String` with a LIMIT clause if a limit has been set.
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
     * @param calculationParameters Parameters used to filter records
     * @param recordTypeName Record Type Developer Name
     * @return  `List<VDT_Data_Calculation__c>` that match with ALL the filter criterias from the search parameter
     */
    public List<VDT_Data_Calculation__c> getByCalculationParameters(VDT_DataCalculationService.CalculationParameters calculationParameters, String recordTypeName) {
        String fieldAnalysisRT = VDT_RecordTypeService.getRecordTypeByObjectAndName('VDT_Data_Calculation__c', recordTypeName)[0].Id;
        String whereString = 'RecordTypeId = :fieldAnalysisRT AND VDT_Object_Name__c = \'' + String.escapeSingleQuotes(calculationParameters.objectName) +'\'';
        if (calculationParameters.startYear != null) {
            whereString += ' AND Start_Year__c = ' + calculationParameters.startYear;
        } else {
            whereString += ' AND Start_Year__c = NULL';
        }
        if (calculationParameters.startMonth != null) {
            whereString += ' AND Start_Month__c = ' + calculationParameters.startMonth;
        } else {
            whereString += ' AND Start_Month__c = NULL';
        }
        if (calculationParameters.endYear != null) {
            whereString += ' AND End_Year__c = ' + calculationParameters.endYear;
        } else {
            whereString += ' AND End_Year__c = NULL';
        }
        if (calculationParameters.endMonth != null) {
            whereString += ' AND End_Month__c = ' + calculationParameters.endMonth;
        } else {
            whereString += ' AND End_Month__c = NULL';
        }
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            'WHERE {2} '+
            'WITH   SECURITY_ENFORCED ORDER BY VDT_Job_End_Date__c DESC', 
            new List<String>{
                getFieldListString(),
                getObjectName(),
                whereString
            }
        );
        return Database.query(query);
    }

    /**
     * @param recordId Data Calculation Record Id
     * @return  `List<VDT_Data_Calculation__c>` Data Calculation record that matches the given record Id
     */
    public List<VDT_Data_Calculation__c> getById(String recordId) {
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            'WHERE Id = :recordId ' +
            'WITH SECURITY_ENFORCED ' +
            '{2}', 
            new List<String>{
                getFieldListString(),
                getObjectName(),
                getLimitString()
            }
        );

        return Database.query(query);
    }

    /**
     * @param countries Comma Separated Country Values to filter the records
     * @return  `List<VDT_Data_Calculation__c>` where their Country field matches the list of provided countries
     */
    public List<VDT_Data_Calculation__c> getByCountries(String countries) {
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            'WHERE VDT_Country__c = :countries AND RecordType.DeveloperName = :MASTER_ANALYSIS_RECORD_TYPE_DEV ' +
            'WITH SECURITY_ENFORCED ' +
            '{2}', 
            new List<String>{
                getFieldListString(),
                getObjectName(),
                getLimitString()
            }
        );

        return Database.query(query);
    }

    /**
     * @param calculationParameters Parameters used to filter records
     * @return  `List<VDT_Data_Calculation__c>` Territory Analysis records that passed the filters.
     */
    public List<VDT_Data_Calculation__c> getByTerritoryCalculationParameters(VDT_DataCalculationService.TerritoryAnalysisParameters calculationParameters) {
        List<String> whereClauses = new List<String>();
        if (!calculationParameters.countries.isEmpty()) {
            whereClauses.add('VDT_Country__c = \'' + String.join(calculationParameters.countries, ',') + '\'');
        }
        if (String.isNotBlank(calculationParameters.territory)) {
            whereClauses.add('Territory__c = \'' + calculationParameters.territory + '\'');
        }
        whereClauses.add('RecordType.DeveloperName = :TERRITORY_ANALYSIS_RECORD_TYPE_DEV');
        String whereString = String.join(whereClauses, ' AND ');
        
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            'WHERE {2} '+
            'WITH SECURITY_ENFORCED ORDER BY VDT_Job_End_Date__c DESC ' +
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
     * 
     * @return  `List<VDT_Data_Calculation__c>` list of Data Calculation records that match the criterias if any is found
     */
    public List<VDT_Data_Calculation__c> query() {
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            '{2} '+
            'WITH SECURITY_ENFORCED ORDER BY VDT_Job_End_Date__c DESC ' +
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

    /**
     * @description This method is called when the user hits the `Diagnose` button on the `Master Data Analysis` screen
     * @param calculationParameters object with all properties to be used to filter records
     * @return  `List<VDT_Data_Calculation__c>` Master Data Analysis records
     */
    public List<VDT_Data_Calculation__c> getByAnalysisCalculationParameters(VDT_DataCalculationService.CalculationAnalysisParameters calculationParameters) {
        List<String> countryCriteria = new List<String>();
        for (String country : calculationParameters.countries) {
            countryCriteria.add('VDT_Country__c LIKE \'%'+ country + '%\'');
        }
        countryCriteria.add('VDT_Country__c LIKE \'%All%\'');
        String whereString = '(' + String.join(countryCriteria, ' OR ') + ')';
        if (calculationParameters.startYear != null) {
            whereString += ' AND Start_Year__c = ' + calculationParameters.startYear;
        }
        if (calculationParameters.startMonth != null) {
            whereString += ' AND Start_Month__c = ' + calculationParameters.startMonth;
        }
        if (calculationParameters.endYear != null) {
            whereString += ' AND End_Year__c = ' + calculationParameters.endYear;
        }
        if (calculationParameters.endMonth != null) {
            whereString += ' AND End_Month__c = ' + calculationParameters.endMonth;
        }
        whereString += ' AND RecordType.DeveloperName = :MASTER_ANALYSIS_RECORD_TYPE_DEV';
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            'WHERE {2} '+
            'WITH SECURITY_ENFORCED ORDER BY VDT_Job_End_Date__c DESC ' +
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
     * @description This method is called when the user hits the `Show Product Adoption` button on the `Product Hierarchy and Adoption` screen
     * @param calculationParameters 
     * @return  `List<VDT_Data_Calculation__c>` Product Adoption records.
     */
    public List<VDT_Data_Calculation__c> getByProductAdoptionParameters(VDT_DataCalculationService.ProductAdoptionParameters calculationParameters) {
        List<String> whereClauses = new List<String>();
        if (!calculationParameters.countries.isEmpty()) {
            List<String> countryCriteria = new List<String>();
            for (String country : calculationParameters.countries) {
                countryCriteria.add('VDT_Country__c LIKE \'%'+ country + '%\'');
            }
            countryCriteria.add('VDT_Country__c LIKE \'%All%\'');
            whereClauses.add('(' + String.join(countryCriteria, ' OR ') + ')');
        }
        if (calculationParameters.startYear != null) {
            whereClauses.add('Start_Year__c = ' + calculationParameters.startYear);
        }
        if (calculationParameters.startMonth != null) {
            whereClauses.add('Start_Month__c = ' + calculationParameters.startMonth);
        }
        if (calculationParameters.endYear != null) {
            whereClauses.add('End_Year__c = ' + calculationParameters.endYear);
        }
        if (calculationParameters.endMonth != null) {
            whereClauses.add('End_Month__c = ' + calculationParameters.endMonth);
        }
        whereClauses.add('RecordType.DeveloperName = :PRODUCT_ADOPTION_RECORD_TYPE_DEV');
        String whereString = String.join(whereClauses, ' AND ');
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            'WHERE {2} '+
            'WITH SECURITY_ENFORCED ORDER BY VDT_Job_End_Date__c DESC ' +
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
     * @param objectName SObject API Name the calculation job was run for.
     * @return  `List<VDT_Data_Calculation__c>` Data Calculation record for the given SOBject
     */
    public List<VDT_Data_Calculation__c> getByObjectName(String objectName) {
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            'WHERE  VDT_Object_Name__c = :objectName ' +
            'WITH   SECURITY_ENFORCED ', 
            new List<String>{
                getFieldListString(),
                getObjectName()
            }
        );

        return Database.query(query);
    }

    /**
     * 
     * @param objectName SObject Name the Calculation was run for
     * @param recordTypeName Data Calculation Record Type Developer Name
     * @return  `List<VDT_Data_Calculation__c>` where their Record Type and SObject match the provided search arguments.
     */
    public List<VDT_Data_Calculation__c> getByObjectNameAndReocordType(String objectName, String recordTypeName) {
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            'WHERE  VDT_Object_Name__c = :objectName AND RecordType.DeveloperName = :recordTypeName ' +
            'WITH   SECURITY_ENFORCED ORDER BY VDT_Job_End_Date__c DESC', 
            new List<String>{
                getFieldListString(),
                getObjectName()
            }
        );

        return Database.query(query);
    }

    /**
     * 
     * @param statuses List of Status to filter records
     * @return  `List<VDT_Data_Calculation__c>` records which status field value matches with one of the provided.
     */
    public List<VDT_Data_Calculation__c> getDataCalculationsByStatus(List<String> statuses) {
        List<String> additionalFields = new List<String>{
            VDT_Data_Calculation__c.Start_Year__c.getDescribe().getName(),
            VDT_Data_Calculation__c.Start_Month__c.getDescribe().getName(),
            VDT_Data_Calculation__c.End_Year__c.getDescribe().getName(),
            VDT_Data_Calculation__c.End_Month__c.getDescribe().getName(),
            VDT_Data_Calculation__c.Start_Date__c.getDescribe().getName(),
            VDT_Data_Calculation__c.End_Date__c.getDescribe().getName(),
            VDT_Data_Calculation__c.VDT_Job_Start_Date__c.getDescribe().getName(),
            VDT_Data_Calculation__c.VDT_Job_End_Date__c.getDescribe().getName(),
            VDT_Data_Calculation__c.VDT_Country__c.getDescribe().getName(),
            VDT_Data_Calculation__c.RecordTypeId.getDescribe().getName(),
            VDT_Data_Calculation__c.Permission_Set_Profile_Name__c.getDescribe().getName(),
            'CreatedBy.Name',
            'RecordType.DeveloperName'
        };
        String completedStatus = VDT_DataCalculationService.STATUS_COMPLETED;
        String errorStatus = VDT_DataCalculationService.STATUS_ERROR;
        List<String> allFields = getFieldList();
        allFields.addAll(additionalFields);
        
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            'WHERE  Status__c IN :statuses ' +
            'WITH   SECURITY_ENFORCED ORDER BY VDT_Job_End_Date__c DESC {2}', 
            new List<String>{
                String.join(allFields, ','),
                getObjectName(),
                getLimitString()
            }
        );

        return Database.query(query);
    }
}