({
    getRecordType : function(cmp) {
        var action = cmp.get("c.getRecordType");
        var recordTypes = [];
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(cmp.isValid() && state === "SUCCESS"){
                console.log('component is valid and state is SUCCESS');
                var res = response.getReturnValue();
                
                for(var i = 0; i<res.length;i++){
                    recordTypes.push({
                        'value':res[i].Id,
                        'label':res[i].Name
                    });
                }                
                cmp.set("v.recordTypes",recordTypes);
                
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action); 
    },
    
    createRecord : function(cmp, rt) {
        
        var recordId = cmp.get("v.recordId");
        console.log("recordId "+recordId);
        var action = cmp.get("c.createLigne");
        action.setParams({ 
            recordId : recordId,
            recordType: rt
        });    
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if(cmp.isValid() && state === "SUCCESS"){
                console.log('createRecord successfull');
                var res = response.getReturnValue();
                console.log('Record created !!! '+res);
                this.gotoURL(res);
                
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action); 
    },
    
    gotoURL : function (id) {
        var urlEvent = $A.get("e.force:navigateToSObject");
        urlEvent.setParams({
            "recordId": id
        });
        urlEvent.fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
    
})