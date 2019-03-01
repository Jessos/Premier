@isTest(seealldata=false)
public class Ctrl_SFHCOPeriodEndProcessing_Test {
    private static Pay_Period__c pay;
    private static Contact ct;
    private static Contact ct1;
    private static Contact ct2;
    private static SFHCO_Ledger__c led;
    private static SFHCO_Ledger__c led1 ;
    private static SFHCO_Ledger__c led2 ;
   
  /*  public static testmethod void testContructer(){
        Test.startTest();
        prepareData();
        ApexPages.currentPage().getParameters().put('Id',pay.id);
        ApexPages.StandardController payRecord = new ApexPages.StandardController(pay);       
        Ctrl_SFHCOPeriodEndProcessing objSFHRAReport_Ctrl = new Ctrl_SFHCOPeriodEndProcessing(payRecord);  
        PageReference pageRef = objSFHRAReport_Ctrl.CreateStipends();
        objSFHRAReport_Ctrl.CreateTransactiosForSFHCOLedgers();
        Test.stopTest();
        //System.assertEquals(3, objSFHRAReport_Ctrl.listOfAllSFHCOLedgers.size());
        System.assertNotEquals(null, objSFHRAReport_Ctrl.oPayPeriod);
        System.assertEquals(1, objSFHRAReport_Ctrl.getTotalPageNumber());
        System.assertEquals(1, objSFHRAReport_Ctrl.nCurrentPageNumber);
        System.assertEquals(3, objSFHRAReport_Ctrl.listOfSFHCOLedgersforPage.size());
        System.assertEquals(null, pageRef);   
        System.assertEquals(190, objSFHRAReport_Ctrl.listOfAllSFHCOLedgers.get(0).getAllocation());         
    } */
    
