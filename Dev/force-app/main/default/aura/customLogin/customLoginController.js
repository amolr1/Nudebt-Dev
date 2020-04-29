({
    doInit : function(component, event, helper) {		 
        
        var browserType = navigator.sayswho= (function(){
            var ua = navigator.userAgent, tem,
                M = ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];
            if(/trident/i.test(M[1])){
                tem =  /\brv[ :]+(\d+)/g.exec(ua) || [];
                return 'IE '+(tem[1] || '');
            }
            if(M[1]=== 'Chrome'){
                tem = ua.match(/\b(OPR|Edge)\/(\d+)/);
                if(tem!= null) return tem.slice(1).join(' ').replace('OPR', 'Opera');
            }
            M = M[2]? [M[1], M[2]]: [navigator.appName, navigator.appVersion, '-?'];
            if((tem = ua.match(/version\/(\d+)/i)) != null) M.splice(1, 1, tem[1]);
            return M.join(' ');
        })();
        
        if (browserType.startsWith("Edge")) {
            var edge = parseInt(browserType.replace("Edge ", ""));
            if (edge > 17) {
                alert('You Don\'t have Access to view this Page.');
                component.set("v.isEdge", false);
            }
        }
        
        let domainURL; //= window.location.origin;
        let pathName = window.location.href.split('/s/');
        if(pathName.length > 1) {
            domainURL = pathName[0];
        }
        
        /* Added for testing in UAT */
        console.log('**** portfolio url', window.location.search);
        let portfolioName = '';
        let searchString = window.location.search;
        if(searchString.indexOf('portfolio=') !== -1 && searchString.split('portfolio=').length > 1) {
            
            console.log('**** portfolio url', searchString.split('portfolio='));
            portfolioName = searchString.split('portfolio=')[1];
        }
        console.log('**** domainURL-->', domainURL, '<--domainURL-->');
        
        /* END of Added for testing in UAT */
        if(domainURL) {
            helper.callServerMethod(
                component,
                helper,
                "getCustomPortalUIValues",                                       
                {
                    domainURL : domainURL,
                    portfolioName : portfolioName
                },  
                function(result) {
                    console.log('***** uiwrapperMap *****', result);
                    component.set("v.uiwrapperMap", result);
                },
                null
            );
        }
    },
    oneSignalNotification : function(oneSignal) {	
        alert('You Don\'t have Access to view this Page.');
    },
    getValue : function(component, event, helper) {
        console.log('***** after scripts loaded');
        
    },
    getMethod : function(component, event, helper) {
        console.log('*****getMethod on click called');
        console.log('****** window', window);        
    }
})