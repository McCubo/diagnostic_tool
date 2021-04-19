public inherited sharing class VDT_AttachmentSelector {

    private List<String> additionalFields = new List<String>();

    public VDT_AttachmentSelector withAdditionalFields(List<String> additionalFields) {
        this.additionalFields = additionalFields;
        return this;
    }

    public String getObjectName() {
        return 'Attachment';
    }
    public List<String> getFieldList() {
        return new List<String>{
            Attachment.Id.getDescribe().getName(),
            Attachment.Body.getDescribe().getName()
        };
    }

    public String getFieldListString() {
        List<String> fields = this.getFieldList();
        if (!this.additionalFields.isEmpty()) {
            fields.addAll(this.additionalFields);
        }
        return String.join(fields, ',');
    }

    public List<Attachment> getByNameAndParentId(String name, Id parentId) {
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            'WHERE  Name = :name AND ' +
            '       ParentId = :parentId ' +
            'WITH   SECURITY_ENFORCED ', 
            new List<String>{
                getFieldListString(),
                getObjectName()
            }
        );

        return Database.query(query);
    }

    public List<Attachment> getByParentIdsAndName(Set<String> parentIds, String name) {
        String query = String.format(
            'SELECT {0} FROM {1} ' + 
            'WHERE  Name = :name AND ' +
            '       ParentId IN :parentIds ' +
            'WITH   SECURITY_ENFORCED ', 
            new List<String>{
                getFieldListString(),
                getObjectName()
            }
        );

        return Database.query(query);
    }
}