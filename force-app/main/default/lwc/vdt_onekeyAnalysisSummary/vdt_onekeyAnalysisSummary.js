import { LightningElement, wire, api } from 'lwc';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
import {loadStyle} from 'lightning/platformResourceLoader'
import COLOR_TABLE from '@salesforce/resourceUrl/vdt_onekey_summary_table'

import onekeyCountryChannel from '@salesforce/messageChannel/vdt_onekeyCountryChannel__c';
import { downloadCSVFile } from 'c/vdt_csvUtil'

const COLUMNS = [
        { label: 'Dimension', fieldName: 'id', wrapText: true, type: 'vdt_enrichedText', typeAttributes: {
            textValue: { fieldName: 'name' },
            helpMessage: { fieldName: 'help' },
            formulaMessage: { fieldName: 'formula' }
        }},
        { label: 'Status', fieldName: 'id', type: 'vdt_progressBar', typeAttributes: {
                actualValue: { fieldName: 'actualValue' },
                targetValue: { fieldName: 'targetValue' },
                type: { fieldName: 'kpiType'}
            }
        }
    ];
export default class Vdt_onekeyAnalysisSummary extends LightningElement {

    isRendered = false;

    @api
    countries = [];
    columns = COLUMNS;

    _rawData = [];
    _calculationData = [];
    
    @api
    get calculationData() {
        return this._calculationData;
    }
    set calculationData(val) {
        let data = JSON.parse(val);
        this._rawData = val;
        this._calculationData = this.parseData(data);
    }

    parseData(data) {
        let parsedData = [];
        Object.values(data.kpi_numbers).forEach(kpi => {
            let kpiEntry = {
                id: kpi.id,
                name: kpi.name,
                help: kpi.help,
                formula: kpi.formula,
                kpiType: kpi.type,
                actualValue: 0,
                targetValue: kpi.default_target,
                totalNumerator: 0,
                totalDenominator: 0
            };
            Object.keys(kpi.countryUsageSummary).forEach(countryCode => {
                if (this.countries.includes(countryCode) || this.countries.includes('All')) {
                    kpiEntry.totalNumerator += kpi.countryUsageSummary[countryCode].numerator;
                    kpiEntry.totalDenominator += kpi.countryUsageSummary[countryCode].denominator;
                }
                if (this.countries && this.countries.length == 1 && this.countries.includes(countryCode) && this.countries[0] != 'All') {
                    kpiEntry.targetValue = kpi.countryUsageSummary[countryCode].target;
                }
            });
            parsedData.push(kpiEntry);
        });
        parsedData.forEach(kpiEntry => {
            kpiEntry.actualValue = Math.round((kpiEntry.totalNumerator / kpiEntry.totalDenominator) * 100);
            if (Number.isNaN(kpiEntry.actualValue)) {
                kpiEntry.actualValue = 'N/A'
            }
        });
        return parsedData;
    }
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
            this._calculationData = this.parseData(JSON.parse(this._rawData));
        }
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this._subscription);
        this._subscription = null;
    }

    handleExportCSV() {
        let headers = {
            name: 'Dimension',
            actualValue: 'Actual Value(%)', 
            targetValue: 'Target Value(%)',
        };
        downloadCSVFile(headers, this._calculationData, 'account_onekey_summary');
    }

    renderedCallback(){ 
        if(this.isRendered) {
            return;
        }
        this.isRendered = true
        loadStyle(this, COLOR_TABLE).then(()=>{}).catch(error=>{ 
            console.error("Rendered Callback Error: %O", error)
        })
    }

}