import { LightningElement } from 'lwc';

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
        label: 'Active Picklist value?'
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
    {
        id: 99,
        totalAccounts: 15700,
        specialty: 'Cardiology',
        recordtype: 'Board Memberships',
        isActive: true,
        visitedCalled: '68000',
        partCyclePlan: '10000',
        notPartOfCyclePlan: '20',
        notInProductMetrics: '50',
        noAddress: '250',
        notAlignedToTerritories: '1'
    },
    {
        id: 96,
        totalAccounts: 951,
        specialty: 'General Preventive Medicine',
        recordtype: 'Board Memberships',
        isActive: false,
        visitedCalled: '45200',
        partCyclePlan: '10000',
        notPartOfCyclePlan: '23',
        notInProductMetrics: '78',
        noAddress: '100',
        notAlignedToTerritories: '4'
    },
    {
        id: 94,
        totalAccounts: 10020,
        specialty: 'Pediatrics',
        recordtype: 'Board Memberships',
        isActive: false,
        visitedCalled: '85400',
        partCyclePlan: '25600',
        notPartOfCyclePlan: '100',
        notInProductMetrics: '52',
        noAddress: '33',
        notAlignedToTerritories: '20'
    },
];

export default class Vdt_onekeyAnalysisDetails extends LightningElement {

    gridColumns = EXAMPLES_COLUMNS_DEFINITION_BASIC;
    gridData = EXAMPLES_DATA_BASIC;
}