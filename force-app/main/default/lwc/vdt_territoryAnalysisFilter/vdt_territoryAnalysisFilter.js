import { LightningElement, wire, api } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import onekeyCountryChannel from '@salesforce/messageChannel/vdt_onekeyCountryChannel__c';
import getTerritoryHierarchy from '@salesforce/apex/VDT_TerritoryAnalysisController.getTerritoryHierarchy'
import { showToast } from 'c/vdt_utils';

export default class Vdt_territoryAnalysisFilter extends LightningElement {

    @wire(MessageContext)
    messageContext;

    @api
    disabled = false;

    territoryOptions = [];

    items = [];

    _filter = {
        countries: [],
        territory: null,
        territoryLabel: null
    }

    connectedCallback() {
        getTerritoryHierarchy().then(response => {
            this.items = response;
        }).catch(error => {
            console.error(error);
        });
    }

    handleSelectTerritory(event) {
        this._filter.territory = event.detail.id;
        this._filter.territoryLabel = event.detail.label;
    }

    handleCountryOptionSelect(evt) {
        const payload = { countries: evt.detail.countries };
        publish(this.messageContext, onekeyCountryChannel, payload);
        this._filter.countries = evt.detail.countries;
    }

    handleDisplayInfoClick() {
        let isInputsCorrect = false;
        if (this._filter.territory && this._filter.countries.length > 0) {
            this.dispatchEvent(showToast('You should select countries or a territory, not both', 'warning'));
        } else if (!this._filter.territory && this._filter.countries.length == 0) {
            this.dispatchEvent(showToast('Please select a valid option, whether from contries or territories', 'error'));
        } else {
            isInputsCorrect = true;
        }
        if (isInputsCorrect) {
            this.dispatchEvent(new CustomEvent('showinfo', { detail: this._filter }) );
        }
    }

}