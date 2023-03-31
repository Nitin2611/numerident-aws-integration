public class PRG_ProFormaController {
    private final Expedition__c Exp;
    public integer MontantUnitaire {get;set;}
    
    public PRG_ProFormaController(ApexPages.StandardController stdController) {
        this.Exp = (Expedition__c)stdController.getRecord();
        MontantUnitaire = (integer) math.ceil((23 / getnbDossiers())) ;
    }

    public List<Opportunity> getListeDossiers() {
    	return [Select Id,Name,Patient__c from Opportunity where Expedition__c = :Exp.Id order by Name];
    }
    public decimal getnbDossiers() {
    	List<Opportunity> Opps = [Select Id from Opportunity where Expedition__c = :Exp.Id];
    	return Opps.size();
    }
    public decimal getPoidsMoyen() {
    	List<Opportunity> Opps = [Select Id from Opportunity where Expedition__c = :Exp.Id];
    	if (Opps.size() == 0){
    		return 0;
    	}else{
	        return Exp.Poids__c / Opps.size();
    	}
    }    
}