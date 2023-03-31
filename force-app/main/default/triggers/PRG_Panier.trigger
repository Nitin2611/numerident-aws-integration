trigger PRG_Panier on Panier__c (before insert,before update,after update) {
    if(trigger.isbefore){
        if(trigger.isupdate){
            List<Id> Ids = new List<Id>();
            List<Id> IdLivres = new List<Id>();
            for(Panier__c P:trigger.new){
                if((P.statut__c == 'A expédier')&&(trigger.oldmap.get(P.ID).statut__c == 'Vérif OK')){
                    P.statut__c = 'Expédié';
                    Ids.Add(P.Id);
                }
                if((P.statut__c == 'Livré')&&(trigger.oldmap.get(P.ID).statut__c != 'Livré')){
                    IdLivres.Add(P.Id);
                }
            }
            if(Ids.size()>0){
                List<Opportunity> Opps = [Select Id,StageNAme from Opportunity where panier__c in :Ids];
                for(Opportunity Opp:Opps){
                    Opp.stagename = 'Expédié';
                }
                if (Opps.size()>0){
                    update Opps;
                }
            }
            if(IdLivres.size()>0){
                List<Opportunity> Opps = [Select Id,StageNAme from Opportunity where panier__c in :IdLivres and stagename = 'Expédié'];
                for(Opportunity Opp:Opps){
                    Opp.stagename = 'Livré au client';
                }
                if (Opps.size()>0){
                    update Opps;
                }
            }
        }else{
		    if(trigger.new.size()==1){
    		    if(trigger.new[0].Compte__c == null){
        			List<AggregateResult> Opps = [Select AccountId from Opportunity where Mode_de_livraison__c='J+1' and StageName='En cours de vérification' group by AccountId];
            	    if(Opps.Size()>0){
    					trigger.new[0].Compte__c = (Id)Opps[0].get('AccountId') ;
	                	List<Panier__c> Ps = new List<Panier__c>();
	                    boolean first = true;
    	                for(AggregateResult Opp:Opps){
        	                if(!first){
            	                Panier__c P = new Panier__c();
                	            P.Compte__c = (Id)Opp.get('AccountId') ;
                    	        P.Date__c = trigger.new[0].Date__c;
                        	    Ps.Add(P);
	                        }else{
								first = false;                            
        	                }
            	        }
                	    if(Ps.size()>0){
                    	    insert Ps;
                    	}
                	}
        		}
    		}
        }
    }else{
        map<ID,ID> mapAccs = new map<Id,Id>();
        for(Panier__c P:trigger.new){
            mapAccs.put(P.Compte__c,P.ID);
        }
        List<Opportunity> Opps = [Select Id,AccountId,Panier__c from Opportunity where Mode_de_livraison__c='J+1' and StageName='En cours de vérification' and AccountId in :mapAccs.keyset() and panier__c=null];
        for(Opportunity Opp:Opps){
            Opp.Panier__c = mapAccs.get(Opp.AccountId);
        }
        if(opps.size()>0){
            update Opps;
        }
    }
}