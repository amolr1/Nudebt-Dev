({
	doInit : function(component, event, helper) {
        
        var domainURL = window.location.origin;
        /* Added for testing in UAT */
        let portfolioname = '';
        let searchString = window.location.search;
        if(searchString.indexOf('portfolio=') !== -1 && searchString.split('portfolio=').length > 1) {
            portfolioname = searchString.split('portfolio=')[1];
        }
        /* END of Added for testing in UAT */
        if(domainURL) {
            helper.callServerMethod(
                component,
                helper,
                "getFooterValue",                                       
                {
                    domainURL : domainURL,
                    portfolioName : portfolioname
                },  
                function(result) {
                    component.set("v.footerValueMap", result);
                },
                null
            );
        }
    }
})