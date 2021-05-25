/**
 * @description This Apex class contains all methods needed get information related to SObjects
 * @author      BASE Life Science
 * @since       2021.03.01
 */
public inherited sharing class VDT_ObjectService {

    public static final String FIELD_LEVEL_SECURITY_ANALYSIS_FILE_NAME = 'field_level_security';
    public static final String TERRITORY_ANALYSIS_FILE_NAME = 'territory_management';
    public static final String FIELD_VALUES_OCCURRENCES_FILE_NAME = 'field_values_occurrences';
    public static final String FIELD_SUMMARY_CALCULATION_FILE_NAME = 'summary_calculation';

    private static final String OBJECT_SUFFX_HISTORY    = 'history';
    private static final String OBJECT_SUFFX_TAG        = 'tag';
    private static final String OBJECT_SUFFX_SHARE      = 'share';
    private static final String OBJECT_SUFFX_FEED       = 'feed';


    /**
     * @return  `List<Schema.SObjectType>` of SOBjects available to the running user. Used to Populate the select component on: 
     *          `Object-Field Analysis` and `Field Level Security Analysis` screens.
     */
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

    /**
     * 
     * @param objectName SObject API Name
     * @return  `List<Schema.SObjectField>` fields the running user has access to get information on `Object-Field Analysis` and `Field Level Security Analysis` jobs.
     */
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

    /**
     * 
     * @param objectName SOBject API Name
     * @param types Field Types we want to include in calculation
     * @return  `List<Schema.SObjectField>` accesible fields based on their type. Used in `Field Values Occurrences` Job.
     */
    public static List<Schema.SObjectField> getAllAccessibleFieldsForObjectAndTypes(String objectName, List<DisplayType> types) {
        List<Schema.SObjectField> fieldsForTypes = new List<Schema.SObjectField>();
        List<Schema.SObjectField> accessibleFields = getAllAccessibleFieldsForObject(objectName);
        for (Schema.SObjectField field : accessibleFields) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            if (types.contains(fieldDescribe.getType())) {
                fieldsForTypes.add(field);
            }
        }
        return fieldsForTypes;
    }

    /**
     * 
     * @param objectName SObject API Name
     * @param fieldNames Field API Names
     * @return  `Map<String, Set<String>>` Avilable values for each Field. used to determine whether a value is an active option for any PICKLIST field.
     *          Used in `Field Values Occurrences` Job.
     */
    public static Map<String, Set<String>> getPicklistValuesByFieldName(String objectName, Set<String> fieldNames) {
        Map<String, Set<String>> picklistOptionsByFieldName = new Map<String, Set<String>>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        for (String fieldName : fieldNames) {
            Set<String> fieldValues = new Set<String>();
            List<Schema.PicklistEntry> values = fieldMap.get(fieldName).getDescribe().getPickListValues();
            for (Schema.PicklistEntry a : values) {
                fieldValues.add(a.getValue());
            }
            picklistOptionsByFieldName.put(fieldName, fieldValues);
        }
        return picklistOptionsByFieldName;
    }

    /**
     * @param objectDescribe SOBject
     * @param fieldName Field API Name
     * @return  `List<VDT_OptionWrapper>` of all Active Options for a given PICKLIST field.
     */
    public static List<VDT_OptionWrapper> getPicklistOptionsBySObjectName(Schema.DescribeSObjectResult objectDescribe, String fieldName) {
        List<VDT_OptionWrapper> options = new List<VDT_OptionWrapper>();
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap(); 
        List<Schema.PicklistEntry> values = fieldMap.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : values) { 
           options.add(new VDT_OptionWrapper(a.getLabel(), a.getValue())); 
        }
        return options;
    }

    /**
     * 
     * @param objectName SObject API Name
     * @param fieldName Field API Name
     * @return  `String` Field Type
     */
    public static String getFieldTypeBySObjectName(String objectName, String fieldName) {
        if (fieldName.contains('__r')) {
            return 'REFERENCE';
        }
        if (fieldName.contains('CreatedBy.Country')) {
            return 'STRING';
        }
        SObjectType sobjectType = ((SObject)(Type.forName('Schema.' + objectName).newInstance())).getSObjectType();
        DescribeSObjectResult describeResult = sobjectType.getDescribe();
        return String.valueOf(describeResult.fields.getMap().get(fieldName).getDescribe().getType());
    }

    /**
     * @description If the Country field configured for the Account SObject is a REFERENCE to an SObject, we need to query records on the related object and create
     *              a list of options to be used on the Country select COMPONENT on `Master Data Analysis` screen.
     * @param objectName SObject API Name
     * @param fieldName Field API Name
     * @return  `List<VDT_OptionWrapper>`
     */
    public static List<VDT_OptionWrapper> getPicklistOptionsByReference(String objectName, String fieldName) {
        List<VDT_OptionWrapper> options = new List<VDT_OptionWrapper>();
        SObjectType sobjectType = ((SObject)(Type.forName('Schema.' + objectName).newInstance())).getSObjectType();
        DescribeSObjectResult describeResult = sobjectType.getDescribe();
        
        List<String> fieldParts = fieldName.split('\\.');
        String fieldApiName = fieldParts.get(0).replace('__r', '__c');
        
        List<Schema.sObjectType> references = describeResult.fields.getMap().get(fieldApiName).getDescribe().getReferenceTo();
        
        if (!references.isEmpty() && references.get(0).getDescribe().isAccessible()) {
            String sobjectName = references.get(0).getDescribe().getName();
            String query = String.format('SELECT Name FROM {0} WITH SECURITY_ENFORCED', new List<String>{ sobjectName });
            for (SObject obj : Database.query(query)) {
                options.add(new VDT_OptionWrapper(obj.get('Name').toString(), obj.get('Name').toString()));
            }
        }
        return options;
    }

}