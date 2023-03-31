@isTest(seealldata = true)
public class MassUpdateRecordTest {
    static testMethod void testMassUpdateRecord() {
		Test.startTest();
            List<Ligne__c> LigneList = [SELECT ID, Couronne__c , Technical_Comments__c FROM Ligne__c WHERE Couronne__c ='CCM' OR Couronne__c = 'EMAX' OR Couronne__c ='CCZ' OR Couronne__c ='Full Zr Multilayer' OR Couronne__c='Céramo-métallique' OR Couronne__c ='Céramique monolithique (hors zircone)' OR Couronne__c='Céramo-céramique' OR Couronne__c='Céramique monolithique Zircone' LIMIT 10];
            MassUpdateRecord mr = new MassUpdateRecord();
            mr.errId = 'Test';
        Test.stopTest();
        Database.executeBatch(mr);
    }
}