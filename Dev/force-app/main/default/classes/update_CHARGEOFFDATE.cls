Public class update_CHARGEOFFDATE{


  public static void updateTradeline(Map<Id, nu_dse__Program__c> programOldMap, List<nu_dse__Program__c> programList){
  
  Map<id,list<nu_dse__TradeLine__c>> mapOfProgramIdVsTradeline= new Map<id,list<nu_dse__TradeLine__c>>();
  
  for(nu_dse__TradeLine__c tdoBj: [select id,nu_dse__Program__c,CHARGE_OFF_DATE__c  from  nu_dse__TradeLine__c  where 
                                  nu_dse__Program__c in :programOldMap.keyset() ]){
                                  
                                  
                                  
                                  
           }
  
  
  
  }




}