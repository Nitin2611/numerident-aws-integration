trigger PRG_Opportunite on Opportunity (before update, before insert,after update) {
	if(trigger.isafter){
		List<Id> Ids = new List<Id>(); 
		for (Opportunity Opp:trigger.new){
			if(Opp.Statut_de_facturation__c == null){
				Ids.Add(Opp.Id);
			}
		}
		if(Ids.size()>0){
			PRG_Ordonnance.UpdateStatutOrdonnance(Ids);
		}
	}
    if (trigger.new.size() == 1){
    	if (trigger.isafter){
    		if(trigger.new[0].Ordonnance__c != null){
    			Ordonnance__c Ord = new Ordonnance__c();
    			Ord.ID = trigger.new[0].Ordonnance__c;
    			Ord.Teinte__c = trigger.new[0].Teinte__c;
    			//Ord.Statut__c = trigger.new[0].Statut_ordonnace__c;
    			try{
    				update Ord;
    			}catch (Exception e){}
    		}
            if((trigger.oldmap.get(trigger.new[0].ID).stageName != 'En transit vers l\'usine')&&(trigger.new[0].stageName == 'En transit vers l\'usine')&&(trigger.new[0].Type_d_empreinte__c == 'Numérique')&&(trigger.new[0].PartageUsine__c!=null)){
    			try{
	             	PRG_Ordonnance.SendDigitalEmail(trigger.new[0]);
    			}catch (Exception e){}
            }
    	}else{
    	if(trigger.new[0].Reception__c){
    		trigger.new[0].Reception__c = false;
            if(UserInfo.getUserType() == 'Standard'){
	    		trigger.new[0].Prothesiste__c = UserInfo.getUserId();
            }
/*        	List<Ordonnance__c> Ords = [Select Id,Statut__c from Ordonnance__c where Id = :trigger.new[0].Ordonnance__c];
        	if(Ords.size()==1){
        		Ords[0].Statut__c = 'En cours de traitement';
        		update Ords[0];
        	}*/
    	}
    	if(trigger.new[0].AccountId == null){
    		List<Contact> Cs = [Select Id,AccountId from Contact where ID=:trigger.new[0].Praticien__c];
    		if(Cs.size()==1){
    			trigger.new[0].AccountId  = Cs[0].AccountId;
    		}
    	}
        List<Aggregateresult> OppLis = [Select Product2.Usine__c Usine from OpportunityLineItem where OpportunityId= :trigger.new[0].Id and Product2.Usine__c <> null group by Product2.Usine__c];
        if (Opplis.size() == 1){
        	if(trigger.new[0].Usine__c == null){
	            trigger.new[0].Usine__c = (Id)Opplis[0].get('Usine');
        	}
        }
        if(trigger.isinsert){
            List<Account> Accs = [Select Id,Catalogue_de_prix__c from account where Id=:trigger.new[0].AccountId];
            List<PriceBook2> StdCat = [Select Id from PriceBook2 where IsActive=true and IsStandard=true];
            if(Accs.size()==1){
                if(Accs[0].Catalogue_de_prix__c != null){
                    trigger.new[0].PriceBook2Id = Accs[0].Catalogue_de_prix__c;
                }else{
                	if (!Test.IsRunningTest()){
	                    trigger.new[0].PriceBook2Id = StdCat[0].Id;
                	}
                }
            }
        }
        if(trigger.new[0].Date_de_r_ception_de_l_empreinte__c !=null){
        	trigger.new[0].Matin__c = ((trigger.new[0].Date_de_r_ception_de_l_empreinte__c.hour()) <13);
        }else{
        	trigger.new[0].Matin__c = ((datetime.now().hour()) <13);
        }
        if(trigger.new[0].Tracabilite__c){
        	List<OpportunityLineItem> OppsLis = [Select Product2.Id from OpportunityLineItem where OpportunityId = :trigger.new[0].Id];
        	List<Id> PId = new List<Id>();
        	for (OpportunityLineItem OppLi:OppsLis){
        		PId.Add(OppLi.Product2.Id);
        	} 
        	List<Lien_produit_materiau__c> LPMs = [Select Id,Mat_riau__c,Produit__c,Mat_riau__r.Num_ro_de_lot__c,Mat_riau__r.Num_ro_CE__c 
        			from Lien_produit_materiau__c 
        			where Produit__c in :PId and (Mat_riau__r.Teinte__c = :trigger.new[0].Teinte__c or Mat_riau__r.Teinte__c = null) ];
        	List<Tracabilite__c> Ts = new List<Tracabilite__c>();
        	for(Lien_produit_materiau__c LPM:LPMs){
        		Tracabilite__c T = new Tracabilite__c();
        		T.Ordonnance__c = trigger.new[0].Ordonnance__c;
        		T.Produit__c = LPM.Produit__c;
        		T.Num_ro_de_lot__c = LPM.Mat_riau__r.Num_ro_de_lot__c;
        		T.Materiau__c = LPM.Mat_riau__c; 
        		Ts.Add(T);
        	}
        	if (Ts.size()>0){
        		insert Ts;
        	}
        }}
    }
}