  /*  public static testmethod void testStatus(){
        Test.startTest();
        prepareData();
        ApexPages.currentPage().getParameters().put('Id',pay.id);
        ApexPages.StandardController payRecord = new ApexPages.StandardController(pay);       
        Ctrl_SFHCOPeriodEndProcessing objSFHRAReport_Ctrl = new Ctrl_SFHCOPeriodEndProcessing(payRecord);          
        Test.stopTest();
        System.assertEquals('Stipend Posted', objSFHRAReport_Ctrl.listOfAllSFHCOLedgers.get(0).getStatus()); 
        System.assertEquals('Allocation Posted', objSFHRAReport_Ctrl.listOfAllSFHCOLedgers.get(1).getStatus()); 
        System.assertEquals('New', objSFHRAReport_Ctrl.listOfAllSFHCOLedgers.get(2).getStatus()); 
    } */
    
/*    public static testmethod void testCreateStipend(){
        Test.startTest();
        prepareData();
        ApexPages.currentPage().getParameters().put('Id',pay.id);
        ApexPages.StandardController payRecord = new ApexPages.StandardController(pay);       
        Ctrl_SFHCOPeriodEndProcessing objSFHRAReport_Ctrl = new Ctrl_SFHCOPeriodEndProcessing(payRecord);       
        objSFHRAReport_Ctrl.CreateSFHCOLedgersForStipends();
        Test.stopTest();
        
        SFHCO_Ledger__c legderInserted = [select Name, Type__c, Start_Date__c, End_Date__c, Candidate__c, Benefit_Accrual__c
                                          from SFHCO_Ledger__c where SFHCO_Ledger__c = : led1.Id]; 
        System.assertEquals('Stipend', legderInserted.Type__c);
        System.assertEquals('SFHCO Stipend - '+ct1.lastName + ' - ' +Datetime.now().format('dd/MM/YYYY'), legderInserted.Name);
        System.assertEquals(Date.today() +2, legderInserted.Start_Date__c);     
        System.assertEquals(Date.today() +8, legderInserted.End_Date__c);     
        System.assertEquals(ct1.id, legderInserted.Candidate__c);
        System.assertEquals(-100.00, legderInserted.Benefit_Accrual__c);  
        
        SFHCO_Ledger__c legderInserted2 = [select Name, Type__c, Start_Date__c, End_Date__c, Candidate__c, Benefit_Accrual__c
                                           from SFHCO_Ledger__c where SFHCO_Ledger__c = : led2.Id]; 
        System.assertEquals('Stipend', legderInserted2.Type__c);
        System.assertEquals('SFHCO Stipend - '+ct2.lastName + ' - ' +Datetime.now().format('dd/MM/YYYY'), legderInserted2.Name);
        System.assertEquals(Date.today() +3, legderInserted2.Start_Date__c);     
        System.assertEquals(Date.today() +7, legderInserted2.End_Date__c);     
        System.assertEquals(ct2.id, legderInserted2.Candidate__c);
        System.assertEquals(-50.00, legderInserted2.Benefit_Accrual__c); 
        
        SFHCO_Ledger__c updatedInserted = [select Stipend__c,Allocation_Amount__c, Stipend_Posted__c
                                           from SFHCO_Ledger__c where id = : led1.Id]; 
        System.assertEquals(100, updatedInserted.Stipend__c);
        System.assertEquals(100, updatedInserted.Allocation_Amount__c);   
        System.assertEquals(true, updatedInserted.Stipend_Posted__c);  
        
        SFHCO_Ledger__c updatedInserted1 = [select Stipend__c,Allocation_Amount__c, Stipend_Posted__c
                                            from SFHCO_Ledger__c where id = : led2.Id]; 
        System.assertEquals(50, updatedInserted1.Stipend__c);
        System.assertEquals(0, updatedInserted1.Allocation_Amount__c);   
        System.assertEquals(true, updatedInserted1.Stipend_Posted__c);  
        
    } /*
    
/*    public static testmethod void testCreateAllocationBatch(){
        Test.startTest();
        prepareData();
        ApexPages.currentPage().getParameters().put('Id',pay.id);
        ApexPages.StandardController payRecord = new ApexPages.StandardController(pay);       
        Ctrl_SFHCOPeriodEndProcessing objSFHRAReport_Ctrl = new Ctrl_SFHCOPeriodEndProcessing(payRecord);       
        objSFHRAReport_Ctrl.CreateAllocationBatch();      
        Test.stopTest();       
        SFHCO_Ledger__c legderInserted = [select Name, Type__c, Start_Date__c, End_Date__c, Candidate__c, Benefit_Accrual__c
                                          from SFHCO_Ledger__c where SFHCO_Ledger__c = : led.Id]; 
        System.assertEquals('Allocation', legderInserted.Type__c);
        System.assertEquals('SFHCO Allocation - '+ct.lastName + ' - ' +Datetime.now().format('dd/MM/YYYY'), legderInserted.Name);
        System.assertEquals(Date.today() +1, legderInserted.Start_Date__c);     
        System.assertEquals(Date.today() +9, legderInserted.End_Date__c);     
        System.assertEquals(ct.id, legderInserted.Candidate__c);
        System.assertEquals(-10.00, legderInserted.Benefit_Accrual__c);  
        
        
        SFHCO_Ledger__c updatedInserted = [select Exclude_Allocation__c, Candidate_Name__c, Hours_This_Pay_Period__c,
                                           Pay_Period__c, Stipend__c, Allocation_Amount__c, Is_Discarded__c,
                                           Stipend_Posted__c, Start_Date__c, End_Date__c , Benefit_Accrual__c,
                                           Candidate__c
                                           from SFHCO_Ledger__c 
                                           where id = : led.Id]; 
        System.assertEquals(false, updatedInserted.Exclude_Allocation__c);
        System.assertEquals(ct.LastName, updatedInserted.Candidate_Name__c);   
        System.assertEquals(10, updatedInserted.Hours_This_Pay_Period__c);  
        System.assertEquals(pay.id, updatedInserted.Pay_Period__c);
        System.assertEquals(10, updatedInserted.Stipend__c);   
        System.assertEquals(10, updatedInserted.Allocation_Amount__c);  
        System.assertEquals(false, updatedInserted.Is_Discarded__c);
        System.assertEquals(true, updatedInserted.Stipend_Posted__c);   
        System.assertEquals(Date.today() +1, updatedInserted.Start_Date__c);  
        System.assertEquals(Date.today() +9, updatedInserted.End_Date__c);
        System.assertEquals(200, updatedInserted.Benefit_Accrual__c);   
        System.assertEquals(ct.id, updatedInserted.Candidate__c);         
    } */
    
    
   
    
    public static testmethod void testGetPreviousBtnVisibility(){
        Test.startTest();
        prepareData();
        ApexPages.currentPage().getParameters().put('Id',pay.id);
        ApexPages.StandardController payRecord = new ApexPages.StandardController(pay);       
        Ctrl_SFHCOPeriodEndProcessing objSFHRAReport_Ctrl = new Ctrl_SFHCOPeriodEndProcessing(payRecord);  
        boolean result = objSFHRAReport_Ctrl.getPreviousBtnVisibility();
        Test.stopTest();
        System.assertEquals(false, result);
    }
    
