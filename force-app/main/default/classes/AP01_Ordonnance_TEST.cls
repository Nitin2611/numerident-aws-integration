@isTest
private class AP01_Ordonnance_TEST {
    
    static testMethod void methodName(){
        Ordonnance__c Ord = new Ordonnance__c();
        Ord.Name = 'Test';
        insert Ord;
        Boolean bool1 = AP01_Ordonnance.updateOrdonnanceAboutRating(Ord.Id, -3, 5);
        Boolean bool2 = AP01_Ordonnance.updateOrdonnanceAboutRating(Ord.Id, 1, 5);
        Boolean bool3 = AP01_Ordonnance.updateOrdonnanceAboutChoiceOfRating(Ord.Id, 'Autre', 'Test');
        Ordonnance__c ord1 = AP01_Ordonnance.getRatingById(Ord.Id);
        String choix = AP01_Ordonnance.getChoiceById(Ord.Id);
    }
    
    static testMethod void triggerUpdateOrdonnance(){
        Map<String,ID> profiles = new Map<String,ID>();

    	List<Profile> ps = [select id, name from Profile where name like 'Numerident%'];

        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }
    
        UserRole Role = [Select Id from Userrole where DeveloperName='HQ'];
    
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
        
        System.runAs(admin) {
            Test.startTest();

            Ordonnance__c Ord1 = new Ordonnance__c();
            Ord1.Name = 'updateTrigger';
            Ord1.Statut__c = 'Reçue';
            insert Ord1;
            Ord1.Rating__c = 5;
            update Ord1;
            Test.stopTest();

            /*Ordonnance__c Ord2 = new Ordonnance__c();
            Ord2.Name = 'updateTrigger';
            Ord2.Statut__c = 'Reçue';
            insert Ord2;
            Ord2.Statut__c = 'Expédiée';
            update Ord2; */       
        }
    }
}