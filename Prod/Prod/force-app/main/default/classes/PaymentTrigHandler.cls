public class PaymentTrigHandler {
    //S20-489 starts
    public static void handleAfterInsert(Map<Id, nu_dse__Payment__c> newPymt){
        set<String> ofrIds = new Set<String>();
        if(newPymt != null && newPymt.size()>0){
            for(nu_dse__Payment__c payment: newPymt.values()){
                if(payment.nu_dse__Offer__c != null){
                    ofrIds.add(payment.nu_dse__Offer__c);
                }
            }
        }
        
        if(ofrIds != null && ofrIds.size()>0){
            updateLastSettlementDate(ofrIds);
        }
    }
    
    public static void handleAfterUpdate(Map<Id, nu_dse__Payment__c> newPymt, Map<Id, nu_dse__Payment__c> oldPymt){
        set<String> ofrIds = new Set<String>();
        if(newPymt != null && newPymt.size()>0){
            for(nu_dse__Payment__c payment: newPymt.values()){
                if(oldPymt.get(payment.Id).nu_dse__Schedule_Date__c != payment.nu_dse__Schedule_Date__c){
                    if(payment.nu_dse__Offer__c != null){
                        ofrIds.add(payment.nu_dse__Offer__c);
                    }
                }
            }
        }
        
        if(ofrIds != null && ofrIds.size()>0){
            updateLastSettlementDate(ofrIds);
        }
    }
    
    public static void handleAfterDelete(Map<Id, nu_dse__Payment__c> oldPymt){
        set<String> ofrIds = new Set<String>();
        if(oldPymt != null && oldPymt.size()>0){
            for(nu_dse__Payment__c payment: oldPymt.values()){
                if(payment.nu_dse__Offer__c != null){
                    ofrIds.add(payment.nu_dse__Offer__c);
                }
            }
        }
        
        if(ofrIds != null && ofrIds.size()>0){
            updateLastSettlementDate(ofrIds);
        }
    }
    
    public static void updateLastSettlementDate(set<String> ofrIds){
        map<Id, nu_dse__Offer__c> offerMap = new map<Id, nu_dse__Offer__c>();
        if(ofrIds != null && ofrIds.size()>0){
            offerMap = new map<Id, nu_dse__Offer__c>([Select Id, Name, Last_Settlement_Payment_Date__c, 
                                                      (Select Id, Name, nu_dse__Schedule_Date__c From nu_dse__Payments__r
                                                       Where nu_dse__Schedule_Date__c != Null Order By nu_dse__Schedule_Date__c)
                                                      From nu_dse__Offer__c 
                                                      Where Id IN: ofrIds]);
            if(offerMap != null && offerMap.size()>0){
                for(nu_dse__Offer__c ofr: offerMap.values()){
                    if(ofr.nu_dse__Payments__r != null && ofr.nu_dse__Payments__r.size()>0){
                        Integer lastkeyIndex=ofr.nu_dse__Payments__r.size()-1;
                        ofr.Last_Settlement_Payment_Date__c=ofr.nu_dse__Payments__r[lastkeyIndex].nu_dse__Schedule_Date__c;
                    }else{
                        ofr.Last_Settlement_Payment_Date__c=null;
                    }
                    offerMap.put(ofr.Id, ofr);
                }
            }
        }
        
        if(offerMap != null && offerMap.size()>0){
            update offerMap.values();
        }
    }
    //S20-489 ends  
}