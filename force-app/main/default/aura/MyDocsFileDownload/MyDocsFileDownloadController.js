({  
    init: function(cmp, event, helper) {
        helper.getCurrentRecord(cmp, event, helper);
    },
    initAwsSdk: function(cmp, event, helper) {
        console.log('SDK loaded');
        var action = cmp.get("c.getAwsSetting"); // get metadata record with S3 credential
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var settings = response.getReturnValue();
                console.log('++++ '+settings.AWS_Access_Key_Id__c);
                cmp.set("v.awsSetting", settings);
                helper.init(cmp);
            }else{
                console.log('++++ err');
            }
        });
        $A.enqueueAction(action);
    },
})