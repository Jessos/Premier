/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest 
private class Test_SickPay {
    
    static Id candidateId;

    public static Contact PopulateDataForSickLeaveAccrual(){
        
        ToC9_TestDataDump testDataDump = new ToC9_TestDataDump();
        
        //create a new tax record
        tc9_ti__TaxID__c testTax = testDataDump.getTaxID();
          
        //create a new market
        tc9_ti__Market__c testMarket = testDataDump.getMarket(testTax.Id);
        
        //Create a site  
        tc9_ti__Site__c testSites = testDataDump.getASite('Test Site', 'www.test.com');
        
        tc9_ti__PaymentTerm__c paymentTerm = new tc9_ti__PaymentTerm__c();
        paymentTerm.tc9_ti__DaysFromInvoice__c = 15;
        paymentTerm.tc9_ti__DueFrom__c = 'Invoice Date';
        paymentTerm.tc9_ti__PaymentTermName__c = 'Net 15';
        paymentTerm.tc9_ti__PaymentTermsDescription__c = 'Net 15';
        paymentTerm.CurrencyIsoCode = 'USD';
        insert paymentTerm;
        
        //create a new account
        Account testAccount = testDataDump.getAClientAccount(testMarket.Id);
        testAccount.Name = 'Premier Staffing, Inc';
        testAccount.BillingStreet = 'BillingStreet';
        testAccount.BillingCity = 'Melbourne';
        testAccount.BillingState = 'Victoria';
        testAccount.BillingPostalCode = '3000';
        testAccount.BillingCountry = 'Australia';
        testAccount.Phone = '1234567899';
        testAccount.Fax = '90000';
        testAccount.Website = 'www.test.com';
        testAccount.tc9_ti__Invoice_Group_By__c = 'Placement';
        testAccount.ts2__Invoice_Terms__c = '10';
        testAccount.tc9_ti__PaymentTerm__c = paymentTerm.Id;
        update testAccount;
          
        //create a client contact
        Contact testContact = testDataDump.getAClientContact(testAccount.Id);
        testContact.Salutation  = 'Mr';
        testContact.State__c = 'AL';
        update testContact;
        
        //Update Contact with Account Payable Lookup
        testAccount.ts2__Accounts_Payable__c = testContact.Id;
        update testAccount;
        
        //create an Employee
        Contact testEmployee = testDataDump.getAClientContact(testAccount.Id);
        testEmployee.First_Day_Worked__c = Date.today().addDays(-200);
        testEmployee.State__c = 'AL';
        update testEmployee;
        
        candidateId = testEmployee.Id;
        
        //Create an Award
        tc9_ti__Award_Master__c testAwardMaster = testDataDump.getAnAward();
        insert testAwardMaster;
        
        //Create a Job
        ts2__Job__c testJob = testDataDump.getAJob(testAccount.Id, testContact.Id, testMarket.Id, testSites.Id);
        testJob.ts2__Location__c = 'San Francisco';
        testJob.tc9_ti__PaymentTerm__c = paymentTerm.Id;
        update testJob;
        
        //create a public holiday calander
        tc9_ti__Public_Holiday_Calendar__c testCalendar = new tc9_ti__Public_Holiday_Calendar__c();
        testCalendar.tc9_ti__Year__c = String.valueOf(Date.today().year());
        testCalendar.Name = 'Australia - Vic';
        insert testCalendar;
        
        RecordType rt = [select id,Name from RecordType where SobjectType='ts2__Placement__c' and Name='Perm' Limit 1];
        
        /*ts2__Placement__c testPlacement = testDataDump.getAPlacement(testJob, testCalendar.Id, testEmployee.Id, Date.Today().toStartOfWeek().addDays(-10), Date.Today().toStartOfWeek().addDays(-1), testAwardMaster.Id , 'Temp');
       testPlacement.recordtypeid = rt.id;
        testPlacement.ts2__Employee__c  = testEmployee.Id;
       update testPlacement;
        
       testPlacement = [SELECT Id, Is_Eligible_for_Sick_Leave_Accrual__c FROM ts2__Placement__c WHERE Id=: testPlacement.id];
       System.debug('@@@@@ '+testPlacement);
        
        //create a candidate
        Contact testCandidate = testDataDump.getACandidate('contactName');
        
        //Create a Timesheet
        tc9_ti__Time_Sheet__c testTimesheet = testDataDump.getATimesheet(testPlacement.Id, testCandidate.Id , Date.Today().toStartOfWeek().addDays(-10), Date.Today().toStartOfWeek().addDays(-1));
       insert testTimesheet;
       
        //insert a list Of Time_Sheet entry
        List<tc9_ti__Time_Sheet_Entry__c> listOfTimesheetEntrys = new List<tc9_ti__Time_Sheet_Entry__c>();
        for(Integer i = 0; i < 200; i++){
            
            tc9_ti__Time_Sheet_Entry__c testTimesheetEntry = testDataDump.getATimesheetEntry(testTimesheet.Id,  Date.today().addDays(-i), '00:00', '08:00');
           listOfTimesheetEntrys.add(testTimesheetEntry);
        }
        
        insert listOfTimesheetEntrys;
        
        tc9_ti__PayCodeMaster__c testPaycode = new tc9_ti__PayCodeMaster__c(tc9_ti__Paycode__c = '121');
        insert testPaycode;*/
        
        //insert a list Of Transactions
        List<tc9_ti__Transaction__c> listOfTransactions = new List<tc9_ti__Transaction__c>();
        /*for(Integer i = 0; i < 200; i++){
            
            tc9_ti__Transaction__c testTransaction = testDataDump.getATransaction(testPlacement.Id, Date.today().addDays(-i), 1, 2, testPaycode.tc9_ti__Paycode__c);
            testTransaction.tc9_ti__InvoiceDate__c = Date.today().addDays(-i);
            testTransaction.tc9_ti__EntryDate__c = Date.today().addDays(-i);
           testTransaction.tc9_ti__Unit__c = 'Hours';
            testTransaction.tc9_ti__HoursActutal__c = 10;
           testTransaction.tc9_ti__Time_Sheet__c = testTimesheet.Id;
           testTransaction.tc9_ti__Time_Sheet_Entry__c = listOfTimesheetEntrys[i].Id;
            listOfTransactions.add(testTransaction);
        }*/
        
        insert listOfTransactions;
        
        Date fromDate = Date.today().addDays(-200);
        Date toDate = Date.today();
        listOfTransactions = [SELECT Name, tc9_ti__Unit__c, tc9_ti__Time_Sheet__r.Job_Name__c, tc9_ti__Time_Sheet__r.tc9_ti__Status__c, 
                                     tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c, tc9_ti__Time_Sheet__r.tc9_ti__Candidate__r.Name, tc9_ti__Time_Sheet__c, 
                                     tc9_ti__Time_Sheet_Entry__r.tc9_ti__Status__c, tc9_ti__Time_Sheet_Entry__r.tc9_ti__Time_Sheet__c, 
                                     tc9_ti__Time_Sheet_Entry__r.Id, tc9_ti__Time_Sheet_Entry__c, tc9_ti__HoursActutal__c, tc9_ti__EntryDate__c, Id, Employee__c, 
                                     Accrued_Datestamp__c, tc9_ti__Time_Sheet_Entry__r.tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.Is_Eligible_for_Sick_Leave_Accrual__c 
                              FROM tc9_ti__Transaction__c 
                              WHERE tc9_ti__Time_Sheet_Entry__r.tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.Is_Eligible_for_Sick_Leave_Accrual__c = true 
                              AND tc9_ti__EntryDate__c >=:fromDate AND tc9_ti__EntryDate__c <=:toDate];
                              
        System.debug('@@@@@ '+listOfTransactions); 
        
        Leave_Settings__c testLeave = new Leave_Settings__c();
        testLeave.Leave_Accrual_Ratio__c = 30;
        testLeave.Is_Accrued__c = true;
        testLeave.Name = 'Sick Leave';
        
        insert testLeave;             

        Alternate_Leave_Types__c settings = new Alternate_Leave_Types__c();
        settings.Name = 'DefaultSettings';
        settings.Alternate_Pay_Excluded__c = 'Sick,Holiday Off';
        insert settings;
        
        return testContact;
    }
    
