import { LightningElement, wire, api } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import onekeyCountryChannel from '@salesforce/messageChannel/vdt_onekeyCountryChannel__c';

export default class Vdt_onekeyFilters extends LightningElement {

    @wire(MessageContext)
    messageContext;

    @api
    disabled = false;

    _filter = {
        startYear: null,
        startMonth: null,
        endYear: null,
        endMonth: null,
        countries: []
    }


    handleCountryOptionSelect(evt) {
        const payload = { countries: evt.detail.countries };
        publish(this.messageContext, onekeyCountryChannel, payload);
        this._filter.countries = evt.detail.countries;
    }

    handleDateRangeChange(evt) {
        Object.assign(this._filter, evt.detail);
    }

    handleDisplayInfoClick() {
        const isInputsCorrect = [...this.template.querySelectorAll('.validate')].reduce((validSoFar, inputComponent) => {
                return validSoFar && inputComponent.validate();
            }, true);
        if (isInputsCorrect) {
            this.dispatchEvent(new CustomEvent('showinfo', { detail: this._filter }) );
        }
    }
}