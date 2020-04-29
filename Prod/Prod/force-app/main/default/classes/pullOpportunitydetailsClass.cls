@RestResource(urlMapping='/pullOpportunitydetails/*')
global class pullOpportunitydetailsClass{
    //public static boolean isNewTradeLine=False;   //PDI-948
    @HttpPost
    global static String pullOpportunitydetails() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        String opportunityId;
        String jsonStr = '';
        ///services/apexrest/pullOpportunitydetails?oppId=123
        //opportunityId = RestContext.request.params.get('oppId');
        opportunityId = RestContext.request.requestBody.toString();
        System.debug('opportunityId: '+opportunityId);
        if(opportunityId != NULL){
            List<String> oppIdSet = (List<String>)JSON.deserialize(opportunityId,List<String>.class);
            UpdateNewTradeNPay(oppIdSet); 
            jsonStr = getOppDataJSON(oppIdSet);
            system.debug('###JsonStr::'+jsonStr);
        }
        return jsonStr;
    }
     
      public static void UpdateNewTradeNPay(List<String> opSetId)  
       {
          
          List<Opportunity> opplst=[Select id,Program_ID__c,DRP_File_Number__c From Opportunity where id in: opSetId];
          set<Id> prgSetId=new set<Id>();
          for(Opportunity op:opplst){
            prgSetId.add(op.Program_ID__c);
          }
          
          List<nu_dse__TradeLine__c> tradeToInsertLst = new List<nu_dse__TradeLine__c>();
            
          List<nu_dse__TradeLine__c> lstTrade=[select id,Name,nu_dse__Program__c,FileNumber__c,isNewTrade__c,Opportunity__c from nu_dse__TradeLine__c where nu_dse__Program__c in : prgSetId AND Opportunity__c=null
                                              AND nu_dse__Include_In_The_Program__c=True]; 
        // map<id,nu_dse__TradeLine__c> opptradeMap=new map<id,nu_dse__TradeLine__c>([Select ]);        
         system.debug('###New TradeLines::'+lstTrade);
           if(!opplst.isEmpty()){
               for(Opportunity op:opplst)
               {
                   if(!lstTrade.isEmpty()){
                       
                       for(nu_dse__TradeLine__c trade:lstTrade){
                           trade.Opportunity__c = op.id;
                           trade.FileNumber__c = op.DRP_File_Number__c;  
                           trade.isNewTrade__c=True;
                           tradeToInsertLst.add(trade);
                       }
                   }
                   system.debug('tradeToInsertLst'+tradeToInsertLst);
                   
               }
           }
           
         if(!tradeToInsertLst.isEmpty())
            Update tradeToInsertLst;
         
      } 
      
      public static String getOppDataJSON(List<String> oppIdSet){
        system.debug('###started::');
          //Program_Id__r.DA_Cash_for_DNL_Post_TILA__c   @PDI-736
       
        List<opportunity> oppWithAccLst = [Select Id,Name,Program_Id__c,Last_Draft__c,Lead_Group__c,DRP_File_Number__c,Remaining_Months_in_Program__c,Loan_Term__c,Debt_Count__c,CloseDate,StageName,Account.Name,Account.nu_dse__Co_First_Name__c,Account.nu_dse__Co_Last_Name__c,Program_Id__r.Name,Program_Type__c,Enroll_Date__c,Additional_months_with_loan__c,Unsettled_Debt__c,Client_Age_Formula__c,Program_Length__c,Loan_Amount__c,Applicant_State__c,Unpaid_Program_Fees_with_DNL__c,Unpaid_Program_Fees_without_Loan__c,Cash_In_Dedicated_Account__c,Program_Id__r.nu_dse__Trust_Account_Balance__c,Program_Id__r.nu_dse__Program_Status__c,
            account.nu_dse__External_RAMS_ID__c,account.nu_dse__External_CFT_ID__c,account.nu_dse__External_GCS_ID__c,Program_Id__r.Portfolio__r.Name,Program_Id__r.Attorney__c,Account.BoxFolderId__c,Program_Id__r.Monthly_Legal_Fee__c,Program_Id__r.nu_dse__Monthly_Processor_Fee__c,Program_Id__r.nu_dse__Monthly_Third_Party_Fees__c,Program_Id__r.Subscribed_to_ALLG__c,Program_Id__r.nu_dse__Payment_Frequency__c,Program_Id__r.nu_dse__Reoccurring_Debit_Day__c,Program_Id__r.nu_dse__Twice_Monthly_Reoccuring_Day__c,Account.PersonBirthDate, Account.PersonMailingCountry, Account.PersonMailingState, Account.PersonEmail,Account.PersonMailingStreet,Account.ClientNumber__c,Account.MiddleName,Account.nu_dse__SSN__c,Account.PersonMailingCity,Account.PersonMailingPostalCode,Account.PersonHomePhone,Account.PersonMobilePhone,Account.nu_dse__Work_Phone__c,Account.FirstName,Account.LastName,Account.nu_dse__CO_Email_Address__c,Account.nu_dse__Co_Phone__c,Account.nu_dse__Co_SSN__c,Account.nu_dse__Co_Date_of_Birth__c,  //Program_Id__r.DA_Cash_for_DNL_Post_TILA__c,
            Program_Id__r.Current_Accumulation__c,Program_Id__r.Versara_First_Funding_Date__c,Program_Id__r.Beginning_DA_Balance__c,Program_Id__r.Addn_l_Drafts_During_Funding__c,Program_Id__r.Current_Admin_Fee__c,Program_Id__r.Paid_Creditor_Payments__c,Program_Id__r.Total_Fees__c,Program_Id__r.Expected_Accumulation__c,Program_Id__r.Expected_Admin_Fee__c,Program_Id__r.Total_Creditor_Payments__c,Program_Id__r.Remaining_Accumulation__c,Program_Id__r.Remaining_Admin_Fee__c,Program_Id__r.Remaining_Creditor_Payments__c,Program_Id__r.Current_Maintenance_Fee__c,Program_Id__r.nu_dse__Expected_Maintenance_Fees__c,Program_Id__r.Remaining_Maintenance_Fee__c,Program_Id__r.Current_Processor_Fee__c,Program_Id__r.Remaining_Processor_Fee__c,Program_Id__r.Expected_Processor_Fee__c,Program_Id__r.Current_Program_Fee__c,Program_Id__r.Expected_Program_Fee__c,Program_Id__r.Remaining_Program_Fee__c,Program_Id__r.Current_Retainer_Fee__c,Program_Id__r.Remaining_Retainer_Fee__c,Program_Id__r.Expected_Retainer_Fee__c,Program_Id__r.Current_Service_Fee__c,Program_Id__r.Remaining_Service_Fee__c,Program_Id__r.Expected_Service_Fee__c,Program_Id__r.Current_Third_Party_Fee__c,Program_Id__r.Remaining_Third_Party_Fee__c,Program_Id__r.Expected_Third_Party_Fee__c,
            (Select Id,name,nds_Current_Creditor_Name__c,nds_Original_Creditor_Name__c,Normalized_Current_Creditor__c,Normalized_Original_Creditor__c,nu_dse__Sales_Creditor_Name__c,nu_dse__Current_Stage__c,SFS_Current_Balance__c,nu_dse__Original_Creditor__r.Name,nu_dse__Original_Account_Number__c,nu_dse__New_Creditor__r.Name,nu_dse__New_Account_Number__c,FileNumber__c,nu_dse__Original_Debt__c,Import_ID__c,Litigation_Stage__c,isNewTrade__c,DNL_Estimated_Settlement__c From TradeLines__r),
            (Select Id,name,NSF_Date__c,Payment_Status__c,nu_dse__Transaction_Status__c,nu_dse__Transaction_Method__c,nu_dse__Payment_Type__c,nu_dse__Schedule_Date__c,nu_dse__Total_Amount__c,FileNumber__c,Recordtype.Name From Payments__r where Recordtype.Name = 'Draft' OR Recordtype.Name = 'Settlement' OR Recordtype.Name = 'Loan' OR Recordtype.Name = 'Refund Loan') 
            FROM Opportunity Where Id IN: oppIdSet];
        Set<Id> tradeLineIds = new Set<Id>();
        for(Opportunity opp: oppWithAccLst){
            for(nu_dse__TradeLine__c trade: opp.TradeLines__r){
                tradeLineIds.add(trade.Id);
            }    
        }
        List<nu_dse__Offer__c> offerLst = [select id,Name,nu_dse__TradeLine__c,Is_Last_Debt__c,DNL_First_Settlement__c,nu_dse__Program_Fee__c,nu_dse__Status__c,nu_dse__Offer_Amount__c,DNL_Funds_For_Fees__c,DNL_Funds_to_Clients__c,DNL_Disbursement_Date__c,DNL_Disbursement_Amount__c,DNL_Settlement_Fees__c, Settlement_Amount_Paid__c,Amount_Paid__c FROM nu_dse__Offer__c where nu_dse__TradeLine__c IN: tradeLineIds AND nu_dse__Status__c = 'Accepted'];
        Set<Id> offerIds = new Set<Id>();
        Map<Id,nu_dse__Offer__c> tradeLineOfferMap = new Map<Id,nu_dse__Offer__c>();
        for(nu_dse__Offer__c offer: offerLst){
            tradeLineOfferMap.put(offer.nu_dse__TradeLine__c,offer);
            offerIds.add(offer.Id);  
        }  
        
        List<nu_dse__Payment__c> paymentLst = [select id,name,FileNumber__c,nu_dse__Offer__c,Payment_Status__c,nu_dse__Total_Amount__c,nu_dse__Payment_Type__c,nu_dse__Schedule_Date__c,nu_dse__Transaction_Method__c from nu_dse__Payment__c where nu_dse__Offer__c IN: offerIds];    
        
        Map<Id,List<nu_dse__Payment__c>> tradeSettPayMap = new Map<Id,List<nu_dse__Payment__c>>();
        for(nu_dse__Payment__c pay: paymentLst){
            if(tradeSettPayMap.containskey(pay.nu_dse__Offer__c) || test.isRunningTest()){
                List<nu_dse__Payment__c> locLst = tradeSettPayMap.get(pay.nu_dse__Offer__c);
                locLst.add(pay);
                tradeSettPayMap.put(pay.nu_dse__Offer__c,locLst);
            }else{
                tradeSettPayMap.put(pay.nu_dse__Offer__c, new List<nu_dse__Payment__c>{pay}); 
            }
        }   
        opportunityJsonClass oppJson = new opportunityJsonClass();
        
        opportunityJsonClass.cls_Opportunity oppCls;
        opportunityJsonClass.cls_Payments paymentsCls;
        opportunityJsonClass.cls_TradeLines tradeLineCls;
        opportunityJsonClass.cls_SettelmentPayments settelmentPaymentCls;
        
        List<opportunityJsonClass.cls_Opportunity> oppClsLst = new List<opportunityJsonClass.cls_Opportunity>();
        List<opportunityJsonClass.cls_Payments> paymentsClsLst;
        List<opportunityJsonClass.cls_TradeLines> tradeLineLst;
        List<opportunityJsonClass.cls_SettelmentPayments> settelmentPaymentClsLst;
        
        for(Opportunity opp: oppWithAccLst){
            paymentsClsLst = new List<opportunityJsonClass.cls_Payments>();
            tradeLineLst = new List<opportunityJsonClass.cls_TradeLines>();
            oppCls = new opportunityJsonClass.cls_Opportunity();
            oppCls.Id = opp.Id;
            oppCls.Name = opp.Name;
            oppCls.FileNumber = opp.DRP_File_Number__c;
            oppCls.CloseDate = String.ValueOf(opp.CloseDate);   
            oppCls.Stage = opp.StageName;
            oppCls.AccountName = opp.Account.Name;
            oppCls.CoFirstName = opp.Account.nu_dse__Co_First_Name__c;
            oppCls.CoLastName = opp.Account.nu_dse__Co_Last_Name__c;
            oppCls.CoSSN = opp.Account.nu_dse__Co_SSN__c;
            if(opp.Account.nu_dse__Co_Date_Of_Birth__c != null)
            oppCls.CoDateOfBirth = String.valueOf(opp.Account.nu_dse__Co_Date_Of_Birth__c);
            oppCls.CoEmailAddress = opp.Account.nu_dse__Co_Email_Address__c;
            oppCls.CoPhone = opp.Account.nu_dse__Co_Phone__c;
            oppCls.RemainingMonths= String.valueOf(opp.Remaining_Months_in_Program__c);
            oppCls.LoanTerm = String.valueOf(opp.Loan_Term__c);
            oppCls.DebtCount = String.valueOf(opp.Debt_Count__c);
            oppCls.BoxFolderId = opp.Account.BoxFolderId__c;
            
            oppCls.ProgramName = opp.Program_Id__r.Name;
            oppCls.ProgramId = opp.Program_Id__c;
            oppCls.ProgramType= opp.Program_Type__c;
            oppCls.ProgramStatus = opp.Program_Id__r.nu_dse__Program_Status__c;
            //PDI-785
            /*if((string.valueOf(opp.Program_Id__r.DA_Cash_for_DNL_Post_TILA__c))!='' || (string.valueOf(opp.Program_Id__r.DA_Cash_for_DNL_Post_TILA__c))!=null)
              oppCls.DACashforDNLPostTILA=string.valueOf(opp.Program_Id__r.DA_Cash_for_DNL_Post_TILA__c); 
            else 
              oppCls.DACashforDNLPostTILA='';  */
                
            oppCls.EnrollmentDate= String.valueOf(opp.Enroll_Date__c);
            oppCls.AddnlMonthsWithLoan= String.valueOf(opp.Additional_months_with_loan__c);
            oppCls.UnsettledDebt= String.valueOf(opp.Unsettled_Debt__c);
            oppCls.ClientAge= String.valueOf(opp.Client_Age_Formula__c);
            oppCls.ProgramLength= String.valueOf(opp.Program_Length__c);
            oppCls.LoanAmount= String.valueOf(opp.Loan_Amount__c);
            oppCls.ApplicantState= opp.Applicant_State__c;
            oppCls.UnpaidProgramFeeWithDNL = String.valueOf(opp.Unpaid_Program_Fees_with_DNL__c);
            oppCls.UnpaidProgramFeeWODNL = String.valueOf(opp.Unpaid_Program_Fees_without_loan__c);
            //oppCls.CashInDedicatedAccount = String.valueOf(opp.Cash_In_Dedicated_Account__c);  @For PDI-730
            oppCls.CashInDedicatedAccount = String.valueOf(opp.Program_Id__r.nu_dse__Trust_Account_Balance__c);  //PDI-730
            oppCls.CurrentBalance = String.valueOf(opp.Program_Id__r.nu_dse__Trust_Account_Balance__c);
            oppCls.TwiceMonthlyReoccuringDay = String.valueOf(opp.Program_Id__r.nu_dse__Twice_Monthly_Reoccuring_Day__c);
            oppCls.ReoccurringDebitDay = String.valueOf(opp.Program_Id__r.nu_dse__Reoccurring_Debit_Day__c);
            oppCls.LastDraft = String.valueOf(opp.Last_Draft__c);
            oppCls.LeadGroup = opp.Lead_Group__c;
            
            //oppCls.PaidAccumulation = String.valueOf(opp.Program_Id__r.Current_Accumulation__c);  //DV-129
            //oppCls.PaidAdminFee = String.valueOf(opp.Program_Id__r.Current_Admin_Fee__c );    //DV-129
            //oppCls.PaidCreditorPayments = String.valueOf(opp.Program_Id__r.Paid_Creditor_Payments__c);  //DV-129
            //oppCls.PaidMaintenanceFee = String.valueOf(opp.Program_Id__r.Current_Maintenance_Fee__c);  //DV-129
            //oppCls.PaidProcessorFee = String.valueOf(opp.Program_Id__r.Current_Processor_Fee__c);  //DV-129
            //oppCls.PaidProgramFee = String.valueOf(opp.Program_Id__r.Current_Program_Fee__c);  //DV-129
            //oppCls.PaidRetainerFee = String.valueOf(opp.Program_Id__r.Current_Retainer_Fee__c);  //DV-129
            //oppCls.PaidServiceFee= String.valueOf(opp.Program_Id__r.Current_Service_Fee__c);  //DV-129
            //oppCls.PaidThirdPartyFee = String.valueOf(opp.Program_Id__r.Current_Third_Party_Fee__c);  //DV-129
            //oppCls.TotalAccumulation = String.valueOf(opp.Program_Id__r.Expected_Accumulation__c);
            //oppCls.TotalAdminFee = String.valueOf(opp.Program_Id__r.Expected_Admin_Fee__c);
            //oppCls.TotalCreditorPayments = String.valueOf(opp.Program_Id__r.Total_Creditor_Payments__c);
            //oppCls.TotalMaintenanceFee = String.valueOf(opp.Program_Id__r.nu_dse__Expected_Maintenance_Fees__c);
            //oppCls.TotalProcessorFee= String.valueOf(opp.Program_Id__r.Expected_Processor_Fee__c);
            //oppCls.TotalProgramFee = String.valueOf(opp.Program_Id__r.Expected_Program_Fee__c);
            //oppCls.TotalRetainerFee = String.valueOf(opp.Program_Id__r.Expected_Retainer_Fee__c);
            //oppCls.TotalServiceFee = String.valueOf(opp.Program_Id__r.Expected_Service_Fee__c);
            //oppCls.TotalThirdPartyFee = String.valueOf(opp.Program_Id__r.Expected_Third_Party_Fee__c);
            oppCls.TotalFee = String.valueOf(opp.Program_Id__r.Total_Fees__c);   //PDI-348
            //PDI-1044
            oppCls.BegDaBalance=String.valueOf(opp.Program_Id__r.Beginning_DA_Balance__c);
            oppCls.AddnlDraftFundng=String.valueOf(opp.Program_Id__r.Addn_l_Drafts_During_Funding__c);
            oppCls.VersaraFundDate=String.valueOf(opp.Program_Id__r.Versara_First_Funding_Date__c); //@1044
            //oppCls.RemainingAccumulation = String.valueOf(opp.Program_Id__r.Remaining_Accumulation__c);  /DV-129
            //oppCls.RemainingAdminFee = String.valueOf(opp.Program_Id__r.Remaining_Admin_Fee__c);
            //oppCls.RemainingCreditorPayments = String.valueOf(opp.Program_Id__r.Remaining_Creditor_Payments__c);
            //oppCls.RemainingMaintenanceFee = String.valueOf(opp.Program_Id__r.Remaining_Maintenance_Fee__c);
            //oppCls.RemainingProcessorFee = String.valueOf(opp.Program_Id__r.Remaining_Processor_Fee__c);
            //oppCls.RemainingProgramFee = String.valueOf(opp.Program_Id__r.Remaining_Program_Fee__c);
            //oppCls.RemainingRetainerFee = String.valueOf(opp.Program_Id__r.Remaining_Retainer_Fee__c);
            //oppCls.RemainingServiceFee = String.valueOf(opp.Program_Id__r.Remaining_Service_Fee__c);
            //oppCls.RemainingThirdPartyFee = String.valueOf(opp.Program_Id__r.Remaining_Third_Party_Fee__c);
            
            oppCls.PersonBirthDate= String.valueOf(opp.Account.PersonBirthDate);
            oppCls.PersonMailingState = opp.Account.PersonMailingState;
            oppCls.PersonMailingCountry = opp.Account.PersonMailingCountry;
            oppCls.PersonEmail = opp.Account.PersonEmail;
            oppCls.PersonMailingStreet = opp.Account.PersonMailingStreet;
            oppCls.ClientNumber = opp.Account.ClientNumber__c;
            oppCls.MiddleName = opp.Account.MiddleName;
            oppCls.AccountSSN = opp.Account.nu_dse__SSN__c;
            oppCls.PersonMailingCity = opp.Account.PersonMailingCity;
            oppCls.PersonMailingPostalCode = opp.Account.PersonMailingPostalCode;
            oppCls.PersonHomePhone = opp.Account.PersonHomePhone;
            oppCls.PersonMobilePhone = opp.Account.PersonMobilePhone;
            oppCls.AccountWorkPhone = opp.Account.nu_dse__Work_Phone__c;
            oppCls.FirstName = opp.Account.FirstName;
            oppCls.LastName = opp.Account.LastName;
            
            if(oppCls.ProcessorName == 'RAMS'){
                oppCls.PaymentAccountNumber = opp.Account.nu_dse__External_RAMS_ID__c;
                oppCls.ProcessorName = 'RAM';
            } else if(oppCls.ProcessorName == 'GCS'){
                oppCls.PaymentAccountNumber = opp.Account.nu_dse__External_GCS_ID__c;
            } else if(oppCls.ProcessorName == 'CFT'){
                oppCls.PaymentAccountNumber = opp.Account.nu_dse__External_CFT_ID__c;
            }
            
            if(opp.Program_Id__r.Attorney__c){
                oppCls.PortfolioType = 'Attorney';
                
            }
            else{
                oppCls.PortfolioType = 'Timberline';
            }
            oppCls.LawFirmName = opp.Program_Id__r.Portfolio__r.Name;
            oppCls.MonthlyLegalFee = String.valueOf(opp.Program_Id__r.Monthly_Legal_Fee__c);
            oppCls.MonthlyProcessorFee = String.valueOf(opp.Program_Id__r.nu_dse__Monthly_Processor_Fee__c);
            oppCls.MonthlyThirdPartyFees = String.valueOf(opp.Program_Id__r.nu_dse__Monthly_Third_Party_Fees__c);
            oppCls.SubscribedToALLG = String.valueOf(opp.Program_Id__r.Subscribed_to_ALLG__c);
           // Commented for DV-129
            /*if(opp.Program_Id__r.nu_dse__Payment_Frequency__c == 'Twice Monthly')
                oppCls.PaymentFrequency = 'Twice-a-Month';
            else
                oppCls.PaymentFrequency = opp.Program_Id__r.nu_dse__Payment_Frequency__c; */
            oppCls.RecurringDebitDay = String.valueOf(opp.Program_Id__r.nu_dse__Reoccurring_Debit_Day__c);
            oppCls.TwiceMonthlyRecurringDay = String.valueOf(opp.Program_Id__r.nu_dse__Twice_Monthly_Reoccuring_Day__c);

            
            for(nu_dse__Payment__c pay: opp.Payments__r){
                paymentsCls = new opportunityJsonClass.cls_Payments();
                paymentsCls.Id = pay.Id;
                paymentsCls.Name = pay.Name;
                paymentsCls.FileNumber = pay.FileNumber__c;
                paymentsCls.NFSDate = String.ValueOf(pay.NSF_Date__c);
                paymentsCls.PaymentStatus = pay.Payment_Status__c;
                paymentsCls.PaymentType = pay.nu_dse__Payment_Type__c;
                paymentsCls.ScheduleDate = String.ValueOf(pay.nu_dse__Schedule_Date__c);
                paymentsCls.TotalAmount = String.ValueOf(pay.nu_dse__Total_Amount__c);
                paymentsCls.TansMethod = pay.nu_dse__Transaction_Method__c;
                paymentsCls.TransactionStatus = pay.nu_dse__Transaction_Status__c;
                System.debug('##paymentsCls.TransactionStatus:'+paymentsCls.TransactionStatus +'trade.isNewTrade__c:'+paymentsCls.TransactionStatus);
                
                if(pay.RecordType.Name=='Settlement')  //@ 743
                   paymentsCls.PayRecType='Settlement';
                else if(pay.RecordType.Name=='Draft')
                   paymentsCls.PayRecType='Draft'; 
                else if(pay.RecordType.Name=='Loan')
                   paymentsCls.PayRecType='Loan';
                else if(pay.RecordType.Name=='Refund Loan')
                   paymentsCls.PayRecType='Refund Loan'; //@743
                
                paymentsClsLst.add(paymentsCls);   
            }
            oppCls.Payments = paymentsClsLst;
           List<nu_dse__TradeLine__c> lsttrade=new list<nu_dse__TradeLine__c>();  
            for(nu_dse__TradeLine__c trade: opp.TradeLines__r){
                tradeLineCls = new opportunityJsonClass.cls_TradeLines();
                tradeLineCls.Id = trade.Id;
                tradeLineCls.Name = trade.Name;
                tradeLineCls.FileNumber = trade.FileNumber__c;  
                tradeLineCls.CurrentStage = trade.nu_dse__Current_Stage__c;
                tradelineCls.LitigationStage = trade.Litigation_Stage__c;
                tradelineCls.DNLEstimatedSettlement = String.valueOf(trade.DNL_Estimated_Settlement__c);
                
               //Commented for DV-129
               /* if(trade.Normalized_Current_Creditor__c!=null || trade.Normalized_Current_Creditor__c!='')
                    tradeLineCls.NewCreditor = trade.Normalized_Current_Creditor__c;
                if(trade.Normalized_Current_Creditor__c==null)
                    tradeLineCls.NewCreditor=trade.nds_Current_Creditor_Name__c; */
                
                //DV-530 (Added because acceptance criteria is to get this value from normalized current creditor)
                if(trade.Normalized_Current_Creditor__c!=null || trade.Normalized_Current_Creditor__c!=''){
                    tradeLineCls.NewCreditor = trade.Normalized_Current_Creditor__c;
                }
                tradeLineCls.OriginalAccountNumber = trade.nu_dse__Original_Account_Number__c;
                System.debug('##tradeLineCls.SFSCurrentBalance-I:'+tradeLineCls.SFSCurrentBalance +'trade.isNewTrade__c:'+trade.isNewTrade__c);
                if(trade.isNewTrade__c==True)    //PDI-948 & DV-129
                {
                  tradeLineCls.isNewTrade='true';  //DV-60
                  tradeLineCls.SFSCurrentBalance = String.ValueOf(trade.SFS_Current_Balance__c);   
                  tradeLineCls.NewAccountNumber = trade.nu_dse__New_Account_Number__c;  
                  //tradeLineCls.NewCreditor = trade.nds_Current_Creditor_Name__c;  DV-530 (Commented because acceptance criteria is to get this value from normalized current creditor)
                }
                else 
                    tradeLineCls.isNewTrade='false';  //DV-60
                System.debug('###@@tradeLineCls.isNewTrade:'+tradeLineCls.isNewTrade);
                System.debug('##tradeLineCls.SFSCurrentBalance-II:'+tradeLineCls.SFSCurrentBalance+'trade.isNewTrade__c:'+trade.isNewTrade__c);    
                tradeLineCls.TradeImportID = trade.Import_ID__c; 
                tradeLineCls.OriginalDebt = String.ValueOf(trade.nu_dse__Original_Debt__c);
                //tradeLineCls.OriginalCreditorName = trade.nu_dse__Original_Creditor__r.Name;  //Change for PDI-788 @
                //PDI-788: Line:233 to 236
                System.debug('##trade.Normalized_Original_Creditor__c'+trade.Normalized_Original_Creditor__c);
                if(trade.Normalized_Original_Creditor__c!=null || trade.Normalized_Original_Creditor__c!='')
                   tradeLineCls.OriginalCreditorName = trade.Normalized_Original_Creditor__c;
                if(trade.Normalized_Original_Creditor__c==null)
                   tradeLineCls.OriginalCreditorName=trade.nu_dse__Sales_Creditor_Name__c;
                system.debug('###tradeLineCls.OriginalCreditorName:'+tradeLineCls.OriginalCreditorName);
                system.debug('###trade.nu_dse__Sales_Creditor_Name__c:'+trade.nu_dse__Sales_Creditor_Name__c);
                if(tradeLineOfferMap.containskey(trade.id)){
                    nu_dse__Offer__c offer = tradeLineOfferMap.get(trade.Id);
                    //tradeLineCls.OfferAmount = String.ValueOf(offer.nu_dse__Offer_Amount__c);   //DV-129
                    tradeLineCls.OfferStatus = offer.nu_dse__Status__c;
                    if(trade.isNewTrade__c==True){
                        
                        tradeLineCls.OfferAmount = String.ValueOf(offer.nu_dse__Offer_Amount__c);   //DV-129 
                        tradeLineCls.OfferProgramFee = String.valueOf(offer.nu_dse__Program_Fee__c);  //DV-129
                        //trade.isNewTrade__c=False;
                        //lsttrade.add(trade);
                    }
                   system.debug('###@trade.isNewTrade__c:'+trade.isNewTrade__c +'  lsttrade:-'+lsttrade);
                   // tradeLineCls.OfferProgramFee = String.valueOf(offer.nu_dse__Program_Fee__c);  //DV-129
                    tradelineCls.DNLFundsForFees = String.valueOf(Offer.DNL_Funds_For_Fees__c);
                    tradelineCls.DNLFundstoClient = String.valueOf(Offer.DNL_Funds_to_Clients__c);
                    tradelineCls.DNLDisbursementDate = String.valueOf(offer.DNL_Disbursement_Date__c);
                    tradelineCls.DNLDisbursementAmount = String.valueOf(offer.DNL_Disbursement_Amount__c);
                    tradelineCls.DNLSettlementFees = String.valueOf(offer.DNL_Settlement_Fees__c);
                    System.debug('##@tradelineCls.DNLDisbursementDate: '+tradelineCls.DNLDisbursementDate); 
                    System.debug('##@tradelineCls.DNLDisbursementAmount: '+tradelineCls.DNLDisbursementAmount);
                    System.debug('##@tradelineCls.DNLSettlementFees: '+tradelineCls.DNLSettlementFees);
                    
                    tradelineCls.SettlementAmountPaid = String.valueOf(offer.Settlement_Amount_Paid__c);
                    tradelineCls.AmountPaid = String.valueOf(offer.Amount_Paid__c);
                    tradelineCls.isLastDebt = (offer.Is_Last_Debt__c) ? 'true' : 'false';  //PDI-1019
                    tradelineCls.DNLfirstSettelment = (offer.DNL_First_Settlement__c) ? 'true' : 'false';  //PDI-1043
                   if(tradeSettPayMap.containskey(offer.Id)){
                        List<nu_dse__Payment__c> payLst = tradeSettPayMap.get(offer.Id);
                        settelmentPaymentClsLst = new List<opportunityJsonClass.cls_SettelmentPayments>();
                        for(nu_dse__Payment__c pay: payLst){ 
                            settelmentPaymentCls = new opportunityJsonClass.cls_SettelmentPayments();    
                            settelmentPaymentCls.Id = pay.Id;
                            settelmentPaymentCls.FileNumber = pay.FileNumber__c;
                            settelmentPaymentCls.PaymentStatus = pay.Payment_Status__c;
                            settelmentPaymentCls.TransactionMethod = pay.nu_dse__Transaction_Method__c;
                            settelmentPaymentCls.PaymentType = pay.nu_dse__Payment_Type__c;
                            settelmentPaymentCls.TotalAmount = String.valueOf(pay.nu_dse__Total_Amount__c);
                            settelmentPaymentCls.ScheduleDate = String.valueOf(pay.nu_dse__Schedule_Date__c);
                            settelmentPaymentClsLst.add(settelmentPaymentCls);
                            
                        }  
                        tradeLineCls.SettelmentPayments =  settelmentPaymentClsLst;
                    }
                }
                tradeLineLst.add(tradeLineCls);
                //DV-60
                if(trade.isNewTrade__c==true){
                    trade.isNewTrade__c=false;
                    lsttrade.add(trade);
                }
            }
            oppCls.TradeLines = tradeLineLst;
            oppClsLst.add(oppCls);
            if(lsttrade.size()>0)
                update lsttrade;  //
            oppJson.Opportunity = oppClsLst;
        }
        String jsonStr = System.JSON.serialize(oppJson, true);
        system.debug('###jsonStr::'+jsonStr);
        return jsonStr;
    }
}