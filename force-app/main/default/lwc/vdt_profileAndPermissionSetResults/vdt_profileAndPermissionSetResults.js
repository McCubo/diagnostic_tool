import { api, LightningElement } from 'lwc';
import { showToast } from 'c/vdt_utils';
import { loadScript } from 'lightning/platformResourceLoader';
import vdt_xlsx from '@salesforce/resourceUrl/vdt_xlsx';

const SOBJECT_COLUMNS = [
    { label: 'Profile/Permission Set', fieldName: 'permissionsetName', type: 'text' },
    { label: 'API Object Name', fieldName: 'objectAPIName', type: 'text' },
    { label: 'Object Name', fieldName: 'objectName', type: 'text' },
    { label: 'Type', fieldName: 'sobjectType', type: 'text' },
    { label: 'Tab Visibility', fieldName: 'tabVisibility', type: 'text' },
    { label: 'Read?', fieldName: 'isReadEnabled', type: 'boolean', initialWidth: 75 },
    { label: 'Create?', fieldName: 'isCreateEnabled', type: 'boolean', initialWidth: 75 },
    { label: 'Edit?', fieldName: 'isEditEnabled', type: 'boolean', initialWidth: 75 },
    { label: 'Delete?', fieldName: 'isDeleteEnabled', type: 'boolean', initialWidth: 75 },
    { label: 'View All?', fieldName: 'isViewAllEnabled', type: 'boolean', initialWidth: 75 },
    { label: 'Modify All?', fieldName: 'isModifyAllEnabled', type: 'boolean', initialWidth: 75 }
];

const FLS_COLUMNS = [
    { label: 'Profile/Permission Set', fieldName: 'permissionsetName', type: 'text' },
    { label: 'API Object Name', fieldName: 'objectAPIName', type: 'text' },
    { label: 'Object Name', fieldName: 'objectName', type: 'text' },
    { label: 'Field API Name', fieldName: 'fieldAPIName', type: 'text' },
    { label: 'Field Name', fieldName: 'fieldName', type: 'text' },
    { label: 'FLS Read', fieldName: 'flsRead', type: 'boolean', initialWidth: 75 },
    { label: 'FLS Edit', fieldName: 'flsEdit', type: 'boolean', initialWidth: 75 },
];

const SOBJECT_TYPES = [
    {label: 'Standard Object', value: 'Standard Object'},
    {label: 'Custom Object', value: 'Custom Object'}
];

export default class Vdt_profileAndPermissionSetResults extends LightningElement {
    
    _recordsPerPage = 10;

    _flsData;
    _flsRawData;
    @api
    get flsData() {
        return this._flsData;
    }; 

    set flsData(data) {
        this._flsRawData = data;
        this._flsData = this.paseFlsData(JSON.parse(this._flsRawData));
        this.initializeFlsPaginator();
    }

    _sobjectDataRaw;
    _sobjectData;
    @api
    get sobjectData() {
        return this._sobjectData;
    }

    set sobjectData(data) {
        this._sobjectDataRaw = data;
        this._sobjectData = this.parseSobjectData(JSON.parse(this._sobjectDataRaw));
        this.initializeSObjectPaginator();
    }

    _selectedObjects;

    @api
    get selectedObjects() {
        return this._selectedObjects;
    }

    set selectedObjects(data) {        
        this._selectedObjects = data;
    }

    connectedCallback() {
        Promise.all([
            loadScript(this, vdt_xlsx)
        ]).then(() => {            
        }).catch(error => {
            this.dispatchEvent(showToast(error, 'error'));
        });
    }

    parseSobjectData(data) {
        let parsedData = data.filter(permissionRecord => {
            if (this._selectedSObjectType) {
                return permissionRecord.sobjectType == this._selectedSObjectType;
            }
            return true;
        }).filter(permissionRecord => {
            if (this.sobjectName) {
                return permissionRecord.objectAPIName.toLowerCase().includes(this.sobjectName) || permissionRecord.objectName.toLowerCase().includes(this.sobjectName);
            }
            return true;
        }).filter(permissionRecord => {
            if (this.sobject_permissionName) {
                return permissionRecord.permissionsetName.toLowerCase().includes(this.sobject_permissionName);
            }
            return true;
        }).filter(permissionRecord => {
            if (this._selectedObjects && this._selectedObjects.length > 0) {
                return this._selectedObjects.includes(permissionRecord.permissionsetAPIName);
            }
            return true;
        });
        
        return parsedData;
    }

    //  SObject Pagination variables
    _totalPagesSObject = 1;
    _currentPageSObject = 1;
    _pageNumbersSObject = [1];
    _selectedSObjectType;
    sobjectName;
    sobject_permissionName;

    get _currentSObjectOffset() {
        return (this._currentPageSObject - 1) * this._recordsPerPage;
    }

    initializeSObjectPaginator() {
        this._totalPagesSObject = Math.ceil(this._sobjectData.length / this._recordsPerPage);
        this._pageNumbersSObject = [];
        this._currentPageSObject = 1;
        for (let i = 1; i <= this._totalPagesSObject; i++) {
            this._pageNumbersSObject.push(i);
        }
    }

    get currentPageSObjectData() {
        return this._sobjectData.slice(this._currentSObjectOffset, this._currentPageSObject * this._recordsPerPage);
    }

    handlePreviousClickSObject() {
        if (this._currentPageSObject > 1) {
            this._currentPageSObject--;
        }
    }

    handlePageClickSObject(event) {
        this._currentPageSObject = event.detail;
    }

    handleNextClickSObject() {
        if (this._currentPageSObject < this._totalPagesSObject) {
            this._currentPageSObject++;
        }
    }

