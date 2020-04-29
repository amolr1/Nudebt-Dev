/**
 * Name      	:    PaymentTriggerHandler
 * Date      	:    11/12/2019
 * Author    	:    Amit Goyal
 * Description  :    Created for S20-433 and S20-459 
 * 					- S20-433: Trigger to Delete RAM Child Fees
 * 					- S20-459: NSF Cancellations To Create Payments Task
*/

public class PaymentTriggerHandler {
    public static boolean hasAlreadyRanAfterUpdate=false;
    
    // Changes done by Amit Goyal for S20-433 and  - Starts Here
    public static void handlerAfterUpdate(Map<id,nu_dse__Payment__c> newPayments, map<id,nu_dse__Payment__c> oldPayments){
        if(!hasAlreadyRanAfterUpdate){
            hasAlreadyRanAfterUpdate=true;
        }
        if(newPayments != null && newPayments.size()>0){
            map<String, String> paymentProgMap = new map<String, String>();
            set<String> nsfCancellationPaymentIds = new set<String>();
            set<String> ramPaymentIds = new set<String>();
            Id draftRTId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
            
            for(nu_dse__Payment__c p: newPayments.values()){
                if(oldPayments.get(p.Id).Program_Status__c=='UnResponsive NSF' && p.Program_Status__c=='Client Cancelled'){
                    // for S20-459
                    nsfCancellationPaymentIds.add(p.Id);
                    if(p.nu_dse__Program__c != null){
                        paymentProgMap.put(p.Id, p.nu_dse__Program__c);
                    }
                }
                
                if(p.RecordTypeId==draftRTId && p.Processor__c.startsWith('RAM')){
                    // for S20-433
                    if(label.RAM_Child_Fee_Cleanup_Test == ''){
                        if(oldPayments.get(p.Id).nu_dse__Transaction_Status__c!=p.nu_dse__Transaction_Status__c && 
                           (p.nu_dse__Transaction_Status__c=='Completed' || p.nu_dse__Transaction_Status__c=='Cleared' ||
                            p.nu_dse__Transaction_Status__c=='Failed' || p.nu_dse__Transaction_Status__c=='Cancelled'))
                        {
                            // collect RAM payment id to delete all child payments of Fee RecordType
                            ramPaymentIds.add(p.Id); 
                        }
                    } else {
                        if((p.nu_dse__Transaction_Status__c=='Completed' || p.nu_dse__Transaction_Status__c=='Cleared' ||
                            p.nu_dse__Transaction_Status__c=='Failed' || p.nu_dse__Transaction_Status__c=='Cancelled'))
                        {
                            // collect RAM payment id to delete all child payments of Fee RecordType
                            ramPaymentIds.add(p.Id); 
                        }
                    }
                }
            }
            
            if(nsfCancellationPaymentIds != null && nsfCancellationPaymentIds.size()>0){
                // for S20-459
                createPaymentsTasks(nsfCancellationPaymentIds, paymentProgMap);
            }
            
            if(ramPaymentIds != null && ramPaymentIds.size()>0){
                // for S20-433
                deleteRAMChildFees(ramPaymentIds);
            }
        }
    }
    
    public static void createPaymentsTasks(set<String> nsfCancellationIds, map<String, String> paymentProgMap){
        // for S20-459
        if((nsfCancellationIds != null && nsfCancellationIds.size()>0) && (paymentProgMap != null && paymentProgMap.size()>0)){
            list<Group> groups = [SELECT Id, Name, DeveloperName, Email, Type FROM Group where Type='Queue' And Name ='Payment Processing' limit 1];
            if(groups != null && groups.size()>0){
                list<nu_dse__Group_Task__c> newPaymentTasks = new list<nu_dse__Group_Task__c>();
                for(String pId: nsfCancellationIds){
                    if(paymentProgMap.containsKey(pId)){
                        nu_dse__Group_Task__c paymentTask = new nu_dse__Group_Task__c();
                        paymentTask.NFS_payment__c=pId;
                        paymentTask.nu_dse__Related_To__c=paymentProgMap.get(pId);
                        paymentTask.Program__c=paymentProgMap.get(pId);
                        paymentTask.Department__c='Payments';
                        paymentTask.nu_dse__Subject__c='Close SPA and Refund';
                        paymentTask.Subject_Picklist__c='Close SPA and Refund';
                        paymentTask.OwnerId=groups[0].Id;
                        paymentTask.Manager_decline_reason__c='';
                        paymentTask.nu_dse__Description__c='Close SPA and Refund due to NSF closure';
                        paymentTask.nu_dse__ActivityDate__c=System.Today().addDays(1);
                        paymentTask.nu_dse__Status__c='Not Started';
                        newPaymentTasks.add(paymentTask);
                    }
                }
                
                if(newPaymentTasks != null && newPaymentTasks.size()>0){
                    insert newPaymentTasks;
                }
            }
        }
    }
    
    public static void deleteRAMChildFees(set<String> ramPaymentIds){
        // for S20-433
        if(ramPaymentIds != null && ramPaymentIds.size()>0){
            map<Id, nu_dse__Payment__c> updateParentPayments = new map<Id, nu_dse__Payment__c>();
            list<nu_dse__Payment__c> clearOutFeePayments = new list<nu_dse__Payment__c>();
            Id feeRTId = Schema.SObjectType.nu_dse__Payment__c.getRecordTypeInfosByName().get('Fee').getRecordTypeId();
            map<Id, nu_dse__Payment__c> ramPaymentsMap = new map<Id, nu_dse__Payment__c>([Select Id, Name, 
                                                                                          (Select Id, Name, nu_dse__Is_Makeup_Payment_Created__c 
                                                                                           From nu_dse__Payments__r Where RecordTypeId =: feeRTId) 
                                                                                          From nu_dse__Payment__c 
                                                                                          Where Id IN: ramPaymentIds]);
            
            if(ramPaymentsMap != null && ramPaymentsMap.size()>0){
                for(nu_dse__Payment__c pp: ramPaymentsMap.values()){
                    if(pp.nu_dse__Payments__r != null && pp.nu_dse__Payments__r.size()>0){
                        // update Processed_RAM_Cleanup field on parent payment
                        updateParentPayments.put(pp.Id, new nu_dse__Payment__c(Id=pp.Id, Processed_RAM_Cleanup__c=true));
                        clearOutFeePayments.addAll(pp.nu_dse__Payments__r);
                    }
                }
                
                if(clearOutFeePayments != null && clearOutFeePayments.size()>0){
                    delete clearOutFeePayments;
                }
                
                if(updateParentPayments != null && updateParentPayments.size()>0){
                    update updateParentPayments.values();
                }
            }
        }
    }
}