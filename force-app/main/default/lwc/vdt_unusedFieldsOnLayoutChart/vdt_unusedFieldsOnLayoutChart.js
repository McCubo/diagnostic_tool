import { LightningElement, api } from 'lwc';

import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import CHARTJS from '@salesforce/resourceUrl/vdt_chartjs';

export default class Vdt_unusedFieldsOnLayoutChart extends LightningElement {
    _calculationData = '';
    _graphData = {
        fieldsOnLayout: {
            value: 0,
            label: '# Unused fields available on layout',
            color: 'rgb(191, 77, 6)'
        },
        fieldsNotOnLayout:  {
            value: 0,
            label: '# Unused fields unavailable on layout',
            color: 'rgb(132, 191, 6)'
        }
    };
    _chartJsInitialized = false;
    _chartName = 'Availability of unused fields (0%) on page layout';
    _selectedCountries = [];
    _chart;

    get _graphValues() {
        return Object.keys(this._graphData).reduce((acc, curr) => {
            acc.push(this._graphData[curr].value);
            return acc;
        }, []);
    }
    get _graphLabels() {
        return Object.keys(this._graphData).reduce((acc, curr) => {
            acc.push(this._graphData[curr].label);
            return acc;
        }, []);
    }
    get _graphColors() {
        return Object.keys(this._graphData).reduce((acc, curr) => {
            acc.push(this._graphData[curr].color);
            return acc;
        }, []);
    }

    @api
    get calculationData() {
        return this._calculationData;
    }
    set calculationData(val) {
        this._calculationData = val;
        this.updateChartData();
    }

    updateChartData() {
        if(this._chart) {
            this.resetGraphData();
            this.populateGraphData();
            this._chart.data.datasets[0].data = this._graphValues;
            this._chart.update();
        }
    }

    resetGraphData() {
        Object.values(this._graphData).forEach(entry => entry.value = 0);
    }

    populateGraphData() {
        Object.values(this._calculationData.fields).forEach(field => {
            let fieldEntry = {
                totalUsage: 0,
                totalRecords: 0,
                totalUsagePercentage: 0
            };
            Object.keys(field.countryUsageSummary).forEach(countryCode => {
                fieldEntry.totalUsage += field.countryUsageSummary[countryCode].usageNumber;
                fieldEntry.totalRecords += field.countryUsageSummary[countryCode].totalRecords;
                fieldEntry.totalUsagePercentage = parseFloat((fieldEntry.totalUsage / fieldEntry.totalRecords).toFixed(2));
            })
            if (fieldEntry.totalUsagePercentage === 0) {
                if (field.pageLayouts && field.pageLayouts.length) {
                    this._graphData.fieldsOnLayout.value++;
                } else if (!field.pageLayouts || !field.pageLayouts.length) {
                    this._graphData.fieldsNotOnLayout.value++;
                }
            }
        })
    }

    initializeGraph() {
        let labels = Object.keys(this._graphData).reduce((acc, curr) => {
            acc.push(this._graphData[curr].label);
            return acc;
        }, []);
        let data = Object.keys(this._graphData).reduce((acc, curr) => {
            acc.push(this._graphData[curr].value);
            return acc;
        }, []);
        let colors = Object.keys(this._graphData).reduce((acc, curr) => {
            acc.push(this._graphData[curr].color);
            return acc;
        }, []);
        let config = {
            type: 'pie',
            data: {
                datasets: [
                {
                    data,
                    backgroundColor: colors,
                    label: this._chartName
                }],
                labels
            },
            options: {
                responsive: true,
                title: {
                    text: this._chartName,
                    position: 'top',
                    fontSize: '14',
                    display: true
                },
                legend: {
                    position: 'bottom'
                }
            }
        };
        const canvas = document.createElement('canvas');
        this.template.querySelector('div.chart').appendChild(canvas);
        const ctx = canvas.getContext('2d');
        this._chart = new Chart(ctx, config);
    }
    
    renderedCallback() {
        if (this._chartJsInitialized) {
            return;
        }
        this._chartJsInitialized = true;
        
        Promise.all([
            loadScript(this, CHARTJS + '/Chart.min.js'),
            loadStyle(this, CHARTJS + '/Chart.min.css')
        ])
        .then(() => {
            window.Chart.platform.disableCSSInjection = true;
            this.populateGraphData();
            this.initializeGraph();
        })
        .catch(error => {
            console.log(error.message);
        });
    }
}