import { LightningElement } from 'lwc';

export default class Vdt_onekeyFilters extends LightningElement {

    _filter = {
        startDate: '',
        endDate: '',
        selectedCountries: []
    }
    _countryCodeOptions = [
        { label: 'All', value: 'All', selected: true}, 
        { label: 'IE', value: 'IE', selected: false}, 
        { label: 'GB', value: 'GB', selected: false}, 
        { label: 'PL', value: 'PL', selected: false}, 
        { label: 'IT', value: 'IT', selected: false}, 
        { label: 'FR', value: 'FR', selected: false}, 
        { label: 'CH', value: 'CH', selected: false}, 
        { label: 'DE', value: 'DE', selected: false}
    ];

    handleCountryOptionSelect(evt) {
        console.log(evt.detail);
    }

    handleDateRangeChange(evt) {
        console.log(JSON.stringify(evt.detail));
    }
}