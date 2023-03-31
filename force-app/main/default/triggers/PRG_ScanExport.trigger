trigger PRG_ScanExport on Scan_export__c (before insert) {
    if(trigger.isbefore){
        map<string,Scan_export__c> Refs = new map<string,Scan_export__c>();
        map<ID,Scan_export__c> RefIds = new map<Id,Scan_export__c>();
        List<Opportunity> OppsExport = new List<Opportunity>();
        for(Scan_export__c S:trigger.new){
            if(!string.isblank(S.CAB__c)){
                Refs.put(S.CAB__c.Replace(' ','-'),S);
            }
        }
        if(Refs.size()>0){
	        List<Opportunity> Opps = [Select Id,Name,StageName from Opportunity where Name in :Refs.keyset() 
                                      and (StageName='Validé' or StageName='Envoyé au laboratoire' or StageName='En transit vers l\'usine' or StageName = 'En cours de fabrication' or StageName='En transit vers le labo' or StageName='En cours de vérification')];
            for(Opportunity Opp:Opps){
                Refs.get(Opp.Name).Opportunite__c = Opp.Id;
                if((Opp.StageName=='Validé') || (Opp.StageName=='Envoyé au laboratoire')){
                    Refs.get(Opp.Name).Sens__c = 'Export';
                }else{
                    Refs.get(Opp.Name).Sens__c = 'Import';
                }
            }
        }
        for(Scan_export__c S:trigger.new){
            if(S.Opportunite__c != null){
                RefIds.put(S.Opportunite__c,S);
                Opportunity Opp = new Opportunity();
                Opp.ID = S.Opportunite__c;
                if(S.Sens__c == 'Export'){
	                Opp.StageName = 'En cours de traitement';
                }else{
	                Opp.StageName = 'Expédié';
    	            Opp.Verification_panier__c = true;
                }
                OppsExport.Add(Opp);
            }
        }

        if(OppsExport.size()>0){
            Database.SaveResult[] srList = Database.update(OppsExport, false);
            integer i=0;
			for (Database.SaveResult sr : srList) {
    			if (!sr.isSuccess()) {
        			RefIds.get(OppsExport[i].Id).Erreur_d_tect_e__c = true;
				}
                i++;
        	}	
    	}	
    }
}