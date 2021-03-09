import { LightningElement, wire, track } from 'lwc';
import tabsMessageChannel from '@salesforce/messageChannel/vdt_tabs__c';
import { publish, MessageContext } from 'lightning/messageService';

export const TABS = {
    home: {
        name: 'Home',
        icon: 'utility:home',
        active: true
    },
    onekey: {
        name: 'OneKey Data',
        icon: 'utility:file',
        active: false
    },
    fieldAnalysis: {
        name: 'Object-Field Analysis',
        icon: 'utility:database',
        active: false
    },
    users: {
        name: 'Veeva Users',
        icon: 'utility:people',
        active: false
    },
    products: {
        name: 'Product Hierarchy and Adoption',
        icon: 'utility:hierarchy',
        active: false
    },
    settings: {
        name: 'Settings',
        icon: 'utility:slider',
        active: false
    }
}
export const DEFAULT_TAB = TABS.onekey;

export default class Vdt_tabs extends LightningElement {
    _currentTab = DEFAULT_TAB;
    @track 
    _tabs = TABS;

    @wire(MessageContext)
    messageContext;

    handleHomeClick() {
        Object.values(this._tabs).forEach(tab => tab.active = tab.name === this._tabs.home.name);
        publish(this.messageContext, tabsMessageChannel, {selectedTab: this._tabs.home.name});
    }

    handleOnekeyClick() {
        Object.values(this._tabs).forEach(tab => tab.active = tab.name === this._tabs.onekey.name);
        publish(this.messageContext, tabsMessageChannel, {selectedTab: this._tabs.onekey.name});
    }

    handleFieldAnalysisClick() {
        Object.values(this._tabs).forEach(tab => tab.active = tab.name === this._tabs.fieldAnalysis.name);
        publish(this.messageContext, tabsMessageChannel, {selectedTab: this._tabs.fieldAnalysis.name});
    }

    handleUsersClick() {
        Object.values(this._tabs).forEach(tab => tab.active = tab.name === this._tabs.users.name);
        publish(this.messageContext, tabsMessageChannel, {selectedTab: this._tabs.users.name});
    }

    handleProductsClick() {
        Object.values(this._tabs).forEach(tab => tab.active = tab.name === this._tabs.products.name);
        publish(this.messageContext, tabsMessageChannel, {selectedTab: this._tabs.products.name});
    }

    handleSettingsClick() {
        Object.values(this._tabs).forEach(tab => tab.active = tab.name === this._tabs.settings.name);
        publish(this.messageContext, tabsMessageChannel, {selectedTab: this._tabs.settings.name});
    }
}