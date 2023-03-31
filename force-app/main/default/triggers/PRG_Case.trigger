trigger PRG_Case on Case (after update,after insert,before insert,before update) {
	if (trigger.isbefore){
        for(case C:trigger.new){
        }
	    if(trigger.new.size() == 1){
    		if(trigger.new[0].Ordonnance__c != null){
    			List<Opportunity> Opps = [Select Id,Praticien__c,AccountId from Opportunity where Ordonnance__c =:trigger.new[0].Ordonnance__c];
    			if(Opps.size() == 1){
    				trigger.new[0].Dossier__c = Opps[0].Id;
    			}		
    		}
    		if(trigger.new[0].Dossier__c != null){
    			List<Opportunity> Opps = [Select Praticien__c,AccountId,Ordonnance__c,CreatedDate from Opportunity where Id =:trigger.new[0].Dossier__c];
    			if(Opps.size() == 1){
            		if(string.isBlank(trigger.new[0].hash__c)){
        				String salt = string.valueOf(Opps[0].CreatedDate);
        				String key = Opps[0].Id;
        				Blob data = crypto.generateMac('HmacSHA256',Blob.valueOf(salt), Blob.valueOf(key));
        				trigger.new[0].hash__c = EncodingUtil.convertToHex(data);                
            		}
    				trigger.new[0].AccountId = Opps[0].AccountId;
    				trigger.new[0].ContactId = Opps[0].Praticien__c;
                    trigger.new[0].Ordonnance__c = Opps[0].Ordonnance__c;
    			}		
    		}
    		if((trigger.new[0].Fixed_by__c == null)&&(trigger.new[0].Status == 'Fixed')){ 
    			trigger.new[0].Fixed_by__c = userinfo.getuserid();
    		}
	    }
	}else{
	    if(trigger.new.size() == 1){
    		if((trigger.new[0].Dossier__c != null)&&((trigger.new[0].RecordTypeId=='0120Y000000NLxJ')||(trigger.new[0].RecordTypeId=='0120Y000000NLxK')||(trigger.new[0].RecordTypeId=='0120Y000000NLxL'))){
    			Opportunity Opp = new opportunity();
    			Opp.Id = trigger.new[0].Dossier__c; 
    			if(trigger.new[0].RecordTypeId=='0120Y000000NLxJ'){
    				/*if(trigger.isinsert){
	    				Opp.En_attente__c = true;
	    				update Opp; 
    				}else{
	    				if(trigger.new[0].Status == 'Fermée'){
		    				Opp.En_attente__c = false;
		    				update Opp; 
    					}
    				}*/
    			}else{
	    			if(trigger.new[0].Status == 'Nouveau'){
    					Opp.Probleme__c = 'Problème en cours';	
    				}
    				if(trigger.new[0].Status == 'En cours'){
    					Opp.Probleme__c = 'Problème en cours';	
	    			}
    				if(trigger.new[0].Status == 'On Hold'){
    					Opp.Probleme__c = 'Problème en attente';	
    				}
    				if(trigger.new[0].Status == 'Fermée'){
    					Opp.Probleme__c = 'Problème résolu';	
    				}
    				update Opp; 
    			}
    		}
    	}
	}
}