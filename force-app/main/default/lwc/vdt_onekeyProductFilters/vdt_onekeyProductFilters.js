import { LightningElement, wire } from 'lwc';
import productFilterMessageChannel from '@salesforce/messageChannel/vdt_productFilter__c';
import { publish, MessageContext } from 'lightning/messageService';

export default class Vdt_onekeyHcpFilters extends LightningElement {
    _salesTeamOptions = [
        { label: 'Sales Team 1', value: 'sales_team_1' },
        { label: 'Sales Team 2', value: 'sales_team_2' },
        { label: 'Sales Team 3', value: 'sales_team_3' },
    ];
    _productOptions = [
        { label: 'Product 1', value: 'product_1' },
        { label: 'Product 2', value: 'product_2' },
        { label: 'Product 3', value: 'product_3' },
    ];
    _callTypeOptions = [
        { label: 'Call Type 1', value: 'call_type_1' },
        { label: 'Call Type 2', value: 'call_type_2' },
        { label: 'Call Type 3', value: 'call_type_3' },
    ];

    @wire(MessageContext)
    _messageContext;

    _selectedSalesTeam = '';
    _selectedProduct = '';
    _selectedCallType = '';

    handleSalesTeamChange(evt) {
        this._selectedSalesTeam = evt.detail.value;
        this.publishFilterChange();
    }

    handleProductChange(evt) {
        this._selectedProduct = evt.detail.value;
        this.publishFilterChange();
    }

    handleCallTypeChange(evt) {
        this._selectedCallType = evt.detail.value;
        this.publishFilterChange();
    }

    publishFilterChange() {
        publish(this._messageContext, productFilterMessageChannel, {filter: {
            salesTeam: this._selectedSalesTeam,
            product: this._selectedProduct,
            callType: this._selectedCallType
        }});
    }
}