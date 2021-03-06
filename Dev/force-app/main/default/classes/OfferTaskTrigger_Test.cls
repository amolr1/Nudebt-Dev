@isTest
public class OfferTaskTrigger_Test{

    static testMethod void ToCancelTask() {
    
        Account accountInstance = TestRecordCreator.createAccount('Record', TestRecordCreator.getRecordTypeId('Account', 'Client'));
        accountInstance.Phone = '8986565676';
        insert accountInstance;
        
        nu_dse__Program__c programInstance = TestRecordCreator.createProgram(accountInstance.id, null);
        insert programInstance;
        
        Account credAcc = TestRecordCreator.createCreditorAccount(TestRecordCreator.getRecordTypeId('Account', 'Creditor'));
        insert credAcc;
        
        nu_dse__TradeLine__c tradeline = TestRecordCreator.createTradeLine(credAcc.Id, programInstance.Id);
        tradeline.SFS_Current_Balance__c = 1;
        insert tradeline;
        
        nu_dse__Offer__c offerInstance = TestRecordCreator.createoffer(programInstance.Id,tradeline.Id, 5000, 300, 6, 2);
        offerInstance.Tradeline_Litigation_Status__c='Lit';
        insert offerInstance;
        
        Task taskInstance = TestRecordCreator.createTask(offerInstance.Id);
        taskInstance.Subject = 'Pending Client Approval (Voice)';
        insert taskInstance;
        
        Task taskInstance1 = TestRecordCreator.createTask(offerInstance.Id);
        taskInstance1.Subject = 'Pending Client Approval (SMS)';
        insert taskInstance1;
        
        Task taskInstance2 = TestRecordCreator.createTask(offerInstance.Id);
        taskInstance2.Subject = 'Pending Client Approval (Email)';
        insert taskInstance2;
        
        Test.startTest();
            
            offerInstance.Authorization_Received__c = True;
            update offerInstance;

        Test.stopTest();
        List<Task> taskQuery = [SELECT id, Status FROM Task WHERE Status = 'Canceled'];
        System.assertEquals(taskQuery.isEmpty(),False);
    }

    static testMethod void ToUpdateOfferRecord(){
    
        Account accountInstance = TestRecordCreator.createAccount('Record', TestRecordCreator.getRecordTypeId('Account', 'Client'));
        accountInstance.Phone = '8986565676';
        insert accountInstance;
        
        nu_dse__Program__c programInstance = TestRecordCreator.createProgram(accountInstance.id, null);
        insert programInstance;
        
        Account credAcc = TestRecordCreator.createCreditorAccount(TestRecordCreator.getRecordTypeId('Account', 'Creditor'));
        insert credAcc;
        
        nu_dse__TradeLine__c tradeline = TestRecordCreator.createTradeLine(credAcc.Id, programInstance.Id);
        tradeline.SFS_Current_Balance__c = 1;
        insert tradeline;
        
        nu_dse__Offer__c offerInstance = TestRecordCreator.createoffer(programInstance.Id,tradeline.Id, 5000, 300, 6, 2);
        offerInstance.Tradeline_Litigation_Status__c='Lit';
        //Below 2 lines are updated for S20-19
        offerInstance.Type_of_Settlement__c = ''; 
        offerInstance.Source_of_Payment__c = '';
        insert offerInstance;
        
        offerInstance.Type_of_Settlement__c = 'Settlement'; 
        offerInstance.Source_of_Payment__c = 'PSA';
        
        Test.startTest();
        update offerInstance;
        Test.stopTest();
    }
   static testMethod void ToLockOfferRecord() {
    
        List<nu_dse__Offer__c> offers = new List<nu_dse__Offer__c>();
        
        Account accountInstance = TestRecordCreator.createAccount('Record', TestRecordCreator.getRecordTypeId('Account', 'Client'));
        accountInstance.Phone = '8986565676';
        insert accountInstance;
        
        nu_dse__Fee_Template__c feeTemp = new nu_dse__Fee_Template__c(Name = 'Test', External_Id__c = '112233');
        insert feeTemp;
        
        nu_dse__Fee_Item__c feeItem = new nu_dse__Fee_Item__c(Name = 'Test', nu_dse__Fee_Template__c = feeTemp.Id,
                                          nu_dse__Fee_Amount__c = 100, nu_dse__Percent__c =10, RecordTypeId = TestRecordCreator.getRecordTypeId('nu_dse__Fee_Item__c', 'Settlement Fee'));
        insert feeItem;
        
        Account credAcc = TestRecordCreator.createCreditorAccount(TestRecordCreator.getRecordTypeId('Account', 'Creditor'));
        insert credAcc;
        
        nu_dse__Program__c programInstance = TestRecordCreator.createProgram(accountInstance.id, null);
        programInstance.nu_dse__Fee_Template__c = feeTemp.Id;
        programInstance.RecordTypeId = TestRecordCreator.getRecordTypeId('nu_dse__Program__c', 'Attorney');
        programInstance.import_id__c = '123456456offertest';
        insert programInstance;
        
        nu_dse__TradeLine__c tradeline = TestRecordCreator.createTradeLine(credAcc.Id, programInstance.Id);
        tradeline.SFS_Current_Balance__c = 1;
        insert tradeline;
        
        nu_dse__Offer__c offerInstance = TestRecordCreator.createoffer(programInstance.Id,tradeline.Id, 5000, 300, 6, 2);
        offerInstance.Tradeline_Litigation_Status__c='Lit';
        offerInstance.Renegotiable__c = True;
        offers.add(offerInstance);
        
        nu_dse__Offer__c offerInstance1 = TestRecordCreator.createoffer(programInstance.Id,tradeline.Id, 5000, 300, 6, 2);
        offerInstance1.Tradeline_Litigation_Status__c='Lit';
        offers.add(offerInstance1);
        
        insert offers;
            
        Test.startTest();
        
            offerInstance.Is_submitted_for_Approval_process__c = True;
            update offerInstance;
            
            offerInstance.Is_submitted_for_Approval_process__c = False;
            //Below 3 lines are updated for S20-178
            offerInstance.nu_dse__Status__c = 'Management Review';
            offerInstance.Source_of_Payment__c = 'Client Direct';
            offerInstance.Tradeline_Litigation_Status__c = 'Lit';
            update offerInstance;
            
            //This code is not need for now... So commented out. Don't move this change to other orgs.
            /*
            nu_dse__Payment__c paymentInstance = TestRecordCreator.createPayments(programInstance.ID);
            paymentInstance.Integration_Status__c = 'Success';
            paymentInstance.Attorney_Payment_Id__c = '1234';
             paymentInstance.nu_dse__Transaction_Status__c = 'Pending';
            paymentInstance.RecordTypeId = TestRecordCreator.getRecordTypeId('nu_dse__Payment__c', 'Settlement');
            paymentInstance.nu_dse__Offer__c = offerInstance.Id;
            insert paymentInstance;
            */
            
            offerInstance1.nu_dse__Status__c = 'Accepted';
            update offerInstance1 ;
            
        Test.stopTest();
        
        List<nu_dse__Offer__c> offerList = [SELECT Id, nu_dse__Status__c FROM nu_dse__Offer__c WHERE Id =:offerInstance.Id];
        System.assertEquals('Canceled', offerList[0].nu_dse__Status__c );  
        
        //Assert check for S20-178
        List<ProcessInstance> processInstances = [SELECT Id, Status FROM ProcessInstance WHERE TargetObjectId = :offerInstance.Id]; 
        System.assertEquals('Rejected', processInstances[0].Status);
    }
}