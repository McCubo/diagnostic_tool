import { LightningElement } from 'lwc';
import { showToast } from 'c/vdt_utils';
import { loadScript } from 'lightning/platformResourceLoader';
import vdt_xlsx from '@salesforce/resourceUrl/vdt_xlsx';

const SOBJECT_COLUMNS = [
    { label: 'Profile/Permission Set', fieldName: 'permissionsetName', type: 'text' },
    { label: 'API Object Name', fieldName: 'objectAPIName', type: 'text' },
    { label: 'Object Name', fieldName: 'objectName', type: 'text' },
    { label: 'Type', fieldName: 'sobjectType', type: 'text' },
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
    {label: 'Custom Object', value: 'Standard Object'}
];

const TEMP_SOBJECT_DATA = [
    {
        permissionsetName: '[PF] System Administrator',
        objectAPIName: 'Account',
        objectName: 'Account',
        sobjectType: 'Standard Object',
        isReadEnabled: true,
        isCreateEnabled: true,
        isEditEnabled: true,
        isDeleteEnabled: true,
        isViewAllEnabled: true,
        isModifyAllEnabled: true
    },
    {
        permissionsetName: '[PF] System Administrator',
        objectAPIName: 'Opportunity',
        objectName: 'Opportunity',
        sobjectType: 'Standard Object',
        isReadEnabled: true,
        isCreateEnabled: false,
        isEditEnabled: false,
        isDeleteEnabled: false,
        isViewAllEnabled: true,
        isModifyAllEnabled: false
    },
    {
        permissionsetName: '[PF] System Administrator',
        objectAPIName: 'VDT_Data_Calculation__c',
        objectName: 'Data Calculation',
        sobjectType: 'Custom Object',
        isReadEnabled: true,
        isCreateEnabled: true,
        isEditEnabled: true,
        isDeleteEnabled: true,
        isViewAllEnabled: true,
        isModifyAllEnabled: true
    },
    {
        permissionsetName: '[PF] System Administrator',
        objectAPIName: 'VDT_Log_Event__c',
        objectName: 'Log Event',
        sobjectType: 'Custom Object',
        isReadEnabled: true,
        isCreateEnabled: true,
        isEditEnabled: true,
        isDeleteEnabled: true,
        isViewAllEnabled: true,
        isModifyAllEnabled: true
    },
    {
        permissionsetName: '[PF] System Administrator',
        objectAPIName: 'Product_vod__c',
        objectName: 'Product Catalog',
        sobjectType: 'Custom Object',
        isReadEnabled: true,
        isCreateEnabled: true,
        isEditEnabled: true,
        isDeleteEnabled: true,
        isViewAllEnabled: true,
        isModifyAllEnabled: true
    },
    {
        permissionsetName: '[PF] System Administrator',
        objectAPIName: 'Call2_vod__c',
        objectName: 'Call',
        sobjectType: 'Custom Object',
        isReadEnabled: true,
        isCreateEnabled: true,
        isEditEnabled: true,
        isDeleteEnabled: true,
        isViewAllEnabled: true,
        isModifyAllEnabled: true
    },
    {
        permissionsetName: '[PF] System Administrator',
        objectAPIName: 'Call2_Detail_vod__c',
        objectName: 'Call Detail',
        sobjectType: 'Custom Object',
        isReadEnabled: true,
        isCreateEnabled: true,
        isEditEnabled: true,
        isDeleteEnabled: true,
        isViewAllEnabled: true,
        isModifyAllEnabled: true
    },
    {
        permissionsetName: '[PF] System Administrator',
        objectAPIName: 'Account_Plan_vod__c',
        objectName: 'Account Plan',
        sobjectType: 'Custom Object',
        isReadEnabled: false,
        isCreateEnabled: false,
        isEditEnabled: false,
        isDeleteEnabled: false,
        isViewAllEnabled: false,
        isModifyAllEnabled: false
    },
    {
        permissionsetName: '[PF] System Administrator',
        objectAPIName: 'Content_Acknowledgement_Item_vod__c',
        objectName: 'Content Acknowledgement Item',
        sobjectType: 'Custom Object',
        isReadEnabled: true,
        isCreateEnabled: true,
        isEditEnabled: true,
        isDeleteEnabled: true,
        isViewAllEnabled: false,
        isModifyAllEnabled: false
    },
];

