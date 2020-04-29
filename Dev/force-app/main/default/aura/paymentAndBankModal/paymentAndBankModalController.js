({
    saveGroupTask : function(component,event,helper) {
        
        var returnedValue;
        var objectInfo = component.get("v.objectInfo");
        if(objectInfo == 'Bank') {
            let adhocPaymentWrapper = component.get("v.adhocPaymentWrapper") || {};
            let editBankInfoFieldsList = [];
            editBankInfoFieldsList.push(
                {
                    'fieldAPIName' : "SFSPortal_Account_Number__c",
                    'fieldLabel': "Account Number",
                    'fieldType' : "string",
                    'isRequired' : true
                },
                {
                    'fieldAPIName' : "SFSPortal_Re_Enter_Account_Number__c",
                    'fieldLabel': "Re-Enter Account Number",
                    'fieldType' : "string",
                    'isRequired' : true
                },
                {
                    'fieldAPIName' : "SFSPortal_Routing_Number__c",
                    'fieldLabel': "Routing Number",
                    'fieldType' : "string",
                    'isRequired' : true
                },
                {
                    'fieldAPIName' : "SFSPortal_Bank_Name__c",
                    'fieldLabel': "Bank Name",
                    'fieldType' : "string",
                    'isRequired' : false
                }
            );
            editBankInfoFieldsList = editBankInfoFieldsList.concat(adhocPaymentWrapper.editBankInfoFieldsList || []); 
            returnedValue = helper.fieldValidationHelper(component, event, editBankInfoFieldsList, component.find("validation"));
            
            if (returnedValue.isFormValid) {
                
                let newGroupTaskInstance = component.get("v.newGroupTaskInstance");
                if (newGroupTaskInstance.SFSPortal_Account_Number__c !== newGroupTaskInstance.SFSPortal_Re_Enter_Account_Number__c) {
                    
                    returnedValue.errorMessage += 'Account number and Re-Enter account number should match';
                    returnedValue.isFormValid = false;
                }
            }
        } else {
            
            returnedValue = helper.fieldValidationHelper(component, event, component.get("v.adhocPaymentWrapper.editPaymentFieldsList"), component.find("validation"));
        }
        if (returnedValue.isFormValid) {
            
            document.getElementById('testDiv').style.display = 'none';
            var errorMsg = component.get("v.toRenderModal");
            errorMsg.Name = 'Confirm';
            var objectInfo = component.get("v.objectInfo");
            if(objectInfo == 'Bank') {
                
                errorMsg.Message = $A.get("$Label.c.SFSPortal_Bank_Account_Confirmation_Message");
            }
            if(objectInfo == 'Payment') {
                
                errorMsg.Message = $A.get("$Label.c.SFSPortal_Add_funds_Confirmation_Message");
            }
            component.set("v.toRenderModal",errorMsg);
        } else {
            
            document.getElementById('testDiv').style.display = 'none';
            var errorMsg = component.get("v.toRenderModal");
            errorMsg.Name = 'Alert';
            errorMsg.Message = returnedValue.errorMessage;
            component.set("v.toRenderModal",errorMsg);
        }
    },
    cancelModal : function(component, event, helper) {
        
        component.set("v.isModal",false);
    },
    handleEvent : function(component,event,helper) {
        
        let objectInfo = component.get("v.objectInfo");
        var newGroupTaskInstance = component.get("v.newGroupTaskInstance");
        if (objectInfo == 'Payment') {
            let inputElement = event.getSource();
            var fieldName = inputElement.get("v.fieldName");
            if (!fieldName) {
                fieldName = inputElement.get("v.name");
            }
            var fieldvalue = event.getParam("value");
            if(fieldName === 'Ad_Hoc_Date__c') {
                let dateValidity = inputElement.get("v.validity").valid;
                if(!dateValidity) {
                    let minDate = new Date(inputElement.get("v.min"));
                    minDate.setTime(minDate.getTime() + minDate.getTimezoneOffset() * 60 * 1000);
                    let maxDate = new Date(inputElement.get("v.max"));
                    maxDate.setTime(maxDate.getTime() + maxDate.getTimezoneOffset() * 60 * 1000);
                    var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                    if (new Date(fieldvalue) < minDate) {
                        inputElement.setCustomValidity('Value must be ' + monthNames[(minDate.getMonth())]  + " " + (minDate.getDate()) + ", " + minDate.getFullYear() + ' or later');
                    } else if (new Date(fieldvalue) > maxDate) {
                        inputElement.setCustomValidity('Value must be ' + monthNames[(maxDate.getMonth())]  + " " + (maxDate.getDate()) + ", " + maxDate.getFullYear() + ' or earlier');
                    } else {
                        inputElement.setCustomValidity('');
                    }
                } else {
                    inputElement.setCustomValidity('');
                }
            }
            newGroupTaskInstance[fieldName] = fieldvalue;
        } else if (objectInfo == 'Bank') {
            var fieldName = event.getSource().get("v.fieldName");
            var fieldvalue = event.getParam("value");
            newGroupTaskInstance[fieldName] = fieldvalue;
        }     
        component.set("v.newGroupTaskInstance",newGroupTaskInstance);
    },
    validateRoutingNumber : function(component, event, helper) {
        let routingNumber = event.getSource().get("v.value");
        let validity = event.getSource().get("v.validity").valid;
        if(routingNumber && validity) {
            
            helper.callServerMethod(
                component,
                helper,
                "getRoutingBankDetails",
                {
                    "routingNumber": routingNumber
                },
                function(response) {
                    let newGroupTaskInstance = component.get("v.newGroupTaskInstance") || {};
                    newGroupTaskInstance.SFSPortal_Bank_Name__c = response.customer_name;
                    component.set("v.newGroupTaskInstance", newGroupTaskInstance);
                }
            );
        }
    },
    cancelConfirmationModal : function(component, event, helper) {
        
        component.set("v.toRenderModal.Name","");
        document.getElementById('testDiv').style.display = 'block';
    },
    createGroupTask : function(component,event,helper) {
        
        helper.callServerMethod(
            component,
            helper,
            "saveRecord",                                       
            {
                newGroupTaskInstance : component.get("v.newGroupTaskInstance"),
                objectInfo :  component.get("v.objectInfo")
            },  
            function(result) {
                component.set("v.newGroupTaskInstance",{'sobjectType':'nu_dse__Group_Task__c'});
                component.set("v.isModal",false);
                document.getElementById('testDiv').style.display = 'none';
                var errorMsg = component.get("v.toRenderModal");
                errorMsg.Name = 'Your request has been received.';
                var objectInfo = component.get("v.objectInfo");
                if(objectInfo == 'Bank') {
                    errorMsg.Message = $A.get("$Label.c.SFSPortal_Bank_Account_Success_Message");
                }
                if(objectInfo == 'Payment') {
                    errorMsg.Message = $A.get("$Label.c.SFSPortal_Add_funds_Success_Message");
                }        
                component.set("v.toRenderModal",errorMsg);
            },null
        ); 
    },
    cancelGroupTask : function(component,event,helper) {
        $A.get('e.force:refreshView').fire();
    },
})