trigger versaraPaymentEditaccess on nu_dse__Payment__c (before update) {
    //Returns the context user's profile ID.
    Id profileId= userinfo.getProfileId();
    String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
    //system.debug('ProfileName'+profileName);
    
     List<String> profileList = new List<String>{'DNL Payments Team Member','System Administrator'};
    set<string> mySet = new Set<String>{'DNL Negotiations Manager', 'DNL Payments Team Member','System Administrator','DNL Negotiations_SF Platform','DNL Payments Manager','Underwriting Manager - SF Platform','Underwriter'};
        
        system.debug('Test>>>> '+mySet.contains('profileName'));
    for (nu_dse__Payment__c payment : Trigger.new) 
    {
        boolean isEditable = false;
        if(payment.DNL_Status__c == 'Converted'){
            if(profileName != 'DNL Payments Team Member' && profileName != 'System Administrator') {
                payment.addError('DNL Payments Team Member can be modified this field, please check with your manager');
            }else{
                isEditable = True;
            }
        }
        for(string str : mySet)
        {
            if(mySet.contains(profileName) && payment.DNL_Status__c == 'Pre-TILA Signed'){
                system.debug('ProfileName '+mySet.contains(profileName) +'and '+payment.DNL_Status__c);
                
                
                
            }else{
                
                if(((profileName!='DNL Negotiations Manager' && profileName!='DNL Payments Team Member'  && profileName!='DNL Negotiations_SF Platform' && profileName!='DNL Payments Manager' && profileName!='Underwriting Manager - SF Platform' && profileName!='Underwriter') && payment.DNL_Status__c != 'Pre-TILA Signed') || isEditable == true)
                {
                    
                }else{
                    system.debug('inside if');
                    payment.addError('Payments of Versara client cannot be modified, please check with your manager');
                }
            }
            
        }
        
        
    }
    
}