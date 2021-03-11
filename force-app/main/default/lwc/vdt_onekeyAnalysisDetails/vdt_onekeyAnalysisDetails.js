import { LightningElement, wire } from 'lwc';
import onekeyCountryChannel from '@salesforce/messageChannel/vdt_onekeyCountryChannel__c';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';

import { downloadCSVFile } from 'c/vdt_csvUtil'

const COLUMNS = [
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

const RAW_DATA = [
    {"id":1,"totalAccounts":33284,"specialty":'Cardiology',"isActive":true,
        "recordTypeUsageSummary": {
            "Hospital Profiles": {"visitedCalled":12176,"partCyclePlan":2500,"notPartOfCyclePlan":2096,"notInProductMetrics":44,"noAddress":50,"notAlignedToTerritories":8, "country": 'PL'},
            "Practice": {"visitedCalled":12176,"partCyclePlan":2500,"notPartOfCyclePlan":2096,"notInProductMetrics":44,"noAddress":50,"notAlignedToTerritories":8, "country": 'PL'},
            "Board Memberships": {"visitedCalled":12176,"partCyclePlan":2500,"notPartOfCyclePlan":2096,"notInProductMetrics":44,"noAddress":50,"notAlignedToTerritories":8, "country": 'IE'},
            "Employer Accounts": {"visitedCalled":12176,"partCyclePlan":2500,"notPartOfCyclePlan":2096,"notInProductMetrics":44,"noAddress":50,"notAlignedToTerritories":8, "country": 'IE'},
            "Hospital Department": {"visitedCalled":12176,"partCyclePlan":2500,"notPartOfCyclePlan":2096,"notInProductMetrics":44,"noAddress":50,"notAlignedToTerritories":8, "country": 'GB'}
        }
        
    },
    {"id":2,"totalAccounts":40080,"specialty":'Emergency Medicine',"isActive":true,
        "recordTypeUsageSummary": {
            "Hospital Profiles": {"visitedCalled":25478,"partCyclePlan":42100,"notPartOfCyclePlan":1020,"notInProductMetrics":23,"noAddress":10,"notAlignedToTerritories":1, "country": 'PL'},
            "Board Memberships": {"visitedCalled":25478,"partCyclePlan":42100,"notPartOfCyclePlan":1020,"notInProductMetrics":23,"noAddress":10,"notAlignedToTerritories":1, "country": 'PL'},
            "Employer Accounts": {"visitedCalled":25478,"partCyclePlan":42100,"notPartOfCyclePlan":1020,"notInProductMetrics":23,"noAddress":10,"notAlignedToTerritories":1, "country": 'PL'},
            "Medical Professional": {"visitedCalled":25478,"partCyclePlan":42100,"notPartOfCyclePlan":2096,"notInProductMetrics":23,"noAddress":10,"notAlignedToTerritories":1, "country": 'GB'},
            "Medical Institution": {"visitedCalled":25478,"partCyclePlan":42100,"notPartOfCyclePlan":2096,"notInProductMetrics":23,"noAddress":10,"notAlignedToTerritories":1, "country": 'IT'},
            "Other Medical Organizations": {"visitedCalled":25478,"partCyclePlan":42100,"notPartOfCyclePlan":2096,"notInProductMetrics":23,"noAddress":10,"notAlignedToTerritories":1, "country": 'FR'},
            "Publication": {"visitedCalled":25478,"partCyclePlan":42100,"notPartOfCyclePlan":2096,"notInProductMetrics":23,"noAddress":10,"notAlignedToTerritories":1, "country": 'FR'},
        }
    },
    {"id":3,"totalAccounts":34469,"specialty":'Family Medicine',"isActive":true,
        "recordTypeUsageSummary" : {
            "Practice" : {"visitedCalled":3039,"partCyclePlan":25700,"notPartOfCyclePlan":15500,"notInProductMetrics":81,"noAddress":24,"notAlignedToTerritories":8, "country": 'PL'},
            "Publication" : {"visitedCalled":3039,"partCyclePlan":25700,"notPartOfCyclePlan":15500,"notInProductMetrics":81,"noAddress":24,"notAlignedToTerritories":8, "country": 'PL'},
            "Employer Accounts" : {"visitedCalled":3039,"partCyclePlan":25700,"notPartOfCyclePlan":15500,"notInProductMetrics":81,"noAddress":24,"notAlignedToTerritories":8, "country": 'PL'},
            "Publication" : {"visitedCalled":3039,"partCyclePlan":25700,"notPartOfCyclePlan":15500,"notInProductMetrics":81,"noAddress":24,"notAlignedToTerritories":8, "country": 'GB'},
            "Board Memberships" : {"visitedCalled":3039,"partCyclePlan":25700,"notPartOfCyclePlan":15500,"notInProductMetrics":81,"noAddress":24,"notAlignedToTerritories":8, "country": 'FR'},
            "Hospital Profiles" : {"visitedCalled":3039,"partCyclePlan":25700,"notPartOfCyclePlan":15500,"notInProductMetrics":81,"noAddress":24,"notAlignedToTerritories":8, "country": 'IE'},
        }
    },
    {"id":4,"totalAccounts":30417,"specialty":'General Practice',"isActive":true,
        "recordTypeUsageSummary": {
            "Other Medical Organizations" : {"visitedCalled":12107,"partCyclePlan":10500,"notPartOfCyclePlan":2500,"notInProductMetrics":91,"noAddress":35,"notAlignedToTerritories":10, "country": 'PL'},
            "Employer Accounts" : {"visitedCalled":12107,"partCyclePlan":10500,"notPartOfCyclePlan":2500,"notInProductMetrics":91,"noAddress":35,"notAlignedToTerritories":10, "country": 'PL'},
            "Employer Accounts" : {"visitedCalled":12107,"partCyclePlan":10500,"notPartOfCyclePlan":2500,"notInProductMetrics":91,"noAddress":35,"notAlignedToTerritories":10, "country": 'PL'},
            "Government Agency" : {"visitedCalled":12107,"partCyclePlan":10500,"notPartOfCyclePlan":2500,"notInProductMetrics":91,"noAddress":35,"notAlignedToTerritories":10, "country": 'FR'},
            "Key Opinion Leader" : {"visitedCalled":12107,"partCyclePlan":10500,"notPartOfCyclePlan":2500,"notInProductMetrics":91,"noAddress":35,"notAlignedToTerritories":10, "country": 'PL'},
        }
    },
    {"id":11,"totalAccounts":26956,"specialty":"Behavioral Medicine","isActive":false,
        "recordTypeUsageSummary": {
            "Government Agency": {"visitedCalled":24159,"partCyclePlan":15874,"notPartOfCyclePlan":20070,"notInProductMetrics":6,"noAddress":3,"notAlignedToTerritories":6, "country": 'PL'},
            "Board Memberships": {"visitedCalled":24159,"partCyclePlan":15874,"notPartOfCyclePlan":20070,"notInProductMetrics":6,"noAddress":3,"notAlignedToTerritories":6, "country": 'PL'},
            "Medical Institution": {"visitedCalled":24159,"partCyclePlan":15874,"notPartOfCyclePlan":20070,"notInProductMetrics":6,"noAddress":3,"notAlignedToTerritories":6, "country": 'PL'},
            "Hospital Profiles": {"visitedCalled":24159,"partCyclePlan":15874,"notPartOfCyclePlan":20070,"notInProductMetrics":6,"noAddress":3,"notAlignedToTerritories":6, "country": 'PL'},
            "Key Opinion Leader": {"visitedCalled":24159,"partCyclePlan":15874,"notPartOfCyclePlan":20070,"notInProductMetrics":6,"noAddress":3,"notAlignedToTerritories":6, "country": 'GB'},
            "Employer Accounts": {"visitedCalled":24159,"partCyclePlan":15874,"notPartOfCyclePlan":20070,"notInProductMetrics":6,"noAddress":3,"notAlignedToTerritories":6, "country": 'GB'},
            "Publication": {"visitedCalled":24159,"partCyclePlan":15874,"notPartOfCyclePlan":20070,"notInProductMetrics":6,"noAddress":3,"notAlignedToTerritories":6, "country": 'PL'},
        }
    },
    {"id":12,"totalAccounts":15783,"specialty":"Hearing Instrument Specialist","isActive":false,
        "recordTypeUsageSummary": {
            "Board Memberships": {"visitedCalled":10852,"partCyclePlan":13785,"notPartOfCyclePlan":1093,"notInProductMetrics":85,"noAddress":5,"notAlignedToTerritories":3, "country": 'PL'},
            "Publication": {"visitedCalled":10852,"partCyclePlan":13785,"notPartOfCyclePlan":1093,"notInProductMetrics":85,"noAddress":5,"notAlignedToTerritories":3, "country": 'PL'},
            "Government Agency": {"visitedCalled":10852,"partCyclePlan":13785,"notPartOfCyclePlan":1093,"notInProductMetrics":85,"noAddress":5,"notAlignedToTerritories":3, "country": 'PL'},
            "Practice": {"visitedCalled":10852,"partCyclePlan":13785,"notPartOfCyclePlan":1093,"notInProductMetrics":85,"noAddress":5,"notAlignedToTerritories":3, "country": 'GB'},
            "Medical Institution": {"visitedCalled":10852,"partCyclePlan":13785,"notPartOfCyclePlan":1093,"notInProductMetrics":85,"noAddress":5,"notAlignedToTerritories":3, "country": 'FR'},
            "Other Medical Organizations": {"visitedCalled":10852,"partCyclePlan":13785,"notPartOfCyclePlan":1093,"notInProductMetrics":85,"noAddress":5,"notAlignedToTerritories":3, "country": 'IE'},
            "Key Opinion Leader": {"visitedCalled":10852,"partCyclePlan":13785,"notPartOfCyclePlan":1093,"notInProductMetrics":85,"noAddress":5,"notAlignedToTerritories":3, "country": 'IT'},
        }
    },
    {"id":13,"totalAccounts":30142,"specialty":"Medical Oncology","isActive":false,
        "recordTypeUsageSummary": {
            "Practice": {"visitedCalled":21587,"partCyclePlan":14369,"notPartOfCyclePlan":7391,"notInProductMetrics":96,"noAddress":11,"notAlignedToTerritories":3, "country": 'PL'},
            "Hospital Profiles": {"visitedCalled":21587,"partCyclePlan":14369,"notPartOfCyclePlan":7391,"notInProductMetrics":96,"noAddress":11,"notAlignedToTerritories":3, "country": 'PL'},
            "Hospital Department": {"visitedCalled":21587,"partCyclePlan":14369,"notPartOfCyclePlan":7391,"notInProductMetrics":96,"noAddress":11,"notAlignedToTerritories":3, "country": 'PL'},
            "Government Agency": {"visitedCalled":21587,"partCyclePlan":14369,"notPartOfCyclePlan":7391,"notInProductMetrics":96,"noAddress":11,"notAlignedToTerritories":3, "country": 'IT'},
            "Board Memberships": {"visitedCalled":21587,"partCyclePlan":14369,"notPartOfCyclePlan":7391,"notInProductMetrics":96,"noAddress":11,"notAlignedToTerritories":3, "country": 'IE'},
            "Employer Accounts": {"visitedCalled":21587,"partCyclePlan":14369,"notPartOfCyclePlan":7391,"notInProductMetrics":96,"noAddress":11,"notAlignedToTerritories":3, "country": 'FR'},
        }
    },
    {"id":14,"totalAccounts":50408,"specialty":"Dental Hygienist","isActive":false,
        "recordTypeUsageSummary": {
            "Hospital Profiles": {"visitedCalled":37722,"partCyclePlan":8718,"notPartOfCyclePlan":24045,"notInProductMetrics":104,"noAddress":2,"notAlignedToTerritories":9, "country": 'PL'},
            "Government Agency": {"visitedCalled":37722,"partCyclePlan":8718,"notPartOfCyclePlan":24045,"notInProductMetrics":104,"noAddress":2,"notAlignedToTerritories":9, "country": 'IE'},
            "Key Opinion Leader": {"visitedCalled":37722,"partCyclePlan":8718,"notPartOfCyclePlan":24045,"notInProductMetrics":104,"noAddress":2,"notAlignedToTerritories":9, "country": 'FR'},
            "Practice": {"visitedCalled":37722,"partCyclePlan":8718,"notPartOfCyclePlan":24045,"notInProductMetrics":104,"noAddress":2,"notAlignedToTerritories":9, "country": 'GB'},
            "Pharmacy Profiles": {"visitedCalled":37722,"partCyclePlan":8718,"notPartOfCyclePlan":24045,"notInProductMetrics":104,"noAddress":2,"notAlignedToTerritories":9, "country": 'IT'},
        }
    },
    {"id":15,"totalAccounts":77200,"specialty":"Electrologist / Hypertrichologist","isActive":false,
        "recordTypeUsageSummary": {
            "Employer Accounts": {"visitedCalled":38968,"partCyclePlan":34101,"notPartOfCyclePlan":26250,"notInProductMetrics":60,"noAddress":5,"notAlignedToTerritories":10, "country": 'PL'},
            "Pharmacy Profiles": {"visitedCalled":38968,"partCyclePlan":34101,"notPartOfCyclePlan":26250,"notInProductMetrics":60,"noAddress":5,"notAlignedToTerritories":10, "country": 'PL'},
            "Government Agency": {"visitedCalled":38968,"partCyclePlan":34101,"notPartOfCyclePlan":26250,"notInProductMetrics":60,"noAddress":5,"notAlignedToTerritories":10, "country": 'PL'},
            "Other Medical Organizations": {"visitedCalled":38968,"partCyclePlan":34101,"notPartOfCyclePlan":26250,"notInProductMetrics":60,"noAddress":5,"notAlignedToTerritories":10, "country": 'IT'},
            "Publication": {"visitedCalled":38968,"partCyclePlan":34101,"notPartOfCyclePlan":26250,"notInProductMetrics":60,"noAddress":5,"notAlignedToTerritories":10, "country": 'FR'},
            "Hospital Profiles": {"visitedCalled":38968,"partCyclePlan":34101,"notPartOfCyclePlan":26250,"notInProductMetrics":60,"noAddress":5,"notAlignedToTerritories":10, "country": 'IE'},
        }
    },
    {"id":16,"totalAccounts":45455,"specialty":"Pharmacy Technician","isActive":false,
        "recordTypeUsageSummary": {
            "Hospital Department" : {"visitedCalled":19159,"partCyclePlan":25741,"notPartOfCyclePlan":30852,"notInProductMetrics":143,"noAddress":23,"notAlignedToTerritories":8, "country": 'PL'},
            "Medical Professional" : {"visitedCalled":19159,"partCyclePlan":25741,"notPartOfCyclePlan":30852,"notInProductMetrics":143,"noAddress":23,"notAlignedToTerritories":8, "country": 'PL'},
            "Publication" : {"visitedCalled":19159,"partCyclePlan":25741,"notPartOfCyclePlan":30852,"notInProductMetrics":143,"noAddress":23,"notAlignedToTerritories":8, "country": 'PL'},
            "Government Agency" : {"visitedCalled":19159,"partCyclePlan":25741,"notPartOfCyclePlan":30852,"notInProductMetrics":143,"noAddress":23,"notAlignedToTerritories":8, "country": 'IE'},
            "Managed Care Plan" : {"visitedCalled":19159,"partCyclePlan":25741,"notPartOfCyclePlan":30852,"notInProductMetrics":143,"noAddress":23,"notAlignedToTerritories":8, "country": 'FR'},
            "Board Memberships" : {"visitedCalled":19159,"partCyclePlan":25741,"notPartOfCyclePlan":30852,"notInProductMetrics":143,"noAddress":23,"notAlignedToTerritories":8, "country": 'GB'},
            "Employer Accounts" : {"visitedCalled":19159,"partCyclePlan":25741,"notPartOfCyclePlan":30852,"notInProductMetrics":143,"noAddress":23,"notAlignedToTerritories":8, "country": 'IT'},
        }
    },
    {"id":17,"totalAccounts":28330,"specialty":"Optometrist","isActive":false,
        "recordTypeUsageSummary": {
            "Hospital Profiles": {"visitedCalled":21874,"partCyclePlan":10258,"notPartOfCyclePlan":14852,"notInProductMetrics":117,"noAddress":50,"notAlignedToTerritories":6, "country": 'PL'},
            "Board Memberships": {"visitedCalled":21874,"partCyclePlan":10258,"notPartOfCyclePlan":14852,"notInProductMetrics":117,"noAddress":50,"notAlignedToTerritories":6, "country": 'PL'},
            "Employer Accounts": {"visitedCalled":21874,"partCyclePlan":10258,"notPartOfCyclePlan":14852,"notInProductMetrics":117,"noAddress":50,"notAlignedToTerritories":6, "country": 'PL'},
            "Hospital Department": {"visitedCalled":21874,"partCyclePlan":10258,"notPartOfCyclePlan":14852,"notInProductMetrics":117,"noAddress":50,"notAlignedToTerritories":6, "country": 'PL'},
            "Managed Care Plan": {"visitedCalled":21874,"partCyclePlan":10258,"notPartOfCyclePlan":14852,"notInProductMetrics":117,"noAddress":50,"notAlignedToTerritories":6, "country": 'IE'},
            "Managed Care Organization": {"visitedCalled":21874,"partCyclePlan":10258,"notPartOfCyclePlan":14852,"notInProductMetrics":117,"noAddress":50,"notAlignedToTerritories":6, "country": 'FR'},
            "Pharmacy Profiles": {"visitedCalled":21874,"partCyclePlan":10258,"notPartOfCyclePlan":14852,"notInProductMetrics":117,"noAddress":50,"notAlignedToTerritories":6, "country": 'IT'},
        }
    },
    {"id":5,"totalAccounts":9281,"specialty":'Internal Medicine',"isActive":true,
        "recordTypeUsageSummary": {
            "Employer Accounts": {"visitedCalled":8500,"partCyclePlan":1500,"notPartOfCyclePlan":15,"notInProductMetrics":66,"noAddress":47,"notAlignedToTerritories":2, "country": 'PL'},
            "Managed Care Organization": {"visitedCalled":8500,"partCyclePlan":1500,"notPartOfCyclePlan":15,"notInProductMetrics":66,"noAddress":47,"notAlignedToTerritories":2, "country": 'PL'},
            "Pharmacy Profiles": {"visitedCalled":8500,"partCyclePlan":1500,"notPartOfCyclePlan":15,"notInProductMetrics":66,"noAddress":47,"notAlignedToTerritories":2, "country": 'PL'},
            "Practice": {"visitedCalled":8500,"partCyclePlan":1500,"notPartOfCyclePlan":15,"notInProductMetrics":66,"noAddress":47,"notAlignedToTerritories":2, "country": 'PL'},
        }
    },
    {"id":6,"totalAccounts":32857,"specialty":'Oncology',"isActive":true,
        "recordTypeUsageSummary": {
            "Hospital Department": {"visitedCalled":30753,"partCyclePlan":2587,"notPartOfCyclePlan":2654,"notInProductMetrics":124,"noAddress":17,"notAlignedToTerritories":4, "country": 'PL'},
            "Medical Professional": {"visitedCalled":30753,"partCyclePlan":2587,"notPartOfCyclePlan":2654,"notInProductMetrics":124,"noAddress":17,"notAlignedToTerritories":4, "country": 'PL'},
            "Medical Institution": {"visitedCalled":30753,"partCyclePlan":2587,"notPartOfCyclePlan":2654,"notInProductMetrics":124,"noAddress":17,"notAlignedToTerritories":4, "country": 'PL'},
            "Other Medical Organizations": {"visitedCalled":30753,"partCyclePlan":2587,"notPartOfCyclePlan":2654,"notInProductMetrics":124,"noAddress":17,"notAlignedToTerritories":4, "country": 'PL'},
            "Publication": {"visitedCalled":30753,"partCyclePlan":2587,"notPartOfCyclePlan":2654,"notInProductMetrics":124,"noAddress":17,"notAlignedToTerritories":4, "country": 'PL'},
        }
    },
    {"id":7,"totalAccounts":37388,"specialty":'Other',"isActive":true,
        "recordTypeUsageSummary": {
            "Board Memberships": {"visitedCalled":8294,"partCyclePlan":17769,"notPartOfCyclePlan":20789,"notInProductMetrics":114,"noAddress":23,"notAlignedToTerritories":3, "country": 'PL'},
            "Employer Accounts": {"visitedCalled":8294,"partCyclePlan":17769,"notPartOfCyclePlan":20789,"notInProductMetrics":114,"noAddress":23,"notAlignedToTerritories":3, "country": 'PL'},
            "Hospital Profiles": {"visitedCalled":8294,"partCyclePlan":17769,"notPartOfCyclePlan":20789,"notInProductMetrics":114,"noAddress":23,"notAlignedToTerritories":3, "country": 'PL'},
            "Government Agency": {"visitedCalled":8294,"partCyclePlan":17769,"notPartOfCyclePlan":20789,"notInProductMetrics":114,"noAddress":23,"notAlignedToTerritories":3, "country": 'PL'},
        }
    },
    {"id":8,"totalAccounts":36804,"specialty":'Pediatrics',"isActive":true,
        "recordTypeUsageSummary": {
            "Medical Institution": {"visitedCalled":25874,"partCyclePlan":22271,"notPartOfCyclePlan":2587,"notInProductMetrics":81,"noAddress":31,"notAlignedToTerritories":3, "country": 'PL'},
            "Hospital Department": {"visitedCalled":25874,"partCyclePlan":22271,"notPartOfCyclePlan":2587,"notInProductMetrics":81,"noAddress":31,"notAlignedToTerritories":3, "country": 'PL'},
            "Managed Care Plan": {"visitedCalled":25874,"partCyclePlan":22271,"notPartOfCyclePlan":2587,"notInProductMetrics":81,"noAddress":31,"notAlignedToTerritories":3, "country": 'PL'},
            "Managed Care Organization": {"visitedCalled":25874,"partCyclePlan":22271,"notPartOfCyclePlan":2587,"notInProductMetrics":81,"noAddress":31,"notAlignedToTerritories":3, "country": 'PL'},
        }
    },
    {"id":18,"totalAccounts":50652,"specialty":"Orthotist","isActive":false,
        "recordTypeUsageSummary": {
            "Medical Institution": {"visitedCalled":28940,"partCyclePlan":5758,"notPartOfCyclePlan":24064,"notInProductMetrics":90,"noAddress":18,"notAlignedToTerritories":2, "country": 'PL'},
            "Pharmacy Profiles": {"visitedCalled":28940,"partCyclePlan":5758,"notPartOfCyclePlan":24064,"notInProductMetrics":90,"noAddress":18,"notAlignedToTerritories":2, "country": 'PL'},
            "Practice": {"visitedCalled":28940,"partCyclePlan":5758,"notPartOfCyclePlan":24064,"notInProductMetrics":90,"noAddress":18,"notAlignedToTerritories":2, "country": 'PL'},
            "Medical Professional": {"visitedCalled":28940,"partCyclePlan":5758,"notPartOfCyclePlan":24064,"notInProductMetrics":90,"noAddress":18,"notAlignedToTerritories":2, "country": 'PL'},
        }
    },
    {"id":19,"totalAccounts":12745,"specialty":"Acupuncturist","isActive":false,
        "recordTypeUsageSummary": {
            "Managed Care Plan": {"visitedCalled":6500,"partCyclePlan":6500,"notPartOfCyclePlan":1656,"notInProductMetrics":124,"noAddress":25,"notAlignedToTerritories":8, "country": 'PL'},
            "Medical Institution": {"visitedCalled":6500,"partCyclePlan":6500,"notPartOfCyclePlan":1656,"notInProductMetrics":124,"noAddress":25,"notAlignedToTerritories":8, "country": 'PL'},
            "Other Medical Organizations": {"visitedCalled":6500,"partCyclePlan":6500,"notPartOfCyclePlan":1656,"notInProductMetrics":124,"noAddress":25,"notAlignedToTerritories":8, "country": 'PL'},
            "Publication": {"visitedCalled":6500,"partCyclePlan":6500,"notPartOfCyclePlan":1656,"notInProductMetrics":124,"noAddress":25,"notAlignedToTerritories":8, "country": 'PL'},
            "Government Agency": {"visitedCalled":6500,"partCyclePlan":6500,"notPartOfCyclePlan":1656,"notInProductMetrics":124,"noAddress":25,"notAlignedToTerritories":8, "country": 'PL'},
        }
    },
    {"id":20,"totalAccounts":42782,"specialty":"General Preventive Medicine","isActive":false,
        "recordTypeUsageSummary": {
            "Managed Care Organization": {"visitedCalled":8963,"partCyclePlan":34384,"notPartOfCyclePlan":18334,"notInProductMetrics":11,"noAddress":23,"notAlignedToTerritories":2, "country": 'PL'},
            "Hospital Profiles": {"visitedCalled":8963,"partCyclePlan":34384,"notPartOfCyclePlan":18334,"notInProductMetrics":11,"noAddress":23,"notAlignedToTerritories":2, "country": 'PL'},
            "Board Memberships": {"visitedCalled":8963,"partCyclePlan":34384,"notPartOfCyclePlan":18334,"notInProductMetrics":11,"noAddress":23,"notAlignedToTerritories":2, "country": 'PL'},
            "Employer Accounts": {"visitedCalled":8963,"partCyclePlan":34384,"notPartOfCyclePlan":18334,"notInProductMetrics":11,"noAddress":23,"notAlignedToTerritories":2, "country": 'PL'},
            "Hospital Department": {"visitedCalled":8963,"partCyclePlan":34384,"notPartOfCyclePlan":18334,"notInProductMetrics":11,"noAddress":23,"notAlignedToTerritories":2, "country": 'PL'},
        }
    }
];
const SPECIALITIES = [
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
    { label: 'All', value: 'All', selected: true}, 
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

    gridColumns = COLUMNS;
    tempData = [];
    _specialityOptions = SPECIALITIES;
    _recordTypeOptions = RECORD_TYPES;
    _data = [];
    _recordTypes = ['All'];
    _subscription = null;
    _selectedCountry = 'All';

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.updateTableInformation();
        this.subscribeToMessageChannel();
    }
    subscribeToMessageChannel() {
        if (!this._subscription) {
            this._subscription = subscribe(
                this.messageContext,
                onekeyCountryChannel,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    handleMessage(message) {
        if (message.countries) {
            this._selectedCountry = message.countries;
            this.updateTableInformation();
        }
    }

    handleExportCSV() {
        let headers = {};
        this.gridColumns.forEach(col => headers[col.fieldName] = col.label);
        downloadCSVFile(headers, this._data, 'account_onekey_details');
    }

    handleSpecialityChange(evt) {
        let selectedSpecialities = evt.detail;
        this.updateTableInformation();
        if (selectedSpecialities.includes('All') || selectedSpecialities.length == 0) {
            this._data = this.tempData;
        } else {
            this._data = this.tempData.filter((record) => {
                return selectedSpecialities.includes(record.specialty);
            });
        }
    }

    handleRecordTypeChange(evt) {
        this._recordTypes = evt.detail;
        this.updateTableInformation();
    }

    updateTableInformation() {
        this._data = RAW_DATA.map((record) => {
            let calculationsOnRecordTypes = { visitedCalled: 0, partCyclePlan: 0, notPartOfCyclePlan: 0, notInProductMetrics: 0, noAddress: 0, notAlignedToTerritories:0 };
            Object.keys(record.recordTypeUsageSummary).forEach(recordTypeName => {
                if (this._recordTypes.length == 0 || this._recordTypes.includes('All') || this._recordTypes.includes(recordTypeName)) {
                    if (this._selectedCountry == 'All' || this._selectedCountry == record.recordTypeUsageSummary[recordTypeName]['country']) {
                        Object.keys(calculationsOnRecordTypes).forEach(propertyName => {
                            calculationsOnRecordTypes[propertyName] += record.recordTypeUsageSummary[recordTypeName][propertyName];
                        });
                    }
                }
            });
            return {
                ...record,
                ...calculationsOnRecordTypes
            }
        });
        this.tempData = JSON.parse(JSON.stringify(this._data))
    }
}