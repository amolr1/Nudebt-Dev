public class NSFProgramWithActiveStatusController {
    
    @RemoteAction
    public static List<ProgramAndRecentPaymentWrapper> getNSFPrograms() {
        
        Set<String> programStatusInSet = new Set<String>{'Active Client'};
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('nu_dse__Payment__c').getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = sobjectResult.getRecordTypeInfosByName();    
        
        Id recordTypeId = recordTypeMap.get('Draft').getRecordTypeId();
        Date today = System.today();
        
        System.debug('**recordTypeId'+recordTypeId);
        
        List<ProgramAndRecentPaymentWrapper> programAndRecentPaymentList = new List<ProgramAndRecentPaymentWrapper>();
        
        List<nu_dse__Program__c> monthlyProgramList = [SELECT Id FROM nu_dse__Program__c 
                                                        WHERE nu_dse__Program_Status__c IN :programStatusInSet 
                                                        AND nu_dse__Payment_Frequency__c = 'Monthly' LIMIT 40000];
        List<nu_dse__Program__c> twiceMonthlyProgramList = [SELECT Id FROM nu_dse__Program__c 
                                                                WHERE nu_dse__Program_Status__c IN :programStatusInSet 
                                                                AND nu_dse__Payment_Frequency__c = 'Twice Monthly' LIMIT 40000];
        
        
        List<AggregateResult> programAndItsScheduleAgg1List = [SELECT nu_dse__Program__c, Max(nu_dse__Schedule_Date__c) scheduleDate
                                                                FROM nu_dse__Payment__c 
                                                                WHERE nu_dse__Program__c IN :monthlyProgramList AND RecordTypeId = :recordTypeId 
                                                                AND nu_dse__Transaction_Status__c IN ('Completed', 'Cleared', 'Failed')
                                                                AND nu_dse__Schedule_Date__c <= :today
                                                                Group By nu_dse__Program__c];
        
        List<AggregateResult> programAndItsScheduleAgg2List = [SELECT nu_dse__Program__c, Max(nu_dse__Schedule_Date__c) scheduleDate
                                                                FROM nu_dse__Payment__c 
                                                                WHERE nu_dse__Program__c IN :twiceMonthlyProgramList AND RecordTypeId = :recordTypeId 
                                                                AND nu_dse__Transaction_Status__c IN ('Completed', 'Cleared', 'Failed')
                                                                AND nu_dse__Schedule_Date__c <= :today
                                                                Group By nu_dse__Program__c];                                                        
        
        Set<String> programAndItsScheduleDateSet1 = new Set<String>();
        Set<String> programAndItsScheduleDateSet2 = new Set<String>();
        
        for (AggregateResult aggResult :programAndItsScheduleAgg1List) {
            
            String programId_ScheduleDateString = (Id)(aggResult.get('nu_dse__Program__c')) + '-' + aggResult.get('scheduleDate');
            programAndItsScheduleDateSet1.add(programId_ScheduleDateString);
        }
        
        for (AggregateResult aggResult :programAndItsScheduleAgg2List) {
            
            String programId_ScheduleDateString = (Id)(aggResult.get('nu_dse__Program__c')) + '-' + aggResult.get('scheduleDate');
            programAndItsScheduleDateSet2.add(programId_ScheduleDateString);
        }
        
        List<nu_dse__Payment__c> payment1List = [SELECT Id, nu_dse__Is_Makeup_Payment_Created__c, nu_dse__Transaction_Status__c, nu_dse__Program__c,
                                                    NSF_Date__c, nu_dse__Schedule_Date__c, Active_NSF_Tasks_Available__c 
                                                    FROM nu_dse__Payment__c 
                                                    WHERE nu_dse__Program__c IN :monthlyProgramList AND RecordTypeId = :recordTypeId AND nu_dse__Schedule_Date__c <= :today AND
                                                    ProgramId_And_Schedule_Date__c IN :programAndItsScheduleDateSet1 AND
                                                    (nu_dse__Transaction_Status__c = 'Failed' OR nu_dse__Transaction_Status__c = 'Cleared' OR nu_dse__Transaction_Status__c = 'Completed') 
                                                    ORDER By nu_dse__Schedule_Date__c DESC];
        
        List<nu_dse__Payment__c> payment2List = [SELECT Id, nu_dse__Is_Makeup_Payment_Created__c, nu_dse__Transaction_Status__c, nu_dse__Program__c,
                                                    NSF_Date__c, nu_dse__Schedule_Date__c, Active_NSF_Tasks_Available__c 
                                                    FROM nu_dse__Payment__c 
                                                    WHERE nu_dse__Program__c IN :twiceMonthlyProgramList AND RecordTypeId = :recordTypeId AND nu_dse__Schedule_Date__c <= :today AND
                                                    ProgramId_And_Schedule_Date__c IN :programAndItsScheduleDateSet2 AND
                                                    (nu_dse__Transaction_Status__c = 'Failed' OR nu_dse__Transaction_Status__c = 'Cleared' OR nu_dse__Transaction_Status__c = 'Completed') 
                                                    ORDER By nu_dse__Schedule_Date__c DESC];
       
       for (nu_dse__Payment__c paymentInst :payment1List) {
           
           ProgramAndRecentPaymentWrapper programAndRecentPaymentInst = new ProgramAndRecentPaymentWrapper();
           programAndRecentPaymentInst.programId = paymentInst.nu_dse__Program__c;
           programAndRecentPaymentInst.programStatus = paymentInst.nu_dse__Program__c;
           programAndRecentPaymentInst.paymentName = paymentInst.nu_dse__Program__c;
           programAndRecentPaymentInst.paymentId = paymentInst.nu_dse__Program__c;
           programAndRecentPaymentInst.scheduleDate = paymentInst.nu_dse__Schedule_Date__c;
           programAndRecentPaymentInst.paymentStatus = paymentInst.nu_dse__Program__c;
           
           
       }
       
       for (nu_dse__Payment__c paymentInst :payment2List) {
           
           ProgramAndRecentPaymentWrapper programAndRecentPaymentInst = new ProgramAndRecentPaymentWrapper();
           programAndRecentPaymentInst.programId = paymentInst.nu_dse__Program__c;
           programAndRecentPaymentInst.programStatus = paymentInst.nu_dse__Program__c;
           programAndRecentPaymentInst.paymentName = paymentInst.nu_dse__Program__c;
           programAndRecentPaymentInst.paymentId = paymentInst.nu_dse__Program__c;
           programAndRecentPaymentInst.scheduleDate = paymentInst.nu_dse__Schedule_Date__c;
           programAndRecentPaymentInst.paymentStatus = paymentInst.nu_dse__Program__c;
           
       }
       
       return programAndRecentPaymentList;
    }
    
    public class ProgramAndRecentPaymentWrapper {
        
        public Id programId;
        public String programStatus;
        public String paymentName;
        public Id paymentId;
        public Date scheduleDate;
        public String paymentStatus;
    }
}