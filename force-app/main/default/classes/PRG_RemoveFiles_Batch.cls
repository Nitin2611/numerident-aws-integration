global class PRG_RemoveFiles_Batch implements Database.Batchable<sObject>, Database.Stateful{
    private integer nbmois=2;
    
    public PRG_RemoveFiles_Batch(integer pOffset) {
        nbmois = pOffset;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
		datetime dt=datetime.now().addmonths(-nbmois);
		datetime dtmin=dt.addmonths(-1);
        String query = 'Select Id from Opportunity where (createddate<:dt and createddate>=:dtmin) and (StageName=\'Facturé\' or StageName=\'Rejeté\') limit 10000'; 
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
		List<Id> Ids = new List<Id>();
		List<Ordonnance__c> Ords = [Select Id from Ordonnance__c where Dossier__c in :scope];
		for(Ordonnance__c Ord:Ords){
    		Ids.Add(Ord.Id);
		}
		Ids.Add(scope[0].Id);
		List<ContentDocumentLink> Lks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId in :Ids];
		List<Id> LIds = new List<Id>();
		for(ContentDocumentLink Lk:Lks){
    		LIds.Add(Lk.ContentDocumentId);
		}
		List<ContentDocument> CD = [SELECT Id,ContentSize from ContentDocument where Id in :LIds and ContentSize > 4000000 and LastModifiedDate<:datetime.now().addmonths(-2)]; 
		delete CD;    
	}   

    global void finish(Database.BatchableContext BC) {
    }
}