/**
 * @description Provides Apex methods to be used on the User Screen.
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_VeevaUsersController {

    /**
     * 
     * @param queryLimit Max number of records to be returned by the SOQL query
     * @param queryOffset offset to apply to the query
     * @return  `List<UserWrapper>` records to be displayed on the LWC-Datatable component
     */
    @AuraEnabled(cacheable=true)
    public static List<UserWrapper> fetchVeevaUsers(Integer queryLimit, Integer queryOffset) {
        List<UserWrapper> wrappers = new List<UserWrapper>();
        for(User user : [ 
                            SELECT  Id, 
                                    Name, 
                                    Email,
                                    LastLoginDate, 
                                    Manager.Name 
                            FROM    User 
                            LIMIT :queryLimit
                            OFFSET :queryOffset
                        ]) {

            UserWrapper wrapper = new UserWrapper();
            wrapper.id = user.Id;
            wrapper.name = user.Name;
            wrapper.email = user.Email;
            wrapper.lastLoginDate = user.LastLoginDate;
            wrapper.managerName = user.Manager.Name;
            wrapper.enableReport = false;
            wrappers.add(wrapper);
        }
        return wrappers;
    }

    @TestVisible
    private class UserWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String email;
        @AuraEnabled public DateTime lastLoginDate;
        @AuraEnabled public String managerName;
        @AuraEnabled public Boolean enableReport;
    }
}