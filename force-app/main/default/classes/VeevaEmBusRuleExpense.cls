/******************************************************************************
 *
 *               Confidentiality Information:
 *
 * This module is the confidential and proprietary information of
 * Veeva Systems, Inc.; it is not to be copied, reproduced, or transmitted
 * in any form, by any means, in whole or in part, nor is it to be used
 * for any purpose other than that for which it is expressly provided
 * without the written permission of Veeva Systems, Inc.
 *
 * Copyright (c) 2021 Veeva Systems, Inc.  All Rights Reserved.
 *
 *******************************************************************************/

/**
 * VeevaEmBusRuleExpense checks expense rule violation by event expense and business rules.
 *
 */
@RestResource(urlMapping='/veeva/business-rule-expenses')
global without sharing class VeevaEmBusRuleExpense{

    private static final Set<String> PER_EVENT_EXPENSE_TYPES = new Set<String>{'EM_Per_Event_Expense_Limit_Rule_vod', 'EM_Per_Event_Attendee_Expense_Limit_Rule_vod', 'EM_Actual_Versus_Estimate_Expense_Threshold_Rule_vod'};
    private static final Set<String> PER_ATTENDEE_EXPENSE_TYPES = new Set<String>{'EM_Attendee_Expense_Cap_Rule_vod', 'EM_Per_Event_Attendee_Expense_Limit_Rule_vod', 'EM_Cross_Event_Attendee_Expense_Cap_Rule_vod'};
    private static final Set<String> ATTENDEE_CAP_EXPENSE_TYPES = new Set<String>{'EM_Attendee_Expense_Cap_Rule_vod', 'EM_Cross_Event_Attendee_Expense_Cap_Rule_vod'};
    private static final String ESTIMATE = 'Estimate_vod';
    private static final String ACTUAL = 'Actual_vod';
    private static final String SEPARATOR = ';;';
    private static final String EVENT_RELATIONSHIP = 'Event_vod__r';

    @HttpPost
    global static ExpenseResult processExpenseRules() {
      
        ExpenseResult expenseResult = new ExpenseResult();
        RestResponse res = RestContext.response;
        if (RestContext.request.requestBody != null) {
            try{
                String requestBodyStr = RestContext.request.requestBody.toString();
                ExpenseRequest expenseRequest = (ExpenseRequest) JSON.deserialize(requestBodyStr, ExpenseRequest.class);
                validateRequest(expenseRequest);
                enrichExpenseRequestBefore(expenseRequest);
                List<VeevaEmBusRuleModel.BusinessRule> rules = VeevaEmBusRuleModel.getBusinessRules(expenseRequest.ruleIds, 
                                                                                                              expenseRequest.eventType,
                                                                                                              expenseRequest.country,
                                                                                                              expenseRequest.startTime);
                enrichExpenseRequestAfter(rules, expenseRequest);
                expenseResult = getRuleViolation(rules, expenseRequest);  
            } catch (VeevaEmBusRuleModel.BadDataException be) {
                expenseResult.success = false;
                expenseResult.errorMessage = be.getMessage();
                res.statusCode = 400;
            } catch (Exception e) {
                expenseResult.success = false;
                expenseResult.errorMessage = e.getMessage();
                res.statusCode = 500;
            }
        } else {
            expenseResult.success = false;
            expenseResult.errorMessage = 'Request body is null';
            res.statusCode = 400;
        }
        
        return expenseResult;
    }
    
    private static void validateRequest(ExpenseRequest expenseRequest) {
        if (String.isEmpty(expenseRequest.eventId)) {
            throw new VeevaEmBusRuleModel.BadDataException('Event Id in request is not valid');
        }

        Set<String> ruleIds = expenseRequest.ruleIds;
        if (ruleIds.isEmpty()) {
            throw new VeevaEmBusRuleModel.BadDataException('Rule Id list is empty in request');
        }

        if (ruleIds.size() > VeevaEmBusRuleUtils.RULE_COUNT_LIMIT) {
            throw new VeevaEmBusRuleModel.BadDataException('Running more than ' + VeevaEmBusRuleUtils.RULE_COUNT_LIMIT + ' rules is not supported');
        }
    }
    
    private static List<ExpenseAttributionRequest> getAttributionRequest(ExpenseRequest expenseRequest){ 
        List<ExpenseAttributionRequest> allAttributions = new List<ExpenseAttributionRequest>();
        if(expenseRequest.expenseLines != null && !expenseRequest.expenseLines.isEmpty()){
            for (ExpenseLineRequest line : expenseRequest.expenseLines){
                List<ExpenseAttributionRequest> attributions = line.expenseAttribution;
                if(attributions != null && !attributions.isEmpty()){
                    allAttributions.addAll(attributions);
                }
            }
        } 
        return allAttributions;
    }
    
    private static void enrichExpenseRequestBefore(ExpenseRequest expenseRequest) {
        EM_Event_vod__c event = [SELECT RecordTypeId, Country_vod__c, Start_Time_vod__c FROM EM_Event_vod__c WHERE Id = :expenseRequest.eventId];
        expenseRequest.startTime = event.Start_Time_vod__c;
        expenseRequest.eventType = VeevaEmBusRuleUtils.getDeveloperName(Schema.SObjectType.EM_Event_vod__c.getRecordTypeInfosById(), event.RecordTypeId);
        expenseRequest.country = event.Country_vod__c;
    }
    
    private static boolean hasAttendee(ExpenseRequest expenseRequest, List<String> eventAttendeeIds){
        boolean hasAttendee = true;
        if(String.isEmpty(expenseRequest.eventAction) && expenseRequest.expenseLines != null && !expenseRequest.expenseLines.isEmpty()
           && eventAttendeeIds.size() == 0){
               hasAttendee = false;
        }
        return hasAttendee;
    }
    private static List<EM_Attendee_vod__c> getEventAttendees(ExpenseRequest expenseRequest, List<String> eventAttendeeIds){
        //come from presave without attendee info
        if(!expenseRequest.hasAttendee){
            return null;
        }
        String eventAttendeesQuery = 'SELECT Id, Account_vod__c, User_vod__c, Contact_vod__c, Attendee_Account_Type_vod__c, Status_vod__c, '          
            + ' First_Name_vod__c, Last_Name_vod__c, Attendee_Name_vod__c,'                     
            + ' Event_vod__r.RecordTypeId, Event_vod__r.Country_vod__c, Event_vod__r.Start_Time_vod__c, Event_vod__r.Topic_vod__c'                       
            + ' FROM EM_Attendee_vod__c WHERE Event_vod__c = \'' + expenseRequest.eventId + '\'';
        if(eventAttendeeIds.size() > 0) {
            eventAttendeesQuery += ' AND Id IN ' + VeevaEmBusRuleUtils.toCommaSeparated(eventAttendeeIds);
        }else if(String.isNotEmpty(expenseRequest.expenseHeaderId)) {
            eventAttendeesQuery += ' AND Id IN (SELECT Incurred_Expense_Attendee_vod__c FROM Expense_Attribution_vod__c WHERE Expense_Line_vod__r.Expense_Header_vod__c = \'' + expenseRequest.expenseHeaderId + '\')';
        }
        return Database.query(eventAttendeesQuery);
    }
    
    private static void enrichExpenseRequestAfter(List<VeevaEmBusRuleModel.BusinessRule> rules, ExpenseRequest expenseRequest) {
        //data from memory
        List<sObject> queryRowFromPreSave = new List<sObject>();
        Map<String, List<sObject>> rowFromPreSaveMap = new Map<String, List<sObject>>();
        Set<String> attributionIds = new Set<String>();
        Map<String, String> eventAttendeeKeys = new Map<String, String>();
        List<ExpenseAttributionRequest> attributions = getAttributionRequest(expenseRequest);
        List<String> eventAttendeeIds = new List<String>();
        for (ExpenseAttributionRequest attribution : attributions){
            attributionIds.add(attribution.Id);
            if(String.isNotEmpty(attribution.attendee)){
                eventAttendeeIds.add(attribution.attendee);  
            }
        }
        expenseRequest.attributionIds = attributionIds;
        List<String> expenseTypeIds = new List<String>();
            
        for (VeevaEmBusRuleModel.BusinessRule rule : rules){   
            expenseTypeIds.add(rule.expenseType);
        }
        Map<String, Set<String>> expenseTypeRelationMap = new Map<String, Set<String>>();
        Map<String, String> expenseTypeNameMap = new Map<String, String>();
        Map<String, String> parentExpenseTypeMap = new Map<String, String>();
        for(Expense_Type_vod__c expenseType : [SELECT Id, Name, (SELECT Id, Name FROM Parent_Expense_Type_vod__r), Parent_Expense_Type_vod__c FROM Expense_Type_vod__c WHERE Id IN : expenseTypeIds]){
            String expenseTypeId = expenseType.Id;
            expenseTypeNameMap.put(expenseTypeId, expenseType.Name);
            String parentExpenseTypeId = (String)expenseType.get('Parent_Expense_Type_vod__c');
            if (parentExpenseTypeId != null) {
                parentExpenseTypeMap.put(expenseTypeId, parentExpenseTypeId);
            }
            List<SObject> childExpenseTypes = expenseType.getSObjects('Parent_Expense_Type_vod__r');
            if(childExpenseTypes != null && childExpenseTypes.size() > 0){   
                Set<String> childExpenseTypeIds = new Set<String>();
                for(SObject childExpenseType : childExpenseTypes){
                    expenseTypeNameMap.put(childExpenseType.Id, (String)childExpenseType.get('Name'));
                    childExpenseTypeIds.add(childExpenseType.Id);
                }
                expenseTypeRelationMap.put(expenseTypeId, childExpenseTypeIds);
            }else{
                expenseTypeRelationMap.put(expenseTypeId, new Set<String>());
            }
        }
        expenseRequest.expenseTypeMap = expenseTypeRelationMap;
        expenseRequest.parentExpenseTypeMap = parentExpenseTypeMap;
        expenseRequest.expenseTypeNameMap = expenseTypeNameMap;
        expenseRequest.hasAttendee  = hasAttendee(expenseRequest, eventAttendeeIds);
        if(!hasRuleType(rules, PER_ATTENDEE_EXPENSE_TYPES)){
            return;
        }
        Map<String, String> attendeeKeyMap = new Map<String, String>();
        List<EM_Attendee_vod__c> eventAttendees = getEventAttendees(expenseRequest, eventAttendeeIds);
        Map<String, RuleAttendee> ruleAttendees = new Map<String, RuleAttendee>();
        if (eventAttendees != null && !eventAttendees.isEmpty()) {  
            Set<String> accountIds = new Set<String>();
            Set<String> userIds = new Set<String>();
            Set<String> contactIds = new Set<String>();
            for (EM_Attendee_vod__c attendee : eventAttendees) {
                String attendeeId;
                if (attendee.Account_vod__c != null) {
                    attendeeId = attendee.Account_vod__c;
                    accountIds.add(attendee.Account_vod__c);
                }
                if (attendee.User_vod__c != null) {
                    attendeeId = attendee.User_vod__c;
                    userIds.add(attendee.User_vod__c);
                }
                if (attendee.Contact_vod__c != null) {
                    attendeeId = attendee.Contact_vod__c;
                    contactIds.add(attendee.Contact_vod__c);
                }
                if (String.isNotBlank(attendeeId)) {
                    eventAttendeeKeys.put(attendee.Id, attendeeId);
                    attendeeKeyMap.put(attendeeId, attendee.Id);
                }
                if (!ruleAttendees.containsKey(attendeeId)) { 
                    RuleAttendee ruleAttendee = new RuleAttendee(attendeeId, null, null);
                    ruleAttendee.attendeeName = attendee.Attendee_Name_vod__c;
                    ruleAttendee.attendeeAccountType = attendee.Attendee_Account_Type_vod__c;
                    ruleAttendee.attendeeFirstName = attendee.First_Name_vod__c;
                    ruleAttendee.attendeeLastName = attendee.Last_Name_vod__c;
                    ruleAttendees.put(attendeeId, ruleAttendee);
                }
            }
            String groupKey;
            //key is account id or user id or contact id
            Map<String, List<ExpenseAttributionRequest>> preSaveAttributionMap = new Map<String, List<ExpenseAttributionRequest>>();
            Map<String, ExpenseAttributionRequest> attendeeAttributionMap = new Map<String, ExpenseAttributionRequest>();
            for (ExpenseAttributionRequest attribution : attributions){
                if(String.isNotBlank(attribution.attendee)){ 
                    groupKey = attribution.expenseType + attribution.currencyIsoCode + attribution.attendee;
                    if(attendeeAttributionMap.get(groupKey) == null){
                        attendeeAttributionMap.put(groupKey, attribution);
                    }else{
                        attendeeAttributionMap.get(groupKey).actual += attribution.actual;
                    }
                } 
            }
            if(attendeeAttributionMap.size() > 0){
                for (String key : attendeeAttributionMap.keySet()){
                    ExpenseAttributionRequest groupAttribution = attendeeAttributionMap.get(key);
                    if(preSaveAttributionMap.get(eventAttendeeKeys.get(groupAttribution.attendee)) == null){
                        List<ExpenseAttributionRequest> preSaveData = new List<ExpenseAttributionRequest>();
                        preSaveData.add(groupAttribution);
                        preSaveAttributionMap.put(eventAttendeeKeys.get(groupAttribution.attendee), preSaveData);
                    }else{
                        preSaveAttributionMap.get(eventAttendeeKeys.get(groupAttribution.attendee)).add(groupAttribution);
                    }
                }
            }
            expenseRequest.accountIds = accountIds;
            expenseRequest.userIds = userIds;
            expenseRequest.contactIds = contactIds;
            expenseRequest.ruleAttendees = ruleAttendees;
            expenseRequest.attendeeKeyMap = attendeeKeyMap;
            expenseRequest.eventAttendeeKeys = eventAttendeeKeys;
            if(preSaveAttributionMap.size() > 0){
                expenseRequest.preSaveAttributionMap = preSaveAttributionMap;   
            }
        } 
    }
    
    private static String getParentExpenseType(String expenseType, ExpenseRequest expenseRequest){
        String result;
        Map<String, Set<String>> expenseTypeMap = expenseRequest.expenseTypeMap;
        if(expenseTypeMap != null && expenseTypeMap.size() > 0){
            for (String parentExpenseType : expenseTypeMap.keySet()){
                Set<String> childExpenseTypes = expenseTypeMap.get(parentExpenseType);
                if(childExpenseTypes.contains(expenseType)){
                    result = parentExpenseType;
                    break;
                }   
            }            
        }
        return result;
    }
    
    private static void addAttributionExpenseTypes(List<ExpenseAttributionRequest> attributions, Set<String> expenseTypes, ExpenseRequest expenseRequest) {
        for(ExpenseAttributionRequest attribution : attributions) {
            addTypeAndParentType(attribution.expenseType, expenseTypes, expenseRequest);
        }
    }

    private static void queryAndAddExpenseTypesForHeader(String expenseHeaderId, Set<String> expenseTypes, ExpenseRequest expenseRequest) {
        for(Expense_Line_vod__c line : [SELECT Expense_Type_vod__c FROM Expense_Line_vod__c WHERE Expense_Type_vod__c !=null AND Expense_Header_vod__c = : expenseHeaderId]) {
            addTypeAndParentType(line.Expense_Type_vod__c, expenseTypes, expenseRequest); 
        } 
    }

    private static void addTypeAndParentType(String expenseType, Set<String> expenseTypes, ExpenseRequest expenseRequest) {
        if(!expenseTypes.contains(expenseType)){
            expenseTypes.add(expenseType);
            String parentExpenseType = getParentExpenseType(expenseType, expenseRequest);
            if(String.isNotEmpty(parentExpenseType)){
                expenseTypes.add(parentExpenseType);
            }
        } 
    }
        
    private static Set<String> getExpenseTypes(String expenseHeaderId, ExpenseRequest expenseRequest){     
        Set<String> expenseTypes = new Set<String>();  
        List<ExpenseAttributionRequest> attributions = getAttributionRequest(expenseRequest);
        if (attributions != null && attributions.size() > 0) {    
            addAttributionExpenseTypes(attributions, expenseTypes, expenseRequest);  
        }else{
            queryAndAddExpenseTypesForHeader(expenseHeaderId, expenseTypes, expenseRequest);
        }
        return expenseTypes;
    }
    
    private static List<VeevaEmBusRuleModel.BusinessRule> filterBusinessRules(ExpenseRequest expenseRequest, List<VeevaEmBusRuleModel.BusinessRule> businessRules){
        List<VeevaEmBusRuleModel.BusinessRule> validRules = new List<VeevaEmBusRuleModel.BusinessRule>();
        Set<String> expenseTypes = getExpenseTypes(expenseRequest.expenseHeaderId, expenseRequest);
        if(expenseTypes.size() > 0){
            for(VeevaEmBusRuleModel.BusinessRule rule : businessRules){                
                if(String.isEmpty(rule.expenseType) || expenseTypes.contains(rule.expenseType)){
                    validRules.add(rule);
                }
            } 
        }else{
            validRules = businessRules;
        }
        return validRules;
    }
    
    private static List<String> replaceFieldInIdClauseBatch(List<String> idClauseBatch){
        List<String> newIdClauseBatch = new List<String>();
        if(idClauseBatch != null && idClauseBatch.size() > 0){
            String prefix = 'Incurred_Expense_Attendee_vod__r.';
            for(String idClause : idClauseBatch){
                idClause = idClause.replace(VeevaEmBusRuleUtils.ATTENDEE_ACCOUNT, prefix + VeevaEmBusRuleUtils.ATTENDEE_ACCOUNT)
                    .replace(VeevaEmBusRuleUtils.ATTENDEE_USER, prefix + VeevaEmBusRuleUtils.ATTENDEE_USER)
                    .replace(VeevaEmBusRuleUtils.ATTENDEE_CONTACT, prefix + VeevaEmBusRuleUtils.ATTENDEE_CONTACT);
                newIdClauseBatch.add(idClause);
            }
        }
        return newIdClauseBatch;
    }

    private static ExpenseResult getRuleViolation(List<VeevaEmBusRuleModel.BusinessRule> businessRules, ExpenseRequest expenseRequest) {
        List<ExpenseViolation> ruleViolations = new List<ExpenseViolation>();
        if(String.isEmpty(expenseRequest.eventAction)){
            businessRules = filterBusinessRules(expenseRequest, businessRules);
        }
        EventExpenseData expenseData; 
        if(hasRuleType(businessRules, PER_EVENT_EXPENSE_TYPES)){
            //query current event expense related info accordingly
            expenseData = getCurrentEventExpenseData(expenseRequest, businessRules);
        }
        Map<String, RuleAttendee> ruleAttendees = new Map<String, RuleAttendee>();
        if(expenseRequest.ruleAttendees != null && !expenseRequest.ruleAttendees.isEmpty()){
            ruleAttendees = expenseRequest.ruleAttendees;
        }
        Set<String> accountNameIds = new Set<String>();
        List<String> accounts = new List<String>(expenseRequest.accountIds);
        List<String> users = new List<String>(expenseRequest.userIds);
        List<String> contacts = new List<String>(expenseRequest.contactIds);  
        List<String> idClauseBatch = VeevaEmBusRuleUtils.composeIdCriteria(accounts, users, contacts);
        if (!idClauseBatch.isEmpty() && idClauseBatch.size() * getPerAttendeeRulesCount(businessRules) > VeevaEmBusRuleUtils.RULE_QUERY_LIMIT) {
            throw new VeevaEmBusRuleModel.BadDataException('Running more than ' + VeevaEmBusRuleUtils.RULE_QUERY_LIMIT + ' queries is not supported');      
        } 
        idClauseBatch = replaceFieldInIdClauseBatch(idClauseBatch);
        boolean hasHardWarningViolation = false;
        boolean isEventAction = String.isNotEmpty(expenseRequest.eventAction);
        for (VeevaEmBusRuleModel.BusinessRule rule : businessRules){
            //if it comes from event action, and had hard warning previously, doesn't need to run soft rule
            if(isEventAction && (rule.warningType == 'Soft_Warning_vod') && hasHardWarningViolation){
                break;
            }
            ExpenseViolation violation = null;
            //per event expense rule
            if(isPerEventRule(rule)){  
                violation = getPerEventViolation(rule, expenseData, expenseRequest);
            }
            //per event attendance rule
            else if(isPerEventAttendeeRule(rule)){
                violation = getPerEventAttendeeViolation(rule, expenseData, expenseRequest);
            }
            //expense threshold rule
            else if(isExpensesThresholdRule(rule)){
                violation = getExpensesThresholdViolation(rule, expenseData, expenseRequest);
            }
            if(violation != null){
                ruleViolations.add(violation);
            }
            //per attendee expense rules
            if(isAttendeeCapRule(rule)){
                List<ExpenseViolation> attendeeCapViolations = getAttendeeCapViolations(rule, expenseRequest, idClauseBatch, ruleAttendees);
                if(attendeeCapViolations.size() > 0){
                    ruleViolations.addAll(attendeeCapViolations);
                }
            }
            if((rule.warningType == 'Hard_Warning_vod')  && (ruleViolations.size() > 0)){
                hasHardWarningViolation = true;
            }
        }
        ExpenseResult expenseResult = new ExpenseResult();
        expenseResult.success = true;
        expenseResult.ruleViolations = ruleViolations;
        expenseResult.ruleAttendees = ruleAttendees;
        expenseResult = filterOverrideRule(expenseData, expenseResult, businessRules);
        if(isEventAction){
           createEventHistory(expenseRequest, expenseResult, businessRules); 
        }
        return expenseResult;
    }
    
    private static void dealWithQueryResult(List<sObject> queryRows, Set<String> accountNameIds, Map<String, List<sObject>> queryMap, Map<String, RuleAttendee> ruleAttendees){
        for(sObject queryRow : queryRows){
            String accountId = (String)queryRow.get('Account_vod__c');
            String userId = (String)queryRow.get('User_vod__c');
            String contactId = (String)queryRow.get('Contact_vod__c');
            if (String.isNotBlank(accountId)) {
                accountNameIds.add(accountId);
            }  
            String attendeeId = VeevaEmBusRuleUtils.getAttendeeId(accountId, userId, contactId);
            if(queryMap.get(attendeeId) == null){
                List<sObject> queryObject = new List<sObject>();
                queryObject.add(queryRow);
                queryMap.put(attendeeId, queryObject);
            }else{    
                queryMap.get(attendeeId).add(queryRow);
            }  
            if (!ruleAttendees.containsKey(attendeeId)) {
                RuleAttendee attendee = new RuleAttendee(accountId, userId, contactId);
                attendee.attendeeName = (String)queryRow.get('Attendee_Name_vod__c');
                attendee.attendeeFirstName = (String)queryRow.get('First_Name_vod__c'); 
                attendee.attendeeLastName = (String)queryRow.get('Last_Name_vod__c');
                ruleAttendees.put(attendeeId, attendee);
            }
        }
    }
 
    private static String currentEventQuery(VeevaEmBusRuleModel.BusinessRule rule, String batch, ExpenseRequest expenseRequest){
        //fetch the data from current event
        String query = getQuerySelect() + ' FROM Expense_Attribution_vod__c WHERE '; 
        query += getAttendeeAndExpenseTypeQuery(rule, batch, expenseRequest);
        if(String.isNotEmpty(expenseRequest.expenseHeaderId) && expenseRequest.attributionIds != null && !expenseRequest.attributionIds.isEmpty()){ 
            query += ' AND Expense_Line_vod__r.Expense_Header_vod__c != \'' + expenseRequest.expenseHeaderId + '\'';
              
        }
        query += ' AND Expense_Line_vod__r.Event_vod__c = \'' + expenseRequest.eventId + '\''; 
        query += getQueryGroupBy();
        return query;
    }
    
    private static List<ExpenseViolation> getAttendeeCapViolations(VeevaEmBusRuleModel.BusinessRule rule, ExpenseRequest expenseRequest, List<String> idClauseBatch, Map<String, RuleAttendee> ruleAttendees){
        List<ExpenseViolation> ruleViolations = new List<ExpenseViolation>();
        String ruleQuery = composeQuery(rule, expenseRequest);
        Set<String> accountNameIds = new Set<String>();
        Map<String, List<sObject>> queryMap = new Map<String, List<sObject>>();
        for (String batch : idClauseBatch) {
            if (String.isBlank(batch)) {
                continue;
            }   
            //all matched data according to rule definition, exclude current Event
            String query = composeBatchQuery(rule, ruleQuery, batch, expenseRequest);
            List<sObject> queryRows = Database.query(query);
            //current Event expense data
            String currentEventQuery = currentEventQuery(rule, batch, expenseRequest);
            List<sObject> currentExpenseRows = Database.query(currentEventQuery);
            if(currentExpenseRows.size() > 0){
                queryRows.addAll(currentExpenseRows);
            }
            dealWithQueryResult(queryRows, accountNameIds, queryMap, ruleAttendees);
        }
        Map<String, List<ExpenseAttributionRequest>> preSaveDataMap = expenseRequest.preSaveAttributionMap;
        // preSave case
        if(preSaveDataMap != null && preSaveDataMap.size() >0){
            List<ExpenseViolation> preSaveViolations = getViolationsFromPreSave(rule, expenseRequest, ruleAttendees, preSaveDataMap, queryMap, accountNameIds);   
            if(preSaveViolations != null && preSaveViolations.size() > 0){
                ruleViolations.addAll(preSaveViolations);    
            }  
        }else{
            //all data come from db
            List<ExpenseViolation> dbViolations = getViolationsFromDB(rule, expenseRequest, ruleAttendees, queryMap);
            if(dbViolations != null && dbViolations.size() > 0){      
                ruleViolations.addAll(dbViolations); 
            }   
        }
        convertAttendeeName(accountNameIds, ruleAttendees);
        return ruleViolations;
    }
    
    private static List<ExpenseViolation> getViolationsFromDB(VeevaEmBusRuleModel.BusinessRule rule, ExpenseRequest expenseRequest, Map<String, RuleAttendee> ruleAttendees, Map<String, List<sObject>> queryMap){
        List<ExpenseViolation> ruleViolations = new List<ExpenseViolation>();
        if(!queryMap.isEmpty()){
            for (String attendeeId : queryMap.keySet()){
                ExpenseViolation violation = null;
                List<sObject> queryObjects = queryMap.get(attendeeId);
                Decimal matchedAmount = 0;
                String eventAttendeeId;           
                for (sObject queryRow : queryObjects){              
                    if(expenseRequest.attendeeKeyMap != null){         
                        eventAttendeeId = expenseRequest.attendeeKeyMap.get(attendeeId);        
                    }     
                    if(MultiCurrencyUtil.isMultiCurrencyOrg()){
                        matchedAmount += MultiCurrencyUtil.convertCurrency((String)queryRow.get('CurrencyIsoCode'), rule.currencyIsoCode, (Decimal)queryRow.get('Total'));
                    }else{
                        matchedAmount += (Decimal)queryRow.get('Total');         
                    }      
                }
                boolean matchedRule = matchSpendLimit(rule, matchedAmount);
                if(matchedRule){
                    violation = getViolation(rule.id, ruleAttendees, attendeeId, eventAttendeeId, matchedAmount);     
                }   
                if(violation != null){
                    ruleViolations.add(violation);
                }     
            }    
        } 
        return ruleViolations;
    }
    
    private static List<ExpenseViolation> getViolationsFromPreSave(VeevaEmBusRuleModel.BusinessRule rule, ExpenseRequest expenseRequest
                                                , Map<String, RuleAttendee> ruleAttendees, Map<String, List<ExpenseAttributionRequest>> preSaveDataMap
                                                , Map<String, List<sObject>> queryMap, Set<String> accountNameIds){
        List<ExpenseViolation> ruleViolations = new List<ExpenseViolation>();
        for (String attendeeId : preSaveDataMap.keySet()){
            ExpenseViolation violation = null;
            if (String.isNotBlank(attendeeId)) {
                accountNameIds.add(attendeeId);    
            }           
            List<sObject> queryObjects = queryMap.get(attendeeId);
            Decimal matchedAmount = 0;
            //from db excluded preSave data
            if(queryObjects != null && !queryObjects.isEmpty()){                    
                for (sObject queryRow : queryObjects){            
                    if(MultiCurrencyUtil.isMultiCurrencyOrg()){             
                        matchedAmount += MultiCurrencyUtil.convertCurrency((String)queryRow.get('CurrencyIsoCode'), rule.currencyIsoCode, (Decimal)queryRow.get('Total'));      
                    }else{      
                        matchedAmount += (Decimal)queryRow.get('Total');       
                    }      
                }       
            }          
            List<ExpenseAttributionRequest> preSaveObjects = preSaveDataMap.get(attendeeId);
            //from preSave data
            String eventAttendeeId;
            for (ExpenseAttributionRequest preSaveData : preSaveObjects){
                eventAttendeeId = preSaveData.attendee;
                Map<String, Set<String>> expenseTypeMap = expenseRequest.expenseTypeMap;
                boolean isExpenseTypeMatch = false;
                if(String.isEmpty(rule.expenseType)
                   || (rule.expenseType.equals(preSaveData.expenseType)
                       || expenseTypeMap.get(rule.expenseType).contains(preSaveData.expenseType))){
                           isExpenseTypeMatch = true;                    
                }   
                if(isExpenseTypeMatch){
                    if(MultiCurrencyUtil.isMultiCurrencyOrg()){
                        matchedAmount += MultiCurrencyUtil.convertCurrency(preSaveData.currencyIsoCode, rule.currencyIsoCode, preSaveData.actual);       
                    }else{        
                        matchedAmount += preSaveData.actual;      
                    }      
                }       
            }         
            boolean matchedRule = matchSpendLimit(rule, matchedAmount);
            if(matchedRule){
                violation = getViolation(rule.id, ruleAttendees, attendeeId, eventAttendeeId, matchedAmount);
            }
            if(violation != null){
                ruleViolations.add(violation);     
            }       
        }
        return ruleViolations;  
    }
    
    private static void createEventHistory(ExpenseRequest expenseRequest, ExpenseResult expenseResult, List<VeevaEmBusRuleModel.BusinessRule> rules){
        Map<String, VeevaEmBusRuleModel.BusinessRule> ruleMap = new Map<String, VeevaEmBusRuleModel.BusinessRule>();
        if(rules != null && rules.size() > 0){
            for(VeevaEmBusRuleModel.BusinessRule rule : rules){
                ruleMap.put(rule.Id, rule);
            }
        }
        List<ExpenseViolation> ruleViolations = expenseResult.ruleViolations;
        RecordTypeInfo recordType = Schema.SObjectType.EM_Event_History_vod__c.getRecordTypeInfosByDeveloperName().get('EM_Business_Rule_History_vod');
        if(ruleViolations !=null && ruleViolations.size() > 0){
            List<EM_Event_History_vod__c> histories = new List<EM_Event_History_vod__c>();
            for(ExpenseViolation violation : ruleViolations) {
                EM_Event_History_vod__c history = new EM_Event_History_vod__c();
                if(recordType != null){
                   history.RecordTypeId = recordType.getRecordTypeId(); 
                }
                history.Action_Type_vod__c = 'EM_Business_Rule_Execution_vod';
                history.Action_Datetime_vod__c = DateTime.now();
                history.Platform_vod__c = expenseRequest.platform;
                history.User_vod__c = UserInfo.getUserId();
                history.Run_Rule_Type__c = 'Run_Rule_on_Event_Action_vod';
                history.Event_vod__c = expenseRequest.eventId;
                history.Event_Action_vod__c = expenseRequest.eventAction;
                VeevaEmBusRuleModel.BusinessRule rule = ruleMap.get(violation.ruleId);
                if(rule != null){
                    history.EM_Business_Rule_Id_vod__c = rule.businessRuleId;
                    history.EM_Business_Rule_Configuration_Id_vod__c = rule.getConfigurationId(expenseRequest.eventType, expenseRequest.country); 
                    history.Warning_Type_vod__c = rule.warningType;
                    history.EM_Business_Rule_Type_vod__c = rule.recordTypeId;
                    history.Expense_Type_vod__c = rule.expenseType;
                }
                RuleAttendee attendee = getRuleAttendee(expenseResult, violation.attendeeId);
                if(attendee != null){
                    history.EM_Attendee_Account_vod__c = attendee.accountId;
                    history.EM_Attendee_User_vod__c = attendee.userId;
                    history.EM_Attendee_Contact_vod__c = attendee.contactId;
                }
                List<String> violatedIds = violation.violatedIds;
                if(violatedIds != null && violatedIds.size() > 0){
                     String violatedId = String.join(violatedIds, ',');
                    history.Record_Violated_ID_vod__c = violatedId;
                }
                history.Record_Violated_Name_vod__c = violation.violatedName;
                histories.add(history);
            }
            try {
                String message = VeevaEmBusRuleUtils.insertObjects(histories, VeevaEmBusRuleUtils.OPT_ALL_OR_NONE);
                if (String.isNotBlank(message)) {
                    expenseResult.eventHistoryMessage = message;
                }
            } catch (Exception e) {
                expenseResult.eventHistoryMessage = e.getMessage();
            }
        }
    }
    
    private static RuleAttendee getRuleAttendee(ExpenseResult expenseResult, String attendeeId){
        RuleAttendee attendee = null;
        if(expenseResult.ruleAttendees != null && !expenseResult.ruleAttendees.isEmpty()){
            attendee = expenseResult.ruleAttendees.get(attendeeId);
        }
        return attendee;
    }

    private static expenseResult filterOverrideRule(EventExpenseData expenseData, ExpenseResult expenseResult, List<VeevaEmBusRuleModel.BusinessRule> rules){
        if(expenseResult.success){
            Map<String, VeevaEmBusRuleModel.BusinessRule> ruleMap = new Map<String, VeevaEmBusRuleModel.BusinessRule>();
            for(VeevaEmBusRuleModel.BusinessRule rule : rules){
                ruleMap.put(rule.Id, rule);
            }
            List<ExpenseViolation> ruleViolations = expenseResult.ruleViolations;
            List<ExpenseViolation> validRuleViolations = new List<ExpenseViolation>();
            String currencySign;
            if (!MultiCurrencyUtil.isMultiCurrencyOrg()) {
               currencySign = ConnectApi.Organization.getSettings().UserSettings.currencySymbol; 
            }
            for(ExpenseViolation violation : ruleViolations){
                Map<String, RuleAttendee> ruleAttendees = expenseResult.ruleAttendees;
                RuleAttendee attendee = ruleAttendees.get(violation.attendeeId);
                if(isValidViolation(expenseData, attendee, ruleMap, violation, ruleViolations)){
                    VeevaEmBusRuleModel.BusinessRule rule = ruleMap.get(violation.ruleId);
                    String currencyIsoCode = rule.currencyIsoCode;
                    if (MultiCurrencyUtil.isMultiCurrencyOrg()) {
                        currencySign = currencyIsoCode != null ? currencyIsoCode : UserInfo.getDefaultCurrency();
                    }
                    violation.matchedAmount = currencySign + ' ' + violation.matchedAmount;
                    validRuleViolations.add(violation); 
                }
            }
            expenseResult.ruleViolations = validRuleViolations;
        }
        return expenseResult;
    }
    
    private static boolean isAccountTypeValid(VeevaEmBusRuleModel.BusinessRule rule, RuleAttendee attendee, Map<String, VeevaEmBusRuleModel.BusinessRule> ruleMap, List<ExpenseViolation> allViolations){
        boolean isAccountTypeValid = true;
        List<String> attendeeAccountOverrideRuleTypes = new List<String>{'EM_Per_Event_Attendee_Expense_Limit_Rule_vod', 'EM_Attendee_Expense_Cap_Rule_vod', 'EM_Cross_Event_Attendee_Expense_Cap_Rule_vod'};
        if (attendeeAccountOverrideRuleTypes.contains(rule.developerName) && attendee != null) {
            String attendeeAccountType = attendee.attendeeAccountType;
            String ruleAccountType = rule.attendeeAccountType;
            if (String.isBlank(attendeeAccountType)) {
                isAccountTypeValid = String.isBlank(ruleAccountType);
            }else{
                if (String.isBlank(ruleAccountType)) {
                    String key = getRuleKey(rule);
                    // remove the violation if other rule violation match the same key and contains the attendee account type
                    for (ExpenseViolation eachViolation : allViolations) {
                        VeevaEmBusRuleModel.BusinessRule eachRule = ruleMap.get(eachViolation.ruleId);
                        String type = eachRule.attendeeAccountType;
                        if (key == getRuleKey(eachRule) && String.isNotBlank(type) && type.split(SEPARATOR).contains(attendeeAccountType)) {
                            isAccountTypeValid = false;
                            break;
                        }
                    }
                } else {
                    isAccountTypeValid = ruleAccountType.split(SEPARATOR).contains(attendeeAccountType);
                }
            }
        }
        return isAccountTypeValid;
    }
    
    private static boolean isEventStatusValid(VeevaEmBusRuleModel.BusinessRule rule, EventExpenseData expenseData, Map<String, VeevaEmBusRuleModel.BusinessRule> ruleMap, List<ExpenseViolation> allViolations){
        boolean isEventStatusValid = true;
        List<String> eventStatusOverrideRuleTypes = new List<String>{'EM_Per_Event_Expense_Limit_Rule_vod' ,'EM_Per_Event_Attendee_Expense_Limit_Rule_vod'};
        if(eventStatusOverrideRuleTypes.contains(rule.developerName)){
            String eventStatus = expenseData.status;
            String ruleEventStatus = rule.eventStatus;
            if (String.isBlank(ruleEventStatus)) {
                String key = getRuleKey(rule);
                // remove the violation if other rule violation match the same key and contains the event status
                for (ExpenseViolation eachViolation : allViolations) {
                    VeevaEmBusRuleModel.BusinessRule eachRule = ruleMap.get(eachViolation.ruleId);
                    String status = eachRule.eventStatus; 
                    if (key == getRuleKey(eachRule) && String.isNotBlank(status) && status.split(SEPARATOR).contains(eventStatus)) {
                        isEventStatusValid = false;
                        break;
                    }
                } 
            } else { 
                isEventStatusValid = ruleEventStatus.split(SEPARATOR).contains(eventStatus);
            }
        }
        return isEventStatusValid;
    }
    
    private static boolean isValidViolation(EventExpenseData expenseData, RuleAttendee attendee, Map<String, VeevaEmBusRuleModel.BusinessRule> ruleMap, ExpenseViolation violation, List<ExpenseViolation> allViolations) {
        VeevaEmBusRuleModel.BusinessRule rule = ruleMap.get(violation.ruleId);
        return isAccountTypeValid(rule, attendee, ruleMap, allViolations) && isEventStatusValid(rule, expenseData, ruleMap, allViolations);
    }
    
    private static String getRuleKey(VeevaEmBusRuleModel.BusinessRule rule) {
        return rule.developerName + rule.warningType + rule.expenseType;
    }
    
    private static ExpenseViolation getViolation(String ruleId, Map<String, RuleAttendee> ruleAttendees, String attendeeId, String eventAttendeeId, Decimal matchedAmount){  
        ExpenseViolation violation = new ExpenseViolation();                                
        violation.matchedAmount = matchedAmount.format();
        violation.ruleId = ruleId;
        violation.attendeeId = attendeeId;
        violation.violatedIds = new List<String>{eventAttendeeId};
        if(ruleAttendees != null && !ruleAttendees.isEmpty()){
            RuleAttendee attendee = ruleAttendees.get(attendeeId);
            if(attendee != null){
                violation.violatedName = attendee.attendeeName;
            }
        }
        return violation;
    }
    
    private static boolean matchSpendLimit(VeevaEmBusRuleModel.BusinessRule rule, Decimal matchedAmount){
        boolean matchRule = false;
        double minimumSpend = rule.minimumSpendLimit;
        double maximumSpend = rule.maximumSpendLimit;
        if(minimumSpend != null){
            matchRule = matchedAmount < minimumSpend;
        }
        if(!matchRule && maximumSpend != null){         
            matchRule = matchedAmount > maximumSpend;
        }
        return matchRule;
    }
    
    private static void convertAttendeeName(Set<String> accountNameIds, Map<String, RuleAttendee> ruleAttendees) {
        if (VeevaSettings.isEnableAccountParentDisplay() && !accountNameIds.isEmpty() && !ruleAttendees.isEmpty()) {
            List<Account> accounts = [SELECT Id, Formatted_Name_vod__c, Primary_Parent_vod__r.Formatted_Name_vod__c FROM Account WHERE Id IN :accountNameIds];
            for (Account account : accounts) {
                String id = account.Id;
                if (ruleAttendees.containsKey(id)) {
                    String name = account.Formatted_Name_vod__c;
                    if (account.Primary_Parent_vod__r != null) {
                        name += ' @ ' + account.Primary_Parent_vod__r.Formatted_Name_vod__c;
                    }
                    RuleAttendee ruleAttendee = ruleAttendees.get(id);
                    ruleAttendee.attendeeName = name;
                }
            }
        }
    }
    
    private static ExpenseViolation getMatchedAmountByEstimate(VeevaEmBusRuleModel.BusinessRule rule, EventExpenseData expenseData, ExpenseRequest expenseRequest){
        double matchedAmount = 0;
        String expenseType = rule.expenseType;
        
        List<ExpenseDataObject> expenseEstimates = expenseData.expenseEstimates;
            
        expenseEstimates = getValidRows(rule, expenseEstimates, expenseRequest);
        
        double totalAmount = 0;
        boolean matchRule = false;
        List<String> violatedIds = new List<String>();
        if(expenseEstimates != null && expenseEstimates.size() > 0){
            for (ExpenseDataObject row : expenseEstimates) {
                ExpenseEstimate estimateRow = (ExpenseEstimate)row;
                violatedIds.add(estimateRow.id);
                totalAmount += toRuleAmount(estimateRow.currencyIsoCode, rule.currencyIsoCode, estimateRow.estimate);        
            }        
            double estimateAttendance = expenseData.estimatedAttendance;
            if(estimateAttendance != null){
                matchedAmount = totalAmount / estimateAttendance;
                matchRule = matchSpendLimit(rule, matchedAmount);
            }
        }
        
        ExpenseViolation violation = null;
        if(matchRule){
            violation = getViolation(rule, null, expenseRequest.expenseTypeNameMap, matchedAmount, violatedIds);
        }  
        return violation;
    }
    
    private static ExpenseViolation getViolation(VeevaEmBusRuleModel.BusinessRule rule, String attendeeId, Map<String, String> expenseTypeNameMap, double matchedAmount, List<String> violatedIds){
        ExpenseViolation violation = new ExpenseViolation();
        violation.matchedAmount = matchedAmount.format();
        violation.ruleId = rule.id;        
        violation.violatedIds = violatedIds;
        violation.attendeeId = attendeeId;
        if(String.isNotEmpty(rule.expenseType) && expenseTypeNameMap != null && !expenseTypeNameMap.isEmpty()){                       
            violation.violatedName = expenseTypeNameMap.get(rule.expenseType);     
        }
        return violation;
    }
    
    private static List<ExpenseAttribution> getValidAttributions(List<ExpenseDataObject> expenseLines){
        List<ExpenseAttribution> validData = new List<ExpenseAttribution>();
        if(expenseLines == null || expenseLines.size() == 0){
            return validData;
        }
        for (ExpenseDataObject lineDataObject : expenseLines) {
            ExpenseLine lineRow = (ExpenseLine)lineDataObject;
            List<ExpenseAttribution> expenseAttribution = lineRow.expenseAttribution;
            if(expenseAttribution != null && expenseAttribution.size() > 0){
               validData.addAll(expenseAttribution); 
            }
        }
        return validData;
    }
    
    private static ExpenseViolation getMatchedAmountByActual(VeevaEmBusRuleModel.BusinessRule rule, EventExpenseData expenseData, ExpenseRequest expenseRequest){
        double matchedAmount = 0;
        List<ExpenseDataObject> expenseLines = expenseData.expenseLines;
        expenseLines = getValidRows(rule, expenseLines, expenseRequest);
        Map<String, List<ExpenseAttribution>> attributionPerHead = new Map<String, List<ExpenseAttribution>>();
        ExpenseViolation violation = null;
        if(expenseLines == null || expenseLines.size() == 0){
            return violation;
        }
        List<String> violatedIds = new List<String>();
        for (ExpenseDataObject lineDataObject : expenseLines) {
            ExpenseLine lineRow = (ExpenseLine)lineDataObject;
            violatedIds.add(lineRow.id);
        }
        List<ExpenseAttribution> expenseAttributions = getValidAttributions(expenseLines);
        List<EventAttendee> validAttendees = getValidAttendees(rule, expenseData.attendees);
        if(expenseAttributions != null && expenseAttributions.size() > 0){
            for (ExpenseAttribution attributionRow : expenseAttributions) {
                if(isValidAttendee(validAttendees, attributionRow.attendee)){
                    matchedAmount += toRuleAmount(attributionRow.currencyIsoCode, rule.currencyIsoCode, attributionRow.actual);
                    if(attributionPerHead.get(attributionRow.attendee) == null){
                        List<ExpenseAttribution> perHead = new List<ExpenseAttribution>();
                        perHead.add(attributionRow);
                        attributionPerHead.put(attributionRow.attendee, perHead);
                    }else{ 
                        attributionPerHead.get(attributionRow.attendee).add(attributionRow);
                    } 
                } 
            } 
        }
        for(String attendee : attributionPerHead.keySet()){
            double matchedAmountPerHead = 0;
            List<ExpenseAttribution> perHeadAttribution = attributionPerHead.get(attendee);
            for (ExpenseAttribution attributionRow : perHeadAttribution) {   
                matchedAmountPerHead += toRuleAmount(attributionRow.currencyIsoCode, rule.currencyIsoCode, attributionRow.actual);
            } 
            boolean matchRule = matchSpendLimit(rule, matchedAmountPerHead);
            if(matchRule){
                String attendeeId;
                if(expenseRequest.eventAttendeeKeys != null && expenseRequest.eventAttendeeKeys.size() > 0){
                    attendeeId = expenseRequest.eventAttendeeKeys.get(attendee);
                }
                violation = getViolation(rule, attendeeId, expenseRequest.expenseTypeNameMap, matchedAmountPerHead, violatedIds);
                break;
            }
        }
        return violation;
    }
    
    private static ExpenseViolation getPerEventAttendeeViolation(VeevaEmBusRuleModel.BusinessRule rule, EventExpenseData expenseData, ExpenseRequest expenseRequest){
        boolean matchRule = verifyEventStatus(rule, expenseData);
        double matchedAmount = 0;
        ExpenseViolation violation = null;
        if(matchRule){
            if(ESTIMATE.equals(rule.expenseCategory)){
                violation = getMatchedAmountByEstimate(rule, expenseData, expenseRequest);
            }
            if(ACTUAL.equals(rule.expenseCategory)){
                violation = getMatchedAmountByActual(rule, expenseData, expenseRequest);
            }
        }
        return violation;
    }
    
    private static List<EventAttendee> getValidAttendees(VeevaEmBusRuleModel.BusinessRule rule, List<EventAttendee> attendees){
        String accountType = rule.attendeeAccountType;
        List<EventAttendee> validAttendees = new List<EventAttendee>();
        //If Attendee Account Type is not defined in the rule, then the rule applies to all EM Attendees, regardless of value in <Attendee_Account_Type_vod> field
        if(attendees != null && !attendees.isEmpty()){
            //the EM Attendee records associated with the event where <Attendee_Account_Type_vod>  of the EM Attendee record matches the <Attendee_Account_Type_vod> defined in the Rule
            for (EventAttendee row : attendees) {
                if(matchRuleValue(row.accountType, accountType)){
                    validAttendees.add(row);
                }
            }
        }
        return validAttendees;
    }
    
    private static ExpenseViolation getExpensesThresholdViolation(VeevaEmBusRuleModel.BusinessRule rule, EventExpenseData expenseData, ExpenseRequest expenseRequest){
        double matchedAmount = 0;
        double estimateAmount = 0;
        List<ExpenseDataObject> expenseEstimates = expenseData.expenseEstimates;
        expenseEstimates = getValidRows(rule, expenseEstimates, expenseRequest);
        List<ExpenseDataObject> expenseLines = expenseData.expenseLines;
        expenseLines = getValidRows(rule, expenseLines, expenseRequest);
        boolean matchRule = false;
        List<String> violatedIds = new List<String>();
        if(expenseEstimates != null && expenseEstimates.size() > 0 && expenseLines != null && expenseLines.size() > 0){
            for (ExpenseDataObject row : expenseEstimates) {
                ExpenseEstimate estimateRow = (ExpenseEstimate)row;
                estimateAmount += toRuleAmount(estimateRow.currencyIsoCode, rule.currencyIsoCode, estimateRow.estimate);
            }
            for (ExpenseDataObject row : expenseLines) { 
                ExpenseLine lineRow = (ExpenseLine)row;
                violatedIds.add(lineRow.id);
                matchedAmount += toRuleAmount(lineRow.currencyIsoCode, rule.currencyIsoCode, lineRow.actual);
            }
            if(estimateAmount != 0){
                double percent = ((matchedAmount - estimateAmount) / estimateAmount) * 100;
                matchRule = percent > rule.percentThreshold;
            }
        }
        ExpenseViolation violation = null;
        if(matchRule){
            violation = getViolation(rule, null, expenseRequest.expenseTypeNameMap, matchedAmount, violatedIds);
        }
        return violation;
    }
    
    private static ExpenseViolation getPerEventViolation(VeevaEmBusRuleModel.BusinessRule rule, EventExpenseData expenseData, ExpenseRequest expenseRequest){
        boolean matchRule = verifyEventStatus(rule, expenseData);
        double matchedAmount = 0;
        List<String> violatedIds = new List<String>();
        if(matchRule){
            if(ESTIMATE.equals(rule.expenseCategory)){
                List<ExpenseDataObject> expenseEstimates = expenseData.expenseEstimates;
                expenseEstimates = getValidRows(rule, expenseEstimates, expenseRequest);
                if(expenseEstimates != null && expenseEstimates.size() > 0){
                    for (ExpenseDataObject row : expenseEstimates) {
                        violatedIds.add(row.id);
                        ExpenseEstimate estimateRow = (ExpenseEstimate)row;
                        matchedAmount += toRuleAmount(row.currencyIsoCode, rule.currencyIsoCode, estimateRow.estimate);
                    }
                    matchRule = matchSpendLimit(rule, matchedAmount);
                }else{
                    matchRule = false;
                }
                
            }
            if(ACTUAL.equals(rule.expenseCategory)){
                List<ExpenseDataObject> expenseLines = expenseData.expenseLines;
                expenseLines = getValidRows(rule, expenseLines, expenseRequest);
                if(expenseLines != null && expenseLines.size() > 0){
                    for (ExpenseDataObject row : expenseLines) {
                        violatedIds.add(row.id);
                        matchedAmount += toRuleAmount(row.currencyIsoCode, rule.currencyIsoCode, row.actual);
                    } 
                    matchRule = matchSpendLimit(rule, matchedAmount);
                }else{
                    matchRule = false;
                }
            }
        }
        ExpenseViolation violation = null;
        if(matchRule){
            violation = getViolation(rule, null, expenseRequest.expenseTypeNameMap, matchedAmount, violatedIds);
        }
        return violation;
    }
    
    private static boolean isValidAttendee(List<EventAttendee> attendeeRows, String attendeeId){
        boolean isValid = false;
        for (EventAttendee row : attendeeRows) {
            if(row.id.equals(attendeeId)){
                isValid = true;
                break;
            }
        }
        return isValid;
    }
    
    private static boolean isRuleParentExpenseType(String rowExpenseType, String ruleExpenseType, Map<String, String> parentExpenseTypeMap) {
        if (parentExpenseTypeMap == null || rowExpenseType == null) {
            return false;
        }
        return rowExpenseType.equals(parentExpenseTypeMap.get(ruleExpenseType));
    }

    private static List<ExpenseDataObject> getValidRows(VeevaEmBusRuleModel.BusinessRule rule, List<ExpenseDataObject> rows, ExpenseRequest expenseRequest){
        String ruleExpenseType = rule.expenseType;
        List<ExpenseDataObject> validRows = new List<ExpenseDataObject>();
        //If Expense Type is not defined in the rule, then the rule applies to all rows regardless of <Expense_Type_vod> value
        if(ruleExpenseType != null){
            if(rows != null && rows.size() > 0){
                for (ExpenseDataObject row : rows) {
                    Map<String, Set<String>> expenseTypeMap = expenseRequest.expenseTypeMap;
                    String rowExpenseType = row.expenseType;
                    if (ruleExpenseType.equals(rowExpenseType)
                        || (isExpensesThresholdRule(rule) && isRuleParentExpenseType(rowExpenseType, ruleExpenseType, expenseRequest.parentExpenseTypeMap))
                        || (expenseTypeMap.get(ruleExpenseType) != null && expenseTypeMap.get(ruleExpenseType).contains(rowExpenseType))) {
                        validRows.add(row);
                    }
                }
            }
        }else{
            validRows = rows;
        }
        return validRows;
    }
    
    private static double toRuleAmount(String fromIsoCode, String toIsoCode, double amount){
        if(!MultiCurrencyUtil.isMultiCurrencyOrg()){
            return amount;
        }
        return MultiCurrencyUtil.convertCurrency(fromIsoCode, toIsoCode, amount);
    }

    private static boolean hasRuleType(List<VeevaEmBusRuleModel.BusinessRule> rules, Set<String> ruleTypes) {
        boolean result = false;
        for (VeevaEmBusRuleModel.BusinessRule rule : rules) {
            if(ruleTypes.contains(rule.developerName)) {
                result = true;
                break;
            }
        }
        return result;
    }
     
    private static boolean isPerEventRule(VeevaEmBusRuleModel.BusinessRule rule) {
        return 'EM_Per_Event_Expense_Limit_Rule_vod'.equals(rule.developerName);
    }
    
    private static boolean isPerEventAttendeeRule(VeevaEmBusRuleModel.BusinessRule rule) {
        return 'EM_Per_Event_Attendee_Expense_Limit_Rule_vod'.equals(rule.developerName);
    }
    
    private static boolean isExpensesThresholdRule(VeevaEmBusRuleModel.BusinessRule rule) {
        return 'EM_Actual_Versus_Estimate_Expense_Threshold_Rule_vod'.equals(rule.developerName);
    }
     
    private static boolean isAttendeeCapRule(VeevaEmBusRuleModel.BusinessRule rule) {
        return ATTENDEE_CAP_EXPENSE_TYPES.contains(rule.developerName);
    }
    
    private static Integer getPerAttendeeRulesCount(List<VeevaEmBusRuleModel.BusinessRule> rules) {
        Integer count = 0;
        for (VeevaEmBusRuleModel.BusinessRule rule : rules) {
            if (!rule.isPerEventExpenseRule()) {
                count ++;
            }
        }
        return count;
    }
    
    private static boolean verifyEventStatus(VeevaEmBusRuleModel.BusinessRule rule, EventExpenseData expenseData){
        boolean matchRule = true;
        if(rule.eventStatus != null
            && !matchRuleValue(expenseData.status, rule.eventStatus)){
            matchRule = false;
        }
        return matchRule;
    }
    
    private static boolean matchRuleValue(String fieldValue, String ruleFieldValue){
        return (ruleFieldValue == null 
                ||(fieldValue == null && ruleFieldValue == null)
                ||(fieldValue != null && ruleFieldValue != null
                   && ruleFieldValue.split(SEPARATOR).contains(fieldValue)));
    }
    
    private static String getQuerySelect(){
       String querySelect = 'SELECT SUM(Actual_vod__c) Total, Expense_Line_vod__r.Expense_Type_vod__c Expense_Type_vod__c,'
            +' Incurred_Expense_Attendee_vod__r.Account_vod__c Account_vod__c, Incurred_Expense_Attendee_vod__r.User_vod__c User_vod__c,'
            +' Incurred_Expense_Attendee_vod__r.Contact_vod__c Contact_vod__c,'
            +' Incurred_Expense_Attendee_vod__r.First_Name_vod__c First_Name_vod__c, Incurred_Expense_Attendee_vod__r.Last_Name_vod__c Last_Name_vod__c,'
            +' Incurred_Expense_Attendee_vod__r.Attendee_Name_vod__c Attendee_Name_vod__c';
        if(MultiCurrencyUtil.isMultiCurrencyOrg()){
            querySelect += ', CurrencyIsoCode ';
        }
        return querySelect;
    }
    
    private static String getQueryGroupBy(){
        String queryGroupBy = ' GROUP BY Expense_Line_vod__r.Expense_Type_vod__c, Incurred_Expense_Attendee_vod__r.Account_vod__c,'
            +' Incurred_Expense_Attendee_vod__r.User_vod__c, Incurred_Expense_Attendee_vod__r.Contact_vod__c,'
            +' Incurred_Expense_Attendee_vod__r.First_Name_vod__c, Incurred_Expense_Attendee_vod__r.Last_Name_vod__c,'
            +' Incurred_Expense_Attendee_vod__r.Attendee_Name_vod__c';
        if(MultiCurrencyUtil.isMultiCurrencyOrg()){
            queryGroupBy += ', CurrencyIsoCode ';
        }
        return queryGroupBy;
    }
    
    private static String composeQuery(VeevaEmBusRuleModel.BusinessRule rule, ExpenseRequest expenseRequest) {
        String query = getQuerySelect();
        Datetime startTime = expenseRequest.startTime;
        Datetime minDatetime; 
        Datetime maxDatetime;
        switch on rule.dateThresholdType {
            when 'Rolling_vod' {
                minDatetime = datetime.newInstance(startTime.year(), startTime.month(), startTime.day(), startTime.hour(), startTime.minute(), startTime.second());
                maxDatetime = datetime.newInstance(startTime.year(), startTime.month(), startTime.day(), startTime.hour(), startTime.minute(), startTime.second());
                Integer rollingPeriod = rule.rollingPeriod;
                minDatetime = minDatetime.addDays(rollingPeriod * (-1));
                maxDatetime = maxDatetime.addDays(rollingPeriod);
            } 
            when 'Calendar_Month_vod' {
                minDatetime = datetime.newInstance(startTime.year(), startTime.month(), 1, 0, 0, 0);
                maxDatetime = datetime.newInstance(startTime.year(), startTime.month(), 1, 0, 0, 0);
                maxDatetime = maxDatetime.addMonths(1);
            }
            when 'Calendar_Year_vod' {
                minDatetime = datetime.newInstance(startTime.year(), 1, 1, 0, 0, 0);
                maxDatetime = datetime.newInstance(startTime.year() + 1, 1, 1, 0, 0, 0);
            }
        }
        String datetimeFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
        String formattedMin = minDateTime.formatGmt(datetimeFormat);
        String formattedMax = maxDatetime.formatGmt(datetimeFormat);
        query += ' FROM Expense_Attribution_vod__c WHERE Incurred_Expense_Attendee_vod__c IN (SELECT Id FROM EM_Attendee_vod__c WHERE ' + EVENT_RELATIONSHIP + '.Start_Time_vod__c >= ' + formattedMin + ' AND ' + EVENT_RELATIONSHIP + '.Start_Time_vod__c < ' + formattedMax;
        String status = composeAttendeeStatusCriteria(rule.getEventAttendeeStatus());
        if (status.length() > 0) {
            query += ' AND (' + status + ')';
        }
        String config = composeEventTypeCountryCriteria(rule.configs);
        if (config.length() > 0) {
            query += ' AND (' + config + ')';
        }
        if (!rule.getAccountTypes().isEmpty()) {
            query += ' AND Attendee_Account_Type_vod__c IN ' + VeevaEmBusRuleUtils.toCommaSeparated(new List<String>(rule.getAccountTypes()));
        }
        query += ' )';
        return query;
    }
    
    private static String getAttendeeAndExpenseTypeQuery(VeevaEmBusRuleModel.BusinessRule rule, String batch, ExpenseRequest expenseRequest){
        String query = ' (' + batch + ')';
        if (String.isNotEmpty(rule.expenseType)) {
            Map<String, Set<String>> expenseTypeMap = expenseRequest.expenseTypeMap;
            List<String> allExpenseTypes = new List<String>();
            allExpenseTypes.add(rule.expenseType);
            if(expenseTypeMap != null && expenseTypeMap.get(rule.expenseType) != null){
                allExpenseTypes.addAll(expenseTypeMap.get(rule.expenseType));
            }
            query += ' AND ( Expense_Line_vod__r.Expense_Type_vod__c  IN ' + VeevaEmBusRuleUtils.toCommaSeparated(allExpenseTypes) + ')';
        }
        return query;
    }
     
    private static String composeBatchQuery(VeevaEmBusRuleModel.BusinessRule rule, String ruleQuery, String batch, ExpenseRequest expenseRequest) {
        String query = ruleQuery;
        query += ' AND ' + getAttendeeAndExpenseTypeQuery(rule, batch, expenseRequest);
        //exclude the data from current event
        query += ' AND ( Expense_Line_vod__r.Event_vod__c != \'' + expenseRequest.eventId + '\')';
        query += getQueryGroupBy();
        
        return query;
    }
    
    private static String composeAttendeeStatusCriteria(Map<String, Set<String>> statusPairs) {
        String query = '';
        Integer i = 0;
        for (String key : statusPairs.keySet()) {
            Set<String> values = statusPairs.get(key);
            if (!values.isEmpty()) {
                if (i > 0) {
                    query += ' OR ';
                }
                query += '(' + EVENT_RELATIONSHIP + '.Status_vod__c = \'' + key + '\' AND Status_vod__c IN '
                    + VeevaEmBusRuleUtils.toCommaSeparated(new List<String>(values)) + ')';
                i++;
            }
        }
        return query;
    }
    
    private static String composeEventTypeCountryCriteria(List<VeevaEmBusRuleModel.BusinessRuleConfig> configs) {
        String query = '';
        Integer i = 0;
        for (VeevaEmBusRuleModel.BusinessRuleConfig config : configs) {
            if (i > 0) {
                query += ' OR ';
            }
            // global rule
            if (String.isBlank(config.country)) {
                query += '(' + EVENT_RELATIONSHIP + '.RecordType.DeveloperName = \'' + config.eventType + '\')';
            } else {
                query += '(' + EVENT_RELATIONSHIP + '.RecordType.DeveloperName = \'' + config.eventType
                    + '\' AND ' + EVENT_RELATIONSHIP + '.Country_vod__c = \'' + config.country + '\')';
            }
            i++;
        }
        return query;
    }
    
    private static EventExpenseData getCurrentEventExpenseData(ExpenseRequest expenseRequest, List<VeevaEmBusRuleModel.BusinessRule> businessRules) {
     
        String eventId = expenseRequest.eventId;
        EventExpenseData eventExpenseData = new EventExpenseData();
        if (eventId != null) {
            EM_Event_vod__c event;
            if(MultiCurrencyUtil.isMultiCurrencyOrg()){
                event = Database.query('SELECT Id,Status_vod__c, Start_Time_vod__c, Estimated_Attendance_vod__c,' 
                                       + '(SELECT Id, Event_vod__c, Actual_vod__c, Expense_Type_vod__c, CurrencyIsoCode FROM Expense_Lines_Event_vod__r),'
                                       + ' (SELECT Id, Attendee_Account_Type_vod__c FROM EM_Attendee_Event_vod__r), '
                                       + ' (SELECT Id, Event_vod__c, Estimate_vod__c, Expense_Type_vod__c, CurrencyIsoCode FROM Expense_Estimate_vod__r)'
                                       + ' FROM EM_Event_vod__c WHERE Id = :eventId ');
            }else{
                event = [SELECT Id,Status_vod__c, Start_Time_vod__c, Estimated_Attendance_vod__c, 
                                     (SELECT Id, Event_vod__c, Actual_vod__c, Expense_Type_vod__c FROM Expense_Lines_Event_vod__r),
                                     (SELECT Id, Attendee_Account_Type_vod__c FROM EM_Attendee_Event_vod__r), 
                                      (SELECT Id, Event_vod__c, Estimate_vod__c, Expense_Type_vod__c FROM Expense_Estimate_vod__r)
                                      FROM EM_Event_vod__c WHERE Id = :eventId];
            }
            eventExpenseData.startTime = event.Start_Time_vod__c;
            eventExpenseData.estimatedAttendance = event.Estimated_Attendance_vod__c;
            eventExpenseData.eventId = event.Id;
            eventExpenseData.status = event.Status_vod__c;
            //all valid expense lines map, key is line id, if presave, expense line should fetched from request
            Map<String, ExpenseLine> expenseLineMap = new Map<String, ExpenseLine>();
            //all valid expense attribution map, key is attribution id, if presave, expense attribution should fetched from request
            Map<String, ExpenseAttribution> attributionMap = new Map<String, ExpenseAttribution>();
           
            List<ExpenseLine> expenseLines = new List<ExpenseLine>();
            //lines from request
            List<ExpenseLineRequest> lineRequests = expenseRequest.expenseLines;
            if(lineRequests != null && lineRequests.size() > 0){
                for(ExpenseLineRequest line : lineRequests){
                    ExpenseLine lineRow = new ExpenseLine();
                    lineRow.actual = line.actual;
                    String expenseType = (String)line.expenseType;
                    lineRow.expenseType = line.expenseType;
                    lineRow.id = line.id;
                    if(MultiCurrencyUtil.isMultiCurrencyOrg()){
                        lineRow.currencyIsoCode = line.currencyIsoCode;
                    }
                    if(String.isNotEmpty(lineRow.id)){
                        expenseLineMap.put(lineRow.id, lineRow);  
                    }else{
                        expenseLines.add(lineRow);
                    }
                    //attribution from request
                    List<ExpenseAttributionRequest> attributionRequests = line.expenseAttribution;
                    if(attributionRequests != null && attributionRequests.size() > 0){
                        List<ExpenseAttribution> requestAttribution = new List<ExpenseAttribution>();
                        for(ExpenseAttributionRequest attribution : attributionRequests){
                            ExpenseAttribution attributionRow = new ExpenseAttribution();
                            attributionRow.expenseLine = attribution.expenseLine;
                            attributionRow.attendee = attribution.attendee;
                            attributionRow.actual = attribution.actual;
                            if(MultiCurrencyUtil.isMultiCurrencyOrg()){
                                attributionRow.currencyIsoCode = attribution.currencyIsoCode;
                            }
                            requestAttribution.add(attributionRow);
                            attributionMap.put(attribution.id, attributionRow);
                        }
                        lineRow.expenseAttribution = requestAttribution;
                    }  
                }  
            }
            if(expenseLineMap.size() > 0){
               expenseLines.addAll(expenseLineMap.values());
            }
            //lines from db
            List<Expense_Line_vod__c> lines = event.getSObjects('Expense_Lines_Event_vod__r');
            List<String> expenseLinesIds = new List<String>();
            if(lines !=null && lines.size() > 0){
               for (Expense_Line_vod__c line : lines){
                   String lineId = line.Id;
                   if(expenseLineMap.get(lineId) == null){
                       expenseLinesIds.add(lineId);
                       ExpenseLine lineRow = new ExpenseLine();
                       double actual = line.Actual_vod__c;
                       lineRow.actual = actual;
                       String expenseType = line.Expense_Type_vod__c;
                       lineRow.expenseType = expenseType;
                       lineRow.id = line.Id;   
                       if(MultiCurrencyUtil.isMultiCurrencyOrg()){
                           lineRow.currencyIsoCode = (String)line.get('CurrencyIsoCode');
                       }
                       expenseLines.add(lineRow);
                   } 
               } 
            }
            eventExpenseData.expenseLines = expenseLines;
            List<EM_Expense_Estimate_vod__c> estimates = event.getSObjects('Expense_Estimate_vod__r');
            List<ExpenseEstimate> estimateLines = new List<ExpenseEstimate>();
            if(estimates != null && !estimates.isEmpty()){
                for (EM_Expense_Estimate_vod__c estimate : estimates){
                    ExpenseEstimate estimateRow = new ExpenseEstimate();
                    double estimateAmount = estimate.Estimate_vod__c;
                    estimateRow.estimate = estimateAmount;
                    String expenseType = estimate.Expense_Type_vod__c;
                    estimateRow.expenseType = expenseType;
                    estimateRow.id = estimate.Id;
                    if(MultiCurrencyUtil.isMultiCurrencyOrg()){
                        estimateRow.currencyIsoCode = (String)estimate.get('CurrencyIsoCode');
                    }
                    estimateLines.add(estimateRow);
               } 
            }         
            eventExpenseData.expenseEstimates = estimateLines;   
            List<EM_Attendee_vod__c> attendees = event.getSObjects('EM_Attendee_Event_vod__r');
            List<EventAttendee> attendeeLines = new List<EventAttendee>();
            if(expenseRequest.hasAttendee && attendees != null && !attendees.isEmpty()){
                for (EM_Attendee_vod__c attendee : attendees){
                    EventAttendee attendeeRow = new EventAttendee();
                    attendeeRow.id = attendee.Id;
                    attendeeRow.accountType = attendee.Attendee_Account_Type_vod__c;
                    attendeeLines.add(attendeeRow);
                }
            }
            eventExpenseData.attendees = attendeeLines;
            List<Expense_Attribution_vod__c> expenseAttributions = new List<Expense_Attribution_vod__c>();
            if(expenseLinesIds !=null && expenseLinesIds.size() > 0){
                if(MultiCurrencyUtil.isMultiCurrencyOrg()){
                    expenseAttributions = Database.query('SELECT Expense_Line_vod__c, Actual_vod__c, Incurred_Expense_Attendee_vod__c, '
                                                         + 'CurrencyIsoCode FROM Expense_Attribution_vod__c WHERE Expense_Line_vod__c IN :expenseLinesIds ') ;
                }else{
                    expenseAttributions = [SELECT Expense_Line_vod__c, Actual_vod__c, Incurred_Expense_Attendee_vod__c FROM Expense_Attribution_vod__c WHERE Expense_Line_vod__c IN : expenseLinesIds];  
                }
            }          
            Map<String, List<ExpenseAttribution>> expenseAttributionMap = new Map<String, List<ExpenseAttribution>>();
            List<ExpenseAttribution> requestAttributions = attributionMap.values();
            //attribution from db
            if(expenseAttributions != null && expenseAttributions.size() > 0){
              for (Expense_Attribution_vod__c attribution : expenseAttributions){
                  ExpenseAttribution attributionRow = new ExpenseAttribution();
                  String expenseLineId = attribution.Expense_Line_vod__c;
                  if(attributionMap.get(expenseLineId) == null){
                      attributionRow.expenseLine = expenseLineId;
                      attributionRow.attendee = attribution.Incurred_Expense_Attendee_vod__c;
                      double actual = attribution.Actual_vod__c;
                      attributionRow.actual = actual;
                      if(MultiCurrencyUtil.isMultiCurrencyOrg()){
                          attributionRow.currencyIsoCode = (String)attribution.get('CurrencyIsoCode');
                      }
                      
                      if(expenseAttributionMap.get(expenseLineId) == null){
                          List<ExpenseAttribution> attributionList = new List<ExpenseAttribution>();
                          attributionList.add(attributionRow);
                          expenseAttributionMap.put(expenseLineId, attributionList);
                      }else{
                          expenseAttributionMap.get(expenseLineId).add(attributionRow);
                      } 
                  }
              }  
            }
            if(eventExpenseData.expenseLines != null && eventExpenseData.expenseLines.size() > 0){
                for (ExpenseLine lineRow : eventExpenseData.expenseLines){
                    String expenseLineId = lineRow.id;
                    if(expenseAttributionMap.get(expenseLineId) != null){
                        lineRow.expenseAttribution = expenseAttributionMap.get(expenseLineId);
                    }
                }
            }
        } 
        return eventExpenseData;
    }
    
    private class EventExpenseData{
        private String eventId;
        private Datetime startTime;
        private double estimatedAttendance;
        private String status;
        private List<ExpenseLine> expenseLines;
        private List<ExpenseEstimate> expenseEstimates;
        private List<EventAttendee> attendees;
    }
    
    private class EventAttendee{
        private String id;
        private String accountType;
    }
    
    private abstract class ExpenseDataObject{
        protected String id;
        protected String expenseType;
        protected String currencyIsoCode;
        protected double actual;
    }

    private class ExpenseEstimate extends ExpenseDataObject{
        private double estimate;
    }

    private class ExpenseLine extends ExpenseDataObject{
        private List<ExpenseAttribution> expenseAttribution;
    }

    private class ExpenseAttribution extends ExpenseDataObject{
        private String expenseLine;
        private String attendee;
    }
    
    private class ExpenseAttributionRequest{
        private String id;
        private String expenseType;
        private String currencyIsoCode;
        private double actual;
        private String expenseLine;
        private String attendee;
    }

    private class ExpenseLineRequest{
        protected String id;
        protected String expenseType;
        protected String currencyIsoCode;
        protected double actual;
        private List<ExpenseAttributionRequest> expenseAttribution;
    }

    private class ExpenseRequest {
        private String eventId;
        private String eventAction;
        private String platform;
        private Datetime startTime;
        private String eventType;
        private String country;
        private String expenseHeaderId;
        private Set<String> ruleIds;
        private Set<String> accountIds;
        private Set<String> userIds;
        private Set<String> contactIds;
        private Set<String> attributionIds;
        private Map<String, String> attendeeKeyMap;
        private Map<String, String> eventAttendeeKeys;
        private List<ExpenseLineRequest> expenseLines;
        private boolean hasAttendee;
        //key is accountid or user id or contact id, group by expense type and currency code and attendee
        Map<String, List<ExpenseAttributionRequest>> preSaveAttributionMap;
        public Map<String, RuleAttendee> ruleAttendees;
        //key is parent expense type id, value is related child expense types id
        private Map<String, Set<String>> expenseTypeMap;
        //key is expense type id, value is expense type name
        private Map<String, String> expenseTypeNameMap;
        //key is expense type id, value is parent expense type id
        private Map<String, String> parentExpenseTypeMap;
    }

    private class ExpenseViolation {
        private String ruleId;
        private String attendeeId;
        private String matchedAmount;
        private List<String> violatedIds;
        private String violatedName;
    }
  
    private class RuleAttendee {
        private String accountId;
        private String userId;
        private String contactId;
        private String attendeeAccountType;
        public String attendeeName;
        private String attendeeFirstName;
        private String attendeeLastName;

        private RuleAttendee(String accountId, String userId, String contactId) {
            this.accountId = accountId;
            this.userId = userId;
            this.contactId = contactId;
        }
    }

    global class ExpenseResult{
        public boolean success;
        public List<ExpenseViolation> ruleViolations;
        public Map<String, RuleAttendee> ruleAttendees;
        public String errorMessage;
        public String eventHistoryMessage;
    }
}