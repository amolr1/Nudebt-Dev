public class Account_Phone_trigger_handeller {
	   public static void CreateAccounts(List<Account> acclist)
    {
        for(Account account : acclist)
        {
            if(account.ShippingState!=account.BillingState)
            {
                account.ShippingState = account.BillingState; 
            }
        }
    }
}