import { LightningElement, api, wire } from 'lwc';
import fetchObjectOptions from '@salesforce/apex/VDT_FieldLevelSecurityController.fetchObjectOptions';

export default class Vdt_fieldLevelSecurityFilter extends LightningElement {

    @api
    disabled = false;
    _filter = {
        objectNames: null
    }
    _objectOptions = [];

    @wire(fetchObjectOptions, {})
    fetchObjectOptionsCallback ({error, data}) {
        if (error) {
            console.log('error', error);
        } else if (data) {
            this._objectOptions = JSON.parse(JSON.stringify(data));
            this._objectOptions.forEach(option => {
                option.secondaryLabel = option.value;
                option.title = `${option.label} / ${option.value}`;
            });
        }
    }

    handleObjectSelected(evt) {
        this._filter.objectNames = evt.detail;
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