public class Attorney_CleanMonthlyMaintenaceFee implements Database.Batchable<Sobject>,Database.stateful,Database.AllowsCallouts{

    public Database.QueryLocator start(Database.BatchableContext BC){
        id draftRecordType = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        //List<nu_dse__Payment__c> Payments = [Select id, nu_dse__Monthly_Maintenance_Fee__c from nu_dse__Payment__c where nu_dse__Monthly_Maintenance_Fee__c != null AND RecordTypeId =: DraftRecordType];
        String query = 'Select id, nu_dse__Monthly_Maintenance_Fee__c from nu_dse__Payment__c where nu_dse__admin_fee != null and nu_dse__Monthly_Maintenance_Fee__c != null AND nu_dse__Monthly_Maintenance_Fee__c>0 AND RecordTypeId =: DraftRecordType AND IsAttorney__c = true';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC,List<nu_dse__Payment__c> Payments){
        List<Id> DraftIds = new List<Id>();
        for(nu_dse__Payment__c Payment: Payments){
            DraftIds.add(Payment.Id);
            Payment.nu_dse__Monthly_Maintenance_Fee__c = 0;
        }
        id draftRecordType = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();
        List<nu_dse__Payment__c> FeePayments = [Select Id,nu_dse__Transaction_Status__c,Payment_Status__c  from nu_dse__Payment__c where nu_dse__Advance_Payment__c =: DraftIds AND nu_dse__Payment_Type__c = 'Maintenance Fee' AND Payment_Status__c != 'Canceled'];
        
        for(nu_dse__Payment__c Payment: FeePayments){
            Payment.nu_dse__Transaction_Status__c = 'Cancelled';
            Payment.Payment_Status__c = 'Canceled';
            Payments.add(Payment);
        }
        Update Payments;
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
    
}