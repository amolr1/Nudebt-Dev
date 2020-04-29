global class Attorney_CreateOrUpdateNDSTradeBatch implements Database.Batchable<Sobject>,Database.AllowsCallouts,Database.StateFul{
   
    global Batch_Data__c TradelineBatchData = new Batch_Data__c();
    public Integer asyncLimitUsed = 0;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        TradelineBatchData = [Select Id, Name, Last_Execution_Time__c, Number_Of_Callouts__c from Batch_Data__c where name='Attorney_CreateOrUpdateNDSTradeBatch'];
        System.OrgLimit async = System.orglimits.getMap().get('DailyAsyncApexExecutions');
        if(TradelineBatchData.Last_Execution_Time__c == null || TradelineBatchData.Last_Execution_Time__c.day() != System.now().day()){
            TradelineBatchData.Number_Of_Callouts__c = String.valueOf(0);
        }
        if(async.getValue() != null)
        asyncLimitUsed = async.getValue();
        
        
        Set<string> reProcessTradeError = Attorney_StaticVariableUtility.reProcessConfigs('TradeLine',true);
        return Database.getQueryLocator([Select Id from nu_dse__TradeLine__c t where ((nu_dse__New_Creditor__c != null or nu_dse__Original_Creditor__c != null or nu_dse__Sales_Creditor_Name__c != null) 
                                                                                   and IsAttorney__c=true and IsRelatedRecordEligibleForPick__c= true and 
                                                                                  ((Integration_Status__c=:Attorney_StaticVariableUtility.INTEGRATION_FAILED and 
                                                                                  (Integration_Reason__c Like:reProcessTradeError or 
                                                                                   Integration_Reason_2__c Like:reProcessTradeError)) or 
                                                                                  (Integration_Status__c = null and Import_Id__c = null))) OR (toBeProcessedByTradeBatch__c = 'True') ]);
    }
    
    global void execute(Database.BatchableContext BC, List<nu_dse__TradeLine__c> TradeLineList){
        
        try{
            //TradeLine
            List<nu_dse__TradeLine__c> TradeLineUpdList = new List<nu_dse__TradeLine__c>();
            for(nu_dse__TradeLine__c objTrade: TradeLineList)
            {
                TradeLineUpdList.add(objTrade);
            }
            update TradeLineUpdList;
        } Catch(Exception E){
            TradelineBatchData.Batch_Failure_Reason__c = E.getMessage();
            TradelineBatchData.Batch_Execution_Status__c = 'Failed';
        }  
    }
    
    global void finish(Database.BatchableContext BC){
        //Attorney_CreateOrUpdateNDSOfferBatch offer = new Attorney_CreateOrUpdateNDSOfferBatch();
                System.debug(TradelineBatchData);
        
      	System.OrgLimit async = System.orglimits.getMap().get('DailyAsyncApexExecutions');
        if(async.getValue() != null)
        	TradelineBatchData.Number_of_Callouts__c = String.valueOf(async.getValue() - asyncLimitUsed);
        else
            TradelineBatchData.Number_of_Callouts__c = String.valueOf(asyncLimitUsed);
        
        TradelineBatchData.Last_Execution_Time__c = System.now();
        if(TradelineBatchData.Batch_Execution_Status__c != 'Failed'){
        	TradelineBatchData.Batch_Execution_Status__c = 'Success';
        }
        //TradelineBatchData.Batch_Execution_Status__c = 'Success';
        Update TradelineBatchData;
       
        if(!test.isRunningTest())
        Database.executeBatch(new Attorney_CreateOrUpdateNDSOfferBatch(),1);
        

    }
}