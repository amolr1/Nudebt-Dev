({
    doBoxFolderToPortalFolderMapping : function(component, helper, allFetchedBoxFoldersName) {
        console.log('helperCalled>>>'+allFetchedBoxFoldersName);
   
        helper.callServerMethod(
            component,
            helper,
            "getPortalBoxNameFromBoxFolders",                                       
            {'allBoxFolderNames' : allFetchedBoxFoldersName},  
            function(result) {
                console.log('*****Portal Box Foldername helper', result);
                if(result) {
                    component.set("v.folderList_cp", result);
                    console.log('1111>>>'+component.get("v.folderList_cp"));
                    let foldersAndSubFoldersMap = {'0' : []};
                    for(let i = 0; i < result.length; i++) {
                        foldersAndSubFoldersMap['0'].push(result[i]);
                    }
                    component.set("v.foldersAndSubFoldersMap_cp", foldersAndSubFoldersMap);
                }
                
            }
        );
    },
    fetchAllSubFoldersID : function(cmp){
        var allSubFolderObjects = cmp.get("v.folderList");
        var arraySubFolderID = [];
        for(var SubFolderID in allSubFolderObjects){
            arraySubFolderID.push(allSubFolderObjects[SubFolderID].id);
        }
        return arraySubFolderID;
    }
})