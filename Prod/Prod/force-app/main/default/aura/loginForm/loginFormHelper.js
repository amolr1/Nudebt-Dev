({
    
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },
    
    qsToEventMap2: {
        'expid'  : 'e.c:setExpId'
    },
    
    handleLogin: function (component, event, helpler, isReset, oneSignalInfo) {
        
        let domain; 
        let pathName = window.location.href.split('/s/');
        let portfolioName = '';
        let uiwrapperMap = component.get("v.uiwrapperMap") || {};
        var startUrl = component.get("v.startUrl");
        var username = component.find("username_loginForm").get("v.value");
        var password = component.find("password_loginForm").get("v.value");
                                
        if(pathName.length > 1) {
            domain = pathName[0];
        }
        if(uiwrapperMap && uiwrapperMap.isSandbox) {
            let searchString = window.location.search;
            if(searchString.indexOf('portfolio=') !== -1 && searchString.split('portfolio=').length > 1) {
                portfolioName = searchString.split('portfolio=')[1];
            }
        }
        
        startUrl = decodeURIComponent(startUrl);
        let searchHerfString = window.location.href;	
        let usernamelist = component.get("v.userNameList");	
        let isRememberme = component.get("v.isRememberme");
        if (!usernamelist.includes(username) && isRememberme) {	
            usernamelist.push(username);	
        }	
        window.localStorage.setItem(searchHerfString,  JSON.stringify(usernamelist));
        var action = component.get("c.login");
        
        action.setParams({
            username:username, 
            password:password, 
            startUrl:startUrl, 
            domain:domain,
            portfolioName: portfolioName,
            oneSignalInfo: oneSignalInfo
        });
        action.setCallback(this, function(a) {
            
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                
                component.set("v.errorMessage",rtnValue);
                component.set("v.showError",true);
                if (isReset) {
                    
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams ({
                        "url": "/?exp=1"
                    });
                    urlEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsUsernamePasswordEnabled : function (component, event, helpler) {
        var action = component.get("c.getIsUsernamePasswordEnabled");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isUsernamePasswordEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsSelfRegistrationEnabled : function (component, event, helpler) {
        var action = component.get("c.getIsSelfRegistrationEnabled");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isSelfRegistrationEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunityForgotPasswordUrl : function (component, event, helpler, portfolioName, isSandbox) {
        var action = component.get("c.getForgotPasswordUrl");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communityForgotPasswordUrl',rtnValue + (isSandbox ? ('?portfolio=' + portfolioName) : '')); //
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunitySelfRegisterUrl : function (component, event, helpler, portfolioName, isSandbox) {
        var action = component.get("c.getSelfRegistrationUrl");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communitySelfRegisterUrl',rtnValue + (isSandbox ? ('?src=4&portfolio=' + portfolioName) : '')); //
            }
        });
        $A.enqueueAction(action);
    },
    
    setBrandingCookie: function (component, event, helpler) {
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({expId:expId});
            action.setCallback(this, function(a){ });
            $A.enqueueAction(action);
        }
    },
    getLoggedInuserIp : function(callback) {
        var ip_dups = {};        
        var RTCPeerConnection = window.RTCPeerConnection
        || window.mozRTCPeerConnection;
        
        if(!RTCPeerConnection){
            var win = iframe.contentWindow;
            RTCPeerConnection = win.RTCPeerConnection
            || win.mozRTCPeerConnection;
        }
        var mediaConstraints = {
            optional: [{RtpDataChannels: true}]
        };
        var servers = {iceServers: [{urls: "stun:stun.services.mozilla.com"}]};
        
        var pc = new RTCPeerConnection(servers, mediaConstraints);
        
        function handleCandidate(candidate){
            var ip_regex = /([0-9]{1,3}(\.[0-9]{1,3}){3}|[a-f0-9]{1,4}(:[a-f0-9]{1,4}){7})/
            var ip_addr = ip_regex.exec(candidate)[1];            
            if(ip_dups[ip_addr] === undefined)
                callback(ip_addr);
            ip_dups[ip_addr] = true;
        }        
        pc.onicecandidate = function(ice){            
            if(ice.candidate)
                handleCandidate(ice.candidate.candidate);
        };
        pc.createDataChannel("");        
        pc.createOffer(function(result){
            pc.setLocalDescription(result, function(){}, function(){});
        }, function(){});
        setTimeout(function(){
            var lines = pc.localDescription.sdp.split('\n');
            lines.forEach(function(line){
                if(line.indexOf('a=candidate:') === 0)
                    handleCandidate(line);
            });
        }, 1000);
    },	
    searchHelper : function(component, event, getInputkeyWord) {	
        var userNameList = component.get("v.userNameList");	
        var listOfSearch = component.get("v.listOfSearchRecords");	
        listOfSearch = [];	
        for (var i = 0; i < userNameList.length; i++) {	
            if (userNameList[i].includes(getInputkeyWord)) {	
                listOfSearch.push(userNameList[i]);	
            }	
        }	
        component.set("v.listOfSearchRecords", listOfSearch);	
    }
})