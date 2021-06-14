import { LightningElement, track } from 'lwc';

import validateCanRunCalculation from '@salesforce/apex/VDT_ObjectsCalculationController.validateCanRunCalculation';
import getProfilesAndPermissionSets from '@salesforce/apex/VDT_FieldLevelSecurityController.searchExistingProfilePermissionSetCalculations';
export default class Vdt_profileAndPermissionSetAnalysis extends LightningElement {

    _showCalculationButton = false;
    _showCalculationSection = false;
    _filterDisabled = false;
    _calculationInProgress = false;
    _filter;

    @track 
    _calculation = {};

    get _showEmpty() {
        return !!this._calculation.data === false;
    }

    get _showCalculation() {
        return !!this._calculation.data;
    }

    get _emptyMessage() {
        return `No Calculations have been run for ${this._filter.objectNames} yet.`;
    }

    handleShowInfo(event) {
        this._showCalculationSection = false;
        this._filterDisabled = true;
        this._filter = event.detail;
        getProfilesAndPermissionSets({ jsonSearchParameters: JSON.stringify(this._filter) }).then(response => {
            this._calculation = response;
            this._showCalculationSection = true;
            this._showCalculationButton = true;
        }).catch(error => {
            console.error('Error in promise: %O', error);
        }).finally(() => {
            this._filterDisabled = false;
        });

    }
}