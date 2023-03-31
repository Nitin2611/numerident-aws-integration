trigger PRG_OppLineItem on OpportunityLineItem (before update,after insert,after update,after undelete,after delete) {
	if (trigger.isbefore){
	    if(trigger.new.size()==1){
    		if(userInfo.getUserType()=='Standard'){
    			if(trigger.new[0].IdOrdonnance__c != null){
	    			Ligne_de_commande__c L = new Ligne_de_commande__c();
    				L.ID = trigger.new[0].Ligne_de_commande__c;
    				if (trigger.new[0].Ligne_de_commande__c == null){
	    				L.Ordonnance__c = trigger.new[0].IdOrdonnance__c;
    				}
    				L.Produit__c = trigger.new[0].Product2Id; 
    				L.Quantite__c = trigger.new[0].Quantity;
    				upsert L;
    				trigger.new[0].Ligne_de_commande__c = L.ID;  
    			}
    		}
    	}
	}else{
		if(trigger.isdelete){
			List<Id> Ids = new List<Id>();
			for (OpportunityLineItem Oppli:trigger.old){
				Ids.Add(Oppli.Id);
			}
			PRG_Mirroring.DeleteOppLineItems(Ids);
		}else{
			List<Id> Ids = new List<Id>();
			for (OpportunityLineItem Oppli:trigger.new){
				Ids.Add(Oppli.Id);
			}
			PRG_Mirroring.MirrorOppLineItems(Ids);
		}
	}
}