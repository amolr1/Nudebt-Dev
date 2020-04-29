public class OpportunityTriggerHandler{
    
    public static void sendEmail(){
        
        List<Opportunity> OpportunityList = (List<Opportunity>)Trigger.new;
        Map<Id,Opportunity> OpportunityOldMap = (Map<Id, Opportunity>)Trigger.oldMap;

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for(Opportunity opp: OpportunityList){
            if(opp.Email_Sent__c == true && (Trigger.isInsert || opp.Email_Sent__c != OpportunityOldMap.get(opp.Id).Email_Sent__c)){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                sendTo.add('mayur.techup@gmail.com');
                mail.setToAddresses(sendTo);
                mail.setReplyTo('jkaplan@anchorlawfirm.com');
                
                //Org- wide address
                mail.setOrgWideEmailAddressId('0D256000000CbB0');
                
                //Display name
         //       mail.setSenderDisplayName('Jason Kaplan');
                //List<String> ccTo = new List<String>();
                //ccTo.add('business@bankofnigeria.com');
                //mail.setCcAddresses(ccTo);
                mail.setSubject('POC Subject');
                String body = 'POC Body, ';
    /*            body += 'I confess this will come as a surprise to you.';
                body += 'I am John Alliston CEO of the Bank of Nigeria.';
                body += 'I write to request your cooperation in this ';
                body += 'urgent matter as I need a foreign partner ';
                body += 'in the assistance of transferring $47,110,000 ';
                body += 'to a US bank account. Please respond with ';
                body += 'your bank account # so I may deposit these funds.';*/
                mail.setHtmlBody(body);
                mails.add(mail);
            }
        }
        Messaging.sendEmail(mails);     
    }
    
}