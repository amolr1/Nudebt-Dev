/*
 * This class is used to be as helper for many BOX api callout 
 * */
public class BoxApiHelper {
    public final String clientId;
    public final String clientSecret;
    public String accessToken ;
    public String refreshToken ;
    public static List<String> requestLabels ;
    public static Map<String, List<String>> requestCategToLabels ;
    public static Map<String,String> headers;
    public static integer maxRequestTimeoutMS = 120000;
    public BoxDocumentWrapper.boxDocumentRespose objWrapper;
    public BoxDocumentWrapper.FoldersInfo objWrapperFolderInfo;
    //public static string boxFolderEndPoint = 'https://api.box.com/2.0/folders/';
    public BoxApiHelper(){}
    public BoxApiHelper(String clientId, String clientSecret, String accessToken, String refreshToken){
        this.clientId = clientId;
        this.clientSecret = clientSecret;
        this.setAccessToken(accessToken);
        this.setRefreshToken(refreshToken);
    }
    //global value for access_token
    public static string globalAccess_Token = '65Rt4TFA3naZ1L5pL4XSwwgQJpg5zHP5';
	//method to get a file preview link
	public String getFilePreviewLink(String fieldID) {
        system.debug('clientId>>'+this.clientId);
        system.debug('clientSecret>>'+this.clientSecret);
        system.debug('fileId>>'+fieldID);
        system.debug('accessToken>>'+this.accessToken);
        system.debug('refreshToken>>'+this.refreshToken);
        BoxApiConnection api = new BoxApiConnection(this.clientId, this.clientSecret, this.AccessToken, this.RefreshToken);
        //BoxApiConnection api = new BoxApiConnection(clientId, clientSecret, accessToken, refreshToken);
        BoxFile file = new BoxFile(api, fieldID);
        String previewLink = file.getPreviewLink();
        return previewLink;
    }
    //Method to generate HTTPRequest for call out
    public static HTTPRequest createHTTPReq(String reqBody, string reqEndPoint, string reqMethod, Map<String,String> headersMap){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(reqEndPoint);
        req.setMethod(reqMethod);
        if(reqBody!=null && reqBody!=''){
            req.setbody(reqBody);
        }
        if(headersMap.size()>0){
            for(String ss : headersMap.keyset()){
                req.setHeader(ss,headersMap.get(ss));   
            }
        }
        req.setTimeout(maxRequestTimeoutMS);
        return req;
    }    
    //Method to do call out to Box
    public static HTTPResponse sendHttpRequest(HTTPRequest req){
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('****response body:'+res.getBody());
        return res;
    }
	//flter all subfolders based on existing schema
    public BoxDocumentWrapper.FoldersInfo doFilterBasedOnSettingSchema(BoxDocumentWrapper.FoldersInfo objWrappFolderInfo){
        system.debug('objWrappFolderInfo>>>'+objWrappFolderInfo);
        objWrapperFolderInfo = new BoxDocumentWrapper.FoldersInfo();
        List<BoxDocumentWrapper.entry> ohjEntityList =  new List<BoxDocumentWrapper.entry>();
        //objWrappFolderInfo.item_collection.entries = new List<BoxDocumentWrapper.entry>();
        //get All existing subfolder schema
        integer countReduce = 0;
        Map<String, Portal_Box_Document_Mapping__c> mapCategoryTypeToSchema = Portal_Box_Document_Mapping__c.getAll();
        system.debug('mapCategoryTypeToSchema>>>'+mapCategoryTypeToSchema);
        //if(objWrappFolderInfo.item_collection.entries.size()> 0 ){
            for(String PortalDocName : mapCategoryTypeToSchema.keyset()){
                system.debug('mapCategoryTypeToSchema.get(PortalDocName).Box_Folder_Names__c>>>'+mapCategoryTypeToSchema.get(PortalDocName).Box_Folder_Names__c);
                if(mapCategoryTypeToSchema.get(PortalDocName).Box_Folder_Names__c != null){
                    system.debug('BoxName--'+PortalDocName+'AllBoxFolderName>>>>'+mapCategoryTypeToSchema.get(PortalDocName).Box_Folder_Names__c.split(';'));
                    for(String boxFolderName :  mapCategoryTypeToSchema.get(PortalDocName).Box_Folder_Names__c.split(',')){
                        system.debug('boxFolderName----'+boxFolderName);
                        for(BoxDocumentWrapper.entry en: objWrappFolderInfo.item_collection.entries){
                            system.debug('en----'+en);
                            if(boxFolderName == en.name){
                                BoxDocumentWrapper.entry objItem = en;
                                objItem.category = PortalDocName;
                                ohjEntityList.add(objItem);
                            }
                        }
                    }
                }
            }
            system.debug('objWrappFoldeohjEntityListrInfo>>>'+ohjEntityList);
            objWrappFolderInfo.item_collection.entries = ohjEntityList;
        //}
        system.debug('objWrappFolderInfo>>>'+objWrappFolderInfo);
     
        return objWrappFolderInfo;
    }
	
