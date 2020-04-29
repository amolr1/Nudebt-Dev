public class ToDeleteContentDocumentLink{
    
    public void init() {
        
        Map<Id, ContentDocument> contentDocumentToDeleteMap = new Map<Id, ContentDocument>();    
        List<EmailMessage> emailMessagelist = Database.query('SELECT Id, Subject, Action_Performed__c, HtmlBody, Related_Account__c,'
            + ' Attachment_Ids__c, Decision_Made_By__c, Decision_Source__c FROM Emailmessage'
            + ' WHERE Decision_Source__c=\'Portal\' AND Subject LIKE \'%^^^TEST%\' LIMIT 1');
            
        system.debug('emailMessagelist--->'+emailMessagelist);
        
        if (emailMessagelist.isempty() == False) {
        
            for (EmailMessage emailMsg : emailMessagelist) {
            
                for ( String attchmentId : (emailMsg.Attachment_Ids__c).split(';')) {
                    
                    contentDocumentToDeleteMap.put(attchmentId , new ContentDocument(Id = attchmentId));
                }
            }
        }
        System.debug('***** contentDocumentToDeleteMap-->' + contentDocumentToDeleteMap);
        
        if(contentDocumentToDeleteMap.isEmpty() == FALSE) {
                                    
            delete contentDocumentToDeleteMap.Values();
        }
    }
}