global class Attorney_CreateOrUpdateNDSOfferBatch implements Database.Batchable<Sobject>,Database.AllowsCallouts,Database.StateFul{

    global Batch_Data__c OfferBatchData = new Batch_Data__c();
    public Integer asyncLimitUsed = 0;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        OfferBatchData = [Select Id, Name, Last_Execution_Time__c, Number_Of_Callouts__c from Batch_Data__c where name='Attorney_CreateOrUpdateNDSOfferBatch'];
        System.OrgLimit async = System.orglimits.getMap().get('DailyAsyncApexExecutions');
        if(OfferBatchData.Last_Execution_Time__c == null || OfferBatchData.Last_Execution_Time__c.day() != System.now().day()){
            OfferBatchData.Number_Of_Callouts__c = String.valueOf(0);
        }
        if(async.getValue() != null)
        asyncLimitUsed = async.getValue();
        
        
        Set<string> reProcessOfferError = Attorney_StaticVariableUtility.reProcessConfigs('Offer',true);
        return Database.getQueryLocator([Select Id from nu_dse__Offer__c where IsAttorney__c=true  and latest_offer__c = true and IsRelatedRecordEligibleForPick__c= true and 
                                                                                 ((Integration_Status__c=:Attorney_StaticVariableUtility.INTEGRATION_FAILED and 
                                                                                  (Integration_Reason__c Like:reProcessOfferError or 
                                                                                   Integration_Reason_2__c Like:reProcessOfferError)) or 
                                                                                  (Integration_Status__c = null and NDS_Offer_Id__c=null) or (latest_offer__c = true and Integration_Status__c = 'Overflow'))]);
    }
    
    global void execute(Database.BatchableContext BC, List<nu_dse__Offer__c> offerList){
        
        //Offer
        try{
            List<nu_dse__Offer__c> offerUpdList = new List<nu_dse__Offer__c>();
            for(nu_dse__Offer__c objPayment: offerList)
            {
                offerUpdList.add(objPayment);
            }
            update offerUpdList;
 		} Catch(Exception E){
            OfferBatchData.Batch_Failure_Reason__c = E.getMessage();
            OfferBatchData.Batch_Execution_Status__c = 'Failed';
        }
    }
    
    global void finish(Database.BatchableContext BC){
        //Attorney_CreateOrUpdateNDSPaymentBatch payment = new Attorney_CreateOrUpdateNDSPaymentBatch();
        
        System.OrgLimit async = System.orglimits.getMap().get('DailyAsyncApexExecutions');
        if(async.getValue() != null)
            OfferBatchData.Number_of_Callouts__c = String.valueOf(async.getValue() - asyncLimitUsed);
        else
            OfferBatchData.Number_of_Callouts__c = String.valueOf(asyncLimitUsed);
        
        OfferBatchData.Last_Execution_Time__c = System.now();
        if(OfferBatchData.Batch_Execution_Status__c != 'Failed'){
        	OfferBatchData.Batch_Execution_Status__c = 'Success';
        }
        //OfferBatchData.Batch_Execution_Status__c = 'Success';
        Update OfferBatchData;
       
        
        if(!Test.isRunningTest())
        Database.executeBatch(new Attorney_CreateOrUpdateNDSPaymentBatch(),10);

       
    }
}