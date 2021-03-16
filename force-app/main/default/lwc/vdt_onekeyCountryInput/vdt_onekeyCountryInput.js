import { api, LightningElement, track, wire } from 'lwc';
import getAccountCountryFieldType from '@salesforce/apex/VDT_MasterDataAnalysisController.getAccountCountryFieldType'
import getCountryOptions from '@salesforce/apex/VDT_MasterDataAnalysisController.getCountryOptions'

import { showToast } from 'c/vdt_utils';

export default class Vdt_onekeyCountryInput extends LightningElement {

    @track
    _countryCodeOptions = [];

    @api
    disabled = false;
    loadCompleted = false;
    _fieldType = '';
    _countries = [];

    get isPicklistField() {
        return this._fieldType == 'PICKLIST';
    }

    get isTextField() {
        return this._fieldType == 'STRING';
    }

    get textHelp() {
        return `Select/Type All....`;
    }

    @wire(getAccountCountryFieldType, {})
    getAccountCountryFieldTypeCallback() {
        getAccountCountryFieldType()
        .then(response => {
            this._fieldType = response;            
            if (response == 'PICKLIST') {
                getCountryOptions()
                .then(countryOptions => {
                    countryOptions.unshift({ label: 'All', value: 'All', selected: false})
                    this._countryCodeOptions = countryOptions;
                })
                .catch(error => {
                    this.dispatchEvent(showToast(error, 'error'));
                })
            }
        })
        .catch(error => {
            this.dispatchEvent(showToast(error, 'error'));
        }).finally(() => {
            this.loadCompleted = true;
        });
    }

    @api
    validate() {
        try {
            let isValid = true;
            if (this.isPicklistField) {
                isValid = [...this.template.querySelectorAll('.validate')].reduce((validSoFar, inputComponent) => {
                    return validSoFar && inputComponent.validate();
                }, true);
            } else if (this.isTextField) {
                const inputCmp = this.template.querySelector('lightning-input');
                if (this._countries.length == 0) {
                    inputCmp.setCustomValidity('Field must not be empty');
                    isValid = false;
                } else {
                    inputCmp.setCustomValidity("");
                }
                inputCmp.reportValidity();
            }
            return isValid;
        } catch (error) {
            console.log(error);
        }
    }

    handleCountryTextChange(event) {
        let countries = event.target.value;
        if (countries) {
            countries = countries.split(',').filter(country => {
                return country != null && country != "";
            });
            this._countries = JSON.parse(JSON.stringify(countries));
            this.dispatchEvent(new CustomEvent('countrychange', { detail: { countries} }));
        } else {
            this._countries = [];
        }
    }

    handleCountryOptionSelect(evt) {
        let countries = evt.detail;
        this.dispatchEvent(new CustomEvent('countrychange', { detail: { countries } }) );
    }
}