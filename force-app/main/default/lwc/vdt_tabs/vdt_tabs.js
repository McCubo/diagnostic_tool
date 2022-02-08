import { LightningElement, wire, track } from 'lwc';
import tabsMessageChannel from '@salesforce/messageChannel/vdt_tabs__c';
import { publish, MessageContext } from 'lightning/messageService';
import getActiveMainMenuOptions from '@salesforce/apex/VDT_TabsController.getActiveMainMenuOptions';

export const TABS = {
    home: {
        name: 'Home',
        icon: 'utility:home',
        active: true
    },
    onekey: {
        name: 'Master Data Analysis',
        icon: 'utility:file',
        active: false
    },
    fieldAnalysis: {
        name: 'Object-Field Analysis',
        icon: 'utility:database',
        active: false
    },
    users: {
        name: 'CRM Users',
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
    },
    territory: {
        name: 'Territory Analysis',
        icon: 'utility:location',
        active: false
    },
    fieldLevelSecurity: {
        name: 'Field Level Security Analysis',
        icon: 'utility:lock',
        active: false
    },
    vaultDocuments: {
        name: 'CRM Vault Documents',
        icon: 'utility:open_folder',
        active: false
    },
    vaultUserKpis : {
        name: 'User Overview Analysis',
        icon: 'utility:metrics',
        active: false
    }
}
export const DEFAULT_TAB = TABS.home;

export default class Vdt_tabs extends LightningElement {

    @wire(getActiveMainMenuOptions)
    _activeMenuOptions;

    get isHomeVisible() {
        if (this.activeMenuOptions.length > 0) {
            return this.activeMenuOptions.includes('home');
        }
        return false;
    }

    get isMasterDataVisible() {
        if (this.activeMenuOptions.length > 0) {
            return this.activeMenuOptions.includes('master_data_analysis');
        }
        return false;
    }

    get isObjectAnalysisVisible() {
        if (this.activeMenuOptions.length > 0) {
            return this.activeMenuOptions.includes('object_field_analysis');
        }
        return false;
    }

    get isUsersVisible() {
        if (this.activeMenuOptions.length > 0) {
            return this.activeMenuOptions.includes('users');
        }
        return false;
    }

    get isProductVisible() {
        if (this.activeMenuOptions.length > 0) {
            return this.activeMenuOptions.includes('product_adoption');
        }
        return false;
    }

    get isSettingsVisible() {
        if (this.activeMenuOptions.length > 0) {
            return this.activeMenuOptions.includes('settings');
        }
        return false;
    }    
    
    get isTerritoryAnalysisVisible() {
        if (this.activeMenuOptions.length > 0) {
            return this.activeMenuOptions.includes('territory_analysis');
        }
        return false;
    }

    get isFieldLevelSecurityVisible() {
        if (this.activeMenuOptions.length > 0) {
            return this.activeMenuOptions.includes('field_level_security');
        }
        return false;
    }

    get activeMenuOptions() {
        if (this._activeMenuOptions.data) {
            return this._activeMenuOptions.data.split(',');
        }
        return [];
    }

    _currentTab = DEFAULT_TAB;
    @track 
    _tabs = TABS;

    @wire(MessageContext)
    messageContext;

    handleFLSClick() {
        Object.values(this._tabs).forEach(tab => tab.active = tab.name === this._tabs.fieldLevelSecurity.name);
        publish(this.messageContext, tabsMessageChannel, {selectedTab: this._tabs.fieldLevelSecurity.name});
    }

    handleTerritoryClick() {
        Object.values(this._tabs).forEach(tab => tab.active = tab.name === this._tabs.territory.name);
        publish(this.messageContext, tabsMessageChannel, {selectedTab: this._tabs.territory.name});
    }

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

    handleVaultDocumentsClick() {
        Object.values(this._tabs).forEach(tab => tab.active = tab.name === this._tabs.vaultDocuments.name);
        publish(this.messageContext, tabsMessageChannel, {selectedTab: this._tabs.vaultDocuments.name});
    }

    handleVaultUserKpisClick() {
        Object.values(this._tabs).forEach(tab => tab.active = tab.name === this._tabs.vaultUserKpis.name);
        publish(this.messageContext, tabsMessageChannel, {selectedTab: this._tabs.vaultUserKpis.name});
    }
}