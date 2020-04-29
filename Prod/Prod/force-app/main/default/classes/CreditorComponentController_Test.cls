@isTest
public class CreditorComponentController_Test implements HttpCalloutMock {
    
    public static String accountSObj = Account.sObjectType.getDescribe().getName();
    
    @isTest static void testCreditorComponentController() {
        
        Velocify_Settings__c settings = new Velocify_Settings__c();
        settings.Username__c = 'velocifyapi@stratfs.com';
        settings.Password__c = 'hSh0BoeJ';
        insert settings;
        
        List<RecordType> rectypeList = [SELECT id from RecordType WHERE DeveloperName = 'Creditor' AND 
                                       SObjectType =: accountSObj AND isActive = True];
                       
        Account acct = new Account(Name = 'TEST_CreidtorAcc', BillingStreet = 'Test Street', BillingCity = 'Clio', BillingState = 'AL', BillingPostalcode = '94403',
                                   ShippingCity = 'Clio', ShippingState = 'AL', ShippingPostalcode = '94403', RecordTypeId = rectypeList[0].Id, nu_dse__CFT_Synced__c = TRUE);
        insert acct;
        
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        //program.External_Id__c= 'Test_CreateTaskData'; 
        program.External_Id__c= '11223344';  //modified on oct03-2017
        program.nu_dse__Payment_Frequency__c ='Monthly';
        program.nu_dse__Program_length__c = 5;
        insert program; 
                
        nu_dse__TradeLine__c trd = new nu_dse__TradeLine__c();
        trd.nu_dse__program__c = program.id;
        trd.nu_dse__Original_Debt__c = 2.0;
        trd.nu_dse__Original_Account_Number__c = '123654789658';
        trd.nu_dse__New_Account_Number__c = '987654321654';
        trd.nu_dse__Original_Creditor__c = acct.Id;
        trd.nu_dse__New_Creditor__c = acct.Id;//un-commented out on Mar-14-2019
        insert trd;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CreditorComponentController_Test());
        
        List<CreditorComponentController.Creditor> creditorCtr = CreditorComponentController.getCreditors(program.Id);
        
        //System.assertEquals(True, creditorCtr[0].verified);  commented out on oct-03-2017
        
        Test.stopTest();  
        System.assertEquals(true, creditorCtr[0].verified); 
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setStatus('Complete');
        return res;
    }
}