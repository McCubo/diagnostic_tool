public with sharing class VDT_MasterAnalysisCalculationBuilder {

    private String countryField;
    private String specialtyField;
    private Date startDate;
    private Date endDate;
    private MasterAnalysisSummary analysisData = new MasterAnalysisSummary();
    private Map<String, List<String>> accountRecordTypesByType = null;
    Map<String, Decimal> targetByCountryAndKpi = new Map<String, Decimal>();
    private Set<String> specialties = new Set<String>();
    private List<Account> records = new List<Account>();
    private Set<Id> accountsWithTerritories = null;
    // Account Types
    private final String ACCOUNT_TYPE_EXTERNAL = 'External_Customers';
    private final String ACCOUNT_TYPE_INTERNAL = 'Internal_Customers';
    // KPI Names
    private final String ONEKEY_VS_NON_ONE_KEY_KPI_ID = 'Onekey_vs_Non_One_Key';
    private final String ONEKEY_ALIGNED_TO_TERRITORIES_KPI_ID = 'Onekey_aligned_to_territories';
    private final String ONEKEY_WITHOUT_VISIT_KPI_ID = 'Onekey_Without_visit';
    private final String ONEKEY_WITHOUT_RATINGS_KPI_ID = 'Onekey_Without_ratings';
    private final String ONEKEY_WITHOUT_CYCLE_PLAN_KPI_ID = 'Onekey_Without_cycle_plan';
    private final String ONEKEY_WITHOUT_VISIT_AND_CYCLE_PLAN_KPI_ID = 'OneKey_Without_Visit_and_Cycle_Plan';
    private final String ONEKEY_WITHOUT_ADDRESS = 'Onekey_without_address';
    private Set<String> accountIds = new Set<String>();
    private Map<String, Integer> addressByAccount = new Map<String, Integer>();
    private Map<String, Integer> metricsByAccount = new Map<String, Integer>();
    private Map<String, Integer> callsByAccount = new Map<String, Integer>();
    private Map<String, Integer> cyclePlanTargetsByAccount = new Map<String,Integer>();
    private Map<String, String> queriesByName = new Map<String, String>();
    // Query Names
    private final String ADDRESS_BY_ACCOUNT_QUERY = 'Addresses_By_Account';
    private final String PRODUCT_METRICS_BY_ACCOUNT_QUERY = 'Product_Metrics';
    private final String CALLS_BY_ACCOUNT_QUERY = 'Calls_By_Account';    
    private final String PLAN_TARGETS_BY_ACCOUNT_QUERY = 'Plan_Targets_By_Account';

    public VDT_MasterAnalysisCalculationBuilder(String countryField, String specialtyField, Date startDate, Date endDate) {
        this.countryField = countryField;
        this.specialtyField = specialtyField;
        this.startDate = startDate;
        this.endDate = endDate;
    }

    public VDT_MasterAnalysisCalculationBuilder withCustomQueries(Map<String, String> queriesByName) {
        this.queriesByName.putAll(queriesByName);
        return this;
    }

    public VDT_MasterAnalysisCalculationBuilder withValidOptions(List<VDT_OptionWrapper> activeSpecialties) {
        for (VDT_OptionWrapper specialty : activeSpecialties) {
            this.specialties.add(specialty.value);
        }
        return this;
    }

    public VDT_MasterAnalysisCalculationBuilder initKpis(List<VDT_KPI_Configuration__mdt> activeKpis) {
        for (VDT_KPI_Configuration__mdt kpi : activeKpis) {
            this.analysisData.kpi_numbers.put(kpi.DeveloperName, new KPISummary(
                Integer.valueOf(kpi.VDT_Display_Order__c), 
                kpi.Description__c, 
                kpi.VDT_Help_Text__c, 
                kpi.VDT_Formula_Text__c, 
                kpi.VDT_Type__c, 
                Integer.valueOf(kpi.VDT_Default_Target__c))
            );
        }
        return this;
    }

    public VDT_MasterAnalysisCalculationBuilder withRecordTypesByType(Map<String, List<String>> accountRecordTypesByType) {
        this.accountRecordTypesByType = accountRecordTypesByType;
        return this;
    }

    public VDT_MasterAnalysisCalculationBuilder withCustomTargets(Map<String, Decimal> targetByCountryAndKpi) {
        this.targetByCountryAndKpi = targetByCountryAndKpi;
        return this;
    }

    public VDT_MasterAnalysisCalculationBuilder withRecords(List<Account> records) {
        this.accountIds.clear();
        this.records = records;
        for (Account account : records) {
            accountIds.add(account.Id);
        }
        return this;
    }

    public VDT_MasterAnalysisCalculationBuilder withTerritories() {
        Set<Id> accountIds = (new Map<Id, Account>(this.records)).keySet();
        this.accountsWithTerritories = new Set<Id>();
        for (ObjectTerritory2Association territory : [SELECT ObjectId FROM ObjectTerritory2Association WHERE ObjectId IN :accountIds]) {
            this.accountsWithTerritories.add(territory.ObjectId);
        }
        return this;
    }

    public VDT_MasterAnalysisCalculationBuilder calculate() {
        this.addressByAccount = getAddressByAccount();
        this.metricsByAccount = getMetricsByAccount();
        this.callsByAccount = getCallsByAccount();
        this.cyclePlanTargetsByAccount = getCyclePlanTargetsByAccount();
        for (Account acc : records) {
            String country = this.getPropertyValue(acc, this.countryField);
            String specialty = this.getPropertyValue(acc, this.specialtyField);
            if (String.isEmpty(specialty)) {
                specialty = '<<Empty>>';
            }
            this.analysisData.recordTypes.add(acc.RecordType.DeveloperName);
            Boolean isExternal = accountRecordTypesByType.get(ACCOUNT_TYPE_EXTERNAL).contains(acc.RecordType.DeveloperName);            
            this.updateKpiForCountry(ONEKEY_VS_NON_ONE_KEY_KPI_ID, country, isExternal ? 1 : 0, 1);            
            if (isExternal) {
                Boolean hasAddress = this.addressByAccount.containsKey(acc.Id) && this.addressByAccount.get(acc.Id) > 0;
                this.updateKpiForCountry(ONEKEY_WITHOUT_ADDRESS, country, hasAddress ? 0 : 1, 1);
                Boolean hasVisits = this.callsByAccount.containsKey(acc.Id) && this.callsByAccount.get(acc.id) > 0;
                this.updateKpiForCountry(ONEKEY_WITHOUT_VISIT_KPI_ID, country, hasVisits ? 0 : 1, 1);
                Boolean hasCyclePlanTargets = this.cyclePlanTargetsByAccount.containsKey(acc.Id) && this.cyclePlanTargetsByAccount.get(acc.id) > 0;
                this.updateKpiForCountry(ONEKEY_WITHOUT_CYCLE_PLAN_KPI_ID, country, hasCyclePlanTargets ? 0 : 1, 1);
                Boolean hasVisitButNotTargets = hasVisits && !hasCyclePlanTargets;
                this.updateKpiForCountry(ONEKEY_WITHOUT_VISIT_AND_CYCLE_PLAN_KPI_ID, country, hasVisitButNotTargets ? 1 : 0, 1);
                Boolean hasRatings = this.metricsByAccount.containsKey(acc.Id) && this.metricsByAccount.get(acc.Id) > 0;
                this.updateKpiForCountry(ONEKEY_WITHOUT_RATINGS_KPI_ID, country, hasRatings ? 0 : 1, 1);
                Integer territory = this.accountsWithTerritories.contains(acc.Id) ? 1 : 0;
                this.updateKpiForCountry(ONEKEY_ALIGNED_TO_TERRITORIES_KPI_ID, country, territory, 1);
            }
            if (this.analysisData.calculations.containsKey(specialty)) {
                SpecialtySummary specialtySummary = this.analysisData.calculations.get(specialty);
                if (specialtySummary.recordTypeUsageSummary.containsKey(acc.RecordType.DeveloperName)) {
                    RecordTypeUsageSummary recordTypeSummary = specialtySummary.recordTypeUsageSummary.get(acc.RecordType.DeveloperName);
                    if (recordTypeSummary.countryUsageSummary.containsKey(country)) {
                        CountryUsageSummary countrySummary = recordTypeSummary.countryUsageSummary.get(country);
                        updateCountrySummary(acc, countrySummary);
                    } else {
                        CountryUsageSummary countrySummary = updateCountrySummary(acc, new CountryUsageSummary());
                        recordTypeSummary.countryUsageSummary.put(country, countrySummary);
                    }
                } else {
                    RecordTypeUsageSummary recordTypeSummary = new RecordTypeUsageSummary();
                    recordTypeSummary.name = acc.RecordType.DeveloperName;
                    CountryUsageSummary countrySummary = updateCountrySummary(acc, new CountryUsageSummary());
                    recordTypeSummary.countryUsageSummary.put(country, countrySummary);
                    specialtySummary.recordTypeUsageSummary.put(acc.RecordType.DeveloperName, recordTypeSummary);
                }
            } else {
                SpecialtySummary specialtySummary = new SpecialtySummary(specialty, this.specialties.contains(specialty));
                RecordTypeUsageSummary recordTypeSummary = new RecordTypeUsageSummary();
                recordTypeSummary.name = acc.RecordType.DeveloperName;
                CountryUsageSummary countrySummary = updateCountrySummary(acc, new CountryUsageSummary());
                recordTypeSummary.countryUsageSummary.put(country, countrySummary);
                specialtySummary.recordTypeUsageSummary.put(acc.RecordType.DeveloperName, recordTypeSummary);
                this.analysisData.calculations.put(specialty, specialtySummary);
                this.analysisData.specialties.add(specialty);
            }
        }
        return this;
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

    private Map<String, Integer> getAddressByAccount() {
        Map<String, Integer> addressByAccount = new Map<String, Integer>();
        String query = String.format(this.queriesByName.get(ADDRESS_BY_ACCOUNT_QUERY), new List<String>());
        return this.getStatsByAccount(query);
    }

    private Map<String, Integer> getMetricsByAccount() {        
        String query = String.format(this.queriesByName.get(PRODUCT_METRICS_BY_ACCOUNT_QUERY), new List<String>());
        return this.getStatsByAccount(query);
    }

    private Map<String, Integer> getCallsByAccount() {        
        String query = String.format(this.queriesByName.get(CALLS_BY_ACCOUNT_QUERY), new List<String>());
        return this.getStatsByAccount(query);
    }

    private Map<String, Integer> getCyclePlanTargetsByAccount() {        
        String query = String.format(this.queriesByName.get(PLAN_TARGETS_BY_ACCOUNT_QUERY), new List<String>());
        return this.getStatsByAccount(query);
    }

    private Map<String,Integer> getStatsByAccount(String query) {
        Map<String, Integer> statsByAccount = new Map<String, Integer>();
        AggregateResult[] statsCount = (AggregateResult[]) Database.query(query);
        for (AggregateResult stat : statsCount)  {
            String accountId = stat.get('accountId').toString();
            Integer counter = Integer.valueOf(stat.get('counter'));
            statsByAccount.put(accountId, counter);
        }
        return statsByAccount;
    }

    public MasterAnalysisSummary build() {
        return this.analysisData;
    }

    private void updateKpiForCountry(String kpiKey, String country, Integer numerator, Integer denominator) {
        if (this.analysisData.kpi_numbers.containsKey(kpiKey)) {
            KPISummary kpiSummary = this.analysisData.kpi_numbers.get(kpiKey);
            KPICountryUsage countryUsage = new KPICountryUsage();
            if (kpiSummary.countryUsageSummary.containsKey(country)) {
                countryUsage = kpiSummary.countryUsageSummary.get(country);
            } else {
                String key = country + '_' + kpiKey;
                if (this.targetByCountryAndKpi.containsKey(key)) {
                    countryUsage.target = Integer.valueOf(this.targetByCountryAndKpi.get(key));
                }
            }
            countryUsage.numerator += numerator;
            countryUsage.denominator += denominator;
            kpiSummary.countryUsageSummary.put(country, countryUsage);
        }
    }

    private CountryUsageSummary updateCountrySummary(Account account, CountryUsageSummary countrySummary) {
        countrySummary.totalAccounts += 1;
        Boolean hasVisits = this.callsByAccount.containsKey(account.Id) && this.callsByAccount.get(account.Id) > 0;
        countrySummary.visitedCalled += hasVisits ? 1 : 0;
        Boolean hasCyclePlan = this.cyclePlanTargetsByAccount.containsKey(account.Id) && this.cyclePlanTargetsByAccount.get(account.Id) > 0;
        countrySummary.partCyclePlan += hasCyclePlan ? 1 : 0;
        countrySummary.notInProductMetrics += this.metricsByAccount.containsKey(account.Id) && this.metricsByAccount.get(account.id) > 0 ? 0 : 1;
        countrySummary.noAddress += this.addressByAccount.containsKey(account.Id) && this.addressByAccount.get(account.Id) > 0 ? 0 : 1;
        countrySummary.notPartOfCyclePlan += hasVisits  && !hasCyclePlan ? 1 : 0;
        countrySummary.notAlignedToTerritories += this.accountsWithTerritories.contains(account.Id) ? 0 : 1;
        return countrySummary;
    }

    public class MasterAnalysisSummary {

        public Map<String, SpecialtySummary> calculations = new Map<String, SpecialtySummary>();

        public Set<String> specialties = new Set<String>();

        public Set<String> recordTypes = new Set<String>();

        public Map<String, KPISummary> kpi_numbers = new Map<String, KPISummary>();
        
    }

    public class KPISummary {

        public KPISummary(Integer id, String name, String help, String formula, String type, Integer default_target) {
            this.id =id;
            this.name = name;
            this.help = help;
            this.formula = formula;
            this.type = type;
            this.default_target = default_target;
        }

        public Integer id;
        public String name;
        public String help;
        public String formula;
        public String type;
        public Integer default_target;
        public Map<String, KPICountryUsage> countryUsageSummary = new Map<String, KPICountryUsage>();
        
    }

    public class KPICountryUsage {

        public Integer numerator = 0;
        public Integer denominator = 0;
        public Integer target;

    }

    public class SpecialtySummary {

        public SpecialtySummary(String specialty, Boolean isActive) {
            this.id = specialty;
            this.specialty = specialty;
            this.isActive = isActive;
        }

        public String id;

        public String specialty;

        public Boolean isActive = true;

        public Map<String, RecordTypeUsageSummary> recordTypeUsageSummary = new Map<String, RecordTypeUsageSummary>();

    }

    public class RecordTypeUsageSummary {
        
        public String name;

        public Map<String, CountryUsageSummary> countryUsageSummary = new Map<String, CountryUsageSummary>();

    }

    public class CountryUsageSummary {

        public Integer totalAccounts = 0;

        public Integer visitedCalled = 0;

        public Integer partCyclePlan = 0;

        public Decimal notPartOfCyclePlan = 0;

        public Decimal notInProductMetrics = 0;

        public Decimal noAddress = 0;

        public Decimal notAlignedToTerritories = 0;

    }

}