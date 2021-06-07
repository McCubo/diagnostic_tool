import { LightningElement } from 'lwc';

export default class Vdt_territoryLogsFilter extends LightningElement {

    _filter = {
        country: '',
        territory: '',
        jobStartDate: '',
        jobEndDate: ''
    }

    handleTerritoryChange(event) {
        this._filter.territory = event.detail.value;
        this.dispatchEvent(new CustomEvent('filterchange', {detail: this._filter}));
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