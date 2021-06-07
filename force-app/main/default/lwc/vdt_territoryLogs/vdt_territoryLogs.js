import { LightningElement } from 'lwc';
import { loadScript, } from 'lightning/platformResourceLoader';
import MOMENT from '@salesforce/resourceUrl/vdt_moment';
import fetchFinishedCalculations from '@salesforce/apex/VDT_TerritoryAnalysisController.fetchFinishedCalculations';
import deleteCalculationRecords from '@salesforce/apex/VDT_TerritoryAnalysisController.deleteCalculationRecords';
import { showToast } from 'c/vdt_utils';

export default class Vdt_territoryLogs extends LightningElement {

    _columns = [
        { label: 'Country', fieldName: 'country' },
        { label: 'Territory ', fieldName: 'territory', type: 'text' },
        { label: 'Total Transactions ', fieldName: 'totalTransactions', type: 'number' },
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

    handleDelete() {        
        let selectedRecords = this.template.querySelector('lightning-datatable').getSelectedRows();
        if (selectedRecords.length > 0) {
            this.isLoading = true;
            let ids = selectedRecords.map(record => record.id);
            console.log(ids);
            deleteCalculationRecords({ids: ids}).then(result => {
                this.dispatchEvent(showToast('Transaction record have been successfully deleted', 'success'));
                this.fetchFinishedCalculationsExecuteion();
            }).catch(error => {
                console.error(error)
            }).finally(() => { this.isLoading = false;})
        } else {
            this.dispatchEvent(showToast('Select at least one record from the table in order to delete them', 'warning'));
        }
    }

    handleRefresh() {
        this.fetchFinishedCalculationsExecuteion();
    }

    handleFilterChange(evt) {
        try {
            let filter = evt.detail;
            console.log('filter: %O', JSON.stringify(filter))
            this._filteredLogs = 
                this._logs
                .filter(log => {
                    if (filter.country && log.country) {
                        return log.country.toLowerCase().indexOf(filter.country.toLowerCase()) >= 0
                    }
                    if (filter.country && !log.country) {
                        return false;
                    }
                    return true;
                })
                .filter(log => {
                    if (filter.territory && log.territory) {
                        return log.territory.toLowerCase().indexOf(filter.territory.toLowerCase()) >= 0
                    }
                    if (filter.territory && !log.territory) {
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

    connectedCallback() {
        Promise.all([
            loadScript(this, MOMENT + '/moment.js')
        ])
        .then(() => {this.fetchFinishedCalculationsExecuteion()})
        .catch(error => {
            console.log(error.message);
        });
    }

    fetchFinishedCalculationsExecuteion() {
        this._disableRefresh = true;
        fetchFinishedCalculations()
        .then(data => {
            let logs = JSON.parse(JSON.stringify(data));
            this._logs = JSON.parse(JSON.stringify(data));
            if (logs.length) {
                this._logs = logs.map(log => {
                    let logEntry = {
                        id: log.record.Id,
                        country: log.record.VDT_Country__c,
                        territory: log.record.Territory__c,
                        totalTransactions: log.totalTransactions,
                        status: log.record.Status__c,
                        jobStartDateString: log.record.VDT_Job_Start_Date__c ? moment(log.record.VDT_Job_Start_Date__c).format(this._jobDateFormat) : null,
                        jobEndDateString: log.record.VDT_Job_End_Date__c ? moment(log.record.VDT_Job_End_Date__c).format(this._jobDateFormat) : null,
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

}