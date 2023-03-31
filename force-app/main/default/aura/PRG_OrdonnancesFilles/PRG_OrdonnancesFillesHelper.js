({
	getFilles : function(component, event, helper) {
        
        var action = component.get("c.OrdFilles");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(data) {
//            component.set("v.datatostring4test",JSON.stringify(data.getReturnValue() ));
            component.set("v.filles", data.getReturnValue());
            console.log('Valeurs - ' + data.getReturnValue());
        });
        $A.enqueueAction(action);		
    }
})