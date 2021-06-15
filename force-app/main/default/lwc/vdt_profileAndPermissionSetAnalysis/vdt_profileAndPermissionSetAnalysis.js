import { LightningElement, track, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';

import validateCanRunCalculation from '@salesforce/apex/VDT_ObjectsCalculationController.validateCanRunCalculation';
import getProfilesAndPermissionSets from '@salesforce/apex/VDT_FieldLevelSecurityController.searchExistingProfilePermissionSetCalculations';
import recalculateFlsAndObjectPermissionAnalysis from '@salesforce/apex/VDT_FieldLevelSecurityController.recalculateFlsAndObjectPermissionAnalysis';
import { showToast } from 'c/vdt_utils';
import refreshMonitoringMessageChannel from '@salesforce/messageChannel/vdt_refreshMonitoring__c';

export default class Vdt_profileAndPermissionSetAnalysis extends LightningElement {

    _showCalculationButton = false;
    _showCalculationSection = false;
    _filterDisabled = false;
    _calculationInProgress = false;
    _filter;

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
        return `No Calculations have been run for ${this._filter.profilesOrPermissionSetsLabels} yet.`;
    }

    handleCalculate(event) {
        this._calculationInProgress = true;
        validateCanRunCalculation()
        .then((response) => {
            if (response) {
                this._calculation.status = 'In Progress';
                recalculateFlsAndObjectPermissionAnalysis({jsonSearchParameters: JSON.stringify(this._filter)})
                .then(() => {                    
                    publish(this._messageContext, refreshMonitoringMessageChannel);
                })
                .catch(error => {
                     console.error(error);
                })
            } else {
                this.dispatchEvent(showToast('Limit of calculation requests has been reached', 'warning'));
            }
        })
        .catch((error) => {
            this.dispatchEvent(showToast(error, 'error'));
        })
        .finally(() => this._calculationInProgress = false);
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