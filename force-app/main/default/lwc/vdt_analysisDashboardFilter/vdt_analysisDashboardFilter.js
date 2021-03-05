import { LightningElement, api, wire, track } from 'lwc';
import getStandardFieldIdentifier from '@salesforce/apex/VDT_AnalysisDashboardFilterController.getStandardFieldIdentifier';

export default class Vdt_analysisDashboardFilter extends LightningElement {
    @track
    _filter = {
        countries: [],
        excludeStandardFields: false,
        standardFieldIdentifier: ''
    }
    _standardFieldIdentifier;
    
    get _excludeFieldsCheckboxLabel() {
        return 'Exclude Standard Fields [' + this._filter.standardFieldIdentifier + ']';
    }
    
    @api
    countryCodeOptions;

    @wire(getStandardFieldIdentifier, {})
    getStandardFieldIdentifierCallback ({error, data}) {
        if (error) {
            console.log(error)
        } else if (data) {
            console.log(data);
            this._filter.standardFieldIdentifier = data;
        }
    }

    handleCountryOptionSelect(evt) {
        this._filter.countries = evt.detail;
        this.dispatchEvent(new CustomEvent('filterchange', {detail: this._filter}));
    }

    handleExcludeStandardFieldsChange(evt) {
        this._filter.excludeStandardFields = evt.detail.checked;
        this.dispatchEvent(new CustomEvent('filterchange', {detail: this._filter}));
    }
}