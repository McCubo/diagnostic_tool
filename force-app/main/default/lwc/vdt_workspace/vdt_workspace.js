import { LightningElement, wire } from 'lwc';
import tabsMessageChannel from '@salesforce/messageChannel/vdt_tabs__c';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
import { TABS, DEFAULT_TAB } from 'c/vdt_tabs';

export default class Vdt_workspace extends LightningElement {
    _subscription = null;
    _selectedTab = DEFAULT_TAB.name;

    @wire(MessageContext)
    messageContext;

    get showHome() {
        return this._selectedTab === TABS.home.name;
    }
    get showOneKey() {
        return this._selectedTab === TABS.onekey.name;
    }
    get showFieldAnalysis() {
        return this._selectedTab === TABS.fieldAnalysis.name;
    }
    get showUsers() {
        return this._selectedTab === TABS.users.name;
    }
    get showProducts() {
        return this._selectedTab === TABS.products.name;
    }
    get showSettings() {
        return this._selectedTab === TABS.settings.name;
    }

    get showTerritory() {
        return this._selectedTab === TABS.territory.name;
    }

    get showFielLevelSecurity() {
        return this._selectedTab === TABS.fieldLevelSecurity.name;
    }
    
    handleMessage(message) {
        if (message.selectedTab) {
            this._selectedTab = message.selectedTab;
        }
    }

    subscribeToMessageChannel() {
        if (!this._subscription) {
            this._subscription = subscribe(
                this.messageContext,
                tabsMessageChannel,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this._subscription);
        this._subscription = null;
    }

    connectedCallback() {
        this.subscribeToMessageChannel();

    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }
}