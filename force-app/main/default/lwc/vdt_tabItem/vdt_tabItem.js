import { LightningElement, api } from 'lwc';

export default class Vdt_tabItem extends LightningElement {
    _active = false;
    _containerClass = 'container';

    @api
    iconName;
    @api
    tabName;
    @api
    get active() {
        return this._active;
    }
    set active(val) {
        this._active = val;
        if (this._active) {
            this._containerClass += ' selected';
        } else {
            this._containerClass = 'container';
        }
    }
}