trigger DnlSettelmentSyncTrigger on DNL_Settlement_Rate__c (After insert) {

    Id networkId = ConnectionHelper_DNL_Settlment.getConnectionId('Peerform'); 
    system.debug('networkId'+networkId);
    Set<Id> DnlrtSet = new Set<Id>(); 
    for (DNL_Settlement_Rate__c Dsr : TRIGGER.new) {
       if (Dsr.ConnectionReceivedId == null )  
           DnlrtSet.add(Dsr.id); 
        }
    if (DnlrtSet.size() > 0) { 
       List<PartnerNetworkRecordConnection> DNLConnections =  new  List<PartnerNetworkRecordConnection>();   
       for (DNL_Settlement_Rate__c dnlRec : Trigger.New) {   
         if (DnlrtSet.contains(dnlRec.id)) {                    
           PartnerNetworkRecordConnection newConnection = new PartnerNetworkRecordConnection(ConnectionId = networkId, 
                                                        LocalRecordId = dnlRec.Id,SendClosedTasks = false,SendOpenTasks = false,
                                                        SendEmails = false);
           DNLConnections.add(newConnection);                 
        }
      }
    if (DNLConnections.size() > 0 ) { 
        database.insert(DNLConnections); 
     }
   }
}