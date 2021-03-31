import { LightningElement } from 'lwc';

export default class Vdt_productAdoptionLogsFilter extends LightningElement {

    _filter = {
        jobStartDate: '',
        jobEndDate: ''
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