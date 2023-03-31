public class champsLightning {
    @AuraEnabled
    public static String getField(String recordId, String FieldId) {
       
        Ligne__c l = new Ligne__c();        
        String queryStr='SELECT Id,'+ FieldId + ' FROM Ligne__c WHERE Id = \'' + recordId + '\''; 
        List<Ligne__c> results=Database.query(queryStr);
               
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        String endpoint = URL.getSalesforceBaseUrl().toExternalForm() +
        '/services/data/v41.0/ui-api/object-info/Ligne__c/picklist-values/0125E00000010IeQAI/'+FieldId+'/';
            
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        if(!Test.isRunningTest())
            req.setHeader('Authorization', 'OAuth ' + PRG_Utils.getSessionIdFromVFPage(Page.SessionID));
        else
           req.setHeader('Authorization', 'OAuth SESSION ID');
        
        HttpResponse res = null;
        try{
            res = h.send(req);
            String response = res.getBody();
            System.debug('response '+response);
            return null;

        }
        catch(Exception e){
            System.debug('Error '+e.getMessage());
            
             return null;
        }
        
       // return (String)l.get(FieldId);
    }


   /* public class JSON2Apex {
	@AuraEnabled
		public  JSON2Apex {
		public ControllerValues controllerValues;
		public Object defaultValue;
		public String url;
		public List<Values> values;
		}

		public  Values {
		public Object attributes;
		public String label;
		public List<ControllerValues> validFor;
		public String value;
		}

		public  ControllerValues {
		}

	
		public static JSON2Apex parse(String json) {
		return (JSON2Apex) System.JSON.deserialize(json, JSON2Apex.class);
		}
} */

    @AuraEnabled
    public static void savefield(String fieldvalue, String recordId, String FieldId) {
        
        Ligne__c fi = new Ligne__c();        
        String queryStr='SELECT Id,'+ FieldId + ' FROM Ligne__c WHERE Id = \'' + recordId + '\'';  
        List<Ligne__c> results=Database.query(queryStr);        
        fi = results[0];    
        fi.put( FieldId,'');
        fi.put(FieldId,fieldvalue);
             
               /*
        Object[] values = (Object[])System.JSON.deserializeUntyped(fieldvalues);
        if(values.size()>0){
            );
        }
        */
        update fi;
    }
    
    @AuraEnabled
    public static List<String> getPicklistValues(String FieldName){
        
        List<String> results = new List<String>();
        
        if(FieldName == 'Finition__c'){
            Schema.DescribeFieldResult res = Ligne__c.Finition__c.getDescribe();            
            List<Schema.PicklistEntry> ple = res.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                results.add(pickListVal.getLabel());
                
            }  
        }
        if(FieldName == 'Produit__c'){
            if('Type__c' != 'none'){
            Schema.DescribeFieldResult res = Ligne__c.Produit__c.getDescribe();            
            List<Schema.PicklistEntry> ple = res.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                results.add(pickListVal.getLabel());
            }  
        }
            else{
               // Ligne__c.Produit__c == 'none';
            }
        }
        if(FieldName == 'Alliage_Inlay_core__c'){
            Schema.DescribeFieldResult res = Ligne__c.Alliage_Inlay_core__c.getDescribe();            
            List<Schema.PicklistEntry> ple = res.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                results.add(pickListVal.getLabel());
            }  
        }
        if(FieldName == 'Liaison__c'){
            Schema.DescribeFieldResult res = Ligne__c.Liaison__c.getDescribe();            
            List<Schema.PicklistEntry> ple = res.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                results.add(pickListVal.getLabel());
            }  
        }
        if(FieldName == 'Arcade__c'){
            Schema.DescribeFieldResult res = Ligne__c.Arcade__c.getDescribe();            
            List<Schema.PicklistEntry> ple = res.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                results.add(pickListVal.getLabel());
            }  
        }
        if(FieldName == 'Alliage__c'){
            if('Couronne__c' != 'none'){
            Schema.DescribeFieldResult res = Ligne__c.Alliage__c.getDescribe();            
            List<Schema.PicklistEntry> ple = res.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                results.add(pickListVal.getLabel());
            }  
        }
        }
        if(FieldName == 'Couronne__c'){
            if('Type__c' != 'none'){
            Schema.DescribeFieldResult res = Ligne__c.Couronne__c.getDescribe();            
            List<Schema.PicklistEntry> ple = res.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                results.add(pickListVal.getLabel());
            }  
        }
        }
        if(FieldName == 'Type__c'){
            Schema.DescribeFieldResult res = Ligne__c.Type__c.getDescribe();            
            List<Schema.PicklistEntry> ple = res.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                results.add(pickListVal.getLabel());
            }  
        }
        if(FieldName == 'Options__c'){
            Schema.DescribeFieldResult res = Ligne__c.Options__c.getDescribe();            
            List<Schema.PicklistEntry> ple = res.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                results.add(pickListVal.getLabel());
            }  
        }
        
        
        return results;
    }
}