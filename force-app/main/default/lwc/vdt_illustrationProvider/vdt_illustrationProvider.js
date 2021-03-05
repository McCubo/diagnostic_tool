import { LightningElement, api } from 'lwc';
import svgLakeMountain from './svgLakeMountain.html'
import svgShowEmpty from './svgShowEmpty.html'

export default class Vdt_illustrationProvider extends LightningElement {
  @api message;
  @api svgname;

  renderHtml = {
      'showempty'     :   svgShowEmpty,
      'lakeMountain'  :   svgLakeMountain
  };
  
  render() {
    if(this.renderHtml[this.svgname]) {
         return this.renderHtml[this.svgname];
    } else {
        return svgShowEmpty;
    }
  }
}