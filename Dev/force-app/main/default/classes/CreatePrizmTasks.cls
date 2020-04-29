@RestResource(urlMapping='/CreateTaskRecord/*')
global class CreatePrizmTasks{
    
    @HttpPost
    global Static void CreateTasks(){
        RestRequest request = RestContext.request;
        String jsonString =  request.requestBody.toString();
        Map<String,List<Task>> datamap =(Map<String,List<Task>>) JSON.deserialize(jsonString, Map<String,List<Task>>.class);
		Set<String> oppIdsSet = datamap.keyset();
        System.debug('size = '+oppIdsSet.size());
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE Id IN : oppIdsSet];
        System.debug('oppList = '+oppList.size());
         List<Task> insertTaskList = new List<Task>();
        System.debug('datamap = '+oppIdsSet);
          for(Opportunity eachOpp : oppList){
              System.debug('eachOpp.Id = '+eachOpp.Id);
            if(datamap.containskey(eachOpp.Id)){
                List<Task> planetOrgTaskList = datamap.get(eachOpp.Id);
                System.debug('planetOrgTaskList = '+planetOrgTaskList.size());
                for(Task eachTask : planetOrgTaskList){
                    Task newTask = new Task();
                    newTask.WhatId = eachOpp.Id;
                    newTask.Subject = eachTask.Subject;
                    newTask.Status = eachTask.Status;
                    newTask.Priority = eachTask.Priority;
                    insertTaskList.add(newTask);
                }
            }
        }
        System.debug('insertTaskList = '+insertTaskList.size());
        if(!insertTaskList.isEmpty()){
            insert insertTaskList;
        }
    }
    
    /*@HttpPost
    global Static void CreateTasks(){  //void:string
        String jsonStr = '';
        
        if ( !Test.isRunningTest() && RestContext.request.requestBody != NULL)
            jsonStr = RestContext.request.requestBody.toString();    
        else{
            List<Task> TaskList = new List<Task>();
            Task t = new Task();
            t.Due_Date_Time__c = System.now();
            t.ActivityDate = Date.today();
            t.Status = 'Not Started';
            t.WhatId = '006m000000B312yAAB';
            t.Id = '00Tm000000S53sg';
            t.Priority = 'Normal';
            TaskList.add(t);
            jsonStr = JSON.serialize(TaskList);
        }
        System.debug(jsonStr);
        
        List<Task> TaskList = (List<Task>)JSON.deserialize(jsonStr,List<Task>.class);
        List<Id> OpportunityIds = new List<Id>();
        Map<String,List<Task>> oppTaskMap = new Map<String,List<Task>>();
        List<Task> TaskCreationList = new List<Task>();
        for(Task t : TaskList){
            Task newTsk = new Task();
            //Opportunity opp = new Opportunity(Import_Id__c = t.whatId);
            newTsk.priority = t.priority;
            newTsk.ActivityDate = t.ActivityDate;
            newTsk.Status = t.Status;
            newTsk.Subject = t.Subject;
            newTsk.Description = t.Description;
            newTsk.whatId = t.whatId; //@t.whatId  : t.mapnm(t.whatId);   map<opp.id,opp.ipmId>:prizm
            //newTsk.Import_Id__c = t.Id; 
            if (t.Due_Date_Time__c != null){ //FS FOR NULL POINTER
                //newTsk.Due_Time__c = t.Due_Date_Time__c.Time();
                newTsk.Due_Date_Time__c= t.Due_Date_Time__c;
            }
            if(!oppTaskMap.containsKey(t.whatId)){
                oppTaskMap.put(t.whatId,new List<Task>());
            }
            oppTaskMap.get(t.whatId).add(newTsk);
            //TaskCreationList.add(newTsk);
            OpportunityIds.add(t.WhatId);
            //TaskList.add(newTsk);
        }
        
        Map<String,Opportunity> OpportunityIdMap = new Map<String,Opportunity>();
        for(Opportunity oppo : [Select Id, OwnerId from Opportunity where id=:OpportunityIds]){ //id:import_ID__c
            //OpportunityIdMap.put(oppo.Import_Id__c,oppo);
            OpportunityIdMap.put(oppo.Id,oppo);
        }
            System.debug(OpportunityIdMap);
        System.debug(OpportunityIds);
            for(String whatId : oppTaskMap.keySet()){
                Id oppId = opportunityIdMap.get(whatId).Id;
                Id OwnerId = opportunityIdMap.get(whatId).ownerId;
                for(Task t : oppTaskMap.get(whatId)){
                    t.whatId = oppId;
                    t.OwnerId = OwnerId;
                    TaskCreationList.add(t);
                }
            }
            Database.SaveResult[] insTaskResults = Database.insert(TaskCreationList);
            //ids of new task & prizm :map-->store json.serialize()  -->return to prizm
            system.debug(logginglevel.error,'****insTaskResults::'+insTaskResults);
            }*/
    }