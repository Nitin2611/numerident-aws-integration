public with sharing class PRG_Facturation {
    
    public static void GenerationAccount(Id AccId){
    	datetime TimeStamp = datetime.now();
    	Product2 P = [Select Id from Product2 where ProductCode = 'DIVERS' limit 1];
    	Recordtype RTConsolidation = [Select Id from Recordtype where sObjectType='sofactoapp__Offre__c' and DeveloperName = 'Consolidation' limit 1];
    	Recordtype RTDetail = [Select Id from Recordtype where sObjectType='sofactoapp__Offre__c' and DeveloperName = 'Detail' limit 1];
    	sofactoapp__Raison_Sociale__c RS = [Select id,sofactoapp__Coordonnees_bancaires_par_defaut__c,D_but_de_p_riode__c,Fin_de_p_riode__c,Preparer_la_facturation__c 
    										from sofactoapp__Raison_Sociale__c where sofactoapp__is_default__c  = true limit 1];
/*    	// Suppression des factures non émises
    	List<sofactoapp__Factures_Client__c> OldFactures = [Select Id from sofactoapp__Factures_Client__c where sofactoapp__Etat__c = 'Brouillon' and sofactoapp__Offre__c !=null];
    	if (OldFactures.size()>0){
    		delete OldFactures;
    	}
    	// Suppression des offres non envoyées 
    	List<sofactoapp__Offre__c> OldOffres = [Select Id from sofactoapp__Offre__c where sofactoapp__Etat__c != 'Envoyée'];
    	if (OldOffres.size()>0){
    		delete OldOffres;
    	}*/
    	// Création des offres consolidées - une par centre
    	List<Id> OpportunityIds = new List<Id>(); 
    	map<Id,sofactoapp__Offre__c> mapAccountConsolidation = new map<Id,sofactoapp__Offre__c>();
    	List<Opportunity> Opps = [Select Id,Statut_de_facturation__c,PriceBook2Id,AccountId,Account.sofactoapp__Contact__c,CreatedDate,
    								Account.sofactoapp__Delai_de_paiement__c,Account.sofactoapp__Mode_de_paiement__c,Account.AccountNumber,Praticien__c,
    								D_tail_du_projet_de_facturation__c,Projet_de_facturation__c
    								from Opportunity where Statut_de_facturation__c = 'En préparation' and Date_d_exp_dition__c < :RS.Fin_de_p_riode__c.AddDays(1) and AccountID =:AccId];
    	List<sofactoapp__Offre__c> Consolidations = new List<sofactoapp__Offre__c>(); 
    	map<string,decimal> mapAccountQte = new map<string,decimal>();
    	for (Opportunity Opp:Opps){
    		OpportunityIds.add(Opp.Id);
   			if(mapAccountQte.containskey((string)Opp.AccountId + (string)Opp.Praticien__c)){
    			mapAccountQte.put((string)Opp.AccountId + (string)Opp.Praticien__c,mapAccountQte.get((string)Opp.AccountId + (string)Opp.Praticien__c)+1);
   			}else{
    			mapAccountQte.put((string)Opp.AccountId + (string)Opp.Praticien__c,1);
   			}
    		if(!mapAccountConsolidation.containskey(Opp.AccountId)){
    			sofactoapp__Offre__c Consolidation = new sofactoapp__Offre__c();
    			Consolidation.Name = 'Projet de facturation ' + Opp.Account.AccountNumber + ' du ' + RS.D_but_de_p_riode__c.format() + ' au ' + RS.Fin_de_p_riode__c.format();
		   		Consolidation.sofactoapp__Catalogue_de_prix__c = Opp.PriceBook2Id;
		   		Consolidation.sofactoapp__Compte__c = Opp.AccountId;
		   		Consolidation.sofactoapp__Contact__c = Opp.Account.sofactoapp__Contact__c;
		   		Consolidation.sofactoapp__Date_de_l_offre__c = date.newinstance(Opp.CreatedDate.year(), Opp.CreatedDate.month(), Opp.CreatedDate.day());
		   		Consolidation.sofactoapp__Payment_term__c = Opp.Account.sofactoapp__Delai_de_paiement__c;
		   		Consolidation.sofactoapp__Description__c = 'Facturation des travaux du ' + RS.D_but_de_p_riode__c.format() + ' au ' + RS.Fin_de_p_riode__c.format(); 
		   		Consolidation.sofactoapp__Etat__c = 'Brouillon';
		   		Consolidation.sofactoapp__Payment_mode__c = Opp.Account.sofactoapp__Mode_de_paiement__c; 
		   		Consolidation.sofactoapp__Raison_sociale__c = RS.Id;
		   		Consolidation.sofactoapp__IsSyncing__c = false;
    			Consolidation.RecordtypeId = RTConsolidation.Id;
    			Consolidations.Add(Consolidation);
    			mapAccountConsolidation.put(Opp.AccountId,Consolidation);
    		}
    	}
    	if(Consolidations.size()>0){
    		insert Consolidations;
    	}
    	mapAccountConsolidation.clear();
    	for (sofactoapp__Offre__c Consolidation:Consolidations){
    		mapAccountConsolidation.put(Consolidation.sofactoapp__Compte__c,Consolidation);
    	}
    	// Création des offres détaillées - une par couple centre-praticien
    	map<string,decimal> mapAccountMontant = new map<string,decimal>();
    	map<string,sofactoapp__Offre__c> mapAccountDetail = new map<string,sofactoapp__Offre__c>();
    	List<sofactoapp__Offre__c> Details = new List<sofactoapp__Offre__c>(); 
    	for (Opportunity Opp:Opps){
    		if(!mapAccountDetail.containskey((string)Opp.AccountId + (string)Opp.Praticien__c)){
    			sofactoapp__Offre__c Detail = new sofactoapp__Offre__c();
    			Detail.Name = 'Détail de facturation ';// + Opp.Account.AccountNumber + ' du ' + RS.D_but_de_p_riode__c.format() + ' au ' + RS.Fin_de_p_riode__c.format();
		   		Detail.sofactoapp__Catalogue_de_prix__c = Opp.PriceBook2Id;
		   		Detail.sofactoapp__Compte__c = Opp.AccountId;
		   		Detail.sofactoapp__Contact__c = Opp.Account.sofactoapp__Contact__c;
		   		Detail.sofactoapp__Date_de_l_offre__c = date.newinstance(Opp.CreatedDate.year(), Opp.CreatedDate.month(), Opp.CreatedDate.day());
		   		Detail.sofactoapp__Payment_term__c = Opp.Account.sofactoapp__Delai_de_paiement__c;
		   		Detail.sofactoapp__Description__c = 'Facturation des travaux du ' + RS.D_but_de_p_riode__c.format() + ' au ' + RS.Fin_de_p_riode__c.format(); 
		   		Detail.sofactoapp__Etat__c = 'Brouillon';
		   		Detail.sofactoapp__Payment_mode__c = Opp.Account.sofactoapp__Mode_de_paiement__c; 
		   		Detail.sofactoapp__Raison_sociale__c = RS.Id;
		   		Detail.sofactoapp__IsSyncing__c = false;
    			Detail.RecordtypeId = RTDetail.Id;
    			Detail.Praticien__c = Opp.Praticien__c;
    			Detail.Projet_de_facture__c = mapAccountConsolidation.get(Detail.sofactoapp__Compte__c).Id;
    			Details.Add(Detail);
    			mapAccountDetail.put((string)Opp.AccountId + (string)Opp.Praticien__c,Detail);
    			mapAccountMontant.put((string)Opp.AccountId + (string)Opp.Praticien__c,0);
    		}
    	}
    	if(Details.size()>0){
    		insert Details;
    	}
    	mapAccountDetail.clear();
    	for (sofactoapp__Offre__c Detail:Details){
    		mapAccountDetail.put((string)Detail.sofactoapp__Compte__c + (string)Detail.Praticien__c,Detail);
    	}
    	// Insertion des lignes de produit
    	List<OpportunityLineItem> OppLis = [Select Id,Name,Opportunity.Name,Opportunity.CreatedDate,Opportunity.Patient__c,Opportunity.AccountId,Opportunity.Praticien__c,
    										ListPrice,UnitPrice,Product2Id,Quantity,TotalPrice,Product2.Name
    										from OpportunityLineItem where OpportunityId in :OpportunityIds order by Opportunity.AccountId,Opportunity.Praticien__c,Opportunity.CreatedDate];	
    	List<sofactoapp__Poste_offre__c> Postes = new List<sofactoapp__Poste_offre__c>(); 
    	integer Ordre = 1;
    	for(OpportunityLineItem OppLi:OppLis){
    		sofactoapp__Poste_offre__c Poste = new sofactoapp__Poste_offre__c();
    		Poste.sofactoapp__Description_detaillee__c = 'Dossier ' +  OppLi.Opportunity.Name + ' du ' + date.newinstance(OppLi.Opportunity.CreatedDate.year(), OppLi.Opportunity.CreatedDate.month(), OppLi.Opportunity.CreatedDate.day()).format() + ' - Patient ' + OppLi.Opportunity.Patient__c;
    		Poste.sofactoapp__Designation__c = Oppli.Product2.Name;
    		Poste.sofactoapp__Offre__c = mapAccountDetail.get((string)OppLi.Opportunity.AccountId + (string)OppLi.Opportunity.Praticien__c).Id;
    		Poste.sofactoapp__OppLineItemId__c = Oppli.Id;
    		Poste.sofactoapp__Prix_de_catalogue__c = Oppli.ListPrice;
    		Poste.sofactoapp__Prix_Unitaire_HT__c = Oppli.UnitPrice;
    		Poste.sofactoapp__Produit__c = Oppli.Product2Id;
    		Poste.sofactoapp__Quantite__c = Oppli.Quantity;
    		Poste.sofactoapp__Taux_de_TVA_list__c = '0%';
    		Poste.sofactoapp__Taux_de_TVA__c = 0;
    		Poste.sofactoapp__Ordre__c = Ordre;
    		Poste.Praticien__c = OppLi.Opportunity.Praticien__c;
    		Postes.Add(Poste);
    		mapAccountMontant.put((string)OppLi.Opportunity.AccountId + (string)OppLi.Opportunity.Praticien__c,mapAccountMontant.get((string)OppLi.Opportunity.AccountId + (string)OppLi.Opportunity.Praticien__c) + OppLi.TotalPrice);
    		Ordre++;
    	}
    	for(sofactoapp__Offre__c Detail:Details){
    		sofactoapp__Poste_offre__c Poste = new sofactoapp__Poste_offre__c();
    		//Poste.sofactoapp__Description_detaillee__c = 'Dossier ' +  OppLi.Opportunity.Name + ' du ' + date.newinstance(OppLi.Opportunity.CreatedDate.year(), OppLi.Opportunity.CreatedDate.month(), OppLi.Opportunity.CreatedDate.day()).format() + ' - Patient ' + OppLi.Opportunity.Patient__c;
    		//Poste.sofactoapp__Designation__c = Oppli.Product2.Name;
    		Poste.sofactoapp__Offre__c = Detail.Projet_de_facture__c;
    		//Poste.sofactoapp__OppLineItemId__c = Oppli.Id;
    		//Poste.sofactoapp__Prix_de_catalogue__c = Oppli.ListPrice;
    		Poste.sofactoapp__Prix_Unitaire_HT__c = mapAccountMontant.get((string)Detail.sofactoapp__Compte__c + (string)Detail.Praticien__c);
    		Poste.sofactoapp__Produit__c = P.Id;
    		Poste.sofactoapp__Quantite__c = 1; //mapAccountQte.get((string)Detail.sofactoapp__Compte__c + (string)Detail.Praticien__c);
    		Poste.sofactoapp__Taux_de_TVA_list__c = '0%';
    		Poste.sofactoapp__Taux_de_TVA__c = 0;
    		Poste.Praticien__c = Detail.Praticien__c;
    		Poste.sofactoapp__Ordre__c = mapAccountQte.get((string)Detail.sofactoapp__Compte__c + (string)Detail.Praticien__c);
    		Postes.Add(Poste);
    	}
    	if(Postes.size()>0){
    		insert Postes;
    	}
    	for (Opportunity Opp:Opps){
    		Opp.D_tail_du_projet_de_facturation__c = mapAccountDetail.get((string)Opp.AccountId + (string)Opp.Praticien__c).Id;
    		Opp.Projet_de_facturation__c = mapAccountConsolidation.get(Opp.AccountId).Id;
    	}
    	if(Opps.size()>0){
    		update Opps;
    	}
/*    	RS.Preparer_la_facturation__c = false;
    	update RS;*/
    }

    public static void Generation(Id RaisonSocialeId){
    	datetime TimeStamp = datetime.now();
    	Product2 P = [Select Id from Product2 where ProductCode = 'DIVERS' limit 1];
    	Recordtype RTConsolidation = [Select Id from Recordtype where sObjectType='sofactoapp__Offre__c' and DeveloperName = 'Consolidation' limit 1];
    	Recordtype RTDetail = [Select Id from Recordtype where sObjectType='sofactoapp__Offre__c' and DeveloperName = 'Detail' limit 1];
    	sofactoapp__Raison_Sociale__c RS = [Select id,sofactoapp__Coordonnees_bancaires_par_defaut__c,D_but_de_p_riode__c,Fin_de_p_riode__c,Preparer_la_facturation__c 
    										from sofactoapp__Raison_Sociale__c where Id =:RaisonSocialeId limit 1];
    	// Suppression des factures non émises
    	List<sofactoapp__Factures_Client__c> OldFactures = [Select Id from sofactoapp__Factures_Client__c where sofactoapp__Etat__c = 'Brouillon' and sofactoapp__Offre__c !=null];
    	if (OldFactures.size()>0){
    		delete OldFactures;
    	}
    	// Suppression des offres non envoyées 
    	List<sofactoapp__Offre__c> OldOffres = [Select Id from sofactoapp__Offre__c where sofactoapp__Etat__c != 'Envoyée'];
    	if (OldOffres.size()>0){
    		delete OldOffres;
    	}
    	// Création des offres consolidées - une par centre
    	List<Id> OpportunityIds = new List<Id>();
    	map<Id,sofactoapp__Offre__c> mapAccountConsolidation = new map<Id,sofactoapp__Offre__c>();
    	List<Opportunity> Opps = [Select Id,Statut_de_facturation__c,PriceBook2Id,AccountId,Account.sofactoapp__Contact__c,CreatedDate,
    								Account.sofactoapp__Delai_de_paiement__c,Account.sofactoapp__Mode_de_paiement__c,Account.AccountNumber,Praticien__c,
    								D_tail_du_projet_de_facturation__c,Projet_de_facturation__c
    								from Opportunity where Statut_de_facturation__c = 'En préparation' and CreatedDate < :RS.Fin_de_p_riode__c.AddDays(1) ];
    	List<sofactoapp__Offre__c> Consolidations = new List<sofactoapp__Offre__c>(); 
    	for (Opportunity Opp:Opps){
    		OpportunityIds.add(Opp.Id);
    		if(!mapAccountConsolidation.containskey(Opp.AccountId)){
    			sofactoapp__Offre__c Consolidation = new sofactoapp__Offre__c();
    			Consolidation.Name = 'Projet de facturation ' + Opp.Account.AccountNumber + ' du ' + RS.D_but_de_p_riode__c.format() + ' au ' + RS.Fin_de_p_riode__c.format();
		   		Consolidation.sofactoapp__Catalogue_de_prix__c = Opp.PriceBook2Id;
		   		Consolidation.sofactoapp__Compte__c = Opp.AccountId;
		   		Consolidation.sofactoapp__Contact__c = Opp.Account.sofactoapp__Contact__c;
		   		Consolidation.sofactoapp__Date_de_l_offre__c = date.newinstance(Opp.CreatedDate.year(), Opp.CreatedDate.month(), Opp.CreatedDate.day());
		   		Consolidation.sofactoapp__Payment_term__c = Opp.Account.sofactoapp__Delai_de_paiement__c;
		   		Consolidation.sofactoapp__Description__c = 'Facturation des travaux du ' + RS.D_but_de_p_riode__c.format() + ' au ' + RS.Fin_de_p_riode__c.format(); 
		   		Consolidation.sofactoapp__Etat__c = 'Brouillon';
		   		Consolidation.sofactoapp__Payment_mode__c = Opp.Account.sofactoapp__Mode_de_paiement__c; 
		   		Consolidation.sofactoapp__Raison_sociale__c = RS.Id;
		   		Consolidation.sofactoapp__IsSyncing__c = false;
    			Consolidation.RecordtypeId = RTConsolidation.Id;
    			Consolidations.Add(Consolidation);
    			mapAccountConsolidation.put(Opp.AccountId,Consolidation);
    		}
    	}
    	if(Consolidations.size()>0){
    		insert Consolidations;
    	}
    	mapAccountConsolidation.clear();
    	for (sofactoapp__Offre__c Consolidation:Consolidations){
    		mapAccountConsolidation.put(Consolidation.sofactoapp__Compte__c,Consolidation);
    	}
    	// Création des offres détaillées - une par couple centre-praticien
    	map<string,decimal> mapAccountMontant = new map<string,decimal>();
    	map<string,decimal> mapAccountQte = new map<string,decimal>();
    	map<string,sofactoapp__Offre__c> mapAccountDetail = new map<string,sofactoapp__Offre__c>();
    	List<sofactoapp__Offre__c> Details = new List<sofactoapp__Offre__c>(); 
    	for (Opportunity Opp:Opps){
    		if(!mapAccountDetail.containskey((string)Opp.AccountId + (string)Opp.Praticien__c)){
    			sofactoapp__Offre__c Detail = new sofactoapp__Offre__c();
    			Detail.Name = 'Détail de facturation ';// + Opp.Account.AccountNumber + ' du ' + RS.D_but_de_p_riode__c.format() + ' au ' + RS.Fin_de_p_riode__c.format();
		   		Detail.sofactoapp__Catalogue_de_prix__c = Opp.PriceBook2Id;
		   		Detail.sofactoapp__Compte__c = Opp.AccountId;
		   		Detail.sofactoapp__Contact__c = Opp.Account.sofactoapp__Contact__c;
		   		Detail.sofactoapp__Date_de_l_offre__c = date.newinstance(Opp.CreatedDate.year(), Opp.CreatedDate.month(), Opp.CreatedDate.day());
		   		Detail.sofactoapp__Payment_term__c = Opp.Account.sofactoapp__Delai_de_paiement__c;
		   		Detail.sofactoapp__Description__c = 'Facturation des travaux du ' + RS.D_but_de_p_riode__c.format() + ' au ' + RS.Fin_de_p_riode__c.format(); 
		   		Detail.sofactoapp__Etat__c = 'Brouillon';
		   		Detail.sofactoapp__Payment_mode__c = Opp.Account.sofactoapp__Mode_de_paiement__c; 
		   		Detail.sofactoapp__Raison_sociale__c = RS.Id;
		   		Detail.sofactoapp__IsSyncing__c = false;
    			Detail.RecordtypeId = RTDetail.Id;
    			Detail.Praticien__c = Opp.Praticien__c;
    			Detail.Projet_de_facture__c = mapAccountConsolidation.get(Detail.sofactoapp__Compte__c).Id;
    			Details.Add(Detail);
    			mapAccountDetail.put((string)Opp.AccountId + (string)Opp.Praticien__c,Detail);
    			mapAccountMontant.put((string)Opp.AccountId + (string)Opp.Praticien__c,0);
    			if(mapAccountQte.containskey((string)Opp.AccountId + (string)Opp.Praticien__c)){
	    			mapAccountQte.put((string)Opp.AccountId + (string)Opp.Praticien__c,mapAccountQte.get((string)Opp.AccountId + (string)Opp.Praticien__c)+1);
    			}else{
	    			mapAccountQte.put((string)Opp.AccountId + (string)Opp.Praticien__c,1);
    			}
    		}
    	}
    	if(Details.size()>0){
    		insert Details;
    	}
    	mapAccountDetail.clear();
    	for (sofactoapp__Offre__c Detail:Details){
    		mapAccountDetail.put((string)Detail.sofactoapp__Compte__c + (string)Detail.Praticien__c,Detail);
    	}
    	// Insertion des lignes de produit
    	List<OpportunityLineItem> OppLis = [Select Id,Name,Opportunity.Name,Opportunity.CreatedDate,Opportunity.Patient__c,Opportunity.AccountId,Opportunity.Praticien__c,
    										ListPrice,UnitPrice,Product2Id,Quantity,TotalPrice,Product2.Name
    										from OpportunityLineItem where OpportunityId in :OpportunityIds order by Opportunity.AccountId,Opportunity.Praticien__c,Opportunity.CreatedDate];	
    	List<sofactoapp__Poste_offre__c> Postes = new List<sofactoapp__Poste_offre__c>(); 
    	integer Ordre = 1;
    	for(OpportunityLineItem OppLi:OppLis){
    		sofactoapp__Poste_offre__c Poste = new sofactoapp__Poste_offre__c();
    		Poste.sofactoapp__Description_detaillee__c = 'Dossier ' +  OppLi.Opportunity.Name + ' du ' + date.newinstance(OppLi.Opportunity.CreatedDate.year(), OppLi.Opportunity.CreatedDate.month(), OppLi.Opportunity.CreatedDate.day()).format() + ' - Patient ' + OppLi.Opportunity.Patient__c;
    		Poste.sofactoapp__Designation__c = Oppli.Product2.Name;
    		Poste.sofactoapp__Offre__c = mapAccountDetail.get((string)OppLi.Opportunity.AccountId + (string)OppLi.Opportunity.Praticien__c).Id;
    		Poste.sofactoapp__OppLineItemId__c = Oppli.Id;
    		Poste.sofactoapp__Prix_de_catalogue__c = Oppli.ListPrice;
    		Poste.sofactoapp__Prix_Unitaire_HT__c = Oppli.UnitPrice;
    		Poste.sofactoapp__Produit__c = Oppli.Product2Id;
    		Poste.sofactoapp__Quantite__c = Oppli.Quantity;
    		Poste.sofactoapp__Taux_de_TVA_list__c = '0%';
    		Poste.sofactoapp__Taux_de_TVA__c = 0;
    		Poste.sofactoapp__Ordre__c = Ordre;
    		Poste.Praticien__c = OppLi.Opportunity.Praticien__c;
    		Postes.Add(Poste);
    		mapAccountMontant.put((string)OppLi.Opportunity.AccountId + (string)OppLi.Opportunity.Praticien__c,mapAccountMontant.get((string)OppLi.Opportunity.AccountId + (string)OppLi.Opportunity.Praticien__c) + OppLi.TotalPrice);
    		Ordre++;
    	}
    	for(sofactoapp__Offre__c Detail:Details){
    		sofactoapp__Poste_offre__c Poste = new sofactoapp__Poste_offre__c();
    		//Poste.sofactoapp__Description_detaillee__c = 'Dossier ' +  OppLi.Opportunity.Name + ' du ' + date.newinstance(OppLi.Opportunity.CreatedDate.year(), OppLi.Opportunity.CreatedDate.month(), OppLi.Opportunity.CreatedDate.day()).format() + ' - Patient ' + OppLi.Opportunity.Patient__c;
    		//Poste.sofactoapp__Designation__c = Oppli.Product2.Name;
    		Poste.sofactoapp__Offre__c = Detail.Projet_de_facture__c;
    		//Poste.sofactoapp__OppLineItemId__c = Oppli.Id;
    		//Poste.sofactoapp__Prix_de_catalogue__c = Oppli.ListPrice;
    		Poste.sofactoapp__Prix_Unitaire_HT__c = mapAccountMontant.get((string)Detail.sofactoapp__Compte__c + (string)Detail.Praticien__c);
    		Poste.sofactoapp__Produit__c = P.Id;
    		Poste.sofactoapp__Quantite__c = mapAccountQte.get((string)Detail.sofactoapp__Compte__c + (string)Detail.Praticien__c);
    		Poste.sofactoapp__Taux_de_TVA_list__c = '0%';
    		Poste.sofactoapp__Taux_de_TVA__c = 0;
    		Poste.Praticien__c = Detail.Praticien__c;
    		Postes.Add(Poste);
    	}
    	if(Postes.size()>0){
    		insert Postes;
    	}
    	for (Opportunity Opp:Opps){
    		Opp.D_tail_du_projet_de_facturation__c = mapAccountDetail.get((string)Opp.AccountId + (string)Opp.Praticien__c).Id;
    		Opp.Projet_de_facturation__c = mapAccountConsolidation.get(Opp.AccountId).Id;
    	}
    	if(Opps.size()>0){
    		update Opps;
    	}
    	RS.Preparer_la_facturation__c = false;
    	update RS;
    }
}