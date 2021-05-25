import { LightningElement, api } from 'lwc';
import { downloadCSVFile } from 'c/vdt_csvUtil';

const COLUMNS = [
    { label: 'SObject Name', fieldName: 'sobjectName', type: 'text' },
    { label: 'Field Name', fieldName: 'fieldName', type: 'text' },
    { label: 'Profile/Permission Set name', fieldName: 'profilePermissionSet', type: 'text' },
    { label: 'FLS Read', fieldName: 'flsRead', type: 'boolean', initialWidth: 75 },
    { label: 'FLS Edit', fieldName: 'flsEdit', type: 'boolean', initialWidth: 75 },
    { label: 'Page Layout Read Only', fieldName: 'pagelayoutRead', type: 'text'},
    { label: 'Page Layout Edit', fieldName: 'pagelayoutEdit', type: 'text'},
    { label: 'Create?', fieldName: 'objectCreate', type: 'boolean', initialWidth: 75},
    { label: 'Read?', fieldName: 'objectRead', type: 'boolean', initialWidth: 75},
    { label: 'Edit?', fieldName: 'objectEdit', type: 'boolean', initialWidth: 75},
    { label: 'Delete?', fieldName: 'objectDelete', type: 'boolean', initialWidth: 75},
    { label: 'View All?', fieldName: 'objectViewAll', type: 'boolean' },
    { label: 'Modify All?', fieldName: 'objectModifyAll', type: 'boolean' }
];
export default class Vdt_fieldLevelSecurityTable extends LightningElement {

    columns = COLUMNS;
    fieldFilter = null;
    sobjectFilter = null;
    permissionFilter = null;
    _rawData = [];
    _calculationData = [];

    _recordsPerPage = 10;
    _totalPages = 1;
    _currentPage = 1;
    _pageNumbers = [];

    @api
    get calculationData() {
        return this._calculationData;
    }

    set calculationData(val) {
        let data = JSON.parse(val);
        this._rawData = val;
        this._calculationData = this.parseData(data);
        this.initializePaginator();
    }

    initializePaginator() {
        this._totalPages = Math.ceil(this._calculationData.length / this._recordsPerPage);
        this._pageNumbers = [];
        this._currentPage = 1;
        for (let i = 1; i <= this._totalPages; i++) {
            this._pageNumbers.push(i);
        }
    }
    
    get _currentOffset() {
        return (this._currentPage - 1) * this._recordsPerPage;
    }

    get _currentPageData() {
        return this._calculationData.slice(this._currentOffset, this._currentPage * this._recordsPerPage);
    }

    parseData(data) {
        let fieldLevelSecurity = data.fieldLevelSecurity;
        let filteredData = fieldLevelSecurity.filter(fieldSecurityInfo => {
            let meetsCriteria = true;
            if (this.fieldFilter) {
                meetsCriteria &= fieldSecurityInfo.fieldName.toLowerCase().includes(this.fieldFilter);
            }
            if (this.permissionFilter) {
                meetsCriteria &= fieldSecurityInfo.profilePermissionSet.toLowerCase().includes(this.permissionFilter);
            }
            if (this.sobjectFilter) {
                meetsCriteria &= fieldSecurityInfo.sobjectName.toLowerCase().includes(this.sobjectFilter);
            }
            return meetsCriteria;
        }).sort((a,b) => (a.fieldName > b.fieldName) ? 1 : ((b.fieldName > a.fieldName) ? -1 : 0));
        return filteredData;
    }

    handlePermissionFilterInputChange(event) {
        this.permissionFilter = null;
        if (event.detail.value) {
            this.permissionFilter = event.detail.value.toLowerCase();
        }
        this._calculationData = this.parseData(JSON.parse(this._rawData));
        this.initializePaginator(); 
    }
    handleFieldFilterInputChange(event) {
        this.fieldFilter = event.detail.value;
        if (event.detail.value) {
            this.fieldFilter = event.detail.value.toLowerCase();
        }
        this._calculationData = this.parseData(JSON.parse(this._rawData));
        this.initializePaginator();        
    }

    handleObjectFilterInputChange(event) {
        this.sobjectFilter = event.detail.value;
        if (event.detail.value) {
            this.sobjectFilter = event.detail.value.toLowerCase();
        }
        this._calculationData = this.parseData(JSON.parse(this._rawData));
        this.initializePaginator();              
    }

    handleExportCSV() {
        let headers = {};
        this.columns.forEach(col => headers[col.fieldName] = col.label);
        downloadCSVFile(headers, this._calculationData, 'field_level_security');
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

}