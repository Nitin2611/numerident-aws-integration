public class uploadFileToAWSD {
    
    // Method to get Type of uploaded file
    public string ContentType(string fileType) {
        switch on fileType.toLowerCase() {
            when 'docx' {
                return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            } 
            when 'csv' {
                return 'application/vnd.ms-excel';
            }
            when 'wav' {
                return 'audio/wav';
            }
            when 'wmv' {
                return 'video/x-ms-wmv';
            }
            when 'mp3' {
                return 'audio/mpeg';
            }
            when 'mp4' {
                return 'video/mp4';
            }
            when 'png' {
                return 'image/png';
            }
            when 'pdf' {
                return 'application/pdf';
            }
            when else {
                return 'image/jpeg';
            }
        }
    }
    
    
    // Call this method to upload file
    // run below code in aynonums code
    
    /********
List<Id> contentVersionList = new List<Id>();
cvIcontentVersionListds.add('0685j00000G54yMAAR');
System.debug(' contentVersionList ==>' + contentVersionList);
uploadFileToAWS uafs = new uploadFileToAWS();
uafs.UploadDocuments(contentVersionList);
*********/
    
    public void UploadDocuments(List<Id> cvIds) {
        //Get Named Credential - get configured s3 url
        //NamedCredential named=[SELECT DeveloperName, Endpoint FROM NamedCredential where DeveloperName='aws_s3'];
        for(ContentVersion attach: [SELECT VersionData,Title,ContentDocumentId,FileExtension FROM ContentVersion WHERE Id IN: cvIds]) {
            try {
                // Creating Multipart Upload
                //String attachmentBody = EncodingUtil.base64Encode(attach.VersionData);
                //String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/octet-stream');
                req.setEndpoint('callout:aws_s3/esta-conseil/' + attach.Title + '.' + attach.FileExtension + '?uploads' );
                
                Http http = new Http();
                HTTPResponse res = http.send(req);
                
                String uploadId = '';
                String responseBody = res.getBody();
                if (responseBody != null && responseBody.contains('UploadId')) {
                    uploadId = responseBody.substringBetween('<UploadId>', '</UploadId>');
                }
                
                System.debug('UploadId from response ==> ' + uploadId);
                system.debug('Response Body ------> '+res.getBody());
                system.debug('Response Status code------> '+res.getStatusCode());
                system.debug('Response Status------> '+res.getStatus());
                
                uploadmultipart(EncodingUtil.base64Encode(attach.VersionData),attach.Title,attach.FileExtension,uploadId);
                
            } catch (Exception e) {
                System.debug('In the catch block of UploadDocuments ==>');
                System.debug('--Line number ==>' + e.getLineNumber() + '-- Message ==>' + e.getMessage());
                System.debug(e);
            }
        }
    }
    
    public void uploadmultipart(String body,String fileName,String fileE, String uploadid){
        System.debug('uploadmultipart');
        Integer chunkSize = 7 * 1024 * 1024; // 5 MB
		//Blob fileBlob = ;// get the file blob to be uploaded
        //Integer totalChunks = integer.valueOf(Math.ceil(fileBlob.size() / chunkSize));
        Integer totalChunks = Integer.valueOf(Math.ceil(Decimal.valueOf(body.length()).divide(chunkSize, /*digits*/ 1)));
        
        String presignedUrl = '';
        
        Integer partNumber =1;
        for (Integer i = 0; i < totalChunks; i++) {
            presignedUrl = 'callout:aws_s3/esta-conseil/' + fileName + '.' + fileE + '?partNumber=' + partNumber + '&uploadId=' + uploadid;
            Integer chunkStart = i * chunkSize;
            Integer chunkEnd = Math.min((i + 1) * chunkSize - 1, body.length() - 1);
            Integer chunkLength = chunkEnd - chunkStart + 1;
            
            System.debug(Limits.getHeapSize());
            System.debug(Limits.getLimitHeapSize());
            if(i== (totalChunks-1)){
                uploadFileToAWSD.submethod(presignedUrl,chunkStart,chunkEnd,body,body.length(),partNumber,fileName,fileE,true,uploadid);
            }else{
                uploadFileToAWSD.submethod(presignedUrl,chunkStart,chunkEnd,body,body.length(),partNumber,fileName,fileE,false,uploadid);
            }
            partNumber++;   
        }   
    }
    
    @future(callout=true)
    public static void submethod(String url,Integer start,Integer endd,String body,Integer sizeFile,Integer i,String fileName,String FileExe,Boolean flag,String uploadId){
        //String attachmentBody = EncodingUtil.base64Encode(body);
        //Blob chunkBlob = EncodingUtil.base64Decode(attachmentBody.mid(start, endd));
        //Blob chunkBlob = EncodingUtil.base64Decode(EncodingUtil.base64Encode(body).mid(start, endd+1));
        System.debug('Start->'+start+'-'+endd);   
        System.debug('->'+Limits.getHeapSize());
        System.debug('->'+Limits.getLimitHeapSize());
        //System.debug(EncodingUtil.base64Encode(body));
        System.debug('->'+Limits.getHeapSize());
        /*Blob chunkBlob;
        for(String c: new List<String>{EncodingUtil.base64Encode(body)}){
            system.debug('hola');
            chunkBlob = EncodingUtil.base64Decode(c);
        }*/
        String StringBody = body.substring(start, endd+1);
        Blob chunkBlob = EncodingUtil.base64Decode(StringBody);
        System.debug('->'+Limits.getHeapSize());
        
        
        HttpRequest request = new HttpRequest();
        request.setMethod('PUT');
        request.setEndpoint(url);
        request.setBodyAsBlob(chunkBlob);        
        Http http = new Http();
        HTTPResponse response = http.send(request);
        if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
            String headerEtag = response.getHeader('ETag');
            System.debug('Chunk ' + i + ' uploaded successfully');
            System.debug(headerEtag);
        } else {
            System.debug('Error uploading chunk ' + i + ': ' + response.getBody());
        }
        
        if(flag){
            completeFile(fileName,FileExe,uploadId,i);
        }
        
    }
    
    public static void completeFile(String filename,String fileExtansion,String uploadId,Integer i){
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        String endPoint = 'callout:aws_s3/esta-conseil/' + filename + '.' + fileExtansion + '?max-parts='+i+'&part-number-marker='+0+'&uploadId='+uploadId;
        request.setEndpoint(endpoint);
        Http requesthttp = new Http();
        HTTPResponse response = requesthttp.send(request);
        System.debug(response.getStatus()+'-'+response.getStatusCode());
        System.debug(response.getBody());
        String s = response.getBody();
        
        Boolean tracker = true;
        List<String> eTagList = new List<String>();
        While(tracker){
            String refString = s.substringBetween('<Part>','</Part>');
            System.debug(refString);
            if(refString != null && refString != ''){
                eTagList.add(refString.subStringBetween('<ETag>&quot;','&quot;</ETag>'));
                s = s.replace('<Part>'+refString+'</Part>','');
            }else{
                tracker = false;
            }
        }
        System.debug(eTagList);
       
        
        String body = '';
//        body += '<?xml version="1.0" encoding="UTF-8"?><CompleteMultipartUpload>';
		body += '<CompleteMultipartUpload>';
        for(Integer ii = 0;ii<eTagList.size();ii++){
            body += '<Part><PartNumber>'+Integer.valueOf(ii+1)+'</PartNumber><ETag>"'+eTagList[ii]+'"</ETag></Part>';
        }    
        body += '</CompleteMultipartUpload>';
        system.debug(body);
        
        HttpRequest reqCmp = new HttpRequest();
        reqCmp.setMethod('POST');
        reqCmp.setEndpoint('callout:aws_s3/esta-conseil/' + filename + '.' + fileExtansion + '?uploadId=' + uploadId);
        //reqCmp.setHeader('Content-Type', 'application/xml');
        reqCmp.setHeader('Content-Type', 'text/plain');
        reqCmp.setBody(body);
        Http httpCmp = new Http();
        HTTPResponse resCmp = httpCmp.send(reqCmp);
        
        System.debug(resCmp.getStatus());
        System.debug(resCmp.getStatusCode());
        System.debug(resCmp.getBody());
    }   
}