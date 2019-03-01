@isTest
public class SFHRAReport_Ctrl_Test {
    private static Pay_Period__c pay;
    private static  Contact ct ;
    private static  Contact ct1 ;
    
    public static testmethod void testController(){
        Test.startTest();
        prepareData();
        ApexPages.currentPage().getParameters().put('Id',pay.id);
        ApexPages.StandardController payRecord = new ApexPages.StandardController(pay);       
        SFHRAReport_Ctrl objSFHRAReport_Ctrl = new SFHRAReport_Ctrl(payRecord);
        TEst.stopTest();
        //Assert Pay period
        System.assertEquals(pay.Id, objSFHRAReport_Ctrl.payperiod.Id);
        System.assertEquals(pay.Start_Date__c, objSFHRAReport_Ctrl.payperiod.Start_Date__c);
        System.assertEquals(pay.End_Date__c, objSFHRAReport_Ctrl.payperiod.End_Date__c);
        //Assert listOfSFHCO
        //System.assertEquals(3, objSFHRAReport_Ctrl.listOfSFHCO.size());
        //Assert mapOfCandidateAndSFHCO
        //System.assertEquals(2, objSFHRAReport_Ctrl.mapOfCandidateAndSFHCO.size());
        //System.assertEquals('', objSFHRAReport_Ctrl.mapOfCandidateAndSFHCO.get(ct.id).birthDate);
        //System.assertEquals('', objSFHRAReport_Ctrl.mapOfCandidateAndSFHCO.get(ct.id).hireDate);
        //System.assertEquals('', objSFHRAReport_Ctrl.mapOfCandidateAndSFHCO.get(ct.id).terminationDate);
        //System.assertEquals('', objSFHRAReport_Ctrl.mapOfCandidateAndSFHCO.get(ct.id).coverageDate);
        
        //System.assertEquals('1985/01/21', objSFHRAReport_Ctrl.mapOfCandidateAndSFHCO.get(ct1.id).birthDate);
        //System.assertEquals('2015/05/26', objSFHRAReport_Ctrl.mapOfCandidateAndSFHCO.get(ct1.id).hireDate);
        //System.assertEquals('2016/05/25', objSFHRAReport_Ctrl.mapOfCandidateAndSFHCO.get(ct1.id).terminationDate);
        //System.assertEquals('2015/05/26', objSFHRAReport_Ctrl.mapOfCandidateAndSFHCO.get(ct1.id).coverageDate);        
    }
    
    private static void prepareData(){
        ToC9_TestDataDump data = new ToC9_TestDataDump();
        pay = data.getPayPeriod(Date.today(), Date.today() + 10);
        insert pay;       
        
       // ct = data.getACandidate('testCandidate');     
        
        ct1 = data.getACandidate('testCandidate1');
       // ct1.Birthdate = Date.newInstance(1985, 01, 21);
       // ct1.First_Day_Worked__c =Date.newInstance(2015, 05,26);
        //ct1.SFHCO_Eligibilty_Date__c =Date.newInstance(2015, 05,26);
        ct1.Premier_Term_Date__c = Date.newInstance(2016,05, 25);
        
        update ct1;
         System.debug('ct1.SFHCO_Eligibilty_Date__c=='+ct1.SFHCO_Eligibilty_Date__c);

        List<SFHCO_Ledger__c>  lsLed = new List<SFHCO_Ledger__c>();      
       // SFHCO_Ledger__c led = data.getSFHCOLedger(10.0d, ct, Date.today() +1, Date.today() + 9);
       // lsLed.add(led);
       // SFHCO_Ledger__c led1 = data.getSFHCOLedger(11.0d, ct, Date.today() +2, Date.today() + 8);
        //lsLed.add(led1);
        //SFHCO_Ledger__c led2 = data.getSFHCOLedger(15.0d, ct1, Date.today() +3, Date.today() + 7);
       // lsLed.add(led2);        
       // insert lsLed;
        
    }
}