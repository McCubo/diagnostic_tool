import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import onekeyCountryChannel from '@salesforce/messageChannel/vdt_onekeyCountryChannel__c';
export default class Vdt_productsAndHierarchy extends LightningElement {
    
    @wire(MessageContext)
    messageContext;

    _countryOptions = [
        {label: 'GB', value: 'GB', selected: false},
        {label: 'FR', value: 'FR', selected: false},
        {label: 'US', value: 'US', selected: false},
        {label: 'DE', value: 'DE', selected: false}
    ];

    _countries = [];

    handleCountryChange(event) {
        const payload = { countries: event.detail };
        publish(this.messageContext, onekeyCountryChannel, payload);
        this._countries = event.detail;
    }

}