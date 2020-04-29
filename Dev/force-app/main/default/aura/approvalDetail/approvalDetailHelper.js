({
    getOfferInfo : function(component, event, helper, parm) {
        helper.callServerMethod(
            component,
            helper,
            "getOfferInfo",
            {
                offerId : parm
            },
            function(result){
                if (result) {
                    component.set("v.offerInfo", JSON.parse(JSON.stringify(result)));
                }
            },
            null 
        );
    }
})