public inherited sharing class VDT_EmailTemplateSelector {
    public String getObjectName() {
        return 'EmailTemplate';
    }
    public List<String> getFieldList() {
        return new List<String>{
            EmailTemplate.Id.getDescribe().getName()
        };
    }

    public String getFieldListString() {
        return String.join(this.getFieldList(), ',');
    }

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