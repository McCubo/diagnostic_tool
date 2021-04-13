public inherited sharing class VDT_DataCalculationService {

    public static final String MASTER_DATA_ANALYSIS_SUMMARY_FILE_NAME = 'onekey_analysis_summary';
    public static final String PRODUCT_ADOPTION_FILE_NAME = 'product_adoption_summary';

    public static final String STATUS_COMPLETED = 'Completed';
    public static final String STATUS_ERROR = 'Error';
    public static final String STATUS_IN_PROGRESS = 'In Progress';
    public static final String STATUS_IN_QUEUE = 'In Queue';

    @TestVisible
    private static List<String> inProgressCalculationStatuses = new List<String>{
        VDT_DataCalculationService.STATUS_IN_PROGRESS, 
        VDT_DataCalculationService.STATUS_IN_QUEUE
    };
    
    @TestVisible
    private static List<String> finishedCalculationStatuses = new List<String>{
        VDT_DataCalculationService.STATUS_COMPLETED, 
        VDT_DataCalculationService.STATUS_ERROR 
    };

    public static void triggerCalculation(CalculationParameters calculationParameters) {
        Integer maxRunningCalculations = VDT_CustomMetadataService.getMaxNumberOfRunningCalculations();
            List<VDT_Data_Calculation__c> inProgressCalculations = 
                new VDT_DataCalculationSelector().getDataCalculationsByStatus(
                    new List<String>{ 
                        VDT_DataCalculationService.STATUS_IN_PROGRESS
                    }
                );

            List<VDT_Data_Calculation__c> calculations = 
                new VDT_DataCalculationSelector()
                    .getByCalculationParameters(calculationParameters);
            
            
            if (inProgressCalculations.size() < maxRunningCalculations) {
                calculationParameters.status = STATUS_IN_PROGRESS;
            } else {
                calculationParameters.status = STATUS_IN_QUEUE;
            }

            VDT_Data_Calculation__c dataCalculationRecord = initializeDataCalculation(calculationParameters);
            if (calculations.isEmpty() == false) {
                dataCalculationRecord.Id = calculations[0].Id;
            }
            upsert dataCalculationRecord;

            if (dataCalculationRecord.Status__c == STATUS_IN_PROGRESS) {
                Integer batchSize = 
                    VDT_CustomMetadataService.getBatchSizeForObject(dataCalculationRecord.VDT_Object_Name__c);
                    system.debug('batchSize :: ' + batchSize);
                    system.debug('dataCalculationRecord.VDT_Object_Name__c :: ' + dataCalculationRecord.VDT_Object_Name__c);
                VDT_FieldsSummaryCalculationBatch fieldSummaryBatch = 
                    new VDT_FieldsSummaryCalculationBatch(dataCalculationRecord); 
                Database.executeBatch(fieldSummaryBatch, batchSize);
            }
    }

    public static VDT_Data_Calculation__c initializeDataCalculation(CalculationParameters calculationParameters) {
        List<RecordType> recordTypes = VDT_RecordTypeService.getRecordTypeByObjectAndName('VDT_Data_Calculation__c', VDT_DataCalculationSelector.OBJECT_ANALYSIS_RECORD_TYPE_DEV);
        return new VDT_Data_Calculation__c(
            VDT_Object_Name__c = calculationParameters.objectName,
            Status__c = calculationParameters.status, 
            Start_Year__c = calculationParameters.startYear,
            Start_Month__c = calculationParameters.startMonth,
            End_Year__c = calculationParameters.endYear,
            End_Month__c = calculationParameters.endMonth,
            RecordTypeId = recordTypes.get(0).Id
        );
    }

    public static void triggerProductAdoptionCalculation(ProductAdoptionParameters searchParameters) {
        Integer maxRunningCalculations = VDT_CustomMetadataService.getMaxNumberOfRunningCalculations();
        List<VDT_Data_Calculation__c> inProgressCalculations = new VDT_DataCalculationSelector().getDataCalculationsByStatus(new List<String>{ VDT_DataCalculationService.STATUS_IN_PROGRESS });
        
        if (inProgressCalculations.size() < maxRunningCalculations) {
            searchParameters.status = STATUS_IN_PROGRESS;
        } else {
            searchParameters.status = STATUS_IN_QUEUE;
        }

        VDT_Data_Calculation__c dataCalculationRecord = initRecordForProductAdoption(searchParameters);
        insert dataCalculationRecord;

        if (dataCalculationRecord.Status__c == STATUS_IN_PROGRESS) {
            Integer batchSize = VDT_CustomMetadataService.getBatchSizeForObject('Product_vod__c');
            List<String> additionalFields = new List<String>{'Start_Date__c', 'End_Date__c'};
            List<VDT_Data_Calculation__c> records = new VDT_DataCalculationSelector().withAdditionalFields(additionalFields).getById(dataCalculationRecord.Id);
            VDT_ProductAdoptionBatch productAdoptionBatch = new VDT_ProductAdoptionBatch(records[0]); 
            Database.executeBatch(productAdoptionBatch, batchSize);
        }
    }

    public static void triggerMasterAnalysisCalculation(CalculationAnalysisParameters searchParameters) {
        Integer maxRunningCalculations = VDT_CustomMetadataService.getMaxNumberOfRunningCalculations();
        List<VDT_Data_Calculation__c> inProgressCalculations = new VDT_DataCalculationSelector().getDataCalculationsByStatus(
                                                                    new List<String>{ VDT_DataCalculationService.STATUS_IN_PROGRESS });
        
        if (inProgressCalculations.size() < maxRunningCalculations) {
            searchParameters.status = STATUS_IN_PROGRESS;
        } else {
            searchParameters.status = STATUS_IN_QUEUE;
        }

        VDT_Data_Calculation__c dataCalculationRecord = initRecordForMasterAnalysis(searchParameters);
        insert dataCalculationRecord;

        if (dataCalculationRecord.Status__c == STATUS_IN_PROGRESS) {
            Integer batchSize = VDT_CustomMetadataService.getBatchSizeForObject('Account');
            List<String> additionalFields = new List<String>{'VDT_Country__c', 'Start_Date__c', 'End_Date__c'};
            List<VDT_Data_Calculation__c> records = new VDT_DataCalculationSelector().withAdditionalFields(additionalFields).getById(dataCalculationRecord.Id);
            VDT_MasterAnalysisCalculationBatch masterAnalysisBatch = new VDT_MasterAnalysisCalculationBatch(records[0]); 
            Database.executeBatch(masterAnalysisBatch, batchSize);
        }
    }

    public static VDT_Data_Calculation__c initRecordForProductAdoption(ProductAdoptionParameters searchParameters) {
        List<RecordType> recordTypes = VDT_RecordTypeService.getRecordTypeByObjectAndName('VDT_Data_Calculation__c', VDT_DataCalculationSelector.PRODUCT_ADOPTION_RECORD_TYPE_DEV);
        VDT_Data_Calculation__c dataCalculationRecord = new VDT_Data_Calculation__c(
            Status__c = searchParameters.status, 
            Start_Year__c = searchParameters.startYear,
            Start_Month__c = searchParameters.startMonth,
            End_Year__c = searchParameters.endYear,
            End_Month__c = searchParameters.endMonth,
            RecordTypeId = recordTypes[0].Id
        );
        return dataCalculationRecord;
    }

    public static VDT_Data_Calculation__c initRecordForMasterAnalysis(CalculationAnalysisParameters searchParameters) {
        List<RecordType> recordTypes = VDT_RecordTypeService.getRecordTypeByObjectAndName('VDT_Data_Calculation__c', VDT_DataCalculationSelector.MASTER_ANALYSIS_RECORD_TYPE_DEV);
        VDT_Data_Calculation__c dataCalculationRecord = new VDT_Data_Calculation__c(
            VDT_Country__c = String.join(searchParameters.countries, ','),
            Status__c = searchParameters.status, 
            Start_Year__c = searchParameters.startYear,
            Start_Month__c = searchParameters.startMonth,
            End_Year__c = searchParameters.endYear,
            End_Month__c = searchParameters.endMonth,
            RecordTypeId = recordTypes[0].Id
        );
        return dataCalculationRecord;
    }

    public static DataCalculation getExistingCalculationMasterAnalysis(CalculationAnalysisParameters searchParameters) {
        List<VDT_Data_Calculation__c> calculations = new VDT_DataCalculationSelector().withLimit(1).getByAnalysisCalculationParameters(searchParameters);
        
        DataCalculation calculation = new DataCalculation();
        if (!calculations.isEmpty()) {
            calculation.status = calculations[0].Status__c;
            calculation.calculationDate = String.valueOf(calculations[0].VDT_Calculation_Date__c);
            Attachment att = VDT_AttachmentService.getAttachmentForRecord(
                VDT_DataCalculationService.MASTER_DATA_ANALYSIS_SUMMARY_FILE_NAME,
                VDT_AttachmentService.JSON_FORMAT, 
                calculations[0].Id
            );

            if (att != null) {
                calculation.data = att.Body.toString();
            }
        }
        return calculation;
    }

    public static DataCalculation getExistingCalculationProductAdoption(ProductAdoptionParameters searchParameters) {
        List<VDT_Data_Calculation__c> calculations = new VDT_DataCalculationSelector().getByProductAdoptionParameters(searchParameters);
        
        DataCalculation calculation = new DataCalculation();
        if (!calculations.isEmpty()) {
            calculation.status = calculations[0].Status__c;
            calculation.calculationDate = String.valueOf(calculations[0].VDT_Calculation_Date__c);
            Attachment att = VDT_AttachmentService.getAttachmentForRecord(
                VDT_DataCalculationService.PRODUCT_ADOPTION_FILE_NAME,
                VDT_AttachmentService.JSON_FORMAT, 
                calculations[0].Id
            );

            if (att != null) {
                calculation.data = att.Body.toString();
            }
        }
        return calculation;        
    }

    public static DataCalculation getExistingCalculation(CalculationParameters calculationParameters) {
        List<VDT_Data_Calculation__c> calculations = 
            new VDT_DataCalculationSelector().getByCalculationParameters(calculationParameters);

        DataCalculation calculation = new DataCalculation();

        if (calculations.isEmpty() == false) {
            calculation.status = calculations[0].Status__c;
            calculation.calculationDate = String.valueOf(calculations[0].VDT_Calculation_Date__c);
            Attachment att = VDT_AttachmentService.getAttachmentForRecord(
                VDT_ObjectService.FIELD_SUMMARY_CALCULATION_FILE_NAME,
                VDT_AttachmentService.JSON_FORMAT, 
                calculations[0].Id
            );

            if (att != null) {
                calculation.data = att.Body.toString();
            }
        }
        
        return calculation;
    }

    public static DataCalculation getCalculationForObject(String objectName) {
        List<VDT_Data_Calculation__c> calculations = new VDT_DataCalculationSelector().getByObjectName(objectName);
        
        DataCalculation data = new DataCalculation();

        if (calculations.isEmpty() == false) {
            data.status = calculations[0].Status__c;
            Attachment att = VDT_AttachmentService.getAttachmentForRecord(
                VDT_ObjectService.FIELD_SUMMARY_CALCULATION_FILE_NAME,
                VDT_AttachmentService.JSON_FORMAT, 
                calculations[0].Id
            );

            data.data = att.Body.toString();
        }
        
        return data;
    }

    public static List<VDT_Data_Calculation__c> getFinishedCalculations() {
        return new VDT_DataCalculationSelector().getDataCalculationsByStatus(finishedCalculationStatuses);
    }

    public static MonitoringData getMonitoringData() {
        Integer maxCalculationRequests = 
            VDT_CustomMetadataService.getMaxNumberOfCalculationRequests();
        MonitoringData monitoringData = new MonitoringData();
        monitoringData.capacity = maxCalculationRequests;
        monitoringData.remaining = monitoringData.capacity;
        
        List<VDT_Data_Calculation__c> calculations = 
            new VDT_DataCalculationSelector().getDataCalculationsByStatus(inProgressCalculationStatuses);

        if (calculations.isEmpty() == false) {
            for (VDT_Data_Calculation__c calculation : calculations) {
                if (calculation.Status__c == VDT_DataCalculationService.STATUS_IN_PROGRESS) {
                    monitoringData.inProgress++;
                } else if (calculation.Status__c == VDT_DataCalculationService.STATUS_IN_QUEUE) {
                    monitoringData.inQueue++;
                }
            }
            monitoringData.remaining -= (monitoringData.inProgress + monitoringData.inQueue);
            monitoringData.calculationRecords = calculations;
        }

        return monitoringData;
    }

    public static void sendStatusUpdateEvent(Id calculationId, String status) {
        VDT_Calculation_Status_Update__e statusUpdate = new VDT_Calculation_Status_Update__e(
            Calculation_Id__c = calculationId,
            Status__c = status
        );

        EventBus.publish(new List<SObject>{ statusUpdate });
    }
    
    public class DataCalculation {
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String data;
        @AuraEnabled
        public String calculationDate;
        @AuraEnabled
        public String detailData;
    }

    public class MonitoringData {
        @AuraEnabled
        public Integer inProgress = 0;
        @AuraEnabled
        public Integer inQueue = 0;
        @AuraEnabled
        public Integer capacity = 0;
        @AuraEnabled
        public Integer remaining = 0;
        @AuraEnabled
        public List<VDT_Data_Calculation__c> calculationRecords = new List<VDT_Data_Calculation__c>();
    }

    public class CalculationParameters {
        @AuraEnabled
        public String objectName;
        @AuraEnabled
        public Integer startYear;
        @AuraEnabled
        public Integer startMonth;
        @AuraEnabled
        public Integer endYear;
        @AuraEnabled
        public Integer endMonth;
        public String status;
    }

    public abstract class SearchParameters {
        @AuraEnabled
        public Integer startYear;
        @AuraEnabled
        public Integer startMonth;
        @AuraEnabled
        public Integer endYear;
        @AuraEnabled
        public Integer endMonth;
        public String status;
    }

    public class CalculationAnalysisParameters extends SearchParameters {
        @AuraEnabled
        public List<String> countries;
    }

    public class ProductAdoptionParameters extends SearchParameters {

    }

}