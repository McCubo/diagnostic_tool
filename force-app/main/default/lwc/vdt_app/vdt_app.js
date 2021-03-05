import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import cssResource from '@salesforce/resourceUrl/vdt_styles'

export default class Vdt_app extends LightningElement {
    connectedCallback() {
        loadStyle(this, cssResource + '/vdt_styles.css');
    }
}