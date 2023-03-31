public with sharing class PRG_Scan {

	@AuraEnabled
	public static string OppURL(string OppName) {
        List<Panier__c> Paniers = [Select Id,Statut__c from Panier__c where Name=:OppName];
        if(Paniers.size()>0){
            system.debug('UserType:' + userinfo.getUserType());
            if((userinfo.getUserType()=='CustomerSuccess')||(userinfo.getUserType()=='PowerCustomerSuccess')||(userinfo.getUserType()=='CspLitePortal')){ 
                Paniers[0].Statut__c = 'Livré';
                update Paniers[0];
            }
            return Paniers[0].id;
        }else{
        	List<Opportunity> Opps = [Select Id,Go_to_next_stage__c from Opportunity where Name =:OppName];
        	List<Profile> Ps = [select Name from Profile where id = :UserInfo.getProfileId()];
        	if (Opps.size() > 0){
        		Opps[0].Go_to_next_stage__c = true;
        		update Opps[0];
        		if(Ps.size()==1){
        			if(Ps[0].Name == 'Numerident Usine'){
		        		return '@' + Opps[0].id;
        			}else{
        				if(Ps[0].Name == 'Logistique'){
		        			return '|' + Opps[0].id;
        				}else{
		        			return Opps[0].id;
        				}
        			}
        		}else{
	        		return Opps[0].id;
        		}
        	}else{
        		List<Ordonnance__c> Ords = [Select Id,Statut__c from Ordonnance__c where Name =:OppName];
        		if(Ords.size()>0){
        			if(Ords[0].Statut__c == 'Validée'){
	        			Ords[0].Statut__c = 'Envoyée au labo';
        			}
        			if(Ords[0].Statut__c == 'Expédiée'){
	        			Ords[0].Statut__c = 'Reçue';
        			}
        			if(Ords[0].Statut__c == 'En cours de fabrication'){
	        			Ords[0].Statut__c = 'Reçue';
        			}
        			update Ords[0];
        			if(Ords[0].Statut__c != 'Reçue'){
	        			return 'Vous serez informés dès que nous recevrons votre commande';
        			}else{
        				return 'Nous avons enregistré réception de votre commandee';
        			}
        		}else{
		        	return '#';
    	    	}
        	}
    	}
	}
}