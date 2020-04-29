trigger accountTrigger12 on Account (before update) {
    system.debug('&&&&&&&&&&&&&&' );
    EmailMessage msg = new EmailMessage(Id = '02s56000000C4fDAAS');
    msg.decision_Source__c = 'Email';
    //update msg;
    system.debug('msg --->'+msg );
}