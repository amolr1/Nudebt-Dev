({
	doInit : function(component, event, helper) {
		helper.callServerMethod(
            component,
            helper,
            "getDefaultFormIdList",                                       
            {},  
            function(result) {
                console.log('***** result', result);
                component.set("v.documentWrapper", result);
            },
            null
        );
	},
    downloadFile : function(component, event, helper) {
        let contentDocId = event.target.getAttribute("data-documentId"); 
        let atag = document.createElement('a');
		atag.href = '/sfc/servlet.shepherd/document/download/'+contentDocId;
        atag.target = '_self';
		atag.click();
    }
})