(function(b){if(!Array.prototype.indexOf){Array.prototype.indexOf=function(d){var c=this.length>>>0,e=Number(arguments[1])||0;e=(e<0)?Math.ceil(e):Math.floor(e);if(e<0){e+=c}for(;e<c;e++){if(e in this&&this[e]===d){return e}}return -1}}var a={};a.SHARED_ALIAS="/shared";a.CHAT_PATH="/CHAT";a.COMMON_PATH="/common";a.ERROR_FLAG="8x8Chat";a.POPUP_WINDOW_NAME_PREFIX="8x8EmbeddedChatPopup";a.MAX_CO_BROWSING_INSTANCE_CHECK_TRIES=10;a.logLevel="debug";a.logList=["debug","info","warn","error"];a.logLevelIndex=a.logList.indexOf(a.logLevel);a.containerProperties={width:"334px",height:{closed:"0",minimized:"50px",invitationOpen:"260px",open:"330px"},left:"20px",right:"20px"};a.windowProperties=a.containerProperties;a.chatHeightChangeDelay=100;a.bus=(function(){var c={};return{subscribe:function(e,f){if(!c[e]){c[e]={listeners:[]}}var d=c[e].listeners.push(f)-1;return{remove:function(){delete c[e].listeners[d]}}},publish:function(f,k){if(!c[f]||!c[f].listeners.length){return}var h=c[f].listeners;for(var g=0,d=h.length;g<d;g++){if(typeof h[g]==="function"){try{h[g](k)}catch(j){a.log("error",j.message)}}}}}})();a.start=function(){this.config=window.__8x8Chat;if(this.checkValid()){this.checkPlatformAndConfigure()}else{a.log("error","Can't load - Invalid parameters")}};a.checkPlatformAndConfigure=function(){a.checkPlatform(function(){a.configure()})};a.configure=function(){this.configureMessage();this.container=this.createContainer();this.iframe=this.createIFrame();this.appendToBody(this.container,this.iframe)};a.onCommunicationEstablished=function(c){a.log("info","Communication established to",(c&&c.isPopup?"Popup":"IFrame"))};a.checkValid=function(){var c=window.__8x8Chat&&this.config&&this.config.uuid&&this.config.tenant&&this.config.domain&&this.config.channel&&this.config.align;if(c){if(this.config.busHandlerURL&&typeof this.config.busHandlerURL!="string"){c=false}else{if(this.config.busHandlerURL&&this.config.busHandlerURL.toLowerCase().indexOf("https:")!==0){c=false}else{if(this.config.stylesheetURL&&typeof this.config.stylesheetURL!="string"){c=false}else{if(this.config.stylesheetURL&&this.config.stylesheetURL.toLowerCase().indexOf("https:")!==0){c=false}}}}}return c};a.configBrokerListener=function(f){try{var d=b.parse(f.data)}catch(h){a.log("error","Failed to parse event data: "+h.message)}var c=d&&d.type;switch(c){case"_8x8ChatReady":var g=[];g.push("action=checkPlatform");g.push(["tenant",encodeURIComponent(this.config.tenant)].join("="));g.push(["channel",encodeURIComponent(this.config.channel)].join("="));g.push(["script",encodeURIComponent(this.config.uuid)].join("="));var i=this.getURL("chat")+"/chat.php?"+g.join("&");f.source.postMessage(b.stringify({url:i}),"*");break;case"_8x8ChatConfig":try{a.checkPlatformScriptLoaded(b.parse(d.config))}catch(h){a.log("error","Failed to parse chat config: "+h.message)}break;default:a.log("debug","Unsuported type: "+c)}}.bind(a);a.checkPlatform=function(c){a.checkPlatformCallback=c;a.__8x8ChatConfigBrokerFrame=a.createConfigBrokerIFrame();window.addEventListener("message",a.configBrokerListener,true)};a.removeConfigBroker=function(){if(a.__8x8ChatConfigBrokerFrame){window.removeEventListener("message",a.configBrokerListener,true);a.__8x8ChatConfigBrokerFrame.parentNode.removeChild(a.__8x8ChatConfigBrokerFrame);a.__8x8ChatConfigBrokerFrame=null}};a.checkPlatformScriptLoaded=function(d){if(d){var c=this.checkPlatformStatus(d.response);this.removeConfigBroker();if(c=="redirect"&&!this.platformRedirection){this.redirectPlatform(d.response.data.platformURLRedirect)}else{if(c=="redirect"){a.checkPlatformCallback&&a.checkPlatformCallback()}else{if(c=="ready"){a.callerIpAddress=d.response.data.callerIPAddress;a.checkPlatformCallback&&a.checkPlatformCallback()}}}}};a.checkPlatformStatus=function(c){var d;if(c&&c.status!==undefined){d="ready";if(c.status==1){a.log("error","Can't load - Internal Server error");d="error"}else{if(c.status==0){if(!c.data.tenantEnabled){a.log("error","Can't load - Internal Server error");d="error"}else{if(c.data.tenantEnabled==="no"){a.log("error","Can't load - Tenant disabled");d="error"}else{if(c.data.tenantEnabled==="yes"){if(c.data.platformInMaintenance){if(c.data.platformURLRedirect){a.log("info","Platform in maintenance - Redirecting...");d="redirect"}else{a.log("error","Can't load - Platform in maintenance");d="error"}}if(!c.data.channelEnabled){a.log("error","Can't load - Channel "+c.data.channelStatus||"disabled");d="error"}}}}}}}return d};a.redirectPlatform=function(d){var c=this.parseURL(d);if(c.protocol){this.config.domain=c.protocol+"://"+c.domain;this.config.path=c.path;this.platformRedirection=true;a.log("debug","Redirecting to",this.config.domain+this.config.path);this.checkPlatformAndConfigure()}else{a.log("error","Can't load - Redirect URL is invalid")}};a.parseURL=function(d){var g={};if(typeof d=="string"){var f=d.split("://");if(f.length==2){g.protocol=f[0];var e=f[1];var c=e.split("/");g.domain=c[0];g.path="/"+c.slice(1).join("/")}}return g};a.createContainer=function(){var c=document.createElement("div");c.style.position="fixed";c.style.bottom="0";c.style.width=a.containerProperties.width;c.style.height=a.containerProperties.height.closed;c.style.overflow="hidden";c.style.zIndex="2147483600";c.style.backgroundColor="transparent";c.style.border="0";if(this.config.align=="left"){c.style.left=a.containerProperties.left}else{c.style.right=a.containerProperties.right}return c};a.createIFrame=function(){var d=this.getEmbeddedChatURL(false);var c=document.createElement("iframe");c.setAttribute("src",d);c.style.width="100%";c.style.height="100%";c.style.border=0;c.marginHeight="0";c.marginWidth="0";c.frameBorder="no";return c};a.createConfigBrokerIFrame=function(){var e=this.getURL("static-common")+"/html/config-broker.html";var c=document.createElement("iframe");c.setAttribute("src",e);c.style.width="0";c.style.height="0";c.style.border=0;c.style.position="absolute";c.style.top="-10px";c.style.left="-10px";c.marginHeight="0";c.marginWidth="0";c.frameBorder="no";var d=document.getElementsByTagName("script")[0];d.parentNode.insertBefore(c,d);return c};a.getEmbeddedChatURL=function(d,c){var c=c?c:"button";var e=window.location.protocol+"//"+window.location.host;var f=this.getURL("static-common")+"/html/embedded-chat.html?uuid="+encodeURIComponent(this.config.uuid)+"&tenant="+encodeURIComponent(this.config.tenant)+"&domain="+encodeURIComponent(e)+"&channel="+encodeURIComponent(this.config.channel)+"&referrer="+encodeURIComponent(location.toString())+"&popup="+encodeURIComponent(d&&d.toString()||"false")+"&popuporigin="+encodeURIComponent(c)+"&startedbychatapi="+encodeURIComponent(a.isStartedByChatAPI())+"&syncrequired="+encodeURIComponent(d&&a.isWaitSyncRequired().toString()||"false");if(this.config.busHandlerURL){f+="&busHandlerURL="+encodeURIComponent(this.config.busHandlerURL)}if(this.config.stylesheetURL){f+="&stylesheetURL="+encodeURIComponent(this.config.stylesheetURL)}return f};a.setStartedByChatAPI=function(c){this._startedByChatAPI=c};a.isStartedByChatAPI=function(){return !!this._startedByChatAPI};a.resetStartedByChatAPI=function(){this._startedByChatAPI=false};a.appendToBody=function(c,d){c.appendChild(d);document.body.appendChild(c)};a.loadButton=function(c){if(this.config.buttonContainerId){this.button={};this.button.el=document.getElementById(this.config.buttonContainerId);if(this.button.el){this.config.renderButton=function(e){a.renderButton(e)};var d=this.getURL("static-tenant")+"/"+c+"/button.js";this.addScriptTagToBody(d)}}};a.addScriptTagToBody=function(e){var d=document.createElement("script");d.type="text/javascript";d.async=true;d.src=e;var c=document.getElementsByTagName("script")[0];c.parentNode.insertBefore(d,c)};a.renderButton=function(e){if(this.button&&this.button.el){var d=this.getURL("domain");var c=e.replace(/##path##/g,d);this.button.el.innerHTML=c;a.bindButtonClick();a.log("debug","button ready")}};a.bindButtonClick=function(){this.button.linkList=this.button.el.getElementsByTagName("a");for(var c=0,e=this.button.linkList.length;c<e;c++){var d=this.button.linkList[c];d.onclick=a.onButtonClick}};a.showButton=function(c){a.log("debug","show button");a.loadButton(c)};a.hideButton=function(){a.log("debug","hide button");a.renderButton("")};a.getURL=function(d){var c=this.config.domain+this.config.path;switch(d){case"chat":c+=a.CHAT_PATH;break;case"static-common":c+=a.CHAT_PATH+a.COMMON_PATH;break;case"static-tenant":c=this.config.domain;c+=a.SHARED_ALIAS+a.CHAT_PATH+"/"+this.config.tenant;break;case"domain":c=this.config.domain;break}return c};a.onButtonClick=function(){if(a.isChatConfiguredToPopout()){a.openChatPopup();a.sendMessage("button:click",{asPopout:true})}else{a.sendMessage("button:click",{asPopout:false})}return false};a.setPopoutConfiguration=function(c){a.configuredToPopout=c};a.isChatConfiguredToPopout=function(){return a.configuredToPopout};a.getPopupWindowName=function(){if(!this._popupWindowName){this._popupWindowName=(this.POPUP_WINDOW_NAME_PREFIX+"_"+this.config.uuid).replace(/[^\w-_]/,"_")}return this._popupWindowName};a.sendBrowserInfo=function(){this.sendMessage("chat:browser-info",{innerWidth:window.innerWidth,outerWidth:window.outerWidth,innerHeight:window.innerHeight,outerHeight:window.outerHeight})};a.sendChatPopupPosition=function(){var d=parseInt(a.windowProperties.width,10);var e=parseInt(a.windowProperties.height.open,10);var c=this.getChatPopupPosition(d,e);this.sendMessage("chat:popup:position",c)};a.getChatPopupPosition=function(g,h){var f=window.screenLeft!==undefined?window.screenLeft:screen.left;var c=window.screenTop!==undefined?window.screenTop:screen.top;width=window.innerWidth?window.innerWidth:document.documentElement.clientWidth?document.documentElement.clientWidth:screen.width;height=window.innerHeight?window.innerHeight:document.documentElement.clientHeight?document.documentElement.clientHeight:screen.height;var e=((width/2)-(g/2))+f;var d=(height/16)+c;return{left:e,top:d}};a.openChatPopup=function(d){var g=parseInt(a.windowProperties.width,10);var k=parseInt(a.windowProperties.height.open,10);var c=this.getChatPopupPosition(g,k);var j="width="+g+"px,height="+k+"px,left="+c.left+"px,top="+c.top+"px,menubar=no,resizable=yes,scrollbars=yes,toolbar=no,status=no";var f;try{f=window.open("",a.getPopupWindowName(),j,true);if(f&&f.location.pathname.indexOf("embedded-chat.html")==-1){var i=this.getEmbeddedChatURL(true,d);f.location=i;f.focus();this.sendChatPopupOpen()}else{a.log("debug","Chat Popup already exists - not opening additional one");setTimeout(function(){a.sendMessage("chat:popup:open",{tryFocus:true})},1)}}catch(h){console.log("Exception while trying to create the popup - probably it already exists");if(h&&h.message&&(h.message.indexOf("Permission denied")||h.message.indexOf("SecurityError"))){setTimeout(function(){a.sendMessage("chat:popup:open",{tryFocus:true})},1)}}try{f.focus()}catch(h){}};a.setWaitSyncRequired=function(){a.log("debug","setWaitSyncRequired");this.waitSyncRequired=true};a.isWaitSyncRequired=function(){return !!this.waitSyncRequired};a.sendChatPopupOpen=function(){this.sendChatPopupOpenInterval=setInterval(function(){a.sendMessage("chat:popup:open")},1000);setTimeout(function(){a.clearChatPopupOpenInterval()},5000)};a.clearChatPopupOpenInterval=function(){clearInterval(this.sendChatPopupOpenInterval)};a.configureMessage=function(){this.receiverDomain=this.config.domain;if(!window.addEventListener){window.attachEvent("onmessage",this.receiveMessage)}else{window.addEventListener("message",this.receiveMessage)}};a.sendMessage=function(c,f){var d=b.stringify({topic:c,data:f});var e=this.getReceiver();if(e){e.postMessage(d,this.receiverDomain)}};a.receiveMessage=function(d){if(d.origin===a.receiverDomain){var c=b.parse(d.data);a.processMessage(c)}};a.processMessage=function(d){a.log("debug","message received",d);switch(d.topic){case"chat:communication:established":this.onCommunicationEstablished(d.data);break;case"chat:loaded":this.chatLoaded(d.data);break;case"chat:open":case"chat:preChat:open":case"chat:postChat:open":case"chat:offline:open":case"chat:skipQueue:open":this.handleChangeHeight("open",d.data);break;case"chat:invitation:open":this.handleChangeHeight("invitationOpen",d.data);break;case"chat:close":this.handleChangeHeight("closed",d.data);break;case"chat:minimize":this.handleChangeHeight("minimized",d.data);break;case"show:button":var c=d.data;this.showButton(c);break;case"hide:button":this.hideButton();break;case"customer:info-sent":this.bus.publish(d.topic,d.data);break;case"chat:popup":this.onChatPopup(d.data);break;case"chat:popup:opened":this.clearChatPopupOpenInterval();break;case"chat:resize":this.setHeight(d.data.height);break;case"co-browsing:start":this.startCoBrowsing();break;case"co-browsing:end":this.endCoBrowsing();break}};a.onChatPopup=function(c){if(c&&c.popup){this.setPopoutConfiguration(c.popup)}};a.handleChangeHeight=function(d,c){if(!c||!c.fromPopup){this.changeHeight(d)}};a.changeHeight=function(d){a.log("debug","change height");var c=a.containerProperties.height[d];this.setHeight(c,true)};a.setHeight=function(c,d){this.container.style.height=c;setTimeout(this.sendMessage.bind(this,"chat:change:height",d),a.chatHeightChangeDelay)};a.chatLoaded=function(d){this.unsubscribeBusEvents();this.subscribeBusEvents();this.unsubscribeFromCoBrowsingEvents();this.subscribeToCoBrowsingEvents();this.resetStartedByChatAPI();if(!d.popup){var c=this.config.onInit;if(typeof c==="function"){c(this.bus)}this.sendBrowserInfo();this.sendChatPopupPosition()}};a.startCoBrowsing=function(){var c=this.getCoBrowsingInstance();if(c){c.requireCoBrowsing()}};a.endCoBrowsing=function(){var c=this.getCoBrowsingInstance();if(c){c.end()}};a.subscribed={};a.subscribeBusEvents=function(){this.subscribed.customerSetInfo=this.bus.subscribe("customer:set-info",a.onSetCustomerInfo);this.subscribed.customerResetInfo=this.bus.subscribe("customer:reset-info",a.onResetCustomerInfo);this.subscribed.chatEnd=this.bus.subscribe("chat:end",a.onChatEnd);this.subscribed.chatTriggerInvitation=this.bus.subscribe("chat:trigger-invitation",a.onChatTriggerInvitation);this.subscribed.chatSetLanguage=this.bus.subscribe("chat:set-language",a.onChatSetLanguage);this.subscribed.chatTriggerPreChat=this.bus.subscribe("chat:trigger-pre-chat",a.onChatTriggerPreChat);this.subscribed.chatTriggerChatWindow=this.bus.subscribe("chat:trigger-chat-window",a.onChatTriggerChatWindow)};a.unsubscribeBusEvents=function(){this.subscribed.customerSetInfo&&this.subscribed.customerSetInfo.remove();this.subscribed.customerResetInfo&&this.subscribed.customerResetInfo.remove();this.subscribed.chatEnd&&this.subscribed.chatEnd.remove();this.subscribed.chatTriggerInvitation&&this.subscribed.chatTriggerInvitation.remove();this.subscribed.chatSetLanguage&&this.subscribed.chatSetLanguage.remove();this.subscribed.chatTriggerPreChat&&this.subscribed.chatTriggerPreChat.remove();this.subscribed.chatTriggerChatWindow&&this.subscribed.chatTriggerChatWindow.remove()};a.coBrowsingSubscriptionTimeoutId=null;a.getCoBrowsingInstance=function(){return window.coBrowsingInstance};a.onCoBrowsingInstanceFound=function(c){c.on("co-browsing:connected",this.onCoBrowsingSessionConnected,this);c.on("co-browsing:disconnected",this.onCoBrowsingSessionDisconnected,this);var d=c.getSessionId();if(d!=null){this.onCoBrowsingSessionConnected({sessionId:d})}this.log("info","Co-browsing instance found");this.sendMessage("co-browsing:found")};a.onCoBrowsingSessionConnected=function(d){this.log("info","Co-browsing session connected");var c=this.getCoBrowsingInstance();this.sendMessage("co-browsing:connected",{sessionId:d.sessionId,stickyHash:c.getStickyHash()})};a.onCoBrowsingSessionDisconnected=function(){this.log("info","Co-browsing session disconnected");this.sendMessage("co-browsing:disconnected")};a.subscribeToCoBrowsingEvents=function(e){e=e||0;var d=this.getCoBrowsingInstance();this.log("info","Checking for co-browsing instance...");if(d){this.onCoBrowsingInstanceFound(d);this.coBrowsingSubscriptionTimeoutId=clearTimeout(this.coBrowsingSubscriptionTimeoutId)}else{var f=a.MAX_CO_BROWSING_INSTANCE_CHECK_TRIES;e++;if(e>=f){this.log("warn","Co-browsing instance not found after "+e+" tries, giving up")}else{var c=Math.pow(2,e)*100;this.coBrowsingSubscriptionTimeoutId=setTimeout(this.subscribeToCoBrowsingEvents.bind(this),c,e)}}};a.unsubscribeFromCoBrowsingEvents=function(){var c=this.getCoBrowsingInstance();if(c){c.off(null,null,this)}};a.getReceiver=function(){return this.iframe.contentWindow};a.onSetCustomerInfo=function(c){a.setWaitSyncRequired();a.sendMessage("customer:set-info",c)};a.onResetCustomerInfo=function(){a.sendMessage("customer:reset-info")};a.onChatEnd=function(){a.sendMessage("chat:end")};a.onChatTriggerInvitation=function(){a.sendMessage("chat:trigger-invitation")};a.onChatSetLanguage=function(c){a.setWaitSyncRequired();a.sendMessage("chat:set-language",c)};a.onChatTriggerPreChat=function(){if(a.isChatConfiguredToPopout()){a.setStartedByChatAPI(true);a.openChatPopup("preChat")}else{a.sendMessage("chat:trigger-pre-chat")}return false};a.onChatTriggerChatWindow=function(){if(a.isChatConfiguredToPopout()){a.setStartedByChatAPI(true);a.openChatPopup("chatWindow")}else{a.sendMessage("chat:trigger-chat-window")}return false};a.log=function(d){if(window.console&&a.logList.indexOf(d)>=a.logLevelIndex){try{window.console[d].apply(console,[a.ERROR_FLAG].concat(Array.apply(null,arguments).slice(1)))}catch(c){}}};a.start()})(window.JSON);