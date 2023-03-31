trigger PRG_Ligne on Ligne__c (before insert, before delete) {
    System.debug('TRIGGER LIGNES__C');
    if (trigger.isdelete){
        for(Ligne__c l :trigger.old){
        	if((l.Validee__c)&&(UserInfo.getUserType() != 'Standard')){
	            l.adderror('La commande est validée, il est impossible de supprimer des lignes');
        	}
        }
        List<Ligne_de_commande__c> Cs = [Select Id from Ligne_de_commande__c where Ligne__c =:trigger.old[0].Id];
        if(CS.Size()>0){
        	delete Cs;
        }
    }else{
    	System.debug('TRIGGER LIGNES__C : Insert');
    	User U = [Select ContactId from User where Id=:UserInfo.GetUserId()];
    	System.debug('TRIGGER LIGNES__C : ' + U.ContactId);
    	If(U.ContactId != null){
	    	Contact C = [Select Maquillage_sillon__c,Type_de_pr_paration__c,Account.Accastillage__c ,Bandeau_m_tallique__c,Maquillage__c,Occlusion__c,Point_de_contact__c
	    				from Contact where Id=:U.ContactId];
	    	RecordType RT = [Select Id,DeveloperName from RecordType where Id = :trigger.new[0].RecordTypeId];
	    	System.debug('TRIGGER LIGNES__C : ' + RT.DeveloperName);
	    	System.debug('TRIGGER LIGNES__C : ' + C.Account.Accastillage__c);
	    	if ((RT.DeveloperName =='Couronne_sur_implants')&&(!string.isblank(C.Account.Accastillage__c))){
		    	trigger.new[0].Accastillage__c = C.Account.Accastillage__c;
	    	}
			trigger.new[0].Bandeau_m_tallique__c = C.Bandeau_m_tallique__c;
			trigger.new[0].Maquillage__c = C.Maquillage__c;
			trigger.new[0].Occlusion__c = C.Occlusion__c;
			trigger.new[0].Point_de_contact__c = C.Point_de_contact__c; 
			trigger.new[0].Maquillage_sillon__c = C.Maquillage_sillon__c;
			trigger.new[0].Type_de_pr_paration__c = C.Type_de_pr_paration__c;
    	}
/*        Set<String> valeurs = new Set<String>();
    
        for(Ligne__c l :trigger.new){
        
            if(l.Inlay_core__c != null)valeurs.addAll(l.Inlay_core__c.Split(';'));
            if(l.Dents_a_restorer__c != null)valeurs.addAll(l.Dents_a_restorer__c.Split(';'));
            if(l.Crochet_flexible__c != null)valeurs.addAll(l.Crochet_flexible__c.Split(';'));
            if(l.Crochet_Acetal__c != null)valeurs.addAll(l.Crochet_Acetal__c.Split(';'));
            if(l.Crochet_transparent__c != null)valeurs.addAll(l.Crochet_transparent__c.Split(';'));
            if(l.Dent_massive_ou_contreplaqu_e__c != null)valeurs.addAll(l.Dent_massive_ou_contreplaqu_e__c.Split(';'));
            if(l.Dents_a_extraire__c != null)valeurs.addAll(l.Dents_a_extraire__c.Split(';'));
            if(l.Dents_a_remplacer__c != null)valeurs.addAll(l.Dents_a_remplacer__c.Split(';'));
        
            l.Total_travaux__c = String.join(new list<string>(valeurs), ',');
        
        */
    }
}