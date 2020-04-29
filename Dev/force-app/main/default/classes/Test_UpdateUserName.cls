@isTest
public with sharing class Test_UpdateUserName {

    private static testMethod void testUsernameUpdateMethod() {
         List<User> users = new List<User>();
    for (Integer i = 0; i < 20; i++) {
      User u = new User();
      u.FirstName         = 'Elsa';
      u.LastName          = 'of Arendelle';
      u.Email             = 'elsa@disney.com';
      u.Alias             = 'elsa' + i;
      u.Username          = 'elsa' + i + '@disney.com';
      u.LocaleSidKey      = 'en_US';
      u.TimeZoneSidKey    = 'GMT';
      u.ProfileID         = '00ei0000000rTfz';
      u.LanguageLocaleKey = 'en_US';
      u.EmailEncodingKey  = 'UTF-8';
      users.add(u);
    }
    insert users;
        
        
        Account acc = new Account();
        acc.PersonEmail = 'abc@gmail.com';
        update acc;
        
        List<User> userList = new List<User>();
   /*     
    Set<User> uSet = [select Id,IsActive,Email from User where ]; // all active users
    Test.startTest();          
	
    for(User u : uSet)
		u.IsActive=false;           
	update uSet;
	
	Test.stopTest();
       */
    } 
}