const TEMP_FLS_DATA = [
    {
        permissionsetName: '[PF] System Administrator',
        objectAPIName: 'VDT_Data_Calculation__c',
        objectName: 'Data Calculation',
        fieldAPIName: 'Batches_Number__c',
        fieldName: 'Batches Number',
        flsRead: true,
        flsEdit: true
    },
    {
        permissionsetName: '[PF] System Administrator',
        objectAPIName: 'VDT_Data_Calculation__c',
        objectName: 'Data Calculation',
        fieldAPIName: 'VDT_Calculation_Date__c',
        fieldName: 'Calculation Date',
        flsRead: true,
        flsEdit: true
    },
    {
        permissionsetName: '[PF] System Administrator',
        objectAPIName: 'VDT_Data_Calculation__c',
        objectName: 'Data Calculation',
        fieldAPIName: 'End_Date__c',
        fieldName: 'End Date',
        flsRead: true,
        flsEdit: false
    },
    {
        permissionsetName: '[PF] System Administrator',
        objectAPIName: 'VDT_Data_Calculation__c',
        objectName: 'Data Calculation',
        fieldAPIName: 'Start_Date__c',
        fieldName: 'Start Date',
        flsRead: true,
        flsEdit: false
    },
    {
        permissionsetName: '[PF] System Administrator',
        objectAPIName: 'VDT_Data_Calculation__c',
        objectName: 'Data Calculation',
        fieldAPIName: 'Status__c',
        fieldName: 'Status',
        flsRead: true,
        flsEdit: true
    },
    {
        permissionsetName: '[PF] System Administrator',
        objectAPIName: 'VDT_Data_Calculation__c',
        objectName: 'Data Calculation',
        fieldAPIName: 'RecordTypeId',
        fieldName: 'Record Type',
        flsRead: true,
        flsEdit: true
    },
    {
        permissionsetName: '[PF] System Administrator',
        objectAPIName: 'VDT_Data_Calculation__c',
        objectName: 'Data Calculation',
        fieldAPIName: 'VDT_Object_Name__c',
        fieldName: 'Object Name',
        flsRead: true,
        flsEdit: true
    },
    {
        permissionsetName: '[PF] System Administrator',
        objectAPIName: 'VDT_Data_Calculation__c',
        objectName: 'Data Calculation',
        fieldAPIName: 'Territory__c',
        fieldName: 'Territory',
        flsRead: true,
        flsEdit: true
    }    
];

export default class Vdt_profileAndPermissionSetResults extends LightningElement {

    _selectedSObjectType;
    _recordsPerPage = 10;

    connectedCallback() {
        Promise.all([
            loadScript(this, vdt_xlsx)
        ]).then(() => {
            this.fetchProfilePermissionSerResults();
        }).catch(error => {
            this.dispatchEvent(showToast(error, 'error'));
        });
    }

    fetchProfilePermissionSerResults() {
        console.log('fetchProfilePermissionSerResults: fired');
    }

    //  SObject Pagination variables
    _totalPagesSObject = 1;
    _currentPageSObject = 1;
    _pageNumbersSObject = [1];

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

    sobjectData = TEMP_SOBJECT_DATA;
    flsData = TEMP_FLS_DATA;

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
            let dataSheet = this.sobjectData.map(record => Object.values(record));
            var ws = window.XLSX.utils.aoa_to_sheet(dataSheet);
            wb.Sheets["Object Permissions"] = ws;

            let flsDataSheet = this.flsData.map(record => Object.values(record));
            var ws2 = window.XLSX.utils.aoa_to_sheet(flsDataSheet);
            wb.Sheets["Field Level Security"] = ws2;

            // var wbout = window.XLSX.write(wb, {bookType:'xlsx',  type: 'binary'});
            window.XLSX.writeFile(wb, 'XXXX.xlsx');
        } catch (error) {
            console.log(error)
        }
    }

    s2ab(s) { 
        var buf = new ArrayBuffer(s.length); //convert s to arrayBuffer
        var view = new Uint8Array(buf);  //create uint8array as viewer
        for (var i=0; i<s.length; i++) view[i] = s.charCodeAt(i) & 0xFF; //convert to octet
        return buf;    
    }
}