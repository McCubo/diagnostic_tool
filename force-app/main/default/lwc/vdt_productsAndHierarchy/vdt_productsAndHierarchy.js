import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import onekeyCountryChannel from '@salesforce/messageChannel/vdt_onekeyCountryChannel__c';
import getProductCountryFieldType from '@salesforce/apex/VDT_ProductAdoptionController.getProductCountryFieldType';
import getCountryOptions from '@salesforce/apex/VDT_ProductAdoptionController.getCountryOptions';
import getCountryOptionFromReference from '@salesforce/apex/VDT_ProductAdoptionController.getCountryOptionFromReference';
import getCountryCodeFromProductSetup from '@salesforce/apex/VDT_ProductAdoptionController.getCountryCodeFromProductSetup';
import getInternationalCountryValue from '@salesforce/apex/VDT_ProductAdoptionController.getInternationalCountryValue';
import { showToast } from 'c/vdt_utils';
export default class Vdt_productsAndHierarchy extends LightningElement {
    
    @wire(MessageContext)
    messageContext;

    @wire(getInternationalCountryValue)
    internationalCountry;
    
    _countryOptions = [];

    _countries = [];

    connectedCallback() {
        getProductCountryFieldType()
        .then(response => {
            if (response == 'PICKLIST') {
                getCountryOptions().then(picklistResponse => {
                    this._countryOptions = picklistResponse;
                }).catch(error => {
                    this.dispatchEvent(showToast(error, 'error'));
                });
            } else if (response == 'REFERENCE') {
                getCountryOptionFromReference().then(referenceResponse => {
                    this._countryOptions = referenceResponse;
                }).catch(error => {
                    this.dispatchEvent(showToast(error, 'error'));
                });
            } else if (response == 'STRING') {
                getCountryCodeFromProductSetup().then(stringResponse => {
                    this._countryOptions = stringResponse;
                }).catch(error => {
                    this.dispatchEvent(showToast(error, 'error'));
                });
            }
        }).catch(error => {
            this.dispatchEvent(showToast(error, 'error'));
        }).finally(() => {

        });
    }

    handleCountryChange(event) {
        const payload = { countries: event.detail };
        publish(this.messageContext, onekeyCountryChannel, payload);
        this._countries = event.detail;
    }

}