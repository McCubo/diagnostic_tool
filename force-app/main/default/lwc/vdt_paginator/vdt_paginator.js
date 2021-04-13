import { LightningElement, api } from 'lwc';

export default class Vdt_paginator extends LightningElement {
    get _showStartDots() {
        return  this._currentPage >= this._firstPageNumber+this._visiblePageNumbersCount-1 &&
                this._visiblePages.length+1 > this._visiblePageNumbersCount;
    }
    _showFirst = false;
    _showLast = false;
    get _showEndDots() {
        return  this._currentPage < this._lastPageNumber-2 && 
                this._visiblePages.length+1 > this._visiblePageNumbersCount;
    }
    _visiblePageNumbersCount = 4;
    _firstPageNumber;
    _lastPageNumber;
    _pageNumbers = [];
    _visiblePages = [];
    _currentPage;

    _dynamicPages = [];

    initVisiblePages() {
        let visibleNumbers = [];
        this._showFirst = true;
        if (this._firstPageNumber === this._lastPageNumber) {
            this._showLast = false;
        } else if (this._pageNumbers.length === 0) {
            this._showLast = true;
        } else if (this._pageNumbers.length <= this._visiblePageNumbersCount) {
            this._showLast = true;
            visibleNumbers = this._pageNumbers;
        } else {
            this._showLast = true;
            visibleNumbers = this._pageNumbers.slice(0, this._visiblePageNumbersCount);
        }

        this._visiblePages = visibleNumbers;
    }

    @api 
    get currentPage() {
        return this._currentPage;
    }
    set currentPage(val) {
        this._currentPage = val;
        this.rerenderPages();
    }
    @api 
    get pageNumbers() {
        return this._pageNumbers;
    }
    set pageNumbers(val) {
        this._firstPageNumber = val[0];
        this._lastPageNumber = val[val.length-1];
        this._pageNumbers = val.slice(1, val.length-1);

        this.initVisiblePages();
    }

    get showPagination() {
        return this.pageNumbers.length > 0 || this._showFirst || this._showLast;
    }

    goToPrevious() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    goToNext() {
        this.dispatchEvent(new CustomEvent('next'));
    }

    firstClick() {
        this._visiblePages = this._pageNumbers.slice(0, this._visiblePageNumbersCount);
        this.dispatchEvent(new CustomEvent('pageclick', { detail: this._firstPageNumber }));
    }

    lastClick() {
        this._visiblePages = this._pageNumbers.slice(this.pageNumbers.length-this._visiblePageNumbersCount, this.pageNumbers.length);
        this.dispatchEvent(new CustomEvent('pageclick', { detail: this._lastPageNumber }));
    }

    goToPage(event) {
        this.dispatchEvent(new CustomEvent('pageclick', { detail: event.target.dataset.pageNumber }));
    }

    rerenderPages() {
        let clickedPage = parseInt(this._currentPage);
        let lastPageClicked = this._visiblePages.indexOf(clickedPage) === this._visiblePages.length-1;
        let firstPageClicked = this._visiblePages.indexOf(clickedPage) === 0;

        if (lastPageClicked && clickedPage < this._lastPageNumber-2) {
            this._visiblePages = this._pageNumbers.slice(this._visiblePages[0]-1, clickedPage);
        } else if (firstPageClicked && clickedPage > this._firstPageNumber+1) {
            this._visiblePages = this._pageNumbers.slice(clickedPage-3, clickedPage+1);
        }
    }
}