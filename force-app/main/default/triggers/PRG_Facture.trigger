trigger PRG_Facture on sofactoapp__Factures_Client__c (after update,after insert) {
    for (sofactoapp__Factures_Client__c soF:trigger.new){
    	if (!string.isblank(soF.sofactoapp__Reference__c)){
    		Facture_client__c F = new Facture_client__c();
    		F.Date__c = soF.sofactoapp__Date_de_facture__c;
    		F.Name = soF.sofactoapp__Reference__c;
    		F.Montant__c = soF.sofactoapp__Amount_VAT__c;
    		if(soF.sofactoapp__Contact__c != null){
	    		List<User> U = [Select Id from User where ContactId =:soF.sofactoapp__Contact__c];
    			if (U.size() >0){
	    			F.OwnerId = U[0].Id;
    			}
    		}
    		F.Ref__c = soF.sofactoapp__Reference__c;
    		F.Solde__c = soF.sofactoapp__Solde_d__c;
    		upsert F Ref__c; 
    		if(soF.sofactoapp__Offre__c !=null){
	    		List<sofactoapp__Offre__c> Offres = [Select Id,Facture__c,sofactoapp__Etat__c from sofactoapp__Offre__c where sofactoapp__Etat__c != 'Envoyée'  
    												and (Id=:soF.sofactoapp__Offre__c or Projet_de_facture__c=:soF.sofactoapp__Offre__c)];
    			if(Offres.size()>0){
    				for(sofactoapp__Offre__c Offre:Offres){
    					Offre.Facture__c = soF.Id;
    					Offre.sofactoapp__Etat__c = 'Envoyée';
    				}
    				try{
    					update Offres;
    				}catch(Exception e){}
    			}
    		}
    	}
    }
}