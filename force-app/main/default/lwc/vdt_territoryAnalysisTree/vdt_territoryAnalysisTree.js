import { LightningElement, api, wire, track } from 'lwc';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
import { showToast } from 'c/vdt_utils';
import onekeyCountryChannel from '@salesforce/messageChannel/vdt_onekeyCountryChannel__c';
import getRecordsPerPage from '@salesforce/apex/VDT_TerritoryAnalysisController.getRecordsPerPageSOQL';
import exportReport from '@salesforce/apex/VDT_TerritoryAnalysisController.exportReport';

const COMPARISON_OPERATORS = [
    {label: 'equals', value: 'eq'},
    {label: 'not equals', value: 'neq'},
    {label: 'less than', value: 'lt'},
    {label: 'greater than', value: 'gt'},
    {label: 'less or equal', value: 'loe'},
    {label: 'greater or equal', value: 'goe'},
];
const ACCOUNT_TYPES = [
    {label: 'Business Accounts', value: 'Business'},
    {label: 'Person Accounts', value: 'Person'}
];
export default class Vdt_territoryAnalysisTree extends LightningElement {

    _columnsBase = [
        { label: 'Territory Name', fieldName: 'name', type: 'text', initialWidth: 150 },
        { label: 'Territory Accounts', fieldName: 'territory_accounts', type: 'number', initialWidth: 115 }
    ];

    accountTypeOptions = ACCOUNT_TYPES;
    _specialties = [];
    metricOptions = [];
    operators = COMPARISON_OPERATORS;
    @api
    countries = [];
    @api
    calculationRecordId;

    isExportLoading = false;
    treeItems = [];
    selectedItem = null;
    prevSelection = null;
    @wire(MessageContext)
    messageContext;
    _subscription = null;
    // Pagination Variables
    _recordsPerPage = 10;
    _currentPage = 1;
    // Filter Variables
    _accountType = 'All';
    _filterNumber = null;
    _comparisonOperator = null;
    _specialtyName = null;
    _territoryName = null;
    // 
    @track
    serverResponse = {};

    loadFromServer() {
        this.serverResponse = {};
        getRecordsPerPage({ 
            calculationRecordId: this.calculationRecordId,
            pageNumber: this._currentPage, 
            recordsPerPage: this._recordsPerPage,
            countries: this.countries,
            territoryName: this._territoryName,
            specialtyName: this._specialtyName,
            comparisonOperator: this._comparisonOperator,
            filterNumber: this._filterNumber,
            accountType: this._accountType
        }).then(result => {
            this.serverResponse.data = result;
        }).catch(error => {
            this.serverResponse.error = error;
        })
    }    

    get isLoading() {
        return !this.serverResponse.data && !this.serverResponse.error;
    }

    connectedCallback() {
        this.loadFromServer();
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
            this._currentPage = 1;
            this.loadFromServer();
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
        return null;
    }

    set calculationData(val) {
        let data = JSON.parse(val);
        this.setMetricOptions(data);
        this.treeItems = data.items;
    }

    setMetricOptions(data) {
        let options = [
            {label: 'Territory Accounts', value: 'territory_accounts'}
        ];
        if (data.specialties && data.specialties.length > 0) {
            data.specialties.forEach(specialty => {
                    options.push({label: specialty, value: `${specialty}_accounts`});
                    this._specialties.push(`${specialty}_accounts`);
                }
            );
        }
        this.metricOptions = options;
    }

    getSpecialtyColumnsWithValues(territories) {
        let defaultProperties = ['parentId', 'name', 'id', 'businessCountrySummary', 'personCountrySummary', 'territory_accounts', 'total_accounts', '_children'];
        let columnsWithValues = territories.reduce((accumulator, territory) => {
            let cols = [];
            Object.keys(territory).forEach(propertyName => {
                if (territory[propertyName] != 0 && !defaultProperties.includes(propertyName)) {
                    cols.push(propertyName);
                }
            });
            return accumulator.concat(cols);
        }, []);
        return columnsWithValues;
    }

    flatTerritoryRecord(territory) {
        let specialtyNumbers = {};
        let accountsInTerritory = 0;
        let countrySummaryProperties = [];
        if (this._accountType == 'All' || this._accountType == 'Business') {
            countrySummaryProperties.push('businessCountrySummary');
        }
        if (this._accountType == 'All' || this._accountType == 'Person') {
            countrySummaryProperties.push('personCountrySummary');
        }
        countrySummaryProperties.forEach(countrySummaryProperty => {
            Object.keys(territory[countrySummaryProperty]).forEach(countryCode => {
                if (this.countries.includes(countryCode) || this.countries.includes('All')) {
                    Object.keys(territory[countrySummaryProperty][countryCode]).forEach(specialty => {
                        if (specialtyNumbers[`${specialty}_accounts`]) {
                            specialtyNumbers[`${specialty}_accounts`] += territory[countrySummaryProperty][countryCode][specialty];
                        } else {
                            specialtyNumbers[`${specialty}_accounts`] = territory[countrySummaryProperty][countryCode][specialty];
                        }
                        accountsInTerritory += territory[countrySummaryProperty][countryCode][specialty];
                    });
                }
            });
        });

        this._specialties.forEach(specialtyProperty => {
            if (!territory.hasOwnProperty(specialtyProperty)) {
                territory[specialtyProperty] = 0;
            }
        })
        territory['territory_accounts'] = accountsInTerritory;
        return Object.assign(territory, specialtyNumbers);
    }

