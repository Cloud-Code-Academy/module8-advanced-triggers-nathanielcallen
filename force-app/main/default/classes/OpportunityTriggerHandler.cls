public with sharing class OpportunityTriggerHandler extends TriggerHandler {
    public override void afterInsert(){
        System.debug('Opportunity after insert');
        OpportunityHelper.createTaskForNewOpps((List<Opportunity>)Trigger.new);
        
    }
    public override void beforeInsert(){
        System.debug('Opportunity before insert starts');
        OpportunityHelper.setNewCustomerType((List<Opportunity>)Trigger.new);
        System.debug('Opportunity before insert ends');
        
    }
    public override void beforeUpdate(){
        System.debug('Opportunity before update');
        OpportunityHelper.setNewCustomerType((List<Opportunity>)Trigger.new);
        OpportunityHelper.stageChangesInDesctiption((Map<Id,Opportunity>)Trigger.newMap, (Map<Id,Opportunity>)Trigger.oldMap);
        OpportunityHelper.oppMinAmount((List<Opportunity>)trigger.new);
        OpportunityHelper.updatePrimaryContact((List<Opportunity>)Trigger.new);
        
    }
    public override void beforeDelete(){
        System.debug('Opportunity before delete');
        OpportunityHelper.preventDelete((List<Opportunity>)Trigger.old);
    }
    
    public override void afterDelete(){
        System.debug('Opportunity after delete');
        OpportunityHelper.notifyOwnersOpportunityDeleted((List<Opportunity>)Trigger.old);
        
    }
    public override void afterUndelete(){
        System.debug('Opportunity after undelete');
        OpportunityHelper.assignPrimaryContact((Map<Id,Opportunity>)Trigger.newMap);
        
    }    
     
}
