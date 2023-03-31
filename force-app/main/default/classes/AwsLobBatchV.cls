global class AwsLobBatchV implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext bc) {

        /* Custom setting 
            List<Aws_Handler__c> awshandler = [select id , start_size__c, end_size__c from Aws_Handler__c  where isActive__c = true LIMIT 1];
            Integer startsize = Integer.valueOf(awshandler[0].start_size__c);
            Integer endsize = Integer.valueOf(awshandler[0].end_size__c);
            System.debug('awshandler'+ awshandler);
            List<ContentVersion> cvs =[SELECT id ,VersionData,Title,ContentDocumentId,FileExtension,contentsize FROM ContentVersion WHERE contentsize >: startsize AND contentsize <: endsize ];
            System.debug(cvs);
        */
        // return Database.getQueryLocator([SELECT Id FROM USer WHERE Id ='005Aa000001IMCxIAO' ]); // user configured

        //return Database.getQueryLocator([SELECT VersionData,Title,ContentDocumentId,FileExtension,contentsize FROM ContentVersion WHERE contentsize >= start_size__c or contentsize < end_size__c]);
        //return Database.getQueryLocator([SELECT VersionData,Title,ContentDocumentId,FileExtension,contentsize FROM ContentVersion WHERE Id =:'068Aa000000I0ZRIA0' ]); // 100 MB file
        // return Database.getQueryLocator([SELECT VersionData,Title,ContentDocumentId,FileExtension,contentsize FROM ContentVersion WHERE Id=: '068Aa000000HzofIAC' ]); // 30 MB file
        // return Database.getQueryLocator([SELECT VersionData,Title,ContentDocumentId,FileExtension,contentsize FROM ContentVersion WHERE Id !=:'068Aa000000HginIAC' AND Id !=:'068Aa000000I0ZRIA0' ]);

        return Database.getQueryLocator([SELECT VersionData,Title,ContentDocumentId,FileExtension,contentsize FROM ContentVersion WHERE Id = '068Aa000000Hhq9IAC' ]); //OR Id = '068Aa000000I6IHIA0'

    }
    global void execute(Database.BatchableContext bc, List<ContentVersion> records){
    // global void execute(Database.BatchableContext bc, List<User> records){

        NamedCredential named=[SELECT DeveloperName, Endpoint FROM NamedCredential where DeveloperName='aws_s3'];
        // for(ContentVersion attach:[SELECT VersionData,Title,ContentDocumentId,FileExtension,contentsize, FirstPublishLocationId FROM ContentVersion WHERE FirstPublishLocationId = :records[0].Id]) {
        for(ContentVersion attach:records) {
            try {
                String filename = attach.Title;
                String fileExtansion = attach.FileExtension; 
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/octet-stream');
                req.setEndpoint('callout:aws_s3/test-mv-1/' + filename + '.' + fileExtansion + '?uploads' );
                Http http = new Http();
                HTTPResponse res = http.send(req);
                String uploadId = '';
                // String responseBody = res.getBody();
                if (res.getBody() != null && res.getBody().contains('UploadId')) {
                    uploadId = res.getBody().substringBetween('<UploadId>', '</UploadId>');
                }
                Integer chunkSize = 7 * 1024 * 1024;
                Decimal base64strlen = EncodingUtil.base64Encode(attach.VersionData).length();
            
                System.debug('base64strlen---->'+ base64strlen);
                Integer totalChunks = integer.valueOf(Math.ceil(base64strlen.divide(chunkSize,10)));
                String presignedUrl = '';
                Integer partNumber =1;

                system.debug( 'A : Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());

                for (Integer i = 0; i < totalChunks; i++) {

                    presignedUrl = 'callout:aws_s3/test-mv-1/' + attach.Title + '.' + attach.FileExtension + '?partNumber=' + partNumber + '&uploadId=' + uploadid;
                    Integer chunkStart = i * chunkSize;
                    Integer chunkEnd = Math.min((i + 1) * chunkSize - 1, integer.valueOf(base64strlen) - 1);
                    Integer chunkLength = chunkEnd - chunkStart + 1;

                    system.debug('B : Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
                    Blob chunkBlob = EncodingUtil.base64Decode(EncodingUtil.base64Encode(attach.VersionData).substring(chunkStart, chunkEnd + 1));

                    HttpRequest request = new HttpRequest();
                    request.setMethod('PUT');
                    request.setEndpoint(presignedUrl);
                    request.setBodyAsBlob(EncodingUtil.base64Decode(EncodingUtil.base64Encode(attach.VersionData).substring(chunkStart, chunkEnd + 1)));


                    chunkBlob = null ;

                    system.debug('C : Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());

                    Http http2 = new Http();
                    HTTPResponse response = http.send(request);
                    if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                        System.debug('response-->' + response);
                        String headerEtag = response.getHeader('ETag');
                    } else {
                        System.debug('Error uploading chunk ' + i + ': ' + response.getBody());
                    }
                    if(i== (totalChunks-1)){
                        System.debug('Final Chunk Value ---> ' + i + 'String value of i ' + String.valueOf(i));
                        completeFile(attach.Title,attach.FileExtension,uploadId, String.valueOf(i));
                    }
                    partNumber++;
                }
                // uploadmultipart(attach,uploadId);
            } catch (Exception e) {
                System.debug('Batch Error');
                System.debug('--Line number ==>' + e.getLineNumber() + '-- Message ==>' + e.getMessage());
                handleAwsException.LogException(e);
            }
        }
    }
    global void finish(Database.BatchableContext bc){

    }

    // public void uploadmultipart(ContentVersion attach, String uploadid) {

    //     Integer chunkSize = 7 * 1024 * 1024;
    //     Decimal base64strlen = EncodingUtil.base64Encode(attach.VersionData).length();
    //     System.debug('base64strlen---->'+ base64strlen);
    //     Integer totalChunks = integer.valueOf(Math.ceil(base64strlen.divide(chunkSize,10)));
    //     String presignedUrl = '';
    //     Integer partNumber =1;

    //     for (Integer i = 0; i < totalChunks; i++) {
    //         presignedUrl = 'callout:aws_s3/test-mv-1/' + attach.Title + '.' + attach.FileExtension + '?partNumber=' + partNumber + '&uploadId=' + uploadid;
    //         Integer chunkStart = i * chunkSize;
    //         Integer chunkEnd = Math.min((i + 1) * chunkSize - 1, integer.valueOf(base64strlen) - 1);
    //         Integer chunkLength = chunkEnd - chunkStart + 1;
    //         if(i== (totalChunks-1)) {
	//             submethod(presignedUrl,chunkStart,chunkEnd,attach.VersionData,partNumber,attach.Title,attach.FileExtension,true,uploadid);

    //         } else {
	//             submethod(presignedUrl,chunkStart,chunkEnd,attach.VersionData,partNumber,attach.Title,attach.FileExtension,false,uploadid);
    //         }
    //         partNumber++;
    //     }
    // }
    // public void submethod(String url,Integer start,Integer endd,Blob body,Integer i,String fileName,String FileExe,Boolean flag,String uploadId) {
        
    //     String attachmentBody = EncodingUtil.base64Encode(body).substring(start, endd + 1);
    //     Blob chunkBlob = EncodingUtil.base64Decode(attachmentBody);

    //     HttpRequest request = new HttpRequest();
    //     request.setMethod('PUT');
    //     request.setEndpoint(url);
    //     request.setBodyAsBlob(chunkBlob);
        
    //     Http http = new Http();
    //     HTTPResponse response = http.send(request);
    //     if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
    //         System.debug('response-->' + response);
    //         String headerEtag = response.getHeader('ETag');
    //     } else {
    //         System.debug('Error uploading chunk ' + i + ': ' + response.getBody());
    //     }
    //     if(flag){
    //         System.debug('Final Chunk Value ---> ' + i + 'String value of i ' + String.valueOf(i));
    //         completeFile(fileName,FileExe,uploadId, String.valueOf(i));
    //     }
    // }

    public static void completeFile(String filename,String fileExtansion,String uploadId, String maxPart) {

        try{

            System.debug(1/0);

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
            reqCmp.setBody(body);
            Http httpCmp = new Http();
            HTTPResponse resCmp = httpCmp.send(reqCmp);        
            system.debug('Status code httpCmp------> '+resCmp.getStatusCode());
            system.debug('Status httpCmp------> '+resCmp.getStatus());
        }
        catch (Exception e){
            handleAwsException.LogException(e);
        }
    }
}