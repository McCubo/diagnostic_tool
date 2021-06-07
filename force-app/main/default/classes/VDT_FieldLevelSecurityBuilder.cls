/**
 * @description iterates over all `FieldPermission` records and accumulates all the information on the `FieldLevelSecurityOutput` class variable
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_FieldLevelSecurityBuilder {

    private List<FieldPermissions> fieldPermissions = new List<FieldPermissions>();
    private Map<String, ObjectPermissions> objectPermissionsByParentAndSObject = new Map<String, ObjectPermissions>();
    private FieldLevelSecurityOutput flsAnalysisData = new FieldLevelSecurityOutput();
    private Map<String, Set<String>> pageLayoutsByFieldAndBehavior = new Map<String, Set<String>>();

    /**
     * @param fieldPermissions FieldPermission records of the current batch's execution
     * @return  `VDT_FieldLevelSecurityBuilder` instance of the builder
     */
    public VDT_FieldLevelSecurityBuilder withRecords(List<FieldPermissions> fieldPermissions) {
        this.fieldPermissions = fieldPermissions;
        return this;
    }

    /**
     * @description for each object's field, we create two map entries, one that contains all page layouts where the field has `READ_ONLY` permissions,
     *              and a second entry where its permission is `EDIT`
     * @param sobjects List of SObject API Names
     * @return  `VDT_FieldLevelSecurityBuilder` instance of the builder
     */
    public VDT_FieldLevelSecurityBuilder withPageLayoutBehaviors(List<String> sobjects) {
        for (String sobjectname : sobjects) {
            pageLayoutsByFieldAndBehavior.putAll(VDT_PageLayoutService.getFieldBehaviourInPageLayoutsForObject(sobjectname));
        }
        return this;
    }

    /**
     * @description Creates a Map that contains field level security permissions based on Profile/Permission Sets for each object included in the calculation
     * @return  `VDT_FieldLevelSecurityBuilder` instance of the builder
     */
    public VDT_FieldLevelSecurityBuilder withObjectPermissions() {
        Set<String> parentIds = new Set<String>();
        for (FieldPermissions fieldPermission : this.fieldPermissions) {
            parentIds.add(fieldPermission.ParentId);
        }
        for (ObjectPermissions objectPermission : [SELECT ParentId, SobjectType, PermissionsCreate, PermissionsRead, PermissionsEdit, PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords 
                                                   FROM ObjectPermissions WHERE ParentId IN :parentIds]) {
            this.objectPermissionsByParentAndSObject.put(objectPermission.ParentId + '_' + objectPermission.SobjectType, objectPermission);
        }
        return this;
    }

    /**
     * @description Creates a List of `FieldLevelSecurity` records with FLS, Object Level Security and Page Layout Behavior Information
     */
    public void calculate() {
        for (FieldPermissions fieldPermission : this.fieldPermissions) {
            FieldLevelSecurity fls = new FieldLevelSecurity(fieldPermission);
            if (this.objectPermissionsByParentAndSObject.containsKey(fieldPermission.ParentId + '_' + fieldPermission.SobjectType)) {
                fls.setObjectLevelPermissions(this.objectPermissionsByParentAndSObject.get(fieldPermission.ParentId + '_' + fieldPermission.SobjectType));
            }
            fls.setPageLayouts(
                pageLayoutsByFieldAndBehavior.get(VDT_PageLayoutService.FIELD_BEHAVIOR_READ_ONLY + '_' + fieldPermission.Field), 
                pageLayoutsByFieldAndBehavior.get(VDT_PageLayoutService.FIELD_BEHAVIOR_EDIT + '_' + fieldPermission.Field));
            this.flsAnalysisData.fieldLevelSecurity.add(fls);
        }
    }

    /**
     * @return  `String` JSON formatted version of all Field Level Security information
     */
    public String build() {
        return JSON.serialize(this.flsAnalysisData);
    }

    public class FieldLevelSecurityOutput {
        public List<FieldLevelSecurity> fieldLevelSecurity = new List<FieldLevelSecurity>();
    }

    public class FieldLevelSecurity {

        public String id;
        public String sobjectName;
        public String profilePermissionSet;
        public String fieldName;
        public Boolean flsEdit;
        public Boolean flsRead;
        public String pagelayoutRead;
        public String pagelayoutEdit;
        public Boolean availableOnPageLayout;
        public Boolean objectCreate;
        public Boolean objectRead;
        public Boolean objectEdit;
        public Boolean objectDelete;
        public Boolean objectViewAll;
        public Boolean objectModifyAll;

        public FieldLevelSecurity(FieldPermissions fieldPermission) {
            this.id = fieldPermission.Id;
            this.sobjectName = fieldPermission.SobjectType;
            if (String.isNotBlank(fieldPermission.Parent.Profile.Name)) {
                this.profilePermissionSet = 'PF:' + fieldPermission.Parent.Profile.Name;
            } else {
                this.profilePermissionSet = 'PS:' + fieldPermission.Parent.Name;
            }
            this.fieldName = fieldPermission.Field.split('\\.').get(1);
            this.flsEdit = fieldPermission.PermissionsEdit;
            this.flsRead = fieldPermission.PermissionsRead;
        }

        public void setObjectLevelPermissions(ObjectPermissions objectPermission) {
            this.objectCreate = objectPermission.PermissionsCreate;
            this.objectRead = objectPermission.PermissionsRead;
            this.objectEdit = objectPermission.PermissionsEdit;
            this.objectDelete = objectPermission.PermissionsDelete;
            this.objectViewAll = objectPermission.PermissionsViewAllRecords;
            this.objectModifyAll = objectPermission.PermissionsModifyAllRecords;
        }

        public void setPageLayouts(Set<String> readOnlyPageLayouts, Set<String> editPageLayouts) {
            if (readOnlyPageLayouts != null) {
                this.pagelayoutRead = String.join(new List<String>(readOnlyPageLayouts), ',');
            }
            if (editPageLayouts != null) {
                this.pagelayoutEdit = String.join(new List<String>(editPageLayouts), ',');
            }
            this.availableOnPageLayout = readOnlyPageLayouts != null || editPageLayouts != null;
        }

    }
}