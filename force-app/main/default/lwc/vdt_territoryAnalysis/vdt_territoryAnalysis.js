import { LightningElement, track, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import { showToast } from 'c/vdt_utils'
import searchExistingCalculations from '@salesforce/apex/VDT_TerritoryAnalysisController.searchExistingCalculations';
import recalculateTerritoryAnalysis from '@salesforce/apex/VDT_TerritoryAnalysisController.recalculateTerritoryAnalysis';
import validateCanRunCalculation from '@salesforce/apex/VDT_ObjectsCalculationController.validateCanRunCalculation';
import refreshMonitoringMessageChannel from '@salesforce/messageChannel/vdt_refreshMonitoring__c';

export default class Vdt_territoryAnalysis extends LightningElement {

    calculationRecordId = null;
    _showCalculationButton = false;
    _showCalculationSection = false;
    _filterDisabled = false;
    _calculationInProgress = false;
    _filter;
    countries = [];

    @wire(MessageContext)
    _messageContext;

    @track 
    _calculation = {};

    get _showEmpty() {
        return !!this._calculation.data === false;
    }

    get _showCalculation() {
        return !!this._calculation.data;
    }

    get _emptyMessage() {
        return `No Calculations have been run for ${this._filter.countries} yet.`;
    }

    handleShowInfo(event) {        
        this._showCalculationSection = false;
        this._filterDisabled = true;
        this._filter = event.detail;
        this.countries = event.detail.countries;
        searchExistingCalculations({ jsonSearchParameters: JSON.stringify(this._filter) }).then(response => {
            this._calculation = response;
            this._showCalculationSection = true;
            this._showCalculationButton = true;
            this.calculationRecordId = response.detailData;
        }).catch(error => {
            console.log('Error in promise: %O', error);
        }).finally(() => {
            this._filterDisabled = false;
        });
    }

    handleCalculate(event) {
        this._calculationInProgress = true;
        validateCanRunCalculation()
        .then((response) => {
            if (response) {
                recalculateTerritoryAnalysis({jsonSearchParameters: JSON.stringify(this._filter)})
                .then(() => {
                    this._calculation.status = 'In Progress';
                    publish(this._messageContext, refreshMonitoringMessageChannel);
                })
                .catch(error => {
                     console.log(error);
                })
            } else {
                this.dispatchEvent(showToast('Limit of calculation requests has been reached', 'warning'));
            }
        })
        .catch((error) => {
            this.dispatchEvent(showToast(error, 'error'));
        })
        .finally(() => this._calculationInProgress = false);;
    }
}