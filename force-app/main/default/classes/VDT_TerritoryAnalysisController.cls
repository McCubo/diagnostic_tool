/**
 * @description provides access to apex service methods to LWC javascript controllers
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_TerritoryAnalysisController {

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
    public static PaginationWrapper getRecordsPerPageSOQL(String calculationRecordId, Integer pageNumber, Integer recordsPerPage, List<String> countries, String territoryName, String specialtyName, String comparisonOperator, Integer filterNumber, String accountType) {

        VDT_TransactionResultService.TerritorySearchParameter searchParameters = 
            new VDT_TransactionResultService.TerritorySearchParameter(calculationRecordId, pageNumber, recordsPerPage, countries, territoryName, specialtyName, comparisonOperator, filterNumber, accountType);
        
        List<VDT_TransactionResultService.TerritoryItem> territoriesInPage = VDT_TransactionResultService.getTransactionResultRecordsForCurrentPage(searchParameters);

        PaginationWrapper pw = new PaginationWrapper();

        pw.currentPageTerritories = territoriesInPage;
        pw.totalRecords = VDT_TransactionResultService.getTransactionTotalRecords(searchParameters);
        return pw;
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
    public static void exportReport(String calculationRecordId, Integer pageNumber, Integer recordsPerPage, List<String> countries, String territoryName, String specialtyName, String comparisonOperator, Integer filterNumber, String accountType) {
        try {
            VDT_TransactionResultService.TerritorySearchParameter searchParameters = 
                                new VDT_TransactionResultService.TerritorySearchParameter(calculationRecordId, pageNumber, recordsPerPage, countries, territoryName, specialtyName, comparisonOperator, filterNumber, accountType);
            Database.executeBatch(new VDT_TerritoryAnalysisExportBatch(searchParameters));
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
}
