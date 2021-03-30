public with sharing class VDT_MasterAnalysisCalculationBuilder {

    private String countryField;
    private String specialtyField;
    private MasterAnalysisSummary analysisData = new MasterAnalysisSummary();
    private Map<String, List<String>> accountRecordTypesByType = null;
    Map<String, Decimal> targetByCountryAndKpi = new Map<String, Decimal>();
    private Set<String> specialties = new Set<String>();
    private List<Account> records = new List<Account>();
    private Set<Id> accountsWithTerritories = null;
    private final String ACCOUNT_TYPE_EXTERNAL = 'External_Customers';
    private final String ACCOUNT_TYPE_INTERNAL = 'Internal_Customers';
    private final String ONEKEY_VS_NON_ONE_KEY_KPI_ID = 'Onekey_vs_Non_One_Key';
    private final String ONEKEY_ALIGNED_TO_TERRITORIES_KPI_ID = 'Onekey_aligned_to_territories';
    private final String ONEKEY_WITHOUT_VISIT_KPI_ID = 'Onekey_Without_visit';
    private final String ONEKEY_WITHOUT_RATINGS_KPI_ID = 'Onekey_Without_ratings';
    private final String ONEKEY_WITHOUT_CYCLE_PLAN_KPI_ID = 'Onekey_Without_cycle_plan';
    private final String ONEKEY_WITHOUT_VISIT_AND_CYCLE_PLAN_KPI_ID = 'OneKey_Without_Visit_and_Cycle_Plan';
    private final String ONEKEY_WITHOUT_ADDRESS = 'Onekey_without_address';
    

    public VDT_MasterAnalysisCalculationBuilder(String countryField, String specialtyField) {
        this.countryField = countryField;
        this.specialtyField = specialtyField;
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
        this.records = records;
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
        for (Account acc : records) {
            String country = null;
            if (this.countryField.contains('.')) {
                String relationship = this.countryField.split('\\.').get(0);
                String relatedField = this.countryField.split('\\.').get(1);
                country = acc.getSObject(relationship).get(relatedField).toString();
            } else {
                country = acc.get(this.countryField).toString();
            }
            String specialty = acc.get(this.specialtyField).toString();
            this.analysisData.recordTypes.add(acc.RecordType.Name);
            Boolean isExternal = accountRecordTypesByType.get(ACCOUNT_TYPE_EXTERNAL).contains(acc.RecordType.Name);            
            this.updateKpiForCountry(ONEKEY_VS_NON_ONE_KEY_KPI_ID, country, isExternal ? 1 : 0, 1);            
            if (isExternal) {
                Boolean hasNoAddress = acc.Address_vod__r.isEmpty();
                this.updateKpiForCountry(ONEKEY_WITHOUT_ADDRESS, country, hasNoAddress ? 1 : 0, 1);
                Boolean hasNoVisits = acc.Call2_vod__r.isEmpty();
                this.updateKpiForCountry(ONEKEY_WITHOUT_VISIT_KPI_ID, country, hasNoVisits ? 1 : 0, 1);
                Boolean hasNoCyclePlanTargets = acc.MC_Cycle_Plan_Targets_vod__r.isEmpty();
                this.updateKpiForCountry(ONEKEY_WITHOUT_CYCLE_PLAN_KPI_ID, country, hasNoCyclePlanTargets ? 1 : 0, 1);
                Boolean hasNoVisitNorTargets = acc.Call2_vod__r.isEmpty() && acc.MC_Cycle_Plan_Targets_vod__r.isEmpty();
                this.updateKpiForCountry(ONEKEY_WITHOUT_VISIT_AND_CYCLE_PLAN_KPI_ID, country, hasNoVisitNorTargets ? 1 : 0, 1);
                Boolean hasNoRatings = acc.Product_Metrics_vod__r.isEmpty();
                this.updateKpiForCountry(ONEKEY_WITHOUT_RATINGS_KPI_ID, country, hasNoRatings ? 1 : 0, 1);
                Integer territory = this.accountsWithTerritories.contains(acc.Id) ? 1 : 0;
                this.updateKpiForCountry(ONEKEY_ALIGNED_TO_TERRITORIES_KPI_ID, country, territory, 1);
            }
            if (this.analysisData.calculations.containsKey(specialty)) {
                SpecialtySummary specialtySummary = this.analysisData.calculations.get(specialty);
                if (specialtySummary.recordTypeUsageSummary.containsKey(acc.RecordType.Name)) {
                    RecordTypeUsageSummary recordTypeSummary = specialtySummary.recordTypeUsageSummary.get(acc.RecordType.Name);
                    if (recordTypeSummary.countryUsageSummary.containsKey(country)) {
                        CountryUsageSummary countrySummary = recordTypeSummary.countryUsageSummary.get(country);
                        updateCountrySummary(acc, countrySummary);
                    } else {
                        CountryUsageSummary countrySummary = updateCountrySummary(acc, new CountryUsageSummary());
                        recordTypeSummary.countryUsageSummary.put(country, countrySummary);
                    }
                } else {
                    RecordTypeUsageSummary recordTypeSummary = new RecordTypeUsageSummary();
                    recordTypeSummary.name = acc.RecordType.Name;
                    CountryUsageSummary countrySummary = updateCountrySummary(acc, new CountryUsageSummary());
                    recordTypeSummary.countryUsageSummary.put(country, countrySummary);
                    specialtySummary.recordTypeUsageSummary.put(acc.RecordType.Name, recordTypeSummary);
                }
            } else {
                SpecialtySummary specialtySummary = new SpecialtySummary(specialty, this.specialties.contains(specialty));
                RecordTypeUsageSummary recordTypeSummary = new RecordTypeUsageSummary();
                recordTypeSummary.name = acc.RecordType.Name;
                CountryUsageSummary countrySummary = updateCountrySummary(acc, new CountryUsageSummary());
                recordTypeSummary.countryUsageSummary.put(country, countrySummary);
                specialtySummary.recordTypeUsageSummary.put(acc.RecordType.Name, recordTypeSummary);
                this.analysisData.calculations.put(specialty, specialtySummary);
                this.analysisData.specialties.add(specialty);
            }
        }
        return this;
    }

    public VDT_MasterAnalysisCalculationBuilder calculateKpiInformation() {
        return this;
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
        countrySummary.visitedCalled += account.Call2_vod__r.isEmpty() ? 0 : 1;
        countrySummary.partCyclePlan += account.MC_Cycle_Plan_Targets_vod__r.isEmpty() ? 0 : 1;
        countrySummary.notInProductMetrics += account.Product_Metrics_vod__r.isEmpty() ? 1 : 0;
        countrySummary.noAddress += account.Address_vod__r.isEmpty() ? 1 : 0;
        countrySummary.notPartOfCyclePlan += !account.Call2_vod__r.isEmpty() && account.MC_Cycle_Plan_Targets_vod__r.isEmpty() ? 1 : 0;
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