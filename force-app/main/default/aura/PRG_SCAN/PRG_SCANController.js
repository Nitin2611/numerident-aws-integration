({
	 doInit: function(cmp) {
		 //setTimeout(function(){ cmp.setfocus(); }, 200);
    },
    
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
			action.setParams({ "OppName":opportunityName});
			console.log('Ready');
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					console.log(response.getReturnValue());
					if(response.getReturnValue()=='#'){
						var resultsToast = $A.get("e.force:showToast");
						resultsToast.setParams({
							"title": "Désolé - Dossier introuvable.",
							"message": "Sorry - Unknown file reference.",
							"type": "error"
						});
						resultsToast.fire();
					}else{
						console.log('Ordonnance');
						if((response.getReturnValue()=='Vous serez informés dès que nous recevrons votre commande')||(response.getReturnValue()=='Nous avons enregistré réception de votre commandee')){
							var resultsToast = $A.get("e.force:showToast");
							resultsToast.setParams({
								"title": "Le dossier a été reconnu.",
								"message": response.getReturnValue(),
								"type": "success"
							});
							resultsToast.fire();
							component.find("searchOpportunity").set("v.value","");
						}else{
							if(response.getReturnValue().startsWith("@")){
								console.log('--- @');
								component.find("searchOpportunity").set("v.value","");
								var strWindowFeatures = "location=yes"; //,height=1000,width=500,scrollbars=yes,status=yes";
								var URL = "https://numerident.lightning.force.com/apex/OrderForm?id=" + response.getReturnValue().substring(1);
								var win = window.open(URL, "_blank", strWindowFeatures);
							}else{
								if(response.getReturnValue().startsWith("|")){
									console.log('--- |');
									var resultsToast = $A.get("e.force:showToast");
									resultsToast.setParams({
										"title": "Le dossier a été reconnu.",
										"message": "Scan OK",
										"type": "success"
									});
									resultsToast.fire();
									component.find("searchOpportunity").set("v.value","");
								}else{
									console.log('--- Autre');
									var navEvt = $A.get("e.force:navigateToSObject"); 
									navEvt.setParams({
										"recordId": response.getReturnValue(),
										"slideDevName": "detail" 
									});
									navEvt.fire();	
									$A.get('e.force:refreshView').fire();			
								}
							}
						}
					}
				}
			});
			$A.enqueueAction(action);
		}
	}
})