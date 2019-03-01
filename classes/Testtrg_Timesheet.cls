/*
  This class contains unit tests for validating the behavior of Apex classes
  and triggers.
 
  Unit tests are class methods that verify whether a particular piece
  of code is working properly. Unit test methods take no arguments,
  commit no data to the database, and are flagged with the testMethod
  keyword in the method definition.
 
  All test methods in an organization are executed whenever Apex code is deployed
  to a production organization to confirm correctness, ensure code
  coverage, and prevent regressions. All Apex classes are
  required to have at least 75% code coverage in order to be deployed
  to a production organization. In addition, all triggers must have some code coverage.
  
  The @isTest class annotation indicates this class only contains test
  methods. Classes defined with the @isTest annotation do not count against
  the organization size limit for all Apex scripts.
 
  See the Apex Language Reference for more information about Testing and Code Coverage.
 */
 @isTest 
 public class Testtrg_Timesheet {
 private static Pay_Period__c pay;
    private static Contact ct;
    private static Contact ct1;
    private static Contact ct2;
    private static SFHCO_Ledger__c led;
    private static SFHCO_Ledger__c led1 ;
    private static SFHCO_Ledger__c led2 ;
      static testMethod void testTrg_Timesheet() {
        ToC9_TestDataDump data = new ToC9_TestDataDump();
        pay = data.getPayPeriod(Date.today(), Date.today() + 10);
        insert pay;   
        
        ct = data.getACandidate('testCandidate');     
       // ct1 = data.getACandidate('testCandidate1');     
       // ct2 = data.getACandidate('testCandidate2');     
        
        List<SFHCO_Ledger__c>  lsLed = new List<SFHCO_Ledger__c>();      
        led = data.getSFHCOLedger(10.0d, ct, Date.today() +1, Date.today() + 9);
        led.Stipend_Posted__c =true;
        led.Stipend__c = 10.00;
        led.Pay_Period__c = pay.id;
        led.Is_Discarded__c = false;
        led.Allocation_Amount__c = 10.0;
        led.Benefit_Accrual__c = 200;
        lsLed.add(led);
        
        //led1 = data.getSFHCOLedger(11.0d, ct1, Date.today() +2, Date.today() + 8);
        //led1.Stipend_Posted__c = false;
        //led1.Benefit_Accrual__c = 200;
        //led1.Pay_Period__c = pay.id;
        //led1.Is_Discarded__c = false;
        //led1.Allocation_Amount__c = 10.0;
        //led1.Allocated_Timestamp__c = Date.today();
       // lsLed.add(led1);
        
        //led2 = data.getSFHCOLedger(15.0d, ct2, Date.today() +3, Date.today() + 7);
        //led2.Stipend_Posted__c =false;
        //led2.Benefit_Accrual__c = 50;
       // led2.Pay_Period__c = pay.id;
       // led2.Is_Discarded__c = false;
       // led2.Allocation_Amount__c = 10.0;
        
        //lsLed.add(led2);        
        
       // insert lsLed;
        
        tc9_ti__TaxID__c tax = data.getTaxID();
        tc9_ti__Market__c market =  data.getMarket(tax.id);
        Account acc = data.getAClientAccount(market.id);
        tc9_ti__Site__c site = data.getASite('goole','http://google.com.vn');
        //ts2__Job__c  job = data.getAJob(acc.id, ct.id, market.id, site.id);
       
        
        tc9_ti__Public_Holiday_Calendar__c cal = data.getPublicHolidayCal();
        tc9_ti__Award_Master__c award = data.getAnAward();
       // ts2__Placement__c placement = data.getAPlacement(job, cal.id, ct.id, Date.today(), Date.today() + 20,  award.id, 'temp');
      
        
       // ts2__Placement__c placement1 = data.getAPlacement(job, cal.id, ct1.id, Date.today(), Date.today() + 20,  award.id, 'temp');
       // placement1.tc9_ti__Market__c = market.id;
       // placement1.ts2__Accounts_Payable__c = ct.id;
       // placement1.tc9_ti__TimeSheetApprover__c = ct.id;
       // update placement;
      //  tc9_ti__Time_Sheet__c timeSheet1 = data.getATimesheet(placement1.id, ct.id, Date.today() +1, Date.today() +7);
      //  insert timeSheet1;      
       

 }
}