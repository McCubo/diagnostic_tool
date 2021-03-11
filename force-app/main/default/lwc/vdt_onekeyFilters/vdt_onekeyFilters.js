import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import onekeyCountryChannel from '@salesforce/messageChannel/vdt_onekeyCountryChannel__c';

export default class Vdt_onekeyFilters extends LightningElement {

    @wire(MessageContext)
    messageContext;

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
        { label: 'FR', value: 'FR', selected: false}
    ];

    handleCountryOptionSelect(evt) {
        const payload = { countries: evt.detail };
        publish(this.messageContext, onekeyCountryChannel, payload);
    }

    handleDateRangeChange(evt) {
        console.log(JSON.stringify(evt.detail));
    }
}