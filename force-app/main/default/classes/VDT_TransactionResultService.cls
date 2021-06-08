public inherited sharing class VDT_TransactionResultService {

    public static final String TERRITORY_ANALYSIS_RECORD_TYPE_DEV = 'VDT_Territory_Analysis';

    private static Set<String> getTerritoryIdsByName(String territoryName, Boolean isFullSearch) {
        Set<String> territoryIds = new Set<String>();
        if (String.isNotBlank(territoryName)) {
            String territoryLike = '%' + territoryName + '%';
            for (Territory2 territory : new VDT_Territory2Selector().addWhereClauses(new List<String>{'Name LIKE \'' + territoryLike + '\''}).query()) {
                territoryIds.add(territory.Id);
            }
            if (!territoryIds.isEmpty() && isFullSearch) {
                List<Territory2> allTerritories = new VDT_Territory2Selector()
                                                    .addWhereClauses(new List<String>{'ParentTerritory2Id != NULL'})
                                                    .withAdditionalFields(new List<String>{'ParentTerritory2Id'})
                                                    .query();
                territoryIds.addAll(getChildTerritories(territoryIds, allTerritories));
            }
            if (territoryIds.isEmpty()) {
                territoryIds.add('000000000000000000');
            }
        }
        return territoryIds;
    }

    private static Set<String> getChildTerritories(Set<String> parentTerritoryIds, List<Territory2> allTerritories) {
        Set<String> childTerritories = new Set<String>();
        for (String territoryId : parentTerritoryIds) {
            for (Territory2 territory : allTerritories) {
                if (territory.ParentTerritory2Id == territoryId) {
                    childTerritories.add(territory.Id);
                }
            }
        }
        if (!childTerritories.isEmpty()) {
            childTerritories.addAll(getChildTerritories(childTerritories, allTerritories));
        }
        return childTerritories;
    }

    public static Map<String, List<String>> getWhereAndHavingClauses(TerritorySearchParameter searchParameters) {

        List<String> whereClauses = new List<String>();
        List<String> havingClauses = new List<String>();
        Set<String> territoryIds = getTerritoryIdsByName(searchParameters.territoryName, searchParameters.isFullSearch);

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
            List<String> territoryIdsQuoted = new List<String>();
            for (String territoryId : territoryIds) {
                territoryIdsQuoted.add('\'' + territoryId + '\'');
            }
            whereClauses.add('Territory_Id__c IN (' + String.join(territoryIdsQuoted, ',') + ')');
        }
        if (!searchParameters.countries.isEmpty() && !searchParameters.countries.contains('All')) {
            List<String> countryCriterias = new List<String>();
            for (String country : searchParameters.countries) {
                countryCriterias.add('Country__c = \'' + country + '\'');
            }
            whereClauses.add('(' + String.join(countryCriterias, ' OR ') + ')');
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
        for (Territory2 territory : new VDT_Territory2Selector().query()) {
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
        private List<String> countries;
        private String territoryName;
        private String specialtyName;
        private String comparisonOperator;
        private Integer filterNumber;
        private String accountType;
        private Boolean isFullSearch;

        public TerritorySearchParameter(String calculationRecordId, Integer pageNumber, Integer recordsPerPage, List<String> countries, String territoryName, String specialtyName, String comparisonOperator, Integer filterNumber, String accountType, Boolean isFullSearch) {
            this.calculationRecordId = calculationRecordId;
            this.pageNumber = pageNumber;
            this.recordsPerPage = recordsPerPage;
            this.countries = countries;
            this.territoryName = territoryName;
            this.specialtyName = specialtyName;
            this.comparisonOperator = comparisonOperator;
            this.filterNumber = filterNumber;
            this.accountType = accountType;
            this.isFullSearch = isFullSearch;
        }

        public String getAccountType() {
            return this.accountType;
        }

        public List<String> getCountries() {
            return this.countries;
        }

        public String getCalculationRecordId() {
            return this.calculationRecordId;
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