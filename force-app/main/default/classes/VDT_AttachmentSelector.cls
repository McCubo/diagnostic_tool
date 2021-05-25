/**
 * @author      BASE Life Science
 * @since       2021.03.01
 * @description This Apex class provides methods to retrieve records from the Attachment SObject.
 */
public inherited sharing class VDT_AttachmentSelector {

    private List<String> additionalFields = new List<String>();

    /**
     * @description builder method to include additional fields to the SELECT statement
     * @param additionalFields list of field API names to be added to the SELECT statement
     * @return  `VDT_AttachmentSelector` instance of the class
     */
    public VDT_AttachmentSelector withAdditionalFields(List<String> additionalFields) {
        this.additionalFields = additionalFields;
        return this;
    }

    /**
     * 
     * @return  `String` the object API name that the query will be run against
     */    
    public String getObjectName() {
        return 'Attachment';
    }

    /**
     * 
     * @return  `List<String>` the list of DEFAULT fields to be included in the SELECT statement
     */
    public List<String> getFieldList() {
        return new List<String>{
            Attachment.Id.getDescribe().getName(),
            Attachment.Body.getDescribe().getName()
        };
    }

    /**
     * 
     * @return  `String` all the default and additional fields (if there are any) to be included in the SELECT statement
     */
    public String getFieldListString() {
        List<String> fields = this.getFieldList();
        if (!this.additionalFields.isEmpty()) {
            fields.addAll(this.additionalFields);
        }
        return String.join(fields, ',');
    }

    /**
     * @param name: Attachment file Name
     * @param parentId: SObject Id
     * @return: List of all attachment records related to the given SObject's ID that match the given name
     */
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

    /**
     * @param name: Attachment file Name
     * @param parentIds: SObject Id
     * @return: List of all attachment records related to the given SObject's IDs that match the given name
     */
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