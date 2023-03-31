trigger PRG_OffreDetail on sofactoapp__Offre__c (after update) {
	List<Id> Ids = new List<Id>();
	List<Id> OppIds = new List<Id>();
	List<Id> OppliIds = new List<Id>();
	for (sofactoapp__Offre__c O:trigger.new){
		if ((Trigger.oldMap.get(O.Id).sofactoapp__Etat__c != O.sofactoapp__Etat__c)&&(O.sofactoapp__Etat__c == 'Envoyée')){
			Ids.Add(O.Id);
		}
	}
	List<sofactoapp__Poste_offre__c> Ps = [Select sofactoapp__OppLineItemId__c from sofactoapp__Poste_offre__c where sofactoapp__Offre__c in :Ids];
	for (sofactoapp__Poste_offre__c P:Ps){
		if(P.sofactoapp__OppLineItemId__c != null){
			OppliIds.Add(P.sofactoapp__OppLineItemId__c);
		}
	}    
	List<OpportunityLineItem> Opplis = [Select opportunityId from OpportunityLineItem 
										where id in :OppliIds and opportunity.Statut_de_facturation__c = 'En préparation'];
	for(OpportunityLineItem Oppli:Opplis){
		OppIds.Add(Oppli.opportunityId);
	}
	List<Opportunity> Opps = [Select Id,Statut_de_facturation__c,StageName from Opportunity where Id in :OppIds];
	for (Opportunity Opp:Opps){
		Opp.Statut_de_facturation__c = 'Facturé';
		Opp.StageName = 'Facturé';
	}
	if(Opps.size()>0){
		update Opps;
	}
}