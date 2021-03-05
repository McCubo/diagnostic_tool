public inherited sharing class VDT_OptionWrapper {
    @AuraEnabled public String label;
    @AuraEnabled public String value;

    public VDT_OptionWrapper(String label, String value) {
        this.label = label;
        this.value = value;
    }
}
