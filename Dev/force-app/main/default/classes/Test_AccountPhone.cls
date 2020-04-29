@isTest
public class Test_AccountPhone {

    static testMethod void AccountPhoneMethod(){
        Account a=new Account();
        a.FirstName='Sumit';
        a.LastName='Test';
        a.nu_dse__Best_Phone__c='5555555555';
       // a.nu_dse__Other_Phone__c='6666666666';
        //a.nu_dse__Work_Phone__c='4444444444';
        //a.nu_dse__Cell_phone__c='9999999999';
        //a.PersonHomePhone='8888888888';
        insert a;
        
        Account a1=[select id,phone,nu_dse__Best_Phone__c,nu_dse__Other_Phone__c,PersonHomePhone from Account where id=:a.Id limit 1];
        //a1.nu_dse__Best_Phone__c='5555555555';
        update a1;
        
        //system.assertEquals(a1.phone, a.nu_dse__Best_Phone__c);
        
       /* Account a2=[select id,phone,nu_dse__Best_Phone__c,nu_dse__Other_Phone__c,PersonHomePhone from Account where id=:a.Id limit 1];
        a2.nu_dse__Other_Phone__c='6666666666';
        update a2;
        
        system.assertNotEquals(a2.phone, a.nu_dse__Other_Phone__c);*/
    }
}