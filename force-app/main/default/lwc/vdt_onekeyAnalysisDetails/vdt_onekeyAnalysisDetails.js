import { LightningElement } from 'lwc';
import { downloadCSVFile } from 'c/vdt_csvUtil'

const EXAMPLES_COLUMNS_DEFINITION_BASIC = [
    {
        type: 'text',
        fieldName: 'specialty',
        label: 'Specialty',
    },
    {
        type: 'text',
        fieldName: 'recordtype',
        label: 'Record Type',
    },
    {
        type: 'boolean',
        fieldName: 'isActive',
        label: 'Is Speciality Active?'
    },
    {
        type: 'text',
        fieldName: 'totalAccounts',
        label: 'Total Accounts'
    },
    {
        type: 'text',
        fieldName: 'visitedCalled',
        label: 'Visited/Called',
    },
    {
        type: 'text',
        fieldName: 'partCyclePlan',
        label: 'Part of Cycle plan'
    },
    {
        type: 'text',
        fieldName: 'notPartOfCyclePlan',
        label: 'Visited and Not part of Cycle plan',
    },
    {
        type: 'text',
        fieldName: 'notInProductMetrics',
        label: 'Not used in Product metric?',
    },
    {
        type: 'text',
        fieldName: 'noAddress',
        label: 'No Address',
    }, 
    {
        type: 'text',
        fieldName: 'notAlignedToTerritories',
        label: 'Not Alinged to territories',
    }, 
];

