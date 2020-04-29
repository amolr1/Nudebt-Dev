/*
* Class Name  : ManageRecordAllocationController
* Description : Controller for Manage Record Allocation VisualForce Page
* Developer(s): MZ
*/
public class ManageRecordAllocationController {
    public list<UserWrapper> lstUserWrapper{get;set;} 
    
    public ManageRecordAllocationController(){
        initData();
    }
    
    /* Function to initialize data
     * Get list of user from Lead Assignment group and form wrapper
     */
    public void initData(){
        set<Id> setUserId = new set<Id>();
        lstUserWrapper = new List<UserWrapper>();
        
        //Get userid from group member object
        for(GroupMember g:[Select Id,UserOrGroupId,Group.Name 
                           from GroupMember where Group.Name = 'Lead Assignment']){
            setUserId.add(g.UserOrGroupId); 
        }
        
        //Generate wrapper from users
        for(User usr: [SELECT Id, Name, IsRoundRobinAllocationEnabled__c, 
                       LastRRAllocationStatusUpdatedDateTime__c FROM User 
                       WHERE Id In :setUserId]) {
            lstUserWrapper.add(new UserWrapper(usr));
        }
        
        System.debug('--lstUserWrapper:'+lstUserWrapper);
    }
    
    /*
     * Function to update user record
     */
   
    public void setEnableChoice(){
        Id userId = ApexPages.currentPage().getParameters().get('userId'); 
        Boolean isSelected = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isSelected'));
        system.debug('--userId : ' + userId);
        system.debug('--isSelected : ' + isSelected);
        
        User userToUpdate = new User();
        userToUpdate.Id = userId;
        userToUpdate.IsRoundRobinAllocationEnabled__c = isSelected;
        
        update userToUpdate;
        initData();
        
    }
    
    /* @AuraEnabled
public static List<User> getUsers(String pProfileName){
List<User> users
= [SELECT Id, Name,
Username,
IsRoundRobinAllocationEnabled__c,
LastRRAllocationStatusUpdatedDateTime__c 
FROM User
WHERE Profile.Name = :pProfileName
AND IsActive = true
ORDER BY Name];

return users;
}

@AuraEnabled
public static String toggleRoundRobinStatus(String pUserId){
ReturnMessage retMsg = new ReturnMessage();
try{
User usr = [SELECT Id, Name, IsRoundRobinAllocationEnabled__c,
LastRRAllocationStatusUpdatedDateTime__c 
FROM User
WHERE Id = :pUserId];

usr.IsRoundRobinAllocationEnabled__c = !(usr.IsRoundRobinAllocationEnabled__c);
usr.LastRRAllocationStatusUpdatedDateTime__c = System.now();
Database.update(usr);

retMsg.message = 'Round-Robin has been ' + (usr.IsRoundRobinAllocationEnabled__c ? 'enabled' : 'disabled') + ' for ' + usr.Name + '.';
}
catch (Exception e){
retMsg = new ReturnMessage(false, e.getMessage());
}

return JSON.serialize(retMsg);
}

public class ReturnMessage{
public Boolean isSuccess;
public String  message;

public ReturnMessage(){
isSuccess = true;
message = '';
}

public ReturnMessage(Boolean pIsSuccess, String pMessage){
isSuccess = pIsSuccess;
message = pMessage;
}
}* /
set<Id> userId=new set<id>();
List<GroupMember> GroupMemberList = [Select Id, UserOrGroupId 
from GroupMember where Group.Name = 'Lead Assignment' 
ORDER BY UserOrGroupId];
/*for(GroupMember g:[Select Id,UserOrGroupId,Group.Name from GroupMember where Group.Name = 'Lead Assignment' limit 10]){
// userId.add(gm.Id); 
}* / 
map<Id,GroupMember> mapGroupMember = new map<Id,GroupMember>([Select UserOrGroupId, Group.Name 
from GroupMember where Group.Name = 'Lead Assignment' 
ORDER BY UserOrGroupId]);
//System.debug('mapUser:'+mapUser);
public list<UserWrapper> wrapUserList{get;set;} 

public ManageRecordAllocationController(){
// System.debug('mapUser:'+mapUser);
for(GroupMember g:[Select Id,UserOrGroupId,Group.Name from GroupMember where Group.Name = 'Lead Assignment' ORDER BY UserOrGroupId]){
userId.add(g.UserOrGroupId); 
}
if(wrapUserList == null) {
wrapUserList = new List<UserWrapper>();
for(User usr: [SELECT Id, Name, IsRoundRobinAllocationEnabled__c,LastRRAllocationStatusUpdatedDateTime__c FROM User WHERE Id in :userId]) {
wrapUserList.add(new UserWrapper(usr));
}
}
System.debug('wrapUserList:'+wrapUserList);
}*/
    
    
    //Wrapper for List of Users with toggle I/P
    public class UserWrapper{
        public String userName {get;set;}
        public String userId{get;set;}
        public boolean isSelected {get;set;}
        
        public UserWrapper(User user){
            this.userName = user.Name;
            this.userId = user.Id;
            this.isSelected = user.IsRoundRobinAllocationEnabled__c;
        }
    }
}