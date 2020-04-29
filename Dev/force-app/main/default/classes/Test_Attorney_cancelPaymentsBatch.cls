@isTest
public class Test_Attorney_cancelPaymentsBatch {
	
    @isTest 
    public static void testMethod1(){
        
        nu_dse__Program__c objProgram = new nu_dse__Program__c();
        objProgram.Attorney__c = true;
        objProgram.nds_EstimatedSettlement_Amount__c = 655;
        objProgram.Draft_Plan_ID__c = '4564';
        objProgram.nu_dse__Program_Status__c = 'Pending Cancellation';
        Database.Insert(objProgram);
    	
        nu_dse__Payment__c payment = new nu_dse__Payment__c();
        payment.recordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        payment.nu_dse__Program__c =objProgram.Id;
        payment.nu_dse__Schedule_Date__c = Date.today() + 1;
        payment.nu_dse__Transaction_Status__c = 'Pending';
        
        insert Payment;
        List<Id> ProgramIds = new List<Id>();
        ProgramIds.add(ObjProgram.Id);
        Database.executeBatch(new Attorney_cancelPaymentsBatch(ProgramIds));
        
    }
    
}