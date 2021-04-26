import { LightningElement, api } from 'lwc';

export default class Vdt_calculationButton extends LightningElement {
    
    @api
    description;

    get buttonLabel() {
        if (this.description) {
            return this._buttonLabel +' ('+ this.description + ')';
        }
        return this._buttonLabel;
    }

    _buttonLabel = 'Calculate';
    _calculationStatus = '';
    _buttonDisabled = false;

    get _showLastCalculation() {
        return !!this.lastCalculationDate;
    }

    @api
    lastCalculationDate;
    @api
    get calculationStatus() {
        return this._calculationStatus;
    }
    set calculationStatus(val) {
        this._calculationStatus = val;
        if (val) {
            this._buttonLabel = val === 'In Progress' ? 'Calculation In Progress...' : 'Recalculate';
        } else {
            this._buttonLabel = 'Calculate'
        }
        this._buttonDisabled = val === 'In Progress';
    }

    handleButtonClick() {
        this.dispatchEvent(new CustomEvent('calculate'));
    }
}