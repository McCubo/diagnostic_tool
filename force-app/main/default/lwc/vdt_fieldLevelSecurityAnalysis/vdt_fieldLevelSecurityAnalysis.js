import { LightningElement, track } from 'lwc';
import validateCanRunCalculation from '@salesforce/apex/VDT_ObjectsCalculationController.validateCanRunCalculation';
import searchExistingCalculations from '@salesforce/apex/VDT_FieldLevelSecurityController.searchExistingCalculations';
import recalculateFieldLevelSecurityAnalysis from '@salesforce/apex/VDT_FieldLevelSecurityController.recalculateFieldLevelSecurityAnalysis';
import { showToast } from 'c/vdt_utils';

export default class Vdt_fieldLevelSecurityAnalysis extends LightningElement {

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
        console.log('this._filter: %O', JSON.stringify(this._filter));
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
                recalculateFieldLevelSecurityAnalysis({jsonSearchParameters: JSON.stringify(this._filter)})
                .then(() => {
                    this._calculation.status = 'In Progress';
                    publish(this._messageContext, refreshMonitoringMessageChannel);
                })
                .catch(error => {
                     console.log(error);
                });
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