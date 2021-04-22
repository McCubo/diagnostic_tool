public without sharing class VDT_PageLayoutService {
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