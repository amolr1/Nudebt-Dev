trigger PaymentTrigger_PopulateFeeTemplate on nu_dse__Payment__c (after insert) {
    
    Set<Id> Ids = new Set<Id>();
	for (nu_dse__Payment__c payID : Trigger.new){
		Ids.add(payID.Id);
	}
	Attorney_CreateOrUpdateNDSPaymentHandler.populateFeeTemplate(Ids);
}