public class testVFClass1 {

    public String tasksItem_Id { get; set; }

    public String document { get; set; }
    public String Titles{get;set;}
    public String Bd{get;set;}
    public List<Account> acclist{set; get;}
    public String dealId{get;set;}
    public Boolean isGrouptask{get;set;}
    public String groupView{get;set;}
    public String taskView{get;set;}
    public String eventView{get;set;}
    public Boolean istask{get;set;}
    public Boolean isevent{get;set;}
    public List<nu_dse__Group_Task__c> openGroupTaskList{set; get;}
    public List<nu_dse__Group_Task__c> closeGroupTaskList{set; get;}
    public nu_dse__Group_Task__c createGroupTask{set; get;}
    public task scheduleTask{set; get;}
    public event scheduleEvent{set; get;}
    public List<task> openTaskList{set; get;}
    public List<task> ClosedTaskList { get; set;}
    public List<Event> openEventList{set; get;}
    public List<Event> ClosedEventList { get; set; }
    public List<Note> openNoteList{set; get;}
    public List<Note> ClosedNoteList { get; set; }
    public Id groupTaskId {get; set;}
    public Id TaskId {get; set;}
    public Id EventId {get; set;}
    public Id RecordId {get; set;}
    public Boolean NewNote { get; set; }
    public Boolean NewNotesID{ get; set; }
    public List<nu_dse__group_task__history> GroupTaskHistoryList { get; set; }
    public List<Attachment> GroupTaskAttachmentList { get; set; }
    public Note nt = new Note();
    public List<Note> GroupTaskNoteList { get; set; }
    public List<Note> GroupTaskNoteList1 { get; set; }
    Public Attachment myfile { get; set; }
    
    public testVFClass1 () {
    
        RecordId = apexpages.currentpage().getparameters().get('recordId');
        system.debug('RecordId' + RecordId);
        NewNote=false;
        NewNotesID=false;
        /* the Boolen to show and hide the create group Task Modal */
        this.isGrouptask = False;
        this.groupView = '';
        this.createGroupTask = new nu_dse__Group_Task__c();
        /* the Boolen to show and hide the Task Modal */
        this.istask = False;
        this.taskView = '';
        this.scheduleTask= new task();
        
        if (recordId != null) {
            
            getData();
        }
    }
    
