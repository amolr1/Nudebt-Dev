global class TransUnionCreditPullerHandler {
    
    
    webservice static void TransUnionWebService(string AccountId)
    {
       TransUnionCalloutAsync(AccountId);
    }
    
    @Future(callout=true)
    public static void TransUnionCalloutAsync(Id accountId)
    {
        Account a = [Select Name,NDS_File_Number__c,PersonMailingStreet,PersonMailingCity,PersonMailingState,PersonMailingPostalCode,PersonBirthdate from Account where id=:accountId];
        TransUnionCreditPuller(a);
    }
    
    public static void TransUnionCalloutSync(Account a)
    {
        TransUnionCreditPuller(a);
    }
    
    private static string trimAccountNumber(string accountnumber)
    {
        Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9]'); 
        Matcher matcher = nonAlphanumeric.matcher(accountnumber);
        return matcher.replaceAll('');
    }
    
   
    private static void TransUnionCreditPuller(Account a)
    {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        string endPointURL = getEndPointURL(a);
        request.setEndpoint(endPointURL);
        request.setMethod('GET');
        //request.setHeader('Authorization', 'Basic NWI1YjQwYjk5ODVmNjcyMGFiZThlNzcxOkY2dE83NDA0bXZvSG9oZWlWcUFSNUFUWQ==');
        HttpResponse response = http.send(request);
        system.debug('++++++++++++++++++++++ endPointURL  ' + endPointURL);
        System.debug('*****'+response);
        System.debug('*****'+response.getBody());
        
        if (response.getStatusCode() == 200) {
            
            Map<string,string> accNoAmountMap = new Map<string,string>();
            TransUnionCreditPullerResponse responseWrapper1 = TransUnionCreditPullerResponse.parse(response.getBody());
            System.debug('+++++++++++++++ responseWrapper1' + responseWrapper1);
            
            try
            {
                TransUnionCreditPullerResponse responseWrapper = TransUnionCreditPullerResponse.parse(response.getBody());
                TransUnionCreditPullerResponse.cls_Collection responseCollection = responseWrapper.data.file.hx5.bureau_xml_data.tu_report.subject_segments.collection_segments.collection;  
                accNoAmountMap.put(responseCollection.account_number,responseCollection.current_balance);
            }
            catch(Exception e){}
            
            try
            {
                TransUnionCreditPullerResponse responseWrapper = TransUnionCreditPullerResponse.parse(response.getBody());
                for(TransUnionCreditPullerResponse.cls_trade trade:responseWrapper.data.file.hx5.bureau_xml_data.tu_report.subject_segments.trade_segments.trade)
                {
                    accNoAmountMap.put(trade.account_number,trade.balance);
                }
            }
            catch(Exception e){}
            
            System.debug('+++++++++++++++ accNoAmountMap' + accNoAmountMap);
            List<nu_dse__TradeLine__c> tradeLineUpdateList = new List<nu_dse__TradeLine__c>();
            for (nu_dse__TradeLine__c tradeLine : [Select nu_dse__New_Account_Number__c,SFS_Current_Balance__c from nu_dse__TradeLine__c 
                                                   where nu_dse__New_Account_Number__c In: accNoAmountMap.KeySet() and nu_dse__Program__r.nu_dse__Account__r.Id =: a.Id])
            {
                     
                     if(accNoAmountMap.containsKey(trimAccountNumber(tradeLine.nu_dse__New_Account_Number__c)))
                     {
                         tradeLine.SFS_Current_Balance__c = Decimal.valueOf(accNoAmountMap.get(trimAccountNumber(tradeLine.nu_dse__New_Account_Number__c)));
                         tradeLineUpdateList.add(tradeLine);
                     }
                     
             }
                 
             update tradeLineUpdateList;

            
        } else {
            
        }
        
    }
    
    private static string getEndPointURL(Account a) {
        String endPointURL = 'callOut:Credit_Puller';
        endPointURL += (String.IsBlank(a.NDS_File_Number__c) ? '/99999999' : '/' + a.NDS_File_Number__c.leftPad(5,'0'));
        
        String paramString = '?';
        
        if (String.IsNotBlank(a.Name)){
            paramString += ('name=' + EncodingUtil.urlEncode(a.Name, 'UTF-8') + '&');
        }
        if (String.IsNotBlank(a.PersonMailingStreet)){
            paramString += ('address=' + EncodingUtil.urlEncode(a.PersonMailingStreet, 'UTF-8') + '&');
        }
        if (String.IsNotBlank(a.PersonMailingCity)){
            paramString += ('city=' + EncodingUtil.urlEncode(a.PersonMailingCity, 'UTF-8') + '&');
        }
        if (String.IsNotBlank(a.PersonMailingState)){
            paramString += ('state=' + EncodingUtil.urlEncode(a.PersonMailingState, 'UTF-8') + '&');
        }
        if (String.IsNotBlank(a.PersonMailingPostalCode)){
            paramString += ('zip=' + EncodingUtil.urlEncode(a.PersonMailingPostalCode, 'UTF-8') + '&');
        }
        if (a.PersonBirthdate != null){
            paramString += ('birthdate=' + EncodingUtil.urlEncode('12/12/1990', 'UTF-8') + '&');
        }
        
        paramString += ('format=' + EncodingUtil.urlEncode('JSON', 'UTF-8') + '&');
        paramString += ('pulltype=' + EncodingUtil.urlEncode('soft', 'UTF-8'));
        
        
        endPointURL = (paramString.equals('?') ? endPointURL : endPointURL + paramString);
        return endPointURL;
    }
    
}