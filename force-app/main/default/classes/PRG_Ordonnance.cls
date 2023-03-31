public without sharing class PRG_Ordonnance {
    public static List<Business_case__c> BCs;
    public static Map<Id,decimal> SelectedBCs;
    public static List<Unit_de_facturation__c> Unites;
    
    @future
    public static void UpdateStatutOrdonnance(List<Id> Ids){ 
        try{
            List<Opportunity> Opps = [Select Id,Ordonnance__c,Statut_ordonnace__c,Type_d_empreinte__c,closedate,PartageUsine__c from Opportunity 
                                        where StageName != 'Facturé' and StageName != 'Partiellement réglé' and StageName != 'Réglé' 
                                        and id in :Ids and Ordonnance__c != null];
            List<Ordonnance__c> Ords = new List<Ordonnance__c>();
            for (Opportunity opp:Opps){
                Ordonnance__c Ord = new Ordonnance__c();
                Ord.id = Opp.Ordonnance__c;
                Ord.Statut__c = Opp.Statut_ordonnace__c;
                Ord.Empreinte_numerique__c = (Opp.Type_d_empreinte__c == 'Numérique');
                ord.Date_classique__c = Opp.CloseDate;
                ord.Date_complexe__c = Opp.CloseDate;
                Ord.PartageUsine__c = Opp.PartageUsine__c;
                Ords.Add(Ord);
            }   
            if (Ords.size()>0){
                update Ords;
            }
        } catch (Exception e) {
            system.debug('Erreur dans UpdateStatutOrdonnance:' + e);
        }
    }

    public static void ClonerFrom(Id OrdId,Id PrecOrdId,boolean refaire,boolean finition){
/*      string letters= 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        String soql = PRG_Utils.getCreatableFieldsSOQL('Ordonnance__c','id=\'' + PrecOrdId + '\'');
        Ordonnance__c o = (Ordonnance__c)Database.query(soql);
        Ordonnance__c o2 = o.clone(false, true);
        if(refaire||finition){
            o2.Ordonnance_pr_c_dente__c = PrecOrdId;
            if(string.isblank(o2.Version__c)){
                o2.Version__c = 'A';
            }else{
                o2.Version__c = letters.mid(letters.indexOf(o2.Version__c, 1) + 2,1) ;
            }
        }
        o2.statut__c = 'Brouillon';
        o2.Id = OrdId;
        update o2;*/
        string soql;
        map<Id,Id> mapLignes = new map<Id,Id>(); 
        List<Ligne__c> Ls = [Select Id from Ligne__c where Ordonnance__c = :PrecOrdId];
        for (Ligne__c L:Ls){
//          if((!finition)||(L.Non_fini__c)){
            if(!Finition){
                soql = PRG_Utils.getCreatableFieldsSOQL('Ligne__c','id=\'' + L.Id + '\'');
                Ligne__c L1 = (Ligne__c)Database.query(soql);
                Ligne__c L2 = l1.clone(false, true);
//              if(L.Non_fini__c){
//                  L2.Finition__c = 'Finition';
//              }
                L2.Ordonnance__c = OrdId;
                insert L2;
                mapLignes.put(L.Id,L2.Id);
/*              if (L2.Finition__c == 'Finition'){
                    SelectedBCs = new Map<Id,decimal>();
                    List<ID> listID = new List<ID>();
                    listID.Add('a0g3E000001bcDJQAY');
                    Unites = [Select Business_case__c,Produit__c from Unit_de_facturation__c where Business_case__c in :listID];
                    getBusinessCases(L2);
                }*/
            }else{
            }
        }
        if(finition){
/*          SelectedBCs = new Map<Id,decimal>();
//          BCs = [Select Id,Name,Ecran__c,Sous_cran__c,Type__c,Materiau__c,Options__c,Finition__c,Minimum__c,Maximum__c, Option__c
//                  from Business_case__c where Ecran__c = 'Inlay core couronne' order by Poids__c DESC];
            List<ID> listID = new List<ID>();
            for(Business_case__c BC:BCs){
                listID.Add('a0g3E000001bcDJQAY');
            }
            listID.Add('a0g3E000001bcDJQAY');
            Unites = [Select Business_case__c,Produit__c from Unit_de_facturation__c where Business_case__c in :listID];
            getBusinessCases(L);*/
        }else{
            List<Ligne_de_commande__c> LCs = [Select Id,Ligne__c from Ligne_de_commande__c where Ordonnance__c = :PrecOrdId];
            for (Ligne_de_commande__c L:LCs){
                if(mapLignes.containskey(L.Ligne__c)){
                    soql = PRG_Utils.getCreatableFieldsSOQL('Ligne_de_commande__c','id=\'' + L.Id + '\'');
                    system.debug('Ici:' + soql);
                    Ligne_de_commande__c L1 = (Ligne_de_commande__c)Database.query(soql);
                    Ligne_de_commande__c L2 = l1.clone(false, true);
                    L2.Ligne__c = mapLignes.get(L.Ligne__c);
                    L2.Ordonnance__c = OrdId;
                    insert L2;
                }
            }
        }
    }
    public static void Cloner(Id OrdId,boolean refaire,boolean finition){ 
        Cloner(OrdId,refaire,finition,false,'','','');
    }
    public static void Cloner(Id OrdId,boolean refaire,boolean finition,boolean etapeSuivante,string strFinition,string strRefection, string strDetailRefection){
        Map<Id,decimal> SelectedBCs = new Map<Id,decimal>();
        List<Unit_de_facturation__c> Unites;
        string letters= 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        String soql = PRG_Utils.getCreatableFieldsSOQL('Ordonnance__c','id=\'' + OrdId + '\'');
        Ordonnance__c o = (Ordonnance__c)Database.query(soql);
        Ordonnance__c o2 = o.clone(false, true);
        if(refaire||finition||etapeSuivante){
            o2.Ordonnance_pr_c_dente__c = OrdId;
            if(string.isblank(o2.Version__c)){
                o2.Version__c = 'A';
            }else{
                o2.Version__c = letters.mid(letters.indexOf(o2.Version__c, 1) + 2,1) ;
            }
        }
        if(finition||etapeSuivante){
            o2.Finir__c = true;
            o2.Motif_de_refection__c = null;
            o2.Motif_detaille__c = '';      
            o2.Commentaires__c = strFinition; // o.Commentaires_de_finition__c; 
            o2.Commentaires_de_finition__c = '';
        }
        if(refaire){
            o2.Travail_r_parer_refaire__c = true;
            o2.Motif_de_refection__c = strRefection; // o.Motif_de_refection__c;
            o2.Motif_detaille__c = ''; // strDetailRefection; //o.Motif_detaille__c; 
            o2.Commentaires__c = strDetailRefection;    
            o2.Empreinte_numerique__c = false;
        }
        o2.statut__c = 'Brouillon';
        o2.Date_d_expedition__c = null;
        o2.Date__c = null;
        o2.Date_de_r_ception__c = null;
        o2.Dossier__c = null;
        o2.Generer__c = false;
        o2.Je_valide_cette_commande_pour_envoi__c = false;
        insert o2;
        map<Id,Id> mapLignes = new map<Id,Id>(); 
        List<Ligne__c> Ls = [Select Id,Finition__c,Non_fini__c from Ligne__c where Ordonnance__c = :OrdId];
        List<Ligne_de_commande__c> newLCs = new List<Ligne_de_commande__c>();
        for (Ligne__c L:Ls){
//          if((!finition)||(L.Non_fini__c)){
            if(!(finition||etapeSuivante)){
                soql = PRG_Utils.getCreatableFieldsSOQL('Ligne__c','id=\'' + L.Id + '\'');
                Ligne__c L1 = (Ligne__c)Database.query(soql);
                Ligne__c L2 = l1.clone(false, true);
//              if(L.Non_fini__c){
//                  L2.Finition__c = 'Finition';
//              }
                // Contrainte sur les alliages
                if((L2.Couronne__c=='CCZ : Céramo-céramique')||(L2.Couronne__c=='EMAX : Céramique monolithique (hors zircone)')||(L2.Couronne__c=='Provisoire')||(L2.Couronne__c=='FZ')||(L2.Couronne__c=='ENAMIC')||(L2.Couronne__c=='Full Zr Multilayer : Céramique monolithique Zircone')){
                    L2.Alliage__c = null;
                }
                L2.Ordonnance__c = o2.id;
                insert L2;
                mapLignes.put(L.Id,L2.Id);
/*              if (L2.Finition__c == 'Finition'){
                    SelectedBCs = new Map<Id,decimal>();
                    List<ID> listID = new List<ID>();
                    listID.Add('a0g3E000001bcDJQAY');
                    Unites = [Select Business_case__c,Produit__c from Unit_de_facturation__c where Business_case__c in :listID];
                    getBusinessCases(L2);
                }*/
            }else{
            //Nouvelles finitions
                List<Ligne_de_commande__c> LCs = new List<Ligne_de_commande__c>();
                if(etapeSuivante){
                    LCs = [Select Id,Produit_suivant__c,Produit_suivant__r.Type__c,Produit_suivant__r.Suivant__c,Produit_suivant__r.Finition__c,Ligne__c
                            from Ligne_de_commande__c where Ligne__c = :L.Id and Produit_suivant__c != null];
                    if(LCs.size()>0){
                        soql = PRG_Utils.getCreatableFieldsSOQL('Ligne__c','id=\'' + L.Id + '\'');
                        Ligne__c L1 = (Ligne__c)Database.query(soql);
                        Ligne__c L2 = l1.clone(false, true);
                        L2.Ordonnance__c = o2.id;
                        L2.Finition__c = null;
                        insert L2;
                        mapLignes.put(L.Id,L2.Id);
                        for (Ligne_de_commande__c LC:LCs){
                            soql = PRG_Utils.getCreatableFieldsSOQL('Ligne_de_commande__c','id=\'' + LC.Id + '\'');
                            Ligne_de_commande__c LC1 = (Ligne_de_commande__c)Database.query(soql);
                            Ligne_de_commande__c LC2 = LC1.clone(false, true);
                            LC2.Ligne__c = mapLignes.get(LC.Ligne__c);
                            LC2.Produit__c = LC.Produit_suivant__c;
                            LC2.Produit_finition__c = LC.Produit_suivant__r.Finition__c;
                            LC2.Produit_suivant__c = LC.Produit_suivant__r.Suivant__c;
                            LC2.Ordonnance__c = o2.id;
                            newLCs.Add(LC2);
                        }
                    }
                }
                if(finition){
                    LCs = [Select Id,Produit_finition__c,Produit_finition__r.Type__c,Produit_finition__r.Suivant__c,Produit_finition__r.Finition__c,Ligne__c 
                            from Ligne_de_commande__c where Ligne__c = :L.Id and Produit_finition__c != null];
                    if(LCs.size()>0){
                        soql = PRG_Utils.getCreatableFieldsSOQL('Ligne__c','id=\'' + L.Id + '\'');
                        Ligne__c L1 = (Ligne__c)Database.query(soql);
                        Ligne__c L2 = l1.clone(false, true);
                        L2.Ordonnance__c = o2.id;
                        L2.Finition__c = null;
                        insert L2;
                        mapLignes.put(L.Id,L2.Id);
                        for (Ligne_de_commande__c LC:LCs){
                            soql = PRG_Utils.getCreatableFieldsSOQL('Ligne_de_commande__c','id=\'' + LC.Id + '\'');
                            Ligne_de_commande__c LC1 = (Ligne_de_commande__c)Database.query(soql);
                            Ligne_de_commande__c LC2 = LC1.clone(false, true);
                            LC2.Ligne__c = mapLignes.get(LC.Ligne__c);
                            LC2.Produit__c = LC.Produit_finition__c;
                            LC2.Produit_finition__c = LC.Produit_finition__r.Finition__c;
                            LC2.Produit_suivant__c = LC.Produit_finition__r.Suivant__c;
                            LC2.Ordonnance__c = o2.id;
                            newLCs.Add(LC2);
                        }
                    }
                }
            //Fin nouvelles finitions
            }
        }
        if(finition||etapeSuivante){
/*          SelectedBCs = new Map<Id,decimal>();
//          BCs = [Select Id,Name,Ecran__c,Sous_cran__c,Type__c,Materiau__c,Options__c,Finition__c,Minimum__c,Maximum__c, Option__c
//                  from Business_case__c where Ecran__c = 'Inlay core couronne' order by Poids__c DESC];
            List<ID> listID = new List<ID>();
            for(Business_case__c BC:BCs){
                listID.Add('a0g3E000001bcDJQAY');
            }
            listID.Add('a0g3E000001bcDJQAY');
            Unites = [Select Business_case__c,Produit__c from Unit_de_facturation__c where Business_case__c in :listID];
            getBusinessCases(L);*/
            //Nouvelles finitions
            /*Unites = [Select Id,Business_case__c,Produit__c from Unit_de_facturation__c];
                    List<Ligne_de_commande__c> newLCs = new List<Ligne_de_commande__c>();

                List<Ligne_de_commande__c> LCs = new List<Ligne_de_commande__c>();
                for (Ligne__c L:Ls){
                if(o.Etape_suivante__c == 'l\'étape suivante'){
                    LCs = [Select Id,Quantite__c,Business_case__r.BC_Etape_suivante__c,Business_case__r.BC_de_finition__c from Ligne_de_commande__c where Ligne__c = :L.Id and Business_case__r.BC_Etape_suivante__c != null];
                    for (Ligne_de_commande__c L1:LCs){
                        SelectedBCs.put(L1.Business_case__r.BC_Etape_suivante__c,L1.Quantite__c);  
                    }
                }
                if(o.Etape_suivante__c == 'la finition'){
                    LCs = [Select Id,Quantite__c,Business_case__r.BC_Etape_suivante__c,Business_case__r.BC_de_finition__c from Ligne_de_commande__c where Ligne__c = :L.Id and Business_case__r.BC_de_finition__c != null];
                    for (Ligne_de_commande__c L1:LCs){
                        SelectedBCs.put(L1.Business_case__r.BC_de_finition__c,L1.Quantite__c); 
                    }
                }*/
                
/*            for (Ligne_de_commande__c L:LCs){
                if(mapLignes.containskey(L.Ligne__c)){
                    soql = PRG_Utils.getCreatableFieldsSOQL('Ligne_de_commande__c','id=\'' + L.Id + '\'');
                    system.debug('Ici:' + soql);
                    Ligne_de_commande__c L1 = (Ligne_de_commande__c)Database.query(soql);
                    Ligne_de_commande__c L2 = l1.clone(false, true);
                    L2.Ligne__c = mapLignes.get(L.Ligne__c);
                    L2.Ordonnance__c = o2.id;
                    if(refaire){
                        L2.A_refaire__c = true;
                    }
                    insert L2;
                }
            }*/

            /*boolean trouve = false;
            for (String BCid : SelectedBCs.keySet()){
                for(Unit_de_facturation__c Unite:Unites){
                    if(Unite.Business_case__c == BCId){
                        trouve = true;
                        Ligne_de_commande__c LC = new Ligne_de_commande__c();
                        LC.Ligne__c = mapLignes.get(L.Id);
                        LC.Business_case__c = BCid;
                        LC.Quantite__c = SelectedBCs.get(BCId);
                        LC.Ordonnance__c = o2.id;
                        LC.Produit__c = Unite.Produit__c;
                        newLCs.Add(LC);
                    }
                }
            }
        }*/
        if(newLCs.size()>0){
            insert newLCs;
        }
            
            //Fin nouvelles finitions
        }else{
            List<Ligne_de_commande__c> LCs = [Select Id,Ligne__c from Ligne_de_commande__c where Ordonnance__c = :OrdId];
            for (Ligne_de_commande__c L:LCs){
                if(mapLignes.containskey(L.Ligne__c)){
                    soql = PRG_Utils.getCreatableFieldsSOQL('Ligne_de_commande__c','id=\'' + L.Id + '\'');
                    system.debug('Ici:' + soql);
                    Ligne_de_commande__c L1 = (Ligne_de_commande__c)Database.query(soql);
                    Ligne_de_commande__c L2 = l1.clone(false, true);
                    L2.Ligne__c = mapLignes.get(L.Ligne__c);
                    L2.Ordonnance__c = o2.id;
                    if(refaire){
                        L2.A_refaire__c = true;
                    }
                    insert L2;
                }
            }
        }
    }
    public static void notifEnvoye(Id OrdId){
        List<Opportunity> Opps = [Select Id,stageName from Opportunity where Ordonnance__c = :OrdId and stageName='Validé'];
        if(Opps.size()==1){
            Opps[0].stageName = 'Envoyé au laboratoire';
            try{
                update Opps[0];
            }
            catch(exception e){} 
        }
    }
    @future(callout=true)
    public static void PostTraitementValidation(Id OrdId,Id OppId,string OPPName,Id ContactId){
        try{
        List<Ligne_de_commande__c> Ls = [Select Id,Description__c,Complement0__c,Complement1__c,Complement2__c,
                                         Complement3__c,Complement4__c,Complement5__c,ProdCol2__c,
                                         ProdCol2A__c,ProdCol2B__c,ProdCol2C__c
                                         from Ligne_de_commande__c where Ordonnance__c = :OrdId];    
        if(Ls.size()>0){
	        for (Ligne_de_commande__c L:Ls){
        		L.Description__c = string.isblank(L.Complement0__c)?'':L.Complement0__c;
        		L.Description__c += string.isblank(L.Complement1__c)?'':' ' + L.Complement1__c;
        		L.Description__c += string.isblank(L.Complement2__c)?'':' ' + L.Complement2__c;
        		L.Description__c += string.isblank(L.Complement3__c)?'':' ' + L.Complement3__c;
        		L.Description__c += string.isblank(L.Complement4__c)?'':' ' + L.Complement4__c;
        		L.Description__c += string.isblank(L.Complement5__c)?'':' ' + L.Complement5__c;
                L.Description__c = L.Description__c.trim();
                L.ProdCol2__c = '';
                L.ProdCol2__c += string.isblank(L.ProdCol2A__c)?'':' ' + L.ProdCol2A__c;
                L.ProdCol2__c += string.isblank(L.ProdCol2B__c)?'':' ' + L.ProdCol2B__c;
                L.ProdCol2__c += string.isblank(L.ProdCol2C__c)?'':' ' + L.ProdCol2C__c;
                L.ProdCol2__c = L.ProdCol2__c.trim();
    	    }
            update Ls;
        }
        List<ContentDocumentLink> Lks = [SELECT ContentDocumentId,LinkedEntityId,ShareType,Visibility FROM ContentDocumentLink WHERE LinkedEntityId = :OrdId ];
        List<ID> LksId = new List<Id>();
        for(ContentDocumentLink Lk:Lks){
            LksId.Add(Lk.ContentDocumentId);
        }
//        List<ContentVersion> Atts = [SELECT Id,VersionData,Title,FileExtension FROM ContentVersion WHERE ContentDocumentId in :LksID AND IsLatest = true and (FileExtension ='STL' or FileExtension ='DCM' or FileExtension ='stl' or FileExtension ='dcm' or FileExtension ='3OXZ' or FileExtension ='3oxz')];
        List<ContentVersion> Atts = [SELECT Id,Title,FileExtension FROM ContentVersion WHERE ContentDocumentId in :LksID AND IsLatest = true and (FileExtension ='STL' or FileExtension ='DCM' or FileExtension ='stl' or FileExtension ='dcm' or FileExtension ='3OXZ' or FileExtension ='3oxz')];
        if((Atts.size()>0)&&(ContactId!=null)){
         	List<OrgWideEmailAddress> owas = [select id, DisplayName, Address from OrgWideEmailAddress where Address='serviceclient@dentegolab.fr' limit 1];
            EmailTemplate templateId = [Select id from EmailTemplate where DeveloperName = 'Digital_job' limit 1];
            List<string> toAddresses = new List<string>();
	        toAddresses.Add('serviceclient@dentegolab.fr');
	        //toAddresses.Add('frederic.loembe@pragma-consulting.fr');
	        List<Contact> Cs = [Select AccountId,Account.Name from Contact where Id=:ContactId];
            List<Contact> FullCs = [Select Id,email from Contact where AccountID =:Cs[0].AccountId and (LastName='Digital job' or Contact_digital__c=true) and Id!=:ContactId];
            for(Contact C:FullCs){
                if(!string.isBlank(C.email)){
                    toAddresses.Add(C.email);
                }
            }
	
            List<Messaging.EmailFileAttachment> efas = new List<Messaging.EmailFileAttachment>();

            PageReference pdfOF =  Page.OrderFormPrat;
            pdfOF.getParameters().put('id',Ordid); 
            pdfOF.setRedirect(true);
            Blob b = pdfOF.getContent();
            Messaging.EmailFileAttachment efaOF = new Messaging.EmailFileAttachment();
            efaOF.setFileName('Order form - ' + OPPName + '.pdf');
            efaOF.setBody(b);
            efas.Add(efaOF);

            PageReference pdfBC =  Page.BonCommandeV2;
            pdfBC.getParameters().put('id',Ordid); 
            pdfBC.setRedirect(false);
            b = pdfBC.getContentAsPDF();
            Messaging.EmailFileAttachment efaBC = new Messaging.EmailFileAttachment();
            efaBC.setFileName(OPPName + '.pdf');
            efaBC.setBody(b);
            efas.Add(efaBC);
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateID(templateId.Id); 
            if(owas.size()==1){
               	mail.setOrgWideEmailAddressId(owas[0].id);
            }
            mail.setTargetObjectId(ContactId);
            mail.setCcAddresses(toAddresses);
           	mail.setWhatId(Ordid);        
           	mail.setSaveAsActivity(false);
           	mail.setFileAttachments(efas);
           	Messaging.SendEmailResult [] r2 = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});

            /*for(ContentVersion Att:Atts){
	        	HttpRequest req = new HttpRequest();
    	    	req.setEndpoint('https://content.dropboxapi.com/2/files/upload');
        		req.setHeader('Dropbox-API-Arg', '{"path":  "/Home/TEST/' + Cs[0].Account.Name + '/' + OPPName + '/' + Att.Title +'.' + Att.FileExtension +'","mode": "add"}');
        		req.setHeader('Content-Type', 'application/octet-stream');
        		req.setHeader('Authorization','Bearer NmuBWDZHghQAAAAAAAAAAWul2s3aS6V9Czta9lTMTHYkjqvUswA9Wq58UkNFdcpp');
        		req.setBodyAsBlob(Att.VersionData);
        		req.setMethod('POST');
        		req.setTimeout(60*1000);
        		HTTPResponse response = new Http().send(req);
				system.debug('response ' +response.getBody());            
            }*/
        }

        }catch(Exception e){}
    }
    public static void SendDigitalEmail(Opportunity pOpp){
        Opportunity Opp = [Select Id,Ordonnance__c,Name,Type_d_empreinte__c,Usine__c from Opportunity where id=:pOpp.id];
        Id UsineContactId;
        List<Contact> Cs = [Select Id from Contact where AccountID =:Opp.Usine__c and (LastName='Digital job' or Contact_digital__c=true) order by LastModifiedDate DESC];
        if(Cs.size()>0){
            UsineContactId = Cs[0].Id;
        }
        if(Opp.Type_d_empreinte__c == 'Numérique'){
            if(UsineContactId!=null){
		        PostTraitementValidation(Opp.Ordonnance__c,Opp.Id,Opp.Name,UsineContactId);
            }
        }
    }
    
    public static boolean FichierEmpreinteNumerique(Id OrdId){
        List<ContentDocumentLink> Lks = [SELECT ContentDocumentId,LinkedEntityId,ShareType,Visibility FROM ContentDocumentLink WHERE LinkedEntityId = :OrdId ];
        List<ID> LksId = new List<Id>();
        for(ContentDocumentLink Lk:Lks){
            LksId.Add(Lk.ContentDocumentId);
        }
        List<ContentVersion> Atts = [SELECT Id FROM ContentVersion WHERE ContentDocumentId in :LksID AND IsLatest = true and (FileExtension ='STL' or FileExtension ='DCM' or FileExtension ='stl' or FileExtension ='dcm' or FileExtension ='dcm' or FileExtension ='3OXZ' or FileExtension ='3oxz')];
        return (Atts.size()>0);
    }
    
    public static Id GenerationDossier(Ordonnance__c Ord){
        User U = [Select Id,ContactId,Contact.Account.OwnerId,Contact.Usine__c,Contact.Account.Blocage_numerique__c 
                  from User where Id=:UserInfo.GetUserId()];
        List<ContentDocumentLink> Lks = [SELECT ContentDocumentId,LinkedEntityId,ShareType,Visibility FROM ContentDocumentLink WHERE LinkedEntityId = :Ord.Id ];
        List<ID> LksId = new List<Id>();
        for(ContentDocumentLink Lk:Lks){
            LksId.Add(Lk.ContentDocumentId);
        }
        List<ContentVersion> Atts = [SELECT Id FROM ContentVersion WHERE ContentDocumentId in :LksID AND IsLatest = true and (FileExtension ='STL' or FileExtension ='DCM' or FileExtension ='stl' or FileExtension ='dcm' or FileExtension ='dcm' or FileExtension ='3OXZ' or FileExtension ='3oxz')];
        Id UsineContactId;
        Opportunity Opp = new Opportunity();
        Opp.Name = Ord.Name;
        Opp.CloseDate = Ord.Date__c;
        boolean BlocageNumerique = false;
        if(U.ContactId != null){
            BlocageNumerique = U.Contact.Account.Blocage_numerique__c ;
        }
        if((Ord.Empreinte_numerique__c)||(Atts.size()>0)){
            Opp.Type_d_empreinte__c = 'Numérique';
            if(BlocageNumerique){
 	           Opp.StageName = 'Validé';
            }else{
 	           Opp.StageName = 'En cours de traitement';
            }
        }else{
	        Opp.StageName = 'Validé';
        }
        if(U.ContactId != null){
            Opp.OwnerId = U.Contact.Account.OwnerId; 
            Opp.Praticien__c = U.ContactId; 
            Opp.Usine__c = U.Contact.Usine__c;
            List<Contact> Cs = [Select Id from Contact where AccountID =:Opp.Usine__c and LastName='Digital job' order by LastModifiedDate DESC];
            if(Cs.size()>0){
                UsineContactId = Cs[0].Id;
            }
        }else{
            Opp.OwnerId = '0050Y000002rA1m'; 
        }
        if(!string.isblank(Ord.Motif_detaille__c)){
            OPP.Commentaires__c = Ord.Motif_detaille__c + ' ' + Ord.Commentaires__c;
        }else{
            OPP.Commentaires__c = Ord.Commentaires__c;
        }
        Opp.Raison_de_r_fection__c = Ord.Motif_de_refection__c;
        Opp.Patient__c = Ord.Patient__c;
        OPP.Teinte__c = ORD.Teinte__c;
        Opp.Teinte_bas__c = Ord.Teinte_bas__c;
        Opp.Teinte_haut__c = Ord.Teinte_haut__c;
        Opp.Travaux_d_origine__c = null;
        Opp.A_refaire__c = Ord.Travail_r_parer_refaire__c;
        Opp.Ordonnance__c = Ord.Id;
        Opp.Urgence__c = Ord.Travail_URGENT__c;
        Opp.Date_pr_visionnelle_de_livraison__c = Ord.Date_pr_visionnelle_de_livraison__c ;
        //Opp.PriceBook2Id = 
        insert Opp; 
        //PostTraitementValidation(Ord.Id,Opp.Id,Opp.Name,UsineContactId);
        Opp = [Select Id,PriceBook2Id,A_refaire__c,Type_d_empreinte__c from Opportunity where Id =:Opp.Id];
        List<Ligne_de_commande__c> Ls = [Select Id,Details__c,Produit__c,Quantite__c,nbDents__c,A_refaire__c
                                            from Ligne_de_commande__c where Ordonnance__c = :Ord.Id];
        List<PriceBookEntry> PBEs = [Select Id,Product2Id,UnitPrice from PriceBookEntry where PriceBook2Id =: Opp.PriceBook2Id];
        map<Id,PriceBookEntry> mapPBE = new map<Id,PriceBookEntry>();
        for(PriceBookEntry PBE:PBEs){
            mapPBE.put(PBE.Product2Id,PBE);
        }
        List<OpportunityLineItem> OppLis = new List<OpportunityLineItem>(); 
        if(Opp.Type_d_empreinte__c == 'Numérique'){
        	List<ContentDocumentLink> NewLks = new List<ContentDocumentLink>();
	        for(ContentDocumentLink L:Lks){
    	        ContentDocumentLink NewL = new ContentDocumentLink();
        	    NewL.ContentDocumentId = L.ContentDocumentId;
            	NewL.LinkedEntityId = Opp.Id;
            	NewL.ShareType = L.ShareType;
            	NewL.Visibility = L.Visibility;
            	NewLks.Add(NewL);
        	}
        	if(NewLks.size()>0){
            	insert NewLks;
        	}       
            List<PriceBookEntry> PBENumerique = [Select Id,Product2Id,UnitPrice from PriceBookEntry where PriceBook2Id =: Opp.PriceBook2Id and Product2.Name ='Forfait traitement empreinte numérique'];
            if(PBENumerique.size()>0){
	            OpportunityLineItem OppLi = new OpportunityLineItem();
    	        OppLI.OpportunityId = Opp.Id;
        	    OppLi.PriceBookEntryId = PBENumerique[0].Id; 
               	OppLi.UnitPrice = PBENumerique[0].UnitPrice;  
            	OppLi.Quantity = 1;
            	OppLis.Add(OppLi);
            }
        }
        for (Ligne_de_commande__c L:Ls){
            OpportunityLineItem OppLi = new OpportunityLineItem();
            OppLI.OpportunityId = Opp.Id;
            OppLi.PriceBookEntryId = mapPBE.get(L.Produit__c).Id; 
            OppLi.A_refaire__c = L.A_refaire__c;
            if(L.A_refaire__c){
                OppLi.UnitPrice = 0;
            }else{
                OppLi.UnitPrice = mapPBE.get(L.Produit__c).UnitPrice;  
            }
            OppLi.Quantity = L.Quantite__c;
            Oppli.nbDents__c = L.nbDents__c;
            Oppli.Ligne_de_commande__c = L.Id; 
            OppLis.Add(OppLi);
        }
        if(OppLis.size()>0){
            insert oppLis;
        }
        return Opp.Id;
    }
    public static boolean getBusinessCases(Ligne__c ligne){
        SelectedBCs.clear();
        if(Ligne.IsGouttiere__c){
            //getBC('Gouttière',Ligne.Type__c,null,null,null,Ligne.Arcade__c =='Haut et bas'?2:1);
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
            getBC('Couronne',Ligne.Couronne__c,Ligne.Alliage__c,null,Ligne.Finition__c,(string.isblank(Ligne.Dents_a_restorer__c))?0:Ligne.Dents_a_restorer__c.split(';').size());
            //getBC('Inlay core',Ligne.Type__c,Ligne.Alliage_Inlay_core__c,null,null,(string.isblank(Ligne.Inlay_core__c))?0:Ligne.Inlay_core__c.split(';').size());
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
    
    public static void getBC(string SousEcran,string Type,string Materiau,string Options, string Finition, integer nb){
        for(Business_case__c BC:BCs){
            if(isOK(BC.Sous_cran__c,SousEcran)){
                if(isOK(BC.Type__c,Type)){
                    system.debug('Type OK' + BC);
                    if(isOK(BC.Materiau__c,Materiau)){
                        system.debug('Materiau OK' + BC);
                        if(isOK(BC.Options__c,Options)){
                            system.debug('Options OK' + BC);
                            if(isOK(BC.Finition__c,Finition)){
                                system.debug('Finition OK' + BC);
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