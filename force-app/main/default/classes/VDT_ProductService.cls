public with sharing class VDT_ProductService {

    public static List<ProductCatalogTreeItem> getProductTreeInformation() {
        List<ProductCatalogTreeItem> productTree = new List<ProductCatalogTreeItem>();
        String productCountry = VDT_CustomMetadataService.getCountryFieldForObject('Product_vod_c');
        List<Product_vod__c> products = new VDT_ProductSelector()
                                        .withAdditionalFields(new List<String> {
                                            '(SELECT Id FROM Child_products_vod__r)',
                                            productCountry
                                        })
                                        .addWhereClause('Parent_Product_vod__c = NULL')
                                        .query();
                                        
        productTree = getProductCatalogTree(products, productCountry);
        return productTree;
    }

    private static List<ProductCatalogTreeItem> getProductCatalogTree(List<Product_vod__c> products, String productCountry) {
        List<ProductCatalogTreeItem> productCatalogTree = new List<ProductCatalogTreeItem>();
        for (Product_vod__c product : products) {
            ProductCatalogTreeItem productTreeItem = new ProductCatalogTreeItem(product.Name, product.Id, product.Product_Type_vod__c, product.Country__c).setMetatext();
            if (product.Child_products_vod__r != null && !product.Child_products_vod__r.isEmpty()) {
                List<Product_vod__c> childProducts = new VDT_ProductSelector()
                                        .withAdditionalFields(new List<String> {
                                            '(SELECT Id FROM Child_products_vod__r)',
                                            Product_vod__c.Country__c.getDescribe().getName()
                                        })
                                        .addWhereClause('Parent_Product_vod__c = \'' + product.Id + '\'')
                                        .query();
                productTreeItem.items = getProductCatalogTree(childProducts, productCountry);
            }
            productCatalogTree.add(productTreeItem);
        }
        return productCatalogTree;
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
            this.metatext = String.format('Product Type: {0} | Country: {1}', new List<String> { this.label, this.country });
            return this;
        }
    }
}
