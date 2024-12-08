public with sharing class AccountTriggerHandler extends TriggerHandler {
    /* Account Trigger
    * When an account is inserted change the account type to 'Prospect' if there is no value in the type field.
    * Trigger should only fire on insert.
    * Account Trigger
    * When an account is inserted copy the shipping address to the billing address.
    * Trigger should only fire on insert.
    * Account Trigger
    * When an account is inserted set the rating to 'Hot' if the Phone, Website, and Fax is not empty.
    * Trigger should only fire on insert.
    */
    public override void beforeInsert() {
        System.debug('account before insert');
        //AccountHelper.setTypeProspect((List<Account>)Trigger.new);
        //AccountHelper.addressCopy((List<Account>)Trigger.new);
        //AccountHelper.setRating((List<Account>)Trigger.new);
        AccountHelper.setTypeProspect((List<Account>)Trigger.new);
        AccountHelper.addressCopy((List<Account>)Trigger.new);
        AccountHelper.setRating((List<Account>)Trigger.new);
        
    }
    /*
    * Account Trigger
    * When an account is inserted create a contact related to the account with the following default values:
    * LastName = 'DefaultContact'
    * Email = 'default@email.com'
    * Trigger should only fire on insert.
    */    
    public override void afterInsert(){
        System.debug('account after insert');
        AccountHelper.defaultContact((List<Account>)Trigger.new);
    }        
    
}