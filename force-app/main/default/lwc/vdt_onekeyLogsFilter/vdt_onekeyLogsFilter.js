import { LightningElement } from 'lwc';

export default class Vdt_onekeyLogsFilter extends LightningElement {

    _filter = {
        country: '',
        jobStartDate: '',
        jobEndDate: ''
    }

    handleCountryChange(evt) {
        this._filter.country = evt.detail.value;
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