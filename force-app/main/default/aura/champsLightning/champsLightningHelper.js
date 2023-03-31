({
	getField : function(cmp) {
        var action = cmp.get("c.getField");
        action.setParams({ 
            recordId : cmp.get("v.recordId"),
            FieldId : cmp.get("v.field")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(cmp.isValid() && state === "SUCCESS"){
                console.log('component is valid and state is SUCCESS');
                var str = response.getReturnValue();
                //cmp.set("v.fieldvalue", str);
                cmp.set("v.ligne", str);
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
        
        var action2 = cmp.get("c.getPicklistValues");
        action2.setParams({ 
            FieldName : cmp.get("v.field")
        });
        
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if(cmp.isValid() && state === "SUCCESS"){
                var str = response.getReturnValue();
                var res = '';
                cmp.set("v.fieldvalues", str);
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
        $A.enqueueAction(action2); 
    },
    
    savefield : function(cmp) {
        var actionsave = cmp.get("c.savefield");
        var j =cmp.get("v.fieldvalue");

        actionsave.setParams({ 
            fieldvalues : j,
            recordId : cmp.get("v.recordId"),
            FieldId : cmp.get("v.field")
        });
        
        actionsave.setCallback(this, function(response) {
            var state = response.getState();
            if(cmp.isValid() && state === "SUCCESS"){
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

        $A.enqueueAction(actionsave); 
        
        

	}
    
})