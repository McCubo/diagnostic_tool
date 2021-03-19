import { LightningElement, wire, api } from 'lwc';
import onekeyCountryChannel from '@salesforce/messageChannel/vdt_onekeyCountryChannel__c';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';

import { downloadCSVFile } from 'c/vdt_csvUtil'

const COLUMNS = [
    { type: 'text', fieldName: 'specialty', label: 'Specialty' },
    { type: 'text', fieldName: 'recordtype', label: 'Record Type', wrapText: true },
    { type: 'boolean', fieldName: 'isActive', label: 'Is Speciality Active?' },
    { type: 'text', fieldName: 'totalAccounts', label: 'Total Accounts' },
    { type: 'text', fieldName: 'visitedCalled', label: 'Visited/Called' },
    { type: 'text', fieldName: 'partCyclePlan', label: 'Part of Cycle plan' },
    { type: 'text', fieldName: 'notPartOfCyclePlan', label: 'Visited and Not part of Cycle plan' },
    { type: 'text', fieldName: 'notInProductMetrics', label: 'Not used in Product metric?' },
    { type: 'text', fieldName: 'noAddress', label: 'No Address' }, 
    { type: 'text', fieldName: 'notAlignedToTerritories', label: 'Not Alinged to territories' }, 
];

export default class Vdt_onekeyAnalysisDetails extends LightningElement {

    @api
    countries = [];
    _specialityOptions = [];
    _recordTypeOptions = [];
    columns = COLUMNS;

    _rawData = [];
    _calculationData = []
    _recordTypes = [];
    _specialties = [];
    _subscription = null;

    @wire(MessageContext)
    messageContext;

    @api
    get calculationData() {
        return this._calculationData;
    }
    set calculationData(val) {
        this._rawData = val;
        let data = JSON.parse(val);
        this._specialityOptions = data.specialties.map(specialty => {
            return { label: specialty, value: specialty };
        });
        this._recordTypeOptions = data.recordTypes.map(recordType => {
            return { label: recordType, value: recordType };
        });
        this._calculationData = this.parseData(data);
    }

    parseData(data) {
        let parsedData = [];
        Object.values(data.calculations).forEach(specialty => {
            if (this._specialties.length == 0 || this._specialties.includes(specialty.specialty)) {
                let specialtyEntry = {
                    id: specialty.id,
                    specialty: specialty.specialty,
                    recordtype: '',
                    isActive: specialty.isActive,
                    totalAccounts: 0,
                    visitedCalled: 0,
                    partCyclePlan: 0,
                    notPartOfCyclePlan: 0,
                    notInProductMetrics: 0,
                    noAddress: 0,
                    notAlignedToTerritories: 0
                };
                if (this._recordTypes.length == 0) {
                    specialtyEntry.recordtype = 'All';
                } else {
                    specialtyEntry.recordtype = this._recordTypes.join(', ');
                }
                Object.values(specialty.recordTypeUsageSummary).forEach(recordTypeInfo => {
                    if (this._recordTypes.length == 0 || this._recordTypes.includes(recordTypeInfo.name)) {
                        Object.keys(recordTypeInfo.countryUsageSummary).forEach(countryCode => {
                            if (this.countries.includes(countryCode) || this.countries.includes('All')) {
                                specialtyEntry.totalAccounts += recordTypeInfo.countryUsageSummary[countryCode].totalAccounts;
                                specialtyEntry.visitedCalled += recordTypeInfo.countryUsageSummary[countryCode].visitedCalled;
                                specialtyEntry.partCyclePlan += recordTypeInfo.countryUsageSummary[countryCode].partCyclePlan;
                                specialtyEntry.notPartOfCyclePlan += recordTypeInfo.countryUsageSummary[countryCode].notPartOfCyclePlan;
                                specialtyEntry.notInProductMetrics += recordTypeInfo.countryUsageSummary[countryCode].notInProductMetrics;
                                specialtyEntry.noAddress += recordTypeInfo.countryUsageSummary[countryCode].noAddress;
                                specialtyEntry.notAlignedToTerritories += recordTypeInfo.countryUsageSummary[countryCode].notAlignedToTerritories;
                            }
                        });
                    }
                });
                parsedData.push(specialtyEntry);
            }
        });
        return parsedData;
    }

    connectedCallback() {
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
            this.countries = message.countries;
            this._calculationData = this.parseData(JSON.parse(this._rawData));
        }
    }

    handleExportCSV() {
        let headers = {};
        this.columns.forEach(col => headers[col.fieldName] = col.label);
        downloadCSVFile(headers, this._calculationData, 'account_onekey_details');
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this._subscription);
        this._subscription = null;
    }

    handleSpecialityChange(evt) {
        this._specialties = evt.detail;
        this._calculationData = this.parseData(JSON.parse(this._rawData));
    }

    handleRecordTypeChange(evt) {
        this._recordTypes = evt.detail;
        this._calculationData = this.parseData(JSON.parse(this._rawData));
    }
}