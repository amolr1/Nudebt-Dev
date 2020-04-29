@isTest
public class SFSPortal_CustomLookupController_Test {
    private static testMethod void getSearchResult_Test(){
		    Contact con =  new Contact();
        	con.LastName = 'Test';
        	con.Email = 'Test@test.com';
        	insert con;
        
        Test.startTest();
        SFSPortal_CustomLookupController.getSearchResult('Test','Contact','Email','');   
        Test.stopTest();
    }
}