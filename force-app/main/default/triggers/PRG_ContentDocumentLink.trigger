trigger PRG_ContentDocumentLink on ContentDocumentLink (after insert) {
	string Id2Check='';
        for (ContentDocumentLink CDL:trigger.new){
            if(((string)(CDL.LinkedEntityId)).startswith('a0i')){
		        Id2Check = CDL.LinkedEntityId;
            }
        }
    if(!string.isblank(Id2Check)){
        List<Ordonnance__c> Os = [Select Id,Statut__c from Ordonnance__c where Id=:Id2Check];
        if(Os.size()==1){
            boolean Numerique = false;
            for(ContentDocumentLink cdl:trigger.new){
				String fileExtension;
    	    	String docId = cdl.ContentDocumentId;
        		FileExtension = [select FileExtension from ContentVersion where ContentDocumentId = :docId].get(0).FileExtension.toUpperCase();  
                if((FileExtension == 'STL')||(FileExtension == 'DCM')||(FileExtension == '3OXZ')){
                    Numerique = true;
                }
            }
            if(Numerique){
	            if(Os[0].Statut__c != 'Brouillon'){
					trigger.new[0].AddError('La commande étant en statut validée, il n\'est plus possible d\'ajouter une empreinte numérique. Merci de recréer votre commande en y glissant votre empreinte avant la validation',true);           
        	    }
            }
        }
        try{
            Ordonnance__c O = new Ordonnance__c();
            O.Id = Id2Check;
            O.Empreinte_numerique__c = PRG_Ordonnance.FichierEmpreinteNumerique(Id2Check);
            update O;
        }catch(exception e){}
    }
}