trigger PRG_Ordonnance on Ordonnance__c (before update) {
    if(trigger.new.size()==1){
        system.debug('PRG STATUT : ' + trigger.new[0].Statut__c);
        system.debug('PRG STATUT : ' + Trigger.oldMap.get(trigger.new[0].Id).Statut__c);
        if(UserInfo.getUserType() != 'Standard'){
            if ((trigger.new[0].Statut__c == 'Brouillon') || (trigger.new[0].Statut__c == 'Reçue') && (trigger.new[0].Travail_r_parer_refaire__c) || (trigger.new[0].Statut__c == 'Validée') && (Trigger.oldMap.get(trigger.new[0].Id).Statut__c == 'Brouillon') 
                ||   ((trigger.new[0].Statut__c == 'Validée') && (Trigger.oldMap.get(trigger.new[0].Id).Statut__c == 'Brouillon')) 
                || ((trigger.new[0].Statut__c == 'Validée') && (Trigger.oldMap.get(trigger.new[0].Id).Statut__c == 'Validée')) 
                || ((trigger.new[0].Statut__c == 'En cours de traitement') && (Trigger.oldMap.get(trigger.new[0].Id).Statut__c == 'Brouillon')) 
                || ((trigger.new[0].Statut__c == 'En cours de fabrication') && (Trigger.oldMap.get(trigger.new[0].Id).Statut__c == 'Validée')) 
                || ((trigger.new[0].Statut__c == 'Envoyée au labo') && (Trigger.oldMap.get(trigger.new[0].Id).Statut__c == 'Validée'))
                || ((trigger.new[0].Statut__c == 'Reçue') && (Trigger.oldMap.get(trigger.new[0].Id).Statut__c == 'Expédiée'))
                || ((trigger.new[0].Statut__c == 'Reçue') && (trigger.new[0].Finir__c))
                || ((trigger.new[0].Statut__c == 'Expédiée') && (trigger.new[0].Travail_r_parer_refaire__c))
                || ((trigger.new[0].Statut__c == 'Expédiée') && (trigger.new[0].Finir__c))
               	|| (trigger.new[0].Rating__c != Trigger.oldMap.get(trigger.new[0].Id).Rating__c) 
                || (trigger.new[0].Choice_of_rating__c != Trigger.oldMap.get(trigger.new[0].Id).Choice_of_rating__c)
                || (trigger.new[0].Choice_of_rating_other__c != Trigger.oldMap.get(trigger.new[0].Id).Choice_of_rating_other__c)
               ){
            }
            else{
                trigger.new[0].adderror('Désolé, cette opération est impossible.');
            }
        }
      if (trigger.new[0].generer__c){
      	List<Ligne_de_commande__c> Divers = [Select Id from Ligne_de_commande__c where Ordonnance__c = :trigger.new[0].Id and Produit__r.ProductCode='DIVERS'];
      	List<Ligne_de_commande__c> Toutes = [Select Id from Ligne_de_commande__c where Ordonnance__c = :trigger.new[0].Id];
      	if((Divers.size()>0)||(Toutes.size()==0)){
      		trigger.new[0].adderror('Merci de revoir votre ordonnance, au moins une ligne est incomplète.');
      	}else{
	        trigger.new[0].Dossier__c = PRG_Ordonnance.GenerationDossier(trigger.new[0]);
    	    List<Ligne_de_commande__c> Ls = [Select Id,Produit_finition__c,Produit_suivant__c,Produit_finition__r.Name,Produit_suivant__r.Name 
        									from Ligne_de_commande__c where Ordonnance__c = :trigger.new[0].Id];
        	trigger.new[0].Description_Etape_suivante__c = '';
        	trigger.new[0].Description_finition__c = '';
        	trigger.new[0].Etape_suivante__c = '';
        	for(Ligne_de_commande__c L:Ls){
        		if(L.Produit_suivant__c !=null){
        			if(trigger.new[0].Description_Etape_suivante__c != ''){
        				trigger.new[0].Description_Etape_suivante__c += ' - ';
        			}
        			trigger.new[0].Description_Etape_suivante__c += L.Produit_suivant__r.Name;
        			trigger.new[0].Etape_suivante__c = 'l\'étape suivante';
        		}
        		if(L.Produit_finition__c !=null){
        			if(trigger.new[0].Description_finition__c != ''){
        				trigger.new[0].Description_finition__c += ' - ';
        			}
        			trigger.new[0].Description_finition__c += L.Produit_finition__r.Name;
        			trigger.new[0].Etape_suivante__c = 'la finition';
        		}
        	}
        	if(trigger.new[0].Description_Etape_suivante__c == ''){
        		trigger.new[0].Description_Etape_suivante__c = 'Aucune étape suivante n\'est possible';
        	}
        	if(trigger.new[0].Description_finition__c == ''){
        		trigger.new[0].Description_finition__c = 'Aucune finition n\'est possible';
        	}
    		trigger.new[0].generer__c = false; 
      		}
      }
      if (trigger.new[0].Statut__c == 'Envoyée au labo'){
        PRG_Ordonnance.notifEnvoye(trigger.new[0].Id);
      }
      if(trigger.new[0].Cloner__c){
        PRG_Ordonnance.Cloner(trigger.new[0].Id,false,false);
        trigger.new[0].Cloner__c = false;
      }
      if(trigger.new[0].Travail_r_parer_refaire__c){
        trigger.new[0].Statut__c = 'Reçue';
        PRG_Ordonnance.Cloner(trigger.new[0].Id,true,false,false,'',trigger.new[0].Motif_de_refection__c,trigger.new[0].Motif_detaille__c);
        trigger.new[0].Travail_r_parer_refaire__c = false;
      }
      if(trigger.new[0].Finir__c){
        trigger.new[0].Statut__c = 'Reçue';
        PRG_Ordonnance.Cloner(trigger.new[0].Id,false,(trigger.new[0].Etape_suivante__c == 'la finition'),(trigger.new[0].Etape_suivante__c == 'l\'étape suivante'),trigger.new[0].Commentaires_de_finition__c,'','');
        trigger.new[0].Finir__c = false;
      }
      if(trigger.new[0].Statut__c == 'Brouillon'){
        User U = [Select Id,ContactId,Contact.Account.Zone_de_livraison__c from User where Id=:UserInfo.GetUserId()];
        try{
            if(U.ContactId != null){
                System.debug('Test');
                date dt = date.today();
                Aggregateresult AggnbAdjointe = [Select sum(Quantite__c) Q from Ligne_de_commande__c where Ordonnance__c=:trigger.new[0].Id and Produit__r.family = 'ADJOINTE'];
                Aggregateresult AggnbConjointe = [Select sum(Quantite__c) Q from Ligne_de_commande__c where Ordonnance__c=:trigger.new[0].Id and Produit__r.family = 'CONJOINTE'];
                
                decimal nbAdjointe = (decimal) AggnbAdjointe.get('Q');
                decimal nbConjointe = (decimal) AggnbConjointe.get('Q');
                if(datetime.now().hour()>14){
                    dt = dt.AddDays(1);
                }
                List<Delai__c> Ds = [Select Date_de_livraison__c,Date_de_livraison_numerique__c,Complexite__c from Delai__c where Date_de_prise_d_empreinte__c =:dt and Zone_de_livraison__c =:U.Contact.Account.Zone_de_livraison__c];
                for (Delai__c D:Ds){
                    if(D.Complexite__c == 'Travail classique'){
                        if(trigger.new[0].Empreinte_numerique__c){
	                        trigger.new[0].Date_classique__c = D.Date_de_livraison_numerique__c;
                        }else{
	                        trigger.new[0].Date_classique__c = D.Date_de_livraison__c;
                        }
                    }
                    if(D.Complexite__c == 'Travail complexe'){
                        if(trigger.new[0].Empreinte_numerique__c){
	                        trigger.new[0].Date_complexe__c = D.Date_de_livraison_numerique__c;
                        }else{
	                        trigger.new[0].Date_complexe__c = D.Date_de_livraison__c;
                        }
                    }
                }
                if((nbConjointe>5)||((nbConjointe>0)&&(nbAdjointe>0))){
                    trigger.new[0].Complexe__c = true;  
                }else{
                    trigger.new[0].Complexe__c = false;
                }
            }
        }catch(Exception e){}
      }
    }
}
/*trigger PRG_Ordonnance on Ordonnance__c (before update,after insert, before insert) {
    if(trigger.new.size()==1){
        if (trigger.isbefore){
            if(trigger.isupdate){
                if (trigger.new[0].generer__c){
                    trigger.new[0].Dossier__c = PRG_Ordonnance.GenerationDossier(trigger.new[0]);
                    trigger.new[0].generer__c = false; 
                }
                if (trigger.new[0].Statut__c == 'Envoyée au labo'){
                    PRG_Ordonnance.notifEnvoye(trigger.new[0].Id);
                }
                if(trigger.new[0].Cloner__c){
                    PRG_Ordonnance.Cloner(trigger.new[0].Id,false,false);
                    trigger.new[0].Cloner__c = false;
                }
                if(trigger.new[0].Travail_r_parer_refaire__c){
                    PRG_Ordonnance.Cloner(trigger.new[0].Id,true,false);
                    trigger.new[0].Travail_r_parer_refaire__c = false;
                }
            }else{
                if(trigger.new[0].Finir__c){
                    string letters= 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
                    id PrecOrdId = trigger.new[0].Ordonnance_pr_c_dente__c;
                    //String soql = PRG_Utils.getCreatableFieldsSOQL('Ordonnance__c','id=\'' + PrecOrdId + '\'');
                    //Ordonnance__c o = (Ordonnance__c)Database.query(soql);
                    //trigger.new[0] = o.clone(false, true);
                    Ordonnance__c o = [Select Age__c,Patient__c,Sexe__c,Teinte__c,Teinte_bas__c,Teinte_haut__c,Version__c 
                                        from Ordonnance__c where Id=:trigger.new[0].Ordonnance_pr_c_dente__c];
                    trigger.new[0].Age__c = o.Age__c ;
                    trigger.new[0].Patient__c = o.Patient__c ;
                    trigger.new[0].Sexe__c = o.Sexe__c ;
                    trigger.new[0].Teinte__c = o.Teinte__c ;
                    trigger.new[0].Teinte_bas__c = o.Teinte_bas__c ;
                    trigger.new[0].Teinte_haut__c = o.Teinte_haut__c ;
                    trigger.new[0].Version__c = o.Version__c ;
                    trigger.new[0].Ordonnance_pr_c_dente__c = PrecOrdId;
                    if(string.isblank(trigger.new[0].Version__c)){
                        trigger.new[0].Version__c = 'A';
                    }else{
                        trigger.new[0].Version__c = letters.mid(letters.indexOf(trigger.new[0].Version__c, 1) + 2,1) ;
                    }
                    trigger.new[0].statut__c = 'Brouillon';
                    trigger.new[0].Date_d_expedition__c = null;
                    trigger.new[0].Date__c = null;
                    trigger.new[0].Date_de_r_ception__c = null;
                    trigger.new[0].Dossier__c = null;
                    trigger.new[0].Generer__c = false;
                    trigger.new[0].Je_valide_cette_commande_pour_envoi__c = false;
                    trigger.new[0].Motif_de_refection__c = null;
                    trigger.new[0].Motif_detaille__c = '';
                }
            }
        }else{
            if(trigger.new[0].Finir__c){
                PRG_Ordonnance.ClonerFrom(trigger.new[0].Id,trigger.new[0].Ordonnance_pr_c_dente__c,false,true);
                //trigger.new[0].Finir__c = false;
            }
        }
    }
}*/