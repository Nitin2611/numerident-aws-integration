trigger PRG_Retour on Retour__c (before insert) {
    List<string> ListId = new List<string>();
    for (Retour__c Ret:trigger.new){
        ListID.Add(Ret.Name);
    }
    map<string,Opportunity> mapOpps = new map<string,Opportunity>();
    list<Opportunity> Opps = [Select Id,Non_conforme__c,StageName,Name from Opportunity where Name in :ListId];
    for (Opportunity Opp:Opps){
            Opp.StageName = 'En cours de vérification';
            mapOpps.put(Opp.Name,Opp);
        }
    list<OpportunityLineItem> OppLis = [Select Id,Opportunity.Name,OpportunityId,Quantity,ProductCode,ShippingList__c,Product2.Name,nbDents__c, 
    									Product2.Product_name__c, Product2.Autres_traductions__c
    									from OpportunityLineItem 
                                        where Opportunity.Name in :ListId and Opportunity.ForecastCategory = 'Commit'];
    integer i = 2;
    for (Retour__c Ret:trigger.new){
	    boolean trouve = false;
	    if(Ret.TEETH__c == 'U/L'){
	    	Ret.Quantite__c = 2; 
	    }
	    if((Ret.TEETH__c == 'U')||(Ret.TEETH__c == 'L')){
	    	Ret.Quantite__c = 1;
	    }
	    for (OpportunityLineItem OppLi:OppLis){
	    	if((string.isblank(Oppli.ShippingList__c))&&(!trouve)){
		    	if(OppLi.Opportunity.Name == ret.Name){
		    		Set<string> AutresTraductions = new Set<string>();
		    		if(!string.isblank(Oppli.Product2.Autres_traductions__c)){
		    			for(string s:Oppli.Product2.Autres_traductions__c.split(';')){
		    				AutresTraductions.Add(s);	
		    			}
		    		}
			    	if((OppLi.Product2.Product_name__c == ret.Code__c)||(AutresTraductions.contains(ret.Code__c))){
				    	if((OppLi.Quantity == ret.Quantite__c)||(OppLi.nbDents__c == ret.Quantite__c)){
	    					OppLI.ShippingList__c = 'OK';
	    					OppLi.ShippingList_content__c = 'Line ' + i + ' : ' + Ret.Name + ',' + Ret.Code__c + ',' + Ret.Quantite__c ;
	    					Ret.Match__c = true;
	    					Ret.Full_match__c = true;
	    					Ret.Dossier__c = OppLi.OpportunityId;
	    					Ret.IdPoste__c = OppLi.Id;
	    					trouve = true;
				    	}else{
	    					OppLI.ShippingList__c = 'Quantité différente';
	    					OppLi.ShippingList_content__c = 'Line ' + i + ' : ' + Ret.Name + ',' + Ret.Code__c + ',' + Ret.Quantite__c ;
	    					Ret.Match__c = true;
	    					Ret.Full_match__c = false;
	    					Ret.Dossier__c = OppLi.OpportunityId;
	    					Ret.IdPoste__c = OppLi.Id;
	    					mapOpps.get(OppLi.Opportunity.Name).Non_conforme__c= true;
	    					trouve = true;
				    	}
			    	}
		    	}
	    	}
	    }
	    i++;
    }
    for (OpportunityLineItem OppLi:OppLis){
    	if(string.isblank(Oppli.ShippingList__c)){
	    	OppLI.ShippingList__c = 'Inexistant dans la shipping list';
			mapOpps.get(OppLi.Opportunity.Name).Non_conforme__c= true;
    	}
    }
    i = 2;
    for (Retour__c Ret:trigger.new){
    	Ret.Ligne__c = i;
    	i++;
    	if(!Ret.Match__c){
    		if(mapOpps.containskey(ret.Name)){
				Ret.Dossier__c = mapOpps.get(ret.Name).Id;
    		}
    	}
    }
    if(Opplis.size()>0){
    	update OppLis;
    }
    if(Opps.size()>0){
        update Opps;
    }
}