/**
 * @description Apex class that exposes Data Layer methods for the Record Type SOBject
 * @author BASE Life Science
 * @since 2021.03.01
 */
public inherited sharing class VDT_RecordTypeService {

    /**
     * @param sobjectName SObject API Name
     * @param developerName Record Type API Name
     * @return  `List<RecordType>` Record Type that match the filters
     */
    public static List<RecordType> getRecordTypeByObjectAndName(String sobjectName, String developerName) {
        return new VDT_RecordTypeSelector().getRecordTypeByObjectAndName(sobjectName, developerName);
    }

    /**
     * @param sobjectName SOBject API NAme
     * @return  `List<RecordType>` all Record Types available for the given SObject
     */
    public static List<RecordType> getAllRecordTypesByObject(String sobjectName) {
        return new VDT_RecordTypeSelector().getAllRecordTypesByObject(sobjectName);
    }

}