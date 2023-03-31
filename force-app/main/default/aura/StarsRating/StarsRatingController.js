/**
 * Created by Sonal_Chaudhary on 1/5/2018.
 */
({
    doInit: function (component, event, helper) {                   
        var action = component.get("c.initData");
        action.setParams({ monid : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var param1 = response.getReturnValue();
                component.set("v.Lanote", param1);
                
                console.log(param1);
                console.log(param1.Note__c);
                component.set("v.value", param1.Note__c);
            }
        });
        $A.enqueueAction(action); 
    },
    
    
    afterScriptsLoaded : function(component, event, helper) {
        var domEl = component.find("ratingArea").getElement();
        var currentRating = component.get('v.value');
        var readOnly =  false;      // component.get('v.readonly');
        var maxRating = component.get('v.NombreDetoiles');    
        var callback = function(rating) {
            component.set('v.value',rating);
        }
        component.ratingObj = rating(domEl,currentRating,maxRating,callback,readOnly);
    },
    
    onValueChange: function(component,event,helper) {
        if (component.ratingObj) {
            var value = component.get('v.value');
            component.ratingObj.setRating(value,false);
            helper.UpsertStar(component,event,helper);     
        }
    },
   /* ShowModale : function(component, event, helper) {
        component.set('v.edit', 'true');
        component.set('v.ShowModal', 'true');
    },*/
    ShowModale : function(component, event, helper) {   
        component.set('v.ShowModale', 'true');
    },
    
    handleCancel : function(cmp,evt,helper){
       cmp.set('v.ShowModale', 'false');  
         $A.get('e.force:refreshView').fire();
    },
    
    SaveCommentaire :function(component,event,helper){
        alert('Save');
    }
    
})