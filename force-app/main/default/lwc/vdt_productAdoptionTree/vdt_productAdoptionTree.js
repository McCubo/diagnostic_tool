import { api, LightningElement, wire } from 'lwc';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
import onekeyCountryChannel from '@salesforce/messageChannel/vdt_onekeyCountryChannel__c';
import getProductCatalogTree from '@salesforce/apex/VDT_ProductAdoptionController.getProductCatalogTree';
import { showToast } from 'c/vdt_utils';

export default class Vdt_productAdoptionTree extends LightningElement {

    @wire(MessageContext)
    messageContext;

    @api
    countries = [];
    _subscription = null;

    _productTypeOptions = [];
    treeData = [];
    _rawData = [];
    _selectedProductTypes = [];
    
    connectedCallback() {
        getProductCatalogTree()
        .then(response => {
            this._productTypeOptions = [... new Set(response.productTypes)].map(productType => {
                return {label: productType, value: productType };
            });            
            this._rawData = JSON.stringify(response.treeItems);
            this.treeData = this.filterTreeData(JSON.parse(this._rawData));
        }).catch(error => {
            this.dispatchEvent(showToast(error, 'error'));
        }).finally();
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this._subscription) {
            this._subscription = subscribe(
                this.messageContext,
                onekeyCountryChannel,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    handleMessage(message) {
        if (message.countries) {
            this.countries = message.countries;
            this.treeData = this.filterTreeData(JSON.parse(this._rawData));
        }
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this._subscription);
        this._subscription = null;
    }

    handleProductTypeChange(event) {
        this._selectedProductTypes = event.detail;
        this.treeData = this.filterTreeData(JSON.parse(this._rawData));
    }

    filterTreeData(data) {
        let filtered = data.filter((recordRow) => {
            if (recordRow.items && recordRow.items.length > 0) {
                recordRow.items = this.filterTreeData(recordRow.items);
            }
            if (this._selectedProductTypes.length > 0 && this.countries.length > 0) {
                return this._selectedProductTypes.includes(recordRow.type) && this.countries.includes(recordRow.country);
            } else if (this._selectedProductTypes.length == 0 && this.countries.length == 0) {
                return true;
            } else if (this._selectedProductTypes.length > 0) {
                return this._selectedProductTypes.includes(recordRow.type)
            } else if (this.countries.length > 0) {
                return this.countries.includes(recordRow.country);
            } else {
                return false;
            }
        });
        return filtered;
    }
}