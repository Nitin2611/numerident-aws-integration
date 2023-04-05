global class AwsLobBatchV2 implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext bc) {    
        return Database.getQueryLocator(
            // [SELECT VersionData, Title, ContentDocumentId, FileExtension, contentsize FROM ContentVersion ORDER BY contentsize ASC]
            [SELECT VersionData, Title, ContentDocumentId, FileExtension, contentsize FROM ContentVersion ORDER BY contentsize DESC]
            // [SELECT VersionData, Title, ContentDocumentId, FileExtension, contentsize FROM ContentVersion WHERE Id = '068Aa000000IUndIAG']
        );
    }

    global void execute(Database.BatchableContext bc, List<ContentVersion> records){
        NamedCredential named=[SELECT DeveloperName, Endpoint FROM NamedCredential where DeveloperName='aws_s3'];
        for(ContentVersion attach:records) {
            try {
                Decimal lengthOfFile = EncodingUtil.base64Encode(attach.VersionData).length();
                String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
                // String filename = attach.Title;
                // Replacing special character and white space from titls of files.
                // String filename = attach.Title.replaceAll('[^a-zA-Z0-9]','');
                String filename = attach.Title.replaceAll('[^a-zA-Z0-9-]','');
                System.debug(' File Name ==> ' + filename);
                String fileExtansion = attach.FileExtension;

                if (attach.contentsize < (11 * 1024 * 1024)) {
                    uploadObject(filename, fileExtansion, attach.VersionData);
                } else {
                    HttpRequest req = new HttpRequest();
                    req.setMethod('POST');
                    req.setHeader('Content-Type', 'application/octet-stream');
                    req.setEndpoint('callout:aws_s3/test-mv-1/' + filename + '.' + fileExtansion + '?uploads' );
                    
                    Http http = new Http();
                    HTTPResponse res = http.send(req);
                    
                    String uploadId = '';
                    String responseBody = res.getBody();
                    if (responseBody != null && responseBody.contains('UploadId')) {
                        uploadId = responseBody.substringBetween('<UploadId>', '</UploadId>');
                    }
                    AwsLobBatchV2.uploadmultipart(attach, uploadId, lengthOfFile, filename, fileExtansion);
                }

            } catch (Exception e) {
                System.debug('In the catch block of UploadDocuments ==>');
                System.debug('--Line number ==>' + e.getLineNumber() + '-- Message ==>' + e.getMessage());
                System.debug(e);
            }
        }
    }

    global void finish(Database.BatchableContext bc){

    }
    
    public static void uploadmultipart(ContentVersion attach, String uploadid, Decimal lengthOfFile, String filename, String fileExtansion) {

        Integer chunkSize = 8 * 1000 * 1000; // 5 MB

        // Blob fileBlob = attach.VersionData;// get the file blob to be uploaded
        System.debug('File length----->' + lengthOfFile);
        Integer totalChunks = integer.valueOf(Math.ceil(lengthOfFile.divide(chunkSize, /*digits*/ 10)));
        String presignedUrl = '';
        Integer partNumber =1;
        System.debug('totalChunks size ==>' + totalChunks);


        for (Integer i = 0; i < totalChunks; i++) {
            presignedUrl = 'callout:aws_s3/test-mv-1/' + filename + '.' + fileExtansion + '?partNumber=' + partNumber + '&uploadId=' + uploadid;
            Integer chunkStart = i * chunkSize;
            Integer chunkEnd = Math.min((i + 1) * chunkSize - 1, integer.valueOf(lengthOfFile) - 1);
            Integer chunkLength = chunkEnd - chunkStart + 1;


            System.debug('Start ---->' + chunkStart);
            System.debug('End ---->' + chunkEnd);

            System.debug('* Heap size current ==> ' + Limits.getHeapSize());
            System.debug('* Heap size Limit ==> ' + Limits.getLimitHeapSize());

            // String attachmentBody = EncodingUtil.base64Encode(attach.VersionData).mid(chunkStart, chunkSize);
            // System.debug('attachmentBody-->'+attachmentBody);
            // Blob chunkBlob = EncodingUtil.base64Decode(attachmentBody);
            Blob chunkBlob = EncodingUtil.base64Decode(EncodingUtil.base64Encode(attach.VersionData).mid(chunkStart, chunkSize));

            System.debug(' Heap size current ==> ' + Limits.getHeapSize());
            System.debug(' Heap size Limit ==> ' + Limits.getLimitHeapSize());

            if(i== (totalChunks-1)) {
	            AwsLobBatchV2.submethod(presignedUrl, chunkStart, chunkEnd, chunkBlob, partNumber, filename, fileExtansion, true, uploadid);

            } else {
                system.debug( 'ELSEE : Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
	            AwsLobBatchV2.submethod(presignedUrl, chunkStart, chunkEnd, chunkBlob, partNumber, filename, fileExtansion, false, uploadid);
            }
            partNumber++;
        }
    }

    // @future(callout=true)
    public static void submethod(String url, Integer start, Integer endd, Blob body, Integer i, String fileName, String FileExe, Boolean flag, String uploadId) {
        System.debug('A');
        HttpRequest request = new HttpRequest();
        request.setMethod('PUT');
        request.setEndpoint(url);
        request.setBodyAsBlob(body);

        System.debug('B');
        
        Http http = new Http();
        HTTPResponse response = http.send(request);
        if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
            System.debug('response-->' + response);
            String headerEtag = response.getHeader('ETag');
            System.debug('headerEtag-->' + headerEtag);

            System.debug('Chunk ' + i + ' uploaded successfully');
            system.debug(response.getBody());
        } else {
            System.debug('Error uploading chunk ' + i + ': ' + response.getBody());
        }
        system.debug('*** getCpuTime() ==> ' + Limits.getCpuTime());
        
        if(flag){
            System.debug('Final Chunk Value ---> ' + i + 'String value of i ' + String.valueOf(i));
            AwsLobBatchV2.completeFile(fileName,FileExe,uploadId, String.valueOf(i));
        }
    }

    public static void completeFile(String filename,String fileExtansion,String uploadId, String maxPart) {

        HttpRequest reqLs = new HttpRequest();
        reqLs.setMethod('GET');
        reqLs.setEndpoint('callout:aws_s3/test-mv-1/' + filename + '.' + fileExtansion + '?uploadId=' + uploadId + '&max-parts=' + maxPart + '&part-number-marker=0');
        
        Http httpLs = new Http();
        HTTPResponse resLs = httpLs.send(reqLs);
        String responseBody = resLs.getBody();

        String etagListStr = '';
        if (responseBody != null && responseBody.contains('UploadId')) {
            etagListStr = responseBody.substringBetween('</IsTruncated>', '</ListPartsResult>');
        }
        
        Boolean tracker = true;
        Map<String, String> eTagMap = new Map<String, String>();
        While(tracker){
            String refPartString = etagListStr.substringBetween('<Part>','</Part>');
            String refPartNumberString = etagListStr.substringBetween('<Part>','</Part>');
            System.debug(refPartString);
            if(refPartString != null && refPartString != ''){
                eTagMap.put(refPartNumberString.subStringBetween('<PartNumber>','</PartNumber>') ,refPartString.subStringBetween('<ETag>&quot;','&quot;</ETag>'));
                etagListStr = etagListStr.replace('<Part>' + refPartString + '</Part>','');
                etagListStr = etagListStr.replace('<PartNumber>' + refPartNumberString + '</PartNumber>','');
            }else{
                tracker = false;
            }
        }
        System.debug('eTagMap ==>' + eTagMap);
        
        HttpRequest reqCmp = new HttpRequest();
        reqCmp.setMethod('POST');
        reqCmp.setEndpoint('callout:aws_s3/test-mv-1/' + filename + '.' + fileExtansion + '?uploadId=' + uploadId);

        String body = '';
        body += '<CompleteMultipartUpload>';
        for(String i: eTagMap.keySet()){
            body += '<Part><PartNumber>'+i+'</PartNumber><ETag>'+eTagMap.get(i)+'</ETag></Part>';
        }
        body += '</CompleteMultipartUpload>';
        system.debug('body ==>' + body);
        reqCmp.setBody(body);
        
        Http httpCmp = new Http();
        HTTPResponse resCmp = httpCmp.send(reqCmp);
        
        system.debug('Status code httpCmp------> '+resCmp.getStatusCode());
        system.debug('Status httpCmp------> '+resCmp.getStatus());
        system.debug('Body httpCmp------> '+resCmp.getBody());
    }

    public void uploadObject(String filename, String fileExtansion, Blob body) {
        try {
            HttpRequest reqObj = new HttpRequest();
            reqObj.setMethod('PUT');
            reqObj.setBodyAsBlob(body);
            reqObj.setEndpoint('callout:aws_s3/test-mv-1/' + filename + '.' + fileExtansion);
            
            Http httpObj = new Http();
            HTTPResponse resObj = httpObj.send(reqObj);
            System.debug('resObj Body ==>' + resObj.getBody() + ' - res Status Code ==> ' + resObj.getStatusCode() + ' - res Status ==> ' + resObj.getStatus());

            if (resObj.getStatusCode() == 200 || resObj.getStatusCode() == 201) {
                System.debug('File uploaded successfully');
            } else {
                System.debug('Error on uploading fiels');
            }
            
        } catch (Exception e) {
            System.debug('In the catch block of uploadObject ==>');
            System.debug('--Line number ==>' + e.getLineNumber() + '-- Message ==>' + e.getMessage());
            System.debug(e);
        }
    }
}