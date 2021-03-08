import { LightningElement } from 'lwc';

export default class Vdt_onekeyDetailFilters extends LightningElement {

    _specialityOptions = [
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
    _recordTypeOptions = [
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

    handleCountryOptionSelect(evt) {
        console.log(evt.detail);
    }
}