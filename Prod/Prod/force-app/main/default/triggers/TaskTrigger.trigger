trigger TaskTrigger on Task (before insert, before update, after insert,before delete, after update) {
    
    //To check is subject contain Inbound or Outbound, mark it a note. (S20-205- 16 September, 2019)
  // if(Trigger.isAfter && Trigger.isInsert){
   //     DispositionTaskTriggerHandler.handleAfterInsert(Trigger.NewMap);
   // }
    
   if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    {
        
        List<String> dispositionList= new List<String>();
        List<Schema.PicklistEntry> ple = nu_dse__Program__c.nu_dse__Disposition__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple)
        {
            dispositionList.add(pickListVal.getLabel());
        }
        system.debug('### dispositionList: '+dispositionList);
        
        for(Task sub: Trigger.new)  
        {
           
           
            for(String dispositionStr: dispositionList)
            {
                if(sub.Subject != null && sub.Subject.contains(': Follow Up') ){
                    sub.IsNote__c=false;
                    break;
                }
                else if(sub.Subject != null && sub.Subject.contains(dispositionStr) && sub.Status == 'Completed' )
                {
                   sub.IsNote__c=true;
                  // sub.Channel_Name__c = grpTask;
                    break;
                }                
            }
          
    }
    }
    if (Trigger.isInsert && Trigger.isAfter) {
        
        // When a task is created with IsNote checkbox set to true, this trigger will create Note under the same Program
        /*
        The created Task will have the following field mappings
        1. Subject -> Title
        2. Description -> Body
        3. RelatedTo(WhatId) -> ParentId    
        */
        TaskHandler_CreateNoteForDispTask.createNotes(Trigger.new);
        TaskHandler_StopTaskCreation.StopTaskCreation(Trigger.new);
        TaskHandler_StopTaskCreation.stopDuplicateTaskCreation(Trigger.new);
    }
    if (Trigger.isInsert && Trigger.isBefore) {
        TaskHandler_PopulateProgram.populatePrograme(Trigger.new);
    }
    // ND-331
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        TaskHandler_PopulateProgram.sendClientSurveyEmail(Trigger.new);
    } 
    // ND-331
}