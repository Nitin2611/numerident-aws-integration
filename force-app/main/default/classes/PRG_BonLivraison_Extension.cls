public without sharing class PRG_BonLivraison_Extension {
    private final Ordonnance__c Ord;
    public boolean ShowTrac {get;set;}
    public decimal PrixTotal {get;set;}
    
    public List<Ligne_de_commande__c> getLCs(){
        map<ID,decimal> mapPrice = new map<ID,decimal>();
        List<Id> LCIds = new List<Id>();
        List<Ligne_de_commande__c> LCs = [Select Id,Travail__c,Product_name__c,txtQuantite__c,Comp0__c,Comp1__c,Comp2__c,Comp3__c,
                                          Comp4__c,Comp5__c,Prefs_EN__c,TotalPrice__c from Ligne_de_commande__c 
                                          where Ordonnance__c=:Ord.Id];
        for(Ligne_de_commande__c LC:LCs){
            LCIds.Add(LC.ID);
        }
        List<OpportunityLineItem> OppLis = [Select Ligne_de_commande__c,TotalPrice from OpportunityLineItem where Ligne_de_commande__c in :LCIds];
        for(OpportunityLineItem OppLi:OppLis){
            mapPrice.put(OppLi.Ligne_de_commande__c,OppLi.TotalPrice);
        }
        PrixTotal = 0;
        for(Ligne_de_commande__c LC:LCs){
            if(mapPrice.containskey(LC.Id)){
                LC.TotalPrice__c = mapPrice.get(LC.Id);
                if(LC.TotalPrice__c!=null){
                    PrixTotal += LC.TotalPrice__c;
                }
            }
        }
        return Lcs;
    }
    
    public List<Tracabilite__c> getTracas(){
        List<Tracabilite__c> Ts = new List<Tracabilite__c>();
        List<Tracabilite__c> TOrd = [Select Id,Produit__r.Name,Materiau__r.Name,Materiau__r.Num_ro_CE__c,Num_ro_de_lot__c from Tracabilite__c where Ordonnance__c=:Ord.ID];
        map<string,string> mapTra = new map<string,string>();
        for(Tracabilite__c T:TOrd){
            if(!mapTra.containskey(T.Produit__r.Name+T.Materiau__r.Name+T.Materiau__r.Num_ro_CE__c+T.Num_ro_de_lot__c)){
                mapTra.put(T.Produit__r.Name+T.Materiau__r.Name+T.Materiau__r.Num_ro_CE__c+T.Num_ro_de_lot__c,null);
	            Ts.Add(T);
            }
        }
        return Ts;
    }

    public string getPaysFab(){
        string tmp = 'France';
        List<Opportunity> Opp = [Select Id,Usine__c,Usine__r.Pays_de_fabrication__c from Opportunity where Ordonnance__c=:Ord.Id];            
        if(Opp[0].Usine__c != null){
	        if(!string.isblank(Opp[0].Usine__r.Pays_de_fabrication__c)){
                tmp = Opp[0].Usine__r.Pays_de_fabrication__c;
    	    }
        }
        return tmp;
    }

    public PRG_BonLivraison_Extension(ApexPages.StandardController stdController) { 
        this.Ord = (Ordonnance__c)stdController.getRecord();
        List<Tracabilite__c> TOrd = [Select Id,Produit__r.Name,Materiau__r.Name,Materiau__r.Num_ro_CE__c,Num_ro_de_lot__c from Tracabilite__c where Ordonnance__c=:Ord.ID];
        ShowTrac = (TOrd.size()>0);
    }
}