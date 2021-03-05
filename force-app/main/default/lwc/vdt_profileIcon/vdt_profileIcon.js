import { LightningElement } from 'lwc';

export default class Vdt_profileIcon extends LightningElement {
    _popoverVisible = false;

    handleClick() {
        this._popoverVisible = !this._popoverVisible;
    }

    handleClosePopover() {
        this._popoverVisible = false;
    }
}