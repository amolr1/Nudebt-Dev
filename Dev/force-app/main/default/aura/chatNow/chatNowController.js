({
	doInit : function(bus) {
	// Message bus created and ready to be used
            window.bus = bus;
            var program = '{!programInstance}';
            var ProgramId = '{!programInstance.Id}';
            var AccountId = '{!programInstance.nu_dse__Account__c}';
            var ProgramName = '{!programInstance.Name}';
            //Set the customer info
            bus.publish("customer:set-info", {
               "First Name": '{!userInstance.FirstName}',
                "Last Name": '{!userInstance.LastName}',
                "Program_Number":ProgramName,
                "Program_Id":ProgramId ,
                "Account_Id":AccountId 
            });
        
       
	}
    
})