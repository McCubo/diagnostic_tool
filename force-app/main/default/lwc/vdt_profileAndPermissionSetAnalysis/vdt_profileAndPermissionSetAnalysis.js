import { LightningElement, track } from 'lwc';

export default class Vdt_profileAndPermissionSetAnalysis extends LightningElement {

    _showCalculationButton = false;
    _showCalculationSection = false;
    _filterDisabled = false;
    _calculationInProgress = false;
    _filter;

    @track 
    _calculation = {};

    get _showEmpty() {
        return false;
        // return !!this._calculation.data === false;
    }

    get _showCalculation() {
        return true;
        // return !!this._calculation.data;
    }

    get _emptyMessage() {
        return `No Calculations have been run for ${this._filter.profilesOrPermissionSetsLabels} yet.`;
    }

    handleShowInfo(event) {
        this._filter = event.detail;
        this._showCalculationSection = true;
        this._showCalculationButton = true;
    }
}