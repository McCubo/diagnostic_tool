/**
 * @description Provides Access to Apex Service Methods
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_PermissionSetService {

    /**
     * @description queries the Permission Set table (which holds information about profiles and permission set)
     *              and build a list of VDT_OptionWrapper
     * @return  `List<VDT_OptionWrapper>` They contain all information about both profiles and permission sets: label, value and secondary label.
     */
    public static List<VDT_OptionWrapper> getPermissionSets() {
        List<VDT_OptionWrapper> permissionSetOptions = new List<VDT_OptionWrapper>();
        List<PermissionSet> permissionSets = new VDT_PermissionSetSelector()
            .withAdditionalFields(new List<String>{'Profile.Name', 'Profile.UserLicense.Name', 'Profile.UserType', 'Label'})
            .query();
        for (PermissionSet ps : permissionSets) {
            String value = ps.Profile != null ? ps.Profile.Name : ps.Name;
            String label = ps.Profile != null ? ps.Profile.Name : ps.Label;
            String secondaryLabel = ps.Profile != null ? ps.Profile.UserType + '_' + ps.Profile.UserLicense.Name : 'Permission Set';
            VDT_OptionWrapper option = new VDT_OptionWrapper(label, value);
            option.setSecondaryLabel(secondaryLabel);
            permissionSetOptions.add(option);
        }
        return permissionSetOptions;
    }

}
