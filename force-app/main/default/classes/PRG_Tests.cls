/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class PRG_Tests {

    static testMethod void OppFlowTest1() {
      Map<String,ID> profiles = new Map<String,ID>();
      List<Profile> ps = [select id, name from Profile where name like 'Numerident%'];

      for(Profile p : ps){
         profiles.put(p.name, p.id);
      }
    
        UserRole Role = [Select Id from Userrole where DeveloperName='HQ'];
    
      User standard = new User(alias = 'standt', 
      email='standarduser@testorgnumerident.com', 
      emailencodingkey='UTF-8', 
      lastname='Testing', languagelocalekey='fr', 
      localesidkey='fr', 
      profileid = profiles.get('Numerident Standard'), 
      timezonesidkey='Europe/Paris', 
      UserRoleId=Role.Id,
      username='standarduser@testorgnumerident.com');
      insert standard;  

      User admin = new User(alias = 'admin', 
      email='adminuser@testorgnumerident.com', 
      emailencodingkey='UTF-8', 
      lastname='Testing', languagelocalekey='fr', 
      localesidkey='fr', 
      profileid = profiles.get('Numerident Admin'), 
      timezonesidkey='Europe/Paris', 
      UserRoleId=Role.Id,
      username='adminuser@testorgnumerident.com');
      insert admin; 
        
      User usine = new User(alias = 'usine', 
      email='usineuser@testorgnumerident.com', 
      emailencodingkey='UTF-8', 
      lastname='Testing', languagelocalekey='en_US', 
      localesidkey='en_US', 
      profileid = profiles.get('Numerident Usine'), 
      timezonesidkey='America/Los_Angeles', 
      UserRoleId=Role.Id,
      username='usineuser@testorgnumerident.com');
      insert usine; 

        Opportunity Opp = new Opportunity();
    
    system.runas(admin){
        Id pricebookId = Test.getStandardPricebookId();
        
        Account Acc = new Account();
        Acc.NAme = 'Centre';
        insert Acc;
        
        Opp.AccountId = Acc.ID;
        Opp.CloseDate = date.today();
        Opp.Date_d_exp_dition__c = date.today().addDays(-10);
        Opp.StageName = 'Envoyé au laboratoire';
        Opp.Name = 'Test';
        Opp.PriceBook2ID = pricebookId;
        insert Opp;
    }
    
      system.runas(usine){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('Envoyé au laboratoire',Opp.StageName);
      }
      system.runas(admin){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('En cours de traitement',Opp.StageName);
      }
      
      system.runas(standard){
        Opp.StageName = 'Livré au client';
        update Opp;
      }
        
      system.runas(usine){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('Livré au client',Opp.StageName);
      }
      system.runas(standard){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('Livré au client',Opp.StageName);
        Opp.StageName = 'Facturé';
        update Opp;
      }
        
      system.runas(usine){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('Facturé',Opp.StageName);
      }
      system.runas(standard){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('Facturé',Opp.StageName);
        Opp.StageName = 'Réglé';
        update Opp;
      }
        
      system.runas(usine){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('Réglé',Opp.StageName);
      }
      system.runas(standard){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('Réglé',Opp.StageName);
        Opp.StageName = 'Rejeté';
        update Opp;
      }

      system.runas(usine){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('Rejeté',Opp.StageName);
      }
      system.runas(standard){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('Rejeté',Opp.StageName);
      }

        
    }

    static testMethod void OppFlowTest2() {
      Map<String,ID> profiles = new Map<String,ID>();
      List<Profile> ps = [select id, name from Profile where name like 'Numerident%'];

      for(Profile p : ps){
         profiles.put(p.name, p.id);
      }
    
        UserRole Role = [Select Id from Userrole where DeveloperName='HQ'];
    
      User standard = new User(alias = 'standt', 
      email='standarduser@testorgnumerident.com', 
      emailencodingkey='UTF-8', 
      lastname='Testing', languagelocalekey='fr', 
      localesidkey='fr', 
      profileid = profiles.get('Numerident Standard'), 
      timezonesidkey='Europe/Paris', 
      UserRoleId=Role.Id,
      username='standarduser@testorgnumerident.com');
      insert standard;  

      User admin = new User(alias = 'admin', 
      email='adminuser@testorgnumerident.com', 
      emailencodingkey='UTF-8', 
      lastname='Testing', languagelocalekey='fr', 
      localesidkey='fr', 
      profileid = profiles.get('Numerident Admin'), 
      timezonesidkey='Europe/Paris', 
      UserRoleId=Role.Id,
      username='adminuser@testorgnumerident.com');
      insert admin; 
        
      User usine = new User(alias = 'usine', 
      email='usineuser@testorgnumerident.com', 
      emailencodingkey='UTF-8', 
      lastname='Testing', languagelocalekey='en_US', 
      localesidkey='en_US', 
      profileid = profiles.get('Numerident Usine'), 
      timezonesidkey='America/Los_Angeles', 
      UserRoleId=Role.Id,
      username='usineuser@testorgnumerident.com');
      insert usine; 

        Opportunity Opp = new Opportunity();
    
    system.runas(admin){
        Id pricebookId = Test.getStandardPricebookId();
        
        Account Acc = new Account();
        Acc.NAme = 'Centre';
        insert Acc;
        
        Opp.AccountId = Acc.ID;
        Opp.CloseDate = date.today();
        Opp.Date_d_exp_dition__c = date.today().addDays(-10);
        Opp.StageName = 'Validé';
        Opp.Name = 'Test';
        Opp.PriceBook2ID = pricebookId;
        insert Opp;
    }
    
      system.runas(usine){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('Validé',Opp.StageName);
      }
      system.runas(standard){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('En cours de traitement',Opp.StageName);
      }
      
      system.runas(usine){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('En cours de traitement',Opp.StageName);
      }
      system.runas(standard){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('En cours de traitement',Opp.StageName);
        Opp.StageName = 'En transit vers l\'usine';
        update Opp;
      }
      
      system.runas(standard){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('En transit vers l\'usine',Opp.StageName);
      }
      system.runas(usine){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('En cours de fabrication',Opp.StageName);
      }

      system.runas(standard){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('En cours de fabrication',Opp.StageName);
      }
      system.runas(usine){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('En transit vers le labo',Opp.StageName);
      }
        
      system.runas(usine){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('En cours de fabrication',Opp.StageName);
      }
      system.runas(usine){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('En transit vers le labo',Opp.StageName);
      }

    }

    static testMethod void OppFlowTest3() {
      Map<String,ID> profiles = new Map<String,ID>();
      List<Profile> ps = [select id, name from Profile where name like 'Numerident%'];

      for(Profile p : ps){
         profiles.put(p.name, p.id);
      }
    
        UserRole Role = [Select Id from Userrole where DeveloperName='HQ'];
    
      User standard = new User(alias = 'standt', 
      email='standarduser@testorgnumerident.com', 
      emailencodingkey='UTF-8', 
      lastname='Testing', languagelocalekey='fr', 
      localesidkey='fr', 
      profileid = profiles.get('Numerident Standard'), 
      timezonesidkey='Europe/Paris', 
      UserRoleId=Role.Id,
      username='standarduser@testorgnumerident.com');
      insert standard;  

      User admin = new User(alias = 'admin', 
      email='adminuser@testorgnumerident.com', 
      emailencodingkey='UTF-8', 
      lastname='Testing', languagelocalekey='fr', 
      localesidkey='fr', 
      profileid = profiles.get('Numerident Admin'), 
      timezonesidkey='Europe/Paris', 
      UserRoleId=Role.Id,
      username='adminuser@testorgnumerident.com');
      insert admin; 
        
      User usine = new User(alias = 'usine', 
      email='usineuser@testorgnumerident.com', 
      emailencodingkey='UTF-8', 
      lastname='Testing', languagelocalekey='en_US', 
      localesidkey='en_US', 
      profileid = profiles.get('Numerident Usine'), 
      timezonesidkey='America/Los_Angeles', 
      UserRoleId=Role.Id,
      username='usineuser@testorgnumerident.com');
      insert usine; 

        Opportunity Opp = new Opportunity();
    
    system.runas(admin){
        Id pricebookId = Test.getStandardPricebookId();
        
        Account Acc = new Account();
        Acc.NAme = 'Centre';
        insert Acc;
        
        Opp.AccountId = Acc.ID;
        Opp.CloseDate = date.today();
        Opp.Date_d_exp_dition__c = date.today().addDays(-10);
        Opp.StageName = 'En cours de fabrication';
        Opp.Name = 'Test';
        Opp.Mode_de_livraison__c = 'J+1';
        Opp.PriceBook2ID = pricebookId;
        insert Opp;
    }
    
      system.runas(usine){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('En transit vers le labo',Opp.StageName);
      }

      system.runas(standard){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('En cours de vérification',Opp.StageName);
      }
      system.runas(usine){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('En cours de vérification',Opp.StageName);
          Panier__c P = new Panier__c();
          P.Name = 'Panier du jour';
          insert P;
      }
        
      system.runas(standard){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('Expédié',Opp.StageName);
      }
      system.runas(usine){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('Expédié',Opp.StageName);
      }
        
      system.runas(standard){
        PRG_Scan.OppURL('Test');
        Opp = [Select Id,StageName from Opportunity where Id=:Opp.Id];
        System.assertEquals('Expédié',Opp.StageName);
      }
        
        
    }
    
    static testMethod void fullSimpleTest() {
        Product2 prod = new Product2(Name = 'Test', ProductCode = 'DIVERS');
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;        

        Account Acc = new Account();
        Acc.NAme = 'Centre';
        insert Acc;
        
        Account Usine = new Account();
        Usine.Name = 'Usine';
        Usine.Type = 'Partner';
        insert Usine;
        
        Opportunity Opp = new Opportunity();
        Opp.AccountId = Acc.ID;
        Opp.Usine__c = Usine.ID;
        Opp.CloseDate = date.today();
        Opp.Date_d_exp_dition__c = date.today().addDays(-10);
        Opp.StageName = 'En cours de traitement';
        Opp.Name = 'Test';
        Opp.Mode_de_livraison__c = 'J+1';
        Opp.PriceBook2ID = pricebookId;
        insert Opp;

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 5,
            PricebookEntryId = standardPrice.Id,
            TotalPrice = 5 * standardPrice.UnitPrice
        );
        insert oli;
        
        PRG_Scan.OppURL('Test');
        
        Expedition__c Exp = new Expedition__c();
        Exp.Destinataire__c = Usine.ID;
        insert Exp;
        
        Exp.Envoi_des_emails__c = true;
        update Exp;
        
        Retour__c Ret = new Retour__c();
        Ret.Name = 'Test';
        Ret.Code__c='CCM : Céramo-métallique';
        Ret.Quantite__c = 2;
        insert Ret;
        
        Opp.Statut_de_facturation__c = 'En préparation';
        update Opp;
        
        sofactoapp__Raison_Sociale__c RS = new sofactoapp__Raison_Sociale__c();
        RS.Name = 'Test';
        RS.sofactoapp__Credit_prefix__c = 'FC{!AAAA}';
        RS.sofactoapp__Invoice_prefix__c = 'AV{!AAAA}';
        insert RS;
        
        RS.D_but_de_p_riode__c = date.today();
        RS.Fin_de_p_riode__c = date.today();
        RS.Preparer_la_facturation__c = true;
        update RS;
        
        Ordonnance__c Ord = new Ordonnance__c();
        Ord.Name = 'Test';
        insert Ord;

		ContentVersion contentVersion = new ContentVersion(
  		Title = 'TESTS',
  		PathOnClient = 'TESTS.DCM',
  		VersionData = Blob.valueOf('Test Content'),
  		IsMajorVersion = true
		);
		insert contentVersion;    
		List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
		ContentDocumentLink cdl = New ContentDocumentLink();
		cdl.LinkedEntityId = Ord.id;
		cdl.ContentDocumentId = documents[0].Id;
		cdl.shareType = 'V';
		insert cdl;
        delete cdl;

        Ord.Statut__c = 'Envoyée au labo';
        update Ord;

        sofactoapp__Factures_Client__c Fac = new sofactoapp__Factures_Client__c();
        Fac.sofactoapp__Compte__c = Acc.Id;
        Fac.sofactoapp__emetteur_facture__c = RS.Id;
        insert Fac;

        Ligne_de_commande__c LC = new Ligne_de_commande__c();
        LC.Ordonnance__c = Ord.Id;
        insert LC;

        Ligne__c Li = new Ligne__c();
        Li.Ordonnance__c = Ord.Id;
        insert Li;
        
        Case C = new Case();
        C.AccountId = Acc.Id;
        insert C;
        
        PRG_Utils.Couverture();
        PRG_Utils.Couverture2();
        PRG_Utils.Couverture3();
        PRG_Utils.Couverture4();
        PRG_Utils.Couverture5();
        PRG_Utils.Couverture6();
    }
}