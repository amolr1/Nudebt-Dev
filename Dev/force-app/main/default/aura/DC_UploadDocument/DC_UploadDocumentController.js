({
	handleUpload: function(component, event, helper) {
		
	},
    
    handleUploadFinished: function(component, event, helper) {
        var uploadedFiles = event.getParam("files");
        console.log("uploadedFiles--->",uploadedFiles)
        var contentDocumentList = component.get("v.contentDocumentList");
        for (var i = 0 ; i < uploadedFiles.length ; i++) {
            contentDocumentList.push(uploadedFiles[i]);
        }
        console.log("contentDocumentList--->",contentDocumentList);
        component.set("v.contentDocumentList",contentDocumentList);
    }, 

})