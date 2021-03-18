public inherited sharing class VDT_RecordTypeService {

    public static List<RecordType> getRecordTypesBySObject(String sobjectName) {
        return new VDT_RecordTypeSelector().getAllRecordTypesForSObject(sobjectName);
    }

    public static List<RecordType> getRecordTypeByObjectAndName(String sobjectName, String developerName) {
        return new VDT_RecordTypeSelector().getRecordTypeByObjectAndName(sobjectName, developerName);
    }

}
