@RestResource(urlMapping='/CreateLendAppTask/*')
global class CreateLendingTask {
   @HttpPost
    
  global Static void CreateTasks(){
        String jsonString;
        list<nu_dse__Group_Task__c> lsttsk=new list<nu_dse__Group_Task__c>();
        RestRequest request = RestContext.request;
        RestResponse response=RestContext.response;  //@new
        if(!Test.isRunningTest()){
           jsonString =  request.requestBody.toString();
        }else {
            nu_dse__Group_Task__c t=new nu_dse__Group_Task__c();   //nu_dse__Group_Task__c
            t.id = [Select Id from nu_dse__Group_Task__c limit 1].Id;
            t.nu_dse__Status__c = 'Completed';
            lsttsk.add(t);
            jsonString = JSON.serialize(lsttsk);
        }
        //Map<String,List<Task>> datamap =(Map<String,List<Task>>) JSON.deserialize(jsonString, Map<String,List<Task>>.class);
        
        list<nu_dse__Group_Task__c> TaskList =(list<nu_dse__Group_Task__c>) JSON.deserialize(jsonString, list<nu_dse__Group_Task__c>.class);
        
         List<nu_dse__Group_Task__c> insertTaskList = new List<nu_dse__Group_Task__c>();
        System.debug('TaskList = '+TaskList);
           Group negotiatorGroup=[select Id, Name from Group where Type = 'Queue' AND NAME = 'DNL Negotiatiators' Limit 1];
            Id NegotiationsRecordTypeId = Schema.SObjectType.nu_dse__Group_Task__c.getRecordTypeInfosByName().get('Negotiations').getRecordTypeId(); 
            if(!TaskList.isEmpty()){
                
                for(nu_dse__Group_Task__c eachTask : TaskList){
                    nu_dse__Group_Task__c newTask = new nu_dse__Group_Task__c();
                    newTask.nu_dse__Subject__c = eachTask.nu_dse__Subject__c;
                    newTask.nu_dse__Status__c = eachTask.nu_dse__Status__c;
                    newTask.Subject_Picklist__c='DNL Negotiations Review Request';
                    newTask.Priority__c = eachTask.Priority__c;
                    newTask.nu_dse__ActivityDate__c = eachTask.nu_dse__ActivityDate__c;
                    //newTask.Task_Id__c=eachTask.Id;
                    newTask.nu_dse__Description__c=eachTask.nu_dse__Description__c;
                    newTask.RecordTypeId=NegotiationsRecordTypeId; 
                    newTask.OwnerId=negotiatorGroup.Id;
                    insertTaskList.add(newTask);  
                  
                }
            }
        
        System.debug('insertTaskList = '+insertTaskList.size());
        if(!insertTaskList.isEmpty()){
            insert insertTaskList;  
        }
     
  }  
}