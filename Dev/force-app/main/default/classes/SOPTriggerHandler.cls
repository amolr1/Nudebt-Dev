/**
* Name:          SOPTriggerHandler
* Author:        Amit Goyal
* CreatedDate:   08/27/2019 - S20-197 - Amit Goyal
* Description:   To Create tasks for SOP Queues on SOP Creation/Updation
*/

public with sharing class SOPTriggerHandler{
    // variables to handler recurssion
    public static boolean hasAlreadyRanAfterInsert = false;
    public static boolean hasAlreadyRanAfterUpdate = false;
    
    public static void handleAfterInsert(map<Id, SOPs__c> newSOPs){
        // Method to execute from Trigger on after insertion of sop
        if(!hasAlreadyRanAfterInsert){
            hasAlreadyRanAfterInsert=true;
        }
        
        if(newSOPs != null && newSOPs.size()>0){
            
        }
    }
    
    public static void handleAfterUpdate(map<Id, SOPs__c> newSOPs, map<Id, SOPs__c> oldSOPs){
        // Method to execute from Trigger on after updation of sop
        if(!hasAlreadyRanAfterUpdate){
            hasAlreadyRanAfterUpdate=true;
        }
        
        if(newSOPs != null && newSOPs.size()>0){
            
        }
    }
}