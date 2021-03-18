public inherited sharing class VDT_DataCalculationSelector {
    
    private Integer limitValue;
    private List<String> additionalFields = new List<String>();
    private static final String MASTER_ANALYSIS_RECORD_TYPE = 'Master Data Analysis';

    public String getObjectName() {
        return 'VDT_Data_Calculation__c';
    }
    public List<String> getFieldList() {
        return new List<String>{
            VDT_Data_Calculation__c.Id.getDescribe().getName(),
            VDT_Data_Calculation__c.VDT_Object_Name__c.getDescribe().getName(),
            VDT_Data_Calculation__c.Status__c.getDescribe().getName(),
            VDT_Data_Calculation__c.VDT_Calculation_Date__c.getDescribe().getName()
        };
    }

    public String getFieldListString() {
        List<String> fields = this.getFieldList();
        if (!this.additionalFields.isEmpty()) {
            fields.addAll(this.additionalFields);
        }
        return String.join(fields, ',');
    }

    public VDT_DataCalculationSelector withLimit(Integer limitValue) {
        this.limitValue = limitValue;
        return this;
    }

    public VDT_DataCalculationSelector withAdditionalFields(List<String> additionalFields) {
        this.additionalFields = additionalFields;
        return this;
    }

    public String getLimitString() {
        String limitString = '';
        if (this.limitValue != null) {
            limitString = 'LIMIT ' + this.limitValue;
        }
        return limitString;
    }

    public List<VDT_Data_Calculation__c> getByCalculationParameters(VDT_DataCalculationService.CalculationParameters calculationParameters) {
        system.debug('calculationParameters: ' + calculationParameters);
        String whereString = 'VDT_Object_Name__c = \'' + String.escapeSingleQuotes(calculationParameters.objectName) +'\'';
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
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            'WHERE {2} '+
            'WITH   SECURITY_ENFORCED ', 
            new List<String>{
                getFieldListString(),
                getObjectName(),
                whereString
            }
        );

        system.debug(query);

        return Database.query(query);
    }

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

    public List<VDT_Data_Calculation__c> getByCountries(String countries) {
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            'WHERE VDT_Country__c = :countries AND RecordType.Name = :MASTER_ANALYSIS_RECORD_TYPE ' +
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
        whereString += ' AND RecordType.Name = :MASTER_ANALYSIS_RECORD_TYPE';
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
            'CreatedBy.Name'
        };
        String completedStatus = VDT_DataCalculationService.STATUS_COMPLETED;
        String errorStatus = VDT_DataCalculationService.STATUS_ERROR;
        List<String> allFields = getFieldList();
        allFields.addAll(additionalFields);
        
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            'WHERE  Status__c IN :statuses ' +
            'WITH   SECURITY_ENFORCED {2}', 
            new List<String>{
                String.join(allFields, ','),
                getObjectName(),
                getLimitString()
            }
        );

        return Database.query(query);
    }
}
