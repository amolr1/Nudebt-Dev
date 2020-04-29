/*
 * This class is used as DocumentCenter Server side controller
 */
public class SFSPortal_DocumentCenterCtrl {
	public static String boxGlobalAccessToken = CreateParentAndSubFoldersInBox.getAccessToken();
    public static Map<String,String> headers;
    public SFSPortal_DocumentCenterCtrl(){
        headers = new Map<String,String>();
    }
    
    @AuraEnabled
    public static Map<String, List<BoxDocumentWrapper.subfolderDetailsWrapper>> getSelectedFolderSchema() {
      //  try{
            BoxApiHelper objhandler = new BoxApiHelper();  //helper class object
            //BoxDocumentWrapper objWrapper = new BoxDocumentWrapper();
            String strCurrentUserFolderId ; //desired box folder ID
            BoxDocumentWrapper.FoldersInfo objFolderWrapp = new BoxDocumentWrapper.FoldersInfo();
            //Map<String, List<BoxDocumentWrapper.FoldersInfo>> mapCategoryToSubFolderInfo = new Map<String, List<BoxDocumentWrapper.FoldersInfo>>();
            Map<String, List<BoxDocumentWrapper.subfolderDetailsWrapper>> mapCategoryToSubFolderEntryInfo = new Map<String, List<BoxDocumentWrapper.subfolderDetailsWrapper>>();
            Map<String, Id> accountIdMap = SFSPortal_Utility.getAccountIdFromCurrentUser(); //get Current context account record
            String accountId = accountIdMap.get('primaryAccountId');
            Map<String, nu_dse__Program__c> mapAccountIdToProgram = new Map<String, nu_dse__Program__c>();
            for(nu_dse__Program__c objProgram : [SELECT Id, nu_dse__Account__r.BoxFolderId__c FROM nu_dse__Program__c WHERE nu_dse__Account__c =: accountId]){
                mapAccountIdToProgram.put(objProgram.nu_dse__Account__c, objProgram);
            }
            system.debug('mapAccountIdToProgram---'+mapAccountIdToProgram);
            if(mapAccountIdToProgram != null && !mapAccountIdToProgram.isEmpty() && mapAccountIdToProgram.get(accountId).nu_dse__Account__r.BoxFolderId__c != null){
                strCurrentUserFolderId = mapAccountIdToProgram.get(accountId).nu_dse__Account__r.BoxFolderId__c; //fetch from local folder
            }
            system.debug('strCurrentUserFolderId---'+strCurrentUserFolderId+'boxGlobalAccessToken---'+boxGlobalAccessToken);
            //strCurrentUserFolderId = '108952151004' ; //fetch from local folder
            //Box__c settingCred = Box__c.getInstance('Cred');
            Box_settings__c settingCred = Box_settings__c.getValues('box');
            system.debug('settingCred--'+settingCred);
            if(settingCred != null && String.isNotBlank(settingCred.Folder_Endpoint__c)){
                String Response='';
                
                //FoldersInfo folderDetails = new FoldersInfo();
                Map<String, List<BoxDocumentWrapper.entry>> mapCategoryToItems = new Map<String, List<BoxDocumentWrapper.entry>>();
                Map<String,String>folderNameToIdMap = new Map<String,String>();
                //The root folder of a Box account is always represented by the id “0”.
                String boxFolderURL = settingCred.Folder_Endpoint__c +'/' +strCurrentUserFolderId;
                headers = BoxApiHelper.getRequestHeader(boxGlobalAccessToken);
                
                HTTPRequest req = BoxApiHelper.createHTTPReq('', boxFolderURL,'GET',headers);
                system.debug('req>>>'+req);
                //do call out to fetch folders details
                HTTPResponse res = BoxApiHelper.sendHttpRequest(req);
                system.debug('res>>>'+res);
                if(res.getStatusCode() == 200 && res.getStatus() == 'OK'){
                    Response = res.getBody();
                    System.debug('**Folder Response:'+Response);
                    //parse JSON response
                    
                    objFolderWrapp = (BoxDocumentWrapper.FoldersInfo)JSON.deserialize(Response,BoxDocumentWrapper.FoldersInfo.class);
                    system.debug('********objFolderWrapp :'+objFolderWrapp);
                    if(objFolderWrapp.item_collection.entries.size()>0){
                       
                        system.debug('responce1231'+objhandler.doFilterBasedOnSettingSchema(objFolderWrapp));
                        objFolderWrapp   = objhandler.doFilterBasedOnSettingSchema(objFolderWrapp);
                        system.debug('schameWrapperFolder.lstFilterItems>>'+objFolderWrapp);
                        
                        for(BoxDocumentWrapper.entry objWrapperFolderentry : objFolderWrapp.item_collection.entries){
                            if(objWrapperFolderentry.id != null && objWrapperFolderentry.name != null){
                                if(!mapCategoryToItems.containsKey(objWrapperFolderentry.category)){
                                    mapCategoryToItems.put(objWrapperFolderentry.category, new List<BoxDocumentWrapper.entry>());
                                }
                                mapCategoryToItems.get(objWrapperFolderentry.category).add(objWrapperFolderentry);
                            }
                        }
                        system.debug('mapCategToRequests----'+mapCategoryToItems);
                        
                        //mapCategoryToSubFolderInfo = BoxApiHelper.doFetchAllSubfolderInfo(mapCategoryToItems);
                        mapCategoryToSubFolderEntryInfo = BoxApiHelper.doFetchAllSubfolderInfo(mapCategoryToItems, boxGlobalAccessToken, (String) settingCred.Folder_Endpoint__c);
                        
                    }
                    
                }else{
                    throw new AuraException('Parent Folder Authorization failed!!' +res.getStatusCode());
                }
                system.debug('mapCategoryToSubFolderEntryInfo---'+mapCategoryToSubFolderEntryInfo);
                if(mapCategoryToSubFolderEntryInfo != null && !mapCategoryToSubFolderEntryInfo.isEmpty()){
                    return mapCategoryToSubFolderEntryInfo;
                }else{
                    return null;
                }
            }else{
                throw new AuraException('Box configuration setting not found !!');
            }
            
       // }catch(Exception ex){
       //     throw new AuraException('Something went wrong '+ex.getMessage());
       // }
    }
    //method to get download selected file
    @AuraEnabled
    public static String  downloadSelectedFile(String fileId){
        if(String.isNotBlank(fileId)){
            system.debug('boxGlobalAccessToken--!!!!'+boxGlobalAccessToken);
            return BoxApiHelper.downloadSelectedFileHelper(fileId, boxGlobalAccessToken);
        }else{
            throw new AuraException('Something went wrong - FileID is not accurate !');
        }
    }
   
