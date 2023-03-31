global class PRG_BatchGenerationFacture implements Database.Batchable<AggregateResult>, Iterable<AggregateResult>, Iterator<AggregateResult>  {
   Integer index;
    List<AggregateResult> aggregates;
    
    public PRG_BatchGenerationFacture ()
    {
    	sofactoapp__Raison_Sociale__c RS = [Select id,sofactoapp__Coordonnees_bancaires_par_defaut__c,D_but_de_p_riode__c,Fin_de_p_riode__c,Preparer_la_facturation__c 
    										from sofactoapp__Raison_Sociale__c where sofactoapp__is_default__c  = true limit 1];
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
        index = 0;
        aggregates = [Select AccountId  from Opportunity  
                        where CloseDate>:date.today().AddDays(-180) and Statut_de_facturation__c = 'En préparation' and Date_d_exp_dition__c < :RS.Fin_de_p_riode__c.AddDays(1) 
                        group by AccountId];
    }
    public void execute(SchedulableContext context)
    {
        Database.executeBatch(this);
    }
    public Iterator<AggregateResult> iterator()
    {
        return this;
    }
    public Boolean hasNext()
    {
        return index < aggregates.size();
    }
    public AggregateResult next()
    {
        return aggregates[index++];
    }
    public Iterable<AggregateResult> start(Database.BatchableContext context)
    {
        return this;
    }        

        global void execute(Database.BatchableContext BC, list<AggregateResult> scope)
        {
            for(AggregateResult Ag:scope)
            {
                 PRG_Facturation.GenerationAccount((string)Ag.get('AccountId'));
            }
        }
        global void finish(Database.BatchableContext BC)
        {
    	sofactoapp__Raison_Sociale__c RS = [Select id,sofactoapp__Coordonnees_bancaires_par_defaut__c,D_but_de_p_riode__c,Fin_de_p_riode__c,Preparer_la_facturation__c 
    										from sofactoapp__Raison_Sociale__c where sofactoapp__is_default__c  = true limit 1];
        RS.Preparer_la_facturation__c = false;
    	update RS;
        }
    
/*    global Database.QueryLocator start(Database.BatchableContext bc) {
    	sofactoapp__Raison_Sociale__c RS = [Select id,sofactoapp__Coordonnees_bancaires_par_defaut__c,D_but_de_p_riode__c,Fin_de_p_riode__c,Preparer_la_facturation__c 
    										from sofactoapp__Raison_Sociale__c where sofactoapp__is_default__c  = true limit 1];
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
//    	List<Opportunity> Opps = [Select Id,Statut_de_facturation__c,PriceBook2Id,AccountId,Account.sofactoapp__Contact__c,CreatedDate,
//    								Account.sofactoapp__Delai_de_paiement__c,Account.sofactoapp__Mode_de_paiement__c,Account.AccountNumber,Praticien__c,
//    								D_tail_du_projet_de_facturation__c,Projet_de_facturation__c
//    								from Opportunity where Statut_de_facturation__c = 'En préparation' and CreatedDate < :RS.Fin_de_p_riode__c.AddDays(1) ]; 
        string strSQL = 'Select Id,Statut_de_facturation__c,PriceBook2Id,AccountId,Account.sofactoapp__Contact__c,CreatedDate,';
        strSQL += 'Account.sofactoapp__Delai_de_paiement__c,Account.sofactoapp__Mode_de_paiement__c,Account.AccountNumber,Praticien__c,';
        strSQL += 'D_tail_du_projet_de_facturation__c,Projet_de_facturation__c ';
        strSQL += 'from Opportunity where Statut_de_facturation__c = \'En préparation\' and ';
        strSQL += ' CreatedDate < ' + string.valueof(RS.Fin_de_p_riode__c.AddDays(1)) + 'T00:00:00Z' ;
        system.debug(strSQL);
        
        return Database.getQueryLocator(strSQL);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> Opps){
    	PRG_Facturation.Generation(Opps);
    }
    
    global void finish(Database.BatchableContext BC) {
    	sofactoapp__Raison_Sociale__c RS = [Select id,sofactoapp__Coordonnees_bancaires_par_defaut__c,D_but_de_p_riode__c,Fin_de_p_riode__c,Preparer_la_facturation__c 
    										from sofactoapp__Raison_Sociale__c where sofactoapp__is_default__c  = true limit 1];
        RS.Preparer_la_facturation__c = false;
    	update RS;
    }
    */
}