import { LightningElement, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import CHARTJS from '@salesforce/resourceUrl/vdt_chartjs';


import { subscribeToMessageChannel, unsubscribeToMessageChannel } from 'c/vdt_utils';
import { MessageContext } from 'lightning/messageService';
import productFilterMessageChannel from '@salesforce/messageChannel/vdt_productFilter__c';
import hcpFilterMessageChannel from '@salesforce/messageChannel/vdt_hcpFilter__c';
import hcoFilterMessageChannel from '@salesforce/messageChannel/vdt_hcoFilter__c';

export default class Vdt_onekeyGraphs extends LightningElement {
    _chartJsInitialized = false;
    _subscription = null;
    _chart1 = null;
    _chart2 = null;
    _chart3 = null;
    _xKpiValue;
    _yKpiValue;
    _zKpiValue;

    @wire(MessageContext)
    _messageContext;

    handleProductFilterChange(message) {
        if (message.filter) {
            alert('product filter :: ' + JSON.stringify(message.filter));
            this._chart1.data.datasets[0].data = [
                this.randomScalingFactor(),
                this.randomScalingFactor(),
                this.randomScalingFactor(),
                this.randomScalingFactor()
            ];
            this._chart2.data.datasets[0].data = [
                this.randomScalingFactor(),
                this.randomScalingFactor(),
                this.randomScalingFactor(),
                this.randomScalingFactor()
            ];
            this._chart3.data.datasets[0].data = [
                this.randomScalingFactor(),
                this.randomScalingFactor(),
                this.randomScalingFactor(),
                this.randomScalingFactor()
            ];
            this._chart1.update();
            this._chart2.update();
            this._chart3.update();
            this.initializeKpiValues();
        }
    }

    handleHcoFilterChange(message) {
        if (message.filter) {
            alert('HCO filter :: ' + JSON.stringify(message.filter));
            this._chart1.data.datasets[0].data = [
                this.randomScalingFactor(),
                this.randomScalingFactor(),
                this.randomScalingFactor(),
                this.randomScalingFactor()
            ];
            this._chart2.data.datasets[0].data = [
                this.randomScalingFactor(),
                this.randomScalingFactor(),
                this.randomScalingFactor(),
                this.randomScalingFactor()
            ];
            this._chart3.data.datasets[0].data = [
                this.randomScalingFactor(),
                this.randomScalingFactor(),
                this.randomScalingFactor(),
                this.randomScalingFactor()
            ];
            this._chart1.update();
            this._chart2.update();
            this._chart3.update();
            this.initializeKpiValues();
        }
    }

    handleHcpFilterChange(message) {
        if (message.filter) {
            alert('HCP filter :: ' + JSON.stringify(message.filter));
            this._chart1.data.datasets[0].data = [
                this.randomScalingFactor(),
                this.randomScalingFactor(),
                this.randomScalingFactor(),
                this.randomScalingFactor()
            ];
            this._chart2.data.datasets[0].data = [
                this.randomScalingFactor(),
                this.randomScalingFactor(),
                this.randomScalingFactor(),
                this.randomScalingFactor()
            ];
            this._chart3.data.datasets[0].data = [
                this.randomScalingFactor(),
                this.randomScalingFactor(),
                this.randomScalingFactor(),
                this.randomScalingFactor()
            ];
            this._chart1.update();
            this._chart2.update();
            this._chart3.update();
            this.initializeKpiValues();
        }
    }

    initializeGraph1() {
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
                    text: 'KPI 1',
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
        this.template.querySelector('div.kpi-1').appendChild(canvas);
        const ctx = canvas.getContext('2d');
        this._chart1 = new Chart(ctx, config);
    }

    
    initializeGraph2() {
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
                    text: 'KPI 2',
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
        this.template.querySelector('div.kpi-2').appendChild(canvas);
        const ctx = canvas.getContext('2d');
        this._chart2 = new Chart(ctx, config);
    }

    initializeGraph3() {
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
                    text: 'KPI 3',
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
        this.template.querySelector('div.kpi-3').appendChild(canvas);
        const ctx = canvas.getContext('2d');
        this._chart3 = new Chart(ctx, config);
    }

    initializeKpiValues() {
        this._xKpiValue = Math.round(Math.random() * 100);
        this._yKpiValue = Math.round(Math.random() * 100);
        this._zKpiValue = Math.round(Math.random() * 10);
    }
    
    randomScalingFactor() {
        return Math.round(Math.random() * 100);
    };
    
    connectedCallback() {
        this._productFilterSubscription = subscribeToMessageChannel(
            this._productFilterSubscription,
            productFilterMessageChannel,
            this.handleProductFilterChange.bind(this),
            this._messageContext
        );
        this._hcpFilterSubscription = subscribeToMessageChannel(
            this._hcpFilterSubscription,
            hcpFilterMessageChannel,
            this.handleHcpFilterChange.bind(this),
            this._messageContext
        );
        this._hcoFilterSubscription = subscribeToMessageChannel(
            this._hcoFilterSubscription,
            hcoFilterMessageChannel,
            this.handleHcoFilterChange.bind(this),
            this._messageContext
        );
        this.initializeKpiValues();
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
            
            this.initializeGraph1();
            this.initializeGraph2();
            this.initializeGraph3();
        })
        .catch(error => {
            console.log(error.message);
        });
    }

    disconnectedCallback() {
        this._productFilterSubscription = unsubscribeToMessageChannel(this._productFilterSubscription);
        this._hcpFilterSubscription = unsubscribeToMessageChannel(this._hcpFilterSubscription);
        this._hcoFilterSubscription = unsubscribeToMessageChannel(this._hcoFilterSubscription);
    }
}