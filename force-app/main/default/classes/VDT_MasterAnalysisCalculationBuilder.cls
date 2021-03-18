public with sharing class VDT_MasterAnalysisCalculationBuilder {

    private String countryField;
    private String specialtyField;
    private MasterAnalysisSummary analysisData = new MasterAnalysisSummary();
    private List<Account> records = new List<Account>();

    public VDT_MasterAnalysisCalculationBuilder(String countryField, String specialtyField) {
        this.countryField = countryField;
        this.specialtyField = specialtyField;
    }

    public VDT_MasterAnalysisCalculationBuilder withRecords(List<Account> records) {
        this.records = records;
        return this;
    }

    public VDT_MasterAnalysisCalculationBuilder calculate() {
        for (Account acc : records) {
            String country = acc.get(this.countryField).toString();
            String specialty = acc.get(this.specialtyField).toString();
            if (analysisData.calculations.containsKey(specialty)) {
                SpecialtySummary specialtySummary = analysisData.calculations.get(specialty);
                specialtySummary.totalAccounts += 1;
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
                SpecialtySummary specialtySummary = new SpecialtySummary('1', specialty);
                RecordTypeUsageSummary recordTypeSummary = new RecordTypeUsageSummary();
                recordTypeSummary.name = acc.RecordType.Name;
                CountryUsageSummary countrySummary = updateCountrySummary(acc, new CountryUsageSummary());
                recordTypeSummary.countryUsageSummary.put(country, countrySummary);
                specialtySummary.recordTypeUsageSummary.put(acc.RecordType.Name, recordTypeSummary);
                analysisData.calculations.put(specialty, specialtySummary);
                analysisData.specialties.add(specialty);
            }
        }
        return this;
    }

    public MasterAnalysisSummary build() {
        return this.analysisData;
    }

    private CountryUsageSummary updateCountrySummary(Account account, CountryUsageSummary countrySummary) {
        countrySummary.visitedCalled += account.Call2_vod__r.isEmpty() ? 0 : 1;
        countrySummary.partCyclePlan += account.MC_Cycle_Plan_Targets_vod__r.isEmpty() ? 0 : 1;
        countrySummary.notInProductMetrics += account.Product_Metrics_vod__r.isEmpty() ? 1 : 0;
        countrySummary.noAddress += account.Address_vod__r.isEmpty() ? 1 : 0;
        countrySummary.notPartOfCyclePlan += !account.Call2_vod__r.isEmpty() && account.MC_Cycle_Plan_Targets_vod__r.isEmpty() ? 1 : 0;
        return countrySummary;
    }

    public class MasterAnalysisSummary {

        public Map<String, SpecialtySummary> calculations = new Map<String, SpecialtySummary>();

        public Set<String> specialties = new Set<String>();
        
    }

    public class SpecialtySummary {

        public SpecialtySummary(String id, String specialty) {
            this.id = id;
            this.specialty = specialty;
            this.totalAccounts = 1;
        }

        public String id;

        public String specialty;

        public Integer totalAccounts = 0;

        public Boolean isActive = true;

        public Map<String, RecordTypeUsageSummary> recordTypeUsageSummary = new Map<String, RecordTypeUsageSummary>();

    }

    public class RecordTypeUsageSummary {
        
        public String name;

        public Map<String, CountryUsageSummary> countryUsageSummary = new Map<String, CountryUsageSummary>();

    }

    public class CountryUsageSummary {

        public Integer visitedCalled = 0;

        public Integer partCyclePlan = 0;

        public Decimal notPartOfCyclePlan = 0;

        public Decimal notInProductMetrics = 0;

        public Decimal noAddress = 0;

        public Decimal notAlignedToTerritories = 0;

    }
}
