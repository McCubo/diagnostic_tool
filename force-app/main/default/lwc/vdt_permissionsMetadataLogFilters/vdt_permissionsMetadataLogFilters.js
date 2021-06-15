import { LightningElement } from 'lwc';

export default class Vdt_permissionsMetadataLogFilters extends LightningElement {

    _filter = {
        objectname: '',
        permissionSetNames: '',
        jobStartDate: '',
        jobEndDate: ''
    }

    handlePermissionNameChange(event) {
        this._filter.permissionSetNames = event.detail.value;
        this.dispatchEvent(new CustomEvent('filterchange', {detail: this._filter}));
    }

    handleObjectNameChange(evt) {
        this._filter.objectname = evt.detail.value;
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