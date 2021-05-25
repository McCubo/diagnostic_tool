/**
 * @description Provides methods to access records stored in the `EmailTemplate` SObject
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_EmailTemplateSelector {

    /**
     * @return  `String` SOBject API Name that wil be used in the FROM Statement
     */
    public String getObjectName() {
        return 'EmailTemplate';
    }

    /**
     * @return  `List<String>` Field API Names included in the SELECT statement
     */
    public List<String> getFieldList() {
        return new List<String>{
            EmailTemplate.Id.getDescribe().getName()
        };
    }

    /**
     * @return  `String` Comma separated Field API Names
     */
    public String getFieldListString() {
        return String.join(this.getFieldList(), ',');
    }

    /**
     * @description Search Email Template based on their names
     * @param templateName Template API Name
     * @return  `List<EmailTemplate>` Template for the given Name
     */
    public List<EmailTemplate> getByName(String templateName) {
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            'WHERE  Name = :templateName ' +
            'WITH   SECURITY_ENFORCED ', 
            new List<String>{
                getFieldListString(),
                getObjectName()
            }
        );

        return Database.query(query);
    }
}