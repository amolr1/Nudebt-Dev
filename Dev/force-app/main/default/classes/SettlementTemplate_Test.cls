@isTest
public class SettlementTemplate_Test {

    static testMethod void getSettlementsTest() {
    
        Id clientRecTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        Id creditorRecTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Creditor').getRecordTypeId();
        Id settlementRecTypeId = Schema.SObjectType.nu_dse__Payment__c .getRecordTypeInfosByName().get('Settlement').getRecordTypeId();
        
        Account acc = TestRecordCreator.createCreditorAccount(creditorRecTypeId);
        insert acc;
        
        nu_dse__Program__c  pgm = TestRecordCreator.createProgram();
        insert pgm;
        
        nu_dse__TradeLine__c tl = TestRecordCreator.createTradeLine(acc.Id, pgm.Id);
        insert tl;
        
        nu_dse__Offer__c off = TestRecordCreator.createoffer(pgm.Id, tl.Id, 100, 500, 5, 10);
        insert off;
        
        nu_dse__Payment__c  pay = TestRecordCreator.createPayment(pgm.Id, 'Pending', 'Withdrawal', settlementRecTypeId , off.Id);
        insert pay;
        
        Test.startTest();
        
        PageReference testPage = new pagereference('/apex/VisualforcePage');
        ApexPages.currentPage().getParameters().put( 'id', pgm.id );
        
        settlementTemplate temp = new settlementTemplate();
        temp.getPayments();
               
        Test.stopTest();
    }
}