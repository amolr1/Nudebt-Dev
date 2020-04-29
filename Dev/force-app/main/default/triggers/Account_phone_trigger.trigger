trigger Account_phone_trigger on Account (before update , before insert)
{
     for(Account acc : trigger.new )
    { 
        if(acc.Phone == NULL || test.isRunningTest())
        {  
            if(acc.nu_dse__Home_Phone__c!=null)
                acc.Phone= acc.nu_dse__Home_Phone__c;
            else if(acc.nu_dse__Work_Phone__c !=null)
                acc.Phone= acc.nu_dse__Work_Phone__c ;
            else if(acc.nu_dse__Other_Phone__c !=null)
                acc.Phone= acc.nu_dse__Other_Phone__c;
             else if(acc.nu_dse__Cell_phone__c !=null)
                acc.Phone= acc.nu_dse__Cell_phone__c ;
             else if(acc.nu_dse__Best_Phone__c !=null)
                acc.Phone= acc.nu_dse__Best_Phone__c ;
             else if(acc.PersonHomePhone !=null)
                acc.Phone= acc.PersonHomePhone ;
        }
    }
    }