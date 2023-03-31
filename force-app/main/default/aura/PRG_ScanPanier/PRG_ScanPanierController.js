({
    onRender: function(component, helper) {
    	setTimeout(function(){ component.find("searchOpportunity").setfocus(); }, 200);
    },
    
    gotoOpportunityName : function(component, event, helper) {
		var opportunityName = component.find("searchOpportunity").get("v.value");
		console.log(opportunityName + '-' + event.which);
		if(event.which === 13){ //Enter key pressed
			console.log('GO13');
			var action = component.get("c.OppURL");
			console.log('Almost ready');
			action.setParams({ "OppName":opportunityName,"PanierId": component.get("v.recordId")});
			console.log('Ready');
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					console.log(response.getReturnValue());
					if(response.getReturnValue()!=""){
						var resultsToast = $A.get("e.force:showToast");
						resultsToast.setParams({
							"title": "Opportunité non trouvée",
							"message": response.getReturnValue(),
							"type": "error"
						});
						resultsToast.fire();
					}else{
						console.log(response.getReturnValue());
							/*var resultsToast = $A.get("e.force:showToast");
							resultsToast.setParams({
								"title": "OK",
								"message": "Opportunité mise à jour",
								"type": "success"
							});
							resultsToast.fire();*/
							component.find("searchOpportunity").set("v.value","");
							$A.get('e.force:refreshView').fire();		
	                        component.find("searchOpportunity").focus();
					}
				}
			});
			$A.enqueueAction(action);
		}
	}
})