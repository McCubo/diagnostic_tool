import { LightningElement, wire } from 'lwc';
import fetchVeevaUsers from '@salesforce/apex/VDT_VeevaUsersController.fetchVeevaUsers';

export default class Vdt_veevaUsers extends LightningElement {
    _actions = [
        { label: 'Revoke Request', name: 'revoke' }
    ]
    _columns = [
        { label: 'User', fieldName: 'name' },
        { label: 'Email', fieldName: 'email', type: 'email' },
        { label: 'Last Login', fieldName: 'lastLoginDate', type: 'date' },
        { label: 'Manager', fieldName: 'managerName'},
        { label: 'Report', fieldName: 'enableReport', type: 'boolean', editable: true },
        { type: 'action', typeAttributes: { rowActions: this._actions }}
    ];
    _users = [];
    _usersQueryLimit = 10;
    _currentOffset = 0;
    _tableElement = null;

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'revoke':
                alert(`handle ${row.name} revoke`)
                break;
            default:
                break;
        }
    }

    loadMoreData(event) {
        this._tableElement = event.target;
        this._tableElement ? this._tableElement.isLoading = true : null;
        fetchVeevaUsers({queryLimit: this._usersQueryLimit, queryOffset: this._currentOffset})
            .then((data) => {
                if (data.length) {
                    const currentData = this._users;
                    const newUsers = currentData.concat(data);
                    this._users = newUsers;
                    this._currentOffset += data.length;
                } else {
                    this._tableElement.enableInfiniteLoading = false;
                }
                this._tableElement.isLoading = false;
            })
            .catch(error => {
                console.log('error', error);
            });
    }

    connectedCallback() {
        fetchVeevaUsers({queryLimit: this._usersQueryLimit, queryOffset: this._currentOffset})
            .then(data => {
                this._users = data;
                this._currentOffset += data.length;
            })
            .catch(error => {
                console.log('error', error);
            })
    }
}