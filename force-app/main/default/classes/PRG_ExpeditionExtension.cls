public class PRG_ExpeditionExtension {

    private final Expedition__c Exp;

    public List<Opportunity> getExpOps(){
        return [SELECT Travail_suivre__c,DateOrderForm__c,CloseDate, Flop_10__c, Demande_sp_ciale__c, Id, Name,A_refaire__c,Urgence__c,Origin__c,Motif_d_taill_de_r_fection__c, (SELECT Id, Description,Ligne_de_commande__r.Complement0__c, Ligne_de_commande__r.Complement1__c, Ligne_de_commande__r.Complement3__c,Ligne_de_commande__r.Complement4__c,Ligne_de_commande__r.Complement5__c,Ligne_de_commande__r.Complement2__c, Ligne_de_commande__r.Prefs_EN__c, Product2.Product_name__c, Product2.Product_name_CN__c, Quantity,Ligne_de_commande__r.PreferencesFR__c,Ligne_de_commande__r.PreferencesEN__c,Ligne_de_commande__r.PreferencesCN__c FROM OpportunityLineItems), Ordonnance__r.Age__c, Ordonnance__r.Sexe__c, Patient__c, Praticien__r.Account.AccountNumber, Praticien__r.Account.Name,Praticien__r.Account.BillingStreet,Praticien__r.Account.BillingPostalCode,Praticien__r.Account.BillingCity,Praticien__r.FirstName, Praticien__r.LastName, Teinte__c, Teinte_bas__c, Teinte_haut__c,Praticien__r.Dentist_Preferences__c FROM Opportunity where Expedition__c = :Exp.Id];
    }
    
    public PRG_ExpeditionExtension(ApexPages.StandardController stdController) { 
        this.Exp = (Expedition__c)stdController.getRecord();
    }
    
 }