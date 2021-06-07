import { api, LightningElement, track } from 'lwc';

export default class Vdt_treeCombobox extends LightningElement {

    selectedLabel;
    @track
    selectedItem;
    items;

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

    get buttonLabel() {
        if (this.selectedLabel) {
            return `Currently Selected: ${this.selectedLabel} `;
        }
        return `Currently Selected: -- NONE --- `;
    }

    @api
    get treeData() {
        return this.items;
    }

    set treeData(data) {
        this.items = data;
    }
}