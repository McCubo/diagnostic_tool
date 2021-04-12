@IsTest
public with sharing class VDT_UserDataFactory {

    private User userSObject;

    public VDT_UserDataFactory() {
        this.userSObject = new User(
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'GMT',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Country = 'DE'
        );
    }    

    public VDT_UserDataFactory username(String username) {
        this.userSObject.Username = username;
        return this;
    }

    public VDT_UserDataFactory alias(String alias) {
        this.userSObject.Alias = alias;
        return this;
    }

    public VDT_UserDataFactory name(String name) {
        this.userSObject.LastName = name;
        return this;
    }

    public VDT_UserDataFactory email(String email) {
        this.userSObject.Email = email;
        return this;
    }
    
    public VDT_UserDataFactory profile(String profileName) {
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        this.userSObject.ProfileId = profile.Id;
        return this;
    }

    public User getRecord() {
        return this.userSObject;
    }

    public User buildAdmin() {
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        this.userSObject.ProfileId = systemAdminProfile.Id;
        return this.userSObject;
    }
}