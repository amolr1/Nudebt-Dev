@isTest
public class Test_Attorney_CreateOrUpdateNDSPaymntBat {
    
    @TestSetup
    private static void creatData(){
        
        /*Test.startTest();
        Test.setMock(WebServiceMock.Class, new Test_Attorney_CreateOrUpdateNDSPayment.LeadTraceNetClientMock());
        Test.stopTest();*/
 //Made changes by Rajesh for NMI-882       
        
            NextBatchJobTimings_Push__c batchJobTimings = new NextBatchJobTimings_Push__c ();
        //batchJobTimings.Duration__c = 1000;
        //batchJobTimings.NextBatchJobEndTime__c = DateTime.Now ().addMinutes (-5000);
        //batchJobTimings.NextBatchJobStartTime__c = DateTime.Now ().addMinutes (1000);
        //batchJobTimings.LastSuccessfulRun__c = DateTime.Now ();
        batchJobTimings.Name = 'Testing';
        batchJobTimings.setupOwnerId = UserInfo.getProfileId ();
        
        batchJobTimings.Push_Backup_Duration__c=1440;
        insert batchJobTimings;
        
        
        
        
        //Update User
          User u1 = new User();
        u1.FirstName = 'test';
        u1.LastName = 'test';
        u1.Email = 'test@test.com';
        u1.Attorney_admin__c = false;
        u1.Attorney_Ignore_Validation__c = True;
        u1.UserName = '99Attorney_TestUser@test.com';
        u1.ProfileId = [select id from profile where name = 'System Administrator'].Id;
        u1.alias = 'test';
        u1.Timezonesidkey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US'; 
        u1.EmailEncodingKey = 'UTF-8'; 
        u1.LanguageLocaleKey = 'en_US';
        
        insert u1;
        
    /*    User apiuser = [select id, attorney_admin__c from user where id =: userinfo.getuserid()];
        apiuser.attorney_admin__c = false;
        Database.Update(apiuser);*/
        
        
        
        //Create Program reocrd
        nu_dse__Program__c objProgram = new nu_dse__Program__c();
        objProgram.Attorney__c = true;
        objProgram.Draft_Plan_ID__c= '232343';
        objProgram.Import_id__c = '2323';
        Database.Insert(objProgram);
        
        //Create Account Object
        Id recID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Creditor').getRecordTypeId();
        Account objNewCreditorAccount = new Account();
        objNewCreditorAccount.RecordTypeId = recID;
        objNewCreditorAccount.nu_dse__CFT_Synced__c = true;
        objNewCreditorAccount.Name = 'TestAccount';
        objNewCreditorAccount.campaignId__c = '3432423';
        objNewCreditorAccount.Attorney__c = true;
        objNewCreditorAccount.Best_Day__c = 'Sunday';
        Database.Insert(objNewCreditorAccount);
        
        //Create Tradeline Object
        nu_dse__TradeLine__c objTradeLine = new nu_dse__TradeLine__c();
        objTradeLine.nds_Debt_Type__c = 'TestType';
        objTradeLine.nu_dse__Original_Debt__c = 1234;
        objTradeline.Applicant_Type__c = 'Joint';
        objTradeLine.nu_dse__Program__c = objProgram.id;
        objTradeLine.nu_dse__Original_Creditor__c = objNewCreditorAccount.id;
            objTradeline.nu_dse__Original_Account_Number__c = '1234';

        objTradeLine.Import_id__c = '2323';
        Attorney_StaticVariableUtility.isTradeLineTriggerExecuted = true;
        Database.Insert(objTradeLine);
        Attorney_StaticVariableUtility.isTradeLineTriggerExecuted =false;
        
        //Create Offer Object 
        nu_dse__Offer__c objOffer = new nu_dse__Offer__c();
        objOffer.Approved__c = true;
        objOffer.nu_dse__TradeLine__c = objTradeLine.Id;
        objOffer.nu_dse__Status__c = 'Offer Made';
        objOffer.NDS_Offer_Id__c  = '233';
        //objOffer.IsAttorney__c = True;
        Attorney_StaticVariableUtility.isOfferTriggerExecuted = true;
        Database.insert(objOffer);
        Attorney_StaticVariableUtility.isOfferTriggerExecuted = false;
        
        
        Set<string> reProcessPaymentError = Attorney_StaticVariableUtility.reProcessConfigs('Payment',true);
     // Create Payment Data
        nu_dse__Payment__c objPayment = new nu_dse__Payment__c();
        //objPayment.NDS_External_Id__c = '12345';
        objPayment.nu_dse__Offer__c  = objOffer.Id;
        objPayment.nu_dse__Program__c = objProgram.Id;
        objPayment.RecordTypeId=Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
        objPayment.nu_dse__Schedule_Date__c = Date.valueOf(System.today());
        objPayment.nu_dse__Payment_Sequence_Number__c = 12;
        objPayment.nu_dse__Amount__c = 12.23;
   //     objPayment.nu_dse__Transaction_Status__c = 'Completed';
        objPayment.Statused_On__c = System.today();
        objPayment.Status_Reason__c = 'TestReason';
        objPayment.nu_dse__Payment_Type__c = 'Third Party Fees';
        objPayment.Payment_Type_Data__c = 'TestType';
        objPayment.Draft_Split__c = 213.23;
        objPayment.Legal_Split__c = 1233;
        objPayment.Reserve_Split__c = 23;
        objPayment.Retainer_Split__c = 22223;
        objPayment.Service_Split__c = 232;
        objPayment.Trust_Split__c = 232;
        //objPayment.IsAttorney__c=true;
        //objPayment.IsRelatedRecordEligibleForPick__c= true;
        //Integration_Status__c=:Attorney_StaticVariableUtility.INTEGRATION_FAILED ;
        //objPayment.Integration_Reason__c= 'Payment';
        //objPayment.Integration_Reason_2__c = String.valueOf(reProcessPaymentError); 
        //objPayment.Integration_Status__c = 'Failed';
        Attorney_StaticVariableUtility.isPaymentTriggerExecuted = true;
        Database.Insert(objPayment);
        Attorney_StaticVariableUtility.isPaymentTriggerExecuted = false;
        
        System.debug('***'+[select id, IsAttorney__c,IsRelatedRecordEligibleForPick__c,Integration_Status__c,Integration_Reason__c,Integration_Reason_2__c from nu_dse__Payment__c where id=:objPayment.Id]);
        
        //Create the custome Setting LeadTracCredentials__c
        LeadTracCredentials__c objCredentials = new LeadTracCredentials__c();
        objCredentials.UserName__c = 'dev_team';
        objCredentials.Password__c = 'Password1234';
        objCredentials.Name = 'LeadTrackCredentials';
        Database.Insert(objCredentials);
    
    }
    @isTest static void batchTest () {
        Test.startTest ();
            System.debug('***'+[Select Id from nu_dse__Payment__c where IsAttorney__c=true and IsRelatedRecordEligibleForPick__c= true and 
                                                                                 ((Integration_Status__c = null and Attorney_Payment_Id__c=null) or 
                                                                                  Integration_Status__c=:Attorney_StaticVariableUtility.INTEGRATION_OVERFLOW)]);
            Attorney_CreateOrUpdateNDSPaymentBatch NDSpaymentsBatch = new Attorney_CreateOrUpdateNDSPaymentBatch ();
            Database.executeBatch(NDSpaymentsBatch);
        Test.stoptest ();
    }
}