public inherited sharing class VDT_ObjectCalculationBuilder {
    private String objectName;
    private List<String> fieldNames = new List<String>();
    private Map<String, List<String>> layoutWithFields = new Map<String, List<String>>();
    private List<SObject> records = new List<SObject>();
    private ObjectFieldsSummary calculation = new ObjectFieldsSummary();
    private String countryField;

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

    public VDT_ObjectCalculationBuilder calculate() {
        for (String field : fieldNames) {
            FieldSummary fieldSummary = this.initFieldSummary(field);

            if (this.layoutWithFields.isEmpty() == false) {
                fieldSummary.pageLayouts = this.getPageLayoutsForField(field);
            }

            for (SObject record : records) {
                // system.debug('record.get(this.countryField) :: ' + record.get('CreatedBy'));
                // system.debug('record.get(this.countryField) :: ' + record.get('CreatedBy.Country'));
                String countryCode;
                if (this.countryField.indexOf('.') >= 0) {
                    system.debug('this.countryField :: ' + this.countryField);
                    List<String> parentCountryField = this.countryField.split('\\.');
                    system.debug('parentCountryField :: ' + parentCountryField);
                    countryCode = String.valueOf(record.getSObject(parentCountryField[0]).get(parentCountryField[1]));
                } else {
                    countryCode = String.valueOf(record.get(this.countryField));
                }

                CountryUsageSummary countryUsageSummary = null;
                if (fieldSummary.countryUsageSummary.get(countryCode) == null) {
                    countryUsageSummary = new CountryUsageSummary();
                    fieldSummary.countryUsageSummary.put(countryCode, countryUsageSummary);
                } else {
                    countryUsageSummary = fieldSummary.countryUsageSummary.get(countryCode);
                }

                if (record.get(field) != null) {
                    countryUsageSummary.usageNumber++;
                }
                countryUsageSummary.totalRecords++;
                countryUsageSummary.usagePercentage = 
                    (Decimal.valueOf(countryUsageSummary.usageNumber) / Decimal.valueOf(countryUsageSummary.totalRecords));
                
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
                }
                this.calculation.uniqueCountryCodes.add(countryCode);
            }
        }

        return this;
    }

    public ObjectFieldsSummary build() {
        this.calculation.countryCodes.addAll(this.calculation.uniqueCountryCodes);
        return this.calculation;
    }

    private FieldSummary initFieldSummary(String field) {
        FieldSummary fieldSummary = null;
        if (this.calculation.fields.get(field) == null) {
            Schema.DescribeFieldResult fieldDescribe = 
                Schema.getGlobalDescribe()
                    .get(this.objectName)
                    .getDescribe()
                    .fields
                    .getMap()
                    .get(field)
                    .getDescribe();
            fieldSummary = new FieldSummary();
            fieldSummary.name = field;
            fieldSummary.label = fieldDescribe.getLabel();
            fieldSummary.type = String.valueOf(fieldDescribe.getType());

            this.calculation.fields.put(field, fieldSummary);
        } else {
            fieldSummary = this.calculation.fields.get(field);
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
        @AuraEnabled public Map<String, FieldSummary> fields = new Map<String, FieldSummary>();
        @AuraEnabled public List<String> countryCodes = new List<String>();
        public Set<String> uniqueCountryCodes = new Set<String>();
    }

    public class FieldSummary {
        @AuraEnabled public String label;
        @AuraEnabled public String name;
        @AuraEnabled public String type;
        @AuraEnabled public Map<String, CountryUsageSummary> countryUsageSummary = 
            new Map<String, CountryUsageSummary>();
        @AuraEnabled public List<String> pageLayouts = new List<String>();
    }

    public class CountryUsageSummary {
        @AuraEnabled public Integer usageNumber = 0;
        @AuraEnabled public Integer totalRecords = 0;
        @AuraEnabled public Decimal usagePercentage = 0;
        @AuraEnabled public Map<String, Decimal> fieldValueOccurences = new Map<String, Decimal>();
    }
}