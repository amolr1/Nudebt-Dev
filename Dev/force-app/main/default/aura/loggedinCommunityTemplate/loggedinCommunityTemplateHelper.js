({
	leaveHandler: function(event) {
        event.returnValue = "Are you sure you want to leave? All changes will be lost!";
    },
    preventLeaving: function(component, helper) {
        window.addEventListener("beforeunload", this.leaveHandler);
    },
    setProfileMenu : function (component, event, helper){
        component.set("v.isSectionExpanded",false);
        component.set("v.isProfileMenu",true);
        let currentTabName = event.detail.menuItem.get("v.value");
        if (currentTabName == "myprofile") {
            currentTabName = 'detail/'+component.get("v.uiwrapperMap.userInstance.Id");
        }
        component.set("v.currentTabName", currentTabName);
        let domain; 
        let pathName = window.location.href.split('/s/');
        if (pathName.length > 1) {
            domain = pathName[0];
        }
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": domain + '/s/' + currentTabName
        });
        urlEvent.fire();
        let isSectionExpanded = component.get("v.isSectionExpanded");
        if (isSectionExpanded) {
            component.set("v.isSectionExpanded", false);
        }
        let isExpandedProfile = component.get("v.isExpandedProfile");
        if (isExpandedProfile) {
            component.set("v.isExpandedProfile", false);
        }
    },
    setCurrentmenu : function (component, event, helper){
        component.set("v.isHideProfileMenu", true); 
        let currentTabName = event.currentTarget.getAttribute("data-tabName");
        if (currentTabName == "myprofile") {
            currentTabName = 'detail/'+component.get("v.uiwrapperMap.userInstance.Id");
        }
        component.set("v.currentTabName", currentTabName);
        let domain; 
        let pathName = window.location.href.split('/s/');
        if (pathName.length > 1) {
            domain = pathName[0];
        }
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": domain + '/s/' + currentTabName
        });
        urlEvent.fire();
       
       /* let atag = document.createElement('a');
        atag.href = domain + '/s/' + currentTabName;
        atag.target = "_self";
        atag.click();*/
        
        let isSectionExpanded = component.get("v.isSectionExpanded");
        if (isSectionExpanded) {
            component.set("v.isSectionExpanded", false);
            component.set("v.isHideProfileMenu", true); 
        }
        let isExpandedProfile = component.get("v.isExpandedProfile");
        if (isExpandedProfile) {
            component.set("v.isExpandedProfile", false);
            //component.set("v.isHideProfileMenu", true); 
        }
    },
    handleApplicationEvent : function(component, event, helper){
        var tabName = event.getParam("tabName");
        component.set("v.currentTabName", tabName);
        //component.set("v.isHideProfileMenu", true); 
        let domain; 
        let pathName = window.location.href.split('/s/');
        if (pathName.length > 1) {
            domain = pathName[0];
        }
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"+ tabName
        });
        urlEvent.fire();
    }
})