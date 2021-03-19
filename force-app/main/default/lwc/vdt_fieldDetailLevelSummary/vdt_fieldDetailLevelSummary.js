import { LightningElement, api, track } from 'lwc';
import { downloadCSVFile } from 'c/vdt_csvUtil'

export default class Vdt_fieldHighLevelSummary extends LightningElement {
    _columnsBase = [
        { label: 'Field Label', fieldName: 'label', initialWidth: 150 },
        { label: 'Field Name', fieldName: 'name', initialWidth: 150 },
        { label: 'Field Type', fieldName: 'type', initialWidth: 80 },
        { label: 'Available On Page Layout', fieldName: 'onPageLayout', initialWidth: 80 }
    ];
    _columns = [
        { label: 'Field Label', fieldName: 'label' },
        { label: 'Field Name', fieldName: 'name' },
        { label: 'Field Type', fieldName: 'type' },
        { label: 'Available On Page Layout', fieldName: 'onPageLayout' },
        { label: 'Page Layout Name', fieldName: 'pageLayoutsString' },
        { label: '# Records have value', fieldName: 'totalUsage' },
        { label: '% Records have value', fieldName: 'totalUsagePercentage' }
    ];

    _rawData = [];
    @track _calculationData = [];
    _filteredData = [];
    _pageNumbers = [];
    _objectName = "";
    _recordsPerPage = 10;
    _totalPages = 1;
    _currentPage = 1;
    _calculationStatus;
    _lastCalculationDate;
    _fieldFilterInput;
    _startDate;
    _countryCodeOptions = [];
    _selectedCountries = []

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
    objectName = '';
    @api
    get calculationData() {
        return this._calculationData;
    }
    set calculationData(val) {
        let data = JSON.parse(val);
        this._rawData = data;
        this._countryCodeOptions = [{ label: 'All', value: 'All', selected: true}].concat(this.parseCountryCodeOptions(this._rawData.countryCodes));
        this._calculationData = this.parseData(data);
        this.sortCalculationData(this._calculationData);
        this._filteredData = JSON.parse(JSON.stringify(this._calculationData));
        this.initializePaginator();
    }

    parseCountryCodeOptions(countryCodes) {
        let countryCodeOptions = [];
        countryCodes.forEach(cc => {
            countryCodeOptions.push({ label: cc, value: cc });
        });
        return countryCodeOptions;
    }

    initializePaginator() {
        this._totalPages = Math.ceil(this._filteredData.length / this._recordsPerPage);
        for (let i = 1; i <= this._totalPages; i++) {
            this._pageNumbers.push(i);
        }
    }

    setCountryColumns(data) {
        if (data.countryCodes && data.countryCodes.length > 0) {
            let columnsWithCountries = JSON.parse(JSON.stringify(this._columnsBase));
            data.countryCodes.forEach(countryCode => {
                    columnsWithCountries.push({ label: countryCode, fieldName: countryCode, type: 'percent', initialWidth: 80});
                }
            );
            this._columns = columnsWithCountries;
        }
    }
    
    parseData(data, countries) {
        let parsedData = [];
        Object.values(data.fields).forEach(field => {
            let fieldEntry = {
                label: field.label,
                name: field.name,
                type: field.type.toLowerCase(),
                onPageLayout: field.pageLayouts && field.pageLayouts.length > 0 ? 'Yes' : 'No',
                pageLayoutsString: (field.pageLayouts && field.pageLayouts.length > 0) ? field.pageLayouts.join(',') : null,
                totalUsage: 0,
                totalUsageString: '',
                totalRecords: 0,
                totalUsagePercentage: 0,
                totalValueUsage: {}
            };
            Object.keys(field.countryUsageSummary).forEach(countryCode => {
                if (countries && countries.length) {
                    if (countries.indexOf(countryCode) >= 0) {
                        this.parseForCountry(field, fieldEntry, countryCode);
                    }
                } else {
                    this.parseForCountry(field, fieldEntry, countryCode);
                }
            })

            parsedData.push(fieldEntry);
        })
        return parsedData;
    }

