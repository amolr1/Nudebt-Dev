public class CancelTasksBatch implements Database.Batchable<sObject>{

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select Id, (Select Id from Tasks) from nu_dse__Offer__c where nu_dse__Status__c = 'Accepted']);
    }
    
    public void execute(Database.BatchableContext BC, List<Task> TaskList){
        
    }
    
    public void finish(Database.BatchableContext BC){
    	  
    }
    
}