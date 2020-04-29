global class InsertGroupTask {
    
    static Map<String, Id> queueId = new Map<String, Id>();
    static Map<String, Id> templateMap = new Map<String, Id>();
    static Boolean mapConstructed = False;
    static Map<String, Holiday> holidayMap = new Map<String, Holiday>();
    
    @InvocableMethod(label='Insert Group Task')
    global static List<CreateGroupTaskResponse> invoke(List<CreateGroupTaskRequest> request ){
        
        if (mapConstructed == False) {

            queueId = getQueueMap();
            templateMap = getTemplateMap(); 
            holidayMap = Holidays.getHolidaysMap();
            mapConstructed = True;
        }
        
        List<nu_dse__Group_Task__c> groupTaskUpsertList = new List<nu_dse__Group_Task__c>(); 
        
        for (CreateGroupTaskRequest tr: request) {
           
          Date activityDate = tr.activityDate; 
            
          activityDate =   Holidays.getNextWorkingDay(holidayMap, ActivityDate);
        
          nu_dse__Group_Task__c groupTaskInstance = new nu_dse__Group_Task__c(); 
        
          groupTaskInstance.nu_dse__Subject__c = tr.subject; 
        
          groupTaskInstance.nu_dse__ActivityDate__c = activityDate; 
        
          groupTaskInstance.nu_dse__Unique_Identifier__c = tr.uniqueIdentifier;
          
          groupTaskInstance.nu_dse__Related_To__c = tr.parentId;
          
          if (templateMap.isEmpty() == False && templateMap.containsKey(tr.templateName) 
                                                  && templateMap.get(tr.templateName) != null) {
                                                  
              groupTaskInstance.nu_dse__Communication_Template__c = templateMap.get(tr.templateName);
              
          } else if (tr.templateId != null) {
              
              groupTaskInstance.nu_dse__Communication_Template__c = tr.templateId;
          }
                 
          if (queueId.isEmpty() == False && String.isNotBlank(tr.queueName) && queueId.ContainsKey(tr.queueName) && queueId.get(tr.queueName) != null) {
              
              groupTaskInstance.ownerId = queueId.get(tr.queueName); 
              
          } else  if (tr.ownerId != null) {
              
              groupTaskInstance.ownerId = tr.ownerId; 
          }
          
          if (String.isNotBlank(tr.subjectPicklist)) {
              
              groupTaskInstance.Subject_Picklist__c = tr.subjectPicklist;
          }
          
          if (String.isNotBlank(tr.description)) {
              
              groupTaskInstance.nu_dse__Description__c = tr.description;
          }    
          
          if (String.isNotBlank(tr.status)) {
              
              groupTaskInstance.nu_dse__Status__c = tr.status;
          } 
                                
          groupTaskUpsertList.add(groupTaskInstance); 
            
        }
       
        List<CreateGroupTaskResponse>  response = new List<CreateGroupTaskResponse>(); 
        
        
        try{
            
            insert groupTaskUpsertList; 
              
            for (nu_dse__Group_Task__c  grouptask: groupTaskUpsertList) {
            
                CreateGroupTaskResponse tresponse =  new CreateGroupTaskResponse();
                tresponse.Id = grouptask.Id; 
                response.add(tresponse);
            }
            
        }catch(Exception e){
            
            CreateGroupTaskResponse tresponse =  new CreateGroupTaskResponse();
            tresponse.error = 'Upsert Failed';
            response.add(tresponse);
            System.debug('upsert failed');
        }
        
        return response; 
    }

    global class CreateGroupTaskRequest {
        
       @InvocableVariable(required=true)
       global String uniqueIdentifier;
       @InvocableVariable
       global Id templateId;
       @InvocableVariable
       global String templateName;
       @InvocableVariable(required=true)
       global String subject; 
       @InvocableVariable(required=true) 
       global Date activityDate;
       @InvocableVariable(required=true) 
       global Id parentId; 
       @InvocableVariable
       global String status; 
       @InvocableVariable
       global Id ownerId = UserInfo.getUserId(); 
       @InvocableVariable
       global String queueName; 
       @InvocableVariable
       global String subjectPicklist;
       @InvocableVariable
       global String description; 
    } 
    
    global class CreateGroupTaskResponse{
        
        @InvocableVariable
        global String Id; 
        @InvocableVariable
        global String error; 
    }
    
    global static Map<String,id> getQueueMap(){
        
        Map<String,id> queueName = new Map<string,id>(); 
        
        for (Group q: [select id,Name,DeveloperName, Type, Email, ownerId from Group where Type='Queue']) {
            
            queueName.put(q.developerName, q.id);
        }
        return queueName; 
    }
    global static Map<string,id> getTemplateMap(){
        
        Map<string,id> template = new Map<String,id>();
        
        for (nu_dse__Communication_Template__c temp: [select id, name from nu_dse__Communication_Template__c]) {
            
            template.put(temp.name,temp.id);
        }
        return template; 
    }
}