    public static testmethod void testGetNextBtnVisibility(){
        Test.startTest();
        prepareData();
        ApexPages.currentPage().getParameters().put('Id',pay.id);
        ApexPages.StandardController payRecord = new ApexPages.StandardController(pay);       
        Ctrl_SFHCOPeriodEndProcessing objSFHRAReport_Ctrl = new Ctrl_SFHCOPeriodEndProcessing(payRecord);  
        boolean result = objSFHRAReport_Ctrl.getNextBtnVisibility();
        Test.stopTest();
        System.assertEquals(false, result);
    }
    
    
    public static testmethod void testGetNextBtnClick(){
        Test.startTest();
        prepareData();
        ApexPages.currentPage().getParameters().put('Id',pay.id);
        ApexPages.StandardController payRecord = new ApexPages.StandardController(pay);       
        Ctrl_SFHCOPeriodEndProcessing objSFHRAReport_Ctrl = new Ctrl_SFHCOPeriodEndProcessing(payRecord);  
        PageReference ref =  objSFHRAReport_Ctrl.nextBtnClick();
        Test.stopTest();
        System.assertEquals(null, ref);
        System.assertEquals(2, objSFHRAReport_Ctrl.nCurrentPageNumber);
    }
    
    public static testmethod void testPreviousBtnClick(){
        Test.startTest();
        prepareData();
        ApexPages.currentPage().getParameters().put('Id',pay.id);
        ApexPages.StandardController payRecord = new ApexPages.StandardController(pay);       
        Ctrl_SFHCOPeriodEndProcessing objSFHRAReport_Ctrl = new Ctrl_SFHCOPeriodEndProcessing(payRecord);  
        PageReference ref =  objSFHRAReport_Ctrl.previousBtnClick();
        Test.stopTest();
        System.assertEquals(null, ref);
        System.assertEquals(0, objSFHRAReport_Ctrl.nCurrentPageNumber);
    }
    
    public static testmethod void testGetPageNumber(){
        Test.startTest();
        prepareData();
        ApexPages.currentPage().getParameters().put('Id',pay.id);
        ApexPages.StandardController payRecord = new ApexPages.StandardController(pay);       
        Ctrl_SFHCOPeriodEndProcessing objSFHRAReport_Ctrl = new Ctrl_SFHCOPeriodEndProcessing(payRecord);  
        integer numPage = objSFHRAReport_Ctrl.getPageNumber();
        Test.stopTest();
        System.assertEquals(1, numPage);
        
    }
    public static testmethod void testGetPageSize(){
        Test.startTest();
        prepareData();
        ApexPages.currentPage().getParameters().put('Id',pay.id);
        ApexPages.StandardController payRecord = new ApexPages.StandardController(pay);       
        Ctrl_SFHCOPeriodEndProcessing objSFHRAReport_Ctrl = new Ctrl_SFHCOPeriodEndProcessing(payRecord);  
        Integer size =  objSFHRAReport_Ctrl.getPageSize();
        Test.stopTest();
        System.assertEquals(50, size);
    }
    
    
    public static testmethod void testCreateTransactiosForSFHCOLedgers(){
        Test.startTest();
        prepareData();
        ApexPages.currentPage().getParameters().put('Id',pay.id);
        ApexPages.StandardController payRecord = new ApexPages.StandardController(pay);       
        Ctrl_SFHCOPeriodEndProcessing objSFHRAReport_Ctrl = new Ctrl_SFHCOPeriodEndProcessing(payRecord); 
        PageReference ref = objSFHRAReport_Ctrl.PeriodReport();
        Test.stopTest();
        System.assertNotEquals(null, ref);   
    }
    
