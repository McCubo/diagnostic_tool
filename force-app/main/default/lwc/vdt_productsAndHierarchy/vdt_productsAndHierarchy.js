import { LightningElement } from 'lwc';
export default class Vdt_productsAndHierarchy extends LightningElement {
    
    

    _countries = [
        {label: 'GB', value: 'GB', selected: false},
        {label: 'FR', value: 'FR', selected: false},
        {label: 'US', value: 'US', selected: false},
        {label: 'DE', value: 'DE', selected: false}
    ];
    
    search = {
        types: [],
        countries: []
    };

    handleCountryChange(event) {
        this.search.countries = event.detail;
        this.treeData = this.filterData(JSON.parse(JSON.stringify(this.items)));
    }
    handleProductTypeChange(event) {
        this.search.types = event.detail;
        this.treeData = this.filterData(JSON.parse(JSON.stringify(this.items)));
        // this.data = this.filterTableData(JSON.parse(JSON.stringify(ADOPTION_DATA)));
    }
    filterData(items) {
        let filtered = items.filter((recordRow) => {
            if (recordRow.items && recordRow.items.length > 0) {
                recordRow.items = this.filterData(recordRow.items);
            }
            if (this.search.types.length > 0 && this.search.countries.length > 0) {
                return this.search.types.includes(recordRow.type) && this.search.countries.includes(recordRow.country);
            } else if (this.search.types.length == 0 && this.search.countries.length == 0) {
                return true;
            } else if (this.search.types.length > 0) {
                return this.search.types.includes(recordRow.type)
            } else if (this.search.countries.length > 0) {
                return this.search.countries.includes(recordRow.country);
            } else {
                return false;
            }
        });
        return filtered;
    }

    filterTableData(records) {
        let filtered = records.filter((recordRow) => {
            return this.search.types.includes(recordRow.type);
        });
        return filtered;
    }

    handleDateRangeChange(evt) {
        console.log(JSON.stringify(evt.detail));
    }
}