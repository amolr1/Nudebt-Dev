/* Date : 01-11-2018
 * Author : Team IDev
 */
@isTest
public class SFSPortal_DocumentsController_Test {

    public static testMethod void testSFSPortal_DocumentsControllerForClient() {
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
                  
        User user1 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        insert user1;
        
        User user2 = user1;
        user2.Email = 'test@test.com';
        
        portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('7523698416');
        portfolioInstance.Active_Status__c = true;
        insert portfolioInstance ;
        
        nu_dse__Program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id, null);
        programInstance.Portfolio__c = portfolioInstance.Id;
        insert programInstance;
        
        List<ContentVersion> contentVersionInstanceList = new List<ContentVersion>{ SFSPortal_TestRecordCreator.createContentVersion(), 
                                                                                    SFSPortal_TestRecordCreator.createContentVersion(),
                                                                                    SFSPortal_TestRecordCreator.createContentVersion(),
                                                                                    SFSPortal_TestRecordCreator.createContentVersion(),
                                                                                    SFSPortal_TestRecordCreator.createContentVersion()};
        insert contentVersionInstanceList;
        
        Set<Id> convertionId = new Set<Id>();
        for(ContentVersion conversion : contentVersionInstanceList) {
            
            convertionId.add(conversion.Id);
        }
        
        List<ContentDocumentLink> contentLinkList  = new List<ContentDocumentLink>();
        for (ContentVersion getDocumentId : [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id IN : convertionId]) {
            
            contentLinkList.add(SFSPortal_TestRecordCreator.createContentDocumentLink(getDocumentId.ContentDocumentId,account1.Id));
        }
        insert contentLinkList;
        
          
        
        String AccountId = '';
        System.runAs(user1) { 
                     
            Test.startTest();
                
                SFSPortal_DocumentsController.documentsWrapper  wrapper = SFSPortal_DocumentsController.getContentDocument();
                AccountId = wrapper.accountId;
                
                EmailMessage incomingMail = new EmailMessage();
                incomingMail.fromaddress='test@email.com';
                incomingMail.toAddress = 'test@test.com';
                incomingMail.subject = 'Test Message';
                incomingMail.TextBody= 'This is the message body ';
                incomingMail.Action_Performed__c = 'Document Upload';
                incomingMail.Related_Account__c = AccountId;
                incomingMail.Attachment_Ids__c = contentLinkList[2].ContentDocumentId;
                insert incomingMail ;    
                
                SFSPortal_DocumentsController.documentsWrapper  wrapper1 = SFSPortal_DocumentsController.getContentDocument();
                
                SFSPortal_DocumentsController.getDefaultFormIdList();
                try {                    
                    
                    SFSPortal_DocumentsController.deleteDocument(contentLinkList[0].ContentDocumentId);                    
                } catch(Exception e) {
        
                    system.assertEquals('Script-thrown exception', e.getMessage());
                }
                try {                    
                    
                    SFSPortal_DocumentsController.deleteDocument(contentLinkList[0].ContentDocumentId +';'+contentLinkList[1].ContentDocumentId);                    
                } catch(Exception e) {
        
                    system.assertEquals('Script-thrown exception', e.getMessage());
                }
                try {                    
                    
                    SFSPortal_DocumentsController.sendEmail(new EmailMessage(subject = 'Bank Form', RelatedToId = contentLinkList[0].ContentDocumentId ),account1.Id);                  
                } catch(Exception e) {
        
                    system.assertEquals('Script-thrown exception', e.getMessage());
                }
            Test.stopTest();
        }
        system.assertEquals(account1.Id, AccountId);
    }
    public static testMethod void testSFSPortal_DocumentsControllerForCoClient() {
        
        Account accountInstance = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert accountInstance;
        
        Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        //account1.Primary_Client__c = accountInstance.Id;
        insert account1;
        
        Contact con = [SELECT Id FROM Contact WHERE AccountId =: account1.Id];
                  
        User user1 = SFSPortal_TestRecordCreator.createCommunityUser(con.Id);
        insert user1;
        
        User user2 = user1;
        user2.Email = 'test@test.com';
        
        portfolio__c portfolioInstance = SFSPortal_TestRecordCreator.createPortfolio('7523698416');
        portfolioInstance.Active_Status__c = true;
        insert portfolioInstance ;
        
        nu_dse__Program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id, null);
        programInstance.Portfolio__c = portfolioInstance.Id;
        insert programInstance;
        
        List<ContentVersion> contentVersionInstanceList = new List<ContentVersion>{ SFSPortal_TestRecordCreator.createContentVersion(), 
                                                                                    SFSPortal_TestRecordCreator.createContentVersion(),
                                                                                    SFSPortal_TestRecordCreator.createContentVersion(),
                                                                                    SFSPortal_TestRecordCreator.createContentVersion(),
                                                                                    SFSPortal_TestRecordCreator.createContentVersion()};
        insert contentVersionInstanceList;
        
        Set<Id> convertionId = new Set<Id>();
        for(ContentVersion conversion : contentVersionInstanceList) {
            
            convertionId.add(conversion.Id);
        }
        List<ContentDocumentLink> contentLinkList  = new List<ContentDocumentLink>();
        for (ContentVersion getDocumentId : [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id IN : convertionId]) {
            
            contentLinkList.add(SFSPortal_TestRecordCreator.createContentDocumentLink(getDocumentId.ContentDocumentId,account1.Id));
        }
        insert contentLinkList;
        
        String AccountId = '';
        System.runAs(user1) { 
                     
            Test.startTest();
                
                SFSPortal_DocumentsController.documentsWrapper  wrapper = SFSPortal_DocumentsController.getContentDocument();
                AccountId = wrapper.accountId;
                SFSPortal_DocumentsController.getDefaultFormIdList();
                try {                    
                    
                    SFSPortal_DocumentsController.deleteDocument(contentLinkList[0].ContentDocumentId);                    
                } catch(Exception e) {
        
                    system.assertEquals('Script-thrown exception', e.getMessage());
                }
                try {                    
                    
                    SFSPortal_DocumentsController.deleteDocument(contentLinkList[0].ContentDocumentId +';'+contentLinkList[1].ContentDocumentId);                    
                } catch(Exception e) {
        
                    system.assertEquals('Script-thrown exception', e.getMessage());
                }
                try {                    
                    
                    SFSPortal_DocumentsController.sendEmail(new EmailMessage(subject = 'Bank Form', RelatedToId = contentLinkList[0].ContentDocumentId ),account1.Id);                  
                } catch(Exception e) {
        
                    system.assertEquals('Script-thrown exception', e.getMessage());
                }
            Test.stopTest();
        }
        system.assertEquals(account1.Id, AccountId);
    }
}