import { LightningElement, api } from 'lwc';

export default class Vdt_paginator extends LightningElement {
    _showStartDots = false;
    _showFirst = false;
    _showLast = false;
    _showEndDots = false;
    _visiblePageNumbersCount = 4;
    _firstPageNumber;
    _lastPageNumber;
    _pageNumbers = [];
    _visiblePages = [];
    _currentPage;

    initVisiblePages() {
        let visibleNumbers = [];
        if (this.pageNumbers.length <= this._visiblePageNumbersCount || 
            this.pageNumbers.length + 1 === this._visiblePageNumbersCount) {
            visibleNumbers = this.pageNumbers;
        } else  {
            visibleNumbers = this.pageNumbers.slice(0, this._visiblePageNumbersCount);
            this._showEndDots = true;
            this._showLast = true;
        } 

        this._visiblePages = visibleNumbers;
        // else if (this._currentPage < this._visiblePageNumbersCount+2) {
        //     visibleNumbers = this.pageNumbers.slice(0, this._visiblePageNumbersCount+2);
        //     visibleNumbers.push(this.pageNumbers[this.pageNumbers.length-1]);
        //     this._showEndDots = true;
        // } else if (this._currentPage < this.pageNumbers.length-1-this._visiblePageNumbersCount) {
        //     visibleNumbers = this.pageNumbers.slice(0, this._visiblePageNumbersCount+2);
        //     visibleNumbers.push(this.pageNumbers[this.pageNumbers.length-1]);
        //     this._showStartDots = true;
        //     this._showEndDots = true;
        // }
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
        this._pageNumbers = val;
        this._firstPageNumber = this._pageNumbers[0];
        this._lastPageNumber = this._pageNumbers[this._pageNumbers.length-1];
        this.initVisiblePages();
    }

    get showPagination() {
        return this.pageNumbers.length > 1;
    }

    goToPrevious() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    goToNext() {
        this.dispatchEvent(new CustomEvent('next'));
    }

    firstClick() {
        this._visiblePages = this._pageNumbers.slice(0, this._visiblePageNumbersCount);
        this._showStartDots = false;
        this._showFirst = false;
        this._showLast = true;
        this._showEndDots = true;
        this.dispatchEvent(new CustomEvent('pageclick', { detail: this._firstPageNumber }));
    }

    lastClick() {
        this._visiblePages = this._pageNumbers.slice(this.pageNumbers.length-this._visiblePageNumbersCount, this.pageNumbers.length-1);
        this._showEndDots = false;
        this._showLast = true;
        this._showFirst = true;
        this._showStartDots = true;
        this.dispatchEvent(new CustomEvent('pageclick', { detail: this._lastPageNumber }));
    }

    goToPage(event) {
        this.dispatchEvent(new CustomEvent('pageclick', { detail: event.target.dataset.pageNumber }));
    }

    rerenderPages() {
        let clickedPage = parseInt(this._currentPage);
        let lastPageClicked = this._visiblePages.indexOf(clickedPage) === this._visiblePages.length-1;
        let firstPageClicked = this._visiblePages.indexOf(clickedPage) === 0;
        let pageBeforeLastPage = this._pageNumbers[this._pageNumbers.length-2];

        if ( lastPageClicked && clickedPage !== pageBeforeLastPage) {
            this._visiblePages = this._pageNumbers.slice(this._visiblePages[0], clickedPage+1);
        } else if (firstPageClicked && clickedPage !== this._firstPageNumber) {
            this._visiblePages = this._pageNumbers.slice(clickedPage-2, (clickedPage-2)+this._visiblePageNumbersCount);
        }

        let startingWithFirstPage = this._pageNumbers.indexOf(this._visiblePages[0]) === 0;
        let startingWithSecondPage = this._pageNumbers.indexOf(this._visiblePages[0]) === 1;
        let endingWithThreeBeforeLast = this._pageNumbers.indexOf(clickedPage) === this._pageNumbers.length-3;
        let endingWithBeforeLast = this._pageNumbers.indexOf(clickedPage) === this._pageNumbers.length-2;
        if (startingWithFirstPage) {
            this._showStartDots = false;
            this._showFirst = false;
        } else if (startingWithSecondPage) {
            this._showStartDots = false;
            this._showFirst = true;
        } else if (endingWithThreeBeforeLast || endingWithBeforeLast) {
            this._showEndDots = false;
        } else {
            this._showStartDots = true;
            this._showFirst = true;
            this._showEndDots = true;
            this._showLast = true;
        }
    }
}