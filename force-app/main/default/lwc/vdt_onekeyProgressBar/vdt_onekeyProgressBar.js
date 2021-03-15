import { api, LightningElement } from 'lwc';

const KPI_TYPE_LOWER_IS_BETTER = 'lower';
const KPI_TYPE_HIGHER_IS_BETTER = 'higher';

export default class Vdt_onekeyProgressBar extends LightningElement {
    
    @api 
    recordId;
    @api
    actualValue;
    @api
    targetValue;
    @api
    kpiType;

    get actualValueLabel() {
        let label = this.actualValue;
        if (this.actualValue != 'N/A') {
            label += ' %';
        }
        return label;
    }

    get targetValueLabel() {
        return 'Target: ' + this.targetValue + '%';
    }

    get completion() {
        let progressConfig = 'width:' + this.actualValue + '%;';
        if ((this.kpiType == KPI_TYPE_HIGHER_IS_BETTER && this.actualValue >= this.targetValue) || (this.kpiType == KPI_TYPE_LOWER_IS_BETTER && this.actualValue <= this.targetValue)) {
            progressConfig += 'background: #4bca81';
        } else {
            progressConfig += 'background: #FF0000';
        }
        return progressConfig;
    }

    get targetPercentage() {
        return 'left:' + this.targetValue + '%';
    }

}