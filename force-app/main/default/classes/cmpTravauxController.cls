public class cmpTravauxController{
    public static Ligne__c Ligne;
    public static List<Business_case__c> BCs;
    public static Map<Id,decimal> SelectedBCs = new Map<Id,decimal>();
    public static List<Unit_de_facturation__c> Unites;

    @AuraEnabled
    public static void ServerDeleteLigne(String recordId){
        Ligne__c l = new Ligne__c();
        l.Id = recordId;
        delete l;
    }

    @AuraEnabled
    public static void ServerCancelLigne(String recordId){ 
        if (Ligne.En_cours_de_creation__c){
            delete ligne; 
        }
    }

    @AuraEnabled
    public static Ligne__c getLigne(String recordId) {
        
        Ligne__c l = [Select Id,Name,Arcade__c,Dents__c,Liaison__c,Ordonnance__c,ShowArcades__c,ShowDents__c,Couronne__c,Alliage__c,Type__c,Ordonnance__r.Name,RecordType.Name,
                     LibDents1__c,LibDents2__c,LibArcades__c,LibTravaux1__c,LibTravaux2__c,PrefBandeau__c,PrefMaquillage__c,PrefOcclusion__c,PrefPointContact__c,
                     PrefSillon__c,PrefTypePreparation__c,LibType1__c,LibssType1__c,LibCnt2__c,LibDep2__c,Dents2__c, Finition__c,Alliage_Inlay_core__c,
                      LibFinition__c,LibHaut__c, 
                     IsGouttiere__c,IsICC__c,RecordType.DeveloperName,txtDents__c,Type_de_couronne__c,Accastillage__c,Marque_d_implant__c,R_f_rence_d_implant__c,Diam_tre__c,
                      RecordType.Description,Type_d_empreinte__c,ShowOptions__c,Type_de_pr_paration__c,
                      Embrasure__c,Perforation__c,Profil_d_mergence__c,Trac_de_stellite__c,Maquillage_sillon__c,
                      Bandeau_m_tallique__c,Maquillage__c,Occlusion__c,Point_de_contact__c,Ref_Diametre__c,Ref_Diametre_BIOTECH__c,Type_d_empreinte_sur_implant__c
                    from Ligne__c where Id= :recordId];         
        return l;
    }

    @AuraEnabled
    public static void ServersaveLigne(String teethValues,String teethValues2,Ligne__c l,string Type1, string SsType1,string Liaison,string Type2,string SsType2,
                                        string Finition,string Arcade,
                                        String PrefLiaison,String PointContact,String Maquillage,String MaquillageSillon,String Bandeau,String TypePreparation,
                                       string Embrasure,string Perforation,string ProfilEmergence,string TraceStellite) {
        Object[] values = (Object[])System.JSON.deserializeUntyped(teethValues);
        if(values.size()>0){
            l.put('Dents__c',String.join(values, ';').replace('_2','')); 
            l.txtDents__c = String.join(values, ';').replace('_2','');
        }
        Object[] values2 = (Object[])System.JSON.deserializeUntyped(teethValues2);
        if(values2.size()>0){
            l.put('Dents2__c',String.join(values2, ';').replace('_2','')); 
        }
        
        if ((l.RecordType.DeveloperName !='Couronne_sur_implants')&&(l.RecordType.DeveloperName !='Superstructure_et_barres')){
            l.Type__c = Type1;
            if(l.RecordType.DeveloperName !='Planification_implantaire'){
	            l.Alliage_Inlay_core__c = SsType1;
            }else{
	            l.Type_de_couronne__c = SsType1;
            }
        }else{
            l.Accastillage__c = Type1;
            l.Type_de_couronne__c = SsType1;
        }
        l.Liaison__c = Liaison;
        if (string.isblank(l.Type__c)){
            l.Type__c = Liaison;
        }
        l.Arcade__c = Arcade;
        l.Alliage__c = SsType2;
        l.Couronne__c = Type2;
        l.Finition__c = Finition;
        l.Maquillage_sillon__c = MaquillageSillon;
        l.Type_de_pr_paration__c = TypePreparation;
        l.Bandeau_m_tallique__c = Bandeau;
        l.Maquillage__c = Maquillage;
        l.Occlusion__c = PrefLiaison;
        l.Point_de_contact__c = PointContact;
        L.Embrasure__c = Embrasure;
        l.Perforation__c = Perforation;
        l.Profil_d_mergence__c = ProfilEmergence;
        l.Trac_de_stellite__c = TraceStellite; 
        if(l.Marque_d_implant__c == 'BIOTECH'){
	        if(!string.isblank(l.Ref_Diametre_BIOTECH__c)){
    	        List<string> s = l.Ref_Diametre_BIOTECH__c.split(' ',2);
        	    if(s.size()==2)                                       {
            	    l.R_f_rence_d_implant__c = s[0];
                	l.Diam_tre__c = s[1];
            	}
        	}
        }
        if(l.Marque_d_implant__c == 'ETK'){
        	if(!string.isblank(l.Ref_Diametre__c)){
            	List<string> s = l.Ref_Diametre__c.split(' ',2);
            	if(s.size()==2)                                       {
                	l.R_f_rence_d_implant__c = s[0];
                	l.Diam_tre__c = s[1];
            	}
            }
        }
        system.debug('Sauvegarde ' + Type1);
        update l;     
        Ligne = GetLigne(l.Id);
        BCs = [Select Id,Sous_cran__c,Type__c,Materiau__c,Options__c,Finition__c,Minimum__c,Maximum__c,Accastillage__c,Type_d_implant__c from Business_case__c];
                system.debug(BCs.size());
        Unites = [Select Id,Business_case__c,Produit__c,Produit__r.Finition__c,Produit__r.Suivant__c,Produit__r.Categorie__c from Unit_de_facturation__c];
        if (!getBusinessCases()){
                List<Product2> Ps = [Select Id,Categorie__c from Product2 where ProductCode='DIVERS'];
                    Ligne_de_commande__c LC = new Ligne_de_commande__c();
                    LC.Ligne__c = Ligne.Id;
                    LC.Quantite__c = 1;
                    LC.Ordonnance__c = Ligne.Ordonnance__c;
                    LC.Produit__c = Ps[0].Id;
            		LC.Categorie__c = PS[0].Categorie__c;
                    insert Lc;
        } 
    }

    @AuraEnabled
    public static void saveTeeth(String teethValues, String recordId, String FieldId) {
        
        Ligne_de_commande__c l = new Ligne_de_commande__c();        
        String queryStr='SELECT Id,'+ FieldId + ' FROM Ligne_de_commande__c WHERE Id = \'' + recordId + '\'';  
        List<Ligne_de_commande__c> results=Database.query(queryStr);        
        l = results[0];    
        l.put( FieldId,'');
                
        Object[] values = (Object[])System.JSON.deserializeUntyped(teethValues);
        if(values.size()>0){
            l.put(FieldId,String.join(values, ';'));
        }
        
        update l;
    }
    
    @AuraEnabled
    public static String getTeeth(String recordId, String FieldId) {
        
        Ligne_de_commande__c l = new Ligne_de_commande__c();        
        String queryStr='SELECT Id,'+ FieldId + ' FROM Ligne_de_commande__c WHERE Id = \'' + recordId + '\'';  
        List<Ligne_de_commande__c> results=Database.query(queryStr);        
        l = results[0];    
        
        return (String)l.get(FieldId);
    }
  @AuraEnabled  
    public static Map<String,List<String>> getDependentOptionsImpl(string objApiName , string contrfieldApiName , string depfieldApiName){
        return getDependentOptionsImpl( objApiName ,  contrfieldApiName ,  depfieldApiName,null);
    }
  @AuraEnabled  
    public static Map<String,List<String>> getDependentOptionsImpl(string objApiName , string contrfieldApiName , string depfieldApiName,string recordId){
        List<string> strExcluded = new List<string>(); 
        if(recordId != null){
            Ligne__c l = [Select Id,RecordType.DeveloperName from Ligne__c where Id= :recordId];
            if(l.RecordType.DeveloperName == 'Couronne_sur_implants'){
                strExcluded.Add('Richmond CCM');
                strExcluded.Add('Couronne metallique');
                strExcluded.Add('Richmond metallique');
                strExcluded.Add('Plateau Richmond');
                strExcluded.Add('Armature de recouvrement');
            } 
        }
        system.debug(objApiName + '##' + contrfieldApiName + '###' + depfieldApiName);
           
        String objectName = objApiName.toLowerCase();
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
            //get the string to sobject global map
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
         
        if (!Schema.getGlobalDescribe().containsKey(objectName)){
            System.debug('OBJNAME NOT FOUND --.> ' + objectName);
            return null;
         }
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        if (objType==null){
            return objResults;
        }
        Bitset bitSetObj = new Bitset();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        //Check if picklist values exist
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            System.debug('FIELD NOT FOUND --.> ' + controllingField + ' OR ' + dependentField);
            return objResults;     
        }
        
        List<Schema.PicklistEntry> contrEntries = objFieldMap.get(controllingField).getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> depEntries = objFieldMap.get(dependentField).getDescribe().getPicklistValues();
         objFieldMap = null;
        List<Integer> controllingIndexes = new List<Integer>();
        for(Integer contrIndex=0; contrIndex<contrEntries.size(); contrIndex++){            
            Schema.PicklistEntry ctrlentry = contrEntries[contrIndex];
            String label = ctrlentry.getLabel();
            if(!strExcluded.contains(label)){
                objResults.put(label,new List<String>());
                controllingIndexes.add(contrIndex);
            }
        }
        List<Schema.PicklistEntry> objEntries = new List<Schema.PicklistEntry>();
        List<PicklistEntryWrapper> objJsonEntries = new List<PicklistEntryWrapper>();
        for(Integer dependentIndex=0; dependentIndex<depEntries.size(); dependentIndex++){            
               Schema.PicklistEntry depentry = depEntries[dependentIndex];
               objEntries.add(depentry);
        } 
        objJsonEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objEntries), List<PicklistEntryWrapper>.class);
        List<Integer> indexes;
        for (PicklistEntryWrapper objJson : objJsonEntries){
            if (objJson.validFor==null || objJson.validFor==''){
                continue;
            }
            indexes = bitSetObj.testBits(objJson.validFor,controllingIndexes);
            for (Integer idx : indexes){                
                String contrLabel = contrEntries[idx].getLabel();
                objResults.get(contrLabel).add(objJson.label);
            }
        }
        objEntries = null;
        objJsonEntries = null;
        system.debug('objResults--->' + objResults);
        return objResults;
    }

 @AuraEnabled
 public static List < String > getselectOptions(sObject objObject, string fld) {
  system.debug('objObject --->' + objObject);
  system.debug('fld --->' + fld);
  List < String > allOpts = new list < String > ();
  // Get the object type of the SObject.
  Schema.sObjectType objType = objObject.getSObjectType();
 
  // Describe the SObject using its object type.
  Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
 
  // Get a map of fields for the SObject
  map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
 
  // Get the list of picklist values for this field.
  list < Schema.PicklistEntry > values =
   fieldMap.get(fld).getDescribe().getPickListValues();
 
  // Add these values to the selectoption list.
  for (Schema.PicklistEntry a: values) {
   allOpts.add(a.getValue());
  }
  system.debug('allOpts ---->' + allOpts);
  allOpts.sort();
  return allOpts;
 }
   
    public static boolean getBusinessCases(){
        SelectedBCs.clear();
        if(Ligne.IsGouttiere__c){
            getBC('Gouttière',Ligne.Type__c,null,null,null,Ligne.Arcade__c =='Haut et bas'?2:1);
        }
        if(Ligne.IsICC__c){
/*          system.debug('Vue ' + Ligne.Inlay_core__c + '-' + Ligne.Dents_a_restorer__c);
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
            */
            if(!string.isblank(Ligne.Dents2__c)){
                getBC('Couronne',Ligne.Couronne__c,Ligne.Alliage__c,null,Ligne.Finition__c,(string.isblank(Ligne.Dents2__c))?0:Ligne.Dents2__c.split(';').size());
            }
            if(!string.isblank(Ligne.Dents__c)){
                getBC('Inlay core',Ligne.Type__c,Ligne.Alliage_Inlay_core__c,null,null,(string.isblank(Ligne.Dents__c))?0:Ligne.Dents__c.split(';').size());
            } 
        }
        if (Ligne.Recordtype.DeveloperName == 'PEI_Cire'){
            getBC('PEI, Cire',Ligne.Type__c,null,null,null,Ligne.Arcade__c =='Haut et bas'?2:1);
        }
        if (Ligne.Recordtype.DeveloperName == 'Services'){
            getBC('Réparations',Ligne.Type__c,null,null,Ligne.Finition__c,Ligne.Arcade__c =='Haut et bas'?2:1);
        }
        if ((Ligne.Recordtype.DeveloperName == 'Resine')||(Ligne.Recordtype.DeveloperName == 'ResineSansAffectation')){
            integer nbHaut = nbDents(true,Ligne.Dents2__c);
            integer nbBas = nbDents(false,Ligne.Dents2__c);
            if (nbHaut > 0){
                getBC('Résine',Ligne.Type__c,null,null,Ligne.Finition__c,nbHaut);
            }
            if (nbBas > 0){
                getBC('Résine',Ligne.Type__c,null,null,Ligne.Finition__c,nbBas);
            }
        }
        if (Ligne.Recordtype.DeveloperName == 'Stellite'){
            integer nbHaut = nbDents(true,Ligne.Dents2__c);
            integer nbBas = nbDents(false,Ligne.Dents2__c);
            if (nbHaut > 0){
                getBC('Stellite',null,null,null,Ligne.Finition__c,nbHaut);
            }
            if (nbBas > 0){
                getBC('Stellite',null,null,null,Ligne.Finition__c,nbBas);
            }
        }
        if (Ligne.Recordtype.DeveloperName == 'Ortho'){
            getBC('Ortho',Ligne.Type__c,null,null,null,Ligne.Arcade__c =='Haut et bas'?2:1);
        }
        if (Ligne.Recordtype.DeveloperName == 'Wax_up'){
            integer nbHaut = nbDents(true,Ligne.Dents__c);
            integer nbBas = nbDents(false,Ligne.Dents__c);
            if (nbHaut > 0){
                getBC('Projet esthétique',Ligne.Type__c,null,null,null,nbHaut);
            }
            if (nbBas > 0){
                getBC('Projet esthétique',Ligne.Type__c,null,null,null,nbBas);
            }
        }
        if (Ligne.Recordtype.DeveloperName == 'Facette'){
            getBC('Inlay onlay facette','Facette',Ligne.Type__c,null,Ligne.Finition__c,(string.isblank(Ligne.Dents__c))?0:Ligne.Dents__c.split(';').size());
        }
        if (Ligne.Recordtype.DeveloperName == 'Inlay_onlay'){
            getBC('Inlay onlay facette','Inlay/Onlay',Ligne.Type__c,null,Ligne.Finition__c,(string.isblank(Ligne.Dents__c))?0:Ligne.Dents__c.split(';').size());
        }
        if (Ligne.Recordtype.DeveloperName == 'Couronne_sur_implants'){
            if(!string.isblank(Ligne.Dents2__c)){
                getBC('Couronne sur implant',Ligne.Couronne__c,Ligne.Alliage__c,Ligne.Type_de_couronne__c,Ligne.Finition__c,Ligne.Accastillage__c,(string.isblank(Ligne.Dents2__c))?0:Ligne.Dents2__c.split(';').size());
            }
            if(!string.isblank(Ligne.Dents__c)){ 
                getBC('Pilier',Ligne.Couronne__c,null,Ligne.Type_de_couronne__c,null,Ligne.Accastillage__c,(string.isblank(Ligne.Dents__c))?0:Ligne.Dents__c.split(';').size());
            } 
        }

        if (Ligne.Recordtype.DeveloperName == 'Superstructure_et_barres'){
            if(!string.isblank(Ligne.Dents__c)){ 
                //getBC('Appareil',Ligne.Couronne__c,null,Ligne.Type_de_couronne__c,null,Ligne.Accastillage__c,(string.isblank(Ligne.Dents__c))?0:Ligne.Dents__c.split(';').size());
	            integer nbHaut = nbDents(true,Ligne.Dents__c);
    	        integer nbBas = nbDents(false,Ligne.Dents__c);
        	    if (nbHaut > 0){
	                getBC('Barre',null,null,Ligne.Type_de_couronne__c,Ligne.Finition__c,Ligne.Accastillage__c,nbHaut);
            	}
            	if (nbBas > 0){
	                getBC('Barre',null,null,Ligne.Type_de_couronne__c,Ligne.Finition__c,Ligne.Accastillage__c,nbBas);
            	}
            } 
            if(!string.isblank(Ligne.Dents2__c)){
                //getBC('Barre',null,null,null,Ligne.Finition__c,Ligne.Accastillage__c,(string.isblank(Ligne.Dents2__c))?0:Ligne.Dents2__c.split(';').size());
	            integer nbHaut = nbDents(true,Ligne.Dents2__c);
    	        integer nbBas = nbDents(false,Ligne.Dents2__c);
        	    if (nbHaut > 0){
	                getBC('Appareil',null,null,Ligne.Type_de_couronne__c,Ligne.Finition__c,Ligne.Accastillage__c,nbHaut);
            	}
            	if (nbBas > 0){
	                getBC('Appareil',null,null,Ligne.Type_de_couronne__c,Ligne.Finition__c,Ligne.Accastillage__c,nbBas);
            	}
            }
        }
        if (Ligne.Recordtype.DeveloperName == 'Planification_implantaire'){
            getBC('Planification implantaire',Ligne.Type__c,null,Ligne.Type_de_couronne__c,Ligne.Finition__c,(string.isblank(Ligne.Dents__c))?0:Ligne.Dents__c.split(';').size());
        }

        /*      if (Ligne.Recordtype.DeveloperName == 'Wax_up'){
            getBC('Projet esthétique','Wax-up',null,null,null,(string.isblank(Ligne.Dents__c))?0:Ligne.Dents__c.split(';').size());
        }*/
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
                    LC.Produit_finition__c = Unite.Produit__r.Finition__c;
                    LC.Produit_suivant__c = Unite.Produit__r.Suivant__c;
                    LC.Categorie__c = Unite.Produit__r.Categorie__c;
                    LCs.Add(LC);
                }
            }
