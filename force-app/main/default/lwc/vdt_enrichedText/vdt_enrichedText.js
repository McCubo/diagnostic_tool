import { api, LightningElement } from 'lwc';

export default class Vdt_enrichedText extends LightningElement {

    @api
    recordId;
    @api
    textValue;
    @api
    helpMessage;
    @api
    formulaMessage;

    get tooltipMessage() {
        return this.helpMessage + ' [' + this.formulaMessage + ']';
    }
}