public class buttonNewLineController {
    @AuraEnabled
    Public Static List<recordtype> getRecordType () {
    	List<RecordType> rt;
    	string s = UserInfo.getUserId();
    	//if((s.startswith('0050Y000002EnVY'))||(s.startswith('0050Y000004cIc1'))||(s.startswith('0050Y000002rA1m'))||(s.startswith('0051v000004ewke'))){
    		rt =[select id, name from recordtype where SobjectType = 'ligne__c' and isActive=true];
    	//}else{
	    //    rt =[select id, name from recordtype where SobjectType = 'ligne__c' and developerName != 'Planification_implantaire' and isActive=true];
    	//}
        return rt;
    }

    @AuraEnabled
    Public Static Id createLigne(Id recordId, Id recordType) {
		System.debug('### Entering in createRecord');
        Ligne__c li = new Ligne__c();
        li.Ordonnance__c = recordId;
		li.RecordTypeId = recordType;
        li.Extraction__c = 'Extraire';
        insert li;
        
        return li.Id;
        
    }
}