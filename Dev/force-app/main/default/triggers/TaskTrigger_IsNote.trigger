/*
* Name        :        TaskTrigger_IsNote 
* Date        :        16 September, 2019
* Author      :       Komal Chauhan
* Description :        To check is subject contain Inbound or Outbound, mark it a note.
*/

trigger TaskTrigger_IsNote on Task (before insert, before update) 
{
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    {
        for(Task sub: Trigger.new)  
        {
            if(sub.Subject.contains('Inbound Call Completed') || sub.Subject.contains('Outbound Call Completed'))
            {
                sub.IsNote__c=true;
            }
        }
    }
}