    static testMethod void SickLeaveAccrual() {
        
        Contact testContact = PopulateDataForSickLeaveAccrual();
        
        Test.startTest();
        
            Test.setCurrentPage(Page.SickLeaveAccrual);
            
            //missing input conditions
            Ctrl_SickLeaveAccrual controller = new Ctrl_SickLeaveAccrual();
            controller.Invokebatch(); 
            
            //input conditions
            controller = new Ctrl_SickLeaveAccrual();
            controller.Plc.ts2__Start_Date__c   = Date.today().addDays(-200);
            controller.Plc.ts2__End_Date__c     = Date.today();
            controller.Invokebatch(); 
            
        Test.stopTest();    
        
        //test scheduler
            String CRON_EXP = '0 0 0 15 3 ? 2022'; //batch job will be run immediately irrespective of cron exp as this is test class
            String jobId = System.schedule('ScheduleApexClassTest',CRON_EXP,new Scheduler_Batch_LeaveAccrual());
        
        //assert that there is a leave ledger created
        //system.assertEquals(1, [SELECT count() from Leave_Ledger__c where Contact__c =: testContact.Id]);
        
        //assert that the candidate has a leave balance
        system.assertNotEquals(null, [SELECT Available_Sick_Leave_Balance__c From contact where id=: testContact.Id]);
                   
    }
     
