/**
 * @description Provides Access to Apex Service Methods
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_PermissionSetAnalysisBuilder {

    private VDT_Data_Calculation__c permissionSetCalculation;
    private Set<String> permissionSetIds = new Set<String>();
    private final String DELIMITER = ',';

    public VDT_PermissionSetAnalysisBuilder(VDT_Data_Calculation__c permissionSetCalculation) {
        this.permissionSetCalculation = permissionSetCalculation;
        this.setPermissionSetIds();
    }

    public void setPermissionSetIds() {
        List<String> permissionSetNames = this.permissionSetCalculation.Permission_Set_Profile_Name__c.split(DELIMITER);
        List<PermissionSet> fieldPermissionSets = [SELECT Id, Profile.Name, Name, Label 
                                                    FROM PermissionSet 
                                                    WHERE Profile.Name IN :permissionSetNames OR Name IN :permissionSetNames];
        this.permissionSetIds = new Set<String>(new Map<String, PermissionSet>(fieldPermissionSets).keySet());
    }

    public void calculateSObject() {
        List<ObjectPermission> calculations = new List<ObjectPermission>();
        Map<String, String> permissionSetTabSetting = getPermissionSetTabSetting();
        for (ObjectPermissions op : [SELECT ParentId, Parent.Label, Parent.Name, Parent.Profile.Name, SobjectType, PermissionsCreate, PermissionsRead, PermissionsEdit, PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords 
                        FROM ObjectPermissions 
                        WHERE ParentId IN :permissionSetIds]) {
            String tabVisibility = permissionSetTabSetting.get(op.ParentId + '_' + op.SobjectType);
            calculations.add(new ObjectPermission(op, tabVisibility));
        }
        VDT_AttachmentService.createAttachmentForRecord(
            JSON.serialize(calculations), 
            VDT_DataCalculationService.OBJECT_PROFILE_PERMISSIONS_FILE_NAME,
            VDT_AttachmentService.JSON_FORMAT,
            this.permissionSetCalculation.Id
        );
    }

    private Map<String, String> getPermissionSetTabSetting() {
        Map<String, String> permissionSetTabSetting = new Map<String, String>();
        for (PermissionSetTabSetting tabSetting: [SELECT ParentId, Name, Visibility FROM PermissionSetTabSetting WHERE ParentId IN :permissionSetIds]) {
            String key = tabSetting.ParentId + '_' + tabSetting.Name.replace('standard-', '');
            permissionSetTabSetting.put(key, tabSetting.Visibility);
        }
        return permissionSetTabSetting;
    }

    public void calculateFLS() {
        List<FieldLevelSecurity> calculations = new List<FieldLevelSecurity>();

        for (FieldPermissions fp : [SELECT Parent.Label, Parent.Name, Parent.Profile.Name, SobjectType, Field, PermissionsEdit, PermissionsRead 
                                        FROM FieldPermissions 
                                        WHERE ParentId IN :permissionSetIds]) {
            calculations.add(new FieldLevelSecurity(fp));
        }
        VDT_AttachmentService.createAttachmentForRecord(
            JSON.serialize(calculations), 
            VDT_DataCalculationService.FIELD_LEVEL_SECURITY_FILE_NAME,
            VDT_AttachmentService.JSON_FORMAT,
            this.permissionSetCalculation.Id
        );
    }

    public class ObjectPermission {

        private String permissionsetAPIName;
        private String permissionsetName;
        private String objectAPIName;
        private String objectName;
        private String sobjectType;
        private String tabVisibility;
        private Boolean isReadEnabled;
        private Boolean isCreateEnabled;
        private Boolean isEditEnabled;
        private Boolean isDeleteEnabled;
        private Boolean isViewAllEnabled;
        private Boolean isModifyAllEnabled;

        public ObjectPermission(ObjectPermissions op, String tabVisibility) {
            if (String.isNotBlank(op.Parent.Profile.Name)) {
                this.permissionsetAPIName = op.Parent.Profile.Name;
                this.permissionsetName = '[PF]' + op.Parent.Profile.Name;
            } else {
                this.permissionsetAPIName = op.Parent.Name;
                this.permissionsetName = '[PS]' + op.Parent.Label;
            }
            this.objectAPIName = op.SobjectType;
            this.objectName = op.SobjectType;
            this.sobjectType = op.SobjectType.contains('__c') ? 'Custom Object' : 'Standard Object';
            this.tabVisibility = tabVisibility;
            this.isReadEnabled = op.PermissionsRead;
            this.isCreateEnabled = op.PermissionsCreate;
            this.isEditEnabled = op.PermissionsEdit;
            this.isDeleteEnabled = op.PermissionsDelete;
            this.isViewAllEnabled = op.PermissionsViewAllRecords;
            this.isModifyAllEnabled = op.PermissionsModifyAllRecords;
        }
    }

    public class FieldLevelSecurity {
        
        private String permissionsetAPIName;
        private String permissionsetName;
        private String objectAPIName;
        private String objectName;
        private String fieldAPIName;
        private String fieldName;
        private Boolean flsRead;
        private Boolean flsEdit;

        public FieldLevelSecurity(FieldPermissions fp) {
            List<String> fieldNameParts = fp.Field.split('\\.');
            String fieldName = fieldNameParts.size() > 1 ? fieldNameParts.get(1) : fieldNameParts.get(0);
            this.fieldAPIName = fieldName;
            this.fieldName = fieldName;
            this.objectAPIName = fp.SobjectType;
            this.objectName = fp.SobjectType;
            this.flsEdit = fp.PermissionsEdit;
            this.flsRead = fp.PermissionsRead;
            if (String.isNotBlank(fp.Parent.Profile.Name)) {
                this.permissionsetAPIName = fp.Parent.Profile.Name;
                this.permissionsetName = '[PF]' + fp.Parent.Profile.Name;
            } else {
                this.permissionsetAPIName = fp.Parent.Name;
                this.permissionsetName = '[PS]' + fp.Parent.Label;
            }
        }
    }
}
