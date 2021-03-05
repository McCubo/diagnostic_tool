import { LightningElement, wire } from 'lwc';
import hcoFilterMessageChannel from '@salesforce/messageChannel/vdt_hcoFilter__c';
import { publish, MessageContext } from 'lightning/messageService';

export default class Vdt_onekeyHcoFilters extends LightningElement {
    _hcoSpecialityOptions = [
        { label: 'HCO Speciality 1', value: 'hco_speciality_1' },
        { label: 'HCO Speciality 2', value: 'hco_speciality_2' },
        { label: 'HCO Speciality 3', value: 'hco_speciality_3' },
    ];
    _hcoTypeOptions = [
        { label: 'HCO Type 1', value: 'hco_type_1' },
        { label: 'HCO Type 2', value: 'hco_type_2' },
        { label: 'HCO Type 3', value: 'hco_type_3' },
    ];
    _hcoCityOptions = [
        { label: 'HCO City 1', value: 'hco_city_1' },
        { label: 'HCO City 2', value: 'hco_city_2' },
        { label: 'HCO City 3', value: 'hco_city_3' },
    ];

    @wire(MessageContext)
    _messageContext;

    _selectedHcoSpeciality = '';
    _selectedHcoType = '';
    _selectedHcoCity = ''

    handleHcoSpecialityChange(evt) {
        this._selectedHcoSpeciality = evt.detail.value;
        this.publishFilterChange();
    }

    handleHcoTypeChange(evt) {
        this._selectedHcoType = evt.detail.value;
        this.publishFilterChange();
    }

    handleHcoCityChange(evt) {
        this._selectedHcoCity = evt.detail.value;
        this.publishFilterChange();
    }

    publishFilterChange() {
        publish(this._messageContext, hcoFilterMessageChannel, {filter: {
            hcoSpeciality: this._selectedHcoSpeciality,
            hcoType: this._selectedHcoType,
            hcoCity: this._selectedHcoCity
        }});
    }
}