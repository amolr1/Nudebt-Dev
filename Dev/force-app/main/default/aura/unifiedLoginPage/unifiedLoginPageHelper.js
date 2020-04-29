({
    
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },
    qsToEventMap2: {
        'expid'  : 'e.c:setExpId'
    },
    handleLogin: function (component, event, helpler, isReset) {
        
        let domain = window.location.origin;
        console.log('domain--->'+domain);
        var username = component.find("username_loginForm").get("v.value");
        var password = component.find("password_loginForm").get("v.value");
        var startUrl = component.get("v.startUrl");
        startUrl = decodeURIComponent(startUrl);
        
        console.log('***** startUrl-->', startUrl);
        helper.callServerMethod(
            component,
            helper,
            "login",
            {
                username:username, 
                password:password, 
                startUrl:startUrl, 
                domain:domain
            },
            function(response) {
                if (response) {
                    component.set("v.errorMessage",response);
                    component.set("v.showError",true);
                    if(isReset) {
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": "/?exp=1"
                        });
                        urlEvent.fire();
                    }
                }
            },null 
        );
    }
})