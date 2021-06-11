import { LightningElement } from 'lwc';

export default class Vdt_permissionsMetadataAnalysis extends LightningElement {

    selectedAnalysisOption = 'sobject';

    get isFieldLevelSecuritySelected() {
        return this.selectedAnalysisOption == 'sobject';
    }

    get isProfileAndPermissionSetSelected() {
        return this.selectedAnalysisOption == 'profile_permissionset';
    }

    get analysisOptions() {
        return [
            { label: 'SObject Analysis', value: 'sobject' },
            { label: 'Profile/Permission Set', value: 'profile_permissionset' },
        ];
    }

    handleAnalysisOptionChange(event) {
        this.selectedAnalysisOption = event.detail.value;
    }
}