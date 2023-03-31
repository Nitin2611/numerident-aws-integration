public with sharing class PRG_OrdonnacesFilles {
	@AuraEnabled
    public static List<Ordonnance__c> OrdFilles(Id recordId) {
        return [Select Id,Name,A_finir__c,A_refaire__c,Statut__c,URL__c from Ordonnance__c 
        			where Ordonnance_pr_c_dente__c = :recordId and  Statut__c <> 'Rejetée' 
        			and (A_finir__c = true or A_refaire__c = true)];
    }
}