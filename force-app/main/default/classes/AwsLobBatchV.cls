global class AwsLobBatchV implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext bc) {    
        return Database.getQueryLocator([SELECT VersionData,Title,ContentDocumentId,FileExtension,contentsize FROM ContentVersion]);
    }
    global void execute(Database.BatchableContext bc, List<ContentVersion> records){
        NamedCredential named=[SELECT DeveloperName, Endpoint FROM NamedCredential where DeveloperName='aws_s3'];
        for(ContentVersion attach:records) {
            try {
                Decimal abc = EncodingUtil.base64Encode(attach.VersionData).length();
                String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
                String filename = attach.Title;
                String fileExtansion = attach.FileExtension;
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
                uploadmultipart(attach,uploadId, abc);
            } catch (Exception e) {
                handleAwsException.LogException(e);
            }
        }
    }

    global void finish(Database.BatchableContext bc){

    }
    
    public void uploadmultipart(ContentVersion attach, String uploadid, Decimal abc) {
        try {
            Integer chunkSize = 7 * 1024 * 1024; // 5 MB
            Blob fileBlob = attach.VersionData;// get the file blob to be uploaded
            //Integer totalChunks = integer.valueOf(Math.ceil(fileBlob.size() / chunkSize));\
            // Decimal abc = EncodingUtil.base64Encode(fileBlob).length();
            System.debug('File length----->' + abc);
            Integer totalChunks = integer.valueOf(Math.ceil(abc.divide(chunkSize, /*digits*/ 10)));
            String presignedUrl = '';
            Integer partNumber =1;
            for (Integer i = 0; i < totalChunks; i++) {
                presignedUrl = 'callout:aws_s3/test-mv-1/' + attach.Title + '.' + attach.FileExtension + '?partNumber=' + partNumber + '&uploadId=' + uploadid;
                Integer chunkStart = i * chunkSize;
                Integer chunkEnd = Math.min((i + 1) * chunkSize - 1, integer.valueOf(abc) - 1);
                Integer chunkLength = chunkEnd - chunkStart + 1;


                System.debug('Start ---->' + chunkStart);
                System.debug('End ---->' + chunkEnd);


                // String attachmentBody = EncodingUtil.base64Encode(attach.VersionData).mid(chunkStart, 7 * 1024 * 1024);
                // System.debug('attachmentBody-->'+attachmentBody);
                // Blob chunkBlob = EncodingUtil.base64Decode(attachmentBody);
                Blob chunkBlob = EncodingUtil.base64Decode(EncodingUtil.base64Encode(attach.VersionData).mid(chunkStart, 7 * 1024 * 1024));


                if(i== (totalChunks-1)) {
                    submethod(presignedUrl,chunkStart,chunkEnd,chunkBlob,fileBlob.size(),partNumber,attach.Title,attach.FileExtension,true,uploadid);

                } else {
                    system.debug( 'ELSEE : Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
                    submethod(presignedUrl,chunkStart,chunkEnd,chunkBlob,fileBlob.size(),partNumber,attach.Title,attach.FileExtension,false,uploadid);
                }
                partNumber++;
            }   
        } catch (Exception e) {
            handleAwsException.LogException(e);
        }
    }

    // @future(callout=true)
    public void submethod(String url,Integer start,Integer endd,Blob body,Integer sizeFile,Integer i,String fileName,String FileExe,Boolean flag,String uploadId) {
        
        // String attachmentBody = EncodingUtil.base64Encode(body);
        // // Blob chunkBlob = EncodingUtil.base64Decode(attachmentBody.mid(start, endd));

        // System.debug('Start ---->' + start);
        // System.debug('End ---->' + endd);


        // // String attachmentBody = EncodingUtil.base64Encode(body).substring(start, endd + 1);
        // // System.debug('attachmentBody-->'+attachmentBody);
        // // Blob chunkBlob = EncodingUtil.base64Decode(attachmentBody);
        // // Blob chunkBlob = EncodingUtil.base64Decode(EncodingUtil.base64Encode(body).substring(start, endd + 1));

        // String attachmentBody = EncodingUtil.base64Encode(body).mid(start, 7 * 1024 * 1024);
        // System.debug('attachmentBody-->'+attachmentBody);
        // Blob chunkBlob = EncodingUtil.base64Decode(attachmentBody);
        // // System.debug('chunkBlob-->'+chunkBlob);
        // // System.debug('chunkBlob-->'+chunkBlob.size());

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
        
        if(flag){
            System.debug('Final Chunk Value ---> ' + i + 'String value of i ' + String.valueOf(i));
            completeFile(fileName,FileExe,uploadId, String.valueOf(i));
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
    }
}