    //Box responce parser class   
   // public class BoxResponse{
   //     @AuraEnabled public FoldersInfo folderDetails;
   // }
    //apex class structure to deserialize Folder response JSON
  /*  public class FoldersInfo{
        @AuraEnabled public String type;
        @AuraEnabled public String id;
        @AuraEnabled public String sequence_id;
        @AuraEnabled public String etag;
        @AuraEnabled public String name;
        @AuraEnabled public String created_at;
        @AuraEnabled public String modified_at;
        @AuraEnabled public String item_status;
        @AuraEnabled public String description;
        @AuraEnabled public itemCollections item_collection;
        
    } 
    
    public class itemCollections{
        @AuraEnabled public String total_count;
        @AuraEnabled public List<entry> entries;
    }
    public class entry{
        @AuraEnabled public String type;
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String category;
        @AuraEnabled public ParentClass parent;
        @AuraEnabled public ModifiedClass modified_by;
        
    }
    public class ParentClass {
        @AuraEnabled public string id;    
    }
    public class ModifiedClass {
        @AuraEnabled public string id;  
        @AuraEnabled public String name;  
    }
    //new Wrapper
   
    public class FoldersInfoWrapp{
        public String type;
        public String id;
        public String sequence_id;
        public String etag;
        public String name;
        public String created_at;
        public String modified_at;
        public String item_status;
        public String description;
        public itemCollectionsWrapp item_collection;
        public FoldersInfoWrapp(){}
        public FoldersInfoWrapp(String type,String id,String sequence_id,String etag,String name,String created_at,String modified_at,String description,String item_status ){
            this.type=type;
            this.id=id;
            this.sequence_id=sequence_id;
            this.etag=etag;
            this.created_at=created_at;
            this.modified_at=modified_at;
            this.description=description;
            this.item_status=item_status;
            this.item_collection=new itemCollectionsWrapp();
            
        }
    }
    public class itemCollectionsWrapp{
        public String total_count;
        public List<entryWrapp> entries;
        public itemCollectionsWrapp(){}
        public itemCollectionsWrapp(String count){
            this.total_count = count;
            this.entries=new list<entryWrapp>();  
        }
    }
    public class entryWrapp{
        public String type;
        public String id;
        public String name;
        public string content_modified_at;
        public String category; 
        public entryWrapp(String type,String id,String name,String content_modified_at, String category){
            this.type=type;
            this.id=id;
            this.name=name;
            this.content_modified_at = content_modified_at;
            this.category = category;
        }   
    }*/
}