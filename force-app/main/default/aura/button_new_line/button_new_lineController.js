({
	init : function(component, event, helper) {
        var url = window.location.pathname;
        console.log("url : "+url);
        console.log("recordID"+component.get("v.recordId"));
		helper.getRecordType(component);
	},
    
    createRecord:function(component, event, helper){
        console.log("controller - create record");
        var rt = component.find("selection").get("v.value");
        console.log("rt "+rt);
        helper.createRecord(component, rt);
        
    }
})