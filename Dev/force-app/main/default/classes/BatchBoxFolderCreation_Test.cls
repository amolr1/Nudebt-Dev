@isTest
public class BatchBoxFolderCreation_Test  implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
         // Create a fake response
        System.debug('::req::'+req);   
        String response;
        if (req.getEndpoint().startsWith('https://api.box.com/2.0/search') == True) {
        
             response = '{"total_count":1,"entries":[{"type":"folder","id":"56618422535","etag":"1","name":"CL-GL0014309452","parent":{"type":"folder","id":"57206468784","sequence_id":"0","etag":"0","name":"GREAT LAKES"}}],"limit":10,"offset":0}';
        }
        else if (req.getEndpoint() == 'https://api.box.com/2.0/folders') {
        
             response = '{"type":"folder","id":"47510948398","sequence_id":"0","etag":"0","name":"Add Remove Debt",'
                      + '"created_at":"2017-12-17T23:35:21-08:00","modified_at":"2017-12-17T23:35:21-08:00",'
                      + '"description":"","size":0,"path_collection":{"total_count":2,"entries":[{"type":"folder","id":"0",'
                      + '"sequence_id":null,"etag":null,"name":"All Files"},{"type":"folder","id":"43404879503",'
                      + '"sequence_id":"0","etag":"0","name":"CL-21972"}]},"created_by":{"type":"user","id":"2771025561",'
                      + '"name":"ArrayApp","login":"AutomationUser_432805_zFIfJqpDlp@boxdevedition.com"},'
                      + '"modified_by":{"type":"user","id":"2771025561","name":"ArrayApp",'
                      + '"login":"AutomationUser_432805_zFIfJqpDlp@boxdevedition.com"},"trashed_at":null,"purged_at":null,'
                      + '"content_created_at":"2017-12-17T23:35:21-08:00","content_modified_at":"2017-12-17T23:35:21-08:00",'
                      + '"owned_by":{"type":"user","id":"2771025561","name":"ArrayApp",'
                      + '"login":"AutomationUser_432805_zFIfJqpDlp@boxdevedition.com"},"shared_link":null,"folder_upload_email":null,'
                      + '"parent":{"type":"folder","id":"43404879503","sequence_id":"0","etag":"0","name":"CL-21972"},'
                      + '"item_status":"active","item_collection":{"total_count":0,"entries":[],"offset":0,"limit":100,'
                      + '"order":[{"by":"type","direction":"ASC"},{"by":"name","direction":"ASC"}]}}';
        } else{
        
            response = '{"access_token":"SBI5y9vqwn13m9cFCo0YbYms0uIhANNA","expires_in":3603,"restricted_to":[],"token_type":"bearer"}';
        }
        HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(response);
            res.setStatus('OK');
            res.setStatusCode(201);    
        return res;
    }

    static testMethod void testCreateBoxFolderAndSubFolders() {
        
       Id clientRecordTypeId = TestRecordCreator.getRecordTypeId('Account', 'Client');
        
       Portfolio__c p = new Portfolio__c();
       p.name = 'TestPortFolio';
       //p.BoxFolderId__c = '22222222222'; replaced inorder to increase code converage... If boxFolderId in the response didn't match id wont be populated...
       p.BoxFolderId__c = '57206468784';
       p.Active_Status__c = true;
       insert p;
       
        Account accountInstance = TestRecordCreator.createAccount('Account Name', clientRecordTypeId);
        accountInstance.PortFolio_Name__c = 'TestPortFolio';
        accountInstance.Phone = '9879879877';
        //accountInstance.Box_Folder_Name__c = 'CL-GL0014309452'; //Field not writeable error occurs
        accountInstance.NDS_File_Number__c = 'CL-GL0014309452';
        accountInstance.Attorney__c = True; 
        insert accountInstance;
        
        nu_dse__Program__c pgm = new nu_dse__Program__c();
        pgm.nu_dse__Account__c = accountInstance.id;
        pgm.Portfolio__c = p.id;
        insert pgm;
        
        Box_settings__c boxInstance = TestRecordCreator.createBoxsettings();
        boxInstance.FolderSearch_Endpoint__c = 'https://api.box.com/2.0/search';
        insert boxInstance;
        
        Test.startTest();
        
            Test.setMock(HttpCalloutMock.class, new BatchBoxFolderCreation_Test());
            Database.executeBatch(new BatchBoxFolderCreation(), 1);
            
        Test.stopTest();
        
        List<Account> accountList = [SELECT Id, BoxFolderId__c FROM Account WHERE Id = :accountInstance.Id];
        //System.assertEquals('47510948398', accountList[0].BoxFolderId__c);
    }
    
    static testMethod void testRootIdMismatchCreateNewBoxFolderAndSubFolders() {
        
        Id clientRecordTypeId = TestRecordCreator.getRecordTypeId('Account', 'Client');
        
       Portfolio__c p = new Portfolio__c();
       p.name = 'TestPortFolio';
       p.BoxFolderId__c = '22222222222'; //actual parent Id is '57206468784'
       p.Active_Status__c = true;
       
       insert p;
       
        Account accountInstance = TestRecordCreator.createAccount('Account Name', clientRecordTypeId);
        accountInstance.PortFolio_Name__c = 'TestPortFolio';
        accountInstance.Attorney__c = True; 
        accountInstance.Phone = '9879879877';
        insert accountInstance;
        
        nu_dse__Program__c pgm = new nu_dse__Program__c();
        pgm.nu_dse__Account__c = accountInstance.id;
        pgm.Portfolio__c = p.id;
        insert pgm;
        
        Box_settings__c boxInstance = TestRecordCreator.createBoxsettings();
        boxInstance.FolderSearch_Endpoint__c = 'https://api.box.com/2.0/search';
        insert boxInstance;
        
        Test.startTest();
        
            Test.setMock(HttpCalloutMock.class, new BatchBoxFolderCreation_Test());
            Database.executeBatch(new BatchBoxFolderCreation(), 1);
            
        Test.stopTest();
        
        List<Account> accountList = [SELECT Id, BoxFolderId__c FROM Account WHERE Id = :accountInstance.Id];
        //System.assertEquals('47510948398', accountList[0].BoxFolderId__c);
    }
}