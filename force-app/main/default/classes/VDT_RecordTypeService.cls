public inherited sharing class VDT_RecordTypeService {

    public static List<RecordType> getRecordTypeByObjectAndName(String sobjectName, String developerName) {
        return new VDT_RecordTypeSelector().getRecordTypeByObjectAndName(sobjectName, developerName);
    }

}
