/**
 * @description Apex Controller to expose Apex Methods to javascript LWC controllers
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_AnalysisDashboardFilterController {

    /**
     * @return  `String` with Standard Field Identifier
     * @exception AuraHandledException
     */
    @AuraEnabled(cacheable=true)
    public static String getStandardFieldIdentifier() {
        try {
            return VDT_CustomMetadataService.getStandardFieldIdentifier();
        } catch (Exception e) { 
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
}