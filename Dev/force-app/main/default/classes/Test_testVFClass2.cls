@isTest
public class Test_testVFClass2 {
 @isTest public static void testGetData(){
     	
     	Account account1 = SFSPortal_TestRecordCreator.createAccount('Test Account 1',SFSPortal_TestRecordCreator.getRecordTypeId('Account','Client'));
        insert account1;
        
        nu_dse__program__c programInstance = SFSPortal_TestRecordCreator.createProgram(account1.Id,null);
        insert programInstance;
     
        nu_dse__Group_Task__c gt1 = new nu_dse__Group_Task__c();
        gt1.nu_dse__Subject__c = 'Test';
        gt1.nu_dse__ActivityDate__c = System.today();
        gt1.nu_dse__Type__c = '';
        gt1.nu_dse__Description__c = 'Test Group Task 1';
        gt1.nu_dse__Status__c = 'Completed';
     	gt1.nu_dse__Related_To__c = programInstance.id;
        insert gt1;

        nu_dse__Group_Task__c gt2 = new nu_dse__Group_Task__c();
        gt2.nu_dse__Subject__c = 'Test';
        gt2.nu_dse__ActivityDate__c = System.today();
        gt2.nu_dse__Type__c = '';
        gt2.nu_dse__Description__c = 'Test Group Task 1';
        gt2.nu_dse__Status__c = 'In Progress';
     	gt2.nu_dse__Related_To__c = programInstance.id; 
        insert gt2;
        
        task t = new task();
        t.Subject = 'test';
        t.ActivityDate = System.today();
        t.Status = 'Completed';
        t.Priority = 'High';
        t.Description = 'Test Task';
     	t.WhatId = programInstance.id; 
        insert t;
        
        Event ev = new Event();
        ev.Subject = 'Test Eve';
        ev.ActivityDate = System.today();
        ev.StartDateTime = System.today();
        ev.EndDateTime = System.today() + 2;
        ev.Description = 'Test Description';
        ev.IsNote__c = True;
     	ev.WhatId = programInstance.id;
        insert ev;
     
     	Event ev1 = new Event();
        ev1.Subject = 'Test Eve';
        ev1.ActivityDate = System.today();
        ev1.StartDateTime = System.today();
        ev1.EndDateTime = System.today() + 2;
        ev1.Description = 'Test Description';
        ev1.IsNote__c = False;
     	ev1.WhatId = programInstance.id;
        insert ev1;

        
        testVFClass2 tvc = new testVFClass2();
    
        
        Test.startTest();
        tvc.getdata();
        tvc.GetGroupTaskInfo();
        testVFClass2.readFieldSet('nu_dse__CreateGroupTask','nu_dse__Group_Task__c');
     
		// View/Edit Task
        tvc.TaskId = t.id;
        tvc.dynamicqueryTask();
        tvc.dynamicqueryEvent();
      	tvc.scheduleTask();
        tvc.viewTask();
        tvc.EditTask();
     	tvc.saveTaskModal();
     	tvc.cancelTaskModal();
        
        // View/Edit Group Task
        testVFClass2.groupTaskId = gt1.id;
        tvc.dynamicqueryGroupTask();
     	tvc.CreateGroupTask();
        tvc.viewGroupTask();
        tvc.EditGroupTask();
     	tvc.saveGroupTaskModal();
     
     
        
        //View/Edit Event
        tvc.EventId = ev.id;
     	tvc.scheduleEvent();
        tvc.viewEvent();
        tvc.EditEvent();
     	tvc.canceleventModal();
        tvc.saveeventModal();
     
        tvc.CreateGroupTask();
        tvc.cancelGroupTaskModal();
        tvc.scheduleTask();
     	tvc.createGroupTask = gt1;
     	tvc.saveGroupTaskModal();
        tvc.cancelTaskModal();
        
        tvc.canceleventModal();
        tvc.CreateNote();
      	tvc.Titles = 'test_Title';
        tvc.Bd  = 'test_body';
     	tvc.CreateNotesSave();
        tvc.cancelNotes();
     
     
         PageReference pageRef = Page.ActivityTabNew5_2; 
         pageRef.getParameters().put('recordId', String.valueOf(programInstance.Id));
         Test.setCurrentPage(pageRef);
        
        testVFClass2.getGroupTask(String.valueOf(programInstance.Id));
     	testVFClass2.getGroupTaskHistory(String.valueOf(programInstance.Id));
     	testVFClass2.getOpenTask(String.valueOf(programInstance.Id));
     	testVFClass2.getOpenTaskHistory(String.valueOf(programInstance.Id));
     	testVFClass2.getOpenEvent(String.valueOf(programInstance.Id));
     	testVFClass2.getEventHistory(String.valueOf(programInstance.Id));
     	testVFClass2.getGTInfo(gt1.Id); 
     
 		Test.stopTest(); 
     
     
 }
}