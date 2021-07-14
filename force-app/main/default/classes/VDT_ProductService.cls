/**
 * @description Apex class used to retrieve the Product Tree information.
 * @author BASE Life Science
 * @since 2021.03.01
 */
public with sharing class VDT_ProductService {

    private static String statusField;
    private static String typeField;
    private static String parentProductField;

    /**
     * @return  `ProductAdoptionData` an object containing all product hierarchy information
     */
    public static ProductAdoptionData getProductTreeInformation() {
        ProductAdoptionData productAdoption = new ProductAdoptionData();
        String productSObjectAPIName = VDT_CustomMetadataService.getProductCatalogObjectAPI();
        String productCountryField = VDT_CustomMetadataService.getCountryFieldForObject(productSObjectAPIName);
        String packageVersion = VDT_CustomMetadataService.getPackageVersion();
        statusField = VDT_CustomMetadataService.getFieldNameForCustomObject(packageVersion, 'PRODUCT_VOD_STATUS');
        typeField = VDT_CustomMetadataService.getFieldNameForCustomObject(packageVersion, 'PRODUCT_TYPE_FIELD');
        parentProductField = VDT_CustomMetadataService.getFieldNameForCustomObject(packageVersion, 'PARENT_PRODUCT_FIELD');
        Map<String,String> queries = VDT_CustomMetadataService.getQueriesByPackageVersionAndModule(packageVersion, 'Product Adoption');
        String query = queries.get('Products_Hierarchy');        
        List<SObject> products = Database.query(query);
        
        Map<Id, List<SObject>> childProductsByParent = new Map<Id, List<SObject>>();        
        for (SObject product : products) {
            productAdoption.productTypes.add(getProductProperty(product, typeField));
            productAdoption.productStatuses.add(getProductProperty(product, statusField));
            String parentProduct = getProductProperty(product, parentProductField);
            if (String.isNotBlank(parentProduct)) {
                if (childProductsByParent.containsKey(parentProduct)) {
                    childProductsByParent.get(parentProduct).add(product);
                } else {
                    childProductsByParent.put(parentProduct, new List<SObject> {product});
                }        
            }
        }                                        
        productAdoption.treeItems = getProductCatalogTree(products, childProductsByParent, productCountryField, true);
        return productAdoption;
    }

    /**
     * @description recursive function used to keep adding child product for each product presented on the list given on the firt parameter
     * @param products 
     * @param childProductsByParent 
     * @param productCountry 
     * @param isRootNode 
     * @return  `List<ProductCatalogTreeItem>`
     */
    private static List<ProductCatalogTreeItem> getProductCatalogTree(List<SObject> products, Map<Id, List<SObject>> childProductsByParent, String productCountry, Boolean isRootNode) {
        List<ProductCatalogTreeItem> productCatalogTree = new List<ProductCatalogTreeItem>();
        for (SObject product : products) {
            String country = getProductProperty(product, productCountry);
            String status = getProductProperty(product, statusField);
            ProductCatalogTreeItem productTreeItem = new ProductCatalogTreeItem(getProductProperty(product, 'Name'), product.Id, getProductProperty(product, typeField), country, status);
            if (childProductsByParent.containsKey(product.Id)) {
                List<SObject> childProducts = childProductsByParent.get(product.Id);
                productTreeItem.items = getProductCatalogTree(childProducts, childProductsByParent, productCountry, false);
            }
            if (isRootNode && String.isBlank(getProductProperty(product, parentProductField)) || !isRootNode) {
                productCatalogTree.add(productTreeItem);
            }
        }
        return productCatalogTree;
    }

    /**
     * @description utility method to get the value from any property on the Product SObject
     * @param product Product SObject
     * @param fieldAPI Field API Name
     * @return  `String` field value
     */
    private static String getProductProperty(SObject product, String fieldAPI) {
        String value = '';
        if (fieldAPI.contains('.')) {
            String relationship = fieldAPI.split('\\.').get(0);
            String relatedField = fieldAPI.split('\\.').get(1);
            if (product.getSObject(relationship) != null) {
                value = product.getSObject(relationship).get(relatedField).toString();
            }
        } else {
            value = String.valueOf(product.get(fieldAPI));
        }
        return value;
    }
    public class ProductAdoptionData {

        @AuraEnabled
        public List<String> productTypes = new List<String>();
        @AuraEnabled
        public List<String> productStatuses = new List<String>();
        @AuraEnabled
        public List<ProductCatalogTreeItem> treeItems = new List<ProductCatalogTreeItem>();

    }

    public class ProductCatalogTreeItem {

        public ProductCatalogTreeItem(String label, String name, String type, String country, String status) {
            this.label = label;
            this.name = name;
            this.type = type;
            this.country = country;
            this.status = status;
            this.setMetatext();
        }

        @AuraEnabled
        public String label;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Boolean expanded = false;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String country;
        @AuraEnabled
        public String metatext;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public List<ProductCatalogTreeItem> items = new List<ProductCatalogTreeItem>();        

        public void setMetatext() {
            this.metatext = String.format('Product Type: {0} | Country: {1} | Status: {2}', new List<String> { this.type, this.country, this.status });
        }
    }
}