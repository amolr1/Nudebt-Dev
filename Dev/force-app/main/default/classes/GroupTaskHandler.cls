public class GroupTaskHandler{
    
    //S20-88 ****Starts**** ~ Developed on Sept 09, 2019 : To reassign the Group Tasks to Program Owner while assigning to Negotiations Associate.
    public static void replaceGroupTaskOwner(List<nu_dse__Group_Task__c> groupTaskList, Map<Id, nu_dse__Group_Task__c> oldGroupTaskMap) {
    
        List<nu_dse__Group_Task__c> filteredGroupTasks = new List<nu_dse__Group_Task__c>();
        Set<Id> programIds = new Set<Id>();
        
        if (groupTaskList.isEmpty() == False) {
        
            String program_prefix = Schema.SObjectType.nu_dse__Program__c.getKeyPrefix();
        
            for (nu_dse__Group_Task__c groupTask : groupTaskList) {
                
                if (String.isNotBlank(groupTask.nu_dse__Related_To__c) && groupTask.nu_dse__Related_To__c.startsWith(program_prefix)
                    && (Trigger.isInsert || (Trigger.isUpdate && oldGroupTaskMap != NULL 
                        && oldGroupTaskMap.get(groupTask.Id).OwnerId != groupTask.OwnerId))
                    && groupTask.Owner_Name__c == 'Negotiations Associate' && groupTask.nu_dse__Status__c != 'Completed'
                    && groupTask.nu_dse__Status__c != 'Canceled') {
                    
                    filteredGroupTasks.add(groupTask);
                    programIds.add(groupTask.nu_dse__Related_To__c);
                }
            }
            System.debug('filteredGroupTasks------>'+filteredGroupTasks);
            System.debug('programIds------>'+programIds);
            
            if (filteredGroupTasks.isEmpty() == False && programIds.isEmpty() == False) {
                
                Map<Id, nu_dse__Program__c> programMap = new Map<Id, nu_dse__Program__c>([SELECT Id, OwnerId FROM nu_dse__Program__c 
                                                                                          WHERE Id IN :programIds]);
                
                for (nu_dse__Group_Task__c groupTask : filteredGroupTasks) {
                    
                    groupTask.OwnerId = programMap.get(groupTask.nu_dse__Related_To__c).OwnerId;                   
                }
            }    
        }               
    }
    //S20-88 ****Ends****
}