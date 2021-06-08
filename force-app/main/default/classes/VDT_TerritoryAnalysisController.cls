/**
 * @description provides access to apex service methods to LWC javascript controllers
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_TerritoryAnalysisController {

    @AuraEnabled
    public static List<VDT_TerritoryAnalysisBuilder.TerritoryItem> getTerritoryHierarchy() {
        try {
             return new VDT_TerritoryAnalysisBuilder().getTerritoryHierarchy();
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void deleteCalculationRecords(List<String> ids) {
        try {
            VDT_DataCalculationService.deleteCalculationRecordsById(ids);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<VDT_DataCalculationService.DataCalculationLog> fetchFinishedCalculations() {
        try {
            return VDT_DataCalculationService.getFinishedCalculationsWithDetailsByRecordType(
                VDT_DataCalculationSelector.TERRITORY_ANALYSIS_RECORD_TYPE_DEV, 
                new List<String>{
                    'Territory__c', 'VDT_Country__c', 'VDT_Job_Start_Date__c', 'VDT_Job_End_Date__c', 'CreatedBy.Name'
                });
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<VDT_OptionWrapper> getAllTerritoryOptions() {
        try {
            List<VDT_OptionWrapper> options = new List<VDT_OptionWrapper>();
            options.add(new VDT_OptionWrapper('All', 'All'));
            for (Territory2 territory : new VDT_Territory2Selector()
                                        .withAdditionalFields(new List<String>{'DeveloperName'})
                                        .addWhereClauses(new List<String>{'ParentTerritory2Id = NULL'})
                                        .query()) {
                options.add(new VDT_OptionWrapper(territory.Name, territory.DeveloperName));
            }
            return options;
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * 
     * @param jsonSearchParameters Search parameters selected by the User on the Territory Analysis screen
     * @return  `VDT_DataCalculationService.DataCalculation` record with all information about the calculation job: Status, Completion Date and Output data generated
     * @exception AuraHandledException
     */
    @AuraEnabled
    public static VDT_DataCalculationService.DataCalculation searchExistingCalculations(String jsonSearchParameters) {
        try {
            VDT_DataCalculationService.TerritoryAnalysisParameters calculationParameters = (VDT_DataCalculationService.TerritoryAnalysisParameters)JSON.deserialize(
                jsonSearchParameters, 
                VDT_DataCalculationService.TerritoryAnalysisParameters.class
                );
            return VDT_DataCalculationService.getExistingTerritoryAnalysisCalculation(calculationParameters);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static PaginationWrapper getRecordsPerPageSOQL(String calculationRecordId, Integer pageNumber, Integer recordsPerPage, List<String> countries, String territoryName, String specialtyName, String comparisonOperator, Integer filterNumber, String accountType, Boolean isFullSearch) {
        try {
            isFullSearch = isFullSearch != null ? isFullSearch : false;
            VDT_TransactionResultService.TerritorySearchParameter searchParameters = 
                new VDT_TransactionResultService.TerritorySearchParameter(calculationRecordId, pageNumber, recordsPerPage, countries, territoryName, specialtyName, comparisonOperator, filterNumber, accountType, isFullSearch);
            
            List<VDT_TransactionResultService.TerritoryItem> territoriesInPage = VDT_TransactionResultService.getTransactionResultRecordsForCurrentPage(searchParameters);
    
            PaginationWrapper pw = new PaginationWrapper();
    
            pw.currentPageTerritories = territoriesInPage;
            pw.totalRecords = VDT_TransactionResultService.getTransactionTotalRecords(searchParameters);
            return pw;            
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());            
        }
    }

    public class PaginationWrapper {

        @AuraEnabled
        public List<VDT_TransactionResultService.TerritoryItem> currentPageTerritories = new List<VDT_TransactionResultService.TerritoryItem>();
        @AuraEnabled
        public Integer totalRecords;

    }

    /**
     * @description If the queue has availability, a new job is triggered for the selected jobs.
     * @param jsonSearchParameters Search parameters selected by the User on the Master Data Analysis screen
     * @exception AuraHandledException
     */
    @AuraEnabled
    public static void recalculateTerritoryAnalysis(String jsonSearchParameters) {
        try {
            VDT_DataCalculationService.TerritoryAnalysisParameters calculationParameters = (VDT_DataCalculationService.TerritoryAnalysisParameters)JSON.deserialize(
                jsonSearchParameters, 
                VDT_DataCalculationService.TerritoryAnalysisParameters.class
            );
            VDT_DataCalculationService.triggerTerritoryAnalysisCalculation(calculationParameters);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void exportReport(String calculationRecordId, Integer pageNumber, Integer recordsPerPage, List<String> countries, String territoryName, String specialtyName, String comparisonOperator, Integer filterNumber, String accountType, Boolean isFullSearch) {
        try {
            isFullSearch = isFullSearch != null ? isFullSearch : false;
            VDT_TransactionResultService.TerritorySearchParameter searchParameters = 
                                new VDT_TransactionResultService.TerritorySearchParameter(calculationRecordId, pageNumber, recordsPerPage, countries, territoryName, specialtyName, comparisonOperator, filterNumber, accountType, false);
            Database.executeBatch(new VDT_TerritoryAnalysisExportBatch(searchParameters));
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
}