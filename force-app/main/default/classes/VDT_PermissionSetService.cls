/**
 * @description Provides Access to Apex Service Methods
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_PermissionSetService {

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
