import { LightningElement, track } from 'lwc';

export default class Vdt_onekeyAnalysisSummary extends LightningElement {
    columns = [
        { label: 'Dimension', fieldName: 'name', type: 'text', wrapText: true,  cellAttributes: { class: 'slds-text-heading_medium' }},
        { label: 'KPI Status', fieldName: 'id', type: 'vdt_progressBar', typeAttributes: {
                actualValue: { fieldName: 'actualValue' },
                targetValue: { fieldName: 'targetValue' }
            }
        }
    ];

    @track
    data = [
        { id: 1, name: 'Percentage of Onekey/External Data Provider Vs Non One Key Customers', actualValue: 100, targetValue: 100},
        { id: 2, name: 'Percentage of Onekey/External Data Provider aligned to the territories', actualValue: 75, targetValue: 100},
        { id: 3, name: 'Percentage of Onekey/External Data Provider Without visit', actualValue: 30, targetValue: 50},
        { id: 4, name: 'Percentage of Onekey/External Data Provider Without ratings', actualValue: 80, targetValue: 120},
        { id: 5, name: 'Percentage of Onekey/External Data Provider Without cycle plan targets', actualValue: 50, targetValue: 50},
        { id: 6, name: 'Percentage of OneKey/Extrennal Data provider customers Without Visit and cyle plan targets', actualValue: 69, targetValue: 100},
        { id: 7, name: 'Percentage of One key/External Data provider Customers with no Address', actualValue: 79, targetValue: 95}
    ];
}