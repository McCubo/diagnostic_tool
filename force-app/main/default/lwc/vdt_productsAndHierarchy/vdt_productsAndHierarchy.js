import { LightningElement } from 'lwc';
const PRODUCT_DATA = [
    {
        label: 'Oncology',
        name: '1',
        expanded: false,
        type: 'Detail',
        country: 'GB',
        metatext: 'Product Type: Detail | Country: GB',
        items: [
            {
                label: 'Product Onco',
                name: '2',
                expanded: false,
                type: 'Detail',
                country: 'GB',
                metatext: 'Product Type: Detail | Country: GB',
                items: [
                    {
                        label: 'Promotional ONCO #1',
                        name: '3',
                        expanded: false,
                        type: 'High Value Promotional',
                        country: 'GB',
                        metatext: 'Product Type: High Value Promotional | Country: GB',
                        items: [],
                    },
                    {
                        label: 'Promotional ONCO #2',
                        name: '4',
                        expanded: false,
                        type: 'Promotional',
                        country: 'GB',
                        metatext: 'Product Type: Promotional | Country: GB',
                        items: [],
                    },
                    {
                        label: 'Promotional ONCO #3',
                        name: '5',
                        expanded: false,
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
        expanded: false,
        type: 'Sample',
        country: 'FR',
        metatext: 'Product Type: Sample | Country: FR',
        items: [
            {
                label: 'Product Pediatric',
                name: '7',
                expanded: false,
                type: 'Sample',
                country: 'FR',
                metatext: 'Product Type: Sample | Country: FR',
                items: [
                    {
                        label: 'Detail Topic Pediatrics #1',
                        name: '8',
                        expanded: false,
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
        expanded: false,
        items: [
            {
                label: 'Respiratory',
                name: '11',
                expanded: false,
                type: 'Market',
                country: 'DE',
                metatext: 'Product Type: Market | Country: DE',
                items: [
                    {
                        label: 'Ambulatory Equipment',
                        name: '12',
                        expanded: false,
                        type: 'Market',
                        country: 'DE',
                        metatext: 'Product Type: Market | Country: DE',
                        items: [],
                    },
                    {
                        label: 'Tracheostomy',
                        name: '13',
                        expanded: false,
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
                expanded: false,
                type: 'Market',
                country: 'DE',
                metatext: 'Product Type: Market | Country: DE',
                items: [
                    {
                        label: 'Kits and Trays',
                        name: '15',
                        expanded: false,
                        type: 'Market',
                        country: 'DE',
                        metatext: 'Product Type: Market | Country: DE',
                        items: [],
                    },
                    {
                        label: 'Wound Care Accessories',
                        name: '17',
                        expanded: false,
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
const columns = [
    { label: 'Product', fieldName: 'name' },
    { label: 'Product Type', fieldName: 'type'},
    { label: '#Active key messages', fieldName: 'activeKeyMessages', type: 'number' },
    { label: '#Active CLM', fieldName: 'activeCLM', type: 'number' },
    { label: '#Approved Document', fieldName: 'approvedDocuments', type: 'number' },
    { label: '#Sent email', fieldName: 'sentEmail', type: 'number' },
    { label: '#Product metric', fieldName: 'productMetric', type: 'number' },
    { label: '#Calls/Visits', fieldName: 'callsVisits', type: 'number' },
    { label: '#Events', fieldName: 'events', type: 'number' },
];
const ADOPTION_DATA = [
    { name: 'Oncology', type: 'Detail', activeKeyMessages: '200', activeCLM:'255', approvedDocuments:'100', sentEmail:'1520', productMetric:'25', callsVisits:'200', events:'50'},
    { name: 'Product Onco', type: 'Detail', activeKeyMessages:'336', activeCLM:'100', approvedDocuments:'31', sentEmail:'670', productMetric:'13', callsVisits:'99', events:'10'},
    { name: 'Promotional ONCO #1', type: 'High Value Promotional', activeKeyMessages:'225', activeCLM:'10', approvedDocuments:'49', sentEmail:'131', productMetric:'10', callsVisits:'200', events:'20'},
    { name: 'Promotional ONCO #2', type: 'Promotional', activeKeyMessages:'200', activeCLM:'321', approvedDocuments:'55', sentEmail:'75', productMetric:'252', callsVisits:'36', events:'25'},
    { name: 'Promotional ONCO #3', type: 'Promotional', activeKeyMessages:'100', activeCLM:'101', approvedDocuments:'541', sentEmail:'3214', productMetric:'51', callsVisits:'100', events:'33'},
    { name: 'Paediatrics', type: 'Sample', activeKeyMessages:'128', activeCLM:'3025', approvedDocuments:'159', sentEmail:'951', productMetric:'32', callsVisits:'55', events:'10'},
    { name: 'Product Pediatric', type: 'Sample', activeKeyMessages:'600', activeCLM:'500', approvedDocuments:'300', sentEmail:'221', productMetric:'100', callsVisits:'852', events:'6'},
    { name: 'Detail Topic Pediatrics #1', type: 'Detail Topic', activeKeyMessages:'852', activeCLM:'8745', approvedDocuments:'357', sentEmail:'8520', productMetric:'100', callsVisits:'356', events:'10'},
    { name: 'Emergency Medicine', type: 'Market', activeKeyMessages:'356', activeCLM:'555', approvedDocuments:'786', sentEmail:'1035', productMetric:'100', callsVisits:'100', events:'59'},
    { name: 'Respiratory', type: 'Market', activeKeyMessages:'2587', activeCLM:'365', approvedDocuments:'108', sentEmail:'25', productMetric:'10', callsVisits:'369', events:'15'},
    { name: 'Ambulatory Equipment', type: 'Market', activeKeyMessages:'369', activeCLM:'300', approvedDocuments:'7804', sentEmail:'9308', productMetric:'10', callsVisits:'93', events:'11'},
    { name: 'Tracheostomy', type: 'Market', activeKeyMessages:'93', activeCLM:'20', approvedDocuments:'19', sentEmail:'33', productMetric:'7', callsVisits:'54', events:'21'},
    { name: 'Wound Care', type: 'Market', activeKeyMessages:'540', activeCLM:'100', approvedDocuments:'17', sentEmail:'27', productMetric:'69', callsVisits:'540', events:'5'},
    { name: 'Kits and Trays', type: 'Market', activeKeyMessages:'620', activeCLM:'12340', approvedDocuments:'500', sentEmail:'95134', productMetric:'55', callsVisits:'53', events:'3'},
    { name: 'Wound Care Accessories', type: 'Market', activeKeyMessages:'456', activeCLM:'327', approvedDocuments:'600', sentEmail:'7845', productMetric:'33', callsVisits:'42', events:'10'},
];
export default class Vdt_productsAndHierarchy extends LightningElement {
    
    items = PRODUCT_DATA;
    columns = columns;
    data = ADOPTION_DATA;

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
        this.data = this.filterTableData(JSON.parse(JSON.stringify(ADOPTION_DATA)));
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