    handleTerritoryFilterInputChange(event) {
        this._currentPage = 1;
        this.selectedItem = null;
        let territoryFilterInput = event.target.value.toLowerCase();
        this._territoryName = territoryFilterInput;
        this.loadFromServer();
    }

    handleOnTerritoryselect(event) {
        try {
            this._currentPage = 1;
            if (this.prevSelection == null || this.prevSelection != event.detail.name.toLowerCase()) {
                this._territoryName = event.detail.name.toLowerCase();
                this.loadFromServer(); 
            }
            this.prevSelection = event.detail.name.toLowerCase();
                       
        } catch (error) {
            console.log(error)
        }
    }

    handleMetricOptionSelect(event) {
        this._currentPage = 1;
        this._specialtyName = null;
        if (event.detail) {
            this._specialtyName = event.detail.replace('_accounts', '');
        }
        if ((this._comparisonOperator && this._specialtyName && this._filterNumber) || !this._specialtyName) {
            this.loadFromServer();
        }        
    }

    handleOperatorOptionSelect(event) {
        this._currentPage = 1;
        this._comparisonOperator = event.detail;
        if ((this._comparisonOperator && this._specialtyName && this._filterNumber) || !this._comparisonOperator) {
            this.loadFromServer();
        }        
    }

    handleAmountChange(event) {
        this._currentPage = 1;
        this._filterNumber = null;
        if (event.detail.value) {
            this._filterNumber = event.detail.value;
        }
        if ((this._comparisonOperator && this._specialtyName && this._filterNumber) || !this._filterNumber) {
            this.loadFromServer();
        }
    }

    handleAccountTypeOptionSelect(event) {
        this._currentPage = 1;        
        let accountType = 'All';
        if (event.detail) {
            accountType = event.detail;
        }
        this._accountType = accountType;
        this.loadFromServer();
    }

    handleExportCSV() {
        this.isExportLoading = true;
        exportReport({ 
            calculationRecordId: this.calculationRecordId,
            countries: this.countries,
            pageNumber: this._currentPage, 
            recordsPerPage: this._recordsPerPage,
            territoryName: this._territoryName,
            specialtyName: this._specialtyName,
            comparisonOperator: this._comparisonOperator,
            filterNumber: this._filterNumber,
            accountType: this._accountType
        }).then(result => {
            
        }).catch(error => {
            
        }).finally(() => {
            this.isExportLoading = false;
            this.dispatchEvent(showToast('You will receive an Email once the report file is created.', 'success'));
        })
    }

    get _currentPageData() {
        if (this.serverResponse.data) {
            let cpd = this.serverResponse.data.currentPageTerritories.map(territory => {
                return this.flatTerritoryRecord(JSON.parse(JSON.stringify(territory)));
            });
            return cpd;
        }
        return [];
    }

    get tableColumns() {        
        if (this.serverResponse.data) {
            let cpd = this.serverResponse.data.currentPageTerritories.map(territory => {
                return this.flatTerritoryRecord(JSON.parse(JSON.stringify(territory)));
            });
            
            let colNames = [... new Set(this.getSpecialtyColumnsWithValues(cpd))].sort();
            return this._columnsBase.concat(colNames.map(columnName => {
                return { label: columnName.replace('_accounts', ''), fieldName: columnName, type: 'number'}
            }));
        }
        return this._columnsBase;
    }

    get totalPages() {
        if (this.serverResponse.data) {
            return Math.ceil(this.serverResponse.data.totalRecords / this._recordsPerPage)
        }
        return 1;
    }

    get currentPageNumber() {
        if (this.serverResponse.data) {
            return this._currentPage;
        }
        return 1;
    }

    get pageNumbers() {        
        if (this.serverResponse.data) {
            let pageNumbers = [];          
            for (let i = 1; i <= this.totalPages; i++) {
                pageNumbers.push(i);
            }
            return pageNumbers;
        }
        return [];
    }

    handlePreviousClick() {
        if (this._currentPage > 1) {
            this._currentPage--;
            this.loadFromServer();
        }
    }
    
    handlePageClick(event) {
        this._currentPage = event.detail;
        this.loadFromServer();
    }

    handleNextClick() {
        if (this._currentPage < this.totalPages) {
            this._currentPage++;
            this.loadFromServer();
        }
    }    
}