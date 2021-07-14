/**
 * @description This Apex class contains all methods needed to trigger new calculation jobs and retrieve information for jobs that have been already calculated
 *              (Master Data Analysis, Product Adoption, Field Occurrences, Field Level Security, Field Calculations)
 * @author      BASE Life Science
 * @since       2021.03.01
 */
public inherited sharing class VDT_DataCalculationService {

    public static final String MASTER_DATA_ANALYSIS_SUMMARY_FILE_NAME = 'onekey_analysis_summary';
    public static final String PRODUCT_ADOPTION_FILE_NAME = 'product_adoption_summary';
    public static final String TERRITORY_ANALYSIS_FILE_NAME = 'territory_management';
    public static final String FIELD_LEVEL_SECURITY_FILE_NAME = 'field_level_security';
    public static final String OBJECT_PROFILE_PERMISSIONS_FILE_NAME = 'object_permissions';

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

    /**
     * @description Creates a new VDT_Data_Calculation__c record, set its record type to `VDT_Field_Level_Security_Analysis`
     *              and checks whether there are free slots to start the calculation, if so, it triggers a new batch job, if not,
     *              the Calculation record's status is set to `In Queue` and the batch job will be triggered once a slot becomes available
     * @param calculationParameters Object that contains the SObject API names the job will include in its calculations
     */
    public static void triggerFlsAndObjectAnalysisCalculation(FieldLevelSecurityParameter calculationParameters) {
        Integer maxRunningCalculations = VDT_CustomMetadataService.getMaxNumberOfRunningCalculations();
        List<VDT_Data_Calculation__c> inProgressCalculations = 
            new VDT_DataCalculationSelector().getDataCalculationsByStatus(
                new List<String>{
                    VDT_DataCalculationService.STATUS_IN_PROGRESS
                }
            );
        
        if (inProgressCalculations.size() < maxRunningCalculations) {
            calculationParameters.status = STATUS_IN_PROGRESS;
        } else {
            calculationParameters.status = STATUS_IN_QUEUE;
        }

        VDT_Data_Calculation__c dataCalculationRecord = initRecordForFlsAndObject(calculationParameters);
        insert dataCalculationRecord;

        if (dataCalculationRecord.Status__c == STATUS_IN_PROGRESS) {
            List<String> additionalFields = new List<String>{'Permission_Set_Profile_Name__c'};
            List<VDT_Data_Calculation__c> records = new VDT_DataCalculationSelector().withAdditionalFields(additionalFields).getById(dataCalculationRecord.Id);
            VDT_PermissionSetAnalysisBuilder builder = new VDT_PermissionSetAnalysisBuilder(records.get(0));
            System.enqueueJob(builder);
        }
    }

    /**
     * @description Search for a VDT_Data_Calculation record that matches with all the criterias from the search parameter,
     *              If a record is found, then the calculations output is returned on the `data` property of the returned object.
     *              The returned object also contains information about when the calculation was ran and its status.
     * @param searchParameters Object with parameters used to find records (Object Names)
     * @return  `DataCalculation` Object with all information for the Calculation Job
     */
    public static DataCalculation getExistingProfileAndPermissionAnalysisCalculation(FieldLevelSecurityParameter searchParameters) {
        List<String> permissionAndProfileCriterias = new List<String>();
        for (String profilePermissionSetName : searchParameters.objectNames) {
            permissionAndProfileCriterias.add('Permission_Set_Profile_Name__c LIKE \'%' + profilePermissionSetName + '%\'');
        }
        List<VDT_Data_Calculation__c> calculations = new VDT_DataCalculationSelector()
                                                        .withLimit(1)
                                                        .withConditionals(new List<String>{
                                                            'RecordType.DeveloperName = \'' + VDT_DataCalculationSelector.FIELD_LEVEL_SECURITY_RECORD_TYPE_DEV + '\'',
                                                            '(' + String.join(permissionAndProfileCriterias, ' OR ') + ')'
                                                        }).query();
        
        DataCalculation calculation = new DataCalculation();
        if (!calculations.isEmpty()) {
            calculation.status = calculations[0].Status__c;
            calculation.calculationDate = String.valueOf(calculations[0].VDT_Calculation_Date__c);
            Attachment objectPermissions = VDT_AttachmentService.getAttachmentForRecord(
                VDT_DataCalculationService.OBJECT_PROFILE_PERMISSIONS_FILE_NAME,
                VDT_AttachmentService.JSON_FORMAT, 
                calculations[0].Id
            );

            if (objectPermissions != null) {
                calculation.data = objectPermissions.Body.toString();
            }
            Attachment flsPermissions = VDT_AttachmentService.getAttachmentForRecord(
                VDT_DataCalculationService.FIELD_LEVEL_SECURITY_FILE_NAME,
                VDT_AttachmentService.JSON_FORMAT, 
                calculations[0].Id
            );
            if (flsPermissions != null) {
                calculation.detailData = flsPermissions.Body.toString();
            }            
        }
        return calculation;
    }

    public static void deleteCalculationRecordsById(List<String> ids) {
        List<VDT_Data_Calculation__c> records = new List<VDT_Data_Calculation__c>();
        for (String recordId : ids) {
            records.add(new VDT_Data_Calculation__c(Id = recordId));
        }
        delete records;
    }

    public static List<DataCalculationLog> getFinishedCalculationsWithDetailsByRecordType(String recordTypeDevName, List<String> fields) {
        List<VDT_Data_Calculation__c> dataCalculations = new VDT_DataCalculationSelector().withConditionals(new List<String>{
            'RecordType.DeveloperName = \'' + recordTypeDevName + '\'',
            '(Status__c = \'' + VDT_DataCalculationService.STATUS_COMPLETED + '\' OR Status__c = \'' + VDT_DataCalculationService.STATUS_ERROR + '\')'
        }).withAdditionalFields(fields)
        .query();
        Map<String, Integer> rowsByParent = VDT_TransactionResultSelector.getTransactionNumberByParent();
        List<DataCalculationLog> logs = new List<DataCalculationLog>();
        for (VDT_Data_Calculation__c dataCalculation : dataCalculations) {
            DataCalculationLog log = new DataCalculationLog();
            log.record = dataCalculation;
            log.totalTransactions = rowsByParent.containsKey(dataCalculation.Id) ? rowsByParent.get(dataCalculation.Id) : 0;
            logs.add(log);
        }
        return logs;
    }

    /**
     * @description Creates a new VDT_Data_Calculation__c record, set its record type to `VDT_Field_Level_Security_Analysis`
     *              and checks whether there are free slots to start the calculation, if so, it triggers a new batch job, if not,
     *              the Calculation record's status is set to `In Queue` and the batch job will be triggered once a slot becomes available
     * @param calculationParameters Object that contains the SObject API names the job will include in its calculations
     */
    public static void triggerFieldLevelSecurityAnalysisCalculation(FieldLevelSecurityParameter calculationParameters) {
        Integer maxRunningCalculations = VDT_CustomMetadataService.getMaxNumberOfRunningCalculations();
        List<VDT_Data_Calculation__c> inProgressCalculations = 
            new VDT_DataCalculationSelector().getDataCalculationsByStatus(
                new List<String>{
                    VDT_DataCalculationService.STATUS_IN_PROGRESS
                }
            );
        
        if (inProgressCalculations.size() < maxRunningCalculations) {
            calculationParameters.status = STATUS_IN_PROGRESS;
        } else {
            calculationParameters.status = STATUS_IN_QUEUE;
        }

        VDT_Data_Calculation__c dataCalculationRecord = initRecordForFieldLevelSecurity(calculationParameters);
        insert dataCalculationRecord;

        if (dataCalculationRecord.Status__c == STATUS_IN_PROGRESS) {
            Integer batchSize = VDT_CustomMetadataService.getBatchSizeForObject(dataCalculationRecord.VDT_Object_Name__c);
            VDT_FieldLevelSecurityBatch flsBatch = new VDT_FieldLevelSecurityBatch(dataCalculationRecord);
            Database.executeBatch(flsBatch, batchSize);
        }
    }

    /**
     * 
     * @param searchParameters Holds information to create the new record: Object Names and Status
     * @return  `VDT_Data_Calculation__c` new record with its record type set to `VDT_Field_Level_Security_Analysis`
     */
    public static VDT_Data_Calculation__c initRecordForFieldLevelSecurity(FieldLevelSecurityParameter searchParameters) {
        List<RecordType> recordTypes = VDT_RecordTypeService.getRecordTypeByObjectAndName('VDT_Data_Calculation__c', VDT_DataCalculationSelector.FIELD_LEVEL_SECURITY_RECORD_TYPE_DEV);
        VDT_Data_Calculation__c dataCalculationRecord = new VDT_Data_Calculation__c(
            VDT_Object_Name__c = String.join(searchParameters.objectNames, ','),
            Status__c = searchParameters.status, 
            RecordTypeId = recordTypes[0].Id
        );
        return dataCalculationRecord;
    }

    public static VDT_Data_Calculation__c initRecordForFlsAndObject(FieldLevelSecurityParameter searchParameters) {
        List<RecordType> recordTypes = VDT_RecordTypeService.getRecordTypeByObjectAndName('VDT_Data_Calculation__c', VDT_DataCalculationSelector.FIELD_LEVEL_SECURITY_RECORD_TYPE_DEV);
        VDT_Data_Calculation__c dataCalculationRecord = new VDT_Data_Calculation__c(
            Permission_Set_Profile_Name__c = String.join(searchParameters.objectNames, ','),
            Status__c = searchParameters.status, 
            RecordTypeId = recordTypes[0].Id
        );
        return dataCalculationRecord;        
    }

    /**
     * @description Search for a VDT_Data_Calculation record that matches with all the criterias from the search parameter,
     *              If a record is found, then the calculations output is returned on the `data` property of the returned object.
     *              The returned object also contains information about when the calculation was ran and its status.
     * @param searchParameters Object with parameters used to find records (Object Names)
     * @return  `DataCalculation` Object with all information for the Calculation Job
     */
    public static DataCalculation getExistingFieldLevelSecurityAnalysisCalculation(FieldLevelSecurityParameter searchParameters) {
        List<String> objectCriterias = new List<String>();
        for (String objectname : searchParameters.objectNames) {
            objectCriterias.add('VDT_Object_Name__c = \'' + objectname + '\'');
        }
        List<VDT_Data_Calculation__c> calculations = new VDT_DataCalculationSelector()
                                                        .withLimit(1)
                                                        .withConditionals(new List<String>{
                                                            'RecordType.DeveloperName = \'' + VDT_DataCalculationSelector.FIELD_LEVEL_SECURITY_RECORD_TYPE_DEV + '\'',
                                                            '(' + String.join(objectCriterias, ' OR ') + ')'
                                                        }).query();
        
        DataCalculation calculation = new DataCalculation();
        if (!calculations.isEmpty()) {
            calculation.status = calculations[0].Status__c;
            calculation.calculationDate = String.valueOf(calculations[0].VDT_Calculation_Date__c);
            Attachment att = VDT_AttachmentService.getAttachmentForRecord(
                VDT_DataCalculationService.FIELD_LEVEL_SECURITY_FILE_NAME,
                VDT_AttachmentService.JSON_FORMAT, 
                calculations[0].Id
            );

            if (att != null) {
                calculation.data = att.Body.toString();
            }
        }
        return calculation;
    }

    /**
     * @description Creates a new VDT_Data_Calculation__c record, set its record type to `VDT_Territory_Analysis`
     *              and checks whether there are free slots to start the calculation, if so, it triggers a new `VDT_TerritoryManagementBatch` job, if not,
     *              the Calculation record's status is set to `In Queue` and the batch job will be triggered once a slot becomes available
     * @param calculationParameters Object that contains the SObject API names the job will include in its calculations
     */
    public static void triggerTerritoryAnalysisCalculation(TerritoryAnalysisParameters calculationParameters) {
        Integer maxRunningCalculations = VDT_CustomMetadataService.getMaxNumberOfRunningCalculations();
            List<VDT_Data_Calculation__c> inProgressCalculations = 
                new VDT_DataCalculationSelector().getDataCalculationsByStatus(
                    new List<String>{ 
                        VDT_DataCalculationService.STATUS_IN_PROGRESS
                    }
                );
            
            if (inProgressCalculations.size() < maxRunningCalculations) {
                calculationParameters.status = STATUS_IN_PROGRESS;
            } else {
                calculationParameters.status = STATUS_IN_QUEUE;
            }

            VDT_Data_Calculation__c dataCalculationRecord = initRecordForTerritoryAnalysis(calculationParameters);
            insert dataCalculationRecord;

            if (dataCalculationRecord.Status__c == STATUS_IN_PROGRESS) {
                Integer batchSize = VDT_CustomMetadataService.getBatchSizeForObject('Account');
                List<String> additionalFields = new List<String>{'VDT_Country__c', 'Territory__c'};
                List<VDT_Data_Calculation__c> records = new VDT_DataCalculationSelector().withAdditionalFields(additionalFields).getById(dataCalculationRecord.Id);
                VDT_TerritoryManagementBatch territoryAnalysisBatch = new VDT_TerritoryManagementBatch(records.get(0));
                Database.executeBatch(territoryAnalysisBatch, batchSize);
            }
    }

    /**
     * @description Creates a new VDT_Data_Calculation__c record, set its record type to `VDT_Object_Field_Analysis`
     *              and checks whether there are free slots to start the calculation, if so, it triggers a new `VDT_FieldsSummaryCalculationBatch` job, if not,
     *              the Calculation record's status is set to `In Queue` and the batch job will be triggered once a slot becomes available
     * @param calculationParameters Object that contains the SObject API names the job will include in its calculations
     */
    public static void triggerCalculation(CalculationParameters calculationParameters) {
        Integer maxRunningCalculations = VDT_CustomMetadataService.getMaxNumberOfRunningCalculations();
            List<VDT_Data_Calculation__c> inProgressCalculations = 
                new VDT_DataCalculationSelector().getDataCalculationsByStatus(
                    new List<String>{ 
                        VDT_DataCalculationService.STATUS_IN_PROGRESS
                    }
                );
            
            if (inProgressCalculations.size() < maxRunningCalculations) {
                calculationParameters.status = STATUS_IN_PROGRESS;
            } else {
                calculationParameters.status = STATUS_IN_QUEUE;
            }

            VDT_Data_Calculation__c dataCalculationRecord = initializeDataCalculation(calculationParameters, VDT_DataCalculationSelector.OBJECT_ANALYSIS_RECORD_TYPE_DEV);
            insert dataCalculationRecord;

            if (dataCalculationRecord.Status__c == STATUS_IN_PROGRESS) {
                Integer batchSize = VDT_CustomMetadataService.getBatchSizeForObject(dataCalculationRecord.VDT_Object_Name__c);
                List<String> additionalFields = new List<String>{'Start_Date__c', 'End_Date__c'};
                List<VDT_Data_Calculation__c> records = new VDT_DataCalculationSelector().withAdditionalFields(additionalFields).getById(dataCalculationRecord.Id);
                VDT_FieldsSummaryCalculationBatch fieldSummaryBatch = new VDT_FieldsSummaryCalculationBatch(records.get(0));
                Database.executeBatch(fieldSummaryBatch, batchSize);
            }
    }

    /**
     * @description Creates a new VDT_Data_Calculation__c record, set its record type to `VDT_Object_Field_Value_Occurrence`
     *              and checks whether there are free slots to start the calculation, if so, it triggers a new `VDT_FieldValuesOccurrencesBatch` job, if not,
     *              the Calculation record's status is set to `In Queue` and the batch job will be triggered once a slot becomes available
     * @param calculationParameters Object that contains the SObject API names the job will include in its calculations
     */
    public static void triggerFieldValueOccurrenceCalculation(CalculationParameters calculationParameters) {
        Integer maxRunningCalculations = VDT_CustomMetadataService.getMaxNumberOfRunningCalculations();
            List<VDT_Data_Calculation__c> inProgressCalculations = 
                new VDT_DataCalculationSelector().getDataCalculationsByStatus(
                    new List<String>{ 
                        VDT_DataCalculationService.STATUS_IN_PROGRESS
                    }
                );
            
            if (inProgressCalculations.size() < maxRunningCalculations) {
                calculationParameters.status = STATUS_IN_PROGRESS;
            } else {
                calculationParameters.status = STATUS_IN_QUEUE;
            }

            VDT_Data_Calculation__c dataCalculationRecord = initializeDataCalculation(calculationParameters, VDT_DataCalculationSelector.FIELD_OCCURRENCE_RECORD_TYPE_DEV);
            insert dataCalculationRecord;

            if (dataCalculationRecord.Status__c == STATUS_IN_PROGRESS) {
                Integer batchSize = VDT_CustomMetadataService.getBatchSizeForObject(dataCalculationRecord.VDT_Object_Name__c);
                List<String> additionalFields = new List<String>{'Start_Date__c', 'End_Date__c'};
                List<VDT_Data_Calculation__c> records = new VDT_DataCalculationSelector().withAdditionalFields(additionalFields).getById(dataCalculationRecord.Id);
                VDT_FieldValuesOccurrencesBatch fieldValueOccurrenceBatch = new VDT_FieldValuesOccurrencesBatch(records.get(0)); 
                Database.executeBatch(fieldValueOccurrenceBatch, batchSize);
            }
    }

    /**
     * @param calculationParameters contains all properties to create the new VDT Data Calculation Record
     * @param recordTypeName Record Type API Name (it can be whether VDT_Object_Field_Analysis or VDT_Object_Field_Value_Occurrence)
     * @return  `VDT_Data_Calculation__c`
     */
    public static VDT_Data_Calculation__c initializeDataCalculation(CalculationParameters calculationParameters, String recordTypeName) {
        List<RecordType> recordTypes = VDT_RecordTypeService.getRecordTypeByObjectAndName('VDT_Data_Calculation__c', recordTypeName);
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

    /**
     * @description Creates a new VDT_Data_Calculation__c record, set its record type to `VDT_Product_Adoption`
     *              and checks whether there are free slots to start the calculation, if so, it triggers a new `VDT_ProductAdoptionBatch` job, if not,
     *              the Calculation record's status is set to `In Queue` and the batch job will be triggered once a slot becomes available
     * @param calculationParameters Object that contains the SObject API names the job will include in its calculations
     */    
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
            String productSObjectAPIName = VDT_CustomMetadataService.getProductCatalogObjectAPI();
            Integer batchSize = VDT_CustomMetadataService.getBatchSizeForObject(productSObjectAPIName);
            List<String> additionalFields = new List<String>{'VDT_Country__c', 'Start_Date__c', 'End_Date__c'};
            List<VDT_Data_Calculation__c> records = new VDT_DataCalculationSelector().withAdditionalFields(additionalFields).getById(dataCalculationRecord.Id);
            VDT_ProductAdoptionBatch productAdoptionBatch = new VDT_ProductAdoptionBatch(records[0]); 
            Database.executeBatch(productAdoptionBatch, batchSize);
        }
    }

    /**
     * @description Creates a new VDT_Data_Calculation__c record, set its record type to `VDT_Master_Data_Analysis`
     *              and checks whether there are free slots to start the calculation, if so, it triggers a new `VDT_MasterAnalysisCalculationBatch` job, if not,
     *              the Calculation record's status is set to `In Queue` and the batch job will be triggered once a slot becomes available
     * @param calculationParameters Object that contains the SObject API names the job will include in its calculations
     */     
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

    /**
     * @param searchParameters object that contains all information for the new Product Adoption record: countries, start/end year, start/end month & status
     * @return  `VDT_Data_Calculation__c` new record with record type set to `VDT_Product_Adoption`
     */
    public static VDT_Data_Calculation__c initRecordForProductAdoption(ProductAdoptionParameters searchParameters) {
        List<RecordType> recordTypes = VDT_RecordTypeService.getRecordTypeByObjectAndName('VDT_Data_Calculation__c', VDT_DataCalculationSelector.PRODUCT_ADOPTION_RECORD_TYPE_DEV);
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

    /**
     * @param searchParameters object that contains all information from the search form on the Master Data Analysis screen.
     * @return  `VDT_Data_Calculation__c` new record with record type set to `VDT_Master_Data_Analysis`
     */
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

    /**
     * @param searchParameters object that contains all information from the search form on the Territory Analysis screen.
     * @return  `VDT_Data_Calculation__c` new record with record type set to `VDT_Territory_Analysis`
     */    
    public static VDT_Data_Calculation__c initRecordForTerritoryAnalysis(TerritoryAnalysisParameters searchParameters) {
        List<RecordType> recordTypes = VDT_RecordTypeService.getRecordTypeByObjectAndName('VDT_Data_Calculation__c', VDT_DataCalculationSelector.TERRITORY_ANALYSIS_RECORD_TYPE_DEV);
        VDT_Data_Calculation__c dataCalculationRecord = new VDT_Data_Calculation__c(
            VDT_Country__c = String.join(searchParameters.countries, ','),
            Territory__c = searchParameters.territory,
            Status__c = searchParameters.status, 
            RecordTypeId = recordTypes[0].Id
        );
        return dataCalculationRecord;
    }

    /**
     * @description Search for a VDT_Data_Calculation record that matches with all the criterias from the search parameter,
     *              If a record is found, then the calculations output is returned on the `data` property of the returned object.
     *              The returned object also contains information about when the calculation was ran and its status.
     * @param searchParameters Object with parameters used to find records (Object Names)
     * @return  `DataCalculation` Object with all information for the Calculation Job
     */
    public static DataCalculation getExistingTerritoryAnalysisCalculation(TerritoryAnalysisParameters searchParameters) {        
        List<VDT_Data_Calculation__c> calculations = new VDT_DataCalculationSelector().withLimit(1).getByTerritoryCalculationParameters(searchParameters);
        
        DataCalculation calculation = new DataCalculation();
        if (!calculations.isEmpty()) {
            calculation.status = calculations[0].Status__c;
            calculation.calculationDate = String.valueOf(calculations[0].VDT_Calculation_Date__c);
            Attachment att = VDT_AttachmentService.getAttachmentForRecord(
                VDT_DataCalculationService.TERRITORY_ANALYSIS_FILE_NAME,
                VDT_AttachmentService.JSON_FORMAT, 
                calculations[0].Id
            );
            calculation.detailData = calculations.get(0).Id;
            if (att != null) {
                calculation.data = att.Body.toString();
            }
        }
        return calculation;
    }

    /**
     * @description Search for a VDT_Data_Calculation record that matches with all the criterias from the search parameter,
     *              If a record is found, then the calculations output is returned on the `data` property of the returned object.
     *              The returned object also contains information about when the calculation was ran and its status.
     * @param searchParameters Object with parameters used to find records (Object Names)
     * @return  `DataCalculation` Object with all information for the Calculation Job
     */
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

    /**
     * @description Search for a VDT_Data_Calculation record that matches with all the criterias from the search parameter,
     *              If a record is found, then the calculations output is returned on the `data` property of the returned object.
     *              The returned object also contains information about when the calculation was ran and its status.
     * @param searchParameters Object with parameters used to find records (Object Names)
     * @return  `DataCalculation` Object with all information for the Calculation Job
     */
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

    /**
     * @description Search for a VDT_Data_Calculation record that matches with all the criterias from the search parameter,
     *              If a record is found, then the calculations output is returned on the `data` property of the returned object.
     *              The returned object also contains information about when the calculation was ran and its status.
     * @param calculationParameters Object with parameters used to find records (Object Names)
     * @param recordTypeName What Record Type the User wants information from (it can be whether VDT_Object_Field_Analysis or VDT_Object_Field_Value_Occurrence)
     * @param fileName Name of the attachment file that stores the calculation data (summary_calculation or field_values_occurrences)
     * @return  `DataCalculation` Object with all information for the Calculation Job
     */    
    public static DataCalculation getExistingCalculation(CalculationParameters calculationParameters, String recordTypeName, String fileName) {
        List<VDT_Data_Calculation__c> calculations = 
            new VDT_DataCalculationSelector().getByCalculationParameters(calculationParameters, recordTypeName);

        DataCalculation calculation = new DataCalculation();

        if (calculations.isEmpty() == false) {
            calculation.status = calculations[0].Status__c;
            calculation.calculationDate = String.valueOf(calculations[0].VDT_Calculation_Date__c);
            Attachment att = VDT_AttachmentService.getAttachmentForRecord(
                fileName,
                VDT_AttachmentService.JSON_FORMAT, 
                calculations[0].Id
            );

            if (att != null) {
                calculation.data = att.Body.toString();
            }
        }
        
        return calculation;
    }

    /**
     * @description Records returned on this method are shown on the `Logs` tab on each screen
     * @return  `List<VDT_Data_Calculation__c>` all Calculation jobs that are completed (Whether Successfully or not)
     */
    public static List<VDT_Data_Calculation__c> getFinishedCalculations() {
        return new VDT_DataCalculationSelector().getDataCalculationsByStatus(finishedCalculationStatuses);
    }

    /**
     * @description Information returned by this method is shown on the `Monitoring` tab presented on each screen
     * @return  `MonitoringData` contains all information about the number of jobs in queue, currently executing
     */
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

    /**
     * @description When an exception is thrown when running a Calculation job, the status of the record that launched the job must be updated to ERROR
     * @param calculationId VDT_Data_Calculation__c record's ID
     * @param status any valid option on `VDT_Data_Calculation__c.Status__c` (In Progress, Completed, In Queue, Error)
     */
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
        @AuraEnabled
        public List<String> countries;
    }

    public class TerritoryAnalysisParameters {

        @AuraEnabled
        public List<String> countries;
        @AuraEnabled
        public String territory;

        public String status;
    }

    public class FieldLevelSecurityParameter {

        @AuraEnabled
        public List<String> objectNames;
        public String status;

    }

    public class DataCalculationLog {
        @AuraEnabled
        public VDT_Data_Calculation__c record;
        @AuraEnabled
        public Integer totalTransactions = 0;

    }
}