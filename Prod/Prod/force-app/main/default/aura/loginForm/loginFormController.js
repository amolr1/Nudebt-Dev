({
    initialize: function(component, event, helper) {
        let portfolioName;
        let searchHerfString = window.location.href;	
        let UserName = window.localStorage.getItem(searchHerfString) || "[]";	
        UserName = JSON.parse(UserName);	
        component.set("v.userNameList", UserName);   
        let uiwrapperMap = component.get("v.uiwrapperMap") || {};
        if(uiwrapperMap && uiwrapperMap.isSandbox) {
            let searchString = window.location.search;
            if(searchString.indexOf('portfolio=') !== -1 && searchString.split('portfolio=').length > 1) {
                
                portfolioName = searchString.split('portfolio=')[1];
                portfolioName = portfolioName.replace(new RegExp("\\+","g"),' ');
            }
        }
        /* END of Added for testing in UAT */
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();    
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap2}).fire();
        component.set('v.isUsernamePasswordEnabled', helper.getIsUsernamePasswordEnabled(component, event, helper));
        component.set("v.isSelfRegistrationEnabled", helper.getIsSelfRegistrationEnabled(component, event, helper));
        component.set("v.communityForgotPasswordUrl", helper.getCommunityForgotPasswordUrl(component, event, helper, portfolioName, uiwrapperMap.isSandbox));
        component.set("v.communitySelfRegisterUrl", helper.getCommunitySelfRegisterUrl(component, event, helper, portfolioName, uiwrapperMap.isSandbox));
        
        if (sessionStorage.getItem('redirectFrom') == 'SelfRegister') {
            
            console.log('~~~~~~****~~~~~~~');
            sessionStorage.setItem('redirectFrom', '');
            var urlEvent = $A.get("e.force:navigateToURL");
            let url = "/SelfRegister?src=4";
            if (uiwrapperMap && uiwrapperMap.isSandbox) {
                url += "&portfolio=" + portfolioName;
            }
            urlEvent.setParams({
                "url": url
            });
            urlEvent.fire();
        }
        /* Adding for portfolio TEST in UAT */
        let forgotPasswordUrl = component.get("v.forgotPasswordUrl");
        let selfRegisterUrl = component.get("v.selfRegisterUrl");
        if(uiwrapperMap && uiwrapperMap.isSandbox ) {
            forgotPasswordUrl = forgotPasswordUrl + '?portfolio=' + portfolioName;
            selfRegisterUrl = selfRegisterUrl + '&portfolio=' + portfolioName;
        }
        component.set("v.forgotPasswordUrl", forgotPasswordUrl);
        component.set("v.selfRegisterUrl", selfRegisterUrl);
        /* END Adding for portfolio TEST in UAT */
        let urlParams = decodeURIComponent(window.location.search);
        if(urlParams && urlParams.indexOf('un') !== -1 && urlParams.indexOf('pw') !== -1) {
            let usernamelist = urlParams.split('&pw=');
            component.find("username_loginForm").set("v.value", usernamelist[0].split("?un=")[1]);
        	component.find("password_loginForm").set("v.value", usernamelist[1]);
            console.log('Before helper');
            console.log(component.find('username_loginForm').get("v.value"));
            console.log(component.find('password_loginForm').get("v.value"));
            var oneSignalInfo = window.globalInformation_onesignal || '';
            helper.handleLogin(component, event, helper, true, oneSignalInfo);
        }
        if(urlParams && urlParams.indexOf('exp') !== -1) {
            component.set("v.isLinkExpired", true);
        }
    },
    
    handleLogin: function (component, event, helpler) {
        var oneSignalInfo = window.globalInformation_onesignal || '';
        helpler.handleLogin(component, event, helpler, false, oneSignalInfo);
    },
    afterRender: function(component, helper) {
        this.superAfterRender();
        var c = component.find("username_loginForm").get("v.value");
        c.getElement().addEventListener('paste', function() {
            console.log('pasted');
        });
    },
    setStartUrl: function (component, event, helpler) {
        var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },
    
    setExpId: function (component, event, helper) {
        var expId = event.getParam('expid');
        if (expId) {
            component.set("v.expid", expId);
        }
        helper.setBrandingCookie(component, event, helper);
    },
    
    onKeyUp: function(component, event, helpler){
        alert(event.type + ' - ' + event.clipboardData.getData('text/plain'));
        //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            var oneSignalInfo = window.globalInformation_onesignal || '';
            helpler.handleLogin(component, event, helpler, false, oneSignalInfo);
        }
    },
    
    navigateToForgotPassword: function(cmp, event, helper) {
        var forgotPwdUrl = cmp.get("v.communityForgotPasswordUrl");
        if ($A.util.isUndefinedOrNull(forgotPwdUrl)) {
            forgotPwdUrl = cmp.get("v.forgotPasswordUrl");
        }
        var attributes = { url: forgotPwdUrl };
        console.log('**** attributes', attributes);
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    },
    
    navigateToSelfRegister: function(cmp, event, helper) {
        var selrRegUrl = cmp.get("v.communitySelfRegisterUrl");
        if (selrRegUrl == null) {
            selrRegUrl = cmp.get("v.selfRegisterUrl");
        }
    
        var attributes = { url: selrRegUrl };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    } ,
    redirectToLoginPage : function(component, event, helper) {
        component.set("v.isLinkExpired", false);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"
        });
        urlEvent.fire();
    },
    onblur : function(component,event,helper){   	
        component.set("v.listOfSearchRecords", null );	
        var forclose = component.find("searchRes");	
        $A.util.addClass(forclose, 'slds-is-close');	
        $A.util.removeClass(forclose, 'slds-is-open');	
    },	
    clear :function(component,event,heplper){	
        var pillTarget = component.find("lookup-pill");	
        var lookUpTarget = component.find("lookupField"); 	
        $A.util.addClass(pillTarget, 'slds-hide');	
        $A.util.removeClass(pillTarget, 'slds-show');	
        $A.util.addClass(lookUpTarget, 'slds-show');	
        $A.util.removeClass(lookUpTarget, 'slds-hide');	
        component.set("v.SearchKeyWord",null);	
        component.set("v.listOfSearchRecords", null );	
        var compEvent = component.getEvent("removedRecordEvent");	
        compEvent.setParams({	
            "recordByEvent" : component.get("v.selectedRecord") 	
        });  	
        compEvent.fire();	
        component.set("v.selectedRecord", {} );   	
        component.set("v.selectedRecordId", '');	
    },	
    keyPressController : function(component, event, helper) {	
        var getInputkeyWord = component.get("v.SearchKeyWord");	
        console.log('getInputkeyWord--->',getInputkeyWord); 	
        if( getInputkeyWord.length > 0 ){	
            var forOpen = component.find("searchRes");	
            $A.util.addClass(forOpen, 'slds-is-open');	
            $A.util.removeClass(forOpen, 'slds-is-close');	
            helper.searchHelper(component,event,getInputkeyWord);	
        } else{  	
            component.set("v.listOfSearchRecords", [] ); 	
            var forclose = component.find("searchRes");	
            $A.util.addClass(forclose, 'slds-is-close');	
            $A.util.removeClass(forclose, 'slds-is-open');	
        }	
    },	
    onfocus : function(component,event,helper){	
        $A.util.addClass(component.find("mySpinner"), "slds-show");	
        var forOpen = component.find("searchRes");	
        $A.util.addClass(forOpen, 'slds-is-open');	
        $A.util.removeClass(forOpen, 'slds-is-close');	
        var getInputkeyWord = ''; 	
        helper.searchHelper(component,event,getInputkeyWord);	
    },	
    selectRecord : function(component,event,helper) {	
        var value = event.currentTarget.dataset.value;	
        component.set("v.SearchKeyWord", value); 	
        component.set("v.listOfSearchRecords", [] ); 	
    },	
    handleMenuClick : function(component,event,helper) {	
        component.set("v.listOfSearchRecords", [] ); 	
    },
    pasteFun : function(component, helper){
        console.log('paste call');
    }
})