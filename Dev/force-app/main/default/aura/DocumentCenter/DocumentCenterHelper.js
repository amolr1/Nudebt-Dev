({
	getCategoryLengthMap : function(component, event, helper, subfoldersSchemaMap) {
        console.log('subfoldersSchemaMap!!!!'+JSON.stringify(subfoldersSchemaMap)+'!!!!');
        const CategoryToEntriesMap = new Map();
        const FilesToPreviewURL = new Map();
        const categoryToFileCount = new Map();
        var categoryEntryCount ;
        //var categoryEntryCountArray = [] ;
        var allCategoryList = component.get("v.allCategoryList");
        var recentUploadeItems = [];
        var entriesWithInCategory = [];
        
        for(let availableCateg in allCategoryList){
            console.log('availableCateg!@!@!'+allCategoryList[availableCateg]+'!@!@!@'+subfoldersSchemaMap[allCategoryList[availableCateg]]);
            var testCategoryName = '';
            if(allCategoryList[availableCateg].includes('_')){
                testCategoryName = allCategoryList[availableCateg].replace('_', ' ');
            }else{
                testCategoryName = allCategoryList[availableCateg];
            }
            if(subfoldersSchemaMap[testCategoryName] && subfoldersSchemaMap[testCategoryName].length > 0){
                categoryEntryCount = 0;
                for(let categoryWiseSubfolders of subfoldersSchemaMap[testCategoryName]){ 
                    if(categoryWiseSubfolders.total_count && categoryWiseSubfolders.total_count > 0){
                        categoryEntryCount = categoryEntryCount + parseInt(categoryWiseSubfolders.total_count);
                        //add those element which recently uploaded
                        for(let eachFiles in categoryWiseSubfolders.entries){
                            console.log('eachfiles----'+JSON.stringify(categoryWiseSubfolders.entries[eachFiles]));
                            if(categoryWiseSubfolders.entries[eachFiles].modified_at){
                                console.log('!@!@!@!@'+ this.calculateDaysBetweenDates(categoryWiseSubfolders.entries[eachFiles].modified_at));
                                var fileAge = parseInt(this.calculateDaysBetweenDates(categoryWiseSubfolders.entries[eachFiles].modified_at));
                                console.log('21212122'+fileAge);
                                if(fileAge <= parseInt(3) &&  fileAge >= parseInt(0)){
                                    console.log('!!!!!TEst--'+fileAge);
                                    var temmpFile = categoryWiseSubfolders.entries[eachFiles];
                                    console.log('categoryWiseSubfolders.entries[eachFiles]----'+categoryWiseSubfolders.entries[eachFiles]);
                                    recentUploadeItems.push(temmpFile);
                                }
                            }
                            entriesWithInCategory.push(categoryWiseSubfolders.entries[eachFiles]);  
                            //fill map for preview link
                            if(!FilesToPreviewURL.has(categoryWiseSubfolders.entries[eachFiles].id)){
                                FilesToPreviewURL[categoryWiseSubfolders.entries[eachFiles].id] =  categoryWiseSubfolders.entries[eachFiles].expiring_embed_link.url;
                            }
                        }
                    }
                    
                }
                if(!CategoryToEntriesMap.has(allCategoryList[availableCateg].toString())){
                    //categoryEntryCountArray.push(categoryEntryCount);
                    categoryToFileCount[allCategoryList[availableCateg].toString()] =  categoryEntryCount
                    console.log('JSON.str121212'+JSON.stringify(entriesWithInCategory));
                    CategoryToEntriesMap[allCategoryList[availableCateg].toString()] =  entriesWithInCategory;
                    entriesWithInCategory = [];
                }
            }
        }
        console.log('recentUploadeItems!@!@!@'+JSON.stringify(recentUploadeItems));
        console.log('categoryToFileCount!@!@!@'+JSON.stringify(categoryToFileCount));
        console.log('CategoryToEntriesMap>>!!!!!'+JSON.stringify(CategoryToEntriesMap));
        if(recentUploadeItems.length > 0){
            component.set("v.recentUploadsEntityList",recentUploadeItems);
        }
        if(categoryToFileCount){
            component.set("v.categoryToFileCount", categoryToFileCount);
        }
        if(CategoryToEntriesMap){
            console.log('CategoryToEntriesMap>>>>'+JSON.stringify(CategoryToEntriesMap));
            component.set("v.selectedCategoryToEntriesMap", CategoryToEntriesMap);
        }
        if(FilesToPreviewURL){
            console.log('FilesToPreviewURL>>>>'+JSON.stringify(FilesToPreviewURL));
            component.set("v.FilesToPreviewURL", FilesToPreviewURL);
        }
        
    },
    calculateDaysBetweenDates : function(fileModifiedDate){
        var varfileModifiedDate = new Date(fileModifiedDate); 
        var varcurrentDate = new Date();    //current date value based on current browser itself
        var Difference_In_Time = varcurrentDate.getTime() - varfileModifiedDate.getTime(); // To calculate the time difference of two dates 
        var Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24); // To calculate the no. of days between two dates 
        console.log("Total number of days between dates  <br>"
                       + varfileModifiedDate + "<br> and <br>" 
                       + varcurrentDate + " is: <br> " 
                       + Difference_In_Days); 
        return Difference_In_Days;            
        
    },
    // function automatic called by aura:waiting event  
    showSpinner : function(component) {
        component.set("v.spinner", true);  // make Spinner attribute true for displaying loading spinner 
    },
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component){   
        component.set("v.spinner", false); // make Spinner attribute to false for hiding loading spinner 
    },
    //used this generic function to create a server side request 
    sendRequest : function(cmp, methodName, params){
        return new Promise($A.getCallback(function(resolve, reject) {
            cmp.set("v.spinner", true);  //displaying loading spinner
            var action = cmp.get(methodName);
            if(params){
            	action.setParams(params);
            }
            action.setCallback(self, function(res) {
                var state = res.getState();
                if(state === 'SUCCESS') {
                    console.log('InsideSuccess---');
                    resolve(res.getReturnValue());
                } else if(state === 'ERROR') {
                    console.log('InsideERROR---');
                    reject(action.getError())
                }
                cmp.set("v.spinner", false);  //hide loading spinner
            });
            $A.enqueueAction(action);
        }));
    }
})