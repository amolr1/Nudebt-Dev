/* Date : 24-10-2018
 * Author : Team IDev
 * Description : Handles to get task 
 */
public class SFSPortal_ClientsTaskController {

    /* Date : 24-10-2018
     * Description : Method to get Task Info of the current user
     * Invoked From : doInit Method in clientTask lightning component 
     */
    @AuraEnabled
    public static DefaultTaskWrapper getTaskList() {
        
        try {
        
            Id accountId, programId;
            DefaultTaskWrapper defaultWrap = new DefaultTaskWrapper();
            defaultWrap.isClientTaskVisible = FeatureManagement.checkPermission('Client_Task');
            defaultWrap.isRescheduleNSF = FeatureManagement.checkPermission('Reschedule_NSF');
            defaultWrap.isOfferListVisible = FeatureManagement.checkPermission('Offer_List');
            defaultWrap.isOfferDecision = FeatureManagement.checkPermission('Offer_Decision');
            
            if (defaultWrap.isClientTaskVisible == true || defaultWrap.isOfferListVisible == true) {
                
                Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser();
                List<nu_dse__Program__c> programList = new List<nu_dse__Program__c>();
                List<String> listViewFields = new List<String>();
                Map<String, Schema.SObjectField> fieldMap = nu_dse__Offer__c.sObjectType.getDescribe().fields.getMap();    
                Map<String, Schema.SObjectField> fieldMapTask = Task.sObjectType.getDescribe().fields.getMap();       
                
                if (accountIdMap != null && accountIdMap.isEmpty() == False) {
                    
                    if (accountIdMap.ContainsKey('primaryAccountId') == True && accountIdMap.get('primaryAccountId') != null) {
                        
                        accountId = accountIdMap.get('primaryAccountId');
                        programList = [SELECT Id, Name, Portfolio__c, Portfolio__r.Support_Phone_Number__c, Portfolio__r.Dispay_Name__c, nu_dse__Program_Status__c 
                                       FROM nu_dse__Program__c 
                                       WHERE nu_dse__Account__c =: accountId AND Portfolio__c != null]; 
                        
                        if (programList != null && programList.isEmpty() == False) {
                            
                            programId = programList[0].id;
                            defaultWrap.program = programList[0];
                        }
                    }
                       
                    for (Schema.FieldSetMember fieldMember : Schema.SObjectType.nu_dse__Offer__c.fieldSets.Pending_Approval_Detail_View.getFields()) {
                        
                        defaultWrap.detailFields.add(fieldMember.getFieldPath());
                    }
                               
                    for (Schema.FieldSetMember fieldMember : Schema.SObjectType.nu_dse__Offer__c.fieldSets.Pending_Approvals_List_View.getFields()) {
                        
                        Schema.DescribeFieldResult child = fieldMap.get(fieldMember.getFieldPath()).getDescribe();
                        String relationName = child.getRelationshipName();
                        
                        if ((String.valueOf(fieldMember.getType())).toLowercase() == 'reference') {
                        
                            defaultWrap.listFields.add(new SFSPortal_TradelineListController.FieldSetMemberWrapper(fieldMember.getRequired() || fieldMember.getDbRequired(),(String.valueOf(fieldMember.getType())).toLowercase(),fieldMember.getLabel(),fieldMember.getFieldPath(),relationName));
                            listViewFields.add(relationName +'.Name');
                        } else {
                        
                            defaultWrap.listFields.add(new SFSPortal_TradelineListController.FieldSetMemberWrapper(fieldMember.getRequired() || fieldMember.getDbRequired(),(String.valueOf(fieldMember.getType())).toLowercase(),fieldMember.getLabel(),fieldMember.getFieldPath(),''));
                            listViewFields.add(fieldMember.getFieldPath());
                        }
                    }
                }
                
                if (defaultWrap.isClientTaskVisible == true && String.isNotBlank(programId)) {                    
                    
                    String query = 'SELECT Id, Call_Type__c, NSF_payment_18_Digit__c, ActivityDate ';
                    for(Schema.FieldSetMember fieldMember : Schema.SObjectType.Task.fieldSets.Task_List_View.getFields()) {
                        
                        if (fieldMember.getFieldPath() != 'Call_Type__c' && fieldMember.getFieldPath() != 'NSF_payment_18_Digit__c' 
                            && fieldMember.getFieldPath() != 'ActivityDate') {
                        
                            query += ', '+fieldMember.getFieldPath();
                        }
                        if ((String.valueOf(fieldMember.getType())).toLowercase() == 'reference') {
        
                            defaultWrap.listViewFields.add(new SFSPortal_TradelineListController.FieldSetMemberWrapper(fieldMember.getRequired() || 
                                                           fieldMember.getDbRequired(),(String.valueOf(fieldMember.getType())).toLowercase(),fieldMember.getLabel(),
                                                           fieldMember.getFieldPath(),fieldMapTask.get(fieldMember.getFieldPath()).getDescribe().getRelationshipName()));
                        } else {
                        
                            defaultWrap.listViewFields.add(new SFSPortal_TradelineListController.FieldSetMemberWrapper(fieldMember.getRequired() || fieldMember.getDbRequired(),
                                                           (String.valueOf(fieldMember.getType())).toLowercase(),fieldMember.getLabel(),fieldMember.getFieldPath(),''));
                        }
                    }
                    query += ' FROM Task WHERE Clients_task__c = true AND WhatId =: programId AND Status = \''+'Not Started'+'\'';
                    
                    system.debug('query--->'+query);
                    
                    if(programList[0].nu_dse__Program_Status__c != 'Active Client') {
                    
                        Map<Id, Task> paymentAndTaskMap = new Map<Id, Task>();
                        for(Task nsfTaskInstance : Database.query (query + ' AND Call_Type__c = \''+'NSF'+'\' AND NSF_payment_18_Digit__c != null ORDER BY CreatedDate ASC, Priority DESC NULLS LAST')) {
                            
                            paymentAndTaskMap.put(nsfTaskInstance.NSF_payment_18_Digit__c, nsfTaskInstance);
                        }
                        if(paymentAndTaskMap.isEmpty() == FALSE) {
                        
                            for(nu_dse__Payment__c payment : [SELECT Id, nu_dse__Advance_Payment__c 
                                                              FROM nu_dse__Payment__c 
                                                              WHERE nu_dse__Advance_Payment__c IN :paymentAndTaskMap.keySet() 
                                                              AND nu_dse__Advance_Payment__r.nu_dse__Is_Makeup_Payment_Created__c = TRUE]) {
                                
                                if(paymentAndTaskMap.containsKey(payment.nu_dse__Advance_Payment__c) == TRUE) {
                                
                                    paymentAndTaskMap.remove(payment.nu_dse__Advance_Payment__c);
                                }
                            }
                        }
                        if(paymentAndTaskMap.isEmpty() == FALSE) {
                        
                            defaultWrap.taskList.addAll(paymentAndTaskMap.values());
                        }
                    }
                    Date fromDate = system.today().AddDays(-30);
                    Date toDate = system.today().AddDays(3);
                    defaultWrap.taskList.addAll((List<Task>)Database.query (query+ ' AND ActivityDate <=: toDate AND ActivityDate >=: fromDate AND Call_Type__c != \''+'NSF'+'\' ORDER BY CreatedDate ASC, Call_Type__c ASC, Priority DESC NULLS LAST'));                       
                }
                if (defaultWrap.isOfferListVisible == true) {
                
                    if (accountId != null && listViewFields.isEmpty() == False) {
                        
                        String query = 'SELECT Id, Name, Available_for_Client_Review__c, Original_Balance__c, nu_dse__Offer_Amount__c, nu_dse__First_Payment_Date__c, '
                                        + 'SFSPortal_Original_Creditor__c, Current_Balance__c, Tradeline_Litigation_Status__c, Source_of_Payment__c, Created_Date_Time__c ';
                        
                        for (String field : listViewFields) {
                            
                            if (field != 'Name' && field != 'Available_for_Client_Review__c' && field != 'Original_Balance__c' && field != 'Created_Date_Time__c' &&
                                field != 'nu_dse__Offer_Amount__c' && field != 'nu_dse__First_Payment_Date__c' && field != 'SFSPortal_Original_Creditor__c' && 
                                field != 'Current_Balance__c' && field != 'Tradeline_Litigation_Status__c' && field != 'Source_of_Payment__c') {
                                
                                query += ', '+field;
                            }
                        }
                        query += ' FROM nu_dse__Offer__c WHERE nu_dse__Program__c != null AND nu_dse__Program__r.nu_dse__Account__c != null'
                                 + ' AND nu_dse__Program__r.nu_dse__Account__c = :accountId AND Authorization_Received__c = FALSE ';
                        
                        if (defaultWrap.program.Portfolio__r.Dispay_Name__c == 'Timberline Financial') {
                            
                            query += ' AND nu_dse__Status__c = \''+'Management Approved'+'\' ';
                        } else if (defaultWrap.program.Portfolio__r.Dispay_Name__c == 'Royal Legal Group') {
                            
                            query += ' AND nu_dse__Status__c = \''+'In-House Attorney Approved'+'\' ';
                        } else if ((defaultWrap.program.Portfolio__r.Dispay_Name__c != 'Timberline Financial') && (defaultWrap.program.Portfolio__r.Dispay_Name__c != 'Royal Legal Group')) {
                            
                            query += ' AND nu_dse__Status__c = \''+'Pending Creditor Approval'+'\' ';
                        }
                                                
                        for (nu_dse__Offer__c offer : Database.query (query + ' ORDER BY CreatedDate ASC')) {
                            
                            if ((system.today().daysBetween(offer.nu_dse__First_Payment_Date__c)) > 2 ) {
                                
                                defaultWrap.offerList.add(offer);
                            }
                        }
                    }
                } 
            }
            return defaultWrap;
        } catch(Exception e) {
        
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /* Date : 24-10-2018
     * Description : Method to get Task Info of the current user
     * Invoked From : doInit Method in clientTask lightning component 
     */
    @AuraEnabled
    public static ViewInfoWrapper getViewInfo(String taskId, String callType) {
    
        try {
        
            ViewInfoWrapper viewInfo = new ViewInfoWrapper();
                        
            for(Schema.SObjectField fieldAPI : Portal_Settings__c.sObjectType.getDescribe().fields.getMap().values()) {
            
                viewInfo.helpTextMap.put(String.valueOf(fieldAPI), fieldAPI.getDescribe().getInlineHelpText() != null ? fieldAPI.getDescribe().getInlineHelpText() : '');
            }
            if (String.isNotBlank(taskId)) {
                
                List<Task> taskList = [SELECT Id, WhatId, Call_Type__c FROM Task WHERE Id =:taskId LIMIT 1];
                
                if (taskList != null && taskList.isEmpty() == False && taskList[0].WhatId != null) {
                    
                    List<nu_dse__Program__c> programList = [SELECT Id, Portfolio__c FROM nu_dse__Program__c WHERE Id =:taskList[0].WhatId AND Portfolio__c != null ];
                    
                    if (programList.isEmpty() == False) {
                                                
                        List<Portfolio__c> portfolioList = [SELECT Id, Business_Hours__c, Support_Phone_Number__c 
                                                            FROM Portfolio__c WHERE Id =:programList[0].Portfolio__c ];
                                                            
                        if (portfolioList != null && portfolioList.isEmpty() == False) {
                            
                            viewInfo.portfolio = portfolioList[0];
                        } else {
                            
                            throw new CustomException('There is no required information populated.Please contact your administrator.');
                        }
                    }
                }
                return viewInfo;
            }
        } catch(Exception e) {
        
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    public class DefaultTaskWrapper {
        
        @AuraEnabled
        public nu_dse__Program__c program = new nu_dse__Program__c();
        
        @AuraEnabled
        public List<Task> taskList = new List<Task>();
        
        @AuraEnabled
        public List<nu_dse__Offer__c> offerList = new List<nu_dse__Offer__c>();
        
        @AuraEnabled
        public List<String> detailFields = new List<String>();
        
        @AuraEnabled
        public List<SFSPortal_TradelineListController.FieldSetMemberWrapper> listViewFields = new List<SFSPortal_TradelineListController.FieldSetMemberWrapper>();
        
        @AuraEnabled
        public List<SFSPortal_TradelineListController.FieldSetMemberWrapper> listFields = new List<SFSPortal_TradelineListController.FieldSetMemberWrapper>();
        
        @AuraEnabled
        public Boolean isClientTaskVisible = True;
        
        @AuraEnabled
        public Boolean isOfferListVisible = True;
        
        @AuraEnabled
        public Boolean isOfferDecision = False;
        
        @AuraEnabled
        public Boolean isRescheduleNSF = False;
    }      
    
    public class ViewInfoWrapper {
        
        @AuraEnabled
        public Portfolio__c portfolio = new Portfolio__c();
        
        @AuraEnabled
        public Map<String,String> helpTextMap = new Map<String,String>(); 
    } 
}