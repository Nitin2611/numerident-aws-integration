({
	gotoName : function(component,helper) {
		var opportunityName = component.find("searchOpportunity").get("v.value");
        var action = component.get("c.OppURL");
        action.setParams({ "OppName":opportunityName});
        console.log('Ready');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                if(response.getReturnValue()=='#'){
                	var resultsToast = $A.get("e.force:showToast");
                	resultsToast.setParams({
                		"title": "Ticket créé.",
                		"message": "Case created.",
                		"type": "error"
                	});
                	resultsToast.fire();
                }else{
                	//window.open(response.getReturnValue());
                	console.log(response.getReturnValue());
                	var resultsToast = $A.get("e.force:showToast");
                	resultsToast.setParams({
                		"title": "Ticket créé.",
                		"message": "Case created.",
                		"type": "success"
                	});
                	resultsToast.fire();
                }
            }
         });
		$A.enqueueAction(action);
	}
})