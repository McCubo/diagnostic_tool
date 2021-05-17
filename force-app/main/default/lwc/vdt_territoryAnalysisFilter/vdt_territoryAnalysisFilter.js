import { LightningElement, wire, api } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import onekeyCountryChannel from '@salesforce/messageChannel/vdt_onekeyCountryChannel__c';

export default class Vdt_territoryAnalysisFilter extends LightningElement {

    @wire(MessageContext)
    messageContext;

    @api
    disabled = false;

    _filter = {
        countries: []
    }

    handleCountryOptionSelect(evt) {
        const payload = { countries: evt.detail.countries };
        publish(this.messageContext, onekeyCountryChannel, payload);
        this._filter.countries = evt.detail.countries;
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