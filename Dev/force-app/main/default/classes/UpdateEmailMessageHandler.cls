public class UpdateEmailMessageHandler {

    public static void updateEmailMessage() {
    
        EmailMessage msgInstance = new EmailMessage(Id='02s56000000Bv8gAAC', decision_Source__c = 'Internal');
        update msgInstance;
        
        System.debug('***** msg' + msgInstance);
        
        
        
    }
}