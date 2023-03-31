public with sharing class PRG_ScanPanier {

    @AuraEnabled
    public static string OppURL(string OppName,string PanierId) {
        List<Opportunity> Opps = [Select Id,panier__c,Verification_panier__c from Opportunity where Name =:OppName and Panier__c=:PanierId and StageName='En cours de vérification'];
        if (Opps.size() > 0){
            Opps[0].Verification_panier__c = !Opps[0].Verification_panier__c;
            update Opps[0];
            List<Opportunity> OppsPanier = [Select Id from Opportunity where panier__c=:PanierID and Verification_panier__c=false];
            if(OppsPanier.size()==0){
                Panier__c P = new Panier__c();
                P.Id = PanierId;
                P.Statut__c = 'Vérif OK';
                update P;
            }else{
                Panier__c P = new Panier__c();
                P.Id = PanierId;
                P.Statut__c = 'A vérifier';
                update P;
            }
            return '';
        }else{
            Opps = [Select Id,panier__c from Opportunity where Name =:OppName and StageName='En cours de vérification'];
            if(Opps.size()>0){
                return 'Opportunité non trouvée dans ce panier';
            }else{
                return 'Opportunité non trouvée';
            }
        }
    }
}