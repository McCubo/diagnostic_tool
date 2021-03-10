import { LightningElement } from 'lwc';
const PRODUCT_DATA = [
    {
        label: 'Oncology',
        name: '1',
        expanded: true,
        type: 'Detail',
        country: 'GB',
        metatext: 'Product Type: Detail | Country: GB',
        items: [
            {
                label: 'Product Onco',
                name: '2',
                expanded: true,
                type: 'Detail',
                country: 'GB',
                metatext: 'Product Type: Detail | Country: GB',
                items: [
                    {
                        label: 'Promotional ONCO #1',
                        name: '3',
                        expanded: true,
                        type: 'High Value Promotional',
                        country: 'GB',
                        metatext: 'Product Type: High Value Promotional | Country: GB',
                        items: [],
                    },
                    {
                        label: 'Promotional ONCO #2',
                        name: '4',
                        expanded: true,
                        type: 'Promotional',
                        country: 'GB',
                        metatext: 'Product Type: Promotional | Country: GB',
                        items: [],
                    },
                    {
                        label: 'Promotional ONCO #3',
                        name: '5',
                        expanded: true,
                        type: 'Promotional',
                        country: 'GB',
                        metatext: 'Product Type: Promotional | Country: GB',
                        items: [],
                    },                        
                ],
            },
        ],
    },
    {
        label: 'Paediatrics',
        name: '6',
        expanded: true,
        type: 'Sample',
        country: 'FR',
        metatext: 'Product Type: Sample | Country: FR',
        items: [
            {
                label: 'Product Pediatric',
                name: '7',
                expanded: true,
                type: 'Sample',
                country: 'FR',
                metatext: 'Product Type: Sample | Country: FR',
                items: [
                    {
                        label: 'Detail Topic Pediatrics #1',
                        name: '8',
                        expanded: true,
                        type: 'Detail Topic',
                        country: 'FR',
                        metatext: 'Product Type: Detail Topic | Country: FR',
                        items: [],
                    }
                ],
            },
        ],
    },
    {
        label: 'Emergency Medicine',
        name: '10',
        type: 'Market',
        country: 'DE',
        metatext: 'Product Type: Market | Country: DE',
        expanded: true,
        items: [
            {
                label: 'Respiratory',
                name: '11',
                expanded: true,
                type: 'Market',
                country: 'DE',
                metatext: 'Product Type: Market | Country: DE',
                items: [
                    {
                        label: 'Ambulatory Equipment',
                        name: '12',
                        expanded: true,
                        type: 'Market',
                        country: 'DE',
                        metatext: 'Product Type: Market | Country: DE',
                        items: [],
                    },
                    {
                        label: 'Tracheostomy',
                        name: '13',
                        expanded: true,
                        type: 'Market',
                        country: 'DE',
                        metatext: 'Product Type: Market | Country: DE',
                        items: [],
                    },
                ],
            },
            {
                label: 'Wound Care',
                name: '14',
                expanded: true,
                type: 'Market',
                country: 'DE',
                metatext: 'Product Type: Market | Country: DE',
                items: [
                    {
                        label: 'Kits and Trays',
                        name: '15',
                        expanded: true,
                        type: 'Market',
                        country: 'DE',
                        metatext: 'Product Type: Market | Country: DE',
                        items: [],
                    },
                    {
                        label: 'Wound Care Accessories',
                        name: '17',
                        expanded: true,
                        type: 'Market',
                        country: 'DE',
                        metatext: 'Product Type: Market | Country: DE',
                        items: [],
                    },
                ],
            },
        ],
    },
];
export default class Vdt_productsAndHierarchy extends LightningElement {
    
    items = PRODUCT_DATA;

    _productTypes= [
        {label: 'Detail', value: 'Detail', selected: false},
        {label: 'High Value Promotional', value: 'High Value Promotional', selected: false},
        {label: 'Promotional', value: 'Promotional', selected: false},
        {label: 'Sample', value: 'Sample', selected: false},
        {label: 'Detail Topic', value: 'Detail Topic', selected: false},
        {label: 'Market', value: 'Market', selected: false}
    ];
    _countries = [
        {label: 'GB', value: 'GB', selected: false},
        {label: 'FR', value: 'FR', selected: false},
        {label: 'US', value: 'US', selected: false},
        {label: 'DE', value: 'DE', selected: false}
    ];
    treeData = PRODUCT_DATA;
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
    }
    filterData(items) {
        let filtered = items.filter((recordRow) => {
            if (recordRow.items && recordRow.items.length > 0) {
                recordRow.items = this.filterData(recordRow.items);
            }
            if (this.search.types.length > 0 && this.search.countries.length > 0) {
                return this.search.types.includes(recordRow.type) || this.search.countries.includes(recordRow.country);
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
}