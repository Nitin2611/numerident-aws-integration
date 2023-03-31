@isTest(seealldata = true)
public class TypeMassUpdateTest{
    static testMethod void testMassUpdateRecord() {
        Test.startTest();
        List<Ligne__c> LigneList = [SELECT ID, Couronne__c , Type__c , Technical_Comments__c FROM Ligne__c WHERE Type__c ='CCM' OR Type__c = 'EMAX' OR Type__c ='CCZ' OR Type__c ='Full Zr Multilayer' OR Type__c='Céramo-métallique' OR Type__c ='Céramique monolithique (hors zircone)' OR Type__c='Céramo-céramique ' OR Type__c='Céramique monolithique Zircone' LIMIT 10];
        TypeMassUpdate mr = new TypeMassUpdate();
        mr.errId = 'Test';
        Test.stopTest();
        Database.executeBatch(mr);

    }
}