({
    init: function(cmp){    
       var setting = cmp.get("v.awsSetting");
        AWS.config.update({
            accessKeyId: setting.AWS_Access_Key_Id__c, 
            secretAccessKey: setting.AWS_Secret_Access_Key__c,
            region: setting.S3_Region_Name__c
        });
        var recordId = cmp.get("v.recordId");
    },
    getCurrentRecord: function(cmp){
      	// we are unable to detect View action on Extranet
      	// we are unbale to detect relationshipPage intranet View Action
        var recordId, objectName, isRecordRelationshipPage;
        var currentUrl = window.location.href; 
        var decodedUri = decodeURIComponent(currentUrl);
        var isIntranet = decodedUri.includes('?inContextOfRef=') || decodedUri.includes('lightning');
        
        if(isIntranet){
            var base64Context = decodedUri.substring(
                decodedUri.indexOf("=") + 1, 
                decodedUri.lastIndexOf("&")
            );
            base64Context = base64Context.startsWith("1\.") ? base64Context.substring(2) : base64Context;
            var addressableContext = JSON.parse(window.atob(base64Context));
            console.log('*** '+ JSON.stringify(addressableContext));
            recordId = addressableContext.attributes.recordId;
            isRecordRelationshipPage = addressableContext.type == 'standard__recordRelationshipPage';
            objectName = addressableContext.attributes.relationshipApiName;
        }
        else {
            // labo/s/ordonnance/a0i5t000000JhygAAC/test => recordPage
            // labo/s/relatedlist/a0i5t000000JhygAAC/MyDocsFiles__r => recordRelationship
            var splitedUri = decodedUri.split(/[\/]+/);
            recordId = splitedUri[splitedUri.length - 2];
            isRecordRelationshipPage = splitedUri.pop().includes('__r'); // for Intranet View is always false
        }
        cmp.set('v.isExtranet', (! isIntranet));
        cmp.set('v.recordId', recordId);
        cmp.set('v.objectName', objectName);
        cmp.set('v.isRecordRelationshipPage', isRecordRelationshipPage);
        // DEBUG 
        var log = {isIntranet, recordId, objectName, isRecordRelationshipPage};
        console.log('*** init Logs: '+ JSON.stringify(log));
        return recordId;
    },
    checkOrdEditable: function(cmp, recordId){
        var action = cmp.get('c.isEditable');
        action.setParams({recordId: recordId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.isEditable", response.getReturnValue());
                console.log('*** Is editable record: '+cmp.get("v.isEditable"));
            }
        });
        $A.enqueueAction(action);
    },
    uploadToAWS: function(cmp, file) {
        if(file){
            let fileName = file.name
                .replace(/\s+/g, "_") //each space character is being replaced with _
                .toLowerCase(); 
            let fileExt = fileName.split('.').pop();
            const date = new Date();
            var dirName =  (date.getMonth() + 1) + '_' +  date.getFullYear() + '/';
            let objKey  = dirName + this.makeId(15) + '.' +fileExt;  

            cmp.set('v.showProgressBar', true);
            cmp.set('v.info', 'Upload en cours...');

            var s3 = new AWS.S3();
            var recordId = cmp.get("v.recordId");
            var setting = cmp.get("v.awsSetting");
            var bucketName = setting.S3_Bucket_Name__c;
            var params = {Bucket: bucketName, Key: objKey, ContentType: file.type, Body: file};
            // var helper = this;
            var recordParam = {
                    fileName: fileName,
                    contentSize: file.size, 
                    fileExt: fileExt,
                    fileUrl: objKey,
                    recordId: recordId
            };
            var uploadPromise = s3.upload(params, function(err, data) {
                if(err) {
                    console.log('There was an error uploading your file: ', err);
                    cmp.set('v.info', '');
                    cmp.set('v.error', 'Erreur: '+ err);
                    return false;
                }
                console.log('Successfully uploaded file.', data);
                return true;
            })
            .on('httpUploadProgress', function(progress) {
                let progressPercentage = Math.round(progress.loaded / progress.total * 100);
                console.log(progressPercentage);
                cmp.set('v.progressBar',  Math.trunc(progressPercentage / 1.42) );
            })
            .promise();
			var self = this;  
            uploadPromise.then((response) => {
                window.setTimeout(
                    $A.getCallback(function() {
                        self.createMyDocsRecord(cmp, recordParam);
                        console.log(response);
            	    }), 500
				);
            });
        }
    },
    createMyDocsRecord: function(cmp, params){
        console.log('*** Create Record with params '+ JSON.stringify(params));
        cmp.set('v.info', 'Création de l\'enregistrement en cours...');
        
        var action = cmp.get("c.createRecord");
        action.setParams(params);
        action.setCallback(this, function(response){

                    var state = response.getState();
                    if(state == 'SUCCESS') {
                        cmp.set('v.progressBar', 100);
                        cmp.set('v.info', '');
                        cmp.set('v.success', 'Le fichier a été créé avec succès !');
                        console.log(response.getReturnValue());
                    }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                // log the error passed in to AuraHandledException
                                console.log("*** Error message: " +  errors[0].message);
                                cmp.set('v.info', '');
                                cmp.set('v.error', 'Erreur: '+ errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
          
            
        });
        $A.enqueueAction(action);
    },
    cancelDialog : function(cmp) {
        var isRelateionshitPage = cmp.get("v.isRecordRelationshipPage");
        if(isRelateionshitPage){
            console.log('&&& isRelateionshitPage');
            var navEvt = $A.get("e.force:navigateToRelatedList");
            navEvt.setParams({
                "relatedListId": "MyDocsFiles__r",
                "parentRecordId": cmp.get("v.recordId")
            });
            navEvt.fire();
        }
       else{
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": cmp.get("v.recordId")
            });
            navEvt.fire();
        }
    },
    showNotification: function(type, title, message, duration){
        duration = duration == undefined ? 5000 : duration;
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({type, title, message, duration});
        toastEvent.fire();
    },
    makeId: function() {
        return self.crypto.randomUUID();
    }
                              
})