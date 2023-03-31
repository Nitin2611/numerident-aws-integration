public class CtrlStarRating {
    
     @AuraEnabled
    public static Notation__c initData(string monid) {           
        //Notation__c  note=[SELECT Id, Name, Note__c, Commentaire__c, Objet_lie__c FROM Notation__c WHERE Objet_lie__c = :monid];
        //return note;
        List<Notation__c> Notes = [SELECT Id, Name, Note__c, Commentaire__c, Objet_lie__c FROM Notation__c WHERE Objet_lie__c = :monid];
        if (Notes.size()>0){
            return Notes[0];
        }else{
            Notation__c  note = new Notation__c  ();
            note.Objet_lie__c = monid;
            note.Ordonnance__c  = monid;
            note.Note__c = 5;
            return note;
        }
    }
     @AuraEnabled
    public static void UpdateData(Notation__c  MaNotation ,string newvalue) { 
        MaNotation.Note__c =  Decimal.valueOf(String.valueOf(newvalue));
       UPDATE  MaNotation;
    }
     @AuraEnabled
    public static Notation__c InsertData(string  idObj ,string newvalue) {
        Notation__c n = new Notation__c();
        n.Objet_lie__c = idObj;
        n.Ordonnance__c = idObj;
        n.Note__c =  Decimal.valueOf (String.valueOf(newvalue));
       UPSERT  n;
        return [SELECT Id, Name, Note__c, Commentaire__c, Objet_lie__c FROM Notation__c WHERE id = :n.id];
    }

}