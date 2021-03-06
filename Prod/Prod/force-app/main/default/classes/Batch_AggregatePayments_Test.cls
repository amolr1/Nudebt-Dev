@isTest
public class Batch_AggregatePayments_Test {

    @testSetup
    static void setup() {
    
        Id clientRecTypeId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        Id debtSettlementRecTypeId = Schema.SObjectType.nu_dse__Payment__c .getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        
        nu_dse__Processor__c newProcessor = TestRecordCreator.createProcessor();
        Insert newProcessor;
        
        List<Account> accountList = new List<Account>();
        
        Account accountInstance1 = TestRecordCreator.createAccount(clientRecTypeId);   
        accountInstance1.nu_dse__External_CFT_ID__c = '123456';
        accountList.add(accountInstance1);
        
        Account accountInstance2 = TestRecordCreator.createAccount(clientRecTypeId);   
        accountInstance2.nu_dse__External_CFT_ID__c = '123457';
        accountList.add(accountInstance2);
        
        insert accountList;
        
        List<nu_dse__Program__c> programList = new List<nu_dse__Program__c>();
        
        nu_dse__Program__c activeProgram = TestRecordCreator.createProgram(accountList[0].Id, newProcessor.Id, 'Active');
        programList.add(activeProgram);
        
        nu_dse__Program__c pendingProgram = TestRecordCreator.createProgram(accountList[1].Id, newProcessor.Id, 'Pending Creation');
        programList.add(pendingProgram );
        
        insert programList;
        
        List<nu_dse__Payment__c> activePaymentList = new List<nu_dse__Payment__c>();
        
        nu_dse__Payment__c depositPayment1 = TestRecordCreator.createPayment(programList[0].Id, 'Completed', 'Deposit', debtSettlementRecTypeId, null);
        depositPayment1.nu_dse__Processor_Fee__c = 100;
        activePaymentList.add(depositPayment1);
        
        nu_dse__Payment__c depositPayment2 = TestRecordCreator.createPayment(programList[0].Id, 'Completed', 'Deposit', debtSettlementRecTypeId, null);
        depositPayment2.nu_dse__Processor_Fee__c = 200;
        activePaymentList.add(depositPayment2);
        
        nu_dse__Payment__c depositPayment3 = TestRecordCreator.createPayment(programList[0].Id, 'In Progress', 'Deposit', debtSettlementRecTypeId, null);
        depositPayment2.nu_dse__Processor_Fee__c = 150;
        activePaymentList.add(depositPayment3);
        
        nu_dse__Payment__c adminFeePayment1 = TestRecordCreator.createPayment(programList[0].Id, 'Completed', 'Admin Fee', debtSettlementRecTypeId, null);
        adminFeePayment1.nu_dse__Processor_Fee__c = 100;
        activePaymentList.add(adminFeePayment1);
        
        nu_dse__Payment__c adminFeePayment2 = TestRecordCreator.createPayment(programList[0].Id, 'Completed', 'Admin Fee', debtSettlementRecTypeId, null);
        adminFeePayment2.nu_dse__Processor_Fee__c = 200;
        activePaymentList.add(adminFeePayment2);
        
        nu_dse__Payment__c adminFeePayment3 = TestRecordCreator.createPayment(programList[0].Id, 'In Progress', 'Admin Fee', debtSettlementRecTypeId, null);
        adminFeePayment3.nu_dse__Processor_Fee__c = 150;
        activePaymentList.add(adminFeePayment3);
        
        insert activePaymentList;
        
        List<nu_dse__Payment__c> pendingPaymentList = new List<nu_dse__Payment__c>();
        
        nu_dse__Payment__c depositPayment4 = TestRecordCreator.createPayment(programList[1].Id, 'Completed', 'Deposit', debtSettlementRecTypeId, null);
        depositPayment4.nu_dse__Processor_Fee__c = 180;
        pendingPaymentList.add(depositPayment4);
        
        nu_dse__Payment__c depositPayment5 = TestRecordCreator.createPayment(programList[1].Id, 'Completed', 'Deposit', debtSettlementRecTypeId, null);
        depositPayment5.nu_dse__Processor_Fee__c = 220;
        pendingPaymentList.add(depositPayment5);
        
        nu_dse__Payment__c depositPayment6 = TestRecordCreator.createPayment(programList[1].Id, 'In Progress', 'Deposit', debtSettlementRecTypeId, null);
        depositPayment6.nu_dse__Processor_Fee__c = 50;
        pendingPaymentList.add(depositPayment6);
        
        insert pendingPaymentList;                               
    }
    
