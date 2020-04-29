public class Attorney_NoteHandler {

    public static boolean isNotesPushed = false;
    
    public static void createNotesInNDS(){
        if(!isNotesPushed){
            List<Note> NoteList = (List<Note>)Trigger.new;
            Map<Id,Note> OldNoteMap = (Map<Id,Note>)Trigger.oldMap;
            List<Id> TradelineIds = new List<Id>();
            List<Note> NewNotes = new List<Note>();
            for(Note n: NoteList){
                String sObjName = n.ParentId.getSObjectType().getDescribe().getName();
                System.debug(sObjName);
                if(sObjName.equalsIgnoreCase('nu_dse__TradeLine__c')){
                    if(Trigger.isInsert || (Trigger.isUpdate && (n.Title != OldNoteMap.get(n.Id).Body || n.Title != OldNoteMap.get(n.Id).Body))){
                        TradelineIds.add(n.ParentId);
                        NewNotes.add(n);
                    }
                }
            }
            
            if(!NewNotes.isEMpty()){
                System.enqueueJob(new createNotes(NewNotes,TradelineIds,Trigger.isInsert));
                isNotesPushed = true;
            }
        }
    }
    
    public class createNotes implements Queueable,Database.AllowsCallouts {
        
        List<Id> TradelineIds = new List<Id>();
        List<Note> Notes = new List<Note>();
        Boolean IsInsert;
        
        public createNotes(List<Note> Notes,List<Id> TradelineIds,Boolean isInsert){
            this.Notes = Notes;
            this.TradelineIds = TradelineIds;
            this.isInsert=isInsert;
        }
        
        public void execute(QueueableContext context) {
            leadtracNetDebt.DebtServiceSoap soap = new leadtracNetDebt.DebtServiceSoap();
            Map<Id,nu_dse__Tradeline__c> TradelineMap = new Map<Id,nu_dse__Tradeline__c>([Select Id,isAttorney__c,FileNumber__c,Import_Id__c from nu_dse__Tradeline__c where Id=:TradelineIds]);
            
            for(Note n: Notes){
                if(TradelineMap.get(n.ParentId).isAttorney__c){
                    leadtracNetDebt.LogEntry logEntry = new leadtracNetDebt.LogEntry();
                    logEntry.FileNumber = TradelineMap.get(n.ParentId).FileNumber__c;
                    logEntry.DebtId = Long.valueOf(TradelineMap.get(n.ParentId).Import_Id__c);
                    logEntry.Entry = n.title + '\n\n' +n.Body;
                    logEntry.CreatedOn = n.CreatedDate;
                    
                    leadtracNetDebt.GetDebtLogEntriesResult result = soap.AddLogEntry(Attorney_StaticVariableUtility.credentials.UserName__c, Attorney_StaticVariableUtility.credentials.Password__c,TradelineMap.get(n.ParentId).FileNumber__c,Long.valueOf(TradelineMap.get(n.ParentId).Import_Id__c),logEntry);
                    
                    if(result.isSuccessful && isInsert){
                        if(result.Entries != null && result.Entries.LogEntry != null){
                            logEntry = result.Entries.logEntry[0];
                            n.Title = n.Title + ' **('+ logEntry.id +')';
                        }
                    }
                }
                //logEntry.
            }
        }
        
    }
    
}