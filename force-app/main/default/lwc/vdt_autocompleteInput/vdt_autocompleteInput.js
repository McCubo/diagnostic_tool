import { LightningElement, api, track } from 'lwc';

export default class Vdt_autocompleteInput extends LightningElement {
    @track 
    _suggestions = [];
    _showSuggestions = false;
    _suggestionSelected = false;
    _selectedItems = [];
    @track _options = [];
    _dropdownHasFocus = false;
    _input;
    _inputValue = '';

    get _selectedValues() {
        let values = this._selectedItems.reduce((acc, curr) => {
            acc.push(curr.value);
            return acc;
        }, []);
        return values;
    }
    get _selectedLabels() {
        let labels = this._selectedItems.reduce((acc, curr) => {
            acc.push(curr.label);
            return acc;
        }, []);
        return labels;
    }

    get _showSpinner() {
        return  (!this.multiselect && this._options.length === 0) ||
                (this.multiselect && this._options.length === 1);
    }

    get _labelVariant() {
        return this.label ? 'standard' : 'label-hidden';
    }

    @api
    disabled;
    @api
    label;
    @api
    placeholder;
    @api
    get options() {
        return this._options;
    }
    set options(val) {
        this._options = JSON.parse(JSON.stringify(val));
        this._selectedItems = this._options.filter(option => option.selected);
        this._inputValue = this._selectedLabels.join(',');
    }
    @api
    multiselect = false;
    @api
    emptyValidationMessage;

    @api
    validate() {
        const inputCmp = this.template.querySelector('lightning-input');
        let isValid = true;

        if (!this._selectedItems.length) {
            inputCmp.setCustomValidity(this.emptyValidationMessage);
            isValid = false;
        } else {
            inputCmp.setCustomValidity("")
        }
        inputCmp.reportValidity();
        return isValid;
    }

    handleInputChange(evt) {
        this._inputValue = evt.detail.value;
        if (!this.multiselect) {
                this.showFilteredSuggestions(this._inputValue);
        } else {
            let inputElements = this._inputValue.split(',');
            this._suggestions = [];
                inputElements.forEach(element => {
                    this._options.forEach(option => {
                        (option.label.toLowerCase().indexOf(element.toLowerCase()) >= 0 && this._selectedLabels.indexOf(element) < 0) ? this._suggestions.push(option) : null;
                    })
                });
                this._showSuggestions = true;
        }
    }

    showFilteredSuggestions(input) {
        if (input) {   
            this._suggestions =
                this._options.filter(option => option.label.toLowerCase().indexOf(input.toLowerCase()) >= 0);
        } else {
            this._suggestions = JSON.parse(JSON.stringify(this._options));
        }
        this._showSuggestions = true;
    }

    handleSuggestionClick(evt) {
        this.template.querySelector('lightning-input').focus();
        const clickedOption = this._options.find(option => option.value === evt.currentTarget.dataset.value);
        clickedOption.selected = !clickedOption.selected;
        if (this.multiselect) {
            if (clickedOption.selected) {
                this.pushSelectedItem(clickedOption.label, clickedOption.value);
            } else {
                this.excludeSelectedItem(clickedOption.value);
            }
            this.sortSelectedItems();
            this.showFilteredSuggestions();
            this.dispatchEvent(new CustomEvent('optionselect', { detail: this._selectedValues}));
        } else {
            this._selectedItems.pop();
            if (clickedOption.selected) {
                this.pushSelectedItem(clickedOption.label, clickedOption.value);
            }
            this._options.forEach(option => option.value !== clickedOption.value ? option.selected = false : null);
            this._showSuggestions = false;
            this.dispatchEvent(new CustomEvent('optionselect', {detail: this._selectedValues[0]}));
        }
        this._inputValue = this._selectedLabels.join(',');
    }

    clearSelectedItem() {
        this._selectedItems = [];
    }

    pushSelectedItem(label, value) {
        this._selectedItems.push({ label, value });
    }

    excludeSelectedItem(value) {
        this._selectedItems = 
            this._selectedItems.filter(selectedItem => selectedItem.value !== value);
    }

    sortSelectedItems() {
        this._selectedItems.sort((a, b) => {
            let optionValues = this._options.reduce((acc, curr) => {acc.push(curr.value);return acc;}, []);
            if (optionValues.indexOf(a.value) < optionValues.indexOf(b.value)) {
                return -1
            }
            if (optionValues.indexOf(a.value) > optionValues.indexOf(b.value)) {
                return 1
            }
            return 0;
        });
    }

    handleInputClick() {
        this.template.querySelector('lightning-input').focus();
        if (this.multiselect) {
            if(this._showSuggestions) {
                this.closeDropdown();
            } else {
                this.showFilteredSuggestions();
            }
        } else {
            this.showFilteredSuggestions(this._inputValue);
        }
    }

    handleBlur() {
        if (!this._dropdownHasFocus) {
            this.closeDropdown();
        }
    }

    closeDropdown() {
        this._inputValue = this._selectedLabels.join(',');
        this._showSuggestions = false;
    }

    handleMouseEnter() {
        this._dropdownHasFocus = true;
    }

    handleMouseLeave() {
        this._dropdownHasFocus = false;
    }
}