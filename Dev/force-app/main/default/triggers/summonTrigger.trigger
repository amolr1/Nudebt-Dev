trigger summonTrigger on Summon__c (before insert, after Update) {

    if (Trigger.isBefore && Trigger.isInsert) {
        
        SummonHandler.litigationSummonOwnerAssignment(Trigger.new);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        SummonHandler.createGroupTaskOnRejected();
    }
}