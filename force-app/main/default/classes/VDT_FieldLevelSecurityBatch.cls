/**
 * @description This Batch job queries the `FieldPermissions` SObject for all the SObjects selected from the `SObject Name` picklist option on the 
 *              Field Level Security Analysis screen.
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_FieldLevelSecurityBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    private VDT_Data_Calculation__c flsDataCalculation;
    private VDT_FieldLevelSecurityBuilder builder;
    private final String DELIMITER_CHARACTER = ',';

    public VDT_FieldLevelSecurityBatch(VDT_Data_Calculation__c flsDataCalculation) {
        this.flsDataCalculation = flsDataCalculation;
    }

    /**
     * @description Builds the query based on the List of SOBjects the user selects on the Picklist component on Field Level Security Analysis screen.
     *              Creates a new instance of the `VDT_FieldLevelSecurityBuilder` class and calls its `withPageLayoutBehaviors` method
     * @param bc 
     * @return  `Database.QueryLocator`
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> sobjects = this.flsDataCalculation.VDT_Object_Name__c.split(DELIMITER_CHARACTER);
        String query = 'SELECT Id, ParentId, Parent.Name, Parent.Profile.Name, SobjectType, Field, PermissionsEdit, PermissionsRead' 
                    + ' FROM FieldPermissions'
                    + ' WHERE SobjectType IN :sobjects';
        this.flsDataCalculation.VDT_Job_Start_Date__c = Datetime.now();
        this.flsDataCalculation.Batches_Number__c = 0;
        this.builder = new VDT_FieldLevelSecurityBuilder().withPageLayoutBehaviors(sobjects);
        update this.flsDataCalculation;
        return Database.getQueryLocator(query);
    }

    /**
     * @description For each set of records, we call the builder's method, It uses an internal variable to keep track of all records
     * @param bc 
     * @param fieldPermissions records to be proccessed in the current execute method
     */
    public void execute(Database.BatchableContext bc, List<FieldPermissions> fieldPermissions) {
        this.flsDataCalculation.Batches_Number__c += 1;
        this.builder.withRecords(fieldPermissions).withObjectPermissions().calculate();
        update this.flsDataCalculation;
    }

    /**
     * @description Once all batches are completed, the VDT_Data_Calculation__c record status is updated to COMPLETED,
     *              Creates a new attachment record and links it to the VDT_Data_Calculation__c record, lastly,
     *              a new Email alert is sent letting the user who triggered the job know the job has been completed.
     * @param bc 
     */
    public void finish(Database.BatchableContext bc) {
        try {
            this.flsDataCalculation.VDT_Job_End_Date__c = Datetime.now();
            this.flsDataCalculation.Status__c = VDT_DataCalculationService.STATUS_COMPLETED;
            this.flsDataCalculation.VDT_Calculation_Date__c = Date.today();

            update this.flsDataCalculation;

            VDT_AttachmentService.createAttachmentForRecord(
                this.builder.build(),
                VDT_ObjectService.FIELD_LEVEL_SECURITY_ANALYSIS_FILE_NAME,
                VDT_AttachmentService.JSON_FORMAT,
                this.flsDataCalculation.Id
            );            
            VDT_EmailService.sendFLSAnalysisFinishedEmailNotification(this.flsDataCalculation.VDT_Object_Name__c);
        } catch (Exception e) {
            VDT_Log.get().add(e.getMessage() + '\n' + e.getStackTraceString(), VDT_LogSeverity.ERROR);
            VDT_Log.get().publish();
            VDT_DataCalculationService.sendStatusUpdateEvent(this.flsDataCalculation.Id, VDT_DataCalculationService.STATUS_ERROR);            
            throw e;
        }
    }
}