    static testMethod void defaultFilter() {
            
        Test.startTest();           
        Schedule_AggregatePayments aggregatePayment = new Schedule_AggregatePayments();
        String CRON_EXP = '0 0 * * * ?';
        System.schedule('Payment Aggregation Schedule job', CRON_EXP, aggregatePayment);
        Batch_AggregatePayments aggregatePaymentBatch = new Batch_AggregatePayments();
        Database.executeBatch(aggregatePaymentBatch , 50);      
        Test.stopTest(); 
        
        List<nu_dse__Program__c> queriedProgramList = [SELECT Id, Expected_Accumulation__c, Current_Accumulation__c, Remaining_Accumulation__c
                                                        FROM nu_dse__Program__c];
        System.assertEquals(2,queriedProgramList.size());
        System.assertEquals(queriedProgramList[0].Expected_Accumulation__c-queriedProgramList[0].Current_Accumulation__c,queriedProgramList[0].Remaining_Accumulation__c);
        System.assertEquals(queriedProgramList[1].Expected_Accumulation__c-queriedProgramList[1].Current_Accumulation__c,queriedProgramList[1].Remaining_Accumulation__c);    
    }
    
    static testMethod void withqueryString() {
            
        Test.startTest();   
        Schedule_AggregatePayments aggregatePayment = new Schedule_AggregatePayments();
        aggregatePayment.batchSize = 5;
        aggregatePayment.queryString = 'nu_dse__Processor_Status__c = \'Active\'';
        String CRON_EXP = '0 0 * * * ?';
        System.schedule('Payment Aggregation Schedule job', CRON_EXP, aggregatePayment);
        Batch_AggregatePayments aggregatePaymentBatch = new Batch_AggregatePayments();
        aggregatePaymentBatch.queryString = 'nu_dse__Processor_Status__c = \'Active\'';
        Database.executeBatch(aggregatePaymentBatch , 5);      
        Test.stopTest(); 
        
        List<nu_dse__Program__c> queriedProgramList = [SELECT Id, Expected_Accumulation__c, Current_Accumulation__c, Remaining_Accumulation__c
                                                        FROM nu_dse__Program__c WHERE nu_dse__Processor_Status__c = 'Active'];
        System.assertEquals(1,queriedProgramList.size());
        System.assertEquals(queriedProgramList[0].Expected_Accumulation__c-queriedProgramList[0].Current_Accumulation__c,queriedProgramList[0].Remaining_Accumulation__c);
    }
    
    static testMethod void withCustomSetting() {
        
        Aggregate_Payments__c aggregatePaymentCustomSettings = new Aggregate_Payments__c();
        aggregatePaymentCustomSettings.Name = 'Aggregate_Payments__c';
        aggregatePaymentCustomSettings.Program_Query_Filter__c = 'nu_dse__Processor_Status__c = \'Active\'';
        
        insert aggregatePaymentCustomSettings;
 
        Test.startTest();   
        Schedule_AggregatePayments aggregatePayment = new Schedule_AggregatePayments();
        aggregatePayment.batchSize = 5;
        String CRON_EXP = '0 0 * * * ?';
        System.schedule('Payment Aggregation Schedule job', CRON_EXP, aggregatePayment);
        Batch_AggregatePayments aggregatePaymentBatch = new Batch_AggregatePayments();
        Database.executeBatch(aggregatePaymentBatch , 5);        
        Test.stopTest(); 
        
        List<nu_dse__Program__c> queriedProgramList = [SELECT Id, Expected_Accumulation__c, Current_Accumulation__c, Remaining_Accumulation__c
                                                        FROM nu_dse__Program__c WHERE nu_dse__Processor_Status__c = 'Active'];
        System.assertEquals(1,queriedProgramList.size());
        System.assertEquals(queriedProgramList[0].Expected_Accumulation__c-queriedProgramList[0].Current_Accumulation__c,queriedProgramList[0].Remaining_Accumulation__c);
    }
}