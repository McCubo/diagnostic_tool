import { LightningElement, api } from 'lwc';

export default class Vdt_productAdoptionTableFilters extends LightningElement {


    @api
    disabled = false;

    _filter = {
        startYear: null,
        startMonth: null,
        endYear: null,
        endMonth: null,
        productTypes: []
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