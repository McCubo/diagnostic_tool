public with sharing class VDT_ProductService {

    public static ProductAdoptionData getProductTreeInformation() {
        ProductAdoptionData productAdoption = new ProductAdoptionData();
        String productCountry = VDT_CustomMetadataService.getCountryFieldForObject('Product_vod__c');
        List<Product_vod__c> products = new VDT_ProductSelector()
                                        .withAdditionalFields(new List<String> {
                                            Product_vod__c.Parent_Product_vod__c.getDescribe().getName(),
                                            productCountry
                                        })
                                        .query();

        Map<Id, List<Product_vod__c>> childProductsByParent = new Map<Id, List<Product_vod__c>>();        
        for (Product_vod__c product : products) {
            productAdoption.productTypes.add(product.Product_Type_vod__c);
            if (String.isNotBlank(product.Parent_Product_vod__c)) {
                if (childProductsByParent.containsKey(product.Parent_Product_vod__c)) {
                    childProductsByParent.get(product.Parent_Product_vod__c).add(product);
                } else {
                    childProductsByParent.put(product.Parent_Product_vod__c, new List<Product_vod__c> {product});
                }        
            }
        }                                        
        productAdoption.treeItems = getProductCatalogTree(products, childProductsByParent, productCountry, true);
        return productAdoption;
    }

    private static List<ProductCatalogTreeItem> getProductCatalogTree(List<Product_vod__c> products, Map<Id, List<Product_vod__c>> childProductsByParent, String productCountry, Boolean isRootNode) {
        List<ProductCatalogTreeItem> productCatalogTree = new List<ProductCatalogTreeItem>();
        for (Product_vod__c product : products) {
            String country = getCountryValue(product, productCountry);
            ProductCatalogTreeItem productTreeItem = new ProductCatalogTreeItem(product.Name, product.Id, product.Product_Type_vod__c, country).setMetatext();
            if (childProductsByParent.containsKey(product.Id)) {
                List<Product_vod__c> childProducts = childProductsByParent.get(product.Id);
                productTreeItem.items = getProductCatalogTree(childProducts, childProductsByParent, productCountry, false);
            }
            if ((isRootNode && String.isBlank(product.Parent_Product_vod__c)) || !isRootNode) {
                productCatalogTree.add(productTreeItem);
            }
        }
        return productCatalogTree;
    }

    private static String getCountryValue(Product_vod__c product, String countryField) {
        String country = '';
        if (countryField.contains('.')) {
            String relationship = countryField.split('\\.').get(0);
            String relatedField = countryField.split('\\.').get(1);
            if (product.getSObject(relationship) != null) {
                country = product.getSObject(relationship).get(relatedField).toString();
            }
        } else {
            country = String.valueOf(product.get(countryField));
        }
        return country;
    }
    public class ProductAdoptionData {

        @AuraEnabled
        public List<String> productTypes = new List<String>();
        @AuraEnabled
        public List<ProductCatalogTreeItem> treeItems = new List<ProductCatalogTreeItem>();

    }

    public class ProductCatalogTreeItem {

        public ProductCatalogTreeItem(String label, String name, String type, String country) {
            this.label = label;
            this.name = name;
            this.type = type;
            this.country = country;
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
        public List<ProductCatalogTreeItem> items = new List<ProductCatalogTreeItem>();        

        public ProductCatalogTreeItem setMetatext() {
            this.metatext = String.format('Product Type: {0} | Country: {1}', new List<String> { this.type, this.country });
            return this;
        }
    }
}
