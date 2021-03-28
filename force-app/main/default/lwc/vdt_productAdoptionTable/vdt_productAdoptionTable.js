import { LightningElement, wire, api } from 'lwc';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
import onekeyCountryChannel from '@salesforce/messageChannel/vdt_onekeyCountryChannel__c';
import { downloadCSVFile } from 'c/vdt_csvUtil'

const COLUMNS = [
    { label: 'Product', fieldName: 'name' },
    { label: 'Product Type', fieldName: 'type'},
    { label: '#Active key messages', fieldName: 'activeKeyMessages', type: 'number' },
    { label: '#Active CLM', fieldName: 'activeCLM', type: 'number' },
    { label: '#Approved Document', fieldName: 'approvedDocuments', type: 'number' },
    { label: '#Sent email', fieldName: 'sentEmail', type: 'number' },
    { label: '#Product metric', fieldName: 'productMetric', type: 'number' },
    { label: '#Calls/Visits', fieldName: 'callsVisits', type: 'number' },
    { label: '#Events', fieldName: 'events', type: 'number' },
];

export default class Vdt_productAdoptionTable extends LightningElement {
   
    columns = COLUMNS;

    @wire(MessageContext)
    messageContext;
    
    _calculationData = [];
    _rawData = [];
    _productTypes = [];
    _selectedProductTypes = [];
    countries = [];
    _subscription = null;

    @api
    get calculationData() {
        return this._calculationData;
    }

    set calculationData(val) {
        this._rawData = val;
        let data = JSON.parse(val);
        this._productTypes = data.productTypes.map(productType => {
            return { label: productType, value: productType };
        });
        this._calculationData = this.parseData(data);
    }

    handleExportCSV() {
        let headers = {};
        this.columns.forEach(col => headers[col.fieldName] = col.label);
        downloadCSVFile(headers, this._calculationData, 'product_adoption_summary');
    }

    handleProductTypeChange(event) {
        this._selectedProductTypes = event.detail;
        this._calculationData = this.parseData(JSON.parse(this._rawData));
    }

    connectedCallback() {
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
            this._calculationData = this.parseData(JSON.parse(this._rawData));
        }
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this._subscription);
        this._subscription = null;
    }

    parseData(data) {
        let parsedData = [];
        Object.values(data.product_adoption).forEach(productType => {
            if (this._selectedProductTypes.length == 0 || this._selectedProductTypes.includes(productType.type)) {
                let productTypeEntry = {
                    id: productType.id,
                    name: productType.name,
                    type: productType.type,
                    activeKeyMessages: 0,
                    activeCLM: 0,
                    approvedDocuments: 0,
                    sentEmail: 0,
                    productMetric: 0,
                    callsVisits: productType.callsVisits,
                    events: 0
                };
                Object.keys(productType.countryUsageSummary).forEach(countryCode => {
                    if (this.countries.length == 0 || this.countries.includes(countryCode) || this.countries.includes('All')) {
                        productTypeEntry.activeKeyMessages += productType.countryUsageSummary[countryCode].activeKeyMessages;
                        productTypeEntry.activeCLM += productType.countryUsageSummary[countryCode].activeCLM;
                        productTypeEntry.approvedDocuments += productType.countryUsageSummary[countryCode].approvedDocuments;
                        productTypeEntry.sentEmail += productType.countryUsageSummary[countryCode].sentEmail;
                        productTypeEntry.productMetric += productType.countryUsageSummary[countryCode].productMetric;
                    }
                });
                parsedData.push(productTypeEntry);
            }

        });
        return parsedData;
    }
}