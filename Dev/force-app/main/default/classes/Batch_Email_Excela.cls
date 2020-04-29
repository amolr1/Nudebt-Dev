global class Batch_Email_Excela implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
    System.debug('123');
        return Database.getQueryLocator([select Id,Subject, Action_Performed__c, textBody, Related_Account__r.Name,Attachment_Ids__c,Decision_Made_By__c,Decision_Source__c FROM Emailmessage Where Decision_Source__c='Portal' AND Subject LIKE '%^^^TEST%']);
        
    }
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
    // Select Id, Body from attachment where id=:attachmentid
    	System.debug('Execute11223');
      	for(emailMessage em : (List<Emailmessage>) scope) {
            String prevSubj=em.subject;
            List<String> contentDocIdList = new List<String>();
            contentDocIdList = String.valueOf(em.RelatedToId).split(';');
            List<Messaging.Emailfileattachment> fileAttachmentList = new List<Messaging.Emailfileattachment>();
            /*System.debug('em  1123 ' + em.Attachment_Ids__c);
            Set<String> setOfAttachementIDs = new Set<String>();
            System.debug('em.Attachment_Ids__c ' + em.Attachment_Ids__c);
            for(String attId : em.Attachment_Ids__c.Split(';')){
                setOfAttachementIDs.add(attId);
            }
            List<Attachment> attList = [SELECT Id,Name, Body FROM Attachment where id IN : setOfAttachementIDs]; */          
            
           /* System.debug('attList' + attList);
            for (Attachment a : attList)
            {
               // Add to attachment file list 
               Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
               efa.setFileName(a.Name);
               efa.setBody(a.Body);
               fileAttachments.add(efa);
            }
            System.debug('fileAttachments ' + fileAttachments);
           /* EmailMessage newEmailMessage = new EmailMessage();
            String prevSubj=em.subject;
            if(prevSubj!= null && prevSubj!= '')
            newEmailMessage.subject=prevSubj.substring(10,prevSubj.length()-1);
			newEmailMessage.Action_Performed__c=em.Action_Performed__c;
            newEmailMessage.textBody=em.TextBody;
            newEmailMessage.ToAddress = ('SampleEmail@yopmail.com');
           newEmailMessage.ContentDocumentIds = setOfAttachementIDs;
            newEmailMessage.Attachment_Ids__c=em.Attachment_Ids__c;*/
            
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            // Exela id to be included
            String[] sendTo = new String[]{'hlingamaneni@stratfs.com'};
            mail.setToAddresses(sendTo);
            if(prevSubj!= null && prevSubj!= '')
            mail.setSubject(prevSubj.substring(10,prevSubj.length()-1));
            mail.setHTMLBody(em.TextBody);
            if(!contentDocIdList.isEmpty()) {
                        
                            for (ContentVersion docContent: [SELECT Id, VersionData, PathOnClient, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId  IN :contentDocIdList]) {
                               
                                Messaging.Emailfileattachment fileAttachment = new Messaging.Emailfileattachment();
                                fileAttachment.setFileName(docContent.PathOnClient);
                                fileAttachment.setBody(docContent.VersionData);
                                fileAttachmentList.add(fileAttachment);
                            }
                        }
                   
              mail.setFileAttachments(fileAttachmentList);
           Messaging.SendEmailResult[] emailResultList=Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    
            }
        }
     
    
        global void finish(Database.BatchableContext BC) {
             
        }
    }