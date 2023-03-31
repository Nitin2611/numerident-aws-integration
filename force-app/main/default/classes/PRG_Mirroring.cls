public with sharing class PRG_Mirroring {
	@future
    public static void MirrorOppLineItems(list<Id> OppLiIds){
    	List<OpportunityLineItem> OppLis = [Select Id,OpportunityId,Quantity,Product2.Product_Name__c,Product2.Name,Description 
    										from OpportunityLineItem where Id in :OppLiIds];
    	List<Mirror__c> Ms = new List<Mirror__c>();
    	for(OpportunityLineItem OppLi:OppLis){
    		Mirror__c M = new Mirror__c();
    		M.LineId__c = OppLi.Id;
    		if(!string.isblank(OppLi.Product2.Product_Name__c)){
	    		M.Name = OppLi.Product2.Product_Name__c;
    		}else{
    			M.Name = OppLi.Product2.Name;
    		}
    		M.Description__c = OppLi.Description;
    		M.Opportunite__c = OppLi.OpportunityId;
    		M.Quantity__c = OppLi.Quantity;
    		MS.Add(M);
    	}
    	if(Ms.size()>0){
    		upsert Ms LineId__c;
    	}
    }
	@future
    public static void DeleteOppLineItems(list<Id> OppLiIds){
    	try{
    		List<Mirror__c> Ms = [Select Id from Mirror__c where LineId__c in :OppLiIds];
    		if (Ms.size() > 0){
	    		delete Ms;
    		}
    	}
    	catch (exception e){
    	}
    }
}