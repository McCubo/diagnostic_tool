import { LightningElement } from 'lwc';

export default class Vdt_orgConnection extends LightningElement {
    orgOptions = [
        { label: 'Current Org', value: 'Current Org' },
        { label: 'Org1', value: 'Org1' },
        { label: 'Org2', value: 'Org2' },
        { label: 'Org3', value: 'Org3' },
    ];

    _selectedOrg = this.orgOptions[0].value;

    handleOrgSelection(event) {
        alert(`${event.detail.value} selected`);
    }
}