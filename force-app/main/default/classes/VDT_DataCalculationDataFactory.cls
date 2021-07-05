@IsTest
public with sharing class VDT_DataCalculationDataFactory {
    
    private VDT_Data_Calculation__c dataCalculation;

    public VDT_DataCalculationDataFactory() {
        this.dataCalculation = new VDT_Data_Calculation__c();
    }

    public VDT_DataCalculationDataFactory profileOrPermissionSet(String objectName) {
        this.dataCalculation.Permission_Set_Profile_Name__c = objectName;
        return this;
    }

    public VDT_DataCalculationDataFactory object(String objectApi) {
        this.dataCalculation.VDT_Object_Name__c = objectApi;
        return this;
    }

    public VDT_DataCalculationDataFactory countries(List<String> countries) {
        this.dataCalculation.VDT_Country__c = String.join(countries, ',');
        return this;
    }

    public VDT_DataCalculationDataFactory startYearAndMonth(Integer year, Integer month) {
        if (year != null) {
            this.dataCalculation.Start_Year__c = year;
        }
        if (month != null) {
            this.dataCalculation.Start_Month__c = month;
        }
        return this;
    }

    public VDT_DataCalculationDataFactory endYearAndMonth(Integer year, Integer month) {
        if (year != null) {
            this.dataCalculation.End_Year__c = year;
        }
        if (month != null) {
            this.dataCalculation.End_Month__c = month;
        }
        return this;
    }

    public VDT_DataCalculationDataFactory calculationDate(Date calculationDate) {
        this.dataCalculation.VDT_Calculation_Date__c = calculationDate;
        return this;
    }

    public VDT_DataCalculationDataFactory country(String country) {
        this.dataCalculation.VDT_Country__c = country;
        return this;
    }

    public VDT_DataCalculationDataFactory status(String status) {
        this.dataCalculation.Status__c = status;
        return this;
    }

    public VDT_DataCalculationDataFactory territory(String territory) {
        this.dataCalculation.Territory__c = territory;
        return this;
    }

    public VDT_DataCalculationDataFactory recordType(String recordTypeName) {
        Id recordTypeId = Schema.SObjectType.VDT_Data_Calculation__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        this.dataCalculation.RecordTypeId = recordTypeId;
        return this;
    }

    public VDT_DataCalculationDataFactory insertRecord() {
        insert this.dataCalculation;
        return this;
    }

    public VDT_DataCalculationDataFactory addAttachment(String name, String content, String format) {
        VDT_AttachmentService.createAttachmentForRecord(content, name, format, this.dataCalculation.Id);
        return this;
    }

    public VDT_Data_Calculation__c getRecord() {
        return this.dataCalculation;
    }
}