/*          if (!trouve){
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

    // Récupération des Business cases implant
    public static void getBC(string SousEcran,string Type,string Materiau,string TypeCouronne, string Finition, string Accastillage,integer nb){ 
        for(Business_case__c BC:BCs){
            if(isOK(BC.Sous_cran__c,SousEcran)){
                system.debug('SSEcran OK' + BC);
                if(isOK(BC.Type__c,Type)){
                    system.debug('Type OK' + BC);
                    if(isOK(BC.Materiau__c,Materiau)){
                        system.debug('Materiau OK' + BC);
                        if(isOK(BC.Type_d_implant__c,TypeCouronne)){
                            system.debug('Type Couronne OK' + BC);
                            if(isOK(BC.Finition__c,Finition)){
                                system.debug('Finition OK' + BC);
                                if(isOK(BC.Accastillage__c,Accastillage)){
                                    system.debug('Accastilage OK' + BC);
                                    if((BC.Minimum__c>=0)&&(BC.Maximum__c>=0)){
                                        if ((nb>=BC.Minimum__c) && (nb<=BC.Maximum__c)){
                                            if(SelectedBCs.containskey(BC.Id)){
                                                SelectedBCs.put(BC.Id,SelectedBCs.get(BC.Id) + 1);
                                            }else{
                                                SelectedBCs.put(BC.Id,1);
                                            }
                                        } 
                                    }else{
                                        if(SelectedBCs.containskey(BC.Id)){
                                            SelectedBCs.put(BC.Id,SelectedBCs.get(BC.Id) + nb);
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
        }
    }

    // Récupération des Business cases standard
    public static void getBC(string SousEcran,string Type,string Materiau,string Options, string Finition, integer nb){ 
        system.debug(BCs.size());
        for(Business_case__c BC:BCs){
            if(isOK(BC.Sous_cran__c,SousEcran)){
                system.debug('SSEcran OK' + BC);
                if(isOK(BC.Type__c,Type)){
                    system.debug('Type OK' + BC);
                    if(isOK(BC.Materiau__c,Materiau)){
                        system.debug('Materiau OK' + BC);
                        if(isOK(BC.Type_d_implant__c,Options)){
                            system.debug('Options OK' + BC);
                            if(isOK(BC.Finition__c,Finition)){
                                system.debug('Finition OK' + BC);
                                if((BC.Minimum__c>=0)&&(BC.Maximum__c>=0)){
                                    if ((nb>=BC.Minimum__c) && (nb<=BC.Maximum__c)){
                                        if(SelectedBCs.containskey(BC.Id)){
                                            SelectedBCs.put(BC.Id,SelectedBCs.get(BC.Id) + 1);
                                        }else{
                                            SelectedBCs.put(BC.Id,1);
                                        }
                                    } 
                                }else{
                                    if(SelectedBCs.containskey(BC.Id)){
                                        SelectedBCs.put(BC.Id,SelectedBCs.get(BC.Id) + nb);
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
    }
    
    public static integer nbDents(boolean bhaut,string d){
        if (string.isblank(d)){ 
            return 0;
        }else{
            integer haut = 0;
            integer bas = 0;
            List<string> dts = d.split(';');
            for (string dt:dts){
                if (integer.valueof(dt) > 30){
                    bas++;
                }else{
                    haut++;
                }
            }
            if(bhaut){
                return haut;
            }else{
                return bas;
            }
        }
    }
    
    public static boolean isOK(string s1,string s2){ 
        if(string.isblank(s1)){
            return true;
        }else{
            if(string.isblank(s2)){
                return false;
            }else{
                return (s1 == s2);
            }
        }
    }

 
}