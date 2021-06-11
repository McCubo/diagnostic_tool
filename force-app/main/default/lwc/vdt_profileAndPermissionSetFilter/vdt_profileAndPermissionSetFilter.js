import { LightningElement, api } from 'lwc';

export default class Vdt_profileAndPermissionSetFilter extends LightningElement {

    @api
    disabled = false;

    _filter = {
        profilesOrPermissionSets: null,
        profilesOrPermissionSetsLabels: null
    }

    _objectOptions = [
        {label: 'System Administrator', secondaryLabel: 'Standard - Salesforce Platform', value: '0PS46000001SPyaGAG'},
        {label: 'Standard User', secondaryLabel: 'Standard - Salesforce Platform', value: '0PS46000001SPywGAG'},
        {label: 'Standard Platform User', secondaryLabel: 'Standard - Salesforce Platform', value: '0PS46000001SPyxGAG'},
        {label: 'Read Only', secondaryLabel: 'Standard - Salesforce Platform', value: '0PS46000001SPyqGAG'}
    ];

    handleOptionsSelected(evt) {
        this._filter.profilesOrPermissionSets = evt.detail;
        this._filter.profilesOrPermissionSetsLabels = this._objectOptions.filter(currentOption => {
            return this._filter.profilesOrPermissionSets.includes(currentOption.value);
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