({
    UpsertStar: function (component, event, helper) { 
        
        //update
        //if(component.get("v.Lanote") !=null){
        if(false){
            console.log('upsert');
            var action = component.get("c.UpdateData");
            var newval =component.get("v.value") ;
            var ONote = component.get("v.Lanote");
            action.setParams({ "MaNotation" : ONote ,"newvalue" : newval });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var param1 = response.getReturnValue();
                    component.set("v.value", param1);
                     component.set("v.edit",false);
                    $A.get('e.force:refreshView').fire();
                }
            });
            $A.enqueueAction(action);            
        }
        
        else{

            var action = component.get("c.InsertData");
            var newval = component.get("v.value") ;
            
            action.setParams({ "idObj" : component.get("v.recordId"),"newvalue" : newval });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                     component.set("v.edit",false);
                    component.set("v.Lanote",response.getReturnValue());
                 $A.get('e.force:refreshView').fire();
                }
            });
            $A.enqueueAction(action); }
        
     

    }
    
    
    })