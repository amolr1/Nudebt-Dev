public class PaymentUpdateTriggerHandler {

    public static void updatePaymentAsDontOverride(List<nu_dse__Payment__c> newPaymentList, Map<Id,nu_dse__Payment__c> oldPaymentMap) {
    
        if (newPaymentList  != null && newPaymentList.isEmpty() == FALSE && oldPaymentMap != null && oldPaymentMap.isEmpty() == FALSE) {
        
            List<RecordType> recTypeList = [SELECT Id,DeveloperName FROM RecordType WHERE sObjectType = 'nu_dse__Payment__c' AND DeveloperName = 'Draft' LIMIT 1];
            
            if (recTypeList.isEmpty() == FALSE) {
            
                for (nu_dse__Payment__c payment : newPaymentList) {
                
                    if(payment.RecordTypeId == recTypeList[0].Id && (payment.nu_dse__Retainer_Fee__c != oldPaymentMap.get(payment.Id).nu_dse__Retainer_Fee__c || payment.nu_dse__Service_Fee__c != oldPaymentMap.get(payment.Id).nu_dse__Service_Fee__c)) {
                    
                        payment.nu_dse__Dont_Override__c = true;
                    }
                }
            }
            
        }
        
    }
}