    Public Void getdata() {
    
        //Open & Closed group task
        this.openGroupTaskList = new List<nu_dse__Group_Task__c>();
        this.openGroupTaskList  = [SELECT Id,nu_dse__Subject__c, nu_dse__ActivityDate__c, nu_dse__Type__c, nu_dse__Description__c, nu_dse__Status__c, NDS_Created_By__c, NDS_Assigned__c, Owner_Name__c FROM nu_dse__Group_Task__c WHERE nu_dse__Status__c NOT IN ('Completed', 'Canceled') AND nu_dse__Related_To__c =: RecordId];
        this.closeGroupTaskList = new List<nu_dse__Group_Task__c>();
        this.closeGroupTaskList = [SELECT Id,nu_dse__Subject__c, nu_dse__ActivityDate__c, nu_dse__Type__c, nu_dse__Description__c, nu_dse__Status__c, NDS_Created_By__c, NDS_Assigned__c, Owner_Name__c FROM nu_dse__Group_Task__c WHERE nu_dse__Status__c  IN ('Completed', 'Canceled') AND nu_dse__Related_To__c =: RecordId];
        
        //Open & Closed task
        this.openTaskList = new List<task>();
        this.openTaskList = [SELECT Subject, ActivityDate, Status, Priority, Description, CreatedById, OwnerId FROM task WHERE Status NOT IN ('Completed', 'Canceled') AND WhatId =: RecordId];
        
        this.ClosedTaskList = new List<task>();
        this.ClosedTaskList = [SELECT Subject, ActivityDate, Status, Priority, Description, CreatedById, OwnerId FROM task WHERE Status IN ('Completed', 'Canceled') AND WhatId =: RecordId]; 
        
        //Open & Closed Event
        this.openEventList= new List<Event>();
        this.openEventList= [SELECT Subject , ActivityDate, StartDateTime,EndDateTime, Description FROM Event WHERE IsNote__c != TRUE AND WhatId =: RecordId];
        
        this.ClosedEventList = new List<Event>();
        this.ClosedEventList = [SELECT Subject , ActivityDate, StartDateTime,EndDateTime, Description FROM Event WHERE IsNote__c != FALSE AND WhatId =: RecordId]; 
        
        //Open & Closed Note
        this.openNoteList= new List<Note>();
        this.openNoteList= [SELECT Title, OwnerId, ParentId FROM Note WHERE ParentId=: RecordId];
        
        this.ClosedNoteList = new List<Note>();
        this.ClosedNoteList = [SELECT Title,OwnerId,ParentId FROM Note WHERE ParentId=: RecordId]; 
     
    }
    
    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName) {
    
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields(); 
    }  
    
    /****   To view Group Task ***/
    public void viewGroupTask() {
        
        if (String.isNotBlank(this.groupTaskId)) {
            
            dynamicqueryGroupTask();
            this.isGrouptask = True;
            this.groupView = 'View';
            myfile = new Attachment();
            GetGroupTaskInfo();   
        }
    }
    
    public void GetGroupTaskInfo() {
        this.GroupTaskNoteList = new List<Note>();
        this.GroupTaskNoteList  = [SELECT Title,Body,CreatedDate,CreatedById, ParentId FROM Note WHERE ParentId=: groupTaskId];
        
        /* this.GroupTaskNoteList = new List<Note>();
        this.GroupTaskNoteList  = [SELECT Title,Body,CreatedDate,CreatedBy.Name, ParentId FROM Note WHERE ParentId=: groupTaskId];  */
        
        this.GroupTaskHistoryList = new List<nu_dse__group_task__history>();
        this.GroupTaskHistoryList = [SELECT CreatedDate,CreatedById,Field, ParentId FROM nu_dse__group_task__history WHERE ParentId=: groupTaskId]; 
        
        this.GroupTaskAttachmentList = new List<Attachment>();
        //this.GroupTaskNoteList  = [SELECT Title,OwnerId,ParentId FROM Note WHERE ParentId=: groupTaskId]; 
    }
    
    /** Edit Group Task Modal **/
    public void EditGroupTask() {
            
        if (String.isNotBlank(this.groupTaskId)) {
            
            dynamicqueryGroupTask();
            this.isGrouptask = True;
            this.groupView = 'Edit';
            myfile = new Attachment();
            GetGroupTaskInfo();
        }
    }
    public void dynamicqueryGroupTask() {
        
        String query = 'SELECT Id';
        this.createGroupTask = new nu_dse__Group_Task__c();
        
        List<Schema.FieldSetMember> fieldSetMemberList =  readFieldSet('nu_dse__CreateGroupTask','nu_dse__Group_Task__c');
        
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
            
            query += ', '+fieldSetMemberObj.getFieldPath();
        }
        query += ' FROM nu_dse__Group_Task__c WHERE ID =: groupTaskId';
        List<nu_dse__Group_Task__c> sobjList = Database.query(query);
        if (sobjList.isEmpty() == False) {
            
            this.createGroupTask = sobjList[0];
        }
       // this.isGrouptask = True;
    }
    
    /** To Open the Group Task */
    public void CreateGroupTask() {
        
        this.createGroupTask = new nu_dse__Group_Task__c();
        this.isGrouptask = true;
        myfile = new Attachment();
        this.groupView = 'New';
       // this.createGroupTask.nu_dse__Related_To__c = RecordId;
    }
    
    /** To Cancel the Group Task In Modal */
    public void cancelGroupTaskModal() {
        
        this.createGroupTask = new nu_dse__Group_Task__c();
        this.isGrouptask = false;
        this.groupView = '';
    }
    
    /* To Save the Group Task In Modal */
    public void saveGroupTaskModal() {
         
         String fileName = apexpages.currentpage().getparameters().get('param1');
         String fileType = apexpages.currentpage().getparameters().get('param2');
         String myString = apexpages.currentpage().getparameters().get('param3');
         System.debug('fileName'+fileName);
         System.debug('fileType'+fileType);
         System.debug('myString'+myString);
         
         upsert createGroupTask;
         
         if (createGroupTask.Id != null && String.isNotBlank(myString) && String.isNotBlank(fileName)) {
             
             List<String> blobList = myString.split(',', 2);
             
             Attachment attachmentInstance = new Attachment();
             attachmentInstance.parentId = createGroupTask.Id;
             attachmentInstance.name=fileName;
             attachmentInstance.ContentType=fileType;
             
             if (blobList.size() == 2) {
                 
                 attachmentInstance.body = EncodingUtil.base64Decode(blobList[1]);
             }
             
             insert attachmentInstance;
             System.debug('attachmentInstance'+attachmentInstance);
         }
         
         this.isGrouptask = false;
         this.groupView = '';
         this.myfile = new Attachment();
         this.createGroupTask = new nu_dse__Group_Task__c();
    }
    
     /****   To view Task ***/
    public void viewTask() {
                
        if (String.isNotBlank(this.TaskId)) {
            
            dynamicqueryTask();
            this.taskView = 'View';
             this.istask = True;
        }
    }
    
    /** Edit Task Modal **/
    public void EditTask() {
            
        if (String.isNotBlank(this.TaskId)) {
            
            dynamicqueryTask();
            this.taskView = 'Edit';
            this.istask = True;
        }
    }
    public void dynamicqueryTask() {
        
        String query = 'SELECT Id';
        this.scheduleTask = new task();
        
        List<Schema.FieldSetMember> fieldSetMemberList =  readFieldSet('nu_dse__Activity_Tab_Edit','task');
        
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
            
            query += ', '+fieldSetMemberObj.getFieldPath();
        }
        query += ' FROM task WHERE ID =: TaskId';
        List<task> sobjList = Database.query(query);
        if (sobjList.isEmpty() == False) {
            
            this.scheduleTask = sobjList[0];
        }
        
    }
    
    /** To Open the Task */
    public void scheduleTask() {
  
      this.scheduleTask= new task();
      this.istask = True;
      this.taskView = 'New';
    }
    
    /** To Cancel the Task In Modal */
    public void cancelTaskModal() {
        
        this.scheduleTask = new task();
        this.istask = false;
        this.taskView = '';
        
            }
    
    /* To Save the Task In Modal */
    public PageReference saveTaskModal() {
         
         upsert scheduleTask;
         this.istask = false;
         this.scheduleTask= new task();
         this.taskView = '';
            
            PageReference pg = new PageReference('/apex/ActivityTabNew6'); 
            pg.setRedirect(true);
            return pg;
            }
    
     /****   To view Event Modal ***/
    public void viewEvent() {
                
        if (String.isNotBlank(this.EventId)) {
            
            dynamicqueryEvent();
            this.eventView = 'View';
        }
    }
    
    /** Edit Group Task Modal **/
    public void EditEvent() {
            
        if (String.isNotBlank(this.EventId)) {
            
            dynamicqueryEvent();
            this.eventView = 'Edit';
        }
    }
    public void dynamicqueryEvent() {
        
        String query = 'SELECT Id';
        this.scheduleEvent = new event();
        
        List<Schema.FieldSetMember> fieldSetMemberList =  readFieldSet('nu_dse__Activity_Tab_Event_Fields','event');
        
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
            
            query += ', '+fieldSetMemberObj.getFieldPath();
        }
        query += ' FROM event WHERE ID =: EventId';
                
        List<event> sobjList = Database.query(query);
                
        if (sobjList.isEmpty() == False) {
            
            this.scheduleEvent = sobjList[0];
        }
        this.isevent = True;
    }
    
    /** To Open the Event */
    public void scheduleEvent() {
  
      this.scheduleEvent = new event();
      this.isevent = True;
      this.eventView  = 'New';
    }
    
    /** To Cancel the Event In Modal */
    public void canceleventModal() {
        
        this.isevent = false;
        this.eventView  = '';
    }
    
    /* To Save the Event In Modal */
    public PageReference saveeventModal() {
         
         upsert scheduleEvent;
         this.isevent = false;
         this.scheduleEvent= new event();
         this.eventView = '';
      PageReference pg = new PageReference('/apex/ActivityTabNew6'); 
            pg.setRedirect(true);
            return pg;
            }
    
    public void CreateNote() {
    
         this.NewNote = true;
         this.NewNotesID = true;  
         this.Titles='';
         this.Bd=''; 
    }
    
    
    public void CreateNotesSave() {    
        Note nt = new Note();
        nt.id = RecordId;
        nt.Title = Titles;
        nt.Body  = Bd;
        nt.ParentId=this.grouptaskid;
        insert nt;
        nt.clear();
        this.NewNote = false;
        this.NewNotesID = false;
        GetGroupTaskInfo();    
    }
    public void cancelNotes() {
        
        this.NewNote = false;
        this.NewNotesID = false;
    }
    
    
    
    public void Refresh() {
       
    }
    
    public void EditDeal() {
    
    }
    public void ViewDeal() {
    
    }
}