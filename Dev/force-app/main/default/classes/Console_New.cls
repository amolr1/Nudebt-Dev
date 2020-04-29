public class Console_New {

public String currentRecordId {get;set;}
public String parameterValue {get;set;}
public nu_dse__Program__c prog {get;set;}
 
    public Console_New() {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('pid');
        prog = [select id,Subscribed_to_ALLG__c,Portfolio__r.name , OwnerId, Owner.Name, Assigned_to_Legal__c, DNL_Status__c  from nu_dse__Program__c where id =: currentRecordId ];
    }
}