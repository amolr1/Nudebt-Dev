trigger upsertTrigger on Account (Before Insert, Before Update) {
List<Account> acclist=new list<Account>();
for (Account acc: Trigger.new){
acc.name='Test1';
acc.NDS_File_Number__c ='12345';
}
Schema.SObjectField f = Account.Fields.NDS_File_Number__c;
Database.UpsertResult[] srList = Database.upsert(acclist,f,false);
for (Database.UpsertResult sr : srList) {
    if (sr.isSuccess()) {
        // Operation was successful  
    }
    else {
        // Operation failed, so get all errors                
        for(Database.Error err : sr.getErrors()) {
            System.debug('error has occurred.' + err.getStatusCode() + ': ' + err.getMessage());                    
            System.debug('fields that affected this error: ' + err.getFields());     
        }
     }
}
}