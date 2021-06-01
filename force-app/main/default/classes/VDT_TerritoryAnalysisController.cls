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
    public static PaginationWrapper getRecordsPerPageSOQL(String calculationRecordId, Integer pageNumber, Integer recordsPerPage, String territoryName, String specialtyName, String comparisonOperator, Integer filterNumber, String accountType) {

        VDT_TransactionResultService.TerritorySearchParameter searchParameters = 
            new VDT_TransactionResultService.TerritorySearchParameter(calculationRecordId, pageNumber, recordsPerPage, 'All', territoryName, specialtyName, comparisonOperator, filterNumber, accountType);
        
        List<VDT_TransactionResultService.TerritoryItem> territoriesInPage = VDT_TransactionResultService.getTransactionResultRecordsForCurrentPage(searchParameters);

        PaginationWrapper pw = new PaginationWrapper();

        pw.currentPageTerritories = territoriesInPage;
        pw.totalRecords = VDT_TransactionResultService.getTransactionTotalRecords(searchParameters);
        return pw;
    }

    // @AuraEnabled(cacheable=true)
    // public static PaginationWrapper getRecordsPerPage(Integer pageNumber, Integer recordsPerPage, String territoryName, String specialtyName, String comparisonOperator, Integer filterNumber, String accountType) {
    //     try {
    //         System.debug('TEST:getCpuTime: ' + Limits.getCpuTime());
    //         Attachment att = [SELECT Id, Body FROM Attachment WHERE Id = '00P0v000005fShGEAU'][0];
    //         System.debug('TEST:getCpuTime: ' + Limits.getCpuTime());
    //         VDT_TerritoryAnalysisBuilder.TerritoryAnalysisOutput jsonFileResponse = 
    //             (VDT_TerritoryAnalysisBuilder.TerritoryAnalysisOutput) JSON.deserialize(att.Body.toString(), VDT_TerritoryAnalysisBuilder.TerritoryAnalysisOutput.class);
    //         System.debug('TEST:getCpuTime: ' + Limits.getCpuTime());
    //         List<TerritoryTreeItem> tempTerritories = new List<TerritoryTreeItem>();
    //         for (String territoryId : jsonFileResponse.territoryAnalysis.keySet()) {
    //             VDT_TerritoryAnalysisBuilder.TerritoryAnalysis territory = jsonFileResponse.territoryAnalysis.get(territoryId);
    //             Boolean meetsCriteria = true;
    //             // Filter By Territory Name
    //             if (String.isNotBlank(territoryName)) {
    //                 meetsCriteria &= territory.name.containsIgnoreCase(territoryName);
    //             }
    //             // Filter By Specialty Numbers
    //             if (String.isNotBlank(specialtyName) && String.isNotBlank(comparisonOperator) && filterNumber != null) {
    //                 Map<String, Integer> accountsBySpecialty = getAccountsBySpecialty(territory, accountType, new List<String>{'All'});
    //                 if (accountsBySpecialty.containsKey(specialtyName)) {
    //                     switch on comparisonOperator {
    //                         when 'eq'  {
    //                             meetsCriteria &= accountsBySpecialty.get(specialtyName) == filterNumber;
    //                         }
    //                         when 'neq' {
    //                             meetsCriteria &= accountsBySpecialty.get(specialtyName) != filterNumber;
    //                         }
    //                         when 'lt' {
    //                             meetsCriteria &= accountsBySpecialty.get(specialtyName) < filterNumber;
    //                         }
    //                         when 'gt' {
    //                             meetsCriteria &= accountsBySpecialty.get(specialtyName) > filterNumber;
    //                         }
    //                         when 'loe' {
    //                             meetsCriteria &= accountsBySpecialty.get(specialtyName) <= filterNumber;
    //                         }
    //                         when 'goe' {
    //                             meetsCriteria &= accountsBySpecialty.get(specialtyName) >= filterNumber;
    //                         }
    //                     }
    //                 } else {
    //                     meetsCriteria &= false;
    //                 }
    //             }

    //             if (meetsCriteria) {
    //                 tempTerritories.add(new TerritoryTreeItem(territory));
    //             }
    //         }
    //         System.debug('TEST:getCpuTime: ' + Limits.getCpuTime());
    //         List<TerritoryTreeItem> currentPageTerritories = new List<TerritoryTreeItem>();
    //         for (Integer i = 0; i < recordsPerPage; i++) {
    //             Integer indexToGet = (pageNumber -1) * recordsPerPage + i;
    //             if (indexToGet < tempTerritories.size()) {
    //                 currentPageTerritories.add(tempTerritories.get(indexToGet));
    //             }                
    //         }
    //         System.debug('TEST:getCpuTime: ' + Limits.getCpuTime());
    //         PaginationWrapper pw = new PaginationWrapper();
    //         pw.totalRecords = tempTerritories.size();
    //         pw.currentPageTerritories = currentPageTerritories;
    //         return pw;
    //     } catch (Exception e) {
    //         VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
    //         VDT_Log.get().publish();
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

    // private static Map<String, Integer> getAccountsBySpecialty(VDT_TerritoryAnalysisBuilder.TerritoryAnalysis territory, String accountType, List<String> countries) {
    //     Map<String, Integer> accountsBySpecialty = new Map<String, Integer>();
    //     if (accountType == 'All' || accountType == 'Business') {
    //         for (String countryCode : territory.businessCountrySummary.keySet()) {
    //             if (countries.indexOf(countryCode) != -1 || countries.indexOf('All') != -1) {
    //                 Map<String, Integer> specialtyMetrics = territory.businessCountrySummary.get(countryCode);
    //                 for (String specialty : specialtyMetrics.keySet()) {
    //                     if (!accountsBySpecialty.containsKey(specialty)) {
    //                         accountsBySpecialty.put(specialty, specialtyMetrics.get(specialty));
    //                     } else {
    //                         Integer specialtiesAcc = specialtyMetrics.get(specialty) + accountsBySpecialty.get(specialty);
    //                         accountsBySpecialty.put(specialty, specialtiesAcc);
    //                     }
    //                 }
    //             }
    //         }
    //     }
    //     if (accountType == 'All' || accountType == 'Person') {
    //         for (String countryCode : territory.personCountrySummary.keySet()) {
    //             if (countries.indexOf(countryCode) != -1 || countries.indexOf('All') != -1) {
    //                 Map<String, Integer> specialtyMetrics = territory.personCountrySummary.get(countryCode);
    //                 for (String specialty : specialtyMetrics.keySet()) {
    //                     if (!accountsBySpecialty.containsKey(specialty)) {
    //                         accountsBySpecialty.put(specialty, specialtyMetrics.get(specialty));
    //                     } else {
    //                         Integer specialtiesAcc = specialtyMetrics.get(specialty) + accountsBySpecialty.get(specialty);
    //                         accountsBySpecialty.put(specialty, specialtiesAcc);
    //                     }
    //                 }
    //             }
    //         }
    //     }        
    //     return accountsBySpecialty;
    // }

    public class PaginationWrapper {

        @AuraEnabled
        public List<VDT_TransactionResultService.TerritoryItem> currentPageTerritories = new List<VDT_TransactionResultService.TerritoryItem>();
        @AuraEnabled
        public Integer totalRecords;

    }

    // public class TerritoryTreeItem {

    //     @AuraEnabled
    //     public String name;
    //     @AuraEnabled
    //     public String id;
    //     @AuraEnabled
    //     public String parentId;
    //     @AuraEnabled
    //     public Map<String, Map<String, Integer>> businessCountrySummary = new Map<String, Map<String, Integer>>();
    //     @AuraEnabled
    //     public Map<String, Map<String, Integer>> personCountrySummary = new Map<String, Map<String, Integer>>();

    //     public TerritoryTreeItem(String id, String name) {
    //         this.name = name;
    //         this.id = id;
    //     }

    //     public TerritoryTreeItem(VDT_TerritoryAnalysisBuilder.TerritoryAnalysis territoryAnalysis) {
    //         this.id = territoryAnalysis.id;
    //         this.name = territoryAnalysis.name;
    //         this.parentId = territoryAnalysis.parentId;
    //         this.businessCountrySummary = territoryAnalysis.businessCountrySummary;
    //         this.personCountrySummary = territoryAnalysis.personCountrySummary;
    //     }
    // }

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
}
