import { LightningElement, api } from 'lwc';

export default class Vdt_numberKpiIndicator extends LightningElement {
    MODES = {
        percentage: 'percentage',
        scalar: 'scalar'
    }

    _mode = '';
    _valueStyle = 'current-value value-neutral';
    _showMaxValue = false;
    _valueString = '';
    _currentValue = 0;

    @api
    get currentValue() {
        return this._currentValue;
    }
    set currentValue(val) {
        this._currentValue = val;
        this.initMode();
    }
    @api
    minValue = 0;
    @api
    maxValue = 0;
    @api
    correctValueTreshold = 0;
    @api
    warningValueTreshold = 0;
    @api
    showMaxValue;
    @api
    get mode() {
        return this._mode;
    }
    set mode(val) {
        this._mode = val;
    }
    @api 
    title = '';

    isPercentage() {
        return _mode === this.MODES.percentage;
    }

    resolveCurrentValueStateStyling() {
        if (this.maxValue) {
            let percentageOfMax = (this._currentValue/this.maxValue)*100;
            if (percentageOfMax >= this.correctValueTreshold) {
                this._valueStyle += ' value-correct';
            } else if (percentageOfMax >= this.warningValueTreshold) {
                this._valueStyle += ' value-warning';
            } else {
                this._valueStyle += ' value-wrong';
            }
        }
    }

    initMode() {
        if (this._mode === this.MODES.percentage) {
            this._showMaxValue = false;
            this._valueString = `${this._currentValue}%`;
            this._valueStyle = 'current-value';
        } else if (this._mode === this.MODES.scalar) {
            this._valueString = this._currentValue;
            this._valueStyle = this.showMaxValue ? 'current-value-with-max' : 'current-value';
        }
        this.resolveCurrentValueStateStyling();
    }

    connectedCallback() {
        this.initMode();
    }

    renderedCallback() {
        if (this._mode === this.MODES.scalar && this.showMaxValue) {
            let maxValueNumberOfDigits = this.maxValue.toString().length;
            const maxValueElement = this.template.querySelector('.max-value');
            maxValueElement.style.setProperty('--separator-width', `${4 * maxValueNumberOfDigits}%`);
        }
    }
}