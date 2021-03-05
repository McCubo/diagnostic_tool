import { LightningElement, api, track } from 'lwc';


export default class Vdt_objectsDashboard extends LightningElement {
    @track
    _countryCodeOptions = [];
    _calculationData;
    @track
    _filteredData;
    _selectedCountries = [];

    get _showEmpty() {
        return !!this._calculationData === false;
    }
    get _showDashboard() {
        return !!this._calculationData;
    }

    @api
    get calculationData() {
        return this._calculationData;
    }
    set calculationData(val) {
        if (val) {
            this._calculationData = JSON.parse(val);
            this._filteredData = JSON.parse(JSON.stringify(this._calculationData));
            this.populateCountryCodeOptions();
        }
    }

    populateCountryCodeOptions() {
        this._countryCodeOptions.push({ label: 'All', value: 'All', selected: true });
        this._calculationData.countryCodes.forEach(cc => {
            this._countryCodeOptions.push({ label: cc, value: cc });
        });
    }

    handleFilterChange(evt) {
        this._filteredData = JSON.parse(JSON.stringify(this._calculationData));
        this.filterCountries(evt.detail.countries);
        this.filterStandardFields(evt.detail.excludeStandardFields, evt.detail.standardFieldIdentifier);
        console.log(evt.detail);
    }

    filterCountries(selectedCountries) {
        this._filteredData.countryCodes = selectedCountries;
        Object.keys(this._filteredData.fields).forEach(field => {
            this._filteredData.fields[field].countryUsageSummary = {};
            Object.keys(this._calculationData.fields[field].countryUsageSummary).forEach(country => {
                if (selectedCountries.indexOf(country) >= 0 || selectedCountries.indexOf('All') >= 0 || !selectedCountries.length) {
                    this._filteredData.fields[field].countryUsageSummary[country] = 
                        this._calculationData.fields[field].countryUsageSummary[country];
                }
            })
        })
    }

    filterStandardFields(exclude, identifier) {
        if (exclude) {
            let filteredFields = {};
            Object.keys(this._filteredData.fields).forEach(field => {
                if (field.toLowerCase().indexOf(identifier.toLowerCase()) < 0) {
                    filteredFields[field] = this._filteredData.fields[field];
                }
            });
            this._filteredData.fields = filteredFields;
        }
    }

    handleCountryOptionSelect(evt) {
        console.log(evt.detail);
        this._selectedCountries = evt.detail;
        
    }
}