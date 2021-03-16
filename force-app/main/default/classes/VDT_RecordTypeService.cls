public inherited sharing class VDT_RecordTypeService {

    public static List<RecordType> getRecordTypesBySObject(String sobjectName) {
        return new VDT_RecordTypeSelector().getAllRecordTypesForSObject(sobjectName);
    }

}
