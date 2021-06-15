import { LightningElement } from 'lwc';
import fetchFinishedCalculations from '@salesforce/apex/VDT_ProductAdoptionController.fetchFinishedCalculations';
import { loadScript, } from 'lightning/platformResourceLoader';
import { MONTH_NAMES } from 'c/vdt_utils';
import MOMENT from '@salesforce/resourceUrl/vdt_moment';

export default class Vdt_productAdoptionLogs extends LightningElement {

    _columns = [
        { label: 'Country ', fieldName: 'country', type: 'text' },
        { label: 'Calculation Range Start ', fieldName: 'startDateString', type: 'text' },
        { label: 'Calculation Range End', fieldName: 'endDateString', type: 'text' },
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

    handleFilterChange(evt) {
        try {
            let filter = evt.detail;
            console.log('filter: %O', JSON.stringify(filter));
            console.log('this._logs: %O', JSON.stringify(this._logs))
            this._filteredLogs = 
                this._logs
                .filter(log => filter.country ? log.country.toLowerCase().includes(filter.country) : true)
                .filter(log => filter.jobStartDate ? moment(log.VDT_Job_Start_Date__c).isSame(moment(filter.jobStartDate), 'day') : true)
                .filter(log => filter.jobEndDate ? moment(log.VDT_Job_End_Date__c).isSame(moment(filter.jobEndDate), 'day') : true)            
        } catch (error) {
            console.log(error);
        }
    }

    handleRefresh() {
        this.fetchFinishedCalculationsExecuteion();
    }

    fetchFinishedCalculationsExecuteion() {
        this._disableRefresh = true;
        fetchFinishedCalculations()
        .then(data => {
            let parsedLogs = JSON.parse(JSON.stringify(data));
            if (parsedLogs.length) {
                this._logs = parsedLogs.map(log => {
                    let logEntry = {
                        country: log.record.VDT_Country__c,
                        startDateString : log.record.Start_Date__c ? `${log.record.Start_Year__c}${log.record.Start_Month__c ? ' ' + MONTH_NAMES[log.record.Start_Month__c] : ' ' + MONTH_NAMES[1]}` : 'ALL TIME',
                        endDateString : log.record.End_Date__c ? `${log.record.End_Year__c} ${log.record.End_Month__c ?' ' + MONTH_NAMES[log.record.End_Month__c] : ' ' + MONTH_NAMES[1]}` : 'ALL TIME',
                        jobStartDateString : log.record.VDT_Job_Start_Date__c ? moment(log.record.VDT_Job_Start_Date__c).format(this._jobDateFormat) : null,
                        jobEndDateString : log.record.VDT_Job_End_Date__c ? moment(log.record.VDT_Job_End_Date__c).format(this._jobDateFormat) : null,
                        createdByName : log.record.CreatedBy.Name,
                        VDT_Job_Start_Date__c : log.record.VDT_Job_Start_Date__c,
                        VDT_Job_End_Date__c : log.record.VDT_Job_End_Date__c,
                        status: log.record.Status__c
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

    connectedCallback() {
        Promise.all([
            loadScript(this, MOMENT + '/moment.js')
        ])
        .then(() => {this.fetchFinishedCalculationsExecuteion()})
        .catch(error => {
            console.log(error.message);
        });
    }
}