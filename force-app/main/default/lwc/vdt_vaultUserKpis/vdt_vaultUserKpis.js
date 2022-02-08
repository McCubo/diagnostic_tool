import { LightningElement } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import CHARTJS from '@salesforce/resourceUrl/vdt_chartjs';

export default class Vdt_vaultUserKpis extends LightningElement {

    chartJsInitialized = false;

    renderedCallback() {
        if (this.chartJsInitialized) {
            return;
        }
        this.chartJsInitialized = true;

        Promise.all([
            loadScript(this, CHARTJS + '/latest_chart.min.js')
        ]).then(() => {
            // we need to enable Setup > Security > Session Settings > Use Lightning Web Security (beta) for Lightning web components.
            this.chartActiveUsersBySecurityProfileAndLicense();
            this.pieActiveUsersBySecurityProfile();
        }).catch(error => {
            console.log(error);
        });
    }

    chartActiveUsersBySecurityProfileAndLicense() {
        const config = {
            type: 'bar',
            data: {
                labels: ['bbb PromoMats User', 'bbb External PromoMats User', 'bbb PromoMats and Portal User', 'bbb System Administrator', 'Vault Owner', 'bbb Business Administrator User'],
                datasets: [
                    {
                        label: 'Full User',
                        data: [100, 10, 11, 25, 1, 2],
                        backgroundColor: 'rgb(3, 119, 252)',
                    },
                    {
                        label: 'Read Only User',
                        data: [20, 1, 1, 1, 1, 1],
                        backgroundColor: 'rgb(252, 132, 3)',
                    },
                    {
                        label: 'External User',
                        data: [30, 0, 3, 4, 5, 6],
                        backgroundColor: 'rgb(252, 194, 3)',
                    },
                ]
            },
            options: {
                plugins: {
                    title: {
                        display: true,
                        text: 'Active Users by Security Profile and License Type'
                    },
                },
                responsive: false,
                scales: {
                    x: {
                        stacked: true,
                    },
                    y: {
                        stacked: true
                    }
                }
            }
        };
        const ctx = this.template.querySelector('canvas.barChart').getContext('2d');
        new Chart(ctx, config);
    }

    pieActiveUsersBySecurityProfile() {
        const ctx = this.template.querySelector('canvas.pieChart').getContext('2d');
        const config = {
            type: 'pie',
            data: {
                labels: ['bbb PromoMats User', 'bbb External PromoMats User', 'bbb PromoMats and Portal User', 'bbb System Administrator', 'Vault Owner', 'bbb Business Administrator User'],
                datasets: [
                    {
                        label: 'Dataset 1',
                        data: [10, 33, 45, 5, 55, 30 ],
                        backgroundColor: ['rgb(255, 99, 132)', 'rgb(255, 159, 64)', 'rgb(255, 205, 86)', 'rgb(75, 192, 192)', 'rgb(54, 162, 235)', 'rgb(153, 102, 255)'],
                    }
                ]
            },
            options: {
                responsive: false,
                plugins: {
                    legend: {
                        position: 'top',
                    },
                    title: {
                        display: true,
                        text: 'Active Users by Security Profile'
                    }
                }
            },
        };
        new Chart(ctx, config); 
    }
}