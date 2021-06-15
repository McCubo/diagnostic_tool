import { LightningElement } from 'lwc';

import fetchFinishedCalculations from '@salesforce/apex/VDT_FieldLevelSecurityController.fetchFinishedCalculations';
import { loadScript, } from 'lightning/platformResourceLoader';
import MOMENT from '@salesforce/resourceUrl/vdt_moment';

export default class Vdt_permissionsMetadataLogs extends LightningElement {

    columns = [
        { label: 'Object Name', fieldName: 'objectname', type: 'text' },
        { label: 'Profile/Permission Set Names ', fieldName: 'permissionSetNames', type: 'text' },
        { label: 'Job Start Date', fieldName: 'jobStartDateString', type: 'text' },
        { label: 'Job End Date', fieldName: 'jobEndDateString', type: 'text' },
        { label: 'Created By', fieldName: 'createdByName', type: 'text' },
        { label: 'Status', fieldName: 'status', type: 'text' }
    ];

    _logs;
    _filteredLogs;
    _showEmpty = false;
    _showTable = false;
    _dateRangeFormat = 'MMMM yyyy';
    _jobDateFormat = 'DD-MM-yyyy, hh:mm a';
    _disableRefresh = false;
    isLoading = false;

    connectedCallback() {
        Promise.all([
            loadScript(this, MOMENT + '/moment.js')
        ])
        .then(() => {this.fetchFinishedCalculationsExecution()})
        .catch(error => {
            console.error(error);
        });
    }

    handleFilterChange(evt) {
        try {
            let filter = evt.detail;
            this._filteredLogs = this._logs
                .filter(log => {
                    if (filter.objectname && log.objectname) {
                        return log.objectname.toLowerCase().indexOf(filter.objectname.toLowerCase()) >= 0
                    }
                    if (filter.objectname && !log.objectname) {
                        return false;
                    }
                    return true;
                })
                .filter(log => {
                    if (filter.permissionSetNames && log.permissionSetNames) {
                        return log.permissionSetNames.toLowerCase().indexOf(filter.permissionSetNames.toLowerCase()) >= 0
                    }
                    if (filter.permissionSetNames && !log.permissionSetNames) {
                        return false;
                    }
                    return true;
                })
                .filter(log => filter.jobStartDate ? moment(log.VDT_Job_Start_Date__c).isSame(moment(filter.jobStartDate), 'day') : true)
                .filter(log => filter.jobEndDate ? moment(log.VDT_Job_End_Date__c).isSame(moment(filter.jobEndDate), 'day') : true)            
        } catch (error) {
            console.log(error)
        }
    }

    fetchFinishedCalculationsExecution() {
        this._disableRefresh = true;
        fetchFinishedCalculations()
        .then(data => {
            let logs = JSON.parse(JSON.stringify(data));
            this._logs = JSON.parse(JSON.stringify(data));
            if (logs.length) {
                this._logs = logs.map(log => {
                    let logEntry = {
                        id: log.record.Id,
                        objectname: log.record.VDT_Object_Name__c,
                        permissionSetNames: log.record.Permission_Set_Profile_Name__c,
                        status: log.record.Status__c,
                        jobStartDateString: log.record.VDT_Job_Start_Date__c ? moment(log.record.VDT_Job_Start_Date__c).format(this._jobDateFormat) : null,
                        VDT_Job_Start_Date__c: log.record.VDT_Job_Start_Date__c,
                        jobEndDateString: log.record.VDT_Job_End_Date__c ? moment(log.record.VDT_Job_End_Date__c).format(this._jobDateFormat) : null,
                        VDT_Job_End_Date__c: log.record.VDT_Job_End_Date__c,
                        createdByName: log.record.CreatedBy.Name
                    };
                    return logEntry;
                });
                this._filteredLogs = JSON.parse(JSON.stringify(this._logs));
                this._showTable = true;
                this._showEmpty = false;
            } else {
                this._showTable = false;
                this._showEmpty = true;
            }
        })
        .catch(error => {
            console.log(error.message);
        })
        .finally(() => this._disableRefresh = false);
    }

    handleRefresh() {
        this.fetchFinishedCalculationsExecution();
    }

}