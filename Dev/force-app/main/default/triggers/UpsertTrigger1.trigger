trigger UpsertTrigger1 on Account (before insert) {
    
    /* Commented by Arumugam Kannan --> To fix the issue 'maximum trigger depth exceeded'*/
    
    
            /*<Account> AccountList = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
           Account acc =new Account(name = 'Test' +i, NDS_File_Number__c='1234' +i);
           AccountList.add(acc);
        } //Upserting the Account Records
        upsert AccountList;
        System.debug('Code iterated for 10 times and created 9 records as one record with External Id 12341 is already present');
        for (Account objAccount: AccountList) {
           if(objAccount.NDS_File_Number__c == '12341') {
              system.debug('The Record which is already present is '+objAccount);
           }
        }*/
}