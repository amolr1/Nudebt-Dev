global class Batch_EmailExela implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select Id, Subject, Action_Performed__c, textBody, Related_Account__r.Name, Attachment_Ids__c,Decision_Made_By__c FROM EmailmessageWHERE Decision_Source__c=\'Portal\' AND Subject LIKE \'%TEST%\'';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Emailmessage> scope) {
        list<Emailmessage> EmailmessageList = new list<Emailmessage>();
        map<id,Emailmessage> EmailmessageMap = new map<id,Emailmessage>();
        set<id> AttachmentIds = new set<id>();
        list<Attachment> AttachmentList = new list<Attachment>();
        for(Emailmessage e : scope)
         {
             String s1 = e.Subject;
             String s2 = s1.substringAfterLast('^');   
             e.Subject= s2;
             Emailmessage em = new Emailmessage();
             em=e.clone();
             em.Subject=s2;
             EmailmessageList.add(em);
             EmailmessageMap.put(e.Id,em); 
            
             String[] arrIds = e.Attachment_Ids__c.split(';');
             for(String aid : arrIds){
                AttachmentIds.add(aid); 
             }
             
           //  Attachment Attach = new Attachment();
             list<Attachment> Attachlist = [Select Id, Body from attachment where id=:AttachmentIds];
             for(Attachment at :Attachlist){
                at.Id = e.Attachment_Ids__c;
                at.ParentId = e.Id;
                AttachmentList.add(at);  
             }             
         }
         
         insert EmailmessageList;
         insert AttachmentList;        
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
}