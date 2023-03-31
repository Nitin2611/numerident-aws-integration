public class AP01_Ordonnance {
    @AuraEnabled
    public static Boolean updateOrdonnanceAboutRating(String ordonnanceId, Decimal rate, Decimal maxRate){
        Ordonnance__c objOrdonnance = [SELECT ID, Rating__c FROM Ordonnance__c WHERE Id =:ordonnanceId];
        if (rate < 0 && rate > maxRate) {
            System.debug('Il faut un rate entre 0 et ' + maxRate);
            return false;
        }
      	objOrdonnance.Rating__c = rate;
        try {
            update objOrdonnance;
        } catch (Exception ex) {
            System.debug(ex.getMessage());
            return false;
        }
        return true;
    }
    
    @AuraEnabled
    public static Boolean updateOrdonnanceAboutChoiceOfRating(String ordonnanceId, String choices, String other){
        Ordonnance__c objOrdonnance = [SELECT ID, Choice_of_rating_other__c, Choice_of_rating__c FROM Ordonnance__c WHERE Id =:ordonnanceId];
        objOrdonnance.choice_of_rating__c = choices;
        
        if (other != null && other != '') {
            objOrdonnance.Choice_of_rating_other__c = other;
        }
  
        try {
            update objOrdonnance;
        } catch (Exception ex) {
            System.debug(ex.getMessage());
            return false;
        }
        return true;
    }
    
    @AuraEnabled(cacheable=true) 
    public static Ordonnance__c getRatingById(String ordonnanceId){
    	Ordonnance__c objOrdonnance = [SELECT ID, Rating__c, Statut__c FROM Ordonnance__c WHERE Id =:ordonnanceId];
        System.debug(objOrdonnance);
        return objOrdonnance;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getChoiceById(String ordonnanceId){
        Ordonnance__c objOrdonnance = [SELECT ID, Choice_of_rating__c FROM Ordonnance__c WHERE Id =:ordonnanceId];
        return objOrdonnance.Choice_of_rating__c;
    }
}