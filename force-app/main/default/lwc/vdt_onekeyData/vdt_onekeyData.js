import { LightningElement, track } from 'lwc';
import searchExistingCalculations from '@salesforce/apex/VDT_MasterDataAnalysisController.searchExistingCalculations';
export default class Vdt_onekeyData extends LightningElement {
    
    _showCalculationButton = false;
    _showCalculationSection = false;
    _filterDisabled = false;
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
        this._showCalculationButton = true;
        this._showCalculationSection = false;
        this._filterDisabled = true;
        this._filter = event.detail;
        this.countries = event.detail.countries;
        searchExistingCalculations({ jsonSearchParameters: JSON.stringify(this._filter) }).then(response => {
            this._calculation = response;
            this._showCalculationSection = true;
        }).catch(error => {
            console.log('Error in promise: %O', error);
        }).finally(() => {
            this._filterDisabled = false;
        });
    }

}