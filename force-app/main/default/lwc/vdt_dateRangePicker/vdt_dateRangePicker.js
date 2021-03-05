import { LightningElement, api, wire, track } from 'lwc';
import getStartDateYearDecrement from '@salesforce/apex/VDT_DateRangePickerController.getStartDateYearDecrement';

export default class Vdt_dateRangePicker extends LightningElement {
    @track
    _dateRange = {
        startYear: null,
        startMonth: null,
        endYear: null,
        endMonth: null
    }
    _startYearDecrement;

    get _minStartYear() {
        return (new Date().getFullYear()) - this._startYearDecrement;
    }

    get _maxStartYear() {
        return new Date().getFullYear();
    }
    
    get _minEndYear() {
        return this._dateRange.startYear;
    }
    
    get _maxEndYear() {
        return new Date().getFullYear();
    }
    
    get _minEndMonth() {
        let minMonth = 0;
        if (this._dateRange.endYear === this._dateRange.startYear) {
            minMonth = this._dateRange.startMonth;
        }
        return minMonth;
    }

    get _endYearDisabled() {
        return this._dateRange.startYear === null;
    }

    get _endMonthDisabled() {
        return this._dateRange.endYear === null || this._dateRange.startMonth === null;
    }

    get _endMonthRequired() {
        return this._dateRange.endYear && this._dateRange.startMonth !== null;
    }

    @api
    disabled;

    @api
    validate() {
        const isValid = [...this.template.querySelectorAll('.validate')]
            .reduce((validSoFar, inputComponent) => {
                return validSoFar && inputComponent.validate();
            }, true);
        return isValid;
    }

    @api
    clearRange() {
        this._dateRange.startYear = null;
        this._dateRange.startMonth = null;
        this._dateRange.endYear = null;
        this._dateRange.endMonth = null;
        this.dispatchEvent(new CustomEvent('rangechange', { detail: this._dateRange}));
    }

    @wire(getStartDateYearDecrement, {})
    getStartDateYearDecrementCallback ({error, data}) {
        if (error) {
            console.log(error)
        } else if (data) {
            this._startYearDecrement = data;
        }
    }
    
    handleStartDateChange(evt) {
        this._dateRange.startYear = evt.detail.year;
        this._dateRange.startMonth = evt.detail.month;
        this.dispatchEvent(new CustomEvent('rangechange', { detail: this._dateRange}));
    }
    
    handleEndDateChange(evt) {
        this._dateRange.endYear = evt.detail.year;
        this._dateRange.endMonth = evt.detail.month;
        this.dispatchEvent(new CustomEvent('rangechange', { detail: this._dateRange}));
    }
}