import { api, LightningElement } from 'lwc';

const BAR_CLASS= 'slds-progress-bar__value';
const BAR_CLASS_COMPLETED = 'slds-progress-bar__value_success';

export default class Vdt_onekeyProgressBar extends LightningElement {
    
    @api 
    recordId;
    @api
    actualValue;
    @api
    targetValue;

    get completion() {
        return 'width:' + ((this.actualValue/this.targetValue) *100) + '%';
    }

    get cssClass() {
        if (this.actualValue == this.targetValue) {
            return BAR_CLASS + ' ' + BAR_CLASS_COMPLETED;
        }
        return BAR_CLASS;
    }
}