trigger PRG_FeedItem on FeedItem (after insert) {
	for(FeedItem F: trigger.new){
		if(f.ParentId.getSObjectType() == Ordonnance__c.SObjectType) {       
			//try{
			user u=[select firstname,lastname, profile.Name from user where id=:f.InsertedById limit 1];
			if ((u.profile.Name == 'Assistante')||(u.profile.Name == 'Praticien')){
				Ordonnance__c feedSubject =[select id,name from Ordonnance__c where id=:f.parentId limit 1];             
                                 
				Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
				message.toAddresses = new String[] { 'secretariat@numerident.fr' };
				//message.optOutPolicy = 'FILTER';
				message.subject = 'Nouveau commentaire sur l\'ordonnance ' + feedSubject.Name;
				message.HTMLBody = '<b>Message : </b>' +f.body +
                    '<b>Créé par : </b>' + u.firstname+' '+u.lastname +
                    '<br/><b>Ordonnance : </b>' + '<a href="https://numerident.lightning.force.com/' + feedSubject.id + '"">' + feedSubject.Name +'</a>'  ;
				Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
				Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
			//}catch(exception e){}
			}
		}
	}    
}