/**
 * @description Plain Object used to populate the select LWC component
 * @author BASE Life Science
 * @since 2021.03.01
 */

public inherited sharing class VDT_OptionWrapper {
    @AuraEnabled public String label;
    @AuraEnabled public String value;
    @AuraEnabled public String secondaryLabel;

    public VDT_OptionWrapper(String label, String value) {
        this.label = label;
        this.value = value;
    }

    public void setSecondaryLabel(String secondaryLabel) {
        this.secondaryLabel = secondaryLabel;
    }

}