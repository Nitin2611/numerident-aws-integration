@isTest
private class PRG_ScanExport_Test {

    static testMethod void Test() {
        Account Acc = new Account();
        Acc.NAme = 'Centre';
        insert Acc;
        Opportunity Opp = new Opportunity();
        Opp.AccountId = Acc.ID;
        Opp.CloseDate = date.today();
        Opp.Date_d_exp_dition__c = date.today().addDays(-10);
        Opp.StageName = 'Validé';
        Opp.Name = 'Test';
        insert Opp;
        
        Scan_export__c S = new Scan_export__c();
      	S.CAB__c = 'Test';
      	insert S;

    }
}