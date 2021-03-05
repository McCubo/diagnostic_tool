import { LightningElement } from 'lwc';

export default class Vdt_profileOptions extends LightningElement {
    handleProfileClick() {
        alert('profile click');
    }

    handleHelpClick() {
        alert('help click');
    }

    handleSuggestFeatureClick() {
        alert('suggest a feature click');
    }

    handleLogoutClick() {
        alert('logout click');
    }
}