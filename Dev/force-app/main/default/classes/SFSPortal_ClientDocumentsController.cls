/* Date : 04-12-2018
 * Author : Team IDev
 * Description : Handler for clientDocuments component
 */
public class SFSPortal_ClientDocumentsController {
    
    public String access_token {get; set;}
    public string previewLogoURL{get;set;}
    
    public void getAccessToken() {
    
        if (FeatureManagement.checkPermission('My_Document')) {
        
            access_token = global_accesstoken;//CreateParentAndSubFoldersInBox.getAccessToken();
            Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser();
            if (accountIdMap != null && accountIdMap.isEmpty() == FALSE) {
            
                String accountId = accountIdMap.get('primaryAccountId');
                
                if (String.isNotBlank(accountId) == TRUE) {
                
                    List<nu_dse__Program__c> programList = [SELECT Id, Portfolio__r.Box_Preview_Logo_Name__c, Portfolio__r.Domain_URL__c 
                                                            FROM nu_dse__Program__c 
                                                            WHERE nu_dse__Account__c =:accountId AND Portfolio__c != null AND Portfolio__r.Box_Preview_Logo_Name__c != null];
                    
                    if (programList != null && programList.isEmpty() == False) {
                        
                        List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource 
                                                            WHERE Name = :programList[0].Portfolio__r.Box_Preview_Logo_Name__c LIMIT 1];
                        
                        if (resourceList.isEmpty() == FALSE){
                        
                           this.previewLogoURL =  programList[0].Portfolio__r.Domain_URL__c + '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + resourceList[0].Name; 
                        }
                    }
                }
            }
        }
        
    }
    
    public static String global_accesstoken = CreateParentAndSubFoldersInBox.getAccessToken();
    
    /* Date : 04-12-2018
     * Description : Method to get the folders which client can see from portfolio level
     * Invoked From : clientDocuments.cmp
     */
    @AuraEnabled
    public static List<EntriesClass> getFolderNames() {
        
        List<EntriesClass> folderList = new List<EntriesClass>();
        try {
            
            Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser();
            if(accountIdMap != null && accountIdMap.isEmpty() == FALSE) {
                
                String accountId = accountIdMap.get('primaryAccountId');
                
                if(String.isNotBlank(accountId) == TRUE) {
                    
                    List<nu_dse__Program__c> programList = [SELECT Id, Portfolio__r.Client_Folders__c, nu_dse__Account__r.BoxFolderId__c FROM nu_dse__Program__c WHERE nu_dse__Account__c =:accountId];
                    
                    System.debug('**** programList-->' + programList);
                    
                    if(programList.isEmpty() == FALSE && programList[0].Portfolio__r.Client_Folders__c != null) {
                    
                        List<String> folderNameList = programList[0].Portfolio__r.Client_Folders__c.split(';');
                        
                        String boxFolderId = programList[0].nu_dse__Account__r.BoxFolderId__c;
                        
                        Box_settings__c boxSettings = Box_settings__c.getValues('box');
                        
                        System.debug('**** boxSettings-->' + boxSettings);
                        
                        String access_token = global_accesstoken; 
                        
                        if (boxSettings != null) {
                        
                            if(String.isNotBlank(boxFolderId) == TRUE && String.isNotBlank(boxSettings.Folder_Endpoint__c) == TRUE) {
                        
                                String finalEndpoint = boxSettings.Folder_Endpoint__c + '/' + boxFolderId + '/items?type=folder&limit=1000&fields=id,name';
                                system.debug('------finalSearchEndpoint-----' + finalEndpoint);
                                HttpRequest requestToSend = new HttpRequest();
                                requestToSend.setEndpoint(finalEndpoint);
                                requestToSend.setMethod('GET');
                                requestToSend.setHeader('Authorization', 'Bearer ' + access_token);
                                system.debug('------requestToSend-----' + requestToSend);
                                
                                Http httpToSend = new Http();
                                HttpResponse response = new HttpResponse();
                                response = httpToSend.send(requestToSend);
                                system.debug('------response-----' + response);
                                
                                if (string.isNotBlank(response.getBody())) {
                                
                                    BoxResponse boxResponseInstance = (BoxResponse)JSON.deserialize(response.getBody(), BoxResponse.class);
                                    
                                    if(boxResponseInstance != null && boxResponseInstance.entries != null) {
                                        
                                        for (EntriesClass boxWrapperInstance : boxResponseInstance.entries) {
                                            
                                            System.debug('****** boxWrapperInstance -->' + boxWrapperInstance);
                                            for(String folderName : folderNameList) {
                                                
                                                System.debug('****** folderName -->' + folderName);
                                                if(folderName == boxWrapperInstance.name) {
                                                
                                                    folderList.add(boxWrapperInstance);
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
            
        } catch(Exception e) {
        
            throw new AuraHandledException(e.getMessage());
        }
        
        return folderList;
    }
    
    /* Date : 04-12-2018
     * Description : Method to get the folders which client can see from portfolio level
     * Invoked From : clientDocuments.cmp
     */
    @AuraEnabled
    public static List<EntriesClass> getAllSubFoldersAndFiles(List<String> selctedFolderId) {
        system.debug('selctedFolderId>>>'+selctedFolderId);
        List<EntriesClass> entryList = new List<EntriesClass>();
        
        try {
        
            if(selctedFolderId != null && !selctedFolderId.isEmpty()) {
                    
                Box_settings__c boxSettings = Box_settings__c.getValues('box');
                
                System.debug('**** boxSettings-->' + boxSettings);
                        
                if (boxSettings != null) {
                    
                    String access_token = global_accesstoken; //CreateParentAndSubFoldersInBox.getAccessToken();
                    System.debug('***** access_token-->' + access_token);

                    //iterate all subfolder ids
                    for(string SubFolderid : selctedFolderId){
                        system.debug('SubFolderid---'+SubFolderid);
                        HttpRequest requestToSend = new HttpRequest();
                        
                        String finalEndpoint = boxSettings.Folder_Endpoint__c + '/' + SubFolderid + '/items';
                        system.debug('------finalSearchEndpoint ----' + finalEndpoint);
                        requestToSend.setEndpoint(finalEndpoint);
                        requestToSend.setMethod('GET');
                        requestToSend.setHeader('Authorization', 'Bearer ' + access_token);
        
                        Http httpToSend = new Http();
                        HttpResponse response = new HttpResponse();
                        response = httpToSend.send(requestToSend);
        
                        system.debug('---Response from Folder Search'+response.getBody());
                        
                        if (string.isNotBlank(response.getBody())) {
                            
                            //Serialize response into wrapper inorder to support bulkified results. (entries node is a list)
                            BoxResponse boxResponseInstance = (BoxResponse) JSON.deserialize(response.getBody(), BoxResponse.class);
                            System.debug('boxEntries-->'+boxResponseInstance);
                            
                            //Looping the entries node in the response and compare it with rootfolder id. If it matches then populate boxfolderId, boxfolderName and rootfolderId.
                            if(boxResponseInstance != null && boxResponseInstance.entries != null) {
                                
                                for (EntriesClass boxWrapperInstance : boxResponseInstance.entries) {
                                    
                                    entryList.add(boxWrapperInstance);
                                }
                            }
                        }
                    }
                    system.debug('responses---'+entryList);
                }
            }
               
        } catch(Exception e) {
        
            throw new AuraHandledException(e.getMessage());
        }
        
        return entryList;
    }

    /* Date : 04-03-2020
     * Description : Method to get portal document mapping based on box folder names request
     * Invoked From : clientDocuments.cmp
     */
    @AuraEnabled
    public static List<EntriesClass> getPortalBoxNameFromBoxFolders(List<String> allBoxFolderNames){
        system.debug('FetchedBoxFolders>>>>'+allBoxFolderNames);
        List<EntriesClass> lstBoxFolders = new List<EntriesClass>() ;
        String targetPortalBoxFolderName ='';
        //get box to portal document type mapping
        Map<String, Portal_Box_Document_Mapping__c> mapPortalBoxNameToBoxFolders = Portal_Box_Document_Mapping__c.getAll();
        system.debug('AllCSEntries-----'+mapPortalBoxNameToBoxFolders.keyset());
        for(String PortalDocName : mapPortalBoxNameToBoxFolders.keyset()){
            if(mapPortalBoxNameToBoxFolders.get(PortalDocName).Box_Folder_Names__c != null){
                system.debug('BoxName--'+PortalDocName+'AllBoxFolderName>>>>'+mapPortalBoxNameToBoxFolders.get(PortalDocName).Box_Folder_Names__c.split(';'));
                for(String boxFolderName :  mapPortalBoxNameToBoxFolders.get(PortalDocName).Box_Folder_Names__c.split(',')){
                    system.debug('checkcondition----'+'boxFolderName--'+boxFolderName+'allBoxFolderNames>>>'+allBoxFolderNames);
                    if(allBoxFolderNames.contains(boxFolderName)){
                        targetPortalBoxFolderName = PortalDocName;
                        EntriesClass objEntries = new EntriesClass();
                        objEntries.id='1';
                        objEntries.name = targetPortalBoxFolderName;
                        objEntries.type = 'folder';
                        lstBoxFolders.add(objEntries);
                        break;
                    }
                }
            }
        }
        system.debug('targetPortalBoxFolderName====='+lstBoxFolders);
        return lstBoxFolders;
    }
    
    public class BoxResponse {
        
        @AuraEnabled
        public List<EntriesClass> entries;
    }
    
    public class EntriesClass {
        
        @AuraEnabled
        public String id;
        
        @AuraEnabled
        public String name;
        
        @AuraEnabled
        public ParentClass parent;
        
        @AuraEnabled
        public ModifiedClass modified_by;
        
        @AuraEnabled
        public String type;
    }
    
    public class ParentClass {
        
        @AuraEnabled
        public string id;    
    }
    
    public class ModifiedClass {
        
        @AuraEnabled
        public string id;  
        
        @AuraEnabled
        public String name;  
    }
 
    
}