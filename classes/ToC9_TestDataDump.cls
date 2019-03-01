public with sharing class ToC9_TestDataDump {
    
    //create a new account
    public Account getAClientAccount(Id marketId){
        Account acc = new Account();
        acc.name    = 'A Premier Staffing, Inc.';
        acc.RecordTypeId    = UtilClass.getRecordTypeId('Account','Candidate');
        acc.tc9_ti__InvoiceCycle__c = 'Weekly';
        acc.BillingStreet   = 'Str';
        acc.BillingCity     = 'Melbourne';
        acc.BillingState    = 'Victoria';
        acc.BillingPostalCode    = '3000';
        acc.AP_Email__c ='test1@ddd.com';
        
        acc.BillingCountry  = 'Australia';
        //acc.BillingCountry  = 'Australia';
        
        acc.tc9_ti__Market__c       = marketId;
        
        System.debug(acc);
        
        insert acc;
        
        return acc;
    }
    
    //create a client contact
    public Contact getAClientContact(ID accntID){
        Contact c = new Contact();
        c.lastName   = 'Test CC Contact';
        c.AccountID  = accntID;
        c.Salutation = 'Ms';
        c.FirstName  = 'Mark';
        c.Email      = 'client.test@xx.abc.com';
        c.MailingStreet   = 'Str';
        c.MailingCity     = 'Melbourne';
        c.MailingState    = 'Victoria';
        
        c.MailingCountry  = 'Australia';
        
        //TMA
        List<Contact> list_of_contacts = [SELECT lastName, AccountID, Salutation, FirstName, Email, MailingStreet, MailingCity, MailingState, MailingCountry from Contact where lastName = :c.LastName and AccountId = :c.AccountId and Email = :c.Email];
        if (list_of_contacts.size() == 0) {
            insert c; 
            return c;
        } else 
        {
            return list_of_contacts[0];
        }
        
        //return c;
    }
    
    //create a candidate
    public Contact getACandidate(String contactName){
        Account acc = new Account();
        acc.name    = 'Test Candidate Account';
        acc.RecordTypeId    = UtilClass.getRecordTypeId('Account','Candidate');
        insert acc;
        
        Contact c = new Contact();
        c.lastName  = contactName;
        c.RecordTypeId  = UtilClass.getRecordTypeId('Contact', 'Candidate');
        c.AccountID = acc.Id;
        c.email = contactName + '.test@xx.abc.com';
        insert c;
        return c;
    }
    
    public User getCustomerPortalUser(Contact portalContact){
        //create customer portal candidate
        Profile px = [select id from profile where name='~Customer Portal'];
        User usr = new User(alias = 'standt', email=portalContact.email,
                            emailencodingkey='UTF-8', lastname=portalContact.lastname, languagelocalekey='en_US',
                            localesidkey='en_US', profileid = px.id, contactId=portalContact.Id,
                            timezonesidkey='America/Los_Angeles', username=portalContact.email);
        insert usr; 
        return usr;
    }
    
    //create a new tax record
    public tc9_ti__TaxID__c getTaxID(){
        tc9_ti__TaxID__C tax = new tc9_ti__TaxID__c (tc9_ti__Rate__c = 0.1, tc9_ti__TaxID__c='tax');
        insert tax;
        return tax;
    }
    
    //create a new market
    public tc9_ti__Market__c getMarket(ID taxID){
        tc9_ti__Market__c market = new tc9_ti__Market__c(tc9_ti__MarketName__c = 'MarketName',tc9_ti__TaxID__c=taxID);
        insert market;
        return market;
    }
    
    public tc9_ti__Site__c getASite(String siteName, String siteURL){
        //insert a new site
        tc9_ti__Site__c sit = new tc9_ti__Site__c(name=siteName,tc9_ti__Site_URL__c = siteURL);
        insert sit;
        return sit;
    }
    
    //create a new job for the given client
    public ts2__Job__c  getAJob(Id accntId, Id contID,Id marketID, Id siteId){
        ts2__Job__c job = new ts2__Job__c();
        job.Name    = 'Test Job';
        job.ts2__Account__c = accntId;
        job.ts2__Contact__c = contID;
        job.tc9_ti__Bill_To_Account__c  = accntId;
        job.tc9_ti__Bill_To_Contact__c  = contId;
        job.ts2__Job_Function__c='FunABC';
        job.ts2__Department__c='DepABC';
        job.ts2__Location__c='LocAC';
        job.CurrencyIsoCode ='USD';
        job.ts2__Recruiter__c = UserInfo.getUserId();
        job.tc9_ti__Market__c   = marketID;
        job.tc9_ti__Site__c     = siteId;
        job.tc9_ti__Base_Bill_Rate__c   = 17;
        job.tc9_ti__Base_Pay_Rate__c    = 15;
        job.RecordTypeId = UtilClass.getRecordTypeId('ts2__Job__c','Temp');
        insert job;
        return job;
    }
     //create a public holiday calander
    public  tc9_ti__Public_Holiday_Calendar__c getPublicHolidayCal(){
        
        tc9_ti__Public_Holiday_Calendar__c clndr = new tc9_ti__Public_Holiday_Calendar__c();
        clndr.tc9_ti__Year__c = '2012';
        clndr.Name = 'Australia - Vic';
        insert clndr;
        return clndr;
    }
    
    
    //create a new placement for the given job, employee, start and end date, award master
    public ts2__Placement__c getAPlacement(ts2__Job__c job, Id calId, Id empId, Date startDate, Date endDate, Id awrdMasterID , String recordTypeName){
        
        ts2__Placement__c plc               = new ts2__Placement__c();
        
        //basic details
        plc.ts2__Start_Date__c              = startDate;
        plc.ts2__End_Date__c                = endDate;
        plc.RecordTypeId                    = UtilClass.getRecordTypeId('ts2__Placement__c', recordTypeName);
   
        //from job
        plc.ts2__Job__c                     = job.Id;
        plc.ts2__Client__c                  = job.ts2__Account__c;
        plc.tc9_ti__TimeSheetApprover__c            = job.ts2__Contact__c;
        plc.tc9_ti__AlternativeTimeSheetApprover__c = job.ts2__Contact__c;
        plc.tc9_ti__Market__c               = job.tc9_ti__Market__c;
        
        //rate
        plc.ts2__Bill_Rate__c               = 15;
        plc.ts2__Pay_Rate__c                = 10;
        plc.tc9_ti__Award_Master__c         = awrdMasterID;
        plc.ts2__Salary__c                  = 100;
        plc.tc9_ti__Conversion_Fee_Pct__c   = 100;
        
        //calendar
        plc.tc9_ti__Public_Holiday_Calendar__c  = calId;
        
        //candidate
        plc.ts2__Employee__c            = empId; 
        
        plc.tc9_ti__Hours_Wednesday__c  = 8;
        plc.tc9_ti__Hours_Tuesday__c    = 8; 
        plc.tc9_ti__Hours_Thursday__c   = 8; 
        plc.tc9_ti__Hours_Sunday__c     = 0;
        plc.tc9_ti__Hours_Saturday__c   = 0;
        plc.tc9_ti__Hours_Monday__c     = 8;
        plc.tc9_ti__Hours_Friday__c     = 8;
        plc.CurrencyIsoCode = 'USD';
        plc.tc9_ti__Pay_Schedule__c ='weekly';
      
      
        insert plc;
        return plc;
    }
    
    public tc9_ti__Award_Master__c getAnAward(){
        tc9_ti__Award_Master__c awrdMaster = new tc9_ti__Award_Master__c();
        awrdMaster.tc9_ti__Ordinary_Weekly_Hours__c    = 1;
        awrdMaster.tc9_ti__Minimum_Weekly_Paid_Hours__c   = 1;
        awrdMaster.tc9_ti__Minimum_Sunday_Paid_Hours__c   = 1;
        awrdMaster.tc9_ti__Minimum_Saturday_Paid_Hours__c  = 1;
        awrdMaster.tc9_ti__Minimum_Public_Holiday_Paid_Hours__c = 1;
        awrdMaster.tc9_ti__Interpret_On_Weekly_Totals__c   = true;
        awrdMaster.tc9_ti__Hourly_Standard_Rate__c    = 10;
        return awrdMaster;
    }
    
    public tc9_ti__Time_Sheet__c getATimesheet(Id plcId, Id candidateId, Date startDate, Date endDate){
        tc9_ti__Time_Sheet__c ts = new tc9_ti__Time_Sheet__c();
        ts.tc9_ti__Placement__c  = plcId;
        ts.tc9_ti__Candidate__c  = candidateId;
        ts.tc9_ti__Start_Date__c = startDate;
        ts.tc9_ti__End_Date__c   = endDate;
        return ts;
    }
    
    
    
    public tc9_ti__Time_Sheet_Entry__c getATimesheetEntry(Id tsId, Date workdate, String startTime, String endTime){
        tc9_ti__Time_Sheet_Entry__c entry = new tc9_ti__Time_Sheet_Entry__c();
        entry.tc9_ti__Time_Sheet__c = tsId;
        entry.tc9_ti__WorkDate__c   = workDate;
        entry.tc9_ti__StartTime__c  = startTime;
        entry.tc9_ti__EndTime__c    = endTime;
        return entry;
    }
    
    public tc9_ti__Transaction__c getATransaction(Id plcId, Date workDate, Decimal payMultiplier, Decimal billMultiplier, String paycode){
        tc9_ti__Transaction__c trans = new tc9_ti__Transaction__c();
        trans.tc9_ti__Placement__c   = plcId;
        trans.tc9_ti__EntryDate__c   = workDate;
        trans.tc9_ti__Bill_Multiplier__c = billMultiplier;
        trans.tc9_ti__Multiplier__c  = payMultiplier;
        trans.tc9_ti__Paycode__c     = paycode;
        return trans;
    }
    
    public Pay_Period__c getPayPeriod(Date startDate, Date endDate){
        Pay_Period__c pay = new Pay_Period__c();
        pay.Start_Date__c = startDate;
        pay.End_Date__c = endDate;        
        return pay;
    }
    
    public SFHCO_Ledger__c getSFHCOLedger(double hoursThisPayPeriod, Contact cont, date startDate, date endDate){
        SFHCO_Ledger__c led = new SFHCO_Ledger__c();
        led.Hours_This_Pay_Period__c = hoursThisPayPeriod;
        led.Candidate__c = cont.id;
        led.Start_Date__c = startDate;
        led.End_Date__c = endDate;
        return led;
    }
    
    
    
}