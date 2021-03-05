import { LightningElement, api } from 'lwc';

import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import CHARTJS from '@salesforce/resourceUrl/vdt_chartjs';

export default class Vdt_objectsFieldsUsageChart extends LightningElement {
    _calculationData = '';
    _graphData = {
        fieldsWith0: {
            value: 0,
            label: '0%',
            color: 'rgb(252, 186, 3)'
        },
        fieldsWith0To25:  {
            value: 0,
            label: '0-25%',
            color: 'rgb(136, 201, 4)'
        },
        fieldsWith25To50:  {
            value: 0,
            label: '25-50%',
            color: 'rgb(6, 149, 196)'
        },
        fieldsWith50To75:  {
            value: 0,
            label: '50-75%',
            color: 'rgb(133, 6, 191)'
        },
        fieldsWith75To100:  {
            value: 0,
            label: '75-100%',
            color: 'rgb(191, 46, 6)'
        }
    };
    _chartJsInitialized = false;
    _chartName = 'Fields Usage Breakdown'
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
        if (this._chart) {
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
                this._graphData.fieldsWith0.value++;
            } else if (fieldEntry.totalUsagePercentage > 0 && fieldEntry.totalUsagePercentage <= 25) {
                this._graphData.fieldsWith0To25.value++;
            } else if (fieldEntry.totalUsagePercentage > 25 && fieldEntry.totalUsagePercentage <= 50) {
                this._graphData.fieldsWith25To50.value++;
            } else if (fieldEntry.totalUsagePercentage > 50 && fieldEntry.totalUsagePercentage <= 75) {
                this._graphData.fieldsWith50To75.value++;
            } else if (fieldEntry.totalUsagePercentage > 75 && fieldEntry.totalUsagePercentage <= 100) {
                this._graphData.fieldsWith75To100.value++;
            }
        })
    }

    initializeGraph() {
        let config = {
            type: 'bar',
            data: {
                datasets: [
                {
                    data: this._graphValues,
                    backgroundColor: this._graphColors,
                    label: this._chartName
                }],
                labels: this._graphLabels
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