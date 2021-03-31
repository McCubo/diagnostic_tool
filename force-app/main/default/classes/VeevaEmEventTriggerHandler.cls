public without sharing class VeevaEmEventTriggerHandler extends VeevaTriggerHandler {

    private List<EM_Event_vod__c> newEvents = new List<EM_Event_vod__c>();
    private List<EM_Event_vod__c> oldEvents = new List<EM_Event_vod__c>();
    private Map<ID, EM_Event_vod__c> newEventsMap = new Map<ID, EM_Event_vod__c>();
    private Map<ID, EM_Event_vod__c> oldEventsMap = new Map<ID, EM_Event_vod__c>();
    
    protected override void preTrigger(List<SObject> triggerNew, List<SObject> triggerOld, Map<ID, SObject> triggerNewMap, Map<ID, SObject> triggerOldMap) {
        this.newEvents = (List<EM_Event_vod__c>) triggerNew;
        this.oldEvents = (List<EM_Event_vod__c>) triggerOld;
        this.newEventsMap = (Map<ID, EM_Event_vod__c>) triggerNewMap;
        this.oldEventsMap = (Map<ID, EM_Event_vod__c>) triggerOldMap;
    }
    
    protected override boolean doRecursionCheck() {
        return true;
    }
    
    protected override String sObjectType() {
        return 'EM_Event_vod__c';
    }
    
    protected override void beforeInsert() {
        vodEmEventLock();
        vodEmEventBeforeInsUpd();
        VeevaCountryHelper.updateCountryFields(EM_Event_vod__c.getSObjectType(), EM_Event_vod__c.OwnerId, null, false, newEvents, oldEvents);
    }
    
    protected override void beforeUpdate() {
        vodEmEventLock();
        vodEmEventBeforeInsUpd();
        vodEventUpdate();
        VeevaCountryHelper.updateCountryFields(EM_Event_vod__c.getSObjectType(), EM_Event_vod__c.OwnerId, null, true, newEvents, oldEvents);
    }
    
    protected override void beforeDelete() {
        vodEmEventLock();
        vodEmEventBeforeDel();
    }
    
    protected override void afterInsert() {
        vodEmEventAfterInsUpd();
    }
    
    protected override void afterUpdate() {
        vodEmEventAfterInsUpd();
    }

    private void vodEmEventBeforeInsUpd() {
        Set<Id> usingEventConfigSet = new Set<Id>();
        Map<Id, List<EM_Event_Rule_vod__c>> configToRules = new Map<Id, List<EM_Event_Rule_vod__c>>();
        Map<String, String> eventToVenue = new Map<String, String>();
        Map<String, String[]> venueToAddress = new Map<String, String[]>();
        Set<String> venueSet = new Set<String>();
        boolean failedExpense = false;

        VOD_Utils.setTriggerEMEvent(true);
        List<Medical_Event_vod__c> medEventStubs = new List<Medical_Event_vod__c>();
        List<EM_Event_History_vod__c> histories = new List<EM_Event_History_vod__c>();
        boolean isAutoNumber = Schema.getGlobalDescribe().get('Medical_Event_vod__c').getDescribe().fields.getMap().get('Name').getDescribe().isAutoNumber();

        for (EM_Event_vod__c event : newEvents) {
            if (event.Venue_vod__c != null) {
                eventToVenue.put(event.Id, event.Venue_vod__c);
                venueSet.add(event.Venue_vod__c);
            }
            if(event.Failed_Expense_vod__c) {
                failedExpense = true;
            }
        }

        boolean stampVenue = false;
        if(Trigger.isInsert) {
            stampVenue = true;
        } else if (Trigger.isUpdate) {
            for(EM_Event_vod__c newEvent: newEvents) {
                EM_Event_vod__c oldEvent = oldEventsMap.get(newEvent.Id);
                if(newEvent.Venue_vod__c != oldEvent.Venue_vod__c) {
                    stampVenue = true;
                    break;
                }
            }
        }
        if(stampVenue) {
            for (EM_Venue_vod__c venue : [SELECT Id, Name, Address_vod__c, Address_Line_2_vod__c, City_vod__c, State_Province_vod__c, Postal_Code_vod__c
                                        FROM EM_Venue_vod__c
                                        WHERE Id IN :venueSet]) {
                venueToAddress.put(venue.Id, new String[] {venue.Name, venue.Address_vod__c, venue.Address_Line_2_vod__c, venue.City_vod__c, venue.State_Province_vod__c, venue.Postal_Code_vod__c});
            }
        }

        if(failedExpense) {
            Set<Id> failedExpenseEvents = new Set<Id>();
            for(Expense_Header_vod__c header: [SELECT Event_vod__c FROM Expense_Header_vod__c WHERE Event_vod__c IN :newEventsMap.keySet() AND Concur_Status_vod__c IN ('Failed_Connection_vod', 'Failed_Config_vod', 'Failed_Duplicate_vod')]) {
                failedExpenseEvents.add(header.Event_vod__c);
            }
            for(EM_Event_vod__c event: newEvents) {
                event.Failed_Expense_vod__c = failedExpenseEvents.contains(event.Id);
            }
        }

        //query event rules for all event configurations used by all new events in this batch
        for (EM_Event_vod__c event : newEvents) {
            if((event.Walk_In_Fields_vod__c == null
                || event.Online_Registration_Fields_vod__c == null
                || event.Account_Attendee_Fields_vod__c == null
                || event.User_Attendee_Fields_vod__c == null
                || event.Contact_Attendee_Fields_vod__c == null)
            && event.Event_Configuration_vod__c != null){
                usingEventConfigSet.add(event.Event_Configuration_vod__c);
            }
        }

        if (usingEventConfigSet.size() > 0) {
            EM_Event_Rule_vod__c[] eventRules4AllUsedConfig = [SELECT Event_Configuration_vod__c, Walk_In_Fields_vod__c, Prescriber_Walk_In_Fields_vod__c , Non_Prescriber_Walk_In_Fields_vod__c, Other_Walk_In_Fields_vod__c,
                                                                    QR_Sign_In_Enabled_vod__c, Online_Registration_Fields_vod__c, Account_Attendee_Fields_vod__c, User_Attendee_Fields_vod__c, Contact_Attendee_Fields_vod__c,
                                                                    RecordType.DeveloperName, Country_Override_vod__c, Country_Override_vod__r.Country_vod__c, Country_Override_vod__r.Event_Configuration_vod__c
                                                            FROM EM_Event_Rule_vod__c
                                                            WHERE RecordType.DeveloperName IN ('Walk_In_Fields_vod', 'Online_Registration_Fields_vod', 'Attendee_Fields_vod') AND
                                                            Event_Configuration_vod__c IN :usingEventConfigSet ORDER BY Event_Configuration_vod__c];
            Id currentConfig = null;
            List<EM_Event_Rule_vod__c> rules4CurrentConfig = null;
            for (Integer i = 0; i < eventRules4AllUsedConfig.size(); i++) {
                if (eventRules4AllUsedConfig[i].Event_Configuration_vod__c != currentConfig){
                    currentConfig = eventRules4AllUsedConfig[i].Event_Configuration_vod__c;
                    rules4CurrentConfig = new List<EM_Event_Rule_vod__c>();
                    configToRules.put(currentConfig, rules4CurrentConfig);
                }
                rules4CurrentConfig.add(eventRules4AllUsedConfig[i]);
            }
        }

        for (EM_Event_vod__c event : newEvents) {
            if((event.Walk_In_Fields_vod__c == null 
                || event.Online_Registration_Fields_vod__c == null 
                || event.Account_Attendee_Fields_vod__c == null 
                || event.User_Attendee_Fields_vod__c == null 
                || event.Contact_Attendee_Fields_vod__c == null) 
                && event.Event_Configuration_vod__c != null) {
                
                EM_Event_Rule_vod__c resultWalkInRule;
                EM_Event_Rule_vod__c resultRegistrationRule;
                EM_Event_Rule_vod__c resultAttendeeFieldsRule;
                List<EM_Event_Rule_vod__c> walkInList = new List<EM_Event_Rule_vod__c>(); 
                List<EM_Event_Rule_vod__c> registrationList = new List<EM_Event_Rule_vod__c>();
                List<EM_Event_Rule_vod__c> attendeeFieldsList = new List<EM_Event_Rule_vod__c>();
                
                List<EM_Event_Rule_vod__c> allEventRules = configToRules.get(event.Event_Configuration_vod__c);
                List<EM_Event_Rule_vod__c> eventRules = new List<EM_Event_Rule_vod__c>();
                //match country between rules and event.
                if (allEventRules != null) {
                    for (EM_Event_Rule_vod__c rule : allEventRules) {
                        if(rule.Country_Override_vod__c ==  NULL ||
                            (rule.Country_Override_vod__r.Country_vod__c == event.Country_vod__c &&
                            rule.Country_Override_vod__r.Event_Configuration_vod__c == event.Event_Configuration_vod__c)){
                            eventRules.add(rule);
                        }
                    }
                }
                

                for(EM_Event_Rule_vod__c rule: eventRules) {
                    if(rule.RecordType.DeveloperName == 'Walk_In_Fields_vod') {
                        walkInList.add(rule);
                    } else if(rule.RecordType.DeveloperName == 'Online_Registration_Fields_vod') {
                        registrationList.add(rule);
                    } else if(rule.RecordType.DeveloperName == 'Attendee_Fields_vod') {
                        attendeeFieldsList.add(rule);    
                    }
                }
                
                if (walkInList.size() == 1) {
                    resultWalkInRule = walkInList.get(0);
                } else if (walkInList.size() == 2) {
                    for (EM_Event_Rule_vod__c row : walkInList) {
                        if (row.Country_Override_vod__c != null) {
                            resultWalkInRule = row;
                            break;
                        }
                    }
                }
                
                if (registrationList.size() == 1) {
                    resultRegistrationRule = registrationList.get(0);
                } else if (registrationList.size() == 2) {
                    for (EM_Event_Rule_vod__c row : registrationList) {
                        if (row.Country_Override_vod__c != null) {
                            resultRegistrationRule = row;
                            break;
                        }
                    }
                }
                
                if(attendeeFieldsList.size() == 1) {
                    resultAttendeeFieldsRule = attendeeFieldsList.get(0);
                } else if (attendeeFieldsList.size() == 2) {
                    for (EM_Event_Rule_vod__c row: attendeeFieldsList) {
                        if(row.Country_Override_vod__c != null) {
                            resultAttendeeFieldsRule = row;
                            break;
                        }
                    }
                }

                if(resultWalkInRule != null){
                    if(resultWalkInRule.Walk_In_Fields_vod__c != null) {
                        event.Walk_In_Fields_vod__c = resultWalkInRule.Walk_In_Fields_vod__c;
                    }
                    if(resultWalkInRule.QR_Sign_In_Enabled_vod__c != null){
                        event.QR_Sign_In_Enabled_vod__c = resultWalkInRule.QR_Sign_In_Enabled_vod__c;
                    }
                    if (resultWalkInRule.Prescriber_Walk_In_Fields_vod__c != null) {
                        event.Prescriber_Walk_In_Fields_vod__c = resultWalkInRule.Prescriber_Walk_In_Fields_vod__c;
                    }
                    if (resultWalkInRule.Non_Prescriber_Walk_In_Fields_vod__c != null) {
                        event.Non_Prescriber_Walk_In_Fields_vod__c = resultWalkInRule.Non_Prescriber_Walk_In_Fields_vod__c;
                    }
                    if (resultWalkInRule.Other_Walk_In_Fields_vod__c != null) {
                        event.Other_Walk_In_Fields_vod__c = resultWalkInRule.Other_Walk_In_Fields_vod__c;
                    }
                }
                
                if(resultRegistrationRule != null && resultRegistrationRule.Online_Registration_Fields_vod__c != null) {
                    event.Online_Registration_Fields_vod__c = resultRegistrationRule.Online_Registration_Fields_vod__c;
                }
                
                if(resultAttendeeFieldsRule != null && 
                (resultAttendeeFieldsRule.Account_Attendee_Fields_vod__c != null
                    || resultAttendeeFieldsRule.User_Attendee_Fields_vod__c != null
                    || resultAttendeeFieldsRule.Contact_Attendee_Fields_vod__c != null)) {
                    event.Account_Attendee_Fields_vod__c = resultAttendeeFieldsRule.Account_Attendee_Fields_vod__c;
                    event.User_Attendee_Fields_vod__c = resultAttendeeFieldsRule.User_Attendee_Fields_vod__c;
                    event.Contact_Attendee_Fields_vod__c = resultAttendeeFieldsRule.Contact_Attendee_Fields_vod__c;
                }else {
                    //default value
                    event.Account_Attendee_Fields_vod__c = ';;Account_Identifier_vod;;LastTopic;;Specialty_1_vod;;Address;;RecentEvents;;';
                    event.User_Attendee_Fields_vod__c = ';;RecentEvents;;';
                    event.Contact_Attendee_Fields_vod__c = ';;RecentEvents;;';
                }
            }
            String venue = eventToVenue.get(event.Id);
            if (venue != null) {
                String[] address = venueToAddress.get(venue);
                if(address != null) {
                    event.Location_vod__c = address[0];
                    event.Location_Address_vod__c = address[1];
                    event.Location_Address_Line_2_vod__c = address[2];
                    event.City_vod__c = address[3];
                    event.State_Province_vod__c = address[4];
                    event.Postal_Code_vod__c = address[5];    
                }           
            }
        }
    }

    private void vodEmEventAfterInsUpd() {
        List<EM_Event_vod__c> childEventstoUpdate = new List<EM_Event_vod__c>();
        List<EM_Event_vod__c> childEvents = new List<EM_Event_vod__c>();
        List<Task> taskstoUpdate = new List<Task>();
        List<Task> tasks = new List<Task>();
        VOD_Utils.setTriggerEMEvent(true);

        List<Id> canceledEvents = new List<Id>();

        Set<String> topicSet = new Set<String>();
        Set<String> configSet = new Set<String>();
        Set<String> countrySet = new Set<String>();

        for(EM_Event_vod__c event: newEvents){
            if(event.Status_vod__c == 'Canceled_vod') {
                canceledEvents.add(event.Id);
            }
            if (event.Topic_vod__c != null) {
                topicSet.add(event.Topic_vod__c);
            }
            if (event.Country_vod__c != null) {
                countrySet.add(event.Country_vod__c);
            }
            if (event.Event_Configuration_vod__c != null) {
                configSet.add(event.Event_Configuration_vod__c);
            }
        }

        // Ad-Hoc Sync Process
        if(Trigger.isUpdate){
            List<EM_Event_vod__c> adHocEvents = new List<EM_Event_vod__c>();

            for(EM_Event_vod__c event: newEvents){
                if(oldEventsMap.get(event.Id).Name != event.Name){
                    adHocEvents.add(event);
                }
            }
            EMEventTriggerHandler.syncEvents(adHocEvents);
        }

        if(canceledEvents.size() > 0) {
            childEvents = [SELECT Id
                        FROM EM_Event_vod__c
                        WHERE Parent_Event_vod__c IN: canceledEvents AND
                        Start_Time_vod__c >=: Datetime.now()];
            tasks = [SELECT Id
                    FROM Task
                    WHERE WhatId IN: canceledEvents];
        }

        for(Task task: tasks) {
            task.Event_Canceled_vod__c = true;
            taskstoUpdate.add(task);
        }

        for(EM_Event_vod__c childEvent: childEvents) {
            childEvent.Status_vod__c = 'Canceled_vod';
            childEventstoUpdate.add(childEvent);
        }

        if(taskstoUpdate.size() > 0) {
            update taskstoUpdate;
        }

        if(childEventstoUpdate.size() > 0) {
            update childEventstoUpdate;
        }
        Map<String,String> medEventRtNameToId = new Map<String,String>();
        Map<String,String> emRtIdToName = new Map<String,String>();
        for (RecordType rt : [SELECT Id,DeveloperName,SobjectType
                            FROM RecordType
                            WHERE SobjectType IN ('Medical_Event_vod__c', 'EM_Event_vod__c')]) {
            if (rt.SobjectType == 'Medical_Event_vod__c') {
                medEventRtNameToId.put(rt.DeveloperName, rt.Id);
            } else if (rt.SobjectType == 'EM_Event_vod__c') {
                emRtIdToName.put(rt.Id, rt.DeveloperName);
            }
        }
        Map<String,Schema.RecordTypeInfo> medEventRTByDeveloperName = Medical_Event_vod__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
        Map<Id,Schema.RecordTypeInfo> eventRTById = EM_Event_vod__c.sObjectType.getDescribe().getRecordTypeInfosById();

        List<Medical_Event_vod__c> medEventStubs = new List<Medical_Event_vod__c>();
        List<EM_Event_History_vod__c> histories = new List<EM_Event_History_vod__c>();
        boolean hasOwner = Schema.getGlobalDescribe().get('Medical_Event_vod__c').getDescribe().fields.getMap().keySet().contains('ownerid');
        boolean isAutoNumber = Schema.getGlobalDescribe().get('Medical_Event_vod__c').getDescribe().fields.getMap().get('Name').getDescribe().isAutoNumber();
        if (Trigger.isInsert) {
            for (EM_Event_vod__c emEvent : newEvents) {
                Medical_Event_vod__c newStub = new Medical_Event_vod__c(
                    Description_vod__c = emEvent.Description_vod__c,
                    Location__c = emEvent.Location_vod__c,
                    Start_Time_vod__c = emEvent.Start_Time_vod__c,
                    End_Time_vod__c = emEvent.End_Time_vod__c,
                    Start_Date_vod__c = (emEvent.Start_Time_vod__c != null ? emEvent.Start_Time_vod__c.date() : null),
                    End_Date_vod__c = (emEvent.End_Time_vod__c != null ? emEvent.End_Time_vod__c.date() : null),
                    Mobile_Id_vod__c = emEvent.Stub_Mobile_Id_vod__c,
                    EM_Event_vod__c = emEvent.Id,
                    Event_Display_Name_vod__c = emEvent.Event_Display_Name_vod__c,
                    Walk_In_Fields_vod__c = emEvent.Walk_In_Fields_vod__c,
                    Prescriber_Walk_In_Fields_vod__c = emEvent.Prescriber_Walk_In_Fields_vod__c,
                    Non_Prescriber_Walk_In_Fields_vod__c = emEvent.Non_Prescriber_Walk_In_Fields_vod__c,
                    Other_Walk_In_Fields_vod__c = emEvent.Other_Walk_In_Fields_vod__c,
                    Account_Attendee_Fields_vod__c = emEvent.Account_Attendee_Fields_vod__c,
                    User_Attendee_Fields_vod__c = emEvent.User_Attendee_Fields_vod__c,
                    Contact_Attendee_Fields_vod__c = emEvent.Contact_Attendee_Fields_vod__c,
                    Override_Lock_vod__c = true,
                    Country_vod__c = emEvent.Country_vod__c,
                    Account_vod__c = emEvent.Account_vod__c,
                    Address_vod__c = emEvent.Address_vod__c
                );
                if (!isAutoNumber) {
                    newStub.put('Name', emEvent.Name);
                }
                if (hasOwner) {
                    newStub.put('OwnerId', emEvent.OwnerId);
                }
                
                if (emEvent.Location_vod__c != null && emEvent.Location_vod__c.length() > 40) {
                    newStub.Location__c = emEvent.Location_vod__c.substring(0,40);
                } else {
                    newStub.Location__c = emEvent.Location_vod__c;
                }
                
                if (emEvent.RecordTypeId != null && medEventRTByDeveloperName.get(eventRTById.get(emEvent.RecordTypeId).getDeveloperName()) != null) {
                    newStub.RecordTypeId = medEventRTByDeveloperName.get(eventRTById.get(emEvent.RecordTypeId).getDeveloperName()).getRecordTypeId();
                }
                medEventStubs.add(newStub);
                EM_Event_History_vod__c history = new EM_Event_History_vod__c(
                    Event_vod__c = emEvent.Id,
                    User_vod__c = UserInfo.getUserId(),
                    Action_Datetime_vod__c = System.now(),
                    Action_Type_vod__c = 'Created_vod',
                    Starting_Status_vod__c = emEvent.Status_vod__c
                );
                
                histories.add(history);
            }
            insert medEventStubs;
            insert histories;

        } else if (Trigger.isUpdate && !VOD_Utils.isTriggerMedicalEvent()) {
            Map<String, EM_Event_vod__c> emEventMap = new Map<String, EM_Event_vod__c>();
            for (EM_Event_vod__c emEvent : newEvents) {
                emEventMap.put(emEvent.Id, emEvent);
            }
            List<Medical_Event_vod__c> eventStubs = new List<Medical_Event_vod__c>();
            String events = '';
            for (String key : emEventMap.keySet()) {
                if (events.length() > 0) {
                    events += ',';
                }
                events += '\'' + key + '\'';
            }
            
            Set<Id> changedEventIds = new Set<Id>();
                
            Set<String> changeFields = new Set<String>();
            changeFields.add('Description_vod__c');
            changeFields.add('Location_vod__c');
            changeFields.add('Start_Time_vod__c');
            changeFields.add('End_Time_vod__c');
            changeFields.add('Event_Display_Name_vod__c');
            changeFields.add('Walk_In_Fields_vod__c');
            changeFields.add('Prescriber_Walk_In_Fields_vod__c');
            changeFields.add('Non_Prescriber_Walk_In_Fields_vod__c');
            changeFields.add('Other_Walk_In_Fields_vod__c');
            changeFields.add('Account_Attendee_Fields_vod__c');
            changeFields.add('User_Attendee_Fields_vod__c');
            changeFields.add('Contact_Attendee_Fields_vod__c');
            changeFields.add('Name');
            changeFields.add('OwnerId');
            changeFields.add('Location_vod__c');
            changeFields.add('RecordTypeId');
            changeFields.add('Country_vod__c');
            changeFields.add('Status_vod__c');
            changeFields.add('Account_vod__c');
            changeFields.add('Address_vod__c');

            for(EM_Event_vod__c oldEvent: oldEvents) {
                EM_Event_vod__c newEvent = newEventsMap.get(oldEvent.Id);
                for(String field: changeFields){
                    if(newEvent.get(field) != oldEvent.get(field)) {
                        changedEventIds.add(newEvent.Id);
                        break;
                    }
                }
            }

            if(changedEventIds.size() > 0) {
                if (hasOwner) {
                eventStubs = Database.query('SELECT Name, Description_vod__c, Location__c, Start_Time_vod__c, End_Time_vod__c, Start_Date_vod__c, End_Date_vod__c, OwnerId, EM_Event_vod__c ' +
                            'FROM Medical_Event_vod__c ' +
                            'WHERE EM_Event_vod__c IN (' + events + ')');
                } else {
                    eventStubs = Database.query('SELECT Name, Description_vod__c, Location__c, Start_Time_vod__c, End_Time_vod__c, Start_Date_vod__c, End_Date_vod__c, EM_Event_vod__c ' +
                                                'FROM Medical_Event_vod__c ' +
                                                'WHERE EM_Event_vod__c IN (' + events + ')');
            }
    
            }
            for (Medical_Event_vod__c eventStub : eventStubs) {
                EM_Event_vod__c emEvent = emEventMap.get(eventStub.EM_Event_vod__c);
                eventStub.Description_vod__c = emEvent.Description_vod__c;
                eventStub.Location__c = emEvent.Location_vod__c;
                eventStub.Start_Time_vod__c = emEvent.Start_Time_vod__c;
                eventStub.End_Time_vod__c = emEvent.End_Time_vod__c;
                eventStub.Start_Date_vod__c = (emEvent.Start_Time_vod__c != null ? emEvent.Start_Time_vod__c.date() : null);
                eventStub.End_Date_vod__c = (emEvent.End_Time_vod__c != null ? emEvent.End_Time_vod__c.date() : null);
                eventStub.EM_Event_vod__c = emEvent.Id;
                eventStub.Event_Display_Name_vod__c = emEvent.Event_Display_Name_vod__c;
                eventStub.Walk_In_Fields_vod__c = emEvent.Walk_In_Fields_vod__c;
                eventStub.Prescriber_Walk_In_Fields_vod__c = emEvent.Prescriber_Walk_In_Fields_vod__c;
                eventStub.Non_Prescriber_Walk_In_Fields_vod__c = emEvent.Non_Prescriber_Walk_In_Fields_vod__c;
                eventStub.Other_Walk_In_Fields_vod__c = emEvent.Other_Walk_In_Fields_vod__c;
                eventStub.Account_Attendee_Fields_vod__c = emEvent.Account_Attendee_Fields_vod__c;
                eventStub.User_Attendee_Fields_vod__c = emEvent.User_Attendee_Fields_vod__c;
                eventStub.Contact_Attendee_Fields_vod__c = emEvent.Contact_Attendee_Fields_vod__c;
                eventStub.Override_Lock_vod__c = true;
                eventStub.Country_vod__c = emEvent.Country_vod__c;
                eventStub.Account_vod__c = emEvent.Account_vod__c;
                eventStub.Address_vod__c = emEvent.Address_vod__c;

                if (hasOwner) {
                    eventStub.put('OwnerId', emEvent.OwnerId);
                }
                
                if (!isAutoNumber) {
                    eventStub.put('Name', emEvent.Name);
                }
                
                if (emEvent.Location_vod__c != null && emEvent.Location_vod__c.length() > 40) {
                    eventStub.Location__c = emEvent.Location_vod__c.substring(0,40);
                } else {
                    eventStub.Location__c = emEvent.Location_vod__c;
                }
                
                if (emEvent.RecordTypeId != null && medEventRTByDeveloperName.get(eventRTById.get(emEvent.RecordTypeId).getDeveloperName()) != null) {
                    eventStub.RecordTypeId = medEventRTByDeveloperName.get(eventRTById.get(emEvent.RecordTypeId).getDeveloperName()).getRecordTypeId();
                }
                
                medEventStubs.add(eventStub);
            }
            update medEventStubs;
        }
        // Create event materials based on event rule and topic material
        List<EM_Event_Material_vod__c> eventMaterials = new List<EM_Event_Material_vod__c>();
        List<EM_Topic_Material_vod__c> topicMaterials = [SELECT Id, Material_vod__c, Material_vod__r.RecordType.DeveloperName, Topic_vod__c, Email_Template_vod__c, CLM_Presentation_vod__c FROM EM_Topic_Material_vod__c
                                                        WHERE ((Material_vod__c != null AND Material_vod__r.Status_vod__c = 'Approved_vod')
                                                                OR (Email_Template_vod__c != null AND Email_Template_vod__r.Status_vod__c IN ('Approved_vod', 'Staged_vod'))
                                                                OR (CLM_Presentation_vod__c != null AND CLM_Presentation_vod__r.Status_vod__c IN ('Approved_vod', 'Staged_vod', '') AND CLM_Presentation_vod__r.Content_Channel_vod__c != null))
                                                        AND Topic_vod__c IN : topicSet];
        List<EM_Event_Rule_vod__c> eventRules = [SELECT Id, Event_Configuration_vod__c, Country_Override_vod__c, Country_Override_vod__r.Country_vod__c,
                                                Material_vod__c, Material_vod__r.RecordType.DeveloperName, Email_Template_vod__c, CLM_Presentation_vod__c FROM EM_Event_Rule_vod__c
                                                WHERE ((Material_vod__c != null AND Material_vod__r.Status_vod__c = 'Approved_vod')
                                                OR (Email_Template_vod__c != null AND Email_Template_vod__r.Status_vod__c IN ('Approved_vod', 'Staged_vod'))
                                                OR (CLM_Presentation_vod__c != null AND CLM_Presentation_vod__r.Status_vod__c IN ('Approved_vod', 'Staged_vod', '') AND CLM_Presentation_vod__r.Content_Channel_vod__c != null))
                                                AND Event_Configuration_vod__c IN : configSet
                                                AND (Country_Override_vod__c = null OR Country_Override_vod__r.Country_vod__c IN : countrySet)];
        Map<String,Schema.RecordTypeInfo> materialRTByDeveloperName = EM_Event_Material_vod__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
        Map<String, String> materialToRecordType = new Map<String, String>();

        if (Trigger.isInsert) {
            for (EM_Event_vod__c event : newEvents) {
                Set<String> materials = new Set<String>();
                for (EM_Topic_Material_vod__c topicMaterial : topicMaterials) {
                    Boolean hasValidTopic = topicMaterial.Topic_vod__c == event.Topic_vod__c;

                    if (hasValidTopic) {
                        if (topicMaterial.Material_vod__c!= null && !materials.contains(topicMaterial.Material_vod__c)) {
                            EM_Event_Material_vod__c eventMaterial = new EM_Event_Material_vod__c(
                                Material_vod__c = topicMaterial.Material_vod__c,
                                Event_vod__c = event.Id
                            );
                            if (materialRTByDeveloperName.get(topicMaterial.Material_vod__r.RecordType.DeveloperName) != null) {
                                eventMaterial.RecordTypeId = materialRTByDeveloperName.get(topicMaterial.Material_vod__r.RecordType.DeveloperName).getRecordTypeId();
                            }
                            materials.add(topicMaterial.Material_vod__c);
                            eventMaterials.add(eventMaterial);
                        } else if (topicMaterial.Email_Template_vod__c != null && !materials.contains(topicMaterial.Email_Template_vod__c)) {
                            EM_Event_Material_vod__c eventMaterial = new EM_Event_Material_vod__c(
                                Email_Template_vod__c = topicMaterial.Email_Template_vod__c,
                                Event_vod__c = event.Id
                            );
                            Schema.RecordTypeInfo templateRecordType = materialRTByDeveloperName.get('Email_Template_vod');
                            if (templateRecordType != null) {
                                eventMaterial.RecordTypeId = templateRecordType.getRecordTypeId();
                            }
                            materials.add(topicMaterial.Email_Template_vod__c);
                            eventMaterials.add(eventMaterial);
                        }
                        else if (topicMaterial.CLM_Presentation_vod__c != null && !materials.contains(topicMaterial.CLM_Presentation_vod__c)) {
                            EM_Event_Material_vod__c eventMaterial = new EM_Event_Material_vod__c(
                                CLM_Presentation_vod__c = topicMaterial.CLM_Presentation_vod__c,
                                Event_vod__c = event.Id
                            );
                            Schema.RecordTypeInfo templateRecordType = materialRTByDeveloperName.get('CLM_Presentation_vod');
                            if (templateRecordType != null) {
                                eventMaterial.RecordTypeId = templateRecordType.getRecordTypeId();
                            }
                            materials.add(topicMaterial.CLM_Presentation_vod__c);
                            eventMaterials.add(eventMaterial);
                        }
                    }
                }
                for (EM_Event_Rule_vod__c eventRule : eventRules) {
                    Boolean hasValidEventConfiguration = eventRule.Event_Configuration_vod__c == event.Event_Configuration_vod__c;
                    Boolean hasValidCountryOverride = eventRule.Country_Override_vod__c == null || eventRule.Country_Override_vod__r.Country_vod__c == event.Country_vod__c;

                    if(hasValidEventConfiguration && hasValidCountryOverride) {
                        if (eventRule.Material_vod__c != null && !materials.contains(eventRule.Material_vod__c)) {
                            EM_Event_Material_vod__c eventMaterial = new EM_Event_Material_vod__c(
                                Material_vod__c = eventRule.Material_vod__c,
                                Event_vod__c = event.Id
                            );
                            if (materialRTByDeveloperName.get(eventRule.Material_vod__r.RecordType.DeveloperName) != null) {
                                eventMaterial.RecordTypeId = materialRTByDeveloperName.get(eventRule.Material_vod__r.RecordType.DeveloperName).getRecordTypeId();
                            }
                            materials.add(eventRule.Material_vod__c);
                            eventMaterials.add(eventMaterial);
                        }
                        else if (eventRule.Email_Template_vod__c != null && !materials.contains(eventRule.Email_Template_vod__c)) {
                            EM_Event_Material_vod__c eventMaterial = new EM_Event_Material_vod__c(
                                Email_Template_vod__c = eventRule.Email_Template_vod__c,
                                Event_vod__c = event.Id
                            );
                            Schema.RecordTypeInfo templateRecordType = materialRTByDeveloperName.get('Email_Template_vod');
                            if (templateRecordType != null) {
                                eventMaterial.RecordTypeId = templateRecordType.getRecordTypeId();
                            }
                            materials.add(eventRule.Email_Template_vod__c);
                            eventMaterials.add(eventMaterial);
                        }
                        else if (eventRule.CLM_Presentation_vod__c != null && !materials.contains(eventRule.CLM_Presentation_vod__c)) {
                            EM_Event_Material_vod__c eventMaterial = new EM_Event_Material_vod__c(
                                CLM_Presentation_vod__c = eventRule.CLM_Presentation_vod__c,
                                Event_vod__c = event.Id
                            );
                            Schema.RecordTypeInfo templateRecordType = materialRTByDeveloperName.get('CLM_Presentation_vod');
                            if(templateRecordType != null) {
                                eventMaterial.RecordTypeId = templateRecordType.getRecordTypeId();
                            }
                            materials.add(eventRule.CLM_Presentation_vod__c);
                            eventMaterials.add(eventMaterial);
                        }
                    }
                }
            }
        } else {
            List<EM_Event_Material_vod__c> deleteEventMaterials = new List<EM_Event_Material_vod__c>();
            List<EM_Event_Material_vod__c> existingMaterials = [SELECT Id, Event_vod__c, Material_vod__c, Email_Template_vod__c, CLM_Presentation_vod__c, Material_Used_vod__c
                                                                FROM EM_Event_Material_vod__c
                                                                WHERE Event_vod__c IN : newEventsMap.keySet()];
            Map<String, Set<String>> eventToMaterials = new Map<String, Set<String>>();       
            for (EM_Event_Material_vod__c material : existingMaterials) {
                if (eventToMaterials.get(material.Event_vod__c) == null) {
                    eventToMaterials.put(material.Event_vod__c, new Set<String>());
                }
                if(material.Material_vod__c != null) {
                    eventToMaterials.get(material.Event_vod__c).add(material.Material_vod__c);   
                } else if (material.Email_Template_vod__c != null) {
                    eventToMaterials.get(material.Event_vod__c).add(material.Email_Template_vod__c);    
                }
                else if (material.CLM_Presentation_vod__c != null) {
                    eventToMaterials.get(material.Event_vod__c).add(material.CLM_Presentation_vod__c);
                }
            }

            for (EM_Event_vod__c event : newEvents) {
                EM_Event_vod__c oldEvent = oldEventsMap.get(event.Id);
                if (oldEvent.Topic_vod__c == event.Topic_vod__c && oldEvent.Event_Configuration_vod__c == event.Event_Configuration_vod__c) {
                    continue;
                }
                Set<String> materials = new Set<String>();
                Set<String> approvedDocuments = new Set<String>();
                Set<String> clmPresentations = new Set<String>();
                for (EM_Topic_Material_vod__c topicMaterial : topicMaterials) {
                    if (topicMaterial.Topic_vod__c == event.Topic_vod__c) {
                        if(topicMaterial.Material_vod__c != null) {
                            materials.add(topicMaterial.Material_vod__c);
                            materialToRecordType.put(topicMaterial.Material_vod__c, topicMaterial.Material_vod__r.RecordType.DeveloperName);
                        } else if(topicMaterial.Email_Template_vod__c != null) {
                            approvedDocuments.add(topicMaterial.Email_Template_vod__c);
                        }
                        else if(topicMaterial.CLM_Presentation_vod__c != null) {
                            clmPresentations.add(topicMaterial.CLM_Presentation_vod__c);
                        }
                    }
                }
                Set<String> ruleMaterials = new Set<String>();
                Set<String> ruleApprovedDocuments = new Set<String>();
                Set<String> ruleClmPresentations = new Set<String>();
                for (EM_Event_Rule_vod__c eventRule : eventRules) {
                    if (eventRule.Event_Configuration_vod__c == event.Event_Configuration_vod__c &&
                    (eventRule.Country_Override_vod__c == null || eventRule.Country_Override_vod__r.Country_vod__c == event.Country_vod__c)) {
                        if(eventRule.Material_vod__c != null) {
                            ruleMaterials.add(eventRule.Material_vod__c);
                            materialToRecordType.put(eventRule.Material_vod__c, eventRule.Material_vod__r.RecordType.DeveloperName);
                        } else if (eventRule.Email_Template_vod__c != null) {
                            ruleApprovedDocuments.add(eventRule.Email_Template_vod__c);
                        }
                        else if (eventRule.CLM_Presentation_vod__c != null) {
                            ruleClmPresentations.add(eventRule.CLM_Presentation_vod__c);
                        }
                    }
                }

                if (oldEvent.Topic_vod__c != event.Topic_vod__c) {
                    for (String material : materials) {
                        if (eventToMaterials.get(event.Id) == null || !eventToMaterials.get(event.Id).contains(material)) {
                            EM_Event_Material_vod__c eventMaterial = new EM_Event_Material_vod__c(
                                Material_vod__c = material,
                                Event_vod__c = event.Id
                            );
                            String rtDeveloperName = materialToRecordType.get(material);
                            if (rtDeveloperName != null && materialRTByDeveloperName.get(rtDeveloperName) != null) {
                                eventMaterial.RecordTypeId = materialRTByDeveloperName.get(rtDeveloperName).getRecordTypeId();
                            }
                            
                            eventMaterials.add(eventMaterial);
                        }
                    }
                    for(String approvedDocument: approvedDocuments) {
                        if (eventToMaterials.get(event.Id) == null || !eventToMaterials.get(event.Id).contains(approvedDocument)) {
                            EM_Event_Material_vod__c eventMaterial = new EM_Event_Material_vod__c(
                                Email_Template_vod__c = approvedDocument,
                                Event_vod__c = event.Id
                            );
                            
                            Schema.RecordTypeInfo templateRecordType = materialRTByDeveloperName.get('Email_Template_vod');
                            if (templateRecordType != null) {
                                eventMaterial.RecordTypeId = templateRecordType.getRecordTypeId();
                            }
                            
                            eventMaterials.add(eventMaterial);
                        }    
                    }
                    for(String clmPresentation: clmPresentations) {
                        if (eventToMaterials.get(event.Id) == null || !eventToMaterials.get(event.Id).contains(clmPresentation)) {
                            EM_Event_Material_vod__c eventMaterial = new EM_Event_Material_vod__c(
                                    CLM_Presentation_vod__c = clmPresentation,
                                    Event_vod__c = event.Id
                            );

                            Schema.RecordTypeInfo templateRecordType = materialRTByDeveloperName.get('CLM_Presentation_vod');
                            if (templateRecordType != null) {
                                eventMaterial.RecordTypeId = templateRecordType.getRecordTypeId();
                            }

                            eventMaterials.add(eventMaterial);
                        }
                    }
                }
                if (oldEvent.Event_Configuration_vod__c != event.Event_Configuration_vod__c || oldEvent.Country_vod__c != event.Country_vod__c) {
                    for (String material : ruleMaterials) {
                        if (eventToMaterials.get(event.Id) == null || !eventToMaterials.get(event.Id).contains(material)) {
                            EM_Event_Material_vod__c eventMaterial = new EM_Event_Material_vod__c(
                                Material_vod__c = material,
                                Event_vod__c = event.Id
                            );
                            String rtDeveloperName = materialToRecordType.get(material);
                            if (rtDeveloperName != null && materialRTByDeveloperName.get(rtDeveloperName) != null) {
                                eventMaterial.RecordTypeId = materialRTByDeveloperName.get(rtDeveloperName).getRecordTypeId();
                            }
                            
                            eventMaterials.add(eventMaterial);
                        }
                    }
                    for(String approvedDocument: ruleApprovedDocuments) {
                        if (eventToMaterials.get(event.Id) == null || !eventToMaterials.get(event.Id).contains(approvedDocument)) {
                            EM_Event_Material_vod__c eventMaterial = new EM_Event_Material_vod__c(
                                Email_Template_vod__c = approvedDocument,
                                Event_vod__c = event.Id
                            );
                            
                            Schema.RecordTypeInfo templateRecordType = materialRTByDeveloperName.get('Email_Template_vod');
                            if (templateRecordType != null) {
                                eventMaterial.RecordTypeId = templateRecordType.getRecordTypeId();
                            }
                            
                            eventMaterials.add(eventMaterial);
                        }    
                    }
                    for(String clmPresentation: ruleClmPresentations) {
                        if (eventToMaterials.get(event.Id) == null || !eventToMaterials.get(event.Id).contains(clmPresentation)) {
                            EM_Event_Material_vod__c eventMaterial = new EM_Event_Material_vod__c(
                                    CLM_Presentation_vod__c = clmPresentation,
                                    Event_vod__c = event.Id
                            );

                            Schema.RecordTypeInfo templateRecordType = materialRTByDeveloperName.get('CLM_Presentation_vod');
                            if (templateRecordType != null) {
                                eventMaterial.RecordTypeId = templateRecordType.getRecordTypeId();
                            }

                            eventMaterials.add(eventMaterial);
                        }
                    }
                }

                for (EM_Event_Material_vod__c material : existingMaterials) {
                    if (material.Event_vod__c == event.Id && !material.Material_Used_vod__c &&
                            ((material.Material_vod__c != null && !materials.contains(material.Material_vod__c) && !ruleMaterials.contains(material.Material_vod__c)) ||
                            (material.Email_Template_vod__c != null && !approvedDocuments.contains(material.Email_Template_vod__c) && !ruleApprovedDocuments.contains(material.Email_Template_vod__c)) ||
                            (material.CLM_Presentation_vod__c != null && !clmPresentations.contains(material.CLM_Presentation_vod__c) && !ruleClmPresentations.contains(material.CLM_Presentation_vod__c)))) {
                        deleteEventMaterials.add(material);
                    }
                }
            }
            if (!deleteEventMaterials.isEmpty()) {
                delete deleteEventMaterials;
            }
        }

        if (!eventMaterials.isEmpty()) {
            insert eventMaterials;
        }
    }

    private void vodEmEventBeforeDel() {
        for (Medical_Event_vod__c[] deleteEventStubs :
            [SELECT Id FROM Medical_Event_vod__c 
            WHERE EM_Event_vod__c IN :oldEventsMap.keySet()]) {
            try {
                delete deleteEventStubs;
            } catch (System.DmlException e) {
                Integer numErrors = e.getNumDml();
                String error = '';
                for (Integer i = 0; i < numErrors; i++) {
                    Id thisId = e.getDmlId(i);
                    if (thisId != null)  {
                            error += e.getDmlMessage(i) +'\n';
                    }
                }
        
                for (EM_Event_vod__c errorRec : oldEvents) {
                    errorRec.Id.addError(error);    
                }   
                        
            }
        }
    }

    private void vodEmEventLock() {
        if (Trigger.isInsert || Trigger.isUpdate) {
            for (EM_Event_vod__c newEvent : newEvents) {
                if (newEvent.Override_Lock_vod__c == true) {
                    newEvent.Override_Lock_vod__c = false;
                } else if (VOD_Utils.isEventLocked(newEvent)) {
                // Need to check old version to allow for lock button
                    for (EM_Event_vod__c oldEvent : oldEvents) {
                        if (oldEvent.Id.equals(newEvent.Id) &&
                            VOD_Utils.isEventLocked(oldEvent)) {
                            newEvent.addError('Event is locked');
                        }
                    }
                }
            }
        } else {
            for (EM_Event_vod__c event : oldEvents) {
                if (VOD_Utils.isEventLocked(event)) {
                    event.addError('Event is locked');
                }
            }
        }
    }

    private void vodEventUpdate() {
        List<String> closedEvents = new List<String>();

        Map<Id, EM_Event_vod__c> eventMap = new Map<Id, EM_Event_vod__c>([SELECT Id, Webinar_Status_vod__c FROM EM_Event_vod__c WHERE Id IN :newEventsMap.keySet()]);
        for (EM_Event_vod__c newEvent : newEvents) {
            EM_Event_vod__c oldEvent = oldEventsMap.get(newEvent.Id);

            if (VOD_EVENT_TRIG.isChangedHostOnScheduledWebinar(newEvent, oldEvent, eventMap.get(newEvent.Id))) {
                newEvent.addError('You cannot change the host for an already scheduled webinar.');
                continue;
            }

            if ((newEvent.Status_vod__c == 'Closed_vod' && oldEvent.Status_vod__c != 'Closed_vod') || (newEvent.Status_vod__c == 'Canceled_vod' && oldEvent.Status_vod__c != 'Canceled_vod')) {
                closedEvents.add(newEvent.Id);
            }
        }

        if (closedEvents.size() > 0) {
            List<EM_Event_Budget_vod__c> eventBudgets = [Select Id, Event_vod__c, Actual_vod__c, Committed_vod__c, Estimate_vod__c, Budget_vod__c
                                                        FROM EM_Event_Budget_vod__c WHERE Event_vod__c IN :closedEvents];
            List<EM_Event_Budget_vod__c> eventBudgetsToUpdate = new List<EM_Event_Budget_vod__c>();

            Map<Id, List<EM_Event_Budget_vod__c>> eventToEventBudgets = new Map<Id, List<EM_Event_Budget_vod__c>>();
            for (EM_Event_Budget_vod__c eventBudget : eventBudgets) {
                if (eventToEventBudgets.get(eventBudget.Event_vod__c) == null) {
                    eventToEventBudgets.put(eventBudget.Event_vod__c, new List<EM_Event_Budget_vod__c>());
                }
                eventToEventBudgets.get(eventBudget.Event_vod__c).add(eventBudget);
            }

            List<EM_Event_Speaker_vod__c> eventSpeakers = [SELECT Id, Event_vod__c, Speaker_vod__c
                                                        FROM EM_Event_Speaker_vod__c WHERE Event_vod__c IN :newEventsMap.keySet()];
            Set<Id> speakersToUpdate = new Set<Id>();
            Map<Id, Set<Id>> eventToSpeakers = new Map<Id, Set<Id>>();
            for (EM_Event_Speaker_vod__c eventSpeaker : eventSpeakers) {
                if (eventToSpeakers.get(eventSpeaker.Event_vod__c) == null) {
                    eventToSpeakers.put(eventSpeaker.Event_vod__c, new Set<Id>());
                }
                eventToSpeakers.get(eventSpeaker.Event_vod__c).add(eventSpeaker.Speaker_vod__c);
            }

            Map<Id, List<EM_Event_History_vod__c>> eventToEventHistories = new Map<Id, List<EM_Event_History_vod__c>>();

            List<EventBudgetRollup> budgetRollups = new List<EventBudgetRollup>();
            for (EM_Event_vod__c newEvent : newEvents) {
                EM_Event_vod__c oldEvent = oldEventsMap.get(newEvent.Id);
                if((newEvent.Status_vod__c == 'Closed_vod' || newEvent.Status_vod__c == 'Canceled_vod') && (oldEvent.Status_vod__c != 'Closed_vod' || oldEvent.Status_vod__c != 'Canceled_vod')) {

                    if(eventToSpeakers.get(newEvent.Id) != null) {
                        speakersToUpdate.addAll(eventToSpeakers.get(newEvent.Id));
                    }

                    List<EM_Event_Budget_vod__c> budgets = eventToEventBudgets.get(newEvent.Id);
                    if (budgets != null) {
                        for(EM_Event_Budget_vod__c eventBudget : budgets) {
                            Decimal actual = eventBudget.Actual_vod__c == null ? 0 : eventBudget.Actual_vod__c;
                            Decimal committed = eventBudget.Committed_vod__c == null ? 0 : eventBudget.Committed_vod__c;
                            Decimal estimated = eventBudget.Estimate_vod__c == null ? 0 : eventBudget.Estimate_vod__c;
                            Decimal committedDifference = actual - committed;
                            Decimal estimatedDifference = actual - estimated;
                            eventBudget.Committed_vod__c = actual;
                            eventBudget.Estimate_vod__c = actual;
                            eventBudget.Override_Lock_vod__c = true;
                            eventBudgetsToUpdate.add(eventBudget);

                            System.debug('Actual: ' + actual +
                                    ' Committed: ' + committed +
                                    ' Estimated: ' + estimated +
                                    ' Budget: ' + eventBudget.Budget_vod__c);

                            if(eventBudget.Budget_vod__c != null) {
                                EventBudgetRollup budgetRollup = new EventBudgetRollup();
                                budgetRollup.commitedDifference = committedDifference;
                                budgetRollup.estimatedDifference = estimatedDifference;
                                budgetRollup.budgetId = eventBudget.Budget_vod__c;
                                budgetRollups.add(budgetRollup);
                            }
                        }
                    }
                }
            }
            VOD_EVENT_TRIG.rollUptoBudgetBulk(budgetRollups);

            if(!speakersToUpdate.isEmpty()) {
                SpeakerYTDCalculator.calculate(speakersToUpdate);
            }

            if (!eventBudgetsToUpdate.isEmpty()) {
                update eventBudgetsToUpdate;
            }
        }
    }
}