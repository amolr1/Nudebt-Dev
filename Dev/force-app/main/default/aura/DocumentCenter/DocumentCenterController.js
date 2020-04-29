({
    doInit : function(component, event, helper){
        var action = component.get("c.getSelectedFolderSchema");
        helper.showSpinner(component);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Success!",
                    message: "All filtered document loaded!",
                    mode: 'dismissible',
                    duration:' 5000',
                    type : 'success'
                });
                toastEvent.fire();  
                console.log("From server: !!!1" + response.getReturnValue());
                if(response.getReturnValue() && response.getReturnValue() != null){
                    component.set("v.filteredFolderMap",response.getReturnValue());
                    console.log("From server: 2" + JSON.stringify(component.get("v.filteredFolderMap")));
                    var subfoldersSchemaMap = new Map();
                    subfoldersSchemaMap = component.get("v.filteredFolderMap");
                    console.log('subfoldersSchemaMap@@@@'+subfoldersSchemaMap);
                    helper.getCategoryLengthMap(component, event, helper, subfoldersSchemaMap);
                }
                
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Something went wrong!",
                            message: errors[0].message,
                            mode: 'dismissible',
                            duration:' 5000',
                            type : 'error'
                        });
                        toastEvent.fire();                        
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            helper.hideSpinner(component);  //hider spinner
        });
        
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    },
	iConClicked : function(component, event, helper) {
        var selectedCategory = event.currentTarget.title;
		console.log('selectedCategory12'+selectedCategory);
        component.set("v.showLandingPage", false);
        component.set("v.selectedCategory",selectedCategory);
        var categoryToEntriesMap = new Map();
        categoryToEntriesMap = component.get("v.selectedCategoryToEntriesMap");
        console.log('1234---'+JSON.stringify(categoryToEntriesMap[selectedCategory]));
        var allSubFolderListing = [];
        if(categoryToEntriesMap[selectedCategory] && categoryToEntriesMap[selectedCategory].length > 0){
            for(let i in categoryToEntriesMap[selectedCategory]){ 
                allSubFolderListing.push(categoryToEntriesMap[selectedCategory][i]);
            }
            if(allSubFolderListing && allSubFolderListing.length > 0){
                component.set("v.CategoryWiseEntitiesList", allSubFolderListing);
                component.set("v.showLandingPage", false); 
            }
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "No file found in this selected category!",
                message: "No file found in this selected category!",
                mode: 'dismissible',
                duration:' 5000',
                type : 'error'
            });
            toastEvent.fire();   
            if(allSubFolderListing && allSubFolderListing.length == 0){
                component.set("v.CategoryWiseEntitiesList", allSubFolderListing);
                component.set("v.showLandingPage", false); 
            }
        }
        
    },
    handleDownloadEntity : function(component, event, helper) {
        var selectedFileId = event.currentTarget.id;
        console.log('selectedFileId----'+selectedFileId);
        var paramObj = { fileId : selectedFileId }; // your parameters
        helper.sendRequest(component, 'c.downloadSelectedFile',paramObj)
        .then($A.getCallback(function(records) {
            console.log('First1 From Server-Side: ' + records);
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": records
            });
            urlEvent.fire();
        }))
        .catch(function(errors) {
            console.error('ERROR: ' + errors);
        });
    },
    getPreviewFile : function(component, event, helper){ 
        var selectedFileId = event.currentTarget.id;
        console.log('selectedPreviewFile----'+selectedFileId);
        var mapFilesToPreviewUrl = component.get("v.FilesToPreviewURL");
        console.log('isLie----'+JSON.stringify(mapFilesToPreviewUrl[selectedFileId]));
        let selectedFilePreviewURL = mapFilesToPreviewUrl[selectedFileId];
        var pageReference = {
            type : "standard__webPage",
            target : "_blank",
            attributes : {
                "url": mapFilesToPreviewUrl[selectedFileId]
            }
    	};
        component.set("v.FilePreviewpageReference", pageReference);
        var navService = component.find("navService");
        navService.generateUrl(pageReference)
        .then($A.getCallback(function(url) {
            console.log('ExactURI---'+url);
        }), $A.getCallback(function(error) {
            console.log('Error while generating the file preview URL');
        }));
        // Uses the pageReference definition in the init handler
        var pageReference = component.get("v.FilePreviewpageReference");
        event.preventDefault();
        navService.navigate(pageReference);
    },
    
    backDocument : function(component, event, helper) {
        var selectedCategory = "";
        component.set("v.showLandingPage", true);
        component.set("v.selectedCategory",selectedCategory);
    },

    handleModal: function (component, event, helper) {
        component.set("v.openModal", true)
    },

    closeModal: function (component, event, helper) {
        component.set("v.openModal", false)
    },


})