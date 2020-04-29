/**
* Name:          SOPTrigger
* Author:        mindZcloud Developers
* CreatedDate:   08/22/2019 - S20-197 - mindZcloud Developers
* Modified By:   08/27/2019 - S20-197 - Amit Goyal
* Description:   To Create tasks for SOP Queues on SOP Creation/Updation
*/
trigger SOPTrigger on SOPs__c (after insert, after update){
    if(Trigger.isAfter){
        // After insert section
        if(Trigger.isInsert){
            // To avoid recurssion
            if(!SOPTriggerHandler.hasAlreadyRanAfterInsert){
                SOPTriggerHandler.handleAfterInsert(Trigger.newMap);
            }
        }
        
        // After update section
        if(Trigger.isUpdate){
            // To avoid recurssion
            if(!SOPTriggerHandler.hasAlreadyRanAfterUpdate){
                SOPTriggerHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
            }
        }
    }
    
    /*List<Task> taskList = new List<Task>();
    List<Group> groupList = new List<Group>();
    for(SOPs__c s : trigger.new){
       
       // if(trigger.oldmap.get(s.Id).Name!=s.Name && trigger.oldmap.get(s.Id).SOP_Display__c!=s.SOP_Display__c ) {
            Task ts = new Task();
            ts.Subject__c='SOP Review Required';
            ts.Subject = 'SOP Review Required';
            ts.Description='Please review this SOP for updates and include a link to the updated SOP.';
            ts.Status='Not Started';
            ts.Due_Date_Time__c=s.LastModifiedDate+1;
             ts.WhatId=s.Id; 
            taskList.add(ts);
            //list<Group> GroupList = [Select Id, DeveloperName From Group Where Type='Queue' And DeveloperName='SOP_Client_Experience'];
          //  GroupList.Id=ts.Id;
           List<Group> groupList = [select Id from Group where Type = 'Queue' AND Name = 'SOP_Client_Experience' LIMIT 1];
                   if(!groupList.isEmpty()) {
                       ts.OwnerId = groupList[0].Id;
                   }
           // groupList.add
            
            
       // }
    }
    insert taskList;*/
 }