public class TaskAssisgnToLead_PreSales
{
  //@InvocableMethod(Label='Tasks Create for Lead')
  public static void LeadTaskMethod(list<Lead> lstLead)
  {
     list<task> lTsk=new list<task>();
     list<user> luser=[SELECT Id FROM User WHERE Profile.Name = 'Pre-Sales'];
     //list<Lead> lstLead=[select id,name from Lead where id in: Ids];
     
     for(Lead ld:lstLead)
        {
                system.debug('Lead---->'+ld.name);
                if(ld.status=='DNL Converted' && ld.Sub_Status__c=='Schedule Appointment'){
                for(user u:luser)
                {
                    Task t=new Task();
                    t.type='Other';
                    t.Subject='Lead has Converted';
                    t.description='Lead has converted with Appointment schedule';
                    t.WhoID=ld.id;
                    t.OwnerId=u.id;
                    t.status='Not Started';
                    t.priority='Normal';
                    t.ActivityDate = system.today();
                    lTsk.add(t);
                }
                }
        }
        if(!lTsk.IsEmpty())
                insert lTsk;
 
  }
}