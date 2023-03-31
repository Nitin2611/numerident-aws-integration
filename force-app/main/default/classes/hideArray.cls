public class hideArray

{
    private final Ligne__c ligne {get; set;}
    public boolean showComponent {get; set;}
    public Boolean SelectedVal {get; set;}
    
    public hideArray(ApexPages.StandardController ctrl)
    {
        //(Ligne__c)ctrl.getRecord()
        ligne = [SELECT Id, Extraction__c FROM Ligne__c WHERE Id = :ctrl.getRecord().Id];
        system.debug('extraction == '+ligne);
        if(ligne.Extraction__c == 'Extraire'){
        	showComponent = true ;

        }
        if(ligne.Extraction__c == 'Ne rien extraire'){
            SelectedVal = true ;
        }
    }
    
    public void RenderSec()
    {
        if(SelectedVal == false)
        {
            showComponent = true ;
            ligne.Extraction__c = 'Extraire';
            update ligne;
        }
        if(SelectedVal == true)
        {
            showComponent = false ; 
            ligne.Extraction__c = 'Ne rien extraire';
            update ligne;       }
        //return null ;
    }
}