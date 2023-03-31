global class MassUpdateRecord implements Database.Batchable<sObject>,Database.Stateful {

    global String succID = '';
    global String errId = '';

   
    global Database.QueryLocator start(Database.BatchableContext bc) {
         if(test.isRunningTest()){
            return Database.getQueryLocator([SELECT ID, Couronne__c , Technical_Comments__c FROM Ligne__c WHERE Couronne__c ='CCM' OR Couronne__c = 'EMAX' OR Couronne__c ='CCZ' OR Couronne__c ='Full Zr Multilayer' OR Couronne__c='Céramo-métallique' OR Couronne__c ='Céramique monolithique (hors zircone)' OR Couronne__c='Céramo-céramique' OR Couronne__c='Céramique monolithique Zircone' LIMIT 10]);
         }
        else{
            return Database.getQueryLocator([SELECT ID, Couronne__c ,Technical_Comments__c FROM Ligne__c WHERE Couronne__c ='CCM' OR Couronne__c = 'EMAX' OR Couronne__c ='CCZ' OR Couronne__c ='Full Zr Multilayer' OR Couronne__c='Céramo-métallique' OR Couronne__c ='Céramique monolithique (hors zircone)' OR Couronne__c='Céramo-céramique' OR Couronne__c='Céramique monolithique Zircone']);
        }
    }
    
    global void execute(Database.BatchableContext bc, List<Ligne__c> records){
        try {

            for(Ligne__c ling : records){
                if(ling.Couronne__c == 'CCM' || ling.Couronne__c == 'Céramo-métallique'){
                    ling.Couronne__c = 'CCM : Céramo-métallique';
                    ling.Technical_Comments__c = 'CCM : Céramo-métallique';
                }
                if(ling.Couronne__c == 'EMAX' || ling.Couronne__c == 'Céramique monolithique (hors zircone)'){
                    ling.Couronne__c = 'EMAX : Céramique monolithique (hors zircone)';
                    ling.Technical_Comments__c = 'EMAX : Céramique monolithique (hors zircone)';
                }
                if(ling.Couronne__c == 'CCZ' || ling.Couronne__c == 'Céramo-céramique'){
                    ling.Couronne__c = 'CCZ : Céramo-céramique';
                    ling.Technical_Comments__c = 'CCZ : Céramo-céramique';
                }
                if(ling.Couronne__c == 'Full Zr Multilayer' || ling.Couronne__c == 'Céramique monolithique Zircone'){
                    ling.Couronne__c = 'Full Zr Multilayer : Céramique monolithique Zircone';
                    ling.Technical_Comments__c = 'Full Zr Multilayer : Céramique monolithique Zircone';
                }
                succID = succID + ling.ID + '\n';
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