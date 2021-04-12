@IsTest
public with sharing class VDT_ProductDataFactory {
    
    private Product_vod__c product;

    public VDT_ProductDataFactory(String name) {
        this.product = new Product_vod__c(
            Name = name
        );
    }

    public VDT_ProductDataFactory setProperty(String propertyName, Object value) {
        this.product.put(propertyName, value);
        return this;
    }

    public VDT_ProductDataFactory create() {
        insert this.product;
        return this;
    }

    public Product_vod__c getRecord() {
        return this.product;
    }

    public VDT_ProductDataFactory addChildProduct(Product_vod__c childProduct) {
        childProduct.Parent_Product_vod__c = this.product.Id;
        insert childProduct;
        return this;
    }
}