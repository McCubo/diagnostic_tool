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
    private TerritoryAnalysisOutput territoryAnalysisData = new TerritoryAnalysisOutput();
    private final String EMPTY_PLACEHOLDER = '<<EMPTY>>';
    private final String DELIMITER_CHAR = '_';

    public VDT_TerritoryAnalysisBuilder(String countryField, String specialtyField, String dataCalculationId) {
        this.countryField = countryField;
        this.specialtyField = specialtyField;
        this.dataCalculationId = dataCalculationId;
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
        return JSON.serialize(this.territoryAnalysisData);
    }

    /**
     * @description aggregates the number of accounts assigned for a given territory segregated by account's specialty
     * @return  `VDT_TerritoryAnalysisBuilder`
     */
    public VDT_TerritoryAnalysisBuilder calculate() {
        Map<Id, Account> accountsById = new Map<Id, Account>(this.records);
        List<ObjectTerritory2Association> accountTerritoryAssignments = getTerritoryAssignmentForAccounts(this.accountIds);
        System.debug('TEST:accountTerritoryAssignments: ' + accountTerritoryAssignments.size());
        Set<String> territoryIds = getTerritoryIdsFromCurrentAssociations(accountTerritoryAssignments);
        System.debug('TEST:territoryIds: ' + territoryIds.size());
        Map<String, VDT_Transaction_Result__c> transactionResultsByTerritory = getTransactionResultsByTerritory(territoryIds);
        System.debug('TEST:transactionResultsByTerritory: ' + transactionResultsByTerritory.size());
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
            System.debug('TEST:key: ' + key);
            VDT_Transaction_Result__c territoryTransaction = null;
            System.debug('TEST:transactionResultsByTerritory.containsKey(key): ' + transactionResultsByTerritory.containsKey(key));
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
        }
        upsert transactionResultsByTerritory.values();
        return this;
    }

    /**
     * @description get all territory asignment records for the given accounts
     * @param accountIds set of ids being processed
     * @return  `List<ObjectTerritory2Association>`
     */
    private List<ObjectTerritory2Association> getTerritoryAssignmentForAccounts(Set<String> accountIds) {
        return [SELECT Id, Territory2Id, Territory2.Name, ObjectId, Territory2.ParentTerritory2Id FROM ObjectTerritory2Association WHERE ObjectId IN :accountIds];
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

    public class TerritoryAnalysisOutput {
        public Set<String> specialties = new Set<String>();
    }
}
