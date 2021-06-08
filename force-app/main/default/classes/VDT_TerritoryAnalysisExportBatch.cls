/**
 * @description Batch used to export Territory Analysis Data
 * @author BASE Life Science
 * @since 2021.03.01
 */
public with sharing class VDT_TerritoryAnalysisExportBatch implements Database.Batchable<AggregateResult>, Database.Stateful {

    private VDT_TransactionResultService.TerritorySearchParameter searchParameters = null;
    private Map<String, String> territoryNameById = new Map<String, String>();
    private List<VDT_Transaction_Result__c> territoryAnalyses = new List<VDT_Transaction_Result__c>();

    public VDT_TerritoryAnalysisExportBatch(VDT_TransactionResultService.TerritorySearchParameter searchParameters) {
        this.searchParameters = searchParameters;
        // get names for all territories
        for (Territory2 territory : new VDT_Territory2Selector().query()) {
            this.territoryNameById.put(territory.Id, territory.Name);
        }        
    }

    // The batch job starts
    public Iterable<AggregateResult> start(Database.BatchableContext bc) {
        Map<String, List<String>> filterCriteriasByName = VDT_TransactionResultService.getWhereAndHavingClauses(this.searchParameters);
        List<String> whereClauses = filterCriteriasByName.get('WHERE');
        List<String> havingClauses = filterCriteriasByName.get('HAVING');

        String query = new VDT_TransactionResultSelector()
            .withGroupByFields(new List<String>{'Territory_Id__c'})
            .addWhereClauses(whereClauses)
            .addHavingClauses(havingClauses)
            .getQueryString();
        return new VDT_AggregateResultIterable(query);
    } 

    // The batch job executes and operates on one batch of records
    public void execute(Database.BatchableContext bc, List<AggregateResult> scope) {
        Set<String> territoriesInPageIds = new Set<String>();
        for (AggregateResult aggregateResult : scope)  {
            territoriesInPageIds.add('\'' + aggregateResult.get('Territory_Id__c').toString() + '\'');
        }

        
        if (!territoriesInPageIds.isEmpty()) {
            this.territoryAnalyses.addAll(new VDT_TransactionResultSelector()
                .withAdditionalFields(new List<String>{'Country__c', 'Specialty__c', 'Territory_Id__c', 'Total_Accounts__c', 'Account_Type__c'})
                .addWhereClauses(new List<String> {
                    'Data_Calculation__c = \'' + this.searchParameters.getCalculationRecordId() +'\'',
                    'Territory_Id__c IN (' + String.join(new List<String>(territoriesInPageIds), ',') + ')'
                })
                .query());
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        String headers = 'Territory, Country, Account Type, Specialty, Total Accounts\n';
        String csvContent = headers;
        for (VDT_Transaction_Result__c territoryAnalysis : this.territoryAnalyses) {
            Boolean accountTypeMatch = this.searchParameters.getAccountType() == 'All' || territoryAnalysis.Account_Type__c == this.searchParameters.getAccountType();
            Boolean countryMatch = this.searchParameters.getCountries().isEmpty() || this.searchParameters.getCountries().contains('All') || this.searchParameters.getCountries().contains(territoryAnalysis.Country__c);
            if (accountTypeMatch && countryMatch) {
                String recordData = String.join(new List<String> {
                    this.territoryNameById.get(territoryAnalysis.Territory_Id__c),
                    territoryAnalysis.Country__c,
                    territoryAnalysis.Account_Type__c,
                    territoryAnalysis.Specialty__c.escapeCsv(),
                    String.valueOf(territoryAnalysis.Total_Accounts__c)
                }, ',') + '\n';   
                csvContent += recordData;
            }
        }


        VDT_AttachmentService.insertDocument('TerritoriesAndSpecialties', csvContent, '.csv');
        VDT_EmailService.sendTerritoryExportNotification();
    }

}