    //  Field Level Security Pagination variables
    _totalPagesFLS = 1
    _currentPageFLS = 1;
    _pageNumbersFLS = [1];
    permissionsetNameFLS;
    sobjectNameFLS;
    fieldNameFLS;

    handleFieldNameChangeFLS(event) {
        this.fieldNameFLS = event.detail.value;
        if (this.fieldNameFLS) {
            this.fieldNameFLS = this.fieldNameFLS.toLowerCase();
        }
        this._flsData = this.paseFlsData(JSON.parse(this._flsRawData));
        this.initializeFlsPaginator();
    }

    handleSObjectNameChangeFLS(event) {
        this.sobjectNameFLS = event.detail.value;
        if (this.sobjectNameFLS) {
            this.sobjectNameFLS = this.sobjectNameFLS.toLowerCase();
        }
        this._flsData = this.paseFlsData(JSON.parse(this._flsRawData));
        this.initializeFlsPaginator();
    }

    handlePermissionNameChangeFLS(event) {
        this.permissionsetNameFLS = event.detail.value;
        if (this.permissionsetNameFLS) {
            this.permissionsetNameFLS = this.permissionsetNameFLS.toLowerCase();
        }
        this._flsData = this.paseFlsData(JSON.parse(this._flsRawData));
        this.initializeFlsPaginator();
    }

    paseFlsData(data) {
        let parsedData = data.filter(permissionRecord => {
            if (this._selectedObjects && this._selectedObjects.length > 0) {
                return this._selectedObjects.includes(permissionRecord.permissionsetAPIName);
            }
            return true;
        }).filter(permissionRecord => {
            if (this.permissionsetNameFLS) {
                return permissionRecord.permissionsetName.toLowerCase().includes(this.permissionsetNameFLS);
            }
            return true;
        }).filter(permissionRecord => {
            if (this.sobjectNameFLS) {
                return permissionRecord.objectAPIName.toLowerCase().includes(this.sobjectNameFLS) || permissionRecord.objectName.toLowerCase().includes(this.sobjectNameFLS);
            }
            return true;
        }).filter(permissionRecord => {
            if (this.fieldNameFLS) {
                return permissionRecord.fieldAPIName.toLowerCase().includes(this.fieldNameFLS) || permissionRecord.fieldName.toLowerCase().includes(this.fieldNameFLS);
            }
            return true;
        });
        return parsedData;
    }

    get _currentFLSOffset() {
        return (this._currentPageFLS - 1) * this._recordsPerPage;
    }

    get currentPageFLSData() {
        return this._flsData.slice(this._currentFLSOffset, this._currentPageFLS * this._recordsPerPage);
    }

    initializeFlsPaginator() {
        this._totalPagesFLS = Math.ceil(this._flsData.length / this._recordsPerPage);
        this._pageNumbersFLS = [];
        this._currentPageFLS = 1;
        for (let i = 1; i <= this._totalPagesFLS; i++) {
            this._pageNumbersFLS.push(i);
        }
    }
    
    handlePreviousClickFLS() {
        if (this._currentPageFLS > 1) {
            this._currentPageFLS--;
        }
    }

    handlePageClickFLS(event) {
        this._currentPageFLS = event.detail;
    }

    handleNextClickFLS() {
        if (this._currentPageFLS < this._totalPagesFLS) {
            this._currentPageFLS++;
        }
    }

    get sobjectColumns() {
        return SOBJECT_COLUMNS;
    }

    get sobjectTypes() {
        return SOBJECT_TYPES;
    }

    get flsColumns() {
        return FLS_COLUMNS;
    }
    
    handleSObjectTypeChange(event) {
        this._selectedSObjectType = event.detail;
        this._sobjectData = this.parseSobjectData(JSON.parse(this._sobjectDataRaw));
        this.initializeSObjectPaginator();
    }

    handleSobjectNameChange(event) {
        this.sobjectName = event.detail.value;
        if (this.sobjectName) {
            this.sobjectName = this.sobjectName.toLowerCase();
        }
        this._sobjectData = this.parseSobjectData(JSON.parse(this._sobjectDataRaw));
        this.initializeSObjectPaginator();
    }

    handlePermissionNameChange(event) {
        this.sobject_permissionName = event.detail.value;
        if (this.sobject_permissionName) {
            this.sobject_permissionName = this.sobject_permissionName.toLowerCase();
        }
        this._sobjectData = this.parseSobjectData(JSON.parse(this._sobjectDataRaw));
        this.initializeSObjectPaginator();
    }

    handleExportSObjectExcel(event) {
        try {
            let wb = window.XLSX.utils.book_new();
            wb.Props = {
                Title: "Profile and Permission Sets",
                Subject: "Security Analysis",
                Author: "BASE Life Science",
                CreatedDate: new Date(2017,12,19)
            };
            wb.SheetNames.push("Object Permissions", "Field Level Security");
            let dataSheet = new Array(SOBJECT_COLUMNS.reduce((accumulator, currentHeader) => { 
                    accumulator.push(currentHeader.label);
                    return accumulator;
                }, []))
                .concat(this._sobjectData.map(record => Object.values(record)));

            var objectPermissionWorkSheet = window.XLSX.utils.aoa_to_sheet(dataSheet);
            wb.Sheets["Object Permissions"] = objectPermissionWorkSheet;

            let flsDataSheet = new Array(FLS_COLUMNS.reduce((accumulator, currentHeader) => { 
                accumulator.push(currentHeader.label);
                return accumulator;
            }, []))
            .concat(this._flsData.map(record => Object.values(record)));
            var flsWorkSheet = window.XLSX.utils.aoa_to_sheet(flsDataSheet);
            wb.Sheets["Field Level Security"] = flsWorkSheet;

            window.XLSX.writeFile(wb, 'ProfileAndPermissionSetAnalysis.xlsx');
        } catch (error) {
            console.error(error)
        }
    }

}