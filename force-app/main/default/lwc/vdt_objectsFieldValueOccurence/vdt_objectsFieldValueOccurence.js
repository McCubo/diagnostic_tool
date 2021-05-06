import { api, LightningElement, track } from 'lwc';
import { downloadCSVFile } from 'c/vdt_csvUtil'

export default class Vdt_objectsFieldValueOccurence extends LightningElement {

    _columnsBase = [
        { label: 'Field Label', fieldName: 'label' },
        { label: 'Field Name', fieldName: 'name' },
        { label: 'Field Value', fieldName: 'value' },
        { label: 'Is Value Active', fieldName: 'isActive', type: 'boolean' }
    ];

    _rawData = [];
    _columns = [];
    _countryColumns = [];
    _calculationData = [];
    _fieldOptions = [];
    _fieldNames = [];

    _pageNumbers = [];
    _currentPage = 1;
    _recordsPerPage = 10;

    get _currentOffset() {
        return (this._currentPage - 1) * this._recordsPerPage;
    }

    get _currentPageData() {
        return this._calculationData.slice(this._currentOffset, this._currentPage * this._recordsPerPage);
    }

    get fieldValueOccurrenceData() {
        return JSON.stringify(this._data);
    }

    @api
    set fieldValueOccurrenceData(fieldValueOccurenceCalculation) {
        try {
            this._rawData = fieldValueOccurenceCalculation.data;
            let data = JSON.parse(this._rawData);
            this.setCountryColumns(data);
            this._calculationData = this.parseData(data);
            this._fieldOptions = data.fieldNames.map(fieldLabel => {
                return { label: fieldLabel, value: fieldLabel };
            });
            this.initializePaginator();
        } catch (error) {
            console.log(error);
        }
    }

    initializePaginator() {
        this._totalPages = Math.ceil(this._calculationData.length / this._recordsPerPage);
        this._pageNumbers = [];
        this._currentPage = 1;
        for (let i = 1; i <= this._totalPages; i++) {
            this._pageNumbers.push(i);
        }
    }

    setCountryColumns(data) {
        if (data.countryCodes && data.countryCodes.length > 0) {
            data.countryCodes.forEach(countryCode => {
                    this._countryColumns.push({ label: countryCode, fieldName: `${countryCode}_fieldValueOccurrence`, type: 'text', initialWidth: 80});
                }
            );
            this._columns = this._columnsBase.concat(this._countryColumns);
        }
    }

    parseData(data) {
        let fieldsData = [];
        Object.values(data.fields).forEach(field => {
            if (this._fieldNames.length == 0 || this._fieldNames.includes(field.name)) {
                let values = new Set();
                Object.keys(field.countryUsageSummary).forEach(countryCode => {
                    Object.keys(field.countryUsageSummary[countryCode].fieldValueOccurences).forEach(value => {
                        values.add(value);
                    });
                });
                values.forEach(value => {
                    let fieldEntry = {
                        label: field.label,
                        name: field.name,
                        type: field.type.toLowerCase(),
                        value: value,
                        isActive: false
                    };
                    Object.keys(field.countryUsageSummary).forEach(countryCode => {
                        Object.keys(field.countryUsageSummary[countryCode].fieldValueOccurences).forEach(fieldValue => {
                            if (!fieldEntry[`${countryCode}_fieldValueOccurrence`]) {
                                fieldEntry[`${countryCode}_fieldValueOccurrence`] = 0;
                            }
                            if (field.countryUsageSummary[countryCode].fieldValueOccurences[value]) {
                                fieldEntry.isActive = data.values_by_fields[field.name].includes(value);
                                fieldEntry[`${countryCode}_fieldValueOccurrence`] = field.countryUsageSummary[countryCode].fieldValueOccurences[value];
                            }
                        });
                    });
                    fieldsData.push(fieldEntry);
                });
            }
        });
        return fieldsData;
    }

    handlePreviousClick() {
        if (this._currentPage > 1) {
            this._currentPage--;
        }
    }
    
    handlePageClick(event) {
        this._currentPage = event.detail;
    }

    handleNextClick() {
        if (this._currentPage < this._totalPages) {
            this._currentPage++;
        }
    }

    handleExportCSV() {
        let headers = {};
        this._columns.forEach(col => headers[col.fieldName] = col.label);
        downloadCSVFile(headers, this._calculationData, 'field_values_occurrences');
    }

    handleFieldNameChange(event) {
        this._fieldNames = event.detail;
        this._calculationData = this.parseData(JSON.parse(this._rawData));
        this.initializePaginator();
    }
}