  /*   public static testmethod void testRemoveLedgerRecordValid(){
        Test.startTest();
        prepareData();
        ApexPages.currentPage().getParameters().put('Id',pay.id);
        ApexPages.StandardController payRecord = new ApexPages.StandardController(pay);       
        Ctrl_SFHCOPeriodEndProcessing objSFHRAReport_Ctrl = new Ctrl_SFHCOPeriodEndProcessing(payRecord);     
        
        objSFHRAReport_Ctrl.listOfAllSFHCOLedgers.get(0).removeRecord = true;
        objSFHRAReport_Ctrl.listOfAllSFHCOLedgers.get(1).removeRecord = false;
        
        objSFHRAReport_Ctrl.removeLedgerRecord();    
        Test.stopTest();      
        System.assertEquals(2, objSFHRAReport_Ctrl.listOfAllSFHCOLedgers.size()) ;
        SFHCO_Ledger__c legderInserted = [select Name, Type__c, Start_Date__c, End_Date__c, Candidate__c, Benefit_Accrual__c
                                          from SFHCO_Ledger__c where SFHCO_Ledger__c = : led.Id]; 
        System.assertEquals('Accrual', legderInserted.Type__c);
        System.assertEquals('SFHCO Allocation - '+ct.lastName + ' - ' +Datetime.now().format('dd/MM/YYYY'), legderInserted.Name);
        System.assertEquals(Date.today() +1, legderInserted.Start_Date__c);     
        System.assertEquals(Date.today() +9, legderInserted.End_Date__c);     
        System.assertEquals(ct.id, legderInserted.Candidate__c);
        System.assertEquals(-200.00, legderInserted.Benefit_Accrual__c);  
    } */
    
    private static void prepareData(){
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
        
      //  led1 = data.getSFHCOLedger(11.0d, ct1, Date.today() +2, Date.today() + 8);
        //led1.Stipend_Posted__c = false;
        //led1.Benefit_Accrual__c = 200;
        //led1.Pay_Period__c = pay.id;
        //led1.Is_Discarded__c = false;
        //led1.Allocation_Amount__c = 10.0;
        //led1.Allocated_Timestamp__c = Date.today();
        //lsLed.add(led1);
        
       // led2 = data.getSFHCOLedger(15.0d, ct2, Date.today() +3, Date.today() + 7);
        //led2.Stipend_Posted__c =false;
        //led2.Benefit_Accrual__c = 50;
        //led2.Pay_Period__c = pay.id;
        //led2.Is_Discarded__c = false;
        //led2.Allocation_Amount__c = 10.0;
        
      //  lsLed.add(led2);        
        
      //  insert lsLed;
        
        tc9_ti__TaxID__c tax = data.getTaxID();
        tc9_ti__Market__c market =  data.getMarket(tax.id);
        Account acc = data.getAClientAccount(market.id);
        tc9_ti__Site__c site = data.getASite('goole','http://google.com.vn');
       // ts2__Job__c  job = data.getAJob(acc.id, ct.id, market.id, site.id);
       // job.ts2__Location__c = 'San Francisco' ;
       // update job;
        
        tc9_ti__Public_Holiday_Calendar__c cal = data.getPublicHolidayCal();
        tc9_ti__Award_Master__c award = data.getAnAward();
       // ts2__Placement__c placement = data.getAPlacement(job, cal.id, ct.id, Date.today(), Date.today() + 20,  award.id, 'temp');
       // placement.tc9_ti__Market__c = market.id;
       // placement.ts2__Accounts_Payable__c = ct.id;
       // placement.tc9_ti__TimeSheetApprover__c = ct.id;
       // update placement;
        
       // ts2__Placement__c placement1 = data.getAPlacement(job, cal.id, ct1.id, Date.today(), Date.today() + 20,  award.id, 'temp');
       // placement1.tc9_ti__Market__c = market.id;
       // placement1.ts2__Accounts_Payable__c = ct.id;
       // placement1.tc9_ti__TimeSheetApprover__c = ct.id;
       // update placement;
       // tc9_ti__Time_Sheet__c timeSheet1 = data.getATimesheet(placement1.id, ct.id, Date.today() +1, Date.today() +7);
       // insert timeSheet1;        
        
        
    }
}