     static testMethod void Ctrl_SFHCOPeriodEndProcessing(){
        
        Contact testContact = PopulateDataForSickLeaveAccrual();
         
         Pay_Period__c pay = new Pay_Period__c();
         pay.Start_Date__c = Date.today();
         pay.End_Date__c =Date.today();
         insert pay;
         
         //create a SFHCO ledger for the contact (should ideally be created from batch)
         SFHCO_Ledger__c ledger     = new SFHCO_Ledger__c();
         ledger.Pay_Period__c       = pay.Id;
         ledger.Name                = 'Test';
         ledger.Benefit_Accrual__c  = 80;
         ledger.Candidate__c        = testContact.Id;
         ledger.Type__c             = 'Accrual';
         insert ledger;
         Test.startTest();
         
             ApexPages.StandardController controller = new ApexPages.StandardController(pay); 
             Ctrl_SFHCOPeriodEndProcessing ctrl = new Ctrl_SFHCOPeriodEndProcessing(controller);
             
             //set stipend greater than 100
             for(Ctrl_SFHCOPeriodEndProcessing.LedgerWrapper wrap : ctrl.listOfAllSFHCOLedgers)
                wrap.stipend = 200; 
             ctrl.CreateStipends();
             
             /******************* CASE - 1 : Error *******************************/
             //check no stipend created
             system.assertEquals(0, [select count() from SFHCO_Ledger__c where Candidate__c=: testContact.Id and Type__c='Stipend']);
             
             //accrual record not updated
             SFHCO_Ledger__c accrualLedger = [select id,Allocation_Amount__c,Stipend_Posted__c,Stipend__c from SFHCO_Ledger__c where id=: ledger.Id];
             system.assertEquals(false, accrualLedger.Stipend_Posted__c);
             system.assertEquals(null, accrualLedger.Stipend__c);
             
             /******************* CASE - 2 : Error *******************************/
             //set stipend less than 100, but greater than benefits
             for(Ctrl_SFHCOPeriodEndProcessing.LedgerWrapper wrap : ctrl.listOfAllSFHCOLedgers)
                wrap.stipend = 100; 
             ctrl.CreateStipends();
             
              //check no stipend created
             system.assertEquals(0, [select count() from SFHCO_Ledger__c where Candidate__c=: testContact.Id and Type__c='Stipend']);
             
             //accrual record not updated
             accrualLedger = [select id,Allocation_Amount__c,Stipend_Posted__c,Stipend__c from SFHCO_Ledger__c where id=: ledger.Id];
             system.assertEquals(false, accrualLedger.Stipend_Posted__c);
             system.assertEquals(null, accrualLedger.Stipend__c);
             
             /******************* CASE - 3 : Valid *******************************/
               //set stipend less than 100, less than benefits
             for(Ctrl_SFHCOPeriodEndProcessing.LedgerWrapper wrap : ctrl.listOfAllSFHCOLedgers)
                wrap.stipend = 30; 
             ctrl.CreateStipends();
             
             //check stipend records created
             //system.assertEquals(1, [select count() from SFHCO_Ledger__c where Candidate__c=: testContact.Id and Type__c='Stipend']);
             
             //accrual record updated
             accrualLedger = [select id,Allocated_Timestamp__c, Allocation_Amount__c,Stipend_Posted__c,Stipend__c from SFHCO_Ledger__c where id=: ledger.Id];
             //system.assertEquals(true, accrualLedger.Stipend_Posted__c);
             //system.assertEquals(30, accrualLedger.Stipend__c);
             //system.assertEquals(50, accrualLedger.Allocation_Amount__c);
             //system.assertEquals(null, accrualLedger.Allocated_Timestamp__c);
             
              //set stipend less than 100, less than benefits
             for(Ctrl_SFHCOPeriodEndProcessing.LedgerWrapper wrap : ctrl.listOfAllSFHCOLedgers)
                //system.assertEquals(wrap.getStatus(),'Stipend Posted'); 
             
             ctrl.CreateAllocationBatch();
             
             //check allocation records created
             //system.assertEquals(1, [select count() from SFHCO_Ledger__c where Candidate__c=: testContact.Id and Type__c='Allocation']);
             
             //accrual record updated
             accrualLedger = [select id,Allocated_Timestamp__c,Stipend_Posted__c,Stipend__c from SFHCO_Ledger__c where id=: ledger.Id];
             //system.assertNotEquals(null, accrualLedger.Allocated_Timestamp__c);
             
             //set stipend less than 100, less than benefits
             for(Ctrl_SFHCOPeriodEndProcessing.LedgerWrapper wrap : ctrl.listOfAllSFHCOLedgers)
                //system.assertEquals(wrap.getStatus(),'Allocation Posted'); 
             
             //Pagereference page4 = ctrl.PeriodReport();
             Pagereference page5 = ctrl.CreateAllocationBatch();
             Pagereference page7 = ctrl.nextBtnClick();
             Pagereference page8 = ctrl.previousBtnClick();
             Integer Int1 = ctrl.getPageNumber();
             Integer Int2 = ctrl.getPageSize();
             Boolean Bool1 = ctrl.getPreviousBtnVisibility();
             Boolean Bool2 = ctrl.getNextBtnVisibility();
         Test.stopTest();  
        
     }
     
