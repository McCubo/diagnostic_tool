import { api, LightningElement, track, wire } from 'lwc';
import getAccountCountryFieldType from '@salesforce/apex/VDT_MasterDataAnalysisController.getAccountCountryFieldType';
import getCountryOptions from '@salesforce/apex/VDT_MasterDataAnalysisController.getCountryOptions';
import getCountryOptionFromReference from '@salesforce/apex/VDT_MasterDataAnalysisController.getCountryOptionFromReference';
import getCountryCodeFromProductSetup from '@salesforce/apex/VDT_ProductAdoptionController.getCountryCodeFromProductSetup';

import { showToast } from 'c/vdt_utils';

export default class Vdt_onekeyCountryInput extends LightningElement {

    @track
    _countryCodeOptions = [];

    @api
    disabled = false;
    loadCompleted = false;
    _fieldType = '';
    _countries = [];

    @wire(getAccountCountryFieldType, {})
    getAccountCountryFieldTypeCallback() {
        getAccountCountryFieldType()
        .then(response => {
            this._fieldType = response;            
            console.log('response: %O', response);
            if (response == 'PICKLIST') {
                getCountryOptions()
                .then(countryOptions => {
                    countryOptions.unshift({ label: 'All', value: 'All', selected: false})
                    this._countryCodeOptions = countryOptions;
                })
                .catch(error => {
                    this.dispatchEvent(showToast(error, 'error'));
                })
            } else if (response == 'REFERENCE') {
                getCountryOptionFromReference().then(countryOptions => {
                    countryOptions.unshift({ label: 'All', value: 'All', selected: false})
                    this._countryCodeOptions = countryOptions;
                }).catch(error => {
                    this.dispatchEvent(showToast(error, 'error'));
                });
            } else if (response == 'STRING') {
                getCountryCodeFromProductSetup()
                .then(countryOptions => {
                    countryOptions.unshift({ label: 'All', value: 'All', selected: false})
                    this._countryCodeOptions = countryOptions;
                })
                .catch(error => {
                    this.dispatchEvent(showToast(error, 'error'));
                });
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
            isValid = [...this.template.querySelectorAll('.validate')].reduce((validSoFar, inputComponent) => {
                return validSoFar && inputComponent.validate();
            }, true);
            return isValid;
        } catch (error) {
            console.log(error);
        }
    }

    handleCountryOptionSelect(evt) {
        let countries = evt.detail;
        this.dispatchEvent(new CustomEvent('countrychange', { detail: { countries } }) );
    }
}