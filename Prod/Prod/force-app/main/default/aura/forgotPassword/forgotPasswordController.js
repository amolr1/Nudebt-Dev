({
    handleForgotPassword: function (component, event, helper) {
       helper.handleCheckUserAccess(component, event, helper);
        //helpler.handleForgotPassword(component, event, helper);
    },
    onKeyUp: function(component, event, helpler){
        //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            //helpler.handleForgotPassword(component, event, helpler);
            helper.handleCheckUserAccess(component, event, helper);
        }
    },
    
    setExpId: function (component, event, helper) {
        var expId = event.getParam('expid');
        if (expId) {
            component.set("v.expid", expId);
        }
        helper.setBrandingCookie(component, event, helper);
    },
    
    initialize: function(component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();
    },
    
    redirectToLoginPage : function(component, event, helper) {
        
        let domainURL;
        let pathName = window.location.href.split('/s/');
        if(pathName.length > 1) {
            domainURL = pathName[0] + '/s/login/';
        }
        let uiwrapperMap = component.get("v.uiwrapperMap") || {};
        if(uiwrapperMap && uiwrapperMap.isSandbox) {
            console.log('**** portfolio url',pathName[1]);
            if(pathName[1].split('portfolio=').length > 1) {
                
                console.log('**** portfolio url', pathName[1].split('portfolio='));
                let portfolioName = pathName[1].split('portfolio=')[1];
               
                if (portfolioName) {
                    //portfolioName=portfolioName.replace(new RegExp("\\+","g"),' ');
                    
                    domainURL += '?portfolio='+portfolioName;
                    console.log('**** domainURL-->', portfolioName, '<--domainURL-->');
                }
            }
        }
        console.log('domainURL---->',domainURL);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": domainURL
        });
        urlEvent.fire();
    }
})