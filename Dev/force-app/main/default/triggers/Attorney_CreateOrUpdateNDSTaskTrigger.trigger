trigger Attorney_CreateOrUpdateNDSTaskTrigger on Task (before insert, before update,after Insert,after update) {

//Following code is commented by Rajesh to Stop Task Push to NDS - NMI-882
 //   AttorneyTriggerActivate__mdt TriggerFlag=[Select Id,isActive__c from AttorneyTriggerActivate__mdt where DeveloperName = 'Attorney_CreateOrUpdateNDSTaskTrigger'];
    if(Trigger.isAfter){
 //      if(TriggerFlag.isActive__c){
            if(Attorney_StaticVariableUtility.isTaskTriggerExecuted == false && Trigger.New[0].Attorney__c)
            {
                Attorney_StaticVariableUtility.isTaskTriggerExecuted = true;
             //   Attorney_CreateOrUpdateNDSTaskHandler.CreateOrUpdateNDSTask(Trigger.new, trigger.OldMap); 
                Attorney_CreateOrUpdateNDSTaskHandler.CreateNDSAddLogEntry(Trigger.new, trigger.OldMap); 
                
            }
 //      }
     
       Prizm_TaskHandler.Prizm_UpdateLeadStatus(Trigger.new, trigger.OldMap);
        
        if(Trigger.isInsert){
             Prizm_TaskHandler.pushTasksToPrizm();
        }
    }
    
     if(Trigger.isBefore){
  
        System.debug('isBefore');
        if(!Attorney_StaticVariableUtility.isTaskBeforeExecuted) 
           Attorney_CreateOrUpdateNDSTaskHandler.UpdateAttorneyFlag(Trigger.new, Trigger.isInsert, Trigger.OldMap); 
           Prizm_TaskHandler.Prizm_validateTask(Trigger.new);
         if(trigger.isInsert)
            Prizm_TaskHandler.ChangeReason(Trigger.new);
        
    }
    System.debug('***Trigger');
   
}