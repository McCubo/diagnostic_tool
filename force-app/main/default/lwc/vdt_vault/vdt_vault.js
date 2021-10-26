import { LightningElement } from 'lwc';

export default class Vdt_vault extends LightningElement {

    selectedSection = 'documents';

    get showDocuments() {
        return this.selectedSection == 'documents';
    }

    get showClmPresentation() {
        return this.selectedSection == 'clm';
    }

    get sectionOptions() {
        return [
            { label: 'Email Templates', value: 'documents' },
            { label: 'CLM Presentation', value: 'clm' },
        ];
    }

    handleSectionOptionChange(event) {
        this.selectedSection = event.detail.value;
    }

}