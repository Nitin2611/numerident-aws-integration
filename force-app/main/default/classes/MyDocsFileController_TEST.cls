@isTest
class MyDocsFileController_TEST {

    @testSetup 
    static void setup() {
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Fabriquant').getRecordTypeId();
        Account acc = new Account(
            Name = 'TEST UNIT 1',
            recordTypeId = recordTypeId,
            Zone_de_livraison__c = 'Paris'
        );
        insert acc;
        // Opp
        Opportunity opp = new Opportunity(
            Name ='Test UNIT',
            AccountID = acc.ID,
            StageName = 'Customer Won',
            Amount = 3000,
            CloseDate = System.today()
        );
        insert opp; 
        // ordonnance Brouillon
        Ordonnance__c ord = new Ordonnance__c(
            Dossier__c = opp.Id,
            Statut__c = 'Brouillon'
        );
        insert ord;
        // Ordonnance Validée      
        Ordonnance__c ordValid = new Ordonnance__c(
            Dossier__c = opp.Id,
            Statut__c = 'Validée'
        );
        insert ordValid;
    }
    
    @isTest 
    static void TestCreateOppFile(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test UNIT'];
        Ordonnance__c ord = [SELECT Id FROM Ordonnance__c WHERE Dossier__c = :opp.Id AND Statut__c = 'Brouillon'];

        Id fileOrdoId = MyDocsFileController.createRecord('TEST', 1000, 'testURL', '.txt', ord.id);
        System.assertNotEquals(null, fileOrdoId);
        Id fileId = MyDocsFileController.createRecord('TEST Opp', 1000, 'testURL2', '.txt', opp.id);
        System.assertNotEquals(null, fileId);
        
        MyDocsFile__c file = MyDocsFileController.getRecord(fileId);
        System.assertEquals(fileId, file.Id);
    }
    
    @isTest 
    static void TestIsEditable(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test UNIT'];
        Ordonnance__c ord = [SELECT Id FROM Ordonnance__c WHERE Dossier__c = :opp.Id AND Statut__c = 'Brouillon'];
        Ordonnance__c ordValide = [SELECT Id FROM Ordonnance__c WHERE Dossier__c = :opp.Id AND Statut__c = 'Validée'];

        System.assertEquals(true, MyDocsFileController.isEditable(opp.Id));
        System.assertEquals(true, MyDocsFileController.isEditable(ord.Id));
        System.assertEquals(false, MyDocsFileController.isEditable(ordValide.Id));
    }

    @isTest 
    static void TestGetAwsSetting(){
        AWS_Setting__mdt settings = MyDocsFileController.getAwsSetting();
    }
}