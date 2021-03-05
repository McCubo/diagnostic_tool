public inherited sharing class VDT_AttachmentSelector {
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
        return String.join(this.getFieldList(), ',');
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
}
