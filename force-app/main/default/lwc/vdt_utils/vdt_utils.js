import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, APPLICATION_SCOPE } from 'lightning/messageService';

const label = {
    error: 'Error',
    success: 'Success',
    warning: 'Warning'
}

export function flattenJSON(obj = {}, res = {}, extraKey = '') {
    for (let key in obj) {
       if (typeof obj[key] !== 'object') {
          res[extraKey + key] = obj[key];
       } else {
          this.flattenJSON(obj[key], res, `${extraKey}${key}.`);
       };
    };
    return res;
};

export function showToast(message, type) {
    const evt = new ShowToastEvent({
        title: label[type],
        message: message,
        variant: type,
    });
    return evt;
}

export function subscribeToMessageChannel(currentSubscription, channel, messageHandler, ctx) {
    let subscription;
    if (!currentSubscription) {
        subscription = subscribe(
            ctx,
            channel,
            message => messageHandler(message),
            { scope: APPLICATION_SCOPE }
        );
    } else {
        subscription = currentSubscription;
    }

    return subscription;
}

export function unsubscribeToMessageChannel(subscription) {
    unsubscribe(subscription);
    return null;
}

export const MONTH_NAMES = {
    1: 'JANUARY',
    2: 'FEBRUARY',
    3: 'MARCH',
    4: 'APRIL',
    5: 'MAY',
    6: 'JUNE',
    7: 'JULY',
    8: 'AUGUST',
    9: 'SEPTEMBER',
    10: 'OCTOBER',
    11: 'NOVEMBER',
    12: 'DECEMBER'
}