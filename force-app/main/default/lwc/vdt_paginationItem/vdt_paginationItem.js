import { LightningElement, api } from 'lwc';

export default class Vdt_paginationItem extends LightningElement {
    @api pageNumber;
    @api iconName;
    @api currentPageNumber;

    get _itemStyle() {
        return 'container' + (!this._hasIcon && (this.pageNumber == this.currentPageNumber) ? ' selected' : '');
    }

    get _hasIcon() {
        return (this.iconName && this.iconName.length != 0);
    }
}