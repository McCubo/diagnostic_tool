import { LightningElement, api } from 'lwc';

export default class Vdt_coloredCell extends LightningElement {

    @api
    value;
    @api
    source;

    get backgroundColorClass() {
        return this.source == 'crm' ? 'crm-cell' : this.source == 'vault' ? 'vault-cell' : '';
    }

}