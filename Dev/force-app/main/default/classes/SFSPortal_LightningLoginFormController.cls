global class SFSPortal_LightningLoginFormController {

    @AuraEnabled
    public static String login(String username, String password, String startUrl, String domain, String portfolioName, String oneSignalInfo) {
       
        try{
            
            String errorMessage = '';
            
            if (String.isNotBlank(username) && String.isNotBlank(password) &&  String.isNotBlank(domain)) {
                
                Id accountId;
                List<User> userList = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE username =:username AND ContactId != null AND Contact.AccountId != null ORDER BY LastModifiedDate DESC LIMIT 1];
                Organization companyInfo = SFSPortal_Utility.getOrgInfo();
                
                if (userList != null && userList.isEmpty() == False) {
                    
                    accountId = userList[0].Contact.AccountId;
                    System.debug('domain '+ domain);
                    Account acc =  [SELECT Portfolio_Name__c from Account Where id =: accountId];
                    System.debug('123 '+ domain);
                    System.debug('profolio name ' + acc);
                    List<nu_dse__Program__c> programList = [SELECT Id, Portfolio__c,Portfolio__r.Name, Portfolio__r.Domain_URL__c, nu_dse__Program_Status__c
                                                            FROM nu_dse__Program__c 
                                                            WHERE nu_dse__Account__c =:accountId AND Portfolio__c != null AND Portfolio__r.Domain_URL__c != null 
                                                            ORDER BY LastModifiedDate DESC LIMIT 1];
                    system.debug('programList--->'+programList);
                    if (programList != null && programList.isEmpty() == False) {
                        
                        if (programList[0].nu_dse__Program_Status__c == 'Client Cancelled' || programList[0].nu_dse__Program_Status__c == 'Graduated Program'
                            || programList[0].nu_dse__Program_Status__c == 'Completed Program' || programList[0].nu_dse__Program_Status__c == 'Not Qualified') {
                             
                             throw new CustomException('You dont have access to portal. Please contact salesforce administrator.');
                        }
                        
                        Id mobileAppInfoId = SFSPortal_Utility.getRecordTypeId('Portal_Settings__c', 'Mobile Domain Info');
                        String query = 'SELECT Id, Mobile_Domain_URL__c, Portfolio_Group__c, Mobile_App_Name__c FROM Portal_Settings__c '
                                       + ' WHERE RecordTypeId =: mobileAppInfoId AND Is_Active__c = TRUE';
                        
                        if(companyInfo.IsSandbox == TRUE && String.isNotBlank(portfolioName) ) {
                        
                            query += ' AND Mobile_App_Name__c = :portfolioName AND Mobile_Domain_URL__c =: domain ';
                        } else {
                        
                            query += ' AND Mobile_Domain_URL__c = :domain ';
                        }
                        List<Portal_Settings__c> mobilePortalSettingsList = Database.query(query+' ORDER BY Lastmodifieddate DESC LIMIT 1');
                        
                        system.debug('mobilePortalSettingsList---->'+mobilePortalSettingsList);
                        system.debug('portfolioName---->'+portfolioName);
                        
                        if (programList[0].Portfolio__r.Domain_URL__c == domain || (mobilePortalSettingsList != null 
                                && mobilePortalSettingsList.isEMpty() == False && mobilePortalSettingsList[0].Portfolio_Group__c != null 
                                && mobilePortalSettingsList[0].Portfolio_Group__c.contains(programList[0].Portfolio__r.Name.replace(' ','')) )) { //|| (!chosenPortfolioList.isEmpty() && chosenPortfolioList.contains(programList[0].Portfolio__r.Name))) {
                            
                            string oneSignalId = '';
                            if (String.isNotBlank(oneSignalInfo)) {
                                
                                Map<String, Object> oneSignalInfoMap = (Map<String, Object>) JSON.deserializeUntyped(oneSignalInfo);
                                system.debug('oneSignalInfoMap --->'+oneSignalInfoMap );
                                
                                if (oneSignalInfoMap  != null &&  oneSignalInfoMap.isempty() == False && oneSignalInfoMap.ContainsKey('oneSignalUserId')) {
                                    
                                    system.debug('oneSignalUserId--->'+oneSignalInfoMap.ContainsKey('oneSignalUserId'));
                                    oneSignalId  = String.ValueOf(oneSignalInfoMap.get('oneSignalUserId'));
                                    SFSPortal_PushNotificationController.pushNotification(oneSignalId, 'Welcome back to Option 1 Legal.Your last login was on '+userList[0].LastLoginDate, 'Welcome', '');
                                    
                                    if (String.isNotBlank(oneSignalId) && programList.isEmpty() == False) {
                                    
                                        updateProgram(oneSignalId, programList);
                                    }
                                }
                            }
                            startUrl = '/apex/LoginFlow2FAPage';
                            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
                            aura.redirect(lgn);
                            return null;
                        } else {
                            /*
                            SFSPortal_Utility.createErrorLogs('SFSPortal_LightningLoginFormController.login', 
                                null, 'You are not eleigible to register from this domain. Domain url is not populated or populated wrongly in the portfolio.', null
                            );
                            */
                            return 'You are not eleigible to login from this domain.<br/>';
                        }
                    } else {
                        /*
                        SFSPortal_Utility.createErrorLogs('SFSPortal_LightningLoginFormController.login', 
                            null, 'Client or portfolio are not populated in program or portfolio domain url not populated in portfolio of program', null
                        );
                        */
                        return 'We cannot locate the record based on the information.<br/>';
                    }
                } else {
                    /*
                    SFSPortal_Utility.createErrorLogs('SFSPortal_LightningLoginFormController.login', 
                        null, 'Invalid UserName or the user is not exist', null
                    );
                    */
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
            /*
            SFSPortal_Utility.createErrorLogs('SFSPortal_LightningLoginFormController.login', 
                null, ex.getMessage(), ex.getStackTraceString()
            );
            */
            return ex.getMessage();            
        }
        return null;
    }
    
    @AuraEnabled
    public static void updateProgram(String oneSignalUserId, List<nu_dse__Program__c> programList) {
        
        List<nu_dse__Program__c> updateProgramList = new List<nu_dse__Program__c>();
            
        for (nu_dse__Program__c program : programList) {
            
            nu_dse__Program__c programInstance = new nu_dse__Program__c(Id = program.Id);
            
            if (String.isNotBlank(program.SFSPortal_OneSignal_App_Id__c) && program.SFSPortal_OneSignal_App_Id__c.contains(oneSignalUserId) == False) {
                    
                programInstance.SFSPortal_OneSignal_App_Id__c = program.SFSPortal_OneSignal_App_Id__c +', ' + oneSignalUserId;                    
            } else {
            
                programInstance.SFSPortal_OneSignal_App_Id__c = oneSignalUserId;
            }
            updateProgramList.add(programInstance);
        }
        if (updateProgramList.isEmpty() == False) {
            
            update updateProgramList;
        }
    }
    
    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }

    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }

    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }

    @AuraEnabled
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }
    
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }

    @AuraEnabled
    global static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {
                Site.setExperienceId(expId);
            }
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            
        }
    }   
    public class OneSignalInfoWrapper {
    
        public String hardware{get; set;}
        public Boolean oneSignalRequiresUserPrivacyConsent{get; set;}
        public String deviceRegKey{get; set;}
        public String osVersion {get; set;}
        public String appId{get; set;}
        public String distribution{get; set;}
        public String os{get; set;}
        public String installationId{get; set;}
        public String platform{get; set;}
        public String timeZone{get; set;}
        public String language{get; set;}
        public String oneSignalUserId{get; set;}
        public Boolean oneSignalSubscribed{get; set;}
        public Boolean isFirstLaunch{get; set;}
        public String publicKey{get; set;}
        public String appVersion{get; set;}
        public String appBuild{get; set;}
        public String model{get; set;}
    }
}