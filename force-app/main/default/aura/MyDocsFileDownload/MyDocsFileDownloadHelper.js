({
    init: function(cmp){    
       var setting = cmp.get("v.awsSetting");
        AWS.config.update({
            accessKeyId: setting.AWS_Access_Key_Id__c, 
            secretAccessKey: setting.AWS_Secret_Access_Key__c,
            region: setting.S3_Region_Name__c
        });
        var recordId = cmp.get("v.recordId");
  		this.getRecord(cmp, recordId);     
        // $A.get("e.force:closeQuickAction").fire();
    },
    getCurrentRecord: function(cmp){
        var currentUrl = window.location.href;
        var decodedUri = decodeURIComponent(currentUrl);
        var splitedUri = decodedUri.split(/[\/]+/);
        var recordId = splitedUri[splitedUri.length - 1];
        recordId = (recordId == 'view') ?  splitedUri[splitedUri.length - 2] : recordId;
        // alert(recordId);
        cmp.set('v.recordId', recordId);
    },
    getS3Object: function(cmp, objKey, fileName) {
        console.log('*** Get Object with key: '+ objKey + ' and create file with name: '+fileName);
        var setting = cmp.get("v.awsSetting");
        var bucketName = setting.S3_Bucket_Name__c;
        var s3 = new AWS.S3();
        s3.getObject({Key: objKey, Bucket: bucketName}, 
            (err, res) => {
                if(err) {
                    console.log('*** Error: ' +err);
                    this.showNotification("error", "Téléchargement du fichier impossible", "Fichier introuvable"); 
                } 
                else {
                    console.log("*** Success");
                    console.log('File data', res);
                    let objectData = res.Body.toString('base64'); 
                    console.log('*** data to Base64', res);
                    this.base64ToFile(objectData, fileName, res.ContentType); 
                    this.showNotification("success", "Téléchargement réussi", "Le fichier a été téléchargé avec succès" );    
                }     
            });
    },
    getRecord: function(cmp, recordId){
        var action = cmp.get('c.getRecord');
        action.setParams({'recordId': recordId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            let fileObj = response.getReturnValue();
            if (state === "SUCCESS" && fileObj != null && fileObj != undefined) {
                var fileName = fileObj.FileName__c;
                var objectKey = fileObj.FileUrl__c;
                this.getS3Object(cmp, objectKey, fileName);
            }
            else{
                this.showNotification("error", "Télécharment du fichier impossible", "Fichier introuvable"); 
            }
            history.back();
        });
        $A.enqueueAction(action);
    },
    base64ToFile: function(base64EncodedData, fileName, fileType) {
        console.log('*** Base64 to File ');
        console.log('*** params fileName: '+fileName);
        console.log('*** param FileType: '+ fileType);
        // to remove charset..
        fileType = fileType.split(';')[0];
        const bufferArray = this.base64ToArrayBuffer(base64EncodedData);
        const blobStore = new Blob([bufferArray], { type: fileType });

        if (window.navigator && window.navigator.msSaveOrOpenBlob) {
            window.navigator.msSaveOrOpenBlob(blobStore);
            return;
        }
        const data = window.URL.createObjectURL(blobStore);
        const link = document.createElement('a');
        document.body.appendChild(link);
        link.href = data;
        link.download = fileName ;
        link.click();
        window.URL.revokeObjectURL(data);
        link.remove();
    },
    base64ToArrayBuffer: function(data) {
        const bString = window.atob(data);
        const bLength = bString.length;
        const bytes = new Uint8Array(bLength);
        for (let i = 0; i < bLength; i++) {
            bytes[i] = bString.charCodeAt(i);
        }
        return bytes;
    },
    showNotification: function(type, title, message, duration){
        duration = duration == undefined ? 5000 : duration;
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({type, title, message, duration});
        toastEvent.fire();
    },                        
})