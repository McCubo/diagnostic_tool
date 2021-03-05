import { LightningElement, wire, api, track } from 'lwc';
import fetchObjectOptions from '@salesforce/apex/VDT_ObjectsCalculationFilterController.fetchObjectOptions';

export default class Vdt_objectsCalculationFilter extends LightningElement {
    _objectOptions = [];
    _selectedObject = '';

    @track
    _filter = {
        objectName: '',
        startYear: null,
        startMonth: null,
        endYear: null,
        endMonth: null,
        fullCalculation: false
    }

    get _rangePickerVisible() {
        return !this._filter.fullCalculation;
    }

    @api
    disabled = false;

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

    handleFullToggleChange(evt) {
        const rangePicker = this.template.querySelector('c-vdt_date-range-picker');
        if (rangePicker) {
            this.template.querySelector('c-vdt_date-range-picker').clearRange();
        }
        this._filter.fullCalculation = evt.target.checked;
    }

    handleObjectSelected(evt) {
        this._filter.objectName = evt.detail;
    }

    handleDateRangeChange(evt) {
        Object.assign(this._filter, evt.detail);
    }

    handleDiagnoseCalculationClick() {
        const isInputsCorrect = [...this.template.querySelectorAll('.validate')]
            .reduce((validSoFar, inputComponent) => {
                return validSoFar && inputComponent.validate();
            }, true);
        if (isInputsCorrect) {
            this.dispatchEvent(new CustomEvent('diagnose', { detail: this._filter }) );
        }
    }
}