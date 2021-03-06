public class CreateGroupTaskWhenOfferisActive{

        @InvocableMethod
        public static void createGroupTask(list<id> offerId){
        list<nu_dse__Group_Task__c> listOfGrpTask= new list<nu_dse__Group_Task__c>();
        list<nu_dse__Offer__c> listOFOfferRecords= new list<nu_dse__Offer__c>();
         map<id,date> mapOfPgrogramIdVsPayemntActivityDate= new map<id,date>();
         set<id> programId= new set<Id>();
         map<id,nu_dse__Offer__c > ProgramIdVsTradelineDeatsils= new map<id,nu_dse__Offer__c >();
         if(offerId !=null && offerId.size()>0){
             //listOFOfferRecords=[select id,nu_dse__Program__c from nu_dse__Offer__c where id in :offerId];
             
             for(nu_dse__Offer__c  offerRec :[select id,nu_dse__Program__c,nu_dse__TradeLine__r.nu_dse__New_Creditor__r.name,nu_dse__TradeLine__r.nu_dse__New_Account_Number__c from nu_dse__Offer__c where id in :offerId]){
             
                         listOFOfferRecords.add(offerRec );
                         programId.add(offerRec.nu_dse__Program__c );
                         ProgramIdVsTradelineDeatsils.put(offerRec.nu_dse__Program__c,offerRec );
             
             }
         }
         system.debug('line 20' + programId);
        if(programId !=null && programId.size()>0){
             for( nu_dse__Payment__c  paymentobj: [select id,nu_dse__Program__c,nu_dse__Schedule_Date__c from nu_dse__Payment__c where nu_dse__Program__c in:
                                                    programId  and recordtype.name='Settlement'  order by   nu_dse__Program__c ]){                                                                                           
                     if(mapOfPgrogramIdVsPayemntActivityDate !=null && mapOfPgrogramIdVsPayemntActivityDate.get(paymentobj.nu_dse__Program__c)
                     !=null  ){
                     
                     Date tempDate =mapOfPgrogramIdVsPayemntActivityDate.get(paymentobj.nu_dse__Program__c);
                     
                     if(paymentobj.nu_dse__Schedule_Date__c >  tempDate){
                         mapOfPgrogramIdVsPayemntActivityDate.put(paymentobj.nu_dse__Program__c,paymentobj.nu_dse__Schedule_Date__c);
                     }
                     }else{
                     
                             mapOfPgrogramIdVsPayemntActivityDate.put(paymentobj.nu_dse__Program__c,paymentobj.nu_dse__Schedule_Date__c);
                     }
             
             
             
            }
            system.debug('line 20' + mapOfPgrogramIdVsPayemntActivityDate);
        }      
          if(programId !=null && programId.size()>0 && mapOfPgrogramIdVsPayemntActivityDate !=null && mapOfPgrogramIdVsPayemntActivityDate.size()>0 ){
            group queueObj=[select id,name from Group  where name='Settlement Payment Processing' and Type = 'Queue'];
            
            if(queueObj !=null){
                for( id pid: programId ){
                 
                     if(mapOfPgrogramIdVsPayemntActivityDate.get(pid) !=null){
                     
                      date finaldate=mapOfPgrogramIdVsPayemntActivityDate.get(pid);
                            nu_dse__Group_Task__c grpTask = new nu_dse__Group_Task__c();
                            
                            grpTask.Department__c='Negotiations Support';
                             
                            grpTask.nu_dse__Subject__c='Mark Account as Settled';
                            grpTask.Subject_Picklist__c='Mark Account as Settled';
                            grpTask.nu_dse__Type__c='None';
                            if(ProgramIdVsTradelineDeatsils !=null && ProgramIdVsTradelineDeatsils.size()>0 && ProgramIdVsTradelineDeatsils.get(pid) !=null ){
                            nu_dse__Offer__c  tempOffer= new nu_dse__Offer__c ();
                            tempOffer=ProgramIdVsTradelineDeatsils.get(pid);
                            
                                grpTask.nu_dse__Description__c='New Creditor :'+ tempOffer.nu_dse__TradeLine__r.nu_dse__New_Creditor__r.name +'  New Account Number : '+ tempOffer.nu_dse__TradeLine__r.nu_dse__New_Account_Number__c; 
                            
                            }
                            //
                            grpTask.nu_dse__Status__c='Not Started';
                            grpTask.nu_dse__ActivityDate__c=finaldate.adddays(7);
                            grpTask.Program__c=pid;
                            grpTask.ownerid=queueObj.id;
                            listOfGrpTask.add(grpTask);
                             system.debug('line 20' + listOfGrpTask);
                      }
                 }
             }
        }
         if(listOfGrpTask !=null && listOfGrpTask.size()>0 ){
         
             try{
                   insert listOfGrpTask;
                     system.debug('line 81'+listOfGrpTask[0].id);
             
             }
             catch(Exception e){
             
                system.debug('exception');
             }
        
         }
    
     }


}