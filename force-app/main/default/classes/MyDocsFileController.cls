public without sharing class MyDocsFileController {

    @AuraEnabled
    public static Id createRecord(String fileName, Integer contentSize, String fileUrl, String fileExt, String recordId){
        try{
            MyDocsFile__c file = new MyDocsFile__c(
                ContentSize__c=contentSize, 
                FileExtension__c=fileExt,
                FileName__c=fileName,
                FileUrl__c=fileUrl
            );
            if(recordId.startsWith('006')){
                Opportunity opp = [SELECT Id, Ordonnance__c FROM Opportunity WHERE Id = :recordId];
                file.Opportunity__c=opp.Id;
                // file.Ordonnance__c=opp.Ordonnance__c;
            }
            else{
                Ordonnance__c ord = [SELECT Id, Dossier__c FROM Ordonnance__c WHERE Id = :recordId];
                file.Ordonnance__c=ord.Id;
                file.Opportunity__c=ord.Dossier__c;
            }
            insert file;
            return file.Id;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean isEditable(String recordId) {
        if(recordId.startsWith('a0i')){
            List<Ordonnance__c> ords = [SELECT Id, Statut__c FROM Ordonnance__c WHERE Id = :recordId];
            System.debug('Size: '+ords.size());
            System.debug('Status: '+ords.get(0).Statut__c);
            if(ords.size() > 0 && ords.get(0).Statut__c != 'Brouillon'){
                System.debug('Not editable');
                return false;
            }
        }
        return true;   
    }

    @AuraEnabled
    public static AWS_Setting__mdt getAwsSetting(){
        List<AWS_Setting__mdt> settings = AWS_Setting__mdt.getAll().values();
        if(settings.size() > 0){
            return settings[0];
        }
        return null;
    }

    @AuraEnabled
    public static MyDocsFile__c getRecord(String recordId){
        MyDocsFile__c record = [SELECT Id, FileName__c, FileUrl__c, Name FROM MyDocsFile__c WHERE Id = :recordId LIMIT 1];
        return record;
    }

    public class MyDocsS3Exception extends Exception {}
}