@isTest
public class Batch_CreateNSFTaskFailedPayment_Test {
    
    @isTest
    static void setupTestData() {
    
        List<nu_dse__Program__c> programs = new List<nu_dse__Program__c>{           
            new nu_dse__Program__c(
                nu_dse__Total_Debt__c = 10000,
                nu_dse__Program_Status__c = 'Active Client'
            )
                };
                    
        insert programs;
        
        Id draftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        Id feeRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();
        
        List<nu_dse__Payment__c> payments = new List<nu_dse__Payment__c>{           
            new nu_dse__Payment__c(
                nu_dse__Program__c = programs[0].Id,
                nu_dse__Amount__c = 100, 
                nu_dse__Schedule_Date__c = System.today().addDays(-5), 
                RecordTypeId = draftRecordTypeId, 
                nu_dse__Transaction_Status__c = 'Failed', 
                nu_dse__Is_Makeup_Payment_Created__c = false, 
                nu_dse__Dont_Consider__c = true,
                Active_NSF_Tasks_Available__c = true
            )
                };
        insert payments;
        
        Test.startTest();                   
        Database.executeBatch(new Batch_CreateNSFTaskFailedPayment() , 50);      
        Test.stopTest();
    }
    
    @isTest
    static void testBatchExecution(){
        
        List<nu_dse__Program__c> programs = new List<nu_dse__Program__c>{           
            new nu_dse__Program__c(
                nu_dse__Total_Debt__c = 10000,
                nu_dse__Program_Status__c = 'Active Client'
            )
        };
                    
        insert programs;
        
        Id draftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        Id feeRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();
        
        List<nu_dse__Payment__c> payments = new List<nu_dse__Payment__c>{           
            new nu_dse__Payment__c(
                nu_dse__Program__c = programs[0].Id,
                nu_dse__Amount__c = 100, 
                nu_dse__Schedule_Date__c = System.today().addDays(-5), 
                RecordTypeId = draftRecordTypeId, 
                nu_dse__Transaction_Status__c = 'Failed', 
                nu_dse__Is_Makeup_Payment_Created__c = false, 
                nu_dse__Dont_Consider__c = true,
                Active_NSF_Tasks_Available__c = False,
                NSF_Date__c = System.Today()
            )
        };
        insert payments;
                       
        Test.startTest();                   
        Database.executeBatch(new Batch_CreateNSFTaskFailedPayment(new Set<Id>{programs[0].Id}) , 50);      
        Test.stopTest();
    }
    
    @isTest
    static void testBatchExecution1(){
        
        List<nu_dse__Program__c> programs = new List<nu_dse__Program__c>{           
            new nu_dse__Program__c(
                nu_dse__Total_Debt__c = 10000,
                nu_dse__Program_Status__c = 'Active Client'
            )
        };
                    
        insert programs;
        
        Id draftRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        Id feeRecordTypeId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();
        
        List<nu_dse__Payment__c> payments = new List<nu_dse__Payment__c>{           
            new nu_dse__Payment__c(
                nu_dse__Program__c = programs[0].Id,
                nu_dse__Amount__c = 100, 
                nu_dse__Schedule_Date__c = System.today().addDays(-5), 
                RecordTypeId = draftRecordTypeId, 
                nu_dse__Transaction_Status__c = 'Failed', 
                nu_dse__Is_Makeup_Payment_Created__c = false, 
                nu_dse__Dont_Consider__c = true,
                Active_NSF_Tasks_Available__c = False,
                NSF_Date__c = System.Today()
            )
        };
        insert payments;
                       
        Test.startTest(); 

            Batch_CreateNSFTaskFailedPayment batchInst = new Batch_CreateNSFTaskFailedPayment(new Set<Id>{programs[0].Id}); 
            batchInst.returnProgramCount = True;
            batchInst.draftSchedulingDate = System.today().addDays(-10);                
            Database.executeBatch(batchInst , 50);
            
        Test.stopTest();
    }
}