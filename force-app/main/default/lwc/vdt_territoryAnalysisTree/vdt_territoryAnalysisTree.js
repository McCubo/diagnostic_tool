import { LightningElement, api, wire } from 'lwc';
import { downloadCSVFile } from 'c/vdt_csvUtil'
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
import onekeyCountryChannel from '@salesforce/messageChannel/vdt_onekeyCountryChannel__c';

const COMPARISON_OPERATORS = [
    {label: 'equals', value: 'eq'},
    {label: 'not equals', value: 'neq'},
    {label: 'less than', value: 'lt'},
    {label: 'greater than', value: 'gt'},
    {label: 'less or equal', value: 'loe'},
    {label: 'greater or equal', value: 'goe'},
];
export default class Vdt_territoryAnalysisTree extends LightningElement {

    _columnsBase = [
        { label: 'Territory Name', fieldName: 'name', type: 'text' },
        { label: 'Total Accounts', fieldName: 'total_accounts', type: 'number' },
        { label: 'Territory Accounts', fieldName: 'territory_accounts', type: 'number' }
    ];

    _rawData = [];
    _calculationData = [];
    _columns = [];
    _specialtyColumns = [];
    territoryTreeData = [];
    _specialties = [];
    specialtyOptions = [];
    filterNumberValue = null;
    selectedSpecialty = null;
    _territoryFilter = '';
    operators = COMPARISON_OPERATORS;
    selectedOperator = null;
    amountFilter = null;
    @api
    countries = [];
    @wire(MessageContext)
    messageContext;
    _subscription = null;

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
            this.territoryTreeData = this.parseData(JSON.parse(this._rawData));
        }
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this._subscription);
        this._subscription = null;
    }

    @api
    get calculationData() {
        return this._calculationData;
    }

    set calculationData(val) {
        let data = JSON.parse(val);
        this._rawData = val;
        this.setSpecialtyColumns(data);
        this.territoryTreeData = this.parseData(data);
    }

    setSpecialtyColumns(data) {
        let options = [];
        if (data.specialties && data.specialties.length > 0) {
            data.specialties.forEach(specialty => {
                options.push({label: specialty, value: `${specialty}_accounts`});
                    this._specialtyColumns.push({ label: specialty, fieldName: `${specialty}_accounts`, type: 'number', initialWidth: 110});
                    this._specialties.push(`${specialty}_accounts`);
                }
            );
            this._columns = this._columnsBase.concat(this._specialtyColumns);
        }
        this.specialtyOptions = options;
    }

    parseData(data) {
        let territoryAnalysis = data.territoryAnalysis;
        let parentTerritories = Object.values(territoryAnalysis)
                                .filter(territory => {
                                    if (this._territoryFilter) {
                                        return territory.parentId == null && territory.name.toLowerCase().includes(this._territoryFilter);
                                    }
                                    return territory.parentId == null;
                                })
                                .map(territory => this.flatTerritoryRecord(territory))
                                .filter(territory => this.filterBySpecialty(territory));
        parentTerritories.forEach(parentTerritory => {
            this.addChildRecords(parentTerritory, territoryAnalysis);
        });
        parentTerritories.forEach(parentTerritory => {
            parentTerritory['total_accounts'] = this.getTotalAccounts(parentTerritory);
        });        
        return parentTerritories;
    }

    filterBySpecialty(territory) {
        let filter = true;
        if (this.selectedSpecialty && this.selectedOperator && this.amountFilter) {
            switch(this.selectedOperator) {
                case 'eq':
                    filter = territory[this.selectedSpecialty] == this.amountFilter;
                    break;
                case 'neq':
                    filter = territory[this.selectedSpecialty] != this.amountFilter;
                    break;
                case 'lt':
                    filter = territory[this.selectedSpecialty] < this.amountFilter;
                    break;
                case 'gt':
                    filter = territory[this.selectedSpecialty] > this.amountFilter;
                    break;
                case 'loe':
                    filter = territory[this.selectedSpecialty] <= this.amountFilter;
                    break;
                case 'goe':
                    filter = territory[this.selectedSpecialty] >= this.amountFilter;
                    break;
            }
        }
        return filter;
    }

    flatTerritoryRecord(territory) {
        let specialtyNumbers = {};
        let accountsInTerritory = 0;
        Object.keys(territory.countrySummary).forEach(countryCode => {
            if (this.countries.includes(countryCode) || this.countries.includes('All')) {
                Object.keys(territory.countrySummary[countryCode]).forEach(specialty => {
                    if (specialtyNumbers[`${specialty}_accounts`]) {
                        specialtyNumbers[`${specialty}_accounts`] += territory.countrySummary[countryCode][specialty];
                    } else {
                        specialtyNumbers[`${specialty}_accounts`] = territory.countrySummary[countryCode][specialty];
                    }
                    accountsInTerritory += specialtyNumbers[`${specialty}_accounts`];
                });
            }
        });
        this._specialties.forEach(specialtyProperty => {
            if (!territory.hasOwnProperty(specialtyProperty)) {
                territory[specialtyProperty] = 0;
            }
        })
        territory['territory_accounts'] = accountsInTerritory;
        return Object.assign(territory, specialtyNumbers);
    }

    addChildRecords(parentTerritory, territoryAnalysis) {
        let childerTerritories = Object.values(territoryAnalysis)
                                .filter(territory => {
                                    if (this._territoryFilter) {
                                        return territory.parentId == parentTerritory.id && territory.name.toLowerCase().includes(this._territoryFilter);
                                    }
                                    return territory.parentId == parentTerritory.id;
                                })
                                .map(childTerritory => {
                                    this.addChildRecords(childTerritory, territoryAnalysis);
                                    return this.flatTerritoryRecord(childTerritory);
                                })
                                .filter(territory => this.filterBySpecialty(territory));
        if (childerTerritories != null && childerTerritories.length > 0) {
            parentTerritory['_children'] = childerTerritories;
        }
    }

    getTotalAccounts(parentTerritory) {
        let totalAccounts = parentTerritory['territory_accounts'];
        if (parentTerritory._children != null && parentTerritory._children.length > 0) {
            parentTerritory._children.forEach(childTerritory => {
                let totalChildAccounts = this.getTotalAccounts(childTerritory);
                totalAccounts += totalChildAccounts;
                childTerritory['total_accounts'] = totalChildAccounts;
            });
        }
        return totalAccounts;
    }

    handleTerritoryFilterInputChange(event) {
        let territoryFilterInput = event.target.value.toLowerCase();
        this._territoryFilter = territoryFilterInput;
        this.territoryTreeData = this.parseData(JSON.parse(this._rawData));
    }

    handleSpecialtyOptionSelect(event) {
        this.selectedSpecialty = event.detail;
        this.territoryTreeData = this.parseData(JSON.parse(this._rawData));
    }

    handleOperatorOptionSelect(event) {
        this.selectedOperator = event.detail;
        this.territoryTreeData = this.parseData(JSON.parse(this._rawData));
    }

    handleAmountChange(event){
        this.amountFilter = event.detail.value;
        this.territoryTreeData = this.parseData(JSON.parse(this._rawData));
    }

    handleExportCSV() {
        let headers = {};
        this._columns.forEach(col => headers[col.fieldName] = col.label);
        headers['parentTerritory'] = 'Parent Territory';
        let records = [];
        this.flatTreeData(this.territoryTreeData, records, null);
        downloadCSVFile(headers, records, 'territory_analysis');
    }

    flatTreeData(treeData, records, parentTerritory) {
        treeData.forEach(territory => {
            let flatTerritory = Object.assign({}, territory);
            // removing unneeded properties
            delete flatTerritory.parentId;
            delete flatTerritory.countrySummary;
            delete flatTerritory._children;
            if (parentTerritory) {
                flatTerritory['parentTerritory'] = parentTerritory;
            }             
            records.push(flatTerritory);
            if (territory._children) {
                this.flatTreeData(territory._children, records, territory.name);
            }           
        });
    }
}