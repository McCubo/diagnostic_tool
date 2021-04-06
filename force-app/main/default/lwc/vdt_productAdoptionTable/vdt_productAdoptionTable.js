import { LightningElement, wire, api } from 'lwc';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
import onekeyCountryChannel from '@salesforce/messageChannel/vdt_onekeyCountryChannel__c';
import { downloadCSVFile } from 'c/vdt_csvUtil'

const COLUMNS = [
    { label: 'Product', fieldName: 'name' },
    { label: 'Product Type', fieldName: 'type'},
    { label: 'Country', fieldName: 'country'},
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
    @api
    countries = [];
    @api
    internationalCountry;

    _recordsPerPage = 10;
    _totalPages = 1;
    _currentPage = 1;
    _pageNumbers = [];

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
        this.initializePaginator();
    }

    initializePaginator() {
        this._totalPages = Math.ceil(this._calculationData.length / this._recordsPerPage);
        this._pageNumbers = [];
        this._currentPage = 1;
        for (let i = 1; i <= this._totalPages; i++) {
            this._pageNumbers.push(i);
        }
    }

    get _currentOffset() {
        return (this._currentPage - 1) * this._recordsPerPage;
    }

    get _currentPageData() {
        return this._calculationData.slice(this._currentOffset, this._currentPage * this._recordsPerPage);
    }

    handleExportCSV() {
        let headers = {};
        this.columns.forEach(col => headers[col.fieldName] = col.label);
        downloadCSVFile(headers, this._calculationData, 'product_adoption_summary');
    }

    handleProductTypeChange(event) {
        this._selectedProductTypes = event.detail;
        this._calculationData = this.parseData(JSON.parse(this._rawData));
        this.initializePaginator();
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
            this.initializePaginator();
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
            if ((this._selectedProductTypes.length == 0 || this._selectedProductTypes.includes(productType.type)) &&
                (this.countries.length == 0 || this.countries.includes(productType.country) || productType.country == this.internationalCountry)
            ) {
                let productTypeEntry = {
                    id: productType.id,
                    name: productType.name,
                    type: productType.type,
                    country: productType.country,
                    activeKeyMessages: 0,
                    activeCLM: 0,
                    approvedDocuments: 0,
                    sentEmail: 0,
                    productMetric: 0,
                    callsVisits: 0,
                    events: 0
                };
                Object.keys(productType.countryUsageSummary).forEach(countryCode => {
                    if (this.countries.length == 0 || this.countries.includes(countryCode)) {
                        productTypeEntry.activeKeyMessages += productType.countryUsageSummary[countryCode].activeKeyMessages;
                        productTypeEntry.activeCLM += productType.countryUsageSummary[countryCode].activeCLM;
                        productTypeEntry.approvedDocuments += productType.countryUsageSummary[countryCode].approvedDocuments;
                        productTypeEntry.sentEmail += productType.countryUsageSummary[countryCode].sentEmail;
                        productTypeEntry.productMetric += productType.countryUsageSummary[countryCode].productMetric;
                        productTypeEntry.callsVisits += productType.countryUsageSummary[countryCode].callsVisits;
                        productTypeEntry.events += productType.countryUsageSummary[countryCode].events;
                    }
                });
                parsedData.push(productTypeEntry);
            }

        });
        return parsedData;
    }

    handlePreviousClick() {
        if (this._currentPage > 1) {
            this._currentPage--;
        }
    }
    
    handlePageClick(event) {
        this._currentPage = event.detail;
    }

    handleNextClick() {
        if (this._currentPage < this._totalPages) {
            this._currentPage++;
        }
    }
}