import { LightningElement, track } from 'lwc';
import { downloadCSVFile } from 'c/vdt_csvUtil'

export default class Vdt_onekeyAnalysisSummary extends LightningElement {
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

    @track
    data = [
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

    handleExportCSV() {
        let headers = {
            name: 'Dimension',
            actualValue: 'Actual Value(%)', 
            targetValue: 'Target Value(%)',
        };
        downloadCSVFile(headers, this.data, 'account_onekey_summary');
    }
}