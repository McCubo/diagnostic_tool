import { LightningElement } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import CHARTJS from '@salesforce/resourceUrl/vdt_chartjs';

export default class Vdt_homeGraphs extends LightningElement {
    _chartJsInitialized = false;
    _oneKeyChart;
    _usersChart;
    _productsChart;
    
    initializeOneKeyKPIGraph() {
        let config = {
            type: 'pie',
            data: {
                datasets: [
                {
                    data: [
                        this.randomScalingFactor(),
                        this.randomScalingFactor(),
                        this.randomScalingFactor(),
                        this.randomScalingFactor()
                    ],
                    backgroundColor: [
                        'rgb(255, 204, 0)',
                        'rgb(149, 40, 100)',
                        'rgb(79, 194, 125)',
                        'rgb(95, 202, 223)'
                    ],
                    label: 'Dataset 1'
                }],
                labels: [
                    'Red',
                    'Orange',
                    'Yellow',
                    'Green'
                ]
            },
            options: {
                responsive: true,
                title: {
                    text: 'OneKey Main KPI',
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
        this.template.querySelector('div.main-kpi-onekey').appendChild(canvas);
        const ctx = canvas.getContext('2d');
        this._oneKeyChart = new Chart(ctx, config);
    }
    
    initializeUsersKPIGraph() {
        let config = {
            type: 'pie',
            data: {
                datasets: [
                {
                    data: [
                        this.randomScalingFactor(),
                        this.randomScalingFactor(),
                        this.randomScalingFactor(),
                        this.randomScalingFactor()
                    ],
                    backgroundColor: [
                        'rgb(255, 204, 0)',
                        'rgb(149, 40, 100)',
                        'rgb(79, 194, 125)',
                        'rgb(95, 202, 223)'
                    ],
                    label: 'Dataset 1'
                }],
                labels: [
                    'Red',
                    'Orange',
                    'Yellow',
                    'Green'
                ]
            },
            options: {
                responsive: true,
                title: {
                    text: 'Veeva Users Main KPI',
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
        this.template.querySelector('div.main-kpi-users').appendChild(canvas);
        const ctx = canvas.getContext('2d');
        this._usersChart = new Chart(ctx, config);
    }
    
    initializeProductsKPIGraph() {
        let config = {
            type: 'bar',
            data: {
                datasets: [
                {
                    data: [
                        this.randomScalingFactor(),
                        this.randomScalingFactor(),
                        this.randomScalingFactor(),
                        this.randomScalingFactor(),
                        this.randomScalingFactor(),
                        this.randomScalingFactor(),
                        this.randomScalingFactor()
                    ],
                    backgroundColor: [
                        'rgb(255, 204, 0)',
                        'rgb(149, 40, 100)',
                        'rgb(79, 194, 125)',
                        'rgb(95, 202, 223)',
                        'rgb(255, 204, 0)',
                        'rgb(149, 40, 100)',
                        'rgb(79, 194, 125)'
                    ],
                    label: 'Dataset 1'
                }],
                labels: ['January', 'February', 'March', 'April', 'May', 'June', 'July']
            },
            options: {
                responsive: true,
                title: {
                    text: 'Products Main KPI',
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
        this.template.querySelector('div.main-kpi-products').appendChild(canvas);
        const ctx = canvas.getContext('2d');
        this._productsChart = new Chart(ctx, config);
    }
    
    randomScalingFactor() {
        return Math.round(Math.random() * 100);
    };
    
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
            
            this.initializeOneKeyKPIGraph();
            this.initializeProductsKPIGraph();
        })
        .catch(error => {
            console.log(error.message);
        });
    }
}