import LightningDatatable from 'lightning/datatable';
import vdt_progressBar from './vdt_progressBar';

export default class Vdt_datatable extends LightningDatatable  {

    static customTypes = {
        vdt_progressBar: {
            template: vdt_progressBar,
            typeAttributes: ['recordId', 'actualValue', 'targetValue']
        }
    }

}