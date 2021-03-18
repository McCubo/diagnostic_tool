import { LightningElement, track } from 'lwc';
import searchExistingCalculations from '@salesforce/apex/VDT_MasterDataAnalysisController.searchExistingCalculations';
import recalculateMasterAnalysis from '@salesforce/apex/VDT_MasterDataAnalysisController.recalculateMasterAnalysis';
import validateCanRunCalculation from '@salesforce/apex/VDT_ObjectsCalculationController.validateCanRunCalculation';

import { showToast } from 'c/vdt_utils';
export default class Vdt_onekeyData extends LightningElement {
    
    _showCalculationButton = false;
    _showCalculationSection = false;
    _filterDisabled = false;
    _calculationInProgress = false;
    _filter;
    countries = [];

    @track 
    _calculation = {};

    get _showEmpty() {
        return !!this._calculation.data === false;
    }

    get _showCalculation() {
        return !!this._calculation.data;
    }

    get _emptyMessage() {
        return `Calculations are not available for ${this._filter.countries} for the selected time period.`;
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
                recalculateMasterAnalysis({jsonSearchParameters: JSON.stringify(this._filter)})
                .then(() => {
                    this._calculation.status = 'In Progress';
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