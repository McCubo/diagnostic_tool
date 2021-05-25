public without sharing class VDT_PageLayoutService {

    public static final String FIELD_BEHAVIOR_EDIT = 'Edit';
    public static final String FIELD_BEHAVIOR_READ_ONLY = 'Read Only';

    private static List<List<String>> getLayoutChunks(List<String> layoutNames) {
        List<List<String>> layoutNamesChunks = new List<List<String>>();
        if (layoutNames.size() > 10) {
            Integer index = 0;
            Integer count = 0;
            List<String> tempList = new List<String>();
            while (index < layoutNames.size()) {
                tempList.add(layoutNames.get(index++));
                ++count;
                if (count == 10) {
                    layoutNamesChunks.add(tempList);
                    tempList = new List<String>();
                    count = 0;
                }
            }
            if (!tempList.isEmpty()) {
                layoutNamesChunks.add(tempList);
            }
        } else {
            layoutNamesChunks.add(layoutNames);
        }
        return layoutNamesChunks;
    }

    /**
     * 
     * @param objectName SObject API Name
     * @return  `Map<String, Set<String>>` for each object's field, we create two map entries, one that contains all page layouts where the field has `READ_ONLY` permissions,
     *           and a second entry where its permission is `EDIT`
     */
    public static Map<String, Set<String>> getFieldBehaviourInPageLayoutsForObject(String objectName) {
        Map<String, Set<String>> fieldsBehavior = new Map<String, Set<String>>();
        List<String> layoutNames = VDT_ToolingAPIService.getLayoutNamesForObject(objectName);
        List<List<String>> layoutNamesChunks = getLayoutChunks(layoutNames);

        for (List<String> chunk : layoutNamesChunks) {
            List<String> layoutFullNames = new List<String>();
            for (String layoutName : chunk) {
                layoutFullNames.add(String.format('{0}-{1}', new String[]{objectName, layoutName}));
            }
            List<Metadata.Metadata> layoutMetadata = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, layoutFullNames);
            //get only layout name
            List<string> fields = new List<string>();
            for (Metadata.Metadata layoutMd : layoutMetadata) {
                Metadata.Layout layout = (Metadata.Layout)layoutMd;
                for (Metadata.LayoutSection section : layout.layoutSections) {
                    for (Metadata.LayoutColumn column : section.layoutColumns) {
                        if (column.layoutItems != null) {
                            for (Metadata.LayoutItem item : column.layoutItems) {
                                String behavior = item.behavior == Metadata.UiBehavior.EDIT || item.behavior == Metadata.UiBehavior.REQUIRED ? FIELD_BEHAVIOR_EDIT : FIELD_BEHAVIOR_READ_ONLY;
                                String layoutname = layoutMd.fullName.right((layoutMd.fullName.length() -1) - layoutMd.fullName.indexOf('-'));
                                if (fieldsBehavior.containsKey(behavior + '_' + objectName + '.' + item.field)) {
                                    Set<String> pageLayouts = fieldsBehavior.get(behavior + '_' + objectName + '.' + item.field);
                                    pageLayouts.add(layoutname);
                                } else {
                                    Set<String> pageLayouts = new Set<String> {layoutname};
                                    fieldsBehavior.put(behavior + '_' + objectName + '.' + item.field, pageLayouts);
                                }
                            }
                        }
                    }
                }
            }
        }
        return fieldsBehavior;
    }

    /**
     * @param objectName SObject API Name
     * @return  `Map<String, List<String>>` Map of All available fields for each Page layout on the given SObject
     */
    public static Map<String, List<String>> getLayoutsWithFieldsForObject(string objectName) {
        List<List<String>> layoutNamesChunks = new List<List<String>>();
        Map<String, List<String>> layoutWithFields = new Map<String, List<String>>();
        List<String> layoutNames = VDT_ToolingAPIService.getLayoutNamesForObject(objectName);

        // only list of 10 names can be retrieved in one Metadata.Operations.retrieve() call
        if (layoutNames.size() > 10) {
            Integer index = 0;
            Integer count = 0;
            List<String> tempList = new List<String>();
            while (index < layoutNames.size()) {
                tempList.add(layoutNames.get(index++));
                ++count;
                if (count == 5) {
                    layoutNamesChunks.add(tempList);
                    tempList = new List<String>();
                    count = 0;
                }
            }
            if (!tempList.isEmpty()) {
                layoutNamesChunks.add(tempList);
            }
        } else {
            layoutNamesChunks.add(layoutNames);
        }

        for (List<String> chunk : layoutNamesChunks) {
            List<String> layoutFullNames = new List<String>();
            for (String layoutName : chunk) {
                layoutFullNames.add(String.format('{0}-{1}', new String[]{objectName, layoutName}));
                if (objectName == 'Account') {
                    layoutFullNames.add(String.format('{0}-{1}', new String[]{'PersonAccount', layoutName}));
                }
            }
            List<Metadata.Metadata> layoutMetadata = 
                Metadata.Operations.retrieve(Metadata.MetadataType.Layout, layoutFullNames);
            //get only layput name
            List<string> fields=new List<string>();
            Map<String, List<Metadata.LayoutSection>> layoutWithSections = 
            new Map<String, List<Metadata.LayoutSection>>();
            for (Metadata.Metadata layoutMd : layoutMetadata) {
                Metadata.Layout layout = (Metadata.Layout)layoutMd;
                for (Metadata.LayoutSection section : layout.layoutSections) {
                    for (Metadata.LayoutColumn column : section.layoutColumns) {
                        if (column.layoutItems != null) {
                            for (Metadata.LayoutItem item : column.layoutItems) {
                                if (layoutWithFields.get(layoutMd.fullName) == null) {
                                    layoutWithFields.put(layoutMd.fullName, new List<String>{item.field});
                                } else {
                                    layoutWithFields.get(layoutMd.fullName).add(item.field);
                                }
                            }
                        }
                    }
                }
            } 
        }
        return layoutWithFields;
    }
}