import { LightningElement, wire, track } from 'lwc';

import searchExistingCalculations from '@salesforce/apex/VDT_ObjectsCalculationController.searchExistingCalculations';
import validateCanRunCalculation from '@salesforce/apex/VDT_ObjectsCalculationController.validateCanRunCalculation';
import recalculateObjectFieldSummary from '@salesforce/apex/VDT_ObjectsCalculationController.recalculateObjectFieldSummary';
import searchExistingFieldOccurrenceCalculations from '@salesforce/apex/VDT_ObjectsCalculationController.searchExistingFieldOccurrenceCalculations';
import recalculateFieldValuesOccurrences from '@salesforce/apex/VDT_ObjectsCalculationController.recalculateFieldValuesOccurrences';

import refreshMonitoringMessageChannel from '@salesforce/messageChannel/vdt_refreshMonitoring__c';
import { publish, MessageContext } from 'lightning/messageService';

import { showToast } from 'c/vdt_utils'

export default class Vdt_objectsCalculation extends LightningElement {
    _showCalculationButton = false;
    _lastCalculationDate = '';
    _calculationStatus = '';
    _data;
    _filter;
    _calculationInProgress = false;
    _showCalculationSection = false;
    _showFieldValuesButton = false;
    _filterDisabled = false;
    @track _calculation = {};
    @track _fieldOccurenceCalculation = {};

    get _emptyMessage() {
        return `Calculation is not available for ${this._filter.objectName} in that date range.`;
    }

    get _showEmpty() {
        return !!this._calculation.data === false;
    }

    get _showCalculation() {
        return !!this._calculation.data;
    }

    @wire(MessageContext)
    _messageContext;

    async handleDiagnose(evt) {
        this._filter = evt.detail;
        this._showCalculationSection = false;
        this._filterDisabled = true;

        try {
            let calculationResponse =  await searchExistingCalculations({calculationParametersString: JSON.stringify(this._filter)});
            let fieldOccurenceResponse = await searchExistingFieldOccurrenceCalculations({calculationParametersString: JSON.stringify(this._filter)});
            this._calculation = calculationResponse;
            this._fieldOccurenceCalculation = fieldOccurenceResponse;
            this._showCalculationButton = true;            
            this._showCalculationSection = true;
            this._showFieldValuesButton = true;

            this.dispatchEvent(new CustomEvent('calculationchange', { detail: this._calculation }));
            this.dispatchEvent(new CustomEvent('fieldvalueoccurrencechange', { detail: this._fieldOccurenceCalculation }));
        } catch (error) {
            console.log(error);
        } finally {
            this._filterDisabled = false;
        }        

    }

    handleCalculate() {
        this._calculationInProgress = true;
        validateCanRunCalculation({})
        .then(valid => {
            if (valid) {
                recalculateObjectFieldSummary({
                    calculationParametersString: JSON.stringify(this._filter)
                })
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
        .finally(() => this._calculationInProgress = false);
    }

    handleCalculateValuesOccurrences() {
        this._calculationInProgress = true;
        validateCanRunCalculation({})
        .then(valid => {
            if (valid) {
                recalculateFieldValuesOccurrences({
                    calculationParametersString: JSON.stringify(this._filter)
                })
                .then(() => {
                    this._fieldOccurenceCalculation.status = 'In Progress';
                    
                    publish(this._messageContext, refreshMonitoringMessageChannel);
                })
                .catch(error => {
                    console.log(error);
                })
            } else {
                this.dispatchEvent(showToast('Limit of calculation requests has been reached', 'warning'));
            }
        })
        .finally(() => this._calculationInProgress = false);        
    }
    
}