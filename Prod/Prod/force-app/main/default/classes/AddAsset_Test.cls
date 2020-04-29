@isTest
public class AddAsset_Test  {
    
   @isTest static void testAddAsset() {
   
        Velocify_Settings__c settings = new Velocify_Settings__c ();
        settings.Username__c = 'velocifyapi@stratfs.com';
        settings.Password__c = 'hSh0BoeJ';
        insert settings;
        
        Id clientRecTypeId;
        
        Map<String, RecordTypeInfo> acctRecTypeMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
        if(acctRecTypeMap.containsKey('Client')) {
            clientRecTypeId = acctRecTypeMap.get('Client').getRecordTypeId();
        }
        
        Account acc = new Account();
        //acc.clientnumber__c = 234324;
        acc.nu_dse__Co_First_Name__c = 'TestCo';
        acc.nu_dse__Client_Status__c = 'New Client';
        acc.FirstName = 'Test';
        acc.LastName = 'Test Record';
        acc.RecordTypeId = clientRecTypeId;
        insert acc;
        
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        //program.Id = '234324';
        program.External_Id__c= 'Test_CreateTaskData'; 
        program.Array_Status__c = '37722';
        program.nu_dse__Account__c = acc.Id;
        insert program; 
        
        nu_dse__TradeLine__c tradeLine = new nu_dse__TradeLine__c();
        //tradeLine.Id = '234324';
        tradeLine.nu_dse__Program__c = program.Id;
        tradeLine.nu_dse__Account__c = acc.Id;
        tradeLine.nu_dse__Original_Debt__c = 200;
        insert tradeLine;
        
        
        RestRequest req = new RestRequest();
        req.params.put('clientId', program.Id);
        req.params.put('debtId', tradeLine.Id);
        req.params.put('assetType', 'my_offertype');
        req.params.put('assetFileName','my_filename.jpg');
        req.params.put('assetDescription','my_desc');
        RestResponse res = new RestResponse();
    
        RestContext.request = req;
        RestContext.response = res; 
        
        /*BoxApiConnection api = new BoxApiConnection('clientid', 'clientsecret', 'accessToken', 'refreshToken');
        api.lastRefresh = DateTime.now().getTime() - 5;
        api.expires = api.lastRefresh + 60000;
        BoxApiRequest request = new BoxApiRequest(api,  'https://example.com', 'GET');
        request.setBody('request body', 12);
        request.setTimeout(500);*/
        
        /*req.requestURI ='/AssetService/AddAsset?clientId=123&debtId=1222';
        req.httpMethod = 'POST';
        RestContext.request = req;*/
        
        Test.startTest();
        AddAsset.Response response1 = AddAsset.doPost();
        System.debug(':::Response1:::'+response1);
        Test.stopTest();
   }
   
     @isTest static void testAddAsset1() {
   
        Velocify_Settings__c settings = new Velocify_Settings__c ();
        settings.Username__c = 'velocifyapi@stratfs.com';
        settings.Password__c = 'hSh0BoeJ';
        insert settings;
        
        Id clientRecTypeId;
        
        Map<String, RecordTypeInfo> acctRecTypeMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
        if(acctRecTypeMap.containsKey('Client')) {
            clientRecTypeId = acctRecTypeMap.get('Client').getRecordTypeId();
        }
        
        Account acc = new Account();
        acc.nu_dse__Co_First_Name__c = 'TestCo';
        acc.nu_dse__Client_Status__c = 'New Client';
        acc.FirstName = 'Test';
        acc.LastName = 'Test Record';
        acc.RecordTypeId = clientRecTypeId;
        insert acc;
        
        nu_dse__Program__c program = new nu_dse__Program__c(); 
        //program.Id = '234324';
        program.External_Id__c= 'Test_CreateTaskData'; 
        program.Array_Status__c = '37722';
        program.nu_dse__Account__c = acc.Id;
        insert program; 
        
        nu_dse__TradeLine__c tradeLine = new nu_dse__TradeLine__c();
        tradeLine.nu_dse__Program__c = program.Id;
        tradeLine.nu_dse__Account__c = acc.Id;
        tradeLine.nu_dse__Original_Debt__c = 200;
        //insert tradeLine;
        
        
        RestRequest req = new RestRequest();
        req.params.put('clientId', program.Id);
        req.params.put('debtId', '');
        req.params.put('assetType', 'my_offertype');
        req.params.put('assetFileName','my_filename.jpg');
        req.params.put('assetDescription','my_desc');
        RestResponse res = new RestResponse();
    
        RestContext.request = req;
        RestContext.response = res; 
      
        Test.startTest();
        try{
        AddAsset.Response response1 = AddAsset.doPost();
        }catch(exception e){
        }
        Test.stopTest();
   }

}