public class testVFClass {

    public Boolean retunToNew {get; set;}

  

    public String getClickMe() {
        return null;
    }


                   
        public void CreateNotesSave() {
        
     
        Note nt = new Note();
        nt.id=RecordId;
        nt.Title = Titles;
        nt.Body  = Bd;   
        insert nt;
        }


    public PageReference CreateNote() {
    
     NewNote=true;
     NewNotesID=true;
     return NULL;
   
    }


      public PageReference Refresh() {
      PageReference  pg = new PageReference ('/apex/ActivityTabNew4');
      
        return pg;
    }


   
  

    public PageReference taskModal() {
        return null;
    }

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
    
  public testVFClass() {
    
     RecordId = apexpages.currentpage().getparameters().get('id');
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
    
    
  //  this.acclist = [select name from Account];
    
    //Open & Closed group task
    this.openGroupTaskList = new List<nu_dse__Group_Task__c>();
    this.openGroupTaskList  = [SELECT Id,nu_dse__Subject__c, nu_dse__ActivityDate__c, nu_dse__Type__c, nu_dse__Description__c, nu_dse__Status__c, NDS_Created_By__c, NDS_Assigned__c, Owner_Name__c FROM nu_dse__Group_Task__c WHERE nu_dse__Status__c NOT IN ('Completed', 'Canceled') AND nu_dse__Related_To__c =: RecordId];
    this.closeGroupTaskList = new List<nu_dse__Group_Task__c>();
    this.closeGroupTaskList = [SELECT Id,nu_dse__Subject__c, nu_dse__ActivityDate__c, nu_dse__Type__c, nu_dse__Description__c, nu_dse__Status__c, NDS_Created_By__c, NDS_Assigned__c, Owner_Name__c FROM nu_dse__Group_Task__c WHERE nu_dse__Status__c  IN ('Completed', 'Canceled') AND nu_dse__Related_To__c =: RecordId];
    
   //Open & Closed task
   
    this.openTaskList = new List<task>();
    this.openTaskList = [SELECT Subject, ActivityDate, Status, Priority, Description, CreatedById, OwnerId FROM task WHERE Status NOT IN ('Completed', 'Canceled')];
    
    this.ClosedTaskList = new List<task>();
    this.ClosedTaskList = [SELECT Subject, ActivityDate, Status, Priority, Description, CreatedById, OwnerId FROM task WHERE Status IN ('Completed', 'Canceled')]; 
    
    
    //Open & Closed Event
   
    this.openEventList= new List<Event>();
    this.openEventList= [SELECT Subject , ActivityDate, StartDateTime,EndDateTime, Description FROM Event WHERE IsNote__c != TRUE];
    
    this.ClosedEventList = new List<Event>();
    this.ClosedEventList = [SELECT Subject , ActivityDate, StartDateTime,EndDateTime, Description FROM Event WHERE IsNote__c != FALSE]; 
    
    
      //Open & Closed Note
   
    this.openNoteList= new List<Note>();
    this.openNoteList= [SELECT Title, OwnerId, ParentId FROM Note];
    
    this.ClosedNoteList = new List<Note>();
    this.ClosedNoteList = [SELECT OwnerId,ParentId FROM Note]; 
    
    
    
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
        
        system.debug('********'+this.groupTaskId);
        
        if (String.isNotBlank(this.groupTaskId)) {
            
            dynamicqueryGroupTask();
            this.groupView = 'View';
        }
    }
    
    /** Edit Group Task Modal **/
    public void EditGroupTask() {
    
        system.debug('********'+this.groupTaskId);
        
        if (String.isNotBlank(this.groupTaskId)) {
            
            dynamicqueryGroupTask();
            this.groupView = 'Edit';
        }
    }
    public void dynamicqueryGroupTask() {
        
        String query = 'SELECT Id';
        this.createGroupTask = new nu_dse__Group_Task__c();
        
        List<Schema.FieldSetMember> fieldSetMemberList =  readFieldSet('nu_dse__CreateGroupTask','nu_dse__Group_Task__c');
        
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList) {
            
            query += ', '+fieldSetMemberObj.getFieldPath();
            
            system.debug('API Name ====>' + fieldSetMemberObj.getFieldPath()); //api name
            system.debug('Label ====>' + fieldSetMemberObj.getLabel());
            system.debug('Required ====>' + fieldSetMemberObj.getRequired());
            system.debug('DbRequired ====>' + fieldSetMemberObj.getDbRequired());
            system.debug('Type ====>' + fieldSetMemberObj.getType());   //type - STRING,PICKLIST
        }
        query += ' FROM nu_dse__Group_Task__c WHERE ID =: groupTaskId';
        
        system.debug('********query '+query );
        
        List<nu_dse__Group_Task__c> sobjList = Database.query(query);
        
        system.debug('********sobjList '+sobjList );
        
