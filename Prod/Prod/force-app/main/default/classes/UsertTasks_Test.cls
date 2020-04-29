@isTest
public class UsertTasks_Test {

    @testsetup
    public static void testData(){
        
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        
        
        insert program; 
        
        Nu_dse__Communication_Template__c template = new nu_dse__Communication_Template__c(); 
        template.name = 'Testing';
        
        insert template; 
        
    }
    
     public testmethod static void testupsertTask(){
        nu_dse__Program__c program = [select id from  nu_dse__Program__c limit 1];
        nu_dse__Communication_Template__c template  = [select id from  nu_dse__Communication_Template__c limit 1];
         
        CreateTask.CreateTaskRequest request = new CreateTask.CreateTaskRequest(); 
        request.activityDate = System.date.today(); 
        request.subject = 'Test'; 
        request.parentId = program.Id;
        request.uniqueIdentifier = String.valueOf(System.Date.today());
        request.templateName = template.id;  
        
        LIst<CreateTask.CreateTaskRequest> requestList = new List<CreateTask.CreateTaskRequest>(); 
        
        requestList.add(request);
        
        CreateTask.invoke(requestList);
         
        UpsertTasks.UpsertTaskRequest upsertrequest = new  UpsertTasks.UpsertTaskRequest(); 
        upsertrequest.activityDate = System.date.today(); 
        upsertrequest.subject = 'Test'; 
        upsertrequest.parentId = program.Id;
        upsertrequest.uniqueIdentifier = String.valueOf(System.Date.today());
        upsertrequest.templateName = template.id; 
        
        List<UpsertTasks.UpsertTaskRequest> upsertRequestList = new  List<UpsertTasks.UpsertTaskRequest>(); 
         
        UpsertTasks.upsertTask(upsertRequestList);
         
    }
}