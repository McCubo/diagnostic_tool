import LightningDatatable from 'lightning/datatable';
import vdt_progressBar from './vdt_progressBar';
import vdt_enrichedText from './vdt_enrichedText';

export default class Vdt_datatable extends LightningDatatable  {

    static customTypes = {
        vdt_progressBar: {
            template: vdt_progressBar,
            typeAttributes: ['recordId', 'actualValue', 'targetValue', 'type']
        },
        vdt_enrichedText: {
            template: vdt_enrichedText,
            typeAttributes: ['recordId', 'textValue', 'helpMessage', 'formulaMessage']
        }
    }

}