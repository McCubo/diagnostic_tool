import { LightningElement, api } from 'lwc';
import { downloadCSVFile } from 'c/vdt_csvUtil'

export default class Vdt_fieldHighLevelSummary extends LightningElement {
    _columnsBase = [
        { label: 'Field Label', fieldName: 'label' },
        { label: 'Field Name', fieldName: 'name' },
        { label: 'Field Type', fieldName: 'type' }
    ];
    _columns = [
        { label: 'Field Label', fieldName: 'label' },
        { label: 'Field Name', fieldName: 'name' },
        { label: 'Field Type', fieldName: 'type' }
    ];
    _countryColumns = [];

    _calculationData = [];
    _filteredData = [];
    _pageNumbers = [];
    _recordsPerPage = 10;
    _totalPages = 1;
    _currentPage = 1;
    _calculationStatus;
    _lastCalculationDate;
    _fieldFilterInput;
    _startDate;

    get _endDateDisabled() {
        return this._startDate === null;
    }

    handleStartDateChange(evt) {
        this._startDate = evt.target.value;
    }

    get _recalculationDisabled() {
        return this._calculationStatus === 'In Progress';
    }

    get _recalculationButtonLabel() {
        return this._recalculationDisabled ? 'Calculation In Progress' : 'Recalculate';
    }

    get _currentOffset() {
        return (this._currentPage - 1) * this._recordsPerPage;
    }

    get _currentPageData() {
        return this._filteredData.slice(this._currentOffset, this._currentPage * this._recordsPerPage);
    }

    @api 
    objectName = "";
    @api
    get calculationData() {
        return this._calculationData;
    }
    set calculationData(val) {
        let data = JSON.parse(val);
        this.setCountryColumns(data);
        this._calculationData = this.parseFieldsStatsData(data);
        this.sortCalculationData(this._calculationData);
        this._filteredData = JSON.parse(JSON.stringify(this._calculationData));
        this.initializePaginator();
    }

    initializePaginator() {
        this._totalPages = Math.ceil(this._filteredData.length / this._recordsPerPage);
        for (let i = 1; i <= this._totalPages; i++) {
            this._pageNumbers.push(i);
        }
    }

    setCountryColumns(data) {
        if (data.countryCodes && data.countryCodes.length > 0) {
            data.countryCodes.forEach(countryCode => {
                    this._countryColumns.push({ label: countryCode, fieldName: countryCode, type: 'percent', initialWidth: 80});
                }
            );
            this._columns = this._columnsBase.concat(this._countryColumns);
        }
    }
    
    parseFieldsStatsData(data) {
        let fieldsData = [];
        Object.values(data.fields).forEach(field => {
            let fieldEntry = {
                label: field.label,
                name: field.name,
                type: field.type.toLowerCase()
            };
            Object.keys(field.countryUsageSummary).forEach(countryCode => {
                fieldEntry[countryCode] = field.countryUsageSummary[countryCode].usagePercentage;
            })

            fieldsData.push(fieldEntry);
        })
        return fieldsData;
    }

    sortCalculationData(fieldsData) {
        fieldsData.sort((a, b) => {
            if (a.name < b.name) {
                return -1;
            }
            if (a.name > b.name) {  
                return 1;
            }
            return 0;
        })
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
        let csvData = JSON.parse(JSON.stringify(this._calculationData));
        this._countryColumns.forEach(column => {
            csvData.forEach(data => {
                if (data[column.fieldName]) {
                    data[column.fieldName] = `${data[column.fieldName] * 100}%`;
                }
            })
        })
        this._columns.forEach(col => headers[col.fieldName] = col.label);
        downloadCSVFile(headers, csvData, this.objectName+'_fields_high_level_summary');
    }

    handleFieldFilterInputChange(evt) {
        let fieldFilterInput = evt.target.value.toLowerCase();
        this._filteredData = this._calculationData.filter(d => d.label.toLowerCase().indexOf(fieldFilterInput) >= 0 || d.name.toLowerCase().indexOf(fieldFilterInput) >= 0);
        
        this._totalPages = Math.ceil(this._filteredData.length / this._recordsPerPage);
        this._pageNumbers = [];
        for (let i = 1; i <= this._totalPages; i++) {
            this._pageNumbers.push(i);
        }
        this._currentPage = 1;
    }
}