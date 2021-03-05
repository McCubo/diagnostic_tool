import { LightningElement } from 'lwc';

export default class Vdt_objects extends LightningElement {
    _data;

    handleCalculationChange(evt) {
        this._data = evt.detail.data;
    }
}