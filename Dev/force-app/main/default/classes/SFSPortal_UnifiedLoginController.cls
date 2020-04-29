/* Date : 16-07-2019
 * Author : Team IDev
 * Description : Handles to update the offer status
 */
global with sharing class SFSPortal_UnifiedLoginController {
    
    @AuraEnabled
    public static String login(String username, String password, String startUrl, String domain) {
        
        try{
            String errorMessage = '';
            if (String.isNotBlank(username) && String.isNotBlank(password) &&  String.isNotBlank(domain)) {
                
                Id accountId;
                
                List<User> userList = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE username =:username AND ContactId != null AND Contact.AccountId != null AND isActive = true ORDER BY LastModifiedDate DESC LIMIT 1];
                if (userList != null && userList.isEmpty() == False) {
                    
                    accountId = userList[0].Contact.AccountId;
                    Account acc =  [SELECT Portfolio_Name__c from Account Where id =: accountId];
                    domain = acc.Portfolio_Name__c;
                    System.debug('Portfolio_Name__c '+ domain);
                    List<nu_dse__Program__c> programList = [SELECT Id, Portfolio__c, Portfolio__r.Domain_URL__c, nu_dse__Program_Status__c
                                                            FROM nu_dse__Program__c 
                                                            WHERE nu_dse__Account__c =:accountId AND Portfolio__c != null AND Portfolio__r.Domain_URL__c != null 
                                                            ORDER BY LastModifiedDate DESC LIMIT 1];
                                                            
                    system.debug('programList--->'+programList);
                    if (programList != null && programList.isEmpty() == False) {
                        
                        if (programList[0].nu_dse__Program_Status__c == 'Client Cancelled' || programList[0].nu_dse__Program_Status__c == 'Graduated Program'
                            || programList[0].nu_dse__Program_Status__c == 'Completed Program' || programList[0].nu_dse__Program_Status__c == 'Not Qualified') {
                             
                             throw new CustomException('You dont have access to portal. Please contact salesforce administrator.');
                        }
                         
                        if (String.isNotBlank(programList[0].Portfolio__r.Domain_URL__c)) {
                            
                            startUrl = programList[0].Portfolio__r.Domain_URL__c+'/apex/LoginFlow2FAPage';
                            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
                            aura.redirect(lgn);
                            return null;
                        } else {
                            
                            
                            return 'You are not eleigible to login from this domain.<br/>';
                        }
                    } else {
                        
                        return 'We cannot locate the record based on the information.<br/>';
                    }
                } else {
                    
                    return 'Invalid UserName.<br/>';
                }
                
            } else {
                if (String.isBlank(username)) {
                    
                    errorMessage += 'Enter UserName. <br/>';
                }
                if (String.isBlank(password)) {
                    
                    errorMessage += 'Enter Password. <br/>';
                }
                if (String.isNotBlank(errorMessage)) {
                
                    return errorMessage;
                }
            }
        } catch (Exception ex) {
            
            return ex.getMessage();            
        }
        return null;
    }
    
    @AuraEnabled
    global static String setExperienceId(String expId) {
    
        try {
            if (expId != null) {
                Site.setExperienceId(expId);
            }
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            
        }
    }     
}