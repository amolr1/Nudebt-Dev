({
	doInit : function(component, event, helper) {
		helper.callServer(component,"c.getOriginalCreditors",function(response){
            component.set('v.OriginalCreditorList',response);
        });
	}
})