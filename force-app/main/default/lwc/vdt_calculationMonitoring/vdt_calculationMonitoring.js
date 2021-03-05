import { LightningElement, wire } from 'lwc';
import getCalculationsInProgress from '@salesforce/apex/VDT_CalculationMonitoringController.getCalculationsInProgress';
import MOMENT from '@salesforce/resourceUrl/vdt_moment';
import { loadScript, } from 'lightning/platformResourceLoader';
import { MONTH_NAMES } from 'c/vdt_utils';
import { subscribeToMessageChannel, unsubscribeToMessageChannel } from 'c/vdt_utils';
import { MessageContext } from 'lightning/messageService';
import refreshMonitoringMessageChannel from '@salesforce/messageChannel/vdt_refreshMonitoring__c';

export default class Vdt_calculationMonitoring extends LightningElement {
    _columns = [
        { label: 'Object/Entity', fieldName: 'VDT_Object_Name__c' },
        { label: 'Calculation Range Start ', fieldName: 'startDateString', type: 'text' },
        { label: 'Calculation Range End', fieldName: 'endDateString', type: 'text' },
        { label: 'Job Start Date', fieldName: 'jobStartDateString', type: 'datetime' },
        { label: 'Created By', fieldName: 'createdByName', type: 'text' },
        { label: 'Status', fieldName: 'Status__c', type: 'text' },
    ];
    _monitoringData = {};
    _showEmpty = false;
    _showTable = false;
    _inProgressNum;
    _inQueueNum;
    _dateRangeFormat = 'MMMM yyyy';
    _jobDateFormat = 'DD-MM-yyyy, hh:mm a';
    _refreshMonitoringSubscription;
    _disableRefresh = false;

    @wire(MessageContext)
    _messageContext;

    handleRefresh() {
        this.getCalculationsInProgressExecution();
    }

    getCalculationsInProgressExecution() {
        this._disableRefresh = true;
        getCalculationsInProgress()
        .then(data => {
            this._monitoringData = JSON.parse(JSON.stringify(data));
            if (this._monitoringData.calculationRecords.length) {
                this._monitoringData.calculationRecords.forEach(record => {
                    record.startDateString = record.Start_Date__c ? `${record.Start_Year__c}${record.Start_Month__c ? ' ' + MONTH_NAMES[record.Start_Month__c] : ''}` : 'ALL TIME';
                    record.endDateString = record.End_Date__c ? `${record.End_Year__c} ${record.End_Month__c ?' ' + MONTH_NAMES[record.End_Month__c] : ''}` : 'ALL TIME';
                    record.jobStartDateString = record.VDT_Job_Start_Date__c ? moment(record.VDT_Job_Start_Date__c).format(this._jobDateFormat) : null;
                    record.createdByName = record.CreatedBy.Name;
                })
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
        .finally(() => {
            this._disableRefresh = false;
        });
    }
    
    connectedCallback() {
        this._refreshMonitoringSubscription = subscribeToMessageChannel(
            this._refreshMonitoringSubscription,
            refreshMonitoringMessageChannel,
            this.getCalculationsInProgressExecution.bind(this),
            this._messageContext
        );
        
        Promise.all([
            loadScript(this, MOMENT + '/moment.js')
        ])
        .then(() => {
           this.getCalculationsInProgressExecution();
        })
        .catch(error => {
            console.log(error.message);
        });
    }

    renderedCallback() {
        console.log('rendered');
    }
}