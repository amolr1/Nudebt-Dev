//A Utility class to process Account records 
public class dupeCheck {

    //the AccountTINTrigger list is getting passed in by our trigger; this should match trigger.new
    public static void checkforDupes(List<Account> accounts){

        //list variable for our query to use as a limit/bind variable
        List<String> names = new List<String>();
        //populate that list variable
        for(Account acct: accounts){
            names.add(acct.Portfolio__c);
        }

        //query for existing items, but only if they have the same TIN (WHERE cond)
        List<Account> existingRelationship = ([SELECT id, Portfolio__c  FROM Account
            WHERE Portfolio__c in :names]);

        List<account> Recordstoupdate = new List <Account>();
        //check to see if there are matches
        if(existingRelationship.size() > 0){
            //this means we have some dupes and we need to identify which records are dupes
            //loop through Accounts

            for (Account currentRelationship: existingRelationship){
                for(Account newRelationship: accounts){
                    if(currentRelationship.Portfolio__c == newRelationship.Portfolio__c) {
                        newRelationship.Id = currentRelationship.Id;}
//What else is needed here to update the accounts so that records are upserted rather than inserted?
                }
            }
        } 
    }
}