@isTest
public class Test_CreditPuller {
    
    @isTest
    public static void testmethod1(){
        User u1 = new User();
        u1.FirstName = 'test';
        u1.LastName = 'test';
        u1.Email = 'test@test.com';
        u1.Attorney_admin__c = false;
        u1.Attorney_Ignore_Validation__c = True;
        u1.UserName = '6Attorney_TestUser@test.com';
        u1.ProfileId = [select id from profile where name = 'System Administrator'].Id;
        u1.alias = 'test';
        u1.Timezonesidkey = 'America/Los_Angeles';
        u1.LocaleSidKey = 'en_US'; 
        u1.EmailEncodingKey = 'UTF-8'; 
        u1.LanguageLocaleKey = 'en_US';
        
        insert u1;
        Account objAccount;
        system.runAs(u1){
            
            String RecTypeId= [select Id from RecordType where (Name='Person Account') and (SobjectType='Account')].Id;
            objAccount = New Account();
            objAccount.Salutation = 'Mr.';
            objAccount.FirstName = 'testAccount';
            objAccount.LastName = 'LastName';
            objAccount.RecordTypeId = RecTypeId;
            objAccount.Attorney__c = true;
            objAccount.PersonBirthdate = Date.today();
            objAccount.PersonMailingCity='Test';
            objAccount.PersonMailingState='Test';
            objAccount.PersonMailingStreet = 'Test';
            objAccount.PersonMailingPostalCode = '12345';
            objAccount.NDS_File_Number__c = 'ABC123';
            
            Database.Insert(objAccount);
            
            nu_dse__Program__c objProgram = new nu_dse__Program__c();
            objProgram.Attorney__c = true;
            objProgram.Import_Id__c = '34324234';
            Database.Insert(objProgram);
            System.debug('objProgram'+objProgram);
            
            nu_dse__TradeLine__c objTradeLine = new nu_dse__TradeLine__c();
            
            //Create Tradeline Object
            
            objTradeLine.nds_Debt_Type__c = 'TestType';
            objTradeLine.nu_dse__Original_Debt__c = 1234;
            objTradeLine.nu_dse__Program__c = objProgram.id;
            objTradeline.applicant_type__c = 'Joint';
            //objTradeLine.nu_dse__Original_Creditor__c = objNewCreditorAccount.id;
            objTradeline.nu_dse__Original_Account_Number__c = '1234';
            objTradeline.nu_dse__New_Account_Number__c = '1234';
            ObjTradeLine.nu_dse__Minimum_Payment_Amount__c=32432;
            ObjTradeline.Negotiator__c = UserInfo.getUserId();
            ObjTradeline.NDS_Negotiator_Id__c ='1234';
            //ObjTradeLine.import_id__c = '34324234';
            Database.Insert(objTradeLine);
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new YourHttpCalloutMockImpl());
        TransUnionCreditPullerHandler.TransUnionWebService(objAccount.Id);
        TransUnionCreditPullerHandler.TransUnionCalloutSync(objAccount);
        Test.stopTest();
        
        
    }
    
    public class YourHttpCalloutMockImpl implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            TransUnionCreditPullerResponse transresponse = new TransUnionCreditPullerResponse();
            response.setBody(JSON.serialize(transResponse));
            response.setStatus('SUCCESS');
            response.setStatusCode(200);
            return response;
        }
    }
    
}