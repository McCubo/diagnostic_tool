import { api, LightningElement } from 'lwc';

export default class Vdt_onekeyCountryInput extends LightningElement {

    _countryCodeOptions = [
        { label: 'All', value: 'All', selected: false}, 
        { label: 'IE', value: 'IE', selected: false}, 
        { label: 'GB', value: 'GB', selected: false}, 
        { label: 'PL', value: 'PL', selected: false}, 
        { label: 'IT', value: 'IT', selected: false}, 
        { label: 'FR', value: 'FR', selected: false}
    ];

    @api
    disabled = false;
    
    @api
    validate() {
        const isValid = [...this.template.querySelectorAll('.validate')].reduce((validSoFar, inputComponent) => {
                return validSoFar && inputComponent.validate();
            }, true);
        return isValid;
    }

    handleCountryOptionSelect(evt) {
        let countries = evt.detail;
        this.dispatchEvent(new CustomEvent('countrychange', { detail: { countries } }) );
    }
}