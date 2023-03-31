({
    getTeeth : function(cmp) {
        var action = cmp.get("c.getTeeth");
        action.setParams({ 
            recordId : cmp.get("v.sObj"),
            FieldId : cmp.get("v.field")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(cmp.isValid() && state === "SUCCESS"){
                console.log('component is valid and state is SUCCESS');
                var str = response.getReturnValue();
                var res = "";
                if(str != null)res = str.split(";");
                cmp.set("v.Dents",res);
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
    
    
	saveTeeth : function(cmp) {
        var action = cmp.get("c.saveTeeth");
        var j =JSON.stringify(cmp.get("v.Dents"));

        action.setParams({ 
            teethValues : j,
            recordId : cmp.get("v.sObj"),
            FieldId : cmp.get("v.field")
        });
        
        action.setCallback(this, function(response) {
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

        $A.enqueueAction(action); 
        
        

	},
    
    initTeeth : function(cmp){
        var teeth = cmp.get("v.Dents");
        var F = cmp.get("v.field");
        if(teeth != null && teeth != ''){
            for(var i=0; i<teeth.length; i++){
                var tooth = document.getElementById(F+teeth[i]);
                if(tooth != null){
                    var svgElement = tooth.getElementsByClassName("dent")[0];
                    if(svgElement != null)svgElement.setAttribute("fill", "rgba(0, 161, 223,1)");
                }
            }
        }

    }, 
    
    
   
    
})