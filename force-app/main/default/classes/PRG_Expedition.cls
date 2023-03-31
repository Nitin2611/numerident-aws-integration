public with sharing class PRG_Expedition {
    @future(callout=true)
	public static void MailTransitUsine(string ExpId){
		Expedition__c Exp = [Select Id,Destinataire__c,email_transitaire__c,Destinataire__r.Name,AWB__c from Expedition__c where Id=:ExpId];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		List<Messaging.EmailFileAttachment> efas = new List<Messaging.EmailFileAttachment>();

        PageReference pdfLetter =  Page.CustomProForma;
   	    pdfLetter.getParameters().put('id',Expid); 
       	pdfLetter.setRedirect(true);
       	Blob b;
 		if (Test.IsRunningTest()){
        	b =Blob.valueOf('UNIT.TEST');
   		}else{
	      		b = pdfLetter.getContent();
   		}       	
	    Messaging.EmailFileAttachment efaLetter = new Messaging.EmailFileAttachment();
    	string FileName = 'PROFORMA' + string.valueof(date.today().year()) + ('0' + string.valueof(date.today().month())).right(2) + ('0' + string.valueof(date.today().day())).right(2) + '-' + Exp.Destinataire__r.Name + '.pdf';
   	    efaLetter.setFileName(FileName);
	    efaLetter.setBody(b);
	    efas.Add(efaLetter);
            
        List<ContentDocumentLink> Lks = [SELECT ContentDocumentId,LinkedEntityId,ShareType,Visibility 
                                         FROM ContentDocumentLink WHERE LinkedEntityId = :ExpId ];
        List<ID> LksId = new List<Id>();
        for(ContentDocumentLink L:Lks){
	        LksId.Add(L.ContentDocumentId);
    	}
		List<ContentVersion> Atts = [SELECT Id,Title,VersionData,FileExtension FROM ContentVersion WHERE ContentDocumentId in :LksID AND IsLatest = true];
        for (ContentVersion Att:Atts){
            Messaging.EmailFileAttachment efaAtt = new Messaging.EmailFileAttachment();
	   	  	efaAtt.setFileName(Att.Title + '.' + Att.FileExtension);
		   	efaAtt.setBody(Att.VersionData);
	       	efas.Add(efaAtt);
        }                             
	    email.setSubject( 'Numerident - Facture ProForma / Tracking Number ' + Exp.AWB__c );
	    List<string> toAddresses = new List<string>();
	    //toAddresses.Add(userinfo.GetUserEmail());
	    toAddresses.Add(Exp.email_transitaire__c);
        toAddresses.Add('secretariat@numerident.fr');
        List<Contact> Cs = [Select Id,Email from Contact where Account.Id =:Exp.Destinataire__c and email!=null and contact_tracking_number__c=true];
        for(Contact C:Cs){
            toAddresses.Add(C.email);
        }
	    email.setToAddresses( toAddresses );
        email.setPlainTextBody( 'Bonjour,\nCi jointe la facture d\'export de ce jour.\nHere is the Tracking Number of the parcel we send today '+ Exp.AWB__c + ', you will receive it normally tomorrow.\nExcellente journée,\n\nLaboratoire Numerident\n23 bis rue Barthelemy Danjou\n92100 Boulogne-Billancourt\n\nTel :  01 58 57 96 32' );

        List<OrgWideEmailAddress> owas = [select id, DisplayName, Address from OrgWideEmailAddress where Address='serviceclient@dentegolab.fr' limit 1];
        if(owas.size()==1){
           	email.setOrgWideEmailAddressId(owas[0].id);
        }

       email.setFileAttachments(efas);
       Messaging.SendEmailResult [] r1 = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
        
    }

    @future(callout=true)
	public static void MailCustom(string ExpId,string Usine){
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		List<Messaging.EmailFileAttachment> efas = new List<Messaging.EmailFileAttachment>();

        PageReference pdfLetter =  Page.CustomProForma;
   	    pdfLetter.getParameters().put('id',Expid); 
       	pdfLetter.setRedirect(true);
       	Blob b;
 		if (Test.IsRunningTest()){
        	b =Blob.valueOf('UNIT.TEST');
   		}else{
	       	b = pdfLetter.getContent();
   		}       	
        Messaging.EmailFileAttachment efaLetter = new Messaging.EmailFileAttachment();
        string FileName = 'PROFORMA' + string.valueof(date.today().year()) + ('0' + string.valueof(date.today().month())).right(2) + ('0' + string.valueof(date.today().day())).right(2) + '-' + Usine + '.pdf';
   	    efaLetter.setFileName(FileName);
       	efaLetter.setBody(b);
       	efas.Add(efaLetter);

        email.setSubject( 'Numerident - Facture ProForma' );
        List<string> toAddresses = new List<string>();
        toAddresses.Add(userinfo.GetUserEmail());
        toAddresses.Add('secretariat@numerident.fr');
        email.setToAddresses( toAddresses );
        email.setPlainTextBody( 'Bonjour,\nCi jointe la facture d\'export de ce jour.\nExcellente journée,\n\nLaboratoire Numerident\n23 bis rue Barthelemy Danjou\n92100 Boulogne-Billancourt\n\nTel :  01 58 57 96 32' );

        email.setFileAttachments(efas);
        Messaging.SendEmailResult [] r1 = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
	}
}