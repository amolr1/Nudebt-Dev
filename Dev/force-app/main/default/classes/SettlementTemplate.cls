public  class SettlementTemplate
{
    public Id programId{get;set;}
    public List<nu_dse__Payment__c> getPayments()
    {
        List<nu_dse__Payment__c> payments = [SELECT Name, nu_dse__Program__r.Name, nu_dse__Total_Amount__c, nu_dse__Schedule_Date__c 
                                               FROM nu_dse__Payment__c WHERE nu_dse__Program__c =: programId AND RecordType.DeveloperName = 'Settlement'
                                               ORDER BY nu_dse__Schedule_Date__c ASC LIMIT 10 ];
        return payments;
    }
}