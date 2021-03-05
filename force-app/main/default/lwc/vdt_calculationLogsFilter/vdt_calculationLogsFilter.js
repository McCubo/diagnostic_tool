import { LightningElement } from 'lwc';

export default class Vdt_calculationLogsFilter extends LightningElement {
    _filter = {
        objectName: '',
        jobStartDate: '',
        jobEndDate: ''
    }

    handleObjectNameChange(evt) {
        this._filter.objectName = evt.detail.value;
        this.dispatchEvent(new CustomEvent('filterchange', {detail: this._filter}));
    }

    handleJobStartDateChange(evt) {
        this._filter.jobStartDate = evt.detail.value;
        this.dispatchEvent(new CustomEvent('filterchange', {detail: this._filter}));
    }

    handleJobEndDateChange(evt) {
        this._filter.jobEndDate = evt.detail.value;
        this.dispatchEvent(new CustomEvent('filterchange', {detail: this._filter}));
    }
}