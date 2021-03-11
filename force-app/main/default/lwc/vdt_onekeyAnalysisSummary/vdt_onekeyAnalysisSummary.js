import { LightningElement, wire } from 'lwc';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
import {loadStyle} from 'lightning/platformResourceLoader'
import COLOR_TABLE from '@salesforce/resourceUrl/vdt_onekey_summary_table'

import onekeyCountryChannel from '@salesforce/messageChannel/vdt_onekeyCountryChannel__c';
import { downloadCSVFile } from 'c/vdt_csvUtil'

const SUMMARY_DATA = [
    { 
        id: 1, 
        name: 'Percentage of Onekey/External Data Provider Vs Non One Key Customers', 
        actualValue: 80, 
        targetValue: 95,
        help: 'Measuring the percentage of the customer universe which is covered by Subscription',
        formula: 'Total Number of One key customers/Total number of accoounts in CRM',
        kpiType: 'higher'
    },
    { 
        id: 2, 
        name: 'Percentage of Onekey/External Data Provider aligned to the territories', 
        actualValue: 75, 
        targetValue: 100,
        help: 'Measuring the percentage of the customers paid that are assinged to the territories ',
        formula: 'Total Number of One key customers assinged to a territory/Total number of one Key customers in CRM',
        kpiType: 'higher'
    },
    { 
        id: 3, 
        name: 'Percentage of Onekey/External Data Provider Without visit', 
        actualValue: 15, 
        targetValue: 10,
        help: 'Measuring whether the subscription is too broad and providing more accounts than required',
        formula: 'Total Number of one Key customers without any activities/Total One Key Customers',
        kpiType: 'lower'
    },
    { 
        id: 4, 
        name: 'Percentage of Onekey/External Data Provider Without ratings', 
        actualValue: 4, 
        targetValue: 5,
        help: 'Measuring the share of the customers which are not segmented by Commerical teams',
        formula: 'Total Number of One Key customers without any rating information/Total number of one key customers',
        kpiType: 'lower'
    },
    { 
        id: 5, 
        name: 'Percentage of Onekey/External Data Provider Without cycle plan targets', 
        actualValue: 17, 
        targetValue: 20,
        help: 'Measuring the share of the customers which are not targeted to visit and not part of cycle plans',
        formula: 'Total Number of One Key Customers without any targets on call plan/Total Number of One Key customers',
        kpiType: 'lower'
    },
    { 
        id: 6, 
        name: 'Percentage of OneKey/Extrennal Data provider customers Without Visit and cyle plan targets', 
        actualValue: 10, 
        targetValue: 15,
        help: 'Measuring the share of the customers which are not Visited and not part of any target',
        formula: 'Total Number of One Key Customers which are neither Visited and Targted/Total Number of One Key customers',
        kpiType: 'lower'
    },
    { 
        id: 7, 
        name: 'Percentage of One key/External Data provider Customers with no Address', 
        actualValue: 2, 
        targetValue: 0,
        help: 'Measuring the share of customers where the address informtion is missing and impacting reps daily life',
        formula: 'Total Number of One Key Customers which don\'t have address/Total Number of One Key customers',
        kpiType: 'lower'
    }
];
const SUMMARY_DATA_PL = [
    { 
        id: 1, 
        name: 'Percentage of Onekey/External Data Provider Vs Non One Key Customers', 
        actualValue: 97, 
        targetValue: 95,
        help: 'Measuring the percentage of the customer universe which is covered by Subscription',
        formula: 'Total Number of One key customers/Total number of accoounts in CRM',
        kpiType: 'higher'
    },
    { 
        id: 2, 
        name: 'Percentage of Onekey/External Data Provider aligned to the territories', 
        actualValue: 100, 
        targetValue: 100,
        help: 'Measuring the percentage of the customers paid that are assinged to the territories ',
        formula: 'Total Number of One key customers assinged to a territory/Total number of one Key customers in CRM',
        kpiType: 'higher'
    },
    { 
        id: 3, 
        name: 'Percentage of Onekey/External Data Provider Without visit', 
        actualValue: 9, 
        targetValue: 10,
        help: 'Measuring whether the subscription is too broad and providing more accounts than required',
        formula: 'Total Number of one Key customers without any activities/Total One Key Customers',
        kpiType: 'lower'
    },
    { 
        id: 4, 
        name: 'Percentage of Onekey/External Data Provider Without ratings', 
        actualValue: 7, 
        targetValue: 5,
        help: 'Measuring the share of the customers which are not segmented by Commerical teams',
        formula: 'Total Number of One Key customers without any rating information/Total number of one key customers',
        kpiType: 'lower'
    },
    { 
        id: 5, 
        name: 'Percentage of Onekey/External Data Provider Without cycle plan targets', 
        actualValue: 3, 
        targetValue: 20,
        help: 'Measuring the share of the customers which are not targeted to visit and not part of cycle plans',
        formula: 'Total Number of One Key Customers without any targets on call plan/Total Number of One Key customers',
        kpiType: 'lower'
    },
    { 
        id: 6, 
        name: 'Percentage of OneKey/Extrennal Data provider customers Without Visit and cyle plan targets', 
        actualValue: 15, 
        targetValue: 15,
        help: 'Measuring the share of the customers which are not Visited and not part of any target',
        formula: 'Total Number of One Key Customers which are neither Visited and Targted/Total Number of One Key customers',
        kpiType: 'lower'
    },
    { 
        id: 7, 
        name: 'Percentage of One key/External Data provider Customers with no Address', 
        actualValue: 0, 
        targetValue: 0,
        help: 'Measuring the share of customers where the address informtion is missing and impacting reps daily life',
        formula: 'Total Number of One Key Customers which don\'t have address/Total Number of One Key customers',
        kpiType: 'lower'
    }
];
const SUMMARY_DATA_IE = [
    { 
        id: 1, 
        name: 'Percentage of Onekey/External Data Provider Vs Non One Key Customers', 
        actualValue: 15, 
        targetValue: 95,
        help: 'Measuring the percentage of the customer universe which is covered by Subscription',
        formula: 'Total Number of One key customers/Total number of accoounts in CRM',
        kpiType: 'higher'
    },
    { 
        id: 2, 
        name: 'Percentage of Onekey/External Data Provider aligned to the territories', 
        actualValue: 30, 
        targetValue: 100,
        help: 'Measuring the percentage of the customers paid that are assinged to the territories ',
        formula: 'Total Number of One key customers assinged to a territory/Total number of one Key customers in CRM',
        kpiType: 'higher'
    },
    { 
        id: 3, 
        name: 'Percentage of Onekey/External Data Provider Without visit', 
        actualValue: 25, 
        targetValue: 10,
        help: 'Measuring whether the subscription is too broad and providing more accounts than required',
        formula: 'Total Number of one Key customers without any activities/Total One Key Customers',
        kpiType: 'lower'
    },
    { 
        id: 4, 
        name: 'Percentage of Onekey/External Data Provider Without ratings', 
        actualValue: 85, 
        targetValue: 5,
        help: 'Measuring the share of the customers which are not segmented by Commerical teams',
        formula: 'Total Number of One Key customers without any rating information/Total number of one key customers',
        kpiType: 'lower'
    },
    { 
        id: 5, 
        name: 'Percentage of Onekey/External Data Provider Without cycle plan targets', 
        actualValue: 20, 
        targetValue: 20,
        help: 'Measuring the share of the customers which are not targeted to visit and not part of cycle plans',
        formula: 'Total Number of One Key Customers without any targets on call plan/Total Number of One Key customers',
        kpiType: 'lower'
    },
    { 
        id: 6, 
        name: 'Percentage of OneKey/Extrennal Data provider customers Without Visit and cyle plan targets', 
        actualValue: 90, 
        targetValue: 15,
        help: 'Measuring the share of the customers which are not Visited and not part of any target',
        formula: 'Total Number of One Key Customers which are neither Visited and Targted/Total Number of One Key customers',
        kpiType: 'lower'
    },
    { 
        id: 7, 
        name: 'Percentage of One key/External Data provider Customers with no Address', 
        actualValue: 15, 
        targetValue: 0,
        help: 'Measuring the share of customers where the address informtion is missing and impacting reps daily life',
        formula: 'Total Number of One Key Customers which don\'t have address/Total Number of One Key customers',
        kpiType: 'lower'
    }
];
const SUMMARY_DATA_GB = [
    { 
        id: 1, 
        name: 'Percentage of Onekey/External Data Provider Vs Non One Key Customers', 
        actualValue: 95, 
        targetValue: 95,
        help: 'Measuring the percentage of the customer universe which is covered by Subscription',
        formula: 'Total Number of One key customers/Total number of accoounts in CRM',
        kpiType: 'higher'
    },
    { 
        id: 2, 
        name: 'Percentage of Onekey/External Data Provider aligned to the territories', 
        actualValue: 100, 
        targetValue: 100,
        help: 'Measuring the percentage of the customers paid that are assinged to the territories ',
        formula: 'Total Number of One key customers assinged to a territory/Total number of one Key customers in CRM',
        kpiType: 'higher'
    },
    { 
        id: 3, 
        name: 'Percentage of Onekey/External Data Provider Without visit', 
        actualValue: 10, 
        targetValue: 10,
        help: 'Measuring whether the subscription is too broad and providing more accounts than required',
        formula: 'Total Number of one Key customers without any activities/Total One Key Customers',
        kpiType: 'lower'
    },
    { 
        id: 4, 
        name: 'Percentage of Onekey/External Data Provider Without ratings', 
        actualValue: 5, 
        targetValue: 5,
        help: 'Measuring the share of the customers which are not segmented by Commerical teams',
        formula: 'Total Number of One Key customers without any rating information/Total number of one key customers',
        kpiType: 'lower'
    },
    { 
        id: 5, 
        name: 'Percentage of Onekey/External Data Provider Without cycle plan targets', 
        actualValue: 20, 
        targetValue: 20,
        help: 'Measuring the share of the customers which are not targeted to visit and not part of cycle plans',
        formula: 'Total Number of One Key Customers without any targets on call plan/Total Number of One Key customers',
        kpiType: 'lower'
    },
    { 
        id: 6, 
        name: 'Percentage of OneKey/Extrennal Data provider customers Without Visit and cyle plan targets', 
        actualValue: 15, 
        targetValue: 15,
        help: 'Measuring the share of the customers which are not Visited and not part of any target',
        formula: 'Total Number of One Key Customers which are neither Visited and Targted/Total Number of One Key customers',
        kpiType: 'lower'
    },
    { 
        id: 7, 
        name: 'Percentage of One key/External Data provider Customers with no Address', 
        actualValue: 1, 
        targetValue: 0,
        help: 'Measuring the share of customers where the address informtion is missing and impacting reps daily life',
        formula: 'Total Number of One Key Customers which don\'t have address/Total Number of One Key customers',
        kpiType: 'lower'
    }
];
const SUMMARY_DATA_IT = [
    { 
        id: 1, 
        name: 'Percentage of Onekey/External Data Provider Vs Non One Key Customers', 
        actualValue: 1, 
        targetValue: 95,
        help: 'Measuring the percentage of the customer universe which is covered by Subscription',
        formula: 'Total Number of One key customers/Total number of accoounts in CRM',
        kpiType: 'higher'
    },
    { 
        id: 2, 
        name: 'Percentage of Onekey/External Data Provider aligned to the territories', 
        actualValue: 1, 
        targetValue: 100,
        help: 'Measuring the percentage of the customers paid that are assinged to the territories ',
        formula: 'Total Number of One key customers assinged to a territory/Total number of one Key customers in CRM',
        kpiType: 'higher'
    },
    { 
        id: 3, 
        name: 'Percentage of Onekey/External Data Provider Without visit', 
        actualValue: 90, 
        targetValue: 10,
        help: 'Measuring whether the subscription is too broad and providing more accounts than required',
        formula: 'Total Number of one Key customers without any activities/Total One Key Customers',
        kpiType: 'lower'
    },
    { 
        id: 4, 
        name: 'Percentage of Onekey/External Data Provider Without ratings', 
        actualValue: 90, 
        targetValue: 5,
        help: 'Measuring the share of the customers which are not segmented by Commerical teams',
        formula: 'Total Number of One Key customers without any rating information/Total number of one key customers',
        kpiType: 'lower'
    },
    { 
        id: 5, 
        name: 'Percentage of Onekey/External Data Provider Without cycle plan targets', 
        actualValue: 90, 
        targetValue: 20,
        help: 'Measuring the share of the customers which are not targeted to visit and not part of cycle plans',
        formula: 'Total Number of One Key Customers without any targets on call plan/Total Number of One Key customers',
        kpiType: 'lower'
    },
    { 
        id: 6, 
        name: 'Percentage of OneKey/Extrennal Data provider customers Without Visit and cyle plan targets', 
        actualValue: 90, 
        targetValue: 15,
        help: 'Measuring the share of the customers which are not Visited and not part of any target',
        formula: 'Total Number of One Key Customers which are neither Visited and Targted/Total Number of One Key customers',
        kpiType: 'lower'
    },
    { 
        id: 7, 
        name: 'Percentage of One key/External Data provider Customers with no Address', 
        actualValue: 90, 
        targetValue: 0,
        help: 'Measuring the share of customers where the address informtion is missing and impacting reps daily life',
        formula: 'Total Number of One Key Customers which don\'t have address/Total Number of One Key customers',
        kpiType: 'lower'
    }
];
const SUMMARY_DATA_FR = [
    { 
        id: 1, 
        name: 'Percentage of Onekey/External Data Provider Vs Non One Key Customers', 
        actualValue: 100, 
        targetValue: 95,
        help: 'Measuring the percentage of the customer universe which is covered by Subscription',
        formula: 'Total Number of One key customers/Total number of accoounts in CRM',
        kpiType: 'higher'
    },
    { 
        id: 2, 
        name: 'Percentage of Onekey/External Data Provider aligned to the territories', 
        actualValue: 100, 
        targetValue: 100,
        help: 'Measuring the percentage of the customers paid that are assinged to the territories ',
        formula: 'Total Number of One key customers assinged to a territory/Total number of one Key customers in CRM',
        kpiType: 'higher'
    },
    { 
        id: 3, 
        name: 'Percentage of Onekey/External Data Provider Without visit', 
        actualValue: 1, 
        targetValue: 10,
        help: 'Measuring whether the subscription is too broad and providing more accounts than required',
        formula: 'Total Number of one Key customers without any activities/Total One Key Customers',
        kpiType: 'lower'
    },
    { 
        id: 4, 
        name: 'Percentage of Onekey/External Data Provider Without ratings', 
        actualValue: 1, 
        targetValue: 5,
        help: 'Measuring the share of the customers which are not segmented by Commerical teams',
        formula: 'Total Number of One Key customers without any rating information/Total number of one key customers',
        kpiType: 'lower'
    },
    { 
        id: 5, 
        name: 'Percentage of Onekey/External Data Provider Without cycle plan targets', 
        actualValue: 1, 
        targetValue: 20,
        help: 'Measuring the share of the customers which are not targeted to visit and not part of cycle plans',
        formula: 'Total Number of One Key Customers without any targets on call plan/Total Number of One Key customers',
        kpiType: 'lower'
    },
    { 
        id: 6, 
        name: 'Percentage of OneKey/Extrennal Data provider customers Without Visit and cyle plan targets', 
        actualValue: 1, 
        targetValue: 15,
        help: 'Measuring the share of the customers which are not Visited and not part of any target',
        formula: 'Total Number of One Key Customers which are neither Visited and Targted/Total Number of One Key customers',
        kpiType: 'lower'
    },
    { 
        id: 7, 
        name: 'Percentage of One key/External Data provider Customers with no Address', 
        actualValue: 0, 
        targetValue: 0,
        help: 'Measuring the share of customers where the address informtion is missing and impacting reps daily life',
        formula: 'Total Number of One Key Customers which don\'t have address/Total Number of One Key customers',
        kpiType: 'lower'
    }
];
export default class Vdt_onekeyAnalysisSummary extends LightningElement {

    isRendered = false;

    _countries;
    columns = [
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
    
    data = SUMMARY_DATA;

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
            this._countries = message.countries;
            if (this._countries == 'PL') {
                this.data = SUMMARY_DATA_PL;
            } else if (this._countries == 'IE') {
                this.data = SUMMARY_DATA_IE;
            } else if (this._countries == 'GB') {
                this.data = SUMMARY_DATA_GB;
            } else if (this._countries == 'IT') {
                this.data = SUMMARY_DATA_IT;
            } else if (this._countries == 'FR') {
                this.data = SUMMARY_DATA_FR;
            } else if (this._countries == 'All') {
                this.data = SUMMARY_DATA;
            }
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
        downloadCSVFile(headers, this.data, 'account_onekey_summary');
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