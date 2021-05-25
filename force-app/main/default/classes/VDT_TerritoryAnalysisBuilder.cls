/**
 * @description Apex builder class used to aggregate data based on territory and account specialty
 * @author BASE Life Science
 * @since 2021.03.01
 */
public with sharing class VDT_TerritoryAnalysisBuilder {

    private String countryField;
    private String specialtyField;
    private Set<String> accountIds = new Set<String>();
    private List<Account> records = new List<Account>();
    private TerritoryAnalysisOutput territoryAnalysisData = new TerritoryAnalysisOutput();
    private final String EMPTY_PLACEHOLDER = '<<EMPTY>>';

    public VDT_TerritoryAnalysisBuilder(String countryField, String specialtyField) {
        this.countryField = countryField;
        this.specialtyField = specialtyField;
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
        for (Territory2 territory : [SELECT Id, Name, ParentTerritory2Id FROM Territory2]) {
            if (!this.territoryAnalysisData.territoryAnalysis.containsKey(territory.Id)) {
                TerritoryAnalysis territoryAnalysis = new TerritoryAnalysis(territory.Name, territory.Id, territory.ParentTerritory2Id);
                this.territoryAnalysisData.territoryAnalysis.put(territory.Id, territoryAnalysis);
            }
        }
        return JSON.serialize(this.territoryAnalysisData);
    }

    /**
     * @description aggregates the number of accounts assigned for a given territory segregated by account's specialty
     * @return  `VDT_TerritoryAnalysisBuilder`
     */
    public VDT_TerritoryAnalysisBuilder calculate() {
        Map<Id, Account> accountsById = new Map<Id, Account>(this.records);
        List<ObjectTerritory2Association> accountTerritoryAssignments = getTerritoryAssignmentForAccounts(this.accountIds);
        for (ObjectTerritory2Association accountTerritory : accountTerritoryAssignments) {
            Account account = accountsById.get(accountTerritory.ObjectId);
            TerritoryAnalysis territoryAnalysis = getTerritoryById(accountTerritory);
            String countryValue = this.getPropertyValue(account, this.countryField);
            if (String.isBlank(countryValue)) {
                countryValue = EMPTY_PLACEHOLDER;
            }
            String specialtyValue = this.getPropertyValue(account, this.specialtyField);
            if (String.isBlank(specialtyValue)) {
                specialtyValue = EMPTY_PLACEHOLDER;
            }
            this.territoryAnalysisData.specialties.add(specialtyValue);
            Map<String, Map<String, Integer>> countrySummaryMap = null;
            if (account.IsPersonAccount) {
                countrySummaryMap = territoryAnalysis.personCountrySummary;
            } else {
                countrySummaryMap = territoryAnalysis.businessCountrySummary;
            }
            if (countrySummaryMap.containsKey(countryValue)) {
                Map<String, Integer> specialties = countrySummaryMap.get(countryValue);
                if (specialties.containsKey(specialtyValue)) {
                    specialties.put(specialtyValue, specialties.get(specialtyValue) + 1);
                } else {
                    specialties.put(specialtyValue, 1);
                }
            } else {
                Map<String, Integer> specialties = new Map<String, Integer>();
                specialties.put(specialtyValue, 1);
                countrySummaryMap.put(countryValue, specialties);
            }
        }
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

    private TerritoryAnalysis getTerritoryById(ObjectTerritory2Association accountTerritory) {
        TerritoryAnalysis territoryAnalysis = null;
        if (this.territoryAnalysisData.territoryAnalysis.containsKey(accountTerritory.Territory2Id)) {
            territoryAnalysis = this.territoryAnalysisData.territoryAnalysis.get(accountTerritory.Territory2Id);
        } else {
            territoryAnalysis = new TerritoryAnalysis(accountTerritory.Territory2.Name, accountTerritory.Territory2Id, accountTerritory.Territory2.ParentTerritory2Id);
            this.territoryAnalysisData.territoryAnalysis.put(accountTerritory.Territory2Id, territoryAnalysis);
        }
        return territoryAnalysis;
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
        public Map<String, TerritoryAnalysis> territoryAnalysis = new Map<String, TerritoryAnalysis>();
        public Set<String> specialties = new Set<String>();
    }

    public class TerritoryAnalysis {

        public String name;
        public String id;
        public String parentId;

        public TerritoryAnalysis(String name, String id, String parentId) {
            this.name = name;
            this.id = id;
            this.parentId = parentId;
        }

        public Map<String, Map<String, Integer>> businessCountrySummary = new Map<String, Map<String, Integer>>();
        public Map<String, Map<String, Integer>> personCountrySummary = new Map<String, Map<String, Integer>>();

    }
}
