import { LightningElement, api, track } from 'lwc';
import { MONTH_NAMES } from 'c/vdt_utils';

export default class Vdt_monthYearPicker extends LightningElement {
    _minYear = new Date().getFullYear() - 20;
    _maxYear = new Date().getFullYear() + 100;
    _minMonth = 0;
    @track
    _date = {
        month: null,
        year: null
    }

    get _monthOptions() {
        let monthOptions = [];
        Object.keys(MONTH_NAMES).forEach(key => key >= this._minMonth ? monthOptions.push({label: MONTH_NAMES[key], value: key}) : null);
        return monthOptions;
    }

    get _yearOptions() {
        let years = [];

        for (let i = this._minYear; i <= this._maxYear; i++) {
            years.push({ label: i+'', value: i+'' });
        }

        return years
    }

    get _yearPickerDisabled() {
        return this.yearDisabled || this.disabled;
    }

    get _monthPickerDisabled() {
        return this.monthDisabled || !!this._date.year === null || this.disabled;
    }

    @api
    validate() {
        const yearCombobox = this.template.querySelector('lightning-combobox.year');
        const monthCombobox = this.template.querySelector('lightning-combobox.month');
        let isValid = true;
        if (this.yearRequired && this._date.year === null) {
            yearCombobox.setCustomValidity("Year must be selected.");
            isValid = false;
        } else {
            yearCombobox.setCustomValidity("")
        }
        if (this.monthRequired && this._date.month === null) {
            monthCombobox.setCustomValidity("Month must be selected.");
            isValid = false;
        } else {
            monthCombobox.setCustomValidity("")
        }
        yearCombobox.reportValidity();
        monthCombobox.reportValidity();
        return isValid;
    }

    @api
    get minYear() {
        return this._minYear;
    }
    set minYear(val) {
        this._minYear = val;
    }
    @api
    get maxYear() {
        return this._maxYear;
    }
    set maxYear(val) {
        this._maxYear = val;
    }
    @api
    get minMonth() {
        return this._minMonth;
    }
    set minMonth(val) {
        this._minMonth = val;
    }
    @api label;
    @api monthDisabled = false;
    @api yearDisabled = false;
    @api yearRequired = false;
    @api monthRequired = false;
    @api disabled = false;

    handleYearChange(evt) {
        this._date.year = parseInt(evt.detail.value);
        this.dispatchEvent(new CustomEvent('datechange', { detail: this._date }));
    }

    handleMonthChange(evt) {
        this._date.month = parseInt(evt.detail.value);
        this.dispatchEvent(new CustomEvent('datechange', { detail: this._date }));
    }
}