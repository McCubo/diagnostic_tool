public inherited sharing class VDT_TransactionResultService {

    public static final String TERRITORY_ANALYSIS_RECORD_TYPE_DEV = 'VDT_Territory_Analysis';

    private static Set<String> getTerritoryIdsByName(String territoryName) {
        Set<String> territoryIds = new Set<String>();
        if (String.isNotBlank(territoryName)) {
            String territoryLike = '%' + territoryName + '%';
            for (Territory2 territory : [SELECT Id FROM Territory2 WHERE Name LIKE :territoryLike]) {
                territoryIds.add('\'' + territory.Id + '\'');
            }
        }
        return territoryIds;
    }

    private static Map<String, List<String>> getWhereAndHavingClauses(TerritorySearchParameter searchParameters) {

        List<String> whereClauses = new List<String>();
        List<String> havingClauses = new List<String>();
        Set<String> territoryIds = getTerritoryIdsByName(searchParameters.territoryName);

        whereClauses.add('Data_Calculation__c = \''+ searchParameters.calculationRecordId + '\'');
        if (String.isNotBlank(searchParameters.specialtyName) && String.isNotBlank(searchParameters.comparisonOperator) && searchParameters.filterNumber != null) {
            whereClauses.add('Specialty__c = \'' + searchParameters.specialtyName + '\'');
            switch on searchParameters.comparisonOperator {
                when 'eq'  {
                    havingClauses.add('SUM(Total_Accounts__c) = ' + searchParameters.filterNumber);
                }
                when 'neq' {
                    havingClauses.add('SUM(Total_Accounts__c) != ' + searchParameters.filterNumber);
                }
                when 'lt' {
                    havingClauses.add('SUM(Total_Accounts__c) < ' + searchParameters.filterNumber);
                }
                when 'gt' {
                    havingClauses.add('SUM(Total_Accounts__c) > ' + searchParameters.filterNumber);
                }
                when 'loe' {
                    havingClauses.add('SUM(Total_Accounts__c) <= ' + searchParameters.filterNumber);
                }
                when 'goe' {
                    havingClauses.add('SUM(Total_Accounts__c) >= ' + searchParameters.filterNumber);
                }
            }
        }
        if (!territoryIds.isEmpty()) {
            whereClauses.add('Territory_Id__c IN (' + String.join(new List<String>(territoryIds), ',') + ')');
        }
        if (String.isNotBlank(searchParameters.country) && searchParameters.country != 'All') {
            whereClauses.add('Country__c = \'' + searchParameters.country + '\'');
        }

        if (String.isNotBlank(searchParameters.accountType) && searchParameters.accountType != 'All') {
            whereClauses.add('Account_Type__c = \'' + searchParameters.accountType + '\'');
        }        

        return new Map<String, List<String>>{
            'WHERE' => whereClauses,
            'HAVING' => havingClauses
        };
    }

    public static Integer getTransactionTotalRecords(TerritorySearchParameter searchParameters) {
        Map<String, List<String>> filterCriteriasByName = getWhereAndHavingClauses(searchParameters);
        List<String> whereClauses = filterCriteriasByName.get('WHERE');
        List<String> havingClauses = filterCriteriasByName.get('HAVING');

        AggregateResult[] territoriesInPage = new VDT_TransactionResultSelector()
            .withGroupByFields(new List<String>{'Territory_Id__c'})
            .addWhereClauses(whereClauses)
            .addHavingClauses(havingClauses)
            .queryCount();
        
        return territoriesInPage.size();
    }

    public static List<TerritoryItem> getTransactionResultRecordsForCurrentPage(TerritorySearchParameter searchParameters) {
        Map<String, String> territoryNameById = new Map<String, String>();
        
        

        // get names for all territories
        for (Territory2 territory : [SELECT Id, Name FROM Territory2]) {
            territoryNameById.put(territory.Id, territory.Name);
        }
        
        Map<String, List<String>> filterCriteriasByName = getWhereAndHavingClauses(searchParameters);
        List<String> whereClauses = filterCriteriasByName.get('WHERE');
        List<String> havingClauses = filterCriteriasByName.get('HAVING');

        AggregateResult[] territoriesInPage = new VDT_TransactionResultSelector()
            .withGroupByFields(new List<String>{'Territory_Id__c'})
            .addWhereClauses(whereClauses)            
            .withLimit(searchParameters.recordsPerPage)
            .withOffset((searchParameters.pageNumber - 1) * searchParameters.recordsPerPage)
            .addHavingClauses(havingClauses)
            .queryAggregate();
        
        Set<String> territoriesInPageIds = new Set<String>();
        for (AggregateResult aggregateResult : territoriesInPage)  {
            territoriesInPageIds.add('\'' + aggregateResult.get('Territory_Id__c').toString() + '\'');
        }

        List<VDT_Transaction_Result__c> territoryAnalyses = new List<VDT_Transaction_Result__c>();
        
        if (!territoriesInPageIds.isEmpty()) {
            territoryAnalyses = new VDT_TransactionResultSelector()
                .withAdditionalFields(new List<String>{'Country__c', 'Specialty__c', 'Territory_Id__c', 'Total_Accounts__c', 'Account_Type__c'})
                .addWhereClauses(new List<String> {
                    'Territory_Id__c IN (' + String.join(new List<String>(territoriesInPageIds), ',') + ')'
                })
                .query();
        }
        
        Map<String, TerritoryItem> itemsByTerritoryId = new Map<String, TerritoryItem>();

        for (VDT_Transaction_Result__c territoryAnalysis : territoryAnalyses) {
            Boolean isNewTerritoryCalculation = false;
            TerritoryItem tableRecord = null;
            if (itemsByTerritoryId.containsKey(territoryAnalysis.Territory_Id__c)) {
                tableRecord = itemsByTerritoryId.get(territoryAnalysis.Territory_Id__c);
            } else {
                tableRecord = new TerritoryItem(territoryAnalysis.Territory_Id__c, territoryNameById.get(territoryAnalysis.Territory_Id__c));
                isNewTerritoryCalculation = true;
            }

            if (territoryAnalysis.Account_Type__c == 'Person') {
                if (tableRecord.personCountrySummary.containsKey(territoryAnalysis.Country__c)) {
                    tableRecord.personCountrySummary.get(territoryAnalysis.Country__c).put(territoryAnalysis.Specialty__c, Integer.valueOf(territoryAnalysis.Total_Accounts__c));
                } else {
                    tableRecord.personCountrySummary.put(territoryAnalysis.Country__c, new Map<String, Integer> {
                        territoryAnalysis.Specialty__c => Integer.valueOf(territoryAnalysis.Total_Accounts__c)
                    });
                }
            }
            if (territoryAnalysis.Account_Type__c == 'Business') {
                if (tableRecord.businessCountrySummary.containsKey(territoryAnalysis.Country__c)) {
                    tableRecord.businessCountrySummary.get(territoryAnalysis.Country__c).put(territoryAnalysis.Specialty__c, Integer.valueOf(territoryAnalysis.Total_Accounts__c));
                } else {
                    tableRecord.businessCountrySummary.put(territoryAnalysis.Country__c, new Map<String, Integer> {
                        territoryAnalysis.Specialty__c => Integer.valueOf(territoryAnalysis.Total_Accounts__c)
                    });
                }
            }

            if (isNewTerritoryCalculation) {
                itemsByTerritoryId.put(territoryAnalysis.Territory_Id__c, tableRecord);
            }
        }
        return itemsByTerritoryId.values();
    }

    public class TerritorySearchParameter {

        private String calculationRecordId;
        private Integer pageNumber;
        private Integer recordsPerPage;
        private String country;
        private String territoryName;
        private String specialtyName;
        private String comparisonOperator;
        private Integer filterNumber;
        private String accountType;

        public TerritorySearchParameter(String calculationRecordId, Integer pageNumber, Integer recordsPerPage, String country, String territoryName, String specialtyName, String comparisonOperator, Integer filterNumber, String accountType) {
            this.calculationRecordId = calculationRecordId;
            this.pageNumber = pageNumber;
            this.recordsPerPage = recordsPerPage;
            this.country = country;
            this.territoryName = territoryName;
            this.specialtyName = specialtyName;
            this.comparisonOperator = comparisonOperator;
            this.filterNumber = filterNumber;
            this.accountType = accountType;
        }
    }

    public class TerritoryItem {

        @AuraEnabled
        public String name;
        @AuraEnabled
        public String id;
        @AuraEnabled
        public Map<String, Map<String, Integer>> businessCountrySummary = new Map<String, Map<String, Integer>>();
        @AuraEnabled
        public Map<String, Map<String, Integer>> personCountrySummary = new Map<String, Map<String, Integer>>();

        public TerritoryItem(String id, String name) {
            this.name = name;
            this.id = id;
        }
    }

}
