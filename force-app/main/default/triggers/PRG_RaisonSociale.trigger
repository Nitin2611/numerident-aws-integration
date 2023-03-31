trigger PRG_RaisonSociale on sofactoapp__Raison_Sociale__c (after update) {
	if(trigger.new.size()==1){
		if(trigger.new[0].Preparer_la_facturation__c){
			//PRG_Facturation.Generation(trigger.new[0].Id);
			PRG_BatchGenerationFacture M = new PRG_BatchGenerationFacture ();
        	Database.executeBatch(M,1);
		}
	}    
}