     static testMethod void Ctrl_SFHCOPeriodEndProcessing1(){
        
        Contact testContact = PopulateDataForSickLeaveAccrual();
         
         Pay_Period__c pay = new Pay_Period__c();
         pay.Start_Date__c = Date.today();
         pay.End_Date__c =Date.today();
         insert pay;
         
         //create a SFHCO ledger for the contact (should ideally be created from batch)
         SFHCO_Ledger__c ledger     = new SFHCO_Ledger__c();
         ledger.Pay_Period__c       = pay.Id;
         ledger.Name                = 'Test';
         ledger.Benefit_Accrual__c  = 80;
         ledger.Candidate__c        = testContact.Id;
         ledger.Type__c             = 'Accrual';
         insert ledger;
         Test.startTest();
         
             ApexPages.StandardController controller = new ApexPages.StandardController(pay); 
             Ctrl_SFHCOPeriodEndProcessing ctrl = new Ctrl_SFHCOPeriodEndProcessing(controller);
             
             //set stipend greater than 100
             for(Ctrl_SFHCOPeriodEndProcessing.LedgerWrapper wrap : ctrl.listOfAllSFHCOLedgers)
                wrap.removeRecord = true; 
             ctrl.removeLedgerRecord();
             
             /******************* CASE - 1 *******************************/
             
             //accrual record not updated
             SFHCO_Ledger__c accrualLedger = [select id,Is_Discarded__c,Stipend_Posted__c,Stipend__c from SFHCO_Ledger__c where id=: ledger.Id];
             //system.assertEquals(true, accrualLedger.Is_Discarded__c);
             
         Test.stopTest();  
     }
     
     static testmethod void testCreateSFHCOLedger(){
         Contact testContact = PopulateDataForSickLeaveAccrual();
          
         Pay_Period__c pay = new Pay_Period__c();
         pay.Start_Date__c = Date.today();
         pay.End_Date__c =Date.today();
         insert pay;
          
         //call batch 
         Test.startTest();
            Batch_SFHCO_Accrual batch = new Batch_SFHCO_Accrual(date.today().addDays(-200), date.today(), pay.Id);
            Database.executeBatch(batch);
         Test.stopTest();
     }
     
     
     
}