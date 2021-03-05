import { LightningElement, wire } from 'lwc';
import hcpFilterMessageChannel from '@salesforce/messageChannel/vdt_hcpFilter__c';
import { publish, MessageContext } from 'lightning/messageService';

export default class Vdt_onekeyHcpFilters extends LightningElement {
    _hcpSpecialityOptions = [
        { label: 'HCP Speciality 1', value: 'hcp_speciality_1' },
        { label: 'HCP Speciality 2', value: 'hcp_speciality_2' },
        { label: 'HCP Speciality 3', value: 'hcp_speciality_3' },
    ];
    _hcpTypeOptions = [
        { label: 'HCP Type 1', value: 'hcp_type_1' },
        { label: 'HCP Type 2', value: 'hcp_type_2' },
        { label: 'HCP Type 3', value: 'hcp_type_3' },
    ];
    _hcpCityOptions = [
        { label: 'HCP City 1', value: 'hcp_city_1' },
        { label: 'HCP City 2', value: 'hcp_city_2' },
        { label: 'HCP City 3', value: 'hcp_city_3' },
    ];

    @wire(MessageContext)
    _messageContext;

    _selectedHcpSpeciality = '';
    _selectedHcpType = '';
    _selectedHcpCity = '';
    
    handleHcpSpecialityChange(evt) {
        this._selectedHcpSpeciality = evt.detail.value;
        this.publishFilterChange();
    }

    handleHcpTypeChange(evt) {
        this._selectedHcpType = evt.detail.value;
        this.publishFilterChange();
    }

    handleHcpCityChange(evt) {
        this._selectedHcpCity = evt.detail.value;
        this.publishFilterChange();
    }

    publishFilterChange() {
        publish(this._messageContext, hcpFilterMessageChannel, {filter: {
            hcpSpeciality: this._selectedHcpSpeciality,
            hcpType: this._selectedHcpType,
            hcpCity: this._selectedHcpCity
        }});
    }
}