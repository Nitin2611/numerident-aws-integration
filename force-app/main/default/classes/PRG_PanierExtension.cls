public class PRG_PanierExtension {
	private final Panier__c P;

    public List<Panier__c> getPaniers(){
        return [SELECT Name,Date__c,Compte__r.AccountNumber, Compte__r.Name,Compte__r.BillingStreet,Compte__r.BillingPostalCode,Compte__r.BillingCity,(SELECT Patient__c, Name,Praticien__r.FirstName, Praticien__r.LastName FROM Opportunit_s__r) from Panier__c where Date__c = :P.date__c];
    }
    
    public PRG_PanierExtension(ApexPages.StandardController stdController) { 
        this.P = (Panier__c)stdController.getRecord();
    }
}