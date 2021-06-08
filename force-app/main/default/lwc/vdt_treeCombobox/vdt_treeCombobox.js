import { api, LightningElement, track } from 'lwc';

export default class Vdt_treeCombobox extends LightningElement {

    selectedLabel;
    @track
    selectedItem;
    items;
    searchString;

    handleOnselect(event) {
        const findNode = (nodeList, name) => nodeList.find((node) => node.name === name) || nodeList.reduce((p, v) => p || (v.items && findNode(v.items, name)), null);
        this.selectedLabel = findNode(this.items, event.detail.name).label;

        const selectedEvent = new CustomEvent('selected', { 
            detail: { 
                id: event.detail.name,
                label: this.selectedLabel
            } 
        });
        this.dispatchEvent(selectedEvent);
        this.selectedItem = event.detail.name;
    }

    handleClearSelection(event) {
        this.selectedLabel = null;
        this.selectedItem = null;
        const selectedEvent = new CustomEvent('selected', { detail: { 
                id: null,
                label: null
            }
        });
        this.dispatchEvent(selectedEvent);        
    }

    handleSearchTextChanged(event) {
        if (event.detail) {
            this.searchString = event.detail.value;
        } else {
            this.searchString = null;
        }
        
    }

    get buttonLabel() {
        if (this.selectedLabel) {
            return `Currently Selected: ${this.selectedLabel} `;
        }
        return `Currently Selected: -- NONE --- `;
    }

    @api
    get treeData() {
        let filteredItems = [];
        if (this.searchString) {
            filteredItems = this.items.filter(item => {
                return this.showItem(item, this.searchString.toLowerCase());
            }).map(item => {
                let _item = JSON.parse(JSON.stringify(item));
                _item.expanded = this.expandItem(_item, this.searchString.toLowerCase());
                return _item;
            });
        } else {
            filteredItems = this.items;
        }
        return filteredItems;
    }

    set treeData(data) {
        this.items = data;
    }

    showItem(item, searchTerm) {
        let filter = item.label.toLowerCase().includes(searchTerm);
        let filterChild = [];
        if (item.items) {
            filterChild = item.items.filter(childItem => {
                return this.showItem(childItem, searchTerm);
            });
        }
        return filter || filterChild.length > 0;
    }

    expandItem(item, searchTerm) {
        let expand = false;
        if (item.items) {
            expand = item.items.reduce((accumulator, currentItem) => {
                currentItem.expanded = this.expandItem(currentItem, searchTerm);
                return accumulator || currentItem.label.toLowerCase().includes(searchTerm) || currentItem.expanded;
            }, false);
        }
        return expand;
    }

}