        if (sobjList.isEmpty() == False) {
            
            this.createGroupTask = sobjList[0];
        }
        system.debug('********this.createGroupTask'+this.createGroupTask);
        system.debug('********this.isGrouptask '+this.isGrouptask );
        this.isGrouptask = True;
    }
    
    
    
    
    /** To Open the Group Task */
    public void CreateGroupTask() {
  
      this.createGroupTask = new nu_dse__Group_Task__c();
      this.isGrouptask = true;
      this.groupView = 'New';
       this.createGroupTask.nu_dse__Related_To__c = RecordId;
       
      
    }
    
    /** To Cancel the Group Task In Modal */
    public void cancelGroupTaskModal() {
        
        this.createGroupTask = new nu_dse__Group_Task__c();
        this.isGrouptask = false;
        this.groupView = '';
        //retunToNew=true;
        
         
    }
    
    /* To Save the Group Task In Modal */
    public void saveGroupTaskModal() {
         
         upsert createGroupTask;
         this.isGrouptask = false;
         this.groupView = '';
         this.createGroupTask = new nu_dse__Group_Task__c();
    }
    
     
     
     
     /****   To view Task ***/
    public void viewTask() {
        
        system.debug('********'+this.TaskId);
        
        if (String.isNotBlank(this.TaskId)) {
            
            dynamicqueryTask();
            this.taskView = 'View';
             this.istask = True;
        }
    }
    
    /** Edit Task Modal **/
    public void EditTask() {
    
        system.debug('********'+this.TaskId);
        
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
            
            system.debug('API Name ====>' + fieldSetMemberObj.getFieldPath()); //api name
            system.debug('Label ====>' + fieldSetMemberObj.getLabel());
            system.debug('Required ====>' + fieldSetMemberObj.getRequired());
            system.debug('DbRequired ====>' + fieldSetMemberObj.getDbRequired());
            system.debug('Type ====>' + fieldSetMemberObj.getType());   //type - STRING,PICKLIST
        }
        query += ' FROM task WHERE ID =: TaskId';
        
        system.debug('********query '+query );
        
        List<task> sobjList = Database.query(query);
        
        system.debug('********sobjList '+sobjList );
        
        if (sobjList.isEmpty() == False) {
            
            this.scheduleTask = sobjList[0];
        }
        system.debug('********this.scheduleTask'+this.scheduleTask);
        system.debug('********this.istask'+this.istask);
        
    }
    
    /** To Open the Task */
    public void scheduleTask() {
  
      this.scheduleTask= new task();
      this.istask = True;
      this.taskView = 'New';
    }
    
    /** To Cancel the Task In Modal */
    public void cancelTaskModal() {
        
        this.scheduleTask= new task();
        this.istask = false;
        this.taskView = '';
    }
    
    /* To Save the Task In Modal */
    public void saveTaskModal() {
         
         upsert scheduleTask;
         this.istask = false;
         this.scheduleTask= new task();
         this.taskView = '';
    }
    
     /****   To view Event Modal ***/
      
    public void viewEvent() {
        
        system.debug('********'+this.EventId);
        
        if (String.isNotBlank(this.EventId)) {
            
            dynamicqueryEvent();
            this.eventView = 'View';
        }
    }
    
    /** Edit Group Task Modal **/
    public void EditEvent() {
    
        system.debug('********'+this.EventId);
        
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
            
            system.debug('API Name ====>' + fieldSetMemberObj.getFieldPath()); //api name
            system.debug('Label ====>' + fieldSetMemberObj.getLabel());
            system.debug('Required ====>' + fieldSetMemberObj.getRequired());
            system.debug('DbRequired ====>' + fieldSetMemberObj.getDbRequired());
            system.debug('Type ====>' + fieldSetMemberObj.getType());   //type - STRING,PICKLIST
        }
        query += ' FROM event WHERE ID =: EventId';
        
        system.debug('********query '+query );
        
        List<event> sobjList = Database.query(query);
        
        system.debug('********sobjList '+sobjList );
        
        if (sobjList.isEmpty() == False) {
            
            this.scheduleEvent = sobjList[0];
        }
        system.debug('********this.scheduleEvent'+this.scheduleEvent);
        system.debug('********this.isevent'+this.isevent);
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
    public void saveeventModal() {
         
         upsert scheduleEvent;
         this.isevent = false;
         this.eventView = '';
    }
    
    public PageReference EditDeal() {
    
        return null;
    }
    public PageReference ViewDeal() {
        return null;
    }

    public void deleteDeal() {
    openGroupTaskList = [SELECT Id, Name,Group_Task_Subject__c FROM nu_dse__Group_Task__c where id = :dealId];
     if(openGroupTaskList.size() > 0 || openGroupTaskList[0].Id != ''){
     delete openGroupTaskList;
     }
    // loadData();
        
    }
}