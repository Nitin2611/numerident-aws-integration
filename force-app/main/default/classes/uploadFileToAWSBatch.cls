global class uploadFileToAWSBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            // [SELECT Id, Title, VersionData, FileExtension, contentsize FROM ContentVersion WHERE Id = '068Aa000000Hhq9IAC' OR Id = '068Aa000000I6IHIA0']
            // [SELECT Id, Title, VersionData, FileExtension, contentsize FROM ContentVersion WHERE Id = '068Aa000000Hhq9IAC']
            // [SELECT Id, Title, VersionData, FileExtension, contentsize FROM ContentVersion WHERE Id = '068Aa000000I0ZRIA0']
            // [SELECT Id, Title, VersionData, FileExtension, contentsize FROM ContentVersion WHERE Id = '068Aa000000IJH7IAO']
            // [SELECT Id, Title, VersionData, FileExtension, contentsize FROM ContentVersion WHERE Id = '068Aa000000IJNZIA4']
            // [SELECT Id, Title, VersionData, FileExtension, contentsize FROM ContentVersion WHERE Id = '068Aa000000IJH7IAO']
            // [SELECT Id, Title, VersionData, FileExtension, contentsize FROM ContentVersion]
            // [SELECT Id, Title, VersionData, FileExtension, contentsize FROM ContentVersion WHERE Id = '068Aa000000HghBIAS' OR Id = '068Aa000000I6mvIAC']
            [SELECT Id, Title, VersionData, FileExtension, contentsize FROM ContentVersion ]
        );
    }

    global void execute(Database.BatchableContext bc, List<ContentVersion> records) {
        UploadDocuments(records);
    }

    global void finish(Database.BatchableContext bc){

    }

    public void UploadDocuments(List<ContentVersion> contentVersionsList) {
        NamedCredential named = [SELECT DeveloperName, Endpoint FROM NamedCredential where DeveloperName='aws_s3'];
        for(ContentVersion attach: contentVersionsList) {
            try {
                Integer lengthOfFile = EncodingUtil.base64Encode(attach.VersionData).Length();
                System.debug('*** lengthOfFile ==>' + lengthOfFile);

                // Creating Multipart Upload
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
                System.debug('UploadId from response ==> ' + uploadId);
                System.debug('Response Body ==> ' + res.getBody() + ' - Status code ==> ' + res.getStatusCode() + ' Status ==> ' + res.getStatus());
                
                uploadmultipart(attach, uploadId, lengthOfFile);
            } catch (Exception e) {
                System.debug('In the catch block of UploadDocuments ==>');
                System.debug('--Line number ==>' + e.getLineNumber() + '-- Message ==>' + e.getMessage());
                System.debug(e);
            }
        }
    }

    public static void uploadmultipart(ContentVersion attach, String uploadid, Integer lengthOfFile) {
        Integer chunkSize = 7 * 1000 * 1000; // 5 MB
        Integer totalChunks = integer.valueOf(Math.ceil(Decimal.valueOf(lengthOfFile).divide(chunkSize, /*digits*/ 8)));
        String presignedUrl = '';
        Integer partNumber = 1;
        System.debug('totalChunks size ==>' + totalChunks);

        for (Integer i = 0; i < totalChunks; i++) {
            System.debug('In the chunk for loop ==> ' + i);
            presignedUrl = 'callout:aws_s3/test-mv-1/' + attach.Title + '.' + attach.FileExtension + '?partNumber=' + partNumber + '&uploadId=' + uploadid;
            Integer chunkStart = i * chunkSize;
            Integer chunkEnd = Math.min((i + 1) * chunkSize - 1, attach.VersionData.size() - 1);
            
            System.debug(' * Heap size current ==> ' + Limits.getHeapSize());
            System.debug('* Heap size Limit ==> ' + Limits.getLimitHeapSize());

            System.debug('cn ** ==> ' + (totalChunks-1) + ' ** i ==>' + i);

            String attachmentBody = EncodingUtil.base64Encode(attach.VersionData).mid(chunkStart, chunkSize);
            System.debug('attachmentBody ==>' + attachmentBody);
            Blob chunkBlob = EncodingUtil.base64Decode(attachmentBody);

            // Blob chunkBlob = EncodingUtil.base64Decode(EncodingUtil.base64Encode(attach.VersionData).mid(chunkStart, chunkSize));

            if(i== (totalChunks-1)) {
	            // requestUploadMultiPart(presignedUrl, chunkStart, chunkEnd, attach.VersionData, partNumber, attach.Title, attach.FileExtension, true, uploadid, chunkSize);
	            uploadFileToAWSBatch.requestUploadMultiPart(presignedUrl, chunkStart, chunkEnd, chunkBlob, partNumber, attach.Title, attach.FileExtension, true, uploadid, chunkSize);
            } else {
                // requestUploadMultiPart(presignedUrl, chunkStart, chunkEnd, attach.VersionData, partNumber, attach.Title, attach.FileExtension, false, uploadid, chunkSize);
                uploadFileToAWSBatch.requestUploadMultiPart(presignedUrl, chunkStart, chunkEnd, chunkBlob, partNumber, attach.Title, attach.FileExtension, false, uploadid, chunkSize);
            }
            partNumber++;
        }
    }

    public static void requestUploadMultiPart(String url, Integer start, Integer endd, Blob body, Integer i, String fileName, String FileExe, Boolean flag, String uploadId, Integer chunkSize) {
        System.debug('** start ==>' + start + ' -- endd ==>' + endd);
        System.debug('Heap size current ==> ' + Limits.getHeapSize());
        System.debug('Heap size Limit ==> ' + Limits.getLimitHeapSize());
        System.debug('ChunkSize ==> ' + chunkSize);
        // System.debug('attachmentBody ==>'+attachmentBody);
        // Blob chunkBlob = EncodingUtil.base64Decode(EncodingUtil.base64Encode(body).mid(start, chunkSize));

        // String attachmentBody = EncodingUtil.base64Encode(body).mid(start, chunkSize);
        // System.debug(' ** Heap size current ==> ' + Limits.getHeapSize());
        // System.debug(' **Heap size Limit ==> ' + Limits.getLimitHeapSize());
        // System.debug('attachmentBody =>' + attachmentBody);
        // Blob chunkBlob = EncodingUtil.base64Decode(attachmentBody);

        // System.debug('Heap size current ==> ' + Limits.getHeapSize());
        // System.debug('Heap size Limit ==> ' + Limits.getLimitHeapSize());

        HttpRequest request = new HttpRequest();
        request.setMethod('PUT');
        request.setEndpoint(url);
        // request.setBodyAsBlob(chunkBlob);
        request.setBodyAsBlob(body);
        
        Http http = new Http();
        HTTPResponse response = http.send(request);
        Integer startLM = System.Now().millisecond();

        if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
            System.debug('response ==>' + response);
            String headerEtag = response.getHeader('ETag');
            System.debug('headerEtag-->' + headerEtag);
            System.debug('Chunk ' + i + ' uploaded successfully');
        } else {
            System.debug('Error uploading chunk ' + i + ': ' + response.getBody());
        }
        if(flag){
            uploadFileToAWSBatch.completeFile(fileName, FileExe, uploadId, String.valueOf(i));
        }
    }

    public static void completeFile(String filename, String fileExtansion, String uploadId, String maxPart) {
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

        HttpRequest reqCmp = new HttpRequest();
        reqCmp.setMethod('POST');
        reqCmp.setEndpoint('callout:aws_s3/test-mv-1/' + filename + '.' + fileExtansion + '?uploadId=' + uploadId);
        String body = '';
        body += '<CompleteMultipartUpload>';
        for(String i: eTagMap.keySet()){
            body += '<Part><PartNumber>'+i+'</PartNumber><ETag>'+eTagMap.get(i)+'</ETag></Part>';
        }
        body += '</CompleteMultipartUpload>';
        System.debug('body ==>' + body);
        reqCmp.setBody(body);

        Http httpCmp = new Http();
        HTTPResponse resCmp = httpCmp.send(reqCmp);        
        system.debug('Status code httpCmp ==> '+resCmp.getStatusCode() + 'Status ==> ' + resCmp.getStatus());
    }
}