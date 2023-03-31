global class TypeMassUpdate implements Database.Batchable<sObject>,Database.Stateful {

    global String succID = '';
    global String errId = '';

    global Database.QueryLocator start(Database.BatchableContext bc) {
        if(test.isRunningTest()){
	        return Database.getQueryLocator([SELECT ID, Couronne__c , Type__c , Technical_Comments__c FROM Ligne__c WHERE Type__c ='CCM' OR Type__c = 'EMAX' OR Type__c ='CCZ' OR Type__c ='Full Zr Multilayer' OR Type__c='Céramo-métallique' OR Type__c ='Céramique monolithique (hors zircone)' OR Type__c='Céramo-céramique ' OR Type__c='Céramique monolithique Zircone' LIMIT 10 ]);            
        }else{
            return Database.getQueryLocator([SELECT ID, Couronne__c , Type__c , Technical_Comments__c FROM Ligne__c WHERE Type__c ='CCM' OR Type__c = 'EMAX' OR Type__c ='CCZ' OR Type__c ='Full Zr Multilayer' OR Type__c='Céramo-métallique' OR Type__c ='Céramique monolithique (hors zircone)' OR Type__c='Céramo-céramique ' OR Type__c='Céramique monolithique Zircone' ]);            
        }

    }
    global void execute(Database.BatchableContext bc, List<Ligne__c> records){
        try {
            for(Ligne__c lign : records){

                // Update Ligne type__c picklist value                 
                if(lign.Type__c == 'CCM' || lign.Type__c == 'Céramo-métallique'){
                    lign.Type__c = 'CCM : Céramo-métallique';
                    lign.Technical_Comments__c = 'CCM : Céramo-métallique';
                }
                if(lign.Type__c == 'EMAX' || lign.Type__c == 'Céramique monolithique (hors zircone)'){
                    lign.Type__c = 'EMAX : Céramique monolithique (hors zircone)';
                    lign.Technical_Comments__c = 'EMAX : Céramique monolithique (hors zircone)';
                }
                if(lign.Type__c == 'CCZ' || lign.Type__c == 'Céramo-céramique'){
                    lign.Type__c = 'CCZ : Céramo-céramique';
                    lign.Technical_Comments__c = 'CCZ : Céramo-céramique';
                }
                if(lign.Type__c == 'Full Zr Multilayer' || lign.Type__c == 'Céramique monolithique Zircone'){
                    lign.Type__c = 'Full Zr Multilayer : Céramique monolithique Zircone';
                    lign.Technical_Comments__c = 'Full Zr Multilayer : Céramique monolithique Zircone';
                }
                succID = succID + lign.ID + '\n';
                System.debug('succID=->'+succID);
            }
            update records;

        } catch (Exception e) {
            errId = errId + e.getMessage() + e.getLineNumber() + '\n';
        }
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        System.debug('Completed');
        System.debug('errId : ' + errId);
        System.debug('succID : ' + succID);

        if(String.isNotBlank(errId)){
            System.debug('Inside if');
            try {
                Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();                                                            
                Blob csvblob = Blob.valueOf(errId);
                String csvName = 'Failed Records.csv';
                csvAttachment.setFileName(csvName);                
                csvAttachment.setBody(csvBlob);                                                      
            
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String exception_emails = 'ravi.m@mvclouds.com,vidit.s@mvclouds.com';
                String[] excepemails = exception_emails.split(',');                
                String[] toAddresses = new String[]{excepemails[0],excepemails[1]};
                Date d = Date.today();
                String subject =  d.day()+'/'+d.month()+'/'+d.year()+' - Failed Records';
                email.setSubject(subject);
                email.setToAddresses(toAddresses);
                email.setPlainTextBody('Hi,\nPlease find the list of Failed Records in below attached files.');
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            } catch (Exception e) {
                System.debug('Exception : ' + e.getMessage());
                System.debug('Exception : ' + e.getLineNumber());
            }
        } 
        if(String.isNotBlank(succID)){
            System.debug('Inside if');
            try {
                Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();                                                            
                Blob csvblob = Blob.valueOf(succID);
                String csvName = 'Success Records.csv';
                csvAttachment.setFileName(csvName);                
                csvAttachment.setBody(csvBlob);                                                      
            
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String exception_emails = 'ravi.m@mvclouds.com,vidit.s@mvclouds.com';
                String[] excepemails = exception_emails.split(',');                
                String[] toAddresses = new String[]{excepemails[0],excepemails[1]};
                Date d = Date.today();
                String subject =  d.day()+'/'+d.month()+'/'+d.year()+' - Success Records';
                email.setSubject(subject);
                email.setToAddresses(toAddresses);
                email.setPlainTextBody('Hi,\nPlease find the list of Success Records in below attached files.');
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            } catch (Exception e) {
                System.debug('Exception : ' + e.getMessage());
                System.debug('Exception : ' + e.getLineNumber());
            }
            
        } 
        
    }
}