public class PRG_AnalyseRetour{
    public List<Retour__c> Rs {get;set;}
    public List<OpportunityLineItem> Os {get;set;}
	public List<clsRetour> anl {get;set;}
    public string str {get;set;}
    public integer nbTotal {get;set;}
    public integer nbOK {get;set;}
    public Opportunity Opp {get;set;}
    public List<Opportunity> Opps;
    public integer idx {get;set;}
    
    public class clsRetour{
        public Retour__c R {get;set;}
        public List<OpportunityLineItem> Os {get;set;}
        public List<string> Cs {get;set;}
        public string C {get;set;}
        public clsRetour(Retour__c pR,List<OpportunityLineItem> pOs){
            R = pR;
            Cs=new List<string>();
            Os = new List<OpportunityLineItem>();
            boolean Red;
            for(OpportunityLineItem pO:pOs){
                string couleur='#FFFFFF';
                Red=true;
                if(pR.IdPoste__c == (string)pO.ID){
                if((pR.Full_match__c)||(pR.Manually_checked__c)){
                    couleur = '#00FF00';
                    red=false;
                    pO.StyleRetour__c = '#00FF00';
                }else{
                    if(pR.Match__c){
                        couleur = '#FFCC00';
                        red=false;
                		pO.StyleRetour__c = '#FFCC00';
                    }else{
                        couleur = '#FFFFFF';
                        pO.StyleRetour__c = '#FFFFFF';
                    }
                }
                }else{
                    pO.StyleRetour__c = '#FFFFFF';
                }
                Cs.Add(pO.StyleRetour__c);
                Os.Add(pO);	
            }
 //           if (Red){
 //               C='#FF0000';
 //           }else{
                C='#FFFFFF';
 //           }
        }
    }
    
    public PRG_AnalyseRetour(){
		Opps = [Select Id,Name,Retours_OK__c from Opportunity where StageName='En cours de vérification'];
        nbTotal = Opps.size();
        nbOK = 0;
        if(nbTotal>0){
            idx = 0;
             OppCourante(Opps[idx]);
        }
    }
    
    public PageReference SaveNext(){
        if(!Opps[idx].Retours_OK__c){
	        Opps[idx].Retours_OK__c = true;
    	    nbOK++;
        }
        if(nbOK<nbTotal){
	        return Next();
        }else{
            return null;
        }
    }

    public PageReference Next(){
        idx++;
        if(idx==nbTotal){
            idx=0;
        }
        if(OppCourante(Opps[idx])){
			SaveNext();
	        return null;
        }else{
	        return null;
        }
    }
    public PageReference Prev(){
        idx--;
        if(idx==-1){
            idx=nbTotal-1;
        }
        OppCourante(Opps[idx]);
        return null;
    }

    
    public boolean OppCourante(Opportunity O){
        //str =apexpages.currentpage().getparameters().get('name');
        Opp = O;
        Rs = [Select Ligne__c,Code__c,Full_match__c,IdPoste__c,Name,Manually_checked__c,Match__c,Quantite__c 
              from Retour__c where Name=:O.Name];
        Os = [Select Opportunity.Name,Product2.Name,Id,Quantity,Name,StyleRetour__c from OpportunityLineItem 
              where Opportunity.Id=:O.Id];
        anl = new List<clsRetour>();
        for (Retour__c R:Rs){
            anl.add(new clsRetour(R,Os));
        }
        if((anl.size()==0)||(O.Retours_OK__c)){
            return true;
        }else{
            return false;
        }
    }
}