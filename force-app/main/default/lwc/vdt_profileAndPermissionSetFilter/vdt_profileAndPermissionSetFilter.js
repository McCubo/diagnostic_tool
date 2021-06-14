import { LightningElement, api } from 'lwc';

import getProfilesAndPermissionSets from '@salesforce/apex/VDT_FieldLevelSecurityController.getProfilesAndPermissionSets';
export default class Vdt_profileAndPermissionSetFilter extends LightningElement {

    @api
    disabled = false;

    _filter = {
        objectNames: null,
        profilesOrPermissionSetsLabels: null
    }

    _objectOptions = [];

    connectedCallback() {
        getProfilesAndPermissionSets()
        .then(response => {
            this._objectOptions = response;
        }).catch(error => {
            console.error(error);
        })
    }

    handleOptionsSelected(evt) {
        this._filter.objectNames = evt.detail;
        this._filter.profilesOrPermissionSetsLabels = this._objectOptions.filter(currentOption => {
            return this._filter.objectNames.includes(currentOption.value);
        }).map(currentOption => currentOption.label);
    }

    handleDisplayInfoClick() {
        const isInputsCorrect = [...this.template.querySelectorAll('.validate')].reduce((validSoFar, inputComponent) => {
                return validSoFar && inputComponent.validate();
            }, true);
        if (isInputsCorrect) {
            this.dispatchEvent(new CustomEvent('showinfo', { detail: this._filter }) );
        }
    }

}