const EXAMPLES_DATA_BASIC = [
    {"id":1,"totalAccounts":33284,"specialty":'Cardiology',"recordtype":'Government Agency',"isActive":true,"visitedCalled":12176,"partCyclePlan":2500,"notPartOfCyclePlan":2096,"notInProductMetrics":44,"noAddress":50,"notAlignedToTerritories":8},
    {"id":2,"totalAccounts":40080,"specialty":'Emergency Medicine',"recordtype":'Board Memberships',"isActive":true,"visitedCalled":35000,"partCyclePlan":5258,"notPartOfCyclePlan":2348,"notInProductMetrics":134,"noAddress":5,"notAlignedToTerritories":9},
    {"id":3,"totalAccounts":34469,"specialty":'Family Medicine',"recordtype":'Practice',"isActive":true,"visitedCalled":3039,"partCyclePlan":25700,"notPartOfCyclePlan":15500,"notInProductMetrics":81,"noAddress":24,"notAlignedToTerritories":8},
    {"id":4,"totalAccounts":30417,"specialty":'General Practice',"recordtype":'Hospital Profiles',"isActive":true,"visitedCalled":12107,"partCyclePlan":10500,"notPartOfCyclePlan":2500,"notInProductMetrics":91,"noAddress":35,"notAlignedToTerritories":10},

    {"id":11,"totalAccounts":26956,"specialty":"Behavioral Medicine","recordtype":'Government Agency',"isActive":false,"visitedCalled":24159,"partCyclePlan":15874,"notPartOfCyclePlan":20070,"notInProductMetrics":6,"noAddress":3,"notAlignedToTerritories":6},
    {"id":12,"totalAccounts":15783,"specialty":"Hearing Instrument Specialist","recordtype":'Board Memberships',"isActive":false,"visitedCalled":10852,"partCyclePlan":13785,"notPartOfCyclePlan":1093,"notInProductMetrics":85,"noAddress":5,"notAlignedToTerritories":3},
    {"id":13,"totalAccounts":30142,"specialty":"Medical Oncology","recordtype":'Practice',"isActive":false,"visitedCalled":21587,"partCyclePlan":14369,"notPartOfCyclePlan":7391,"notInProductMetrics":96,"noAddress":11,"notAlignedToTerritories":3},
    {"id":14,"totalAccounts":50408,"specialty":"Dental Hygienist","recordtype":'Hospital Profiles',"isActive":false,"visitedCalled":37722,"partCyclePlan":8718,"notPartOfCyclePlan":24045,"notInProductMetrics":104,"noAddress":2,"notAlignedToTerritories":9},
    {"id":15,"totalAccounts":77200,"specialty":"Electrologist / Hypertrichologist","recordtype":'Employer Accounts',"isActive":false,"visitedCalled":38968,"partCyclePlan":34101,"notPartOfCyclePlan":26250,"notInProductMetrics":60,"noAddress":5,"notAlignedToTerritories":10},
    {"id":16,"totalAccounts":45455,"specialty":"Pharmacy Technician","recordtype":'Hospital Department',"isActive":false,"visitedCalled":19159,"partCyclePlan":25741,"notPartOfCyclePlan":30852,"notInProductMetrics":143,"noAddress":23,"notAlignedToTerritories":8},
    {"id":17,"totalAccounts":28330,"specialty":"Optometrist","recordtype":'Hospital Profiles',"isActive":false,"visitedCalled":21874,"partCyclePlan":10258,"notPartOfCyclePlan":14852,"notInProductMetrics":117,"noAddress":50,"notAlignedToTerritories":6},

    
    {"id":5,"totalAccounts":9281,"specialty":'Internal Medicine',"recordtype":'Employer Accounts',"isActive":true,"visitedCalled":8500,"partCyclePlan":1500,"notPartOfCyclePlan":15,"notInProductMetrics":66,"noAddress":47,"notAlignedToTerritories":2},
    {"id":6,"totalAccounts":32857,"specialty":'Oncology',"recordtype":'Hospital Department',"isActive":true,"visitedCalled":30753,"partCyclePlan":2587,"notPartOfCyclePlan":2654,"notInProductMetrics":124,"noAddress":17,"notAlignedToTerritories":4},
    {"id":7,"totalAccounts":37388,"specialty":'Other',"recordtype":'Hospital Profiles',"isActive":true,"visitedCalled":8294,"partCyclePlan":17769,"notPartOfCyclePlan":20789,"notInProductMetrics":114,"noAddress":23,"notAlignedToTerritories":3},
    {"id":8,"totalAccounts":36804,"specialty":'Pediatrics',"recordtype":'Medical Institution',"isActive":true,"visitedCalled":25874,"partCyclePlan":22271,"notPartOfCyclePlan":2587,"notInProductMetrics":81,"noAddress":31,"notAlignedToTerritories":3},
    
    {"id":18,"totalAccounts":50652,"specialty":"Orthotist","recordtype":'Medical Institution',"isActive":false,"visitedCalled":28940,"partCyclePlan":5758,"notPartOfCyclePlan":24064,"notInProductMetrics":90,"noAddress":18,"notAlignedToTerritories":2},
    {"id":19,"totalAccounts":12745,"specialty":"Acupuncturist","recordtype":'Managed Care Plan',"isActive":false,"visitedCalled":6500,"partCyclePlan":6500,"notPartOfCyclePlan":1656,"notInProductMetrics":124,"noAddress":25,"notAlignedToTerritories":8},
    {"id":20,"totalAccounts":42782,"specialty":"General Preventive Medicine","recordtype":'Managed Care Organization',"isActive":false,"visitedCalled":8963,"partCyclePlan":34384,"notPartOfCyclePlan":18334,"notInProductMetrics":11,"noAddress":23,"notAlignedToTerritories":2},
];
const SPECIALITIES = [
    { label: 'All', value: 'All', selected: false}, 
    { label: 'Cardiology', value: 'Cardiology', selected: false},
    { label: 'Emergency Medicine', value: 'Emergency Medicine', selected: false}, 
    { label: 'Family Medicine', value: 'Family Medicine', selected: false},
    { label: 'General Practice', value: 'General Practice', selected: false},
    { label: 'Internal Medicine', value: 'Internal Medicine', selected: false},
    { label: 'Oncology', value: 'Oncology', selected: false},
    { label: 'Other', value: 'Other', selected: false},
    { label: 'Pediatrics', value: 'Pediatrics', selected: false},
    // inactive options
    { label: 'General Preventive Medicine', value: 'General Preventive Medicine', selected: false},
    { label: 'Mental Health Counselor', value: 'Mental Health Counselor', selected: false},
    { label: 'Acupuncturist', value: 'Acupuncturist', selected: false},
    { label: 'Orthotist', value: 'Orthotist', selected: false},
    { label: 'Clinical Laboratory Supervisor', value: 'Clinical Laboratory Supervisor', selected: false},
    { label: 'Dietician', value: 'Dietician', selected: false},
    { label: 'Massage Therapist', value: 'Massage Therapist', selected: false},
    { label: 'Radiation Therapist', value: 'Radiation Therapist', selected: false},
    { label: 'Behavioral Medicine', value: 'Behavioral Medicine', selected: false},
    { label: 'Clinical Laboratory Director', value: 'Clinical Laboratory Director', selected: false},
    { label: 'Optometrist', value: 'Optometrist', selected: false},
    { label: 'Pharmacology', value: 'Pharmacology', selected: false},
    { label: 'Alternative Care', value: 'Alternative Care', selected: false},
];
const RECORD_TYPES = [
    { label: 'All', value: 'All', selected: false}, 
    { label: 'Hospital Profiles', value: 'Hospital Profiles', selected: false},
    { label: 'Board Memberships', value: 'Board Memberships', selected: false},
    { label: 'Employer Accounts', value: 'Employer Accounts', selected: false},
    { label: 'Includes all Rehab, LTC, Nursing Home Facilities', value: 'Includes all Rehab, LTC, Nursing Home Facilities', selected: false},
    { label: 'Hospital Department', value: 'Hospital Department', selected: false},
    { label: 'Testing and Laboratory Service Providers', value: 'Testing and Laboratory Service Providers', selected: false},
    { label: 'Managed Care Plan', value: 'Managed Care Plan', selected: false},
    { label: 'Managed Care Organization', value: 'Managed Care Organization', selected: false},
    { label: 'Pharmacy Profiles', value: 'Pharmacy Profiles', selected: false},
    { label: 'Practice', value: 'Practice', selected: false},
    { label: 'Medical Professional', value: 'Medical Professional', selected: false},
    { label: 'Medical Institution', value: 'Medical Institution', selected: false},
    { label: 'Other Medical Organizations', value: 'Other Medical Organizations', selected: false},
    { label: 'Publication', value: 'Publication', selected: false},
    { label: 'Key Opinion Leader', value: 'Key Opinion Leader', selected: false},
    { label: 'Government Agency', value: 'Government Agency', selected: false}
];
export default class Vdt_onekeyAnalysisDetails extends LightningElement {

    gridColumns = EXAMPLES_COLUMNS_DEFINITION_BASIC;
    gridData = EXAMPLES_DATA_BASIC;
    _specialityOptions = SPECIALITIES;
    _recordTypeOptions = RECORD_TYPES;
    _data = EXAMPLES_DATA_BASIC;

    handleExportCSV() {
        let headers = {};
        this.gridColumns.forEach(col => headers[col.fieldName] = col.label);
        downloadCSVFile(headers, this.gridData, 'account_onekey_details');
    }

    handleSpecialityChange(evt) {
        let selectedSpecialities = evt.detail;
        if (selectedSpecialities.includes('All') || selectedSpecialities.length == 0) {
            this._data = this.gridData;
        } else {
            this._data = this.gridData.filter((record) => {
                return selectedSpecialities.includes(record.specialty);
            });
        }
    }

    handleRecordTypeChange(evt) {
        let selectedRecordTypes = evt.detail;
        if (selectedRecordTypes.includes('All') || selectedRecordTypes.length == 0) {
            this._data = this.gridData;
        } else {
            this._data = this.gridData.filter((record) => {
                return selectedRecordTypes.includes(record.recordtype);
            });
        }
    }
}