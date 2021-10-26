import { api, LightningElement } from 'lwc';

import getAPIFieldNameByMappingName from '@salesforce/apex/VDT_VeevaVaultController.getAPIFieldNameByMappingName';
import getDocumentsFromVault from '@salesforce/apex/VDT_VeevaVaultController.getDocumentsFromVault';
import getVaultColumns from '@salesforce/apex/VDT_VeevaVaultController.getVaultColumns';
import getStatusValue from '@salesforce/apex/VDT_VeevaVaultController.getStatusValue';
import getCRMColumns from '@salesforce/apex/VDT_VeevaVaultController.getCRMColumns';
import getApprovedDocuments from '@salesforce/apex/VDT_VeevaVaultController.getApprovedDocuments';
import getStatusMap from '@salesforce/apex/VDT_VeevaVaultController.getStatusMap';
import { downloadCSVFile } from 'c/vdt_csvUtil'
import { flattenJSON } from 'c/vdt_utils';

export default class Vdt_vaultDocuments extends LightningElement {

    @api
    section;

    showSpinner = true;
    columns = [];
    data = [];
    rawData = [];

    connectedCallback() {
        this.getDataFromServer();
    }

    handleExport() {
        let headers = {};
        this.columns.forEach(col => headers[col.fieldName] = col.label);
        downloadCSVFile(headers, this.data, 'VaultDocuments');
    }

    handleRefresh(event) {        
        this.showSpinner = true;
        this.columns = [];
        this.data = [];
        this.getDataFromServer();
    }

    async getDataFromServer() {
        let vaultId = await getAPIFieldNameByMappingName({mapName: 'VAULT_IDENTIFIER'});
        let vaultStatus = await getAPIFieldNameByMappingName({mapName: 'VAULT_STATUS'});
        let matchProperty = await getAPIFieldNameByMappingName({mapName: 'CRM_VAULT_JOIN_FIELD_' + this.section.toUpperCase()});
        let crmStatus = await getAPIFieldNameByMappingName({mapName: 'CRM_DOCUMENT_STATUS_' + this.section.toUpperCase()});
        let _columns = await getVaultColumns({section: this.section});
        let _crmColumns = await getCRMColumns({section: this.section});
        let statusMap = await getStatusMap({section: this.section});
        let approvedValue = await getStatusValue({status: 'Approved', section: this.section});

        _columns = _columns.map(column => {
            return {
                label: column.MasterLabel, 
                fieldName: column.Vault_API_Name__c,
                type: 'vdt_coloredCell',
                typeAttributes: {
                    source: 'vault'
                }
            };
        });

        _crmColumns.forEach(cmrcolumn => {
            let vaultColumn = _columns.findIndex(column => column.fieldName == cmrcolumn.Vault_API_Field__c);
            let position = vaultColumn != -1 ? vaultColumn + 1 : _columns.length;
            _columns.splice(position, 0, {
                label: cmrcolumn.MasterLabel, 
                fieldName: cmrcolumn.Field_API_Name__c,
                type: 'vdt_coloredCell',
                typeAttributes: {
                    source: 'crm'
                }
            });
        });

        this.columns = _columns.concat([
            { 
                label: 'Statuses Match?', 
                fieldName: 'statuses_match',
                type: 'boolean'
            },
            { 
                label: 'Ready to Use?', 
                fieldName: 'ready_for_use',
                type: 'boolean'
            }
        ]);
        let vaultDocuments = await getDocumentsFromVault({section: this.section});
        let vaultDocIds = vaultDocuments.reduce((ids, document) => {
            if (document[vaultId]) {
                ids.push(document[vaultId]);
            }
            return ids;
        }, []);
        let approvedDocuments = await getApprovedDocuments({vaultDocIds, section: this.section});
        
        vaultDocuments.map(document => {
            let newDocument = document;
            let matchedDocument = approvedDocuments.find(approvedDocument => approvedDocument[matchProperty] == document[vaultId]);
            if (matchedDocument) {
                let crmDocument = flattenJSON(matchedDocument);
                let isMatch = document[vaultStatus] == statusMap[crmDocument[crmStatus]];
                let isReadyToUse = isMatch && String(crmDocument[crmStatus]) == approvedValue;
                newDocument = Object.assign(document, crmDocument);
                newDocument['statuses_match'] = isMatch;
                newDocument['ready_for_use'] = isReadyToUse;
            }
            return newDocument;
        });
        this.rawData = JSON.stringify(vaultDocuments);
        this.data = vaultDocuments;
        this.showSpinner = false;
    }

}