trigger opportunityRestApitrigger on Opportunity (after insert, before insert, After Update) {

    if(Trigger.isBefore){
        SendOpportunityAccountUsingRestApi.OpportunityBeforeInsert();
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
        SendOpportunityAccountUsingRestApi.CopyTradelinePaymentsFromLead(trigger.new);
        SendOpportunityAccountUsingRestApi.getOppDataJSON(trigger.newMap.keySet());
    }
    
    if(Trigger.isAfter){
        OpportunityTriggerHandler.sendEmail();
    }
}