    parseForCountry(field, fieldEntry, countryCode) {
        if (field.type.toLowerCase() === 'boolean') {
            const trueValueUsage = field.countryUsageSummary[countryCode].fieldValueOccurences['true'] || 0;
            const falseValueUsage = field.countryUsageSummary[countryCode].fieldValueOccurences['false'] || 0;
            fieldEntry.totalRecords += field.countryUsageSummary[countryCode].totalRecords;
            
            fieldEntry.totalValueUsage.true ? fieldEntry.totalValueUsage.true+= trueValueUsage : fieldEntry.totalValueUsage.true = trueValueUsage;
            fieldEntry.totalValueUsage.false ? fieldEntry.totalValueUsage.false+= falseValueUsage : fieldEntry.totalValueUsage.false = falseValueUsage;

            fieldEntry.totalUsage = `${fieldEntry.totalValueUsage.true}/${fieldEntry.totalValueUsage.false}`;

            fieldEntry.totalUsagePercentage = `${Math.floor((fieldEntry.totalValueUsage.true/fieldEntry.totalRecords)*100)}% / ${Math.floor((fieldEntry.totalValueUsage.false/fieldEntry.totalRecords)*100)}%`
        } else {
            fieldEntry.totalUsage += field.countryUsageSummary[countryCode].usageNumber;
            fieldEntry.totalUsageString = fieldEntry.totalUsage + '';
            fieldEntry.totalRecords += field.countryUsageSummary[countryCode].totalRecords;
            fieldEntry.totalUsagePercentage = Math.floor((fieldEntry.totalUsage / fieldEntry.totalRecords)*100)+'%';
        }
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
        let csvData = [];
        this._columns.forEach(col => headers[col.fieldName] = col.label);
        if (this._selectedCountries.length > 1) {
            headers.country = 'country';
            this._selectedCountries.forEach(country => {
                let countryData = this.parseData(this._rawData, [country]);
                this.sortCalculationData(countryData);
                countryData.forEach(data => {
                    data.country = country;
                    csvData.push(data);
                    data.totalUsagePercentage = data.totalUsagePercentage;
                });
            });
            let countrySummaryData = this.parseData(this._rawData, this._selectedCountries);
            this.sortCalculationData(countrySummaryData);
            countrySummaryData.forEach(data => {
                data.country = this._selectedCountries.join(',');
                csvData.push(data);
                data.totalUsagePercentage = data.totalUsagePercentage ;
            });
        } else {
            csvData = JSON.parse(JSON.stringify(this._calculationData));
            csvData.forEach(data => {
                data.totalUsagePercentage = data.totalUsagePercentage;
                data.pageLayoutsString = data.pageLayoutsString ? data.pageLayoutsString : '';
            });
        }
        downloadCSVFile(headers, csvData, this.objectName + '_fields_country_detail_summary');
    }

    handleFieldFilterInputChange(evt) {
        let fieldFilterInput = evt.target.value.toLowerCase();
        this._filteredData = this._calculationData.filter(d => d.label.toLowerCase().indexOf(fieldFilterInput) >= 0 || d.name.toLowerCase().indexOf(fieldFilterInput) >= 0);
        console.log(fieldFilterInput);
        this._totalPages = Math.ceil(this._filteredData.length / this._recordsPerPage);
        this._pageNumbers = [];
        for (let i = 1; i <= this._totalPages; i++) {
            this._pageNumbers.push(i);
        }
        this._currentPage = 1;
    }

    handleCountryOptionSelect(evt) {
        console.log(evt.detail);
        this._selectedCountries = evt.detail;
        if (this._selectedCountries.indexOf('All') < 0 && this._selectedCountries.length > 0) {
            this._calculationData = this.parseData(this._rawData, this._selectedCountries);
        } else {
            this._selectedCountries = [];
            this._calculationData = this.parseData(this._rawData);
        }
        this.sortCalculationData(this._calculationData);
        this._filteredData = JSON.parse(JSON.stringify(this._calculationData));
        this.initializePaginator();
    }
}