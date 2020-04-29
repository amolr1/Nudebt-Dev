public class AutomatedPaymentOutCtrl {
    public list<ProgramPaymentModal> ppmList {get; set;}
    public AutomatedPaymentOutCtrl(){
        ppmList = new list<ProgramPaymentModal>();
        SFDC_AIMMS_Config__mdt config = new SFDC_AIMMS_Config__mdt();
        list<SFDC_AIMMS_Config__mdt> configs = [Select Id, MasterLabel, Current_Stage__c, Portfolio_Name__c, 
                                                Record_Type__c, Schedule_Date__c, Status__c 
                                                From SFDC_AIMMS_Config__mdt 
                                                Where MasterLabel = 'Payments Out'];
        if(configs != null && configs.size()>0){
            config=configs[0];
            
            list<String> statuses = new list<String>();
            list<String> portfolioNames = new list<String>();
            list<String> currentStages = new list<String>();
            if(config.Status__c != null && config.Status__c.trim().length()>0){
                statuses = config.Status__c.split(',');
            }
            
            if(config.Portfolio_Name__c != null && config.Portfolio_Name__c.trim().length()>0){
                portfolioNames = config.Portfolio_Name__c.split(',');
            }
            
            if(config.Current_Stage__c != null && config.Current_Stage__c.trim().length()>0){
                currentStages = config.Current_Stage__c.split(',');
            }
            
            String soqlStr = 'Select Id, Name, (Select Id, Name From nu_dse__Offers__r Where Latest_Offer__c = true AND nu_dse__TradeLine__r.nu_dse__Current_Stage__c NOT IN: currentStages) From nu_dse__Program__c';
            String whereClauseStr='';
            whereClauseStr+= 'nu_dse__Program_Status__c IN: statuses';
            whereClauseStr+= ' AND Portfolio_Name__c IN: portfolioNames';
            soqlStr+=' Where '+whereClauseStr;
            system.debug('### soqlStr: '+soqlStr);
            list<nu_dse__Program__c> programList = Database.Query(soqlStr);
            if(programList != null && programList.size()>0){
                set<String> offerIds = new set<String>();
                for(nu_dse__Program__c prog: programList){
                    if(prog.nu_dse__Offers__r != null && prog.nu_dse__Offers__r.size()>0){
                        for(nu_dse__Offer__c ofr: prog.nu_dse__Offers__r){
                            offerIds.add(ofr.Id);
                        }
                    }
                }
                
                system.debug('### offerIds size: '+offerIds.size());
                // Get all the payments for the offer related to the queries programs
                if(offerIds != null && offerIds.size()>0){
                    //map<String, list<nu_dse__Payment__c>> offerPaymentsMap = new map<String, list<nu_dse__Payment__c>>();
                    map<String, map<Date, list<nu_dse__Payment__c>>> offerPaymentsMap = new map<String, map<Date, list<nu_dse__Payment__c>>>();
                    Id settlementRTId = SFSPortal_TestRecordCreator.getRecordTypeId('nu_dse__Payment__c','Settlement');
                    list<nu_dse__Payment__c> payments = [Select Id, Name, nu_dse__Offer__c, nu_dse__Schedule_Date__c,
                                                         nu_dse__Amount__c From nu_dse__Payment__c 
                                                         Where nu_dse__Offer__c IN: offerIds 
                                                         AND RecordTypeId=:settlementRTId
                                                         AND nu_dse__Schedule_Date__c >: System.Today()];
                    if(payments != null && payments.size()>0){
                        for(nu_dse__Payment__c p: payments){
                        	map<Date, list<nu_dse__Payment__c>> result=offerPaymentsMap.get(p.nu_dse__Offer__c);
                            if(result==null){
                            	result=new map<Date, list<nu_dse__Payment__c>>();
                            }
                            
                            if(result.containsKey(p.nu_dse__Schedule_Date__c)){
                                list<nu_dse__Payment__c> result1 = result.get(p.nu_dse__Schedule_Date__c);
                                result1.add(p);
                                result.put(p.nu_dse__Schedule_Date__c, result1);
                                offerPaymentsMap.put(p.nu_dse__Offer__c, result);
                            }else{
                                result.put(p.nu_dse__Schedule_Date__c, new list<nu_dse__Payment__c>{p});
                                offerPaymentsMap.put(p.nu_dse__Offer__c, result);
                            }
                        }
                        /*for(nu_dse__Payment__c p: payments){
                            list<nu_dse__Payment__c> result = offerPaymentsMap.get(p.nu_dse__Offer__c);
                            if(result==null){
                                result=new list<nu_dse__Payment__c>();
                            }
                            result.add(p);
                            offerPaymentsMap.put(p.nu_dse__Offer__c, result);
                        }*/
                    }
                    
                    // Process the payments with programs
                    for(nu_dse__Program__c prog: programList){
                        if(prog.nu_dse__Offers__r != null && prog.nu_dse__Offers__r.size()>0){
                            for(nu_dse__Offer__c ofr: prog.nu_dse__Offers__r){
                                if(offerPaymentsMap.containsKey(ofr.Id)){
                                    map<Date, list<nu_dse__Payment__c>> offerPayments = offerPaymentsMap.get(ofr.Id);
                                    if(offerPayments != null && offerPayments.size()>0){
                                        for(Date sd: offerPayments.keyset()){
                                        	Decimal amount = 0;
                                            list<nu_dse__Payment__c> pmts = offerPayments.get(sd);
                                            for(nu_dse__Payment__c p: pmts){
                                                amount+=p.nu_dse__Amount__c;
                                            }
                                            ppmList.add(new ProgramPaymentModal(prog.Id, prog.Name, sd, amount));
                                        }
                                        /*for(nu_dse__Payment__c p: offerPayments){
                                            ppmList.add(new ProgramPaymentModal(prog.Id, prog.Name, p.nu_dse__Schedule_Date__c, p.nu_dse__Amount__c));
                                        }*/
                                    }
                                }
                            }
                        }
                    }
                    
                    if(ppmList != null && ppmList.size()>0){
                        // Store data in Program_Payment_Out_In__c object
                        /*Id ppOutRTId = SFSPortal_TestRecordCreator.getRecordTypeId('Program_Payment_Out_In__c','Settlement');
                        list<Program_Payment_Out_In__c> ppSettlement = new list<Program_Payment_Out_In__c>();
                        for(ProgramPaymentModal ppm: ppmList){
                            ppSettlement.add(new Program_Payment_Out_In__c(RecordTypeId=ppOutRTId,
                                                                           PROGRAM_UUID__c=ppm.PROGRAM_UUID,
                                                                           PROGRAM_NUM__c=ppm.PROGRAM_NUM,
                                                                           SCHEDULED_DATE__c=ppm.SCHEDULED_DATE,
                                                                           AMOUNT__c=ppm.AMOUNT));
                        }
                        
                        if(ppSettlement != null && ppSettlement.size()>0){
                            upsert ppSettlement;
                        }*/
                    }
                }
            }
        }
    }
    
    public class ProgramPaymentModal{
        public String PROGRAM_UUID {get; set;}
        public String PROGRAM_NUM {get; set;}
        public Date SCHEDULED_DATE {get; set;}
        public Decimal AMOUNT {get; set;}
        public ProgramPaymentModal(String PROGRAM_UUID, String PROGRAM_NUM, Date SCHEDULED_DATE, Decimal AMOUNT){
			this.PROGRAM_UUID=PROGRAM_UUID;
            this.PROGRAM_NUM=PROGRAM_NUM;
            this.SCHEDULED_DATE=SCHEDULED_DATE;
            this.AMOUNT=AMOUNT;
        }
    }
}