    //Create HTTP request header
	public static Map<String, String> getRequestHeader(String access_token){
        if(String.isNotBlank(access_token)){
			headers=new Map<String,String>();
			headers.put('Content-Type','application/x-www-form-urlencoded');
			headers.put('Accept','application/json');
			headers.put('Authorization','Bearer ' + access_token);
			return headers;
		}else{
			return null;
		}			
	}
        
    //get All subfolder details
    public static  Map<String, List<BoxDocumentWrapper.subfolderDetailsWrapper>> doFetchAllSubfolderInfo( Map<String, List<BoxDocumentWrapper.entry>> mapCategoryToEntries, String access_token, String boxFolderEndPoint){
        system.debug('mapCategoryToEntries!!!'+mapCategoryToEntries);
        Map<String, List<BoxDocumentWrapper.subfolderDetailsWrapper>> mapCategoryToSubFolderEntryInfo = new Map<String, List<BoxDocumentWrapper.subfolderDetailsWrapper>>();
        BoxDocumentWrapper.subfolderDetailsWrapper objSubFolderWrapper;
        //String access_token = 'HJjC6PfKvq6jPw3BNx7t3YH3O29hhcAs';
        headers = getRequestHeader(access_token);
        HTTPResponse res ;
        String resposeBody = '';
        String boxFolderEndPointTemp = '';
        String requestParam = '/items?fields=name,created_at,modified_at,extension,size,expiring_embed_link';
        for(String strCategory : mapCategoryToEntries.keySet()){
            for(BoxDocumentWrapper.entry objWraapEntry : mapCategoryToEntries.get(strCategory)){
                boxFolderEndPointTemp = boxFolderEndPoint + '/' + objWraapEntry.id + requestParam;
                System.debug('boxFolderEndPoint>>>>'+boxFolderEndPoint);
                if(createHTTPReq('', boxFolderEndPointTemp,'GET',headers) != null && createHTTPReq('', boxFolderEndPointTemp,'GET',headers).getMethod().startsWith('GET')){
                    HttpRequest objRequestLabel  = createHTTPReq('', boxFolderEndPointTemp,'GET',headers);
                    res = sendHttpRequest(objRequestLabel); //Callout in for loop as we have fetch all subfolder details
                    system.debug('res!!!!!'+res);
                    if(res.getStatusCode() == 200 && res.getStatus() == 'OK'){
                        resposeBody = res.getBody();
                        
                        string resposeBodyTemp = resposeBody.replace('"limit"','"res_limit"');
                        system.debug(resposeBodyTemp+'resposeBody!!!!@!!!!!');
                        
                        objSubFolderWrapper = (BoxDocumentWrapper.subfolderDetailsWrapper)JSON.deserialize(resposeBodyTemp,BoxDocumentWrapper.subfolderDetailsWrapper.class);
                        
                        system.debug('objSubFolderWrapper===='+objSubFolderWrapper);
                        if(!mapCategoryToSubFolderEntryInfo.containsKey(strCategory)){
                            mapCategoryToSubFolderEntryInfo.put(strCategory, new List<BoxDocumentWrapper.subfolderDetailsWrapper>());
                        }
                        mapCategoryToSubFolderEntryInfo.get(strCategory).add(objSubFolderWrapper);
                    }
                    
                }
            }
        }
        system.debug('mapCategoryToSubFolderEntryInfo>!!!>>'+mapCategoryToSubFolderEntryInfo);
        if(!mapCategoryToSubFolderEntryInfo.isEmpty()){
            return mapCategoryToSubFolderEntryInfo;
        }else{
            return null;
        }
    }
    //generic method to download a file
    public static String downloadSelectedFileHelper(String fileID, String access_token){
        String endpointForFileDownload = ' https://api.box.com/2.0/files/'+fileID+'/content';
        HTTPResponse res ;
        String sFilename='';
        Blob body;
        //String access_token = 'HJjC6PfKvq6jPw3BNx7t3YH3O29hhcAs';
        try{
            headers = getRequestHeader(access_token); 
            system.debug('href----'+headers);
            HttpRequest objRequestLabel  = createHTTPReq('', endpointForFileDownload , 'GET' , headers);
            res = sendHttpRequest(objRequestLabel); 
            if(res.getStatusCode() == 302 && res.getStatus() == 'Found' ){
                system.debug('doc-----'+res.getBody());
                String fileDownloadURL = res.getHeader('Location');
                system.debug('fileDownloadURL----'+fileDownloadURL);
                return fileDownloadURL;
            }else{
                throw new AuraException('Something went wrong while downloading the file - '+res.getStatus());
            }
        }catch(Exception ex){
            throw new AuraException('Something went wrong while downloading the file - '+ex.getMessage());
        }
    }
    //Set access token to current instance
    private virtual void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }
    //Set refresh token to current instance
    private virtual void setRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }
    public class FolderSchemaWrapper{
        public List<FilterFolders> lstFilterItems ;
    }
    public class FilterFolders{
        public string id;  
        public String name; 
        public String category;  
        public FilterFolders(String id, String name, String category){
            this.id = id;
            this.name = name;
            this.category = category;
        }
    }
	public class continuationWrapperList{
		public object continuationWrapperlst ;
	}
	public class continuationWrapper{
		public Continuation objContinuation ;
		public List<String> requestsPerContinuation;
	}
}