({
    doInit : function(cmp, event, helper) {
        /*
         var values = cmp.get("TempValues");
         if(cmp.get("TempValues") != null){
            var values = cmp.get("TempValues").split(",");
            cmp.set("fieldvalues", values);
        }*/
        helper.getField(cmp);
    },
    
    clientsavefield : function(cmp, event, helper) {
        var field = cmp.get("v.fieldvalue");
        if(event.getParam('value') != null){
            helper.savefield(cmp);            
        }	
    }
})