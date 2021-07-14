@IsTest
public with sharing class VDT_ProductDataFactory {
    
    private SObject product;

    public VDT_ProductDataFactory(String name) {
        String productSObjectAPIName = VDT_CustomMetadataService.getProductCatalogObjectAPI();
        this.product = Schema.getGlobalDescribe().get(productSObjectAPIName).newSObject();
        this.setProperty('Name', name);
    }

    public VDT_ProductDataFactory setProperty(String propertyName, Object value) {
        this.product.put(propertyName, value);
        return this;
    }

    public VDT_ProductDataFactory create() {
        insert this.product;
        return this;
    }

    public SObject getRecord() {
        return this.product;
    }

    public VDT_ProductDataFactory addChildProduct(SObject childProduct) {
        childProduct.put('Parent_Product_vod__c', this.product.Id);
        insert childProduct;
        return this;
    }
}