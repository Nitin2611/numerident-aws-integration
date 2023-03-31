({  
    init: function(cmp, event, helper) {
        var currentUrl = window.location.href; 
        var recordId = helper.getCurrentRecord(cmp, event, helper);
        helper.checkOrdEditable(cmp, recordId);  
    },
    initAwsSdk: function(cmp, event, helper) {
        console.log('SDK loaded');
        var action = cmp.get("c.getAwsSetting"); // get metadata record with S3 credential
        // action.setParams({});
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
    handleSelectedFiles: function(cmp, event, helper) {
        if (event.target.files.length > 0) {
            var selectedFilesToUpload = event.target.files[0];
            var fileName = event.target.files[0].name;
            console.log("*** fileName ====> " + fileName); 
            helper.uploadToAWS(cmp, selectedFilesToUpload);  
        }
    },
    handleFileClick: function(cmp, event, helper){
        console.log('Files length: ', event.target.files.length);
        if (event.target.files.length > 0) {
            //alert('Files Loaded');
        }else{
            // helper.cancelDialog(cmp);
        }
    },
    handleClose: function(cmp, event, helper) {
        var isExtranet = cmp.get("v.isExtranet");
        var error = cmp.get("v.error");
        var success = cmp.get("v.success");
        var showProgressBar = cmp.get("v.showProgressBar");
       
       if(showProgressBar && success == '' && error == ''){
            helper.showNotification("information", "Opération en cours", "Veuillez attendre la fin de l'opération."); 
       }
        else{
            if(isExtranet){
              //cmp.destroy();
              $A.get('e.force:refreshView').fire();
              $A.get("e.force:closeQuickAction").fire();
            }else {
               helper.cancelDialog(cmp);
            } 
        }
        
    },
})