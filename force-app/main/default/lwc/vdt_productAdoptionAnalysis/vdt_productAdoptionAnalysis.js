import { api, LightningElement, track, wire } from 'lwc';

import searchExistingCalculations from '@salesforce/apex/VDT_ProductAdoptionController.searchExistingCalculations';
import recalculateProductAdoption from '@salesforce/apex/VDT_ProductAdoptionController.recalculateProductAdoption';
import validateCanRunCalculation from '@salesforce/apex/VDT_ObjectsCalculationController.validateCanRunCalculation';
import { showToast } from 'c/vdt_utils';

import refreshMonitoringMessageChannel from '@salesforce/messageChannel/vdt_refreshMonitoring__c';
import { publish, MessageContext } from 'lightning/messageService';
export default class Vdt_productAdoptionAnalysis extends LightningElement {

    @wire(MessageContext)
    _messageContext;

    @api
    internationalCountry;

    _showCalculationButton = false;
    _showCalculationSection = false;
    _filterDisabled = false;
    _calculationInProgress = false;
    
    disabled = false;
    @track
    _calculation = {}
    _filter;

    get _showCalculation() {
        return !!this._calculation.data;
    }
    
    get _showEmpty() {
        return !!this._calculation.data === false;
    }

    get _emptyMessage() {
        return `No information was found for the selected filter criteria`;
    }

    handleShowInfo(event) {
        this._showCalculationSection = false;
        this._filterDisabled = true;
        this._filter = event.detail;
        searchExistingCalculations({ jsonSearchParameters: JSON.stringify(this._filter) }).then(response => {
            this._calculation = response;
            this._showCalculationSection = true;
            this._showCalculationButton = true;
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
                recalculateProductAdoption({jsonSearchParameters: JSON.stringify(this._filter)})
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