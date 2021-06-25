import { LightningElement } from 'lwc';

import getDocumentsFromVault from '@salesforce/apex/VDT_VeevaVaultController.getDocumentsFromVault';
import getColumns from '@salesforce/apex/VDT_VeevaVaultController.getColumns';
import getApprovedDocuments from '@salesforce/apex/VDT_VeevaVaultController.getApprovedDocuments';
import { downloadCSVFile } from 'c/vdt_csvUtil'

export default class Vdt_vaultDocuments extends LightningElement {

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
        let _columns = await getColumns();
        let idPosition = null;
        this.columns = _columns.map((column, index) => {
            if (column.Veeva_API_Name__c == 'id') {
                idPosition = index + 1;
            }
            return {
                
                label: column.MasterLabel, 
                fieldName: column.Veeva_API_Name__c,
                type: 'vdt_coloredCell',
                typeAttributes: {
                    source: 'vault'
                }
            };
        })
        .concat([
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
        this.columns.splice(idPosition, 0, {
            label: 'Id - CRM', 
            fieldName: 'vaultDocId',
            type: 'vdt_coloredCell',
            typeAttributes: {
                source: 'crm'
            }
        });
        let vaultStatus = this.columns.findIndex(column => column.fieldName == 'status__v') + 1;        
        this.columns.splice(vaultStatus, 0, { 
            label: 'Status - CRM', 
            fieldName: 'cmr_doc_status',
            type: 'vdt_coloredCell',
            typeAttributes: {
                source: 'crm'
            }
        });
        let vaultType = this.columns.findIndex(column => column.fieldName == 'type__v') + 1;
        this.columns.splice(vaultType, 0, { 
            label: 'Type - CRM', 
            fieldName: 'type',
            type: 'vdt_coloredCell',
            typeAttributes: {
                source: 'crm'
            }
        });
        let vaultDocuments = await getDocumentsFromVault();
        let vaultDocIds = vaultDocuments.reduce((ids, document) => {
            if (document['id']) {
                ids.push(document['id']);
            }
            return ids;
        }, []);
        let approvedDocuments = await getApprovedDocuments({vaultDocIds});
        
        vaultDocuments.forEach(document => {
            document['ready_for_use'] = false;

            if (document.type__v == 'Material') {
                document.status__v = 'Approved';
            }

            let matchedDocument = approvedDocuments.find(approvedDocument => approvedDocument.vaultDocId == document.id);
            if (matchedDocument) {
                let dateValidation = true;
                if (document.expiration_date__c) {
                    dateValidation = new Date(document.expiration_date__c) > new Date();
                }
                document['ready_for_use'] = dateValidation && matchedDocument.isApproved && document.status__v == 'Approved';
                document['vaultDocId'] = matchedDocument.vaultDocId;
                document['statuses_match'] = matchedDocument.status == document.status__v;
                document['cmr_doc_status'] = matchedDocument.status;
                document['crmId'] = matchedDocument.crmId;
                document['type'] = matchedDocument.type;
            }
        });
        this.rawData = JSON.stringify(vaultDocuments);
        this.data = vaultDocuments;
        this.showSpinner = false;
    }
}