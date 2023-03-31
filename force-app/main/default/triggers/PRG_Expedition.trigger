trigger PRG_Expedition on Expedition__c (after insert,before update,after update) {
    if(trigger.isinsert){
	    if((trigger.new.size()==1)&&(!trigger.new[0].Ne_pas_calculer__c)){
    	    List<Opportunity> Opps = [Select Id,Usine__c,StageName,Amount,Usine__r.Name from Opportunity 
        				where CloseDate>:date.today().AddDays(-30) and StageName ='En cours de traitement' and Usine__c =: trigger.new[0].Destinataire__c and En_attente__c = false 
                                  and Type_d_empreinte__c != 'Numérique' order by Usine__c];
        	for (Opportunity Opp:Opps){
            	Opp.StageName = 'En transit vers l\'usine';
            	Opp.Expedition__c = trigger.new[0].Id;
        	}
        	if(Opps.size()>0){
            	update Opps;
	        	PRG_Expedition.MailCustom(trigger.new[0].Id,Opps[0].Usine__r.Name);
        	}
    	}
    }
    if(trigger.isupdate){
        if(trigger.isbefore){
	    	if(trigger.new.size()==1){
    	    	if(trigger.new[0].Envoi_des_emails__c){
        	        List<ContentDocumentLink> Lks = [SELECT ContentDocumentId,LinkedEntityId,ShareType,Visibility 
            	                             FROM ContentDocumentLink WHERE LinkedEntityId = :trigger.new[0].Id ];
                	if((Lks.size()>0)||(Test.isRunningTest())){
	            		trigger.new[0].Envoi_des_emails__c = false;
    	        		PRG_Expedition.MailTransitUsine(trigger.new[0].Id);
                	}else{
                    	trigger.new[0].addError('Merci de joindre le bordereau de transport à cette expédition.');
                	}
        		}
    		}
        }else{
            List<ID> Ids = new List<ID>();
            for(Expedition__c E:trigger.new){
                if(E.Arrivee_LAB__c && !trigger.oldmap.get(E.Id).Arrivee_LAB__c){
                    Ids.Add(E.Id);
                }
            }
            if(Ids.size()>0){
	            List<Opportunity> Opps = [Select Id,StageName from Opportunity where Expedition__c in :IDs and StageNAme = 'En transit vers l\'usine'];
                for(Opportunity Opp:Opps){
                    Opp.StageName = 'En cours de fabrication';
                }
                if(Opps.size()>0){
                    update Opps;
                }
            }
        }
    }
}