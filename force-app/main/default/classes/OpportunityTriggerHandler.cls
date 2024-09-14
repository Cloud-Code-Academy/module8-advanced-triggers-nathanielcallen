public with sharing class OpportunityTriggerHandler {
    public static void assignPrimaryContact(Map<Id,Opportunity> oppNewMap) {        
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        List<Contact> primaryContacts = [SELECT Id, AccountId FROM Contact WHERE Title = 'VP Sales'];
        Map<Id, Contact> accountIdToContactMap = new Map<Id, Contact>();
        for (Contact con : primaryContacts) {
            if (accountIdToContactMap.containsKey(con.AccountId)) {
                continue;
            }
            accountIdToContactMap.put(con.AccountId, con);
        }
        for (Opportunity opp : oppNewMap.values()){           
            if (opp.Primary_Contact__c == null){
                Opportunity oppToUpdate = new Opportunity(Id = opp.Id);
                oppToUpdate.Primary_Contact__c = accountIdToContactMap.get(opp.AccountId).Id;
                oppMap.put(opp.Id, oppToUpdate);
            }
        }
        update oppMap.values();
    }
    public static void notifyOwnersOpportunityDeleted(List<Opportunity> opps) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Set<Id> oppOwnerIds = new Set<Id>();
        for (Opportunity opp : opps) {
            oppOwnerIds.add(opp.OwnerId);
        }
        List<User> oppOwners = [SELECT Id, Email FROM User WHERE Id IN :oppOwnerIds];
        List<String> toAddresses = new List<String>();
        for (User oppOwner : oppOwners) {
            toAddresses.add(oppOwner.Email);
        }
        
        for (Opportunity opp : opps){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();           
            mail.setToAddresses(toAddresses);
            mail.setSubject('Opportunity Deleted : ' + opp.Name);
            mail.setPlainTextBody('Your Opportunity: ' + opp.Name +' has been deleted.');
            mails.add(mail);
        }        
        
        try {
            Messaging.sendEmail(mails);
        } catch (Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
    }

    public static void createTaskForNewOpps(List<Opportunity> newOpps){
        List<Task> myTasks = new List<Task>();
            for (Opportunity opp : newOpps){
                Task tsk = new Task();
                tsk.Subject = 'Call Primary Contact';
                tsk.WhatId = opp.Id;
                tsk.WhoId = opp.Primary_Contact__c;
                tsk.OwnerId = opp.OwnerId;
                tsk.ActivityDate = Date.today().addDays(3);
                myTasks.add(tsk);
            }
            insert myTasks;
    }
    public static void stageChangesInDesctiption(Map<Id,Opportunity> newOppMap, Map<Id,Opportunity> oldOppMap){    
        for ( Id oppId : newOppMap.keySet()) {
            if (newOppMap.get(oppId).StageName != oldOppMap.get(oppId).StageName) {
                newOppMap.Get(oppId).Description = '\n Stage Change:' + newOppMap.get(oppId).StageName + ':' + DateTime.now().format();
                }
        }
    }    
    public static void setNewCustomerType(List<Opportunity> newOpps){    
        for(Opportunity opp : newOpps){
            if (opp.Type == null){
                opp.Type = 'New Customer';
            } 
        }
    }    
    public static void oppMinAmount(List<Opportunity> newOpps){
        for(Opportunity opp : newOpps){
            if(opp.Amount < 5000){
                opp.addError('Opportunity amount must be greater than 5000');
            }
        }
    }
    Public static void preventDelete(List<Opportunity> oldOpps){
        for (Opportunity oldOpp : oldOpps){
            if (oldOpp.IsClosed){
                oldOpp.addError('Cannot delete closed opportunity');
            }
        }    
    }
    public static void updatePrimaryContact(List<Opportunity> newOpps){      
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity opp : newOpps){
            accountIds.add(opp.AccountId);
        }
        
        Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id, FirstName, AccountId FROM Contact WHERE AccountId IN :accountIds AND Title = 'CEO' ORDER BY FirstName ASC]);
        Map<Id, Contact> accountIdToContact = new Map<Id, Contact>();

        for (Contact cont : contacts.values()) {
            if (!accountIdToContact.containsKey(cont.AccountId)) {
                accountIdToContact.put(cont.AccountId, cont);
            }
        }

        for(Opportunity opp : newOpps){
            if(opp.Primary_Contact__c == null){
                if (accountIdToContact.containsKey(opp.AccountId)){
                    opp.Primary_Contact__c = accountIdToContact.get(opp.AccountId).Id;
                }
            }
        }
    }
}
