import { LightningElement } from 'lwc';
import fetchFinishedCalculations from '@salesforce/apex/VDT_CalculationLogsController.fetchFinishedCalculations';
import { loadScript, } from 'lightning/platformResourceLoader';
import { MONTH_NAMES } from 'c/vdt_utils';
import MOMENT from '@salesforce/resourceUrl/vdt_moment';

export default class Vdt_productAdoptionLogs extends LightningElement {

    _columns = [
        { label: 'Calculation Range Start ', fieldName: 'startDateString', type: 'text' },
        { label: 'Calculation Range End', fieldName: 'endDateString', type: 'text' },
        { label: 'Job Start Date', fieldName: 'jobStartDateString', type: 'text' },
        { label: 'Job End Date', fieldName: 'jobEndDateString', type: 'text' },
        { label: 'Created By', fieldName: 'createdByName', type: 'text' },
        { label: 'Status', fieldName: 'Status__c', type: 'text' }
    ];

    _logs;
    _filteredLogs;
    _showEmpty = false;
    _showTable = false;
    _dateRangeFormat = 'MMMM yyyy';
    _jobDateFormat = 'DD-MM-yyyy, hh:mm a';
    _disableRefresh = false;  

    handleFilterChange(evt) {
        let filter = evt.detail;
        this._filteredLogs = 
            this._logs
            .filter(log => filter.jobStartDate ? moment(log.VDT_Job_Start_Date__c).isSame(moment(filter.jobStartDate), 'day') : true)
            .filter(log => filter.jobEndDate ? moment(log.VDT_Job_End_Date__c).isSame(moment(filter.jobEndDate), 'day') : true)
    }

    handleRefresh() {
        this.fetchFinishedCalculationsExecuteion();
    }

    fetchFinishedCalculationsExecuteion() {
        this._disableRefresh = true;
        fetchFinishedCalculations()
        .then(data => {
            this._logs = JSON.parse(JSON.stringify(data)).filter(logRecord => {
                return logRecord.RecordType != null && logRecord.RecordType.DeveloperName != null && logRecord.RecordType.DeveloperName == 'VDT_Product_Adoption';
            });
            if (this._logs.length) {
                this._logs.forEach(log => {
                    log.startDateString = log.Start_Date__c ? `${log.Start_Year__c}${log.Start_Month__c ? ' ' + MONTH_NAMES[log.Start_Month__c] : ''}` : 'ALL TIME';
                    log.endDateString = log.End_Date__c ? `${log.End_Year__c} ${log.End_Month__c ?' ' + MONTH_NAMES[log.End_Month__c] : ''}` : 'ALL TIME';
                    log.jobStartDateString = log.VDT_Job_Start_Date__c ? moment(log.VDT_Job_Start_Date__c).format(this._jobDateFormat) : null;
                    log.jobEndDateString = log.VDT_Job_End_Date__c ? moment(log.VDT_Job_End_Date__c).format(this._jobDateFormat) : null;
                    log.createdByName = log.CreatedBy.Name;
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