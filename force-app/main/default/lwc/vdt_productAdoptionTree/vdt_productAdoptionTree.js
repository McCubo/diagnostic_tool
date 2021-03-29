import { LightningElement } from 'lwc';
import getProductCatalogTree from '@salesforce/apex/VDT_ProductAdoptionController.getProductCatalogTree';
export default class Vdt_productAdoptionTree extends LightningElement {

    _productTypes= [
        {label: 'Detail', value: 'Detail', selected: false},
        {label: 'High Value Promotional', value: 'High Value Promotional', selected: false},
        {label: 'Promotional', value: 'Promotional', selected: false},
        {label: 'Sample', value: 'Sample', selected: false},
        {label: 'Detail Topic', value: 'Detail Topic', selected: false},
        {label: 'Market', value: 'Market', selected: false}
    ];

    treeData = [];
    
    connectedCallback() {
        console.log('connectedCallback')
        getProductCatalogTree()
        .then(response => {
            console.log('response: %O', JSON.stringify(response));
            this.treeData = response;
        }).catch(error => {
            console.log('error on promise: %O', JSON.stringify(error));
        }).finally();
    }
}