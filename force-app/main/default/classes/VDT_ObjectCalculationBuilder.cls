public inherited sharing class VDT_ObjectCalculationBuilder {
    private String objectName;
    private List<String> fieldNames = new List<String>();
    private Map<String, List<String>> layoutWithFields = new Map<String, List<String>>();
    private List<SObject> records = new List<SObject>();
    private String countryField;
    Map<String, VDT_FieldSummary> summaries = new Map<String, VDT_FieldSummary>();
    public Set<String> uniqueCountryCodes = new Set<String>();

    public VDT_ObjectCalculationBuilder(String objectName, List<String> fieldNames) { 
        this.objectName = objectName;
        this.fieldNames = fieldNames;

        this.countryField = VDT_CustomMetadataService.getCountryFieldForObject(this.objectName);
    }

    public VDT_ObjectCalculationBuilder withPageLayoutInformation(Map<String, List<String>> layoutWithFields) {
        this.layoutWithFields = layoutWithFields;
        return this;
    }

    public VDT_ObjectCalculationBuilder withRecords(List<SObject> records) {
        this.records = records;
        return this;
    }

    public VDT_ObjectCalculationBuilder withFieldSummaryRecords(List<VDT_Field_Summary__c> summaries) {
        this.summaries = new Map<String, VDT_FieldSummary>(); 
        for (VDT_Field_Summary__c summary : summaries) {
            VDT_FieldSummary fieldSummary = new VDT_FieldSummary(summary.Label__c, summary.Name__c, summary.Type__c);
            fieldSummary.id = summary.Id;
            fieldSummary.countryUsageSummary = (Map<String, VDT_FieldSummary.CountryUsageSummary>) JSON.deserialize(summary.Country_Usage_Summary__c, Map<String, VDT_FieldSummary.CountryUsageSummary>.class);
            fieldSummary.pageLayouts = (List<String>) JSON.deserialize(summary.Page_Layouts__c, List<String>.class);
            this.summaries.put(summary.Name__c, fieldSummary);
        }
        return this;
    }

    public VDT_ObjectCalculationBuilder calculate(String jobId) {
        List<VDT_FieldSummary> upsertSummaries = new List<VDT_FieldSummary>();
        for (String field : fieldNames) {
            VDT_FieldSummary fieldSummary = this.initFieldSummary(field);

            if (!this.layoutWithFields.isEmpty()) {
                fieldSummary.pageLayouts = this.getPageLayoutsForField(field);
            }

            for (SObject record : records) {
                String countryCode;
                if (this.countryField.indexOf('.') >= 0) {
                    List<String> parentCountryField = this.countryField.split('\\.');
                    countryCode = String.valueOf(record.getSObject(parentCountryField[0]).get(parentCountryField[1]));
                } else {
                    countryCode = String.valueOf(record.get(this.countryField));
                }

                VDT_FieldSummary.CountryUsageSummary countryUsageSummary = null;
                if (fieldSummary.countryUsageSummary.get(countryCode) == null) {
                    countryUsageSummary = new VDT_FieldSummary.CountryUsageSummary();
                    fieldSummary.countryUsageSummary.put(countryCode, countryUsageSummary);
                } else {
                    countryUsageSummary = fieldSummary.countryUsageSummary.get(countryCode);
                }

                if (record.get(field) != null) {
                    countryUsageSummary.usageNumber++;
                }
                countryUsageSummary.totalRecords++;
                countryUsageSummary.usagePercentage = (Decimal.valueOf(countryUsageSummary.usageNumber) / Decimal.valueOf(countryUsageSummary.totalRecords)).setScale(2);
                
                if (fieldSummary.type == 'boolean') {
                    if (countryUsageSummary.fieldValueOccurences.get('true') == null) {
                        countryUsageSummary.fieldValueOccurences.put('true', 0);
                    }
                    if (countryUsageSummary.fieldValueOccurences.get('false') == null) {
                        countryUsageSummary.fieldValueOccurences.put('false', 0);
                    }
                    
                    if (record.get(field) == true) {
                        countryUsageSummary.fieldValueOccurences.put('true', countryUsageSummary.fieldValueOccurences.get('true')+1);
                    } else {
                        countryUsageSummary.fieldValueOccurences.put('false', countryUsageSummary.fieldValueOccurences.get('false')+1);
                    }
                } else if (fieldSummary.type == 'picklist') {
                    String picklistValue = record.get(field) == null ? '' : String.valueOf(record.get(field));
                    if (countryUsageSummary.fieldValueOccurences.get(picklistValue) == null) {
                        countryUsageSummary.fieldValueOccurences.put(picklistValue, 1);
                    } else {
                        countryUsageSummary.fieldValueOccurences.put(picklistValue, countryUsageSummary.fieldValueOccurences.get(picklistValue) + 1);
                    }
                }
                this.uniqueCountryCodes.add(countryCode);
            }
            upsertSummaries.add(fieldSummary);
        }
        if (!upsertSummaries.isEmpty()) {
            List<VDT_Field_Summary__c> fieldSummaries = new List<VDT_Field_Summary__c>();
            for (VDT_FieldSummary fieldSummary : upsertSummaries) {
                VDT_Field_Summary__c fieldSummarySObject = new VDT_Field_Summary__c(
                    Label__c = fieldSummary.label,
                    Name__c = fieldSummary.name,
                    Page_Layouts__c = JSON.serialize(fieldSummary.pageLayouts),
                    Type__c = fieldSummary.type,
                    Country_Usage_Summary__c = JSON.serialize(fieldSummary.countryUsageSummary),
                    Job_Id__c = jobId
                );
                if (!fieldSummary.isNew()) {
                    fieldSummarySObject.Id = fieldSummary.id;
                }
                fieldSummaries.add(fieldSummarySObject);
            }
            upsert fieldSummaries;
        }
        return this;
    }

    public String build(String jobId) {        
        List<VDT_Field_Summary__c> summaries =  new VDT_FieldSummarySelector()
            .addWhereClause('Job_Id__c = \'' + jobId + '\'')
            .query();
        String fieldsProperty = VDT_FieldSummary.getParsedObjects(summaries);
        String countriesProperty = JSON.serialize(this.uniqueCountryCodes);
        String builtJson = String.format('\'{\'"uniqueCountryCodes":{1},{0},"countryCodes":{1}\'}\'', new List<String>{
            fieldsProperty,
            countriesProperty
        });
        return builtJson;
    }

    private VDT_FieldSummary initFieldSummary(String field) {
        VDT_FieldSummary fieldSummary = null;
        if (!this.summaries.containsKey(field)) {
            Schema.DescribeFieldResult fieldDescribe = 
                Schema.getGlobalDescribe()
                    .get(this.objectName)
                    .getDescribe()
                    .fields
                    .getMap()
                    .get(field)
                    .getDescribe();
            fieldSummary = new VDT_FieldSummary(
                fieldDescribe.getLabel(),
                field,
                String.valueOf(fieldDescribe.getType())
            );
            this.summaries.put(field, fieldSummary);
        } else {
            fieldSummary = this.summaries.get(field);
        }

        return fieldSummary;
    }

    private List<String> getPageLayoutsForField(String field) {
        Set<String> uniquePageLayouts = new Set<String>();
        for (String layout : this.layoutWithFields.keySet()) {
            List<String> layoutFields = layoutWithFields.get(layout);
            if (layoutFields.indexOf(field) >= 0) {
                uniquePageLayouts.add(layout);
            }
        }
        return new List<String>(uniquePageLayouts);
    }

    public class ObjectFieldsSummary {
        
        Map<String, VDT_FieldSummary> fields = new Map<String, VDT_FieldSummary>();
        public Set<String> uniqueCountryCodes = new Set<String>();
        public Set<String> countryCodes = new Set<String>();

    }
}