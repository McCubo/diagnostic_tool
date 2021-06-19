/**
 * @description Provides Access to Apex Service Methods
 * @author BASE Life Science
 * @since 2021.03.01
 */
public with sharing class VDT_FieldLevelSecurityController {

    /**
     * @return  `List<VDT_OptionWrapper>` List of SOBject options the user has access to 
     */
    @AuraEnabled(cacheable=true)
    public static List<VDT_OptionWrapper> fetchObjectOptions(){
        List<VDT_OptionWrapper> objecOptions = new List<VDT_OptionWrapper>();

        for(Schema.SObjectType objType : VDT_ObjectService.getAllAccessibleObjects()) {
            objecOptions.add(new VDT_OptionWrapper(objType.getDescribe().getLabel(), objType.getDescribe().getName()));
        }

        return objecOptions;
    }

    /**
     * 
     * @param jsonSearchParameters Search parameters selected by the User on the Field Level Security Analysis screen
     * @return  `VDT_DataCalculationService.DataCalculation` record with all information about the calculation job: Status, Completion Date and Output data generated
     * @exception AuraHandledException
     */
    @AuraEnabled
    public static VDT_DataCalculationService.DataCalculation searchExistingCalculations(String jsonSearchParameters) {
        try {
            VDT_DataCalculationService.FieldLevelSecurityParameter calculationParameters = (VDT_DataCalculationService.FieldLevelSecurityParameter)JSON.deserialize(
                jsonSearchParameters, 
                VDT_DataCalculationService.FieldLevelSecurityParameter.class
                );
            return VDT_DataCalculationService.getExistingFieldLevelSecurityAnalysisCalculation(calculationParameters);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description If the queue has availability, a new job is triggered for the selected jobs.
     * @param jsonSearchParameters Search parameters selected by the User on the Field Level Security Analysis screen
     * @exception AuraHandledException
     */
    @AuraEnabled
    public static void recalculateFieldLevelSecurityAnalysis(String jsonSearchParameters) {
        try {
            VDT_DataCalculationService.FieldLevelSecurityParameter calculationParameters = (VDT_DataCalculationService.FieldLevelSecurityParameter)JSON.deserialize(
                jsonSearchParameters, 
                VDT_DataCalculationService.FieldLevelSecurityParameter.class
            );
            VDT_DataCalculationService.triggerFieldLevelSecurityAnalysisCalculation(calculationParameters);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @return  `List<VDT_OptionWrapper>` They contain all information about both profiles and permission sets: label, value and secondary label.
     * @exception AuraHandledException
     */
    @AuraEnabled
    public static List<VDT_OptionWrapper> getProfilesAndPermissionSets() {
        try {
            return VDT_PermissionSetService.getPermissionSets();
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static VDT_DataCalculationService.DataCalculation searchExistingProfilePermissionSetCalculations(String jsonSearchParameters) {
        try {
            VDT_DataCalculationService.FieldLevelSecurityParameter calculationParameters = (VDT_DataCalculationService.FieldLevelSecurityParameter)JSON.deserialize(
                jsonSearchParameters, 
                VDT_DataCalculationService.FieldLevelSecurityParameter.class
                );
            return VDT_DataCalculationService.getExistingProfileAndPermissionAnalysisCalculation(calculationParameters);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<VDT_DataCalculationService.DataCalculationLog> fetchFinishedCalculations() {
        try {
            return VDT_DataCalculationService.getFinishedCalculationsWithDetailsByRecordType(
                VDT_DataCalculationSelector.FIELD_LEVEL_SECURITY_RECORD_TYPE_DEV, 
                new List<String>{
                    'Permission_Set_Profile_Name__c', 'VDT_Job_Start_Date__c', 'VDT_Job_End_Date__c', 'CreatedBy.Name'
                });
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void recalculateFlsAndObjectPermissionAnalysis(String jsonSearchParameters) {
        try {
            VDT_DataCalculationService.FieldLevelSecurityParameter calculationParameters = (VDT_DataCalculationService.FieldLevelSecurityParameter)JSON.deserialize(
                jsonSearchParameters, 
                VDT_DataCalculationService.FieldLevelSecurityParameter.class
                );
            VDT_DataCalculationService.triggerFlsAndObjectAnalysisCalculation(calculationParameters);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

}