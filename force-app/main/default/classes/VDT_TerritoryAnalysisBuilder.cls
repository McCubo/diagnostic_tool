/**
 * @description Apex builder class used to aggregate data based on territory and account specialty
 * @author BASE Life Science
 * @since 2021.03.01
 */
public with sharing class VDT_TerritoryAnalysisBuilder {

    private String countryField;
    private String specialtyField;
    private String dataCalculationId;
    private Set<String> accountIds = new Set<String>();
    private List<Account> records = new List<Account>();
    private List<String> territoriesInCalculation = new List<String>();
    private TerritoryAnalysisOutput territoryAnalysisData = new TerritoryAnalysisOutput();
    private final String EMPTY_PLACEHOLDER = '<<EMPTY>>';
    private final String DELIMITER_CHAR = '_';
    private Map<String, Integer> associationsByParentAccount = new Map<String, Integer>();

    public VDT_TerritoryAnalysisBuilder() {

    }

    public VDT_TerritoryAnalysisBuilder(String countryField, String specialtyField, String dataCalculationId) {
        this.countryField = countryField;
        this.specialtyField = specialtyField;
        this.dataCalculationId = dataCalculationId;
    }

    public VDT_TerritoryAnalysisBuilder withTerritories(String territoryCalculation) {
        if (String.isNotBlank(territoryCalculation) && territoryCalculation != 'All') {
            this.territoriesInCalculation = new VDT_Territory2Selector().getAllTerritoryIdsInHierarchy(new List<String>{territoryCalculation});
        }        
        return this;
    }

    /**
     * @param records account records from current batch's execution
     * @return  `VDT_TerritoryAnalysisBuilder`
     */
    public VDT_TerritoryAnalysisBuilder withRecords(List<Account> records) {
        this.accountIds.clear();
        this.records = records;
        for (Account account : records) {
            accountIds.add(account.Id);
        }
        return this;
    }

    public String build() {
        this.territoryAnalysisData.items = this.getTerritoryHierarchy();
        return JSON.serialize(this.territoryAnalysisData);
    }

    /**
     * @description aggregates the number of accounts assigned for a given territory segregated by account's specialty
     * @return  `VDT_TerritoryAnalysisBuilder`
     */
    public VDT_TerritoryAnalysisBuilder calculate() {
        Map<Id, Account> accountsById = new Map<Id, Account>(this.records);
        List<ObjectTerritory2Association> accountTerritoryAssignments = getTerritoryAssignmentForAccounts(this.accountIds);
        
        Set<String> territoryIds = getTerritoryIdsFromCurrentAssociations(accountTerritoryAssignments);
        
        Map<String, VDT_Transaction_Result__c> transactionResultsByTerritory = getTransactionResultsByTerritory(territoryIds);
        
        for (ObjectTerritory2Association accountTerritory : accountTerritoryAssignments) {
            Account account = accountsById.get(accountTerritory.ObjectId);
            String accountType = account.IsPersonAccount ? 'Person' : 'Business';
            String countryValue = this.getPropertyValue(account, this.countryField);
            if (String.isBlank(countryValue)) {
                countryValue = EMPTY_PLACEHOLDER;
            }
            String specialtyValue = this.getPropertyValue(account, this.specialtyField);
            if (String.isBlank(specialtyValue)) {
                specialtyValue = EMPTY_PLACEHOLDER;
            }
            this.territoryAnalysisData.specialties.add(specialtyValue);
            String key = accountTerritory.Territory2Id + DELIMITER_CHAR + countryValue + DELIMITER_CHAR + specialtyValue + DELIMITER_CHAR + accountType;
            
            VDT_Transaction_Result__c territoryTransaction = null;
            
            if (transactionResultsByTerritory.containsKey(key)) {
                territoryTransaction = transactionResultsByTerritory.get(key);
            } else {
                territoryTransaction = new VDT_Transaction_Result__c(
                    Territory_Id__c = accountTerritory.Territory2Id,
                    Country__c = countryValue,
                    Specialty__c = specialtyValue,
                    Account_Type__c = accountType,
                    Data_Calculation__c = this.dataCalculationId,
                    Total_Accounts__c = 0
                );                
            }
            territoryTransaction.Total_Accounts__c += 1;
            transactionResultsByTerritory.put(key, territoryTransaction);
            if (String.isNotBlank(accountTerritory.Territory2Id) && associationsByParentAccount.containsKey(accountTerritory.Territory2Id)) {
                Integer numOfAssociations = associationsByParentAccount.get(accountTerritory.Territory2Id) + 1;
                associationsByParentAccount.put(accountTerritory.Territory2Id, numOfAssociations);
            } else if (String.isNotBlank(accountTerritory.Territory2Id)) {
                associationsByParentAccount.put(accountTerritory.Territory2Id, 1);
            }
        }
        if (!transactionResultsByTerritory.isEmpty()) {
            upsert transactionResultsByTerritory.values();
        }
        return this;
    }

    /**
     * @description get all territory asignment records for the given accounts
     * @param accountIds set of ids being processed
     * @return  `List<ObjectTerritory2Association>`
     */
    private List<ObjectTerritory2Association> getTerritoryAssignmentForAccounts(Set<String> accountIds) {
        if (this.territoriesInCalculation.isEmpty()) {
            return [SELECT Id, Territory2Id, Territory2.Name, ObjectId, Territory2.ParentTerritory2Id FROM ObjectTerritory2Association WHERE ObjectId IN :accountIds];
        } else {
            return [SELECT Id, Territory2Id, Territory2.Name, ObjectId, Territory2.ParentTerritory2Id 
                        FROM ObjectTerritory2Association 
                        WHERE ObjectId IN :accountIds AND Territory2Id IN :this.territoriesInCalculation];
        }
        
    }

    private Set<String> getTerritoryIdsFromCurrentAssociations(List<ObjectTerritory2Association> associations) {
        Set<String> territoryIds = new Set<String>();
        for (ObjectTerritory2Association association : associations) {
            territoryIds.add('\'' + association.Territory2Id + '\'');
        }
        return territoryIds;
    }

    private Map<String, VDT_Transaction_Result__c> getTransactionResultsByTerritory(Set<String> territoryIds) {
        Map<String, VDT_Transaction_Result__c> transactionResultsByKey = new Map<String, VDT_Transaction_Result__c>();
        if (!territoryIds.isEmpty()) {
            List<RecordType> recordTypes = VDT_RecordTypeService.getRecordTypeByObjectAndName('VDT_Transaction_Result__c', VDT_TransactionResultService.TERRITORY_ANALYSIS_RECORD_TYPE_DEV);
            List<VDT_Transaction_Result__c> transactions = new VDT_TransactionResultSelector()
                .withAdditionalFields(new List<String> {
                    'Territory_Id__c',
                    'Country__c',
                    'Specialty__c',
                    'Account_Type__c',
                    'Total_Accounts__c'
                })
                .addWhereClauses(new List<String> {
                    'RecordTypeId = \'' + recordTypes.get(0).Id + '\'',
                    'Data_Calculation__c = \'' + this.dataCalculationId + '\'',
                    'Territory_Id__c IN (' + String.join(new List<String>(territoryIds), ',') + ')'
                })
                .query();
            for (VDT_Transaction_Result__c territoryTransaction : transactions) {
                String key = territoryTransaction.Territory_Id__c + DELIMITER_CHAR + territoryTransaction.Country__c + DELIMITER_CHAR + territoryTransaction.Specialty__c + DELIMITER_CHAR + territoryTransaction.Account_Type__c;
                transactionResultsByKey.put(key, territoryTransaction);
            }
        }
        return transactionResultsByKey;
    }

    private String getPropertyValue(Account account, String fieldName) {
        String value = '';
        if (fieldName.contains('.')) {
            String relationship = fieldName.split('\\.').get(0);
            String relatedField = fieldName.split('\\.').get(1);
            if (account.getSObject(relationship) != null) {
                value = account.getSObject(relationship).get(relatedField).toString();
            }
        } else {
            value = String.valueOf(account.get(fieldName));
        }
        return value;
    }

    public List<TerritoryItem> getTerritoryHierarchy() {        
        Map<String, List<Territory2>> territoriesByParent = new Map<String, List<Territory2>>();
        for (Territory2 territory : new VDT_Territory2Selector()
                                    .withAdditionalFields(new List<String>{'ParentTerritory2Id', 'DeveloperName'})
                                    .query()) {
            String parentId = String.isBlank(territory.ParentTerritory2Id) ? 'NULL' : territory.ParentTerritory2Id;
            if (territoriesByParent.containsKey(parentId)) {
                territoriesByParent.get(parentId).add(territory);
            } else {
                territoriesByParent.put(parentId, new List<Territory2> {territory});
            }
        }
        List<TerritoryItem> parentTerritories = addChildrenTerritories(territoriesByParent.get('NULL'), territoriesByParent);
        return parentTerritories;
    }

    private List<TerritoryItem> addChildrenTerritories(List<Territory2> parentTerritories, Map<String, List<Territory2>> territoriesByParent) {
        List<TerritoryItem> parentItems = new List<TerritoryItem>();
        for (Territory2 parentTerritory : parentTerritories) {
            TerritoryItem territoryItem = new TerritoryItem(parentTerritory.Id, parentTerritory.Name, parentTerritory.DeveloperName, this.associationsByParentAccount.get(parentTerritory.Id));
            if (territoriesByParent.containsKey(parentTerritory.Id)) {
                territoryItem.items = addChildrenTerritories(territoriesByParent.get(parentTerritory.Id), territoriesByParent);
            }
            parentItems.add(territoryItem);
        }
        return parentItems;
    }

    public class TerritoryAnalysisOutput {
        public Set<String> specialties = new Set<String>();
        public List<TerritoryItem> items = new List<TerritoryItem>();
        
    }

    public class TerritoryItem {

        @AuraEnabled
        public String id;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Boolean expanded = false;
        @AuraEnabled
        public Integer totalAccounts = 0;
        @AuraEnabled
        public List<TerritoryItem> items;

        public TerritoryItem(String id, String label, String name, Integer totalAccounts) {
            this.id = id;
            this.label = label;
            this.name = name;
            if (totalAccounts != null) {
                this.totalAccounts = totalAccounts;
            }
        }

    }
}