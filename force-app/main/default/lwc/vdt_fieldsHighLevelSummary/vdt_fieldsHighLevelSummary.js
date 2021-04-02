import { LightningElement, api } from 'lwc';
import { downloadCSVFile } from 'c/vdt_csvUtil'

export default class Vdt_fieldHighLevelSummary extends LightningElement {
    _actions = [
        { label: 'Export Field Breakdown', name: 'export_breakdown' }
    ];

    _columnsBase = [
        { label: 'Field Label', fieldName: 'label' },
        { label: 'Field Name', fieldName: 'name' },
        { label: 'Field Type', fieldName: 'type' },
        {
            type: 'action',
            typeAttributes: { rowActions: this.getRowActions },
        }
    ];
    // _columns = [
    //     { label: 'Field Label', fieldName: 'label' },
    //     { label: 'Field Name', fieldName: 'name' },
    //     { label: 'Field Type', fieldName: 'type' }
    // ];
    _columns = [];
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
                    this._countryColumns.push({ label: countryCode, fieldName: `${countryCode}_usagePercentage`, type: 'text', initialWidth: 80});
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
                if (field.type.toLowerCase() === 'boolean') {
                    const trueValueUsage = field.countryUsageSummary[countryCode].fieldValueOccurences['true'] || 0;
                    const falseValueUsage = field.countryUsageSummary[countryCode].fieldValueOccurences['false'] || 0;
                    const totalRecords = field.countryUsageSummary[countryCode].totalRecords;

                    fieldEntry[`${countryCode}_usagePercentage`] = `${Math.floor((trueValueUsage/totalRecords)*100)}% / ${Math.floor((falseValueUsage/totalRecords)*100)}%`;
                    fieldEntry[`${countryCode}_valueOccurences`] = field.countryUsageSummary[countryCode].fieldValueOccurences;
                    fieldEntry[`${countryCode}_totalRecords`] = field.countryUsageSummary[countryCode].totalRecords;
                } else {
                    fieldEntry[`${countryCode}_usagePercentage`] = `${field.countryUsageSummary[countryCode].usagePercentage*100 + '%'}`;
                    fieldEntry[`${countryCode}_valueOccurences`] = field.countryUsageSummary[countryCode].fieldValueOccurences;
                    fieldEntry[`${countryCode}_totalRecords`] = field.countryUsageSummary[countryCode].totalRecords;
                }
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
        this._columns.forEach(col => headers[col.fieldName] = col.label);
        downloadCSVFile(headers, csvData, this.objectName+'_fields_high_level_summary');
    }

    getRowActions(row, doneCallback) {
        const actions = [];
        actions.push({
            'label': 'Export Field Breakdown',
            'iconName': 'utility:list',
            'name': 'export_breakdown',
            'disabled': row.type !== 'picklist'
        });
        doneCallback(actions);
    }

    handleRowAction(evt) {
        const action = evt.detail.action;
        const row = evt.detail.row;
        switch (action.name) {
            case 'export_breakdown':
                this.handleExportFieldBreakdown(row);
                break;
            default:
                break;
        }
    }

    handleExportFieldBreakdown(row) {
        let headers = {
            [this._columns[1].fieldName]: this._columns[1].label,
            'value': 'Field Value',
        };
        const fieldEntry = this._calculationData.find(entry => entry.name === row.name);
        let csvData = [];
        if (this._columns.length > 4) {
            for (let i = 4; i < this._columns.length; i++) {
                let countryLabel = this._columns[i].label;
                let valueOccurences = fieldEntry[`${countryLabel}_valueOccurences`];
                if (valueOccurences) {
                    let totalRecords = fieldEntry[`${countryLabel}_totalRecords`];
                    Object.keys(valueOccurences).forEach(value => {
                        let occurencesNum = valueOccurences[value];
                        csvData.push({
                            name: fieldEntry.name,
                            value: value || '',
                            [countryLabel]: `${Math.floor((occurencesNum/totalRecords)*100)}%`
                        })
                    })
                }
                headers[countryLabel] = countryLabel;
            }
        }

        downloadCSVFile(headers, csvData, `${this.objectName}_${row.name}_usage_breakdown`);
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