trigger Attorney_CreateOrUpdateNDSPaymentTrigger on nu_dse__Payment__c (before Insert,before Update,after Insert, after Update,after delete) {
    
    AttorneyTriggerActivate__mdt TriggerFlag=[Select Id,isActive__c from AttorneyTriggerActivate__mdt where DeveloperName = 'Attorney_CreateOrUpdateNDSPaymentTrigger'];
    if(TriggerFlag.isActive__c){
        if(Trigger.isAfter && (Trigger.IsInsert || Trigger.IsUpdate)) {
            
            if(Attorney_StaticVariableUtility.isPaymentTriggerExecuted == false)
            {
                Attorney_StaticVariableUtility.isPaymentTriggerExecuted = true;// moving it to handler
                
                Attorney_CreateOrUpdateNDSPaymentHandler.CreateOrUpdateNDSPayment(trigger.new, trigger.oldMap,trigger.newMap); 
                
            }
        }
        
    }
    
    if(Trigger.isBefore){
        
        Attorney_CreateOrUpdateNDSPaymentHandler.BeforeUpdateHandler(trigger.new,trigger.newMap,trigger.isInsert);
        
    }
    if(Trigger.isAfter){   
        
        if(Trigger.IsDelete)
        {
            Attorney_CreateOrUpdateNDSPaymentHandler.rollupCalculationToOffer(trigger.old);
        }  
        else
        {
            Attorney_CreateOrUpdateNDSPaymentHandler.CreateRefundRecord(trigger.new, trigger.oldMap,trigger.newMap);
            Attorney_CreateOrUpdateNDSPaymentHandler.rollupCalculationToOffer(trigger.new); 
        }  
    }
    
}