public inherited sharing class VDT_ObjectService {
    public static final String FIELD_SUMMARY_CALCULATION_FILE_NAME = 'summary_calculation';

    private static final String OBJECT_SUFFX_HISTORY    = 'history';
    private static final String OBJECT_SUFFX_TAG        = 'tag';
    private static final String OBJECT_SUFFX_SHARE      = 'share';
    private static final String OBJECT_SUFFX_FEED       = 'feed';


    public static List<Schema.SObjectType> getAllAccessibleObjects() {
        List<Schema.SObjectType> accessibleTypes = new List<Schema.SObjectType>();

        for(Schema.SObjectType objType : Schema.getGlobalDescribe().values()) {
            String apiName = objType.getDescribe().getName();
            
            if( objType.getDescribe().isAccessible() == true        &&
                !apiName.containsignorecase(OBJECT_SUFFX_HISTORY)   && 
                !apiName.containsignorecase(OBJECT_SUFFX_TAG)       &&
                !apiName.containsignorecase(OBJECT_SUFFX_SHARE)     &&
                !apiName.containsignorecase(OBJECT_SUFFX_FEED)) {

                accessibleTypes.add(objType);
            }
        }

        return accessibleTypes;
    }

    public static List<Schema.SObjectField> getNumberOfAccessibleFieldsForObject(String objectName, Integer fieldsNum) {
        
        List<Schema.SObjectField> fields = new List<Schema.SObjectField>();

        Map<String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = globalDescribe.get(objectName);
        Schema.DescribeSObjectResult typeDescribe = sobjType.getDescribe();
        Map<String, Schema.SObjectField> typeFieldsMapping = typeDescribe.fields.getMap();
        List<String> fieldNames = new List<String>(typeFieldsMapping.keySet());
        fieldNames.sort();
        
        Integer idx = 0;
        while(fields.size() < fieldsNum) {
            Schema.SObjectField field = typeFieldsMapping.get(fieldNames[idx]);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

            if (fieldDescribe.isAccessible() == true) {
                fields.add(field);
            }
            idx++;
        }

        return fields;
    }

    public static List<Schema.SObjectField> getAllAccessibleFieldsForObject(String objectName) {
        
        List<Schema.SObjectField> fields = new List<Schema.SObjectField>();

        Map<String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = globalDescribe.get(objectName);
        Schema.DescribeSObjectResult typeDescribe = sobjType.getDescribe();
        Map<String, Schema.SObjectField> typeFieldsMapping = typeDescribe.fields.getMap();
        List<String> fieldNames = new List<String>(typeFieldsMapping.keySet());
        fieldNames.sort();
        
        for(String fieldName : fieldNames) {
            Schema.SObjectField field = typeFieldsMapping.get(fieldName);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

            if (fieldDescribe.isAccessible() == true) {
                fields.add(field);
            }
        }

        return fields;
    }

    public static List<VDT_OptionWrapper> getPicklistOptionsBySObjectName(Schema.DescribeSObjectResult objectDescribe, String fieldName) {
        List<VDT_OptionWrapper> options = new List<VDT_OptionWrapper>();
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap(); 
        List<Schema.PicklistEntry> values = fieldMap.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : values) { 
           options.add(new VDT_OptionWrapper(a.getLabel(), a.getValue())); 
        }
        return options;
    }

}
