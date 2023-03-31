trigger PRG_LigneCommande on Ligne_de_commande__c (before insert,before update) {
	try{
		User U = [Select Id,ContactId,Contact.Account.Zone_de_livraison__c from User where Id=:UserInfo.GetUserId()];
		if(U.ContactId != null){
			List<Id> Ids = new List<Id>();
			for(Ligne_de_commande__c L:trigger.new){
				Ids.Add(L.Produit__c);
			}
			map<Id,string> mapProduct = new map<Id,string>(); 
			List<Product2> Ps = [Select Id,Complexite__c from Product2 where Id in :Ids];
			for (Product2 P:Ps){
				mapProduct.put(P.Id,P.Complexite__c);
			}
			List<Delai__c> Delais = PRG_Utils.getDelais(date.today());
			for(Ligne_de_commande__c L:trigger.new){
				L.Date_previsionnelle__c = null; 
				for (Delai__c D:Delais){
					if(PRG_Utils.IsOK(D.Zone_de_livraison__c,U.Contact.Account.Zone_de_livraison__c)){
						if(PRG_Utils.IsOK(D.Complexite__c,mapProduct.get(L.Produit__c))){
							L.Date_previsionnelle__c = D.Date_de_livraison__c;
						}
					}
				}
			}
		}
	}catch(exception e){}
}
/*	    for(Ligne_de_commande__c L:trigger.new){
    		List<Pr_f_rence_praticien__c> Ps = [Select Id,Pr_f_rence__r.Commentaire__c,Pr_f_rence__r.Comment__c from Pr_f_rence_praticien__c 
    											where Praticien__c = :U.ContactId and Oui_Non__c = true and Pr_f_rence__r.Produit__c = :L.Produit__c];
    		L.Prefs__c = '';
    		L.Prefs_EN__c = '';
    		boolean first = true;
    		for(Pr_f_rence_praticien__c P:Ps){
    			if (first){
	    			L.Prefs__c = P.Pr_f_rence__r.Commentaire__c;
	    			L.Prefs_EN__c = P.Pr_f_rence__r.Comment__c;
	    			first = false;
    			}else{
	    			L.Prefs__c += '<br/>' + P.Pr_f_rence__r.Commentaire__c;
	    			L.Prefs_EN__c += '<br/>' + P.Pr_f_rence__r.Comment__c;
    			}
    		} 
    	}*/