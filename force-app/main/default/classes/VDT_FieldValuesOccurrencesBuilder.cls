public with sharing class VDT_FieldValuesOccurrencesBuilder {
    
    private String objectName;
    private List<String> fieldNames = new List<String>();
    private String countryField;
    private List<SObject> records = new List<SObject>();
    private Map<String, VDT_FieldSummary> fieldByName = new Map<String, VDT_FieldSummary>();
    private List<VDT_FieldSummary> fieldSummaries = new List<VDT_FieldSummary>();
    private Set<String> countries = new Set<String>();

    public VDT_FieldValuesOccurrencesBuilder(String objectName, List<String> fieldNames) {
        this.objectName = objectName;
        this.fieldNames = fieldNames;
        this.countryField = VDT_CustomMetadataService.getCountryFieldForObject(objectName);
    }

    public VDT_FieldValuesOccurrencesBuilder withRecords(List<SObject> records) {
        this.records = records;
        return this;
    }

    public VDT_FieldValuesOccurrencesBuilder calculate() {

        for (String field : this.fieldNames) {
            VDT_FieldSummary fieldSummary = this.initFieldSummary(field);
            for (SObject record : records) {
                String countryCode;
                if (this.countryField.indexOf('.') >= 0) {
                    List<String> parentCountryField = this.countryField.split('\\.');
                    countryCode = String.valueOf(record.getSObject(parentCountryField[0]).get(parentCountryField[1]));
                } else {
                    countryCode = String.valueOf(record.get(this.countryField));
                }
                countries.add(countryCode);
                VDT_FieldSummary.CountryUsageSummary countryUsageSummary = null;
                if (!fieldSummary.countryUsageSummary.containsKey(countryCode)) {
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

                if (fieldSummary.type == 'picklist') {
                    String picklistValue = record.get(field) == null ? '' : String.valueOf(record.get(field));
                    if (countryUsageSummary.fieldValueOccurences.get(picklistValue) == null) {
                        countryUsageSummary.fieldValueOccurences.put(picklistValue, 1);
                    } else {
                        countryUsageSummary.fieldValueOccurences.put(picklistValue, countryUsageSummary.fieldValueOccurences.get(picklistValue) + 1);
                    }
                }

            }
        }
        return this;
    }

    public String build() {
        Map<String, Object> output = new Map<String, Object>();
        Set<String> fieldNames = new Set<String>();
        for (VDT_FieldSummary fieldSummary : fieldByName.values()) {
            fieldNames.add(fieldSummary.name);
        }
        output.put('fieldNames', fieldNames);
        output.put('fields', fieldByName.values());
        output.put('countryCodes', this.countries);
        
        Map<String, Set<String>> valuesByField = VDT_ObjectService.getPicklistValuesByFieldName(this.objectName, fieldNames);
        output.put('values_by_fields', valuesByField);
        return JSON.serialize(output);
    }

    private VDT_FieldSummary initFieldSummary(String field) {
        VDT_FieldSummary fieldSummary = null;
        if (!this.fieldByName.containsKey(field)) {
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
            this.fieldByName.put(field, fieldSummary);
        } else {
            fieldSummary = this.fieldByName.get(field);
        }

        return fieldSummary;
    }

}