public class SelectToothController {
    @AuraEnabled
    public static void saveTeeth(String teethValues, String recordId, String FieldId) {
        
/*        Ligne__c l = new Ligne__c();        
        String queryStr='SELECT Id,'+ FieldId + ' FROM Ligne__c WHERE Id = \'' + recordId + '\'';  
        List<Ligne__c> results=Database.query(queryStr);        
        l = results[0];    
        l.put( FieldId,'');
                
        Object[] values = (Object[])System.JSON.deserializeUntyped(teethValues);
        if(values.size()>0){
            l.put(FieldId,String.join(values, ';'));
        }
        
        update l; */
        Temp__c tmp = new Temp__c();
        tmp.Info__c = recordId + FieldId;
        tmp.Valeur__c = teethValues.replace('"",','');
        upsert tmp Info__c; 
    }
    
    @AuraEnabled
    public static String getTeeth(String recordId, String FieldId) {
        
        Ligne__c l = new Ligne__c();        
        String queryStr='SELECT Id,'+ FieldId + ' FROM Ligne__c WHERE Id = \'' + recordId + '\'';  
        List<Ligne__c> results=Database.query(queryStr);        
        l = results[0];    
        
        return (String)l.get(FieldId);
    }
}