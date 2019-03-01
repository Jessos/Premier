/*
        @Scrum:             SC-11619
        @TestClassFor:      Batch_LeaveLedger and Scheduler_Batch_LeaveLedger
        @CreatedBy:         Sethuraman

Change History 
***************************************************************************************************************
    SCRUM          ModifiedBy          Date            Requested By            Description                   Tag
***************************************************************************************************************

*/

@isTest
private class TestScheduler_Batch_LeaveLedger {
    
    private static void prepareData(){
        
         ToC9_TestDataDump testDataDump = new ToC9_TestDataDump();
         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Location__c = 'San Francisco',
            TimeZoneSidKey='America/Los_Angeles', UserName='standardsfsduser@testorg.com');
        //create a new tax record
        tc9_ti__TaxID__c testTax = testDataDump.getTaxID();
          
        //create a new market
        tc9_ti__Market__c testMarket = testDataDump.getMarket(testTax.Id);
        
        //Create a site  
        tc9_ti__Site__c testSites = testDataDump.getASite('Test Site', 'www.test.com');
        
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
        update testAccount;
          
        //create a client contact
        Contact testContact = testDataDump.getAClientContact(testAccount.Id);
        testContact.Salutation  = 'Mr';
        update testContact;
        
        //Update Contact with Account Payable Lookup
        testAccount.ts2__Accounts_Payable__c = testContact.Id;
        update testAccount;
        
        //create an Employee
        Contact testEmployee = testDataDump.getAClientContact(testAccount.Id);
        testEmployee.First_Day_Worked__c = Date.today().addDays(-200);
        testEmployee.State__c = 'AL';
        update testEmployee;

        
        //Create an Award
        tc9_ti__Award_Master__c testAwardMaster = testDataDump.getAnAward();
        insert testAwardMaster;
        
        //Create a Job
        ts2__Job__c testJob = testDataDump.getAJob(testAccount.Id, testContact.Id, testMarket.Id, testSites.Id);
        testJob.ts2__Location__c = 'San Francisco';
        testJob.Street__c = 'Test';
        testJob.City__c = 'Test';
        testJob.State__c = 'T';
        testJob.Postal_Code__c = 'Test';
        update testJob;
        
        //create a public holiday calander
        tc9_ti__Public_Holiday_Calendar__c testCalendar = new tc9_ti__Public_Holiday_Calendar__c();
        testCalendar.tc9_ti__Year__c = String.valueOf(Date.today().year());
        testCalendar.Name = 'Australia - Vic';
        insert testCalendar;
        
         System.runAs(u) {
        ts2__Application__c app = new ts2__Application__c();
        app.ts2__Job__c = testJob.id;
        app.ts2__Candidate_Contact__c = testEmployee.id;
        app.ts2__SecondaryRecruiter__c =  u.id;
        insert app;
       
       ts2__Placement__c plc               = new ts2__Placement__c();
        
        //basic details
        plc.ts2__Start_Date__c              = Date.Today().toStartOfWeek().addDays(-10);
        plc.ts2__End_Date__c                = Date.Today().toStartOfWeek().addDays(-1);
        plc.RecordTypeId                    = UtilClass.getRecordTypeId('ts2__Placement__c', 'Temp');
   
        //from job
        plc.ts2__Job__c                     = testJob.Id;
        plc.ts2__Client__c                  = testJob.ts2__Account__c;
        plc.tc9_ti__TimeSheetApprover__c            = testJob.ts2__Contact__c;
        plc.tc9_ti__AlternativeTimeSheetApprover__c = testJob.ts2__Contact__c;
        plc.tc9_ti__Market__c               = testJob.tc9_ti__Market__c;
        
        //rate
        plc.ts2__Bill_Rate__c               = 25;
        plc.ts2__Pay_Rate__c                = 10;
        plc.tc9_ti__Award_Master__c         = testAwardMaster.id;
        plc.ts2__Salary__c                  = 100;
        plc.tc9_ti__Conversion_Fee_Pct__c   = 100;
        
        //calendar
        plc.tc9_ti__Public_Holiday_Calendar__c  = testCalendar.id;
        
        //candidate
        plc.ts2__Employee__c            = testEmployee.id; 
        
        plc.tc9_ti__Hours_Wednesday__c  = 8;
        plc.tc9_ti__Hours_Tuesday__c    = 8; 
        plc.tc9_ti__Hours_Thursday__c   = 8; 
        plc.tc9_ti__Hours_Sunday__c     = 0;
        plc.tc9_ti__Hours_Saturday__c   = 0;
        plc.tc9_ti__Hours_Monday__c     = 8;
        plc.tc9_ti__Hours_Friday__c     = 8;
        plc.CurrencyIsoCode = 'USD';
        plc.tc9_ti__Pay_Schedule__c ='weekly';
        PLC.ts2__Filled_By_2__c = app.ts2__SecondaryRecruiter__c; 
        plc.ts2__Related_Application__c = app.id;
        insert plc;
        
        plc= [SELECT Id, Is_Eligible_for_Sick_Leave_Accrual__c FROM ts2__Placement__c WHERE Id=: plc.id];
        System.debug('@@@@@ '+plc);
       
        //create a candidate
        Contact testCandidate = testDataDump.getACandidate('contactName');
        testCandidate.Last_Date_Worked__c = Date.today();
        update testCandidate;
        
        //Create a Timesheet
        tc9_ti__Time_Sheet__c testTimesheet = testDataDump.getATimesheet(plc.Id, testCandidate.Id , Date.Today().toStartOfWeek().addDays(-10), Date.Today().toStartOfWeek().addDays(-1));
        insert testTimesheet;
       
        //insert a list Of Time_Sheet entry
        List<tc9_ti__Time_Sheet_Entry__c> listOfTimesheetEntrys = new List<tc9_ti__Time_Sheet_Entry__c>();
        for(Integer i = 0; i < 200; i++){
            
            tc9_ti__Time_Sheet_Entry__c testTimesheetEntry = testDataDump.getATimesheetEntry(testTimesheet.Id,  Date.today().addDays(-i), '00:00', '08:00');
            listOfTimesheetEntrys.add(testTimesheetEntry);
        }
        
        insert listOfTimesheetEntrys;
        
        
        //create a candidate
       // Contact testCandidate1 = testDataDump.getACandidate('contactName');
        //testCandidate1.Last_Date_Worked__c = Date.today().addYears(-2);
       // update testCandidate1;
        
        Leave_Ledger__c ledger  = new Leave_Ledger__c();
        ledger.Type__c          = 'Sick Leave';
        ledger.Contact__c       = testCandidate.Id;
        ledger.Leave_Hours__c   = 5;    //add 5 hours leave for the candidate
        ledger.Reason__c        = 'Leave Accrual';
        ledger.Name             = 'Leave Accrual'; 
        ledger.Date_Incurred__c = Date.today();
        ledger.Status__c        = 'Accrued';
        insert ledger;
        
        Leave_Ledger__c ledger2  = new Leave_Ledger__c();
        ledger2.Type__c          = 'Sick Leave';
        ledger2.Contact__c       = testCandidate.Id;
        ledger2.Leave_Hours__c   = 5;    //add 5 hours leave for the candidate
        ledger2.Reason__c        = 'Leave Accrual';
        ledger2.Name             = 'Leave Accrual'; 
        ledger2.Date_Incurred__c = Date.today();
        ledger2.Status__c        = 'Accrued';
        insert ledger2;

    }
   }
    static testMethod void testScheduler_Batch_LeaveLedger() {

    }
}