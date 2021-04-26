import { LightningElement, track } from 'lwc';

export default class Vdt_objects extends LightningElement {
    
    _data;
    @track _fieldvalueoccurrence = {};

    get _showFieldValueOccurrenceTab() {
        return !!this._fieldvalueoccurrence.data;
    }

    handleCalculationChange(evt) {
        this._data = evt.detail.data;
    }

    handleFieldValueOccurenceChange(event) {
        this._fieldvalueoccurrence = event.detail;
    }
}