public class PRG_LigneControllerExtension {

    private final Ligne__c Ligne;
    public  List<Business_case__c> BCs;
    public  Map<Id,decimal> SelectedBCs;
    public List<Unit_de_facturation__c> Unites;
    public boolean readOnly {get;set;}
    
    public PRG_LigneControllerExtension(ApexPages.StandardController stdController) {
        this.Ligne = (Ligne__c)stdController.getRecord();
        readOnly = Ligne.Validee__c;
        SelectedBCs = new Map<Id,decimal>();
        if(Ligne.IsGouttiere__c){
	        BCs = [Select Id,Name,Ecran__c,Sous_cran__c,Type__c,Materiau__c,Options__c,Finition__c,Minimum__c,Maximum__c
	        		from Business_case__c where Ecran__c = 'Gouttiere'];
        }
        if(Ligne.IsICC__c){
	        BCs = [Select Id,Name,Ecran__c,Sous_cran__c,Type__c,Materiau__c,Options__c,Finition__c,Minimum__c,Maximum__c
	        		from Business_case__c where Ecran__c = 'Inlay core couronne'];
        }
        List<ID> listID = new List<ID>();
        for(Business_case__c BC:BCs){
        	listID.Add(BC.Id);
        }
        Unites = [Select Business_case__c,Produit__c from Unit_de_facturation__c where Business_case__c in :listID];
    }

    public PageReference SaveLigne(){
    	Ligne.En_cours_de_creation__c = false;
        if (getBusinessCases()){
	    	update Ligne;
	    	return Ordonnance(Ligne.Ordonnance__c);
        }else{
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Désolé, des informations sont manquantes, vous ne pouvez pas enregistrer cette ligne.'));
        	return null;
        }
    }
    
    public PageReference DeleteLigne(){
    	string IdOrd = Ligne.Ordonnance__c;
   		delete ligne;
    	return Ordonnance(IdOrd);
    }

    public PageReference CancelLigne(){
    	string IdOrd = Ligne.Ordonnance__c;
    	if (Ligne.En_cours_de_creation__c){
    		delete ligne;
    	}
    	return Ordonnance(IdOrd);
    }
    
    public PageReference Ordonnance(string IdOrdonnance){
    	Pagereference PR = new PageReference('/' + IdOrdonnance);
    	//PR.setRedirect(true);
    	return PR;
    }
    
/*    public PageReference Autosave() {
        update Ligne;
        getBusinessCases();
        return null;
    }

    public PageReference AutosaveArcade() {
        update Ligne;
        getBusinessCases();
        return null;
    }

    public PageReference AutosaveType() {
    	Ligne.Couronne__c = null;
        update Ligne;
        getBusinessCases();
        return null;
    }*/
    
    public boolean getBusinessCases(){
    	SelectedBCs.clear();
    	if(Ligne.IsGouttiere__c){
    		getBC('Gouttière',Ligne.Type__c,null,null,null,Ligne.Arcade__c =='Haut et bas'?2:1);
    	}
    	if(Ligne.IsICC__c){
    		system.debug('Vue ' + Ligne.Inlay_core__c + '-' + Ligne.Dents_a_restorer__c);
    		List<Temp__c> tmp = [Select Valeur__c from Temp__c where Info__c =: (string)Ligne.Id + 'Inlay_core__c'];
    		if (tmp.size()==1){
		        Ligne.Inlay_core__c = '';
        		Object[] values = (Object[])System.JSON.deserializeUntyped(tmp[0].Valeur__c);
        		if(values.size()>0){
            		Ligne.Inlay_core__c = String.join(values, ';');
            		Ligne.txtInlayCore__c = Ligne.Inlay_core__c;
        		}
    		}
    		tmp = [Select Valeur__c from Temp__c where Info__c =: (string)Ligne.Id + 'Dents_a_restorer__c'];
    		if (tmp.size()==1){
		        Ligne.Dents_a_restorer__c = '';
        		Object[] values = (Object[])System.JSON.deserializeUntyped(tmp[0].Valeur__c);
        		if(values.size()>0){
            		Ligne.Dents_a_restorer__c = String.join(values, ';');
            		Ligne.txtDents__c = Ligne.Dents_a_restorer__c;
        		}
    		}
    		getBC('Couronne',Ligne.Couronne__c,Ligne.Alliage__c,null,Ligne.Finition__c,(string.isblank(Ligne.Inlay_core__c))?0:Ligne.Inlay_core__c.split(';').size());
    		getBC('Inlay core',Ligne.Type__c,Ligne.Alliage_Inlay_core__c,null,Ligne.Finition__c,(string.isblank(Ligne.Dents_a_restorer__c))?0:Ligne.Dents_a_restorer__c.split(';').size());
    	}
    	List<Ligne_de_commande__c> oldLCs = [Select Id from Ligne_de_commande__c where Ligne__c = :Ligne.Id];
    	if(oldLCs.size()>0){
    		delete oldLCS;
    	}
    	List<Ligne_de_commande__c> LCs = new List<Ligne_de_commande__c>();
   		boolean trouve = false;
    	for (String BCid : SelectedBCs.keySet()){
    		for(Unit_de_facturation__c Unite:Unites){
	   			if(Unite.Business_case__c == BCId){
	   				trouve = true;
					Ligne_de_commande__c LC = new Ligne_de_commande__c();
					LC.Ligne__c = Ligne.Id;
            		LC.Business_case__c = BCid;
            		LC.Quantite__c = SelectedBCs.get(BCId);
            		LC.Ordonnance__c = Ligne.Ordonnance__c;
            		LC.Produit__c = Unite.Produit__c;
            		LCs.Add(LC);
    			}
    		}
/*    		if (!trouve){
				Ligne_de_commande__c LC = new Ligne_de_commande__c();
				LC.Ligne__c = Ligne.Id;
           		LC.Business_case__c = BCid;
           		LC.Quantite__c = SelectedBCs.get(BCId);
           		LC.Ordonnance__c = Ligne.Ordonnance__c;
           		LCs.Add(LC);
    		}*/
        }
    	if(LCs.size()>0){
    		insert LCs;
    	}
    	return (trouve);
    }
    
    public void getBC(string SousEcran,string Type,string Materiau,string Options, string Finition, integer nb){
    	for(Business_case__c BC:BCs){
    		if(isOK(BC.Sous_cran__c,SousEcran)){
	    		if(isOK(BC.Type__c,Type)){
		    		if(isOK(BC.Materiau__c,Materiau)){
			    		if(isOK(BC.Options__c,Options)){
				    		if(isOK(BC.Finition__c,Finition)){
				    			if((BC.Minimum__c>=0)&&(BC.Maximum__c>=0)){
				    				if ((nb>=BC.Minimum__c) && (nb<=BC.Maximum__c)){
				    					SelectedBCs.put(BC.Id,1);
				    				} 
				    			}else{
				    				SelectedBCs.put(BC.Id,nb);
				    			}
			    			}
		    			}
	    			}
    			}
    		}
    	}
    }
    
    public boolean isOK(string s1,string s2){ 
    	if(string.isblank(s2)){
    		return true;
    	}else{
    		if(string.isblank(s1)){
    			return false;
    		}else{
    			return (s1 == s2);
    		}
    	}
    }
}