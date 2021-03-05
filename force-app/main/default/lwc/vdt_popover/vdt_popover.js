import { LightningElement, api, track } from 'lwc';



export default class Vdt_popover extends LightningElement {
    _nubbinPositionMapping = {
        left: 'slds-nubbin_left',
        "left-top": 'slds-nubbin_left-top',
        "left-bottom": 'slds-nubbin_left-bottom',
        top: 'slds-nubbin_top',
        "top-left": 'slds-nubbin_top-left',
        "top-right": 'slds-nubbin_top-right',
        right: 'slds-nubbin_right',
        "right-top": 'slds-nubbin_right-top',
        "right-bottom": 'slds-nubbin_right-bottom',
        bottom: 'slds-nubbin_bottom',
        "bottom-left": 'slds-nubbin_bottom-left',
        "bottom-right": 'slds-nubbin_bottom-right',
    }
    _sectionClass = 'slds-popover slds-popover_small';
    _nubbinPosition = 'left';
    _showCloseButton = false;

    @api
    get nubbinPosition() {
        return this._nubbinPosition;
    }
    set nubbinPosition(val) {
        this._nubbinPosition = val;
        this._sectionClass = `slds-popover slds-popover_small ${this._nubbinPositionMapping[this._nubbinPosition]}`
    }
    
    @api showCloseButton;

    handleCloseClick() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}