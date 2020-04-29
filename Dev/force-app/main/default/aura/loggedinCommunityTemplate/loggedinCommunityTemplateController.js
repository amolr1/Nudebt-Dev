({
    doInit : function(component, event, helper) {
        
        var isShowAlert =  window.sessionStorage.getItem('isShowAlert');
        console.log('isShowAlert>>'+isShowAlert);
        let domainURL = window.location.origin;
        let pathName = window.location.pathname.split('/');
        if(pathName.length > 2) {
            component.set("v.currentTabName", pathName[2]);
        }
        if(domainURL) {
            
            helper.callServerMethod(
                component,
                helper,
                "getCustomPortalUIValues",                                       
                {
                    domainURL : domainURL,
                    portfolioName : null
                },  
                function(result) {
                         
                    console.log('isShowAlert----'+isShowAlert);                    
                    if(isShowAlert == null){
                       	component.set("v.isModalOpen2",true);
                        console.log("ismodal");
                    }
                    component.set("v.uiwrapperMap", result);
                    if(result.ReferralUrl) {
                        component.set("v.ReferralURL", result.ReferralUrl);
                    }
                },
                null
            );
        }
        
    },
    closeModal1 : function(component, event, helper) {
        console.log('close tab--Before'+sessionStorage.getItem('isShowAlert'));
        sessionStorage.setItem('isShowAlert', 1);
        console.log('close tab--After'+sessionStorage.getItem('isShowAlert'));
        component.set("v.isModalOpen2",false);
    },
    handleSelect: function(component, event, helper) {
        
        let selectButton1 = component.find("menu-item-div1_id");
        var isExpandable1 = $A.util.hasClass(component.find("menu-item-div1_id"), "slds-is-open");
        if (!isExpandable1) {
            $A.util.addClass(selectButton1,  " slds-is-open");
            component.set("v.isHideProfileMenu", false);
        } else {
            $A.util.removeClass(selectButton1, "slds-is-open");
            component.set("v.isHideProfileMenu", true);           
        }
        helper.setProfileMenu(component, event, helper);      
    },
    expandSection : function(component, event, helper) {
       // component.set("v.isHideProfileMenu", false);
        component.set("v.isExpandedProfile", false);
        component.set("v.isSectionExpanded", !component.get("v.isSectionExpanded"));
        console.log("@@##@@ before "+component.get("v.showMyProfile"));
        component.set("v.showMyProfile", !component.get("v.showMyProfile"));
        console.log("@@##@@ before "+component.get("v.showMyProfile"));
        let selectButton1 = component.find("menu-item-div1_id");
        let selectButton2 = component.find("menu-item-div2_id");
        let selectButton3 = component.find("menu-item-div_id");
        
        var isExpandable1 = $A.util.hasClass(component.find("menu-item-div1_id"), "slds-show");
        var isExpandable2 = $A.util.hasClass(component.find("menu-item-div2_id"), "slds-show");
        var isExpandable3 = $A.util.hasClass(component.find("menu-item-div_id"), "slds-show");
        
        if (!isExpandable3) {
            $A.util.addClass(selectButton3,  "slds-show"); 
            $A.util.removeClass(selectButton3, "slds-hide");
        } else {
            $A.util.addClass(selectButton3,  "slds-hide"); 
            $A.util.removeClass(selectButton3, "slds-show");
        }
        if (!isExpandable1) {
            $A.util.addClass(selectButton1,  "slds-show"); 
            $A.util.removeClass(selectButton1, "slds-hide");
        } else {
            $A.util.addClass(selectButton1,  "slds-hide"); 
            $A.util.removeClass(selectButton1, "slds-show");
        }
        if (!isExpandable2) {
            $A.util.addClass(selectButton2,  "slds-show"); 
            $A.util.removeClass(selectButton2, "slds-hide");
        } else {
            $A.util.addClass(selectButton2,  "slds-hide"); 
            $A.util.removeClass(selectButton2, "slds-show");
        }
         // component.set("v.isHideProfileMenu", true); 
    },
    
    expandProfile : function(component, event, helper) {
        component.set("v.isSectionExpanded", false);
        component.set("v.isExpandedProfile", !component.get("v.isExpandedProfile"));
    },
    
    blurProfile : function(component, event, helper) {
        
        setTimeout(function(){
            component.set("v.isExpandedProfile", !component.get("v.isExpandedProfile"));
        }, 300);
    },
    
    redirectToFeedbackUrl : function(component, event, helper) {
        
        let uiwrapperMap = component.get("v.uiwrapperMap");
        var urlEvent = $A.get("e.force:navigateToURL");
        let urlToSend = uiwrapperMap.uiInstance.Portfolio__r.Submit_Feedback__c;
        if(uiwrapperMap && uiwrapperMap.currentUserType !== 'Guest') {
            urlToSend = '/s/contactsupport?subject=feed'
        } 
        urlEvent.setParams({
            "url": urlToSend
        });
        urlEvent.fire();
    },
    
    closeModel : function(component, event, helper) {
        component.set("v.uiwrapperMap.isInCriticalStage", false);
    },
    
    rescheduleNow : function(component, event, helper) {
        component.set("v.uiwrapperMap.isInCriticalStage", false);
        let paymentId = event.currentTarget.getAttribute("data-paymentId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/payments?id="+paymentId
        });
        urlEvent.fire(); 
    },
    
    handleApplicationEvent : function(component, event, helper) {
        helper.handleApplicationEvent(component, event, helper);
    },
    setCurrentMenu : function(component, event, helper) {
        component.set("v.isModalOpen2",false);
        let selectButton = component.find("menu-item-div_id");
        let selectButton1 = component.find("menu-item-div1_id");
        let selectButton2 = component.find("menu-item-div2_id");
        if ($A.util.hasClass(selectButton, "slds-is-open") || $A.util.hasClass(selectButton1, "slds-is-open")
            							|| $A.util.hasClass(selectButton2, "slds-is-open")) {
            if ($A.util.hasClass(selectButton, "slds-is-open")) {
                $A.util.removeClass(selectButton, "slds-is-open");
            }
            if ($A.util.hasClass(selectButton1, "slds-is-open")) {
                $A.util.removeClass(selectButton1, "slds-is-open");
            }
        }   
        helper.setCurrentmenu(component, event, helper);
    },
    
    setDisplayAlert: function(component, event, helper) {
        component.set("v.displayAlert",event.getParam("isDisplayTaskAlert"));
    },
    handleMenuClick : function(component, event, helper) {
        
        let selectButton = component.find("menu-item-div_id");
        let selectButton1 = component.find("menu-item-div1_id");
        let selectButton2 = component.find("menu-item-div2_id");
        if (!$A.util.hasClass(component.find("menu-item-div_id"), "slds-is-open")) {
            $A.util.addClass(selectButton,  " slds-is-open");
            component.set("v.isHideProfileMenu", false);
        } else {
            $A.util.removeClass(selectButton, "slds-is-open");
            component.set("v.isHideProfileMenu", true);           
        }
        if (!$A.util.hasClass(component.find("menu-item-div1_id"), "slds-is-open")) {
            $A.util.addClass(selectButton1,  " slds-is-open");
            component.set("v.isHideProfileMenu", false);
        } else {
            $A.util.removeClass(selectButton1, "slds-is-open");
            component.set("v.isHideProfileMenu", true);           
        }    
      /*  if (!$A.util.hasClass(component.find("menu-item-div2_id"), "slds-is-open")) {
            $A.util.addClass(selectButton2,  " slds-is-open");
            component.set("v.isHideProfileMenu", false);
        } else { 
            $A.util.removeClass(selectButton2, "slds-is-open");
            component.set("v.isHideProfileMenu", true);           
        } */     
    },
    top: function(component){
        var scrollOptions = { left: 0, top: 0, behavior: 'smooth' }; 
        window.scrollTo(scrollOptions);
    },
    SetStatusPosition : function(component){
        var elmnt = document.getElementById("debtOverviewCmp");
        var y = elmnt.offsetTop;
        var scrollOptions = { left: 0, top: y-100, behavior: 'smooth' }; 
        window.scrollTo(scrollOptions);
    },
    SetAlertsPosition : function(component){
        var elmnt = document.getElementById("offerListTop");
        var y = elmnt.offsetTop;
        var scrollOptions = { left: 0, top: y, behavior: 'smooth' }; 
        window.scrollTo(scrollOptions);
    }
})