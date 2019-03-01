/*
    Class      : TestDataDump
    Developer  : 2c9 
    Reason     : Helper class for test classes (Used for data creation)

    Change History
    ******************************************************************************************************************************************
         SCRUM        ModifiedBy        Date            Requested By                           Description                              Tag
    ******************************************************************************************************************************************
        Sc-11480      Khushboo.B        05/08/2016      Benoit Legalant             Increasing the code coverage


*/ 
public with sharing class TestDataDump {
    
    public tc9_ti__PayCodeMaster__c Expense = new tc9_ti__PayCodeMaster__c();
    public tc9_ti__PayCodeMaster__c Allowance = new tc9_ti__PayCodeMaster__c();
        
    Id awardMasterID;
    public TestDataDump(){
        
        awardMasterID    = UtilClass1.getTypeId_ByDeveloperName(NamespaceUtil1.getObjectName(new tc9_ti__Award_Master__c()), UtilClass1.AWARD_DAILY_REC_TYPE);
        Expense.tc9_ti__Paycode__c = 'EXP';
        Expense.Name = 'Expense';
        List<tc9_ti__PayCodeMaster__c> listOfPaycodes = new List<tc9_ti__PayCodeMaster__c>([Select tc9_ti__Paycode__c from tc9_ti__PaycodeMaster__c where tc9_ti__Paycode__c = 'EXP' OR tc9_ti__Paycode__c = 'ALW']);
        Integer exp = 0;
        Integer alw = 0;
        if(listOfPaycodes.size()>0)
        {
            for(tc9_ti__PayCodeMaster__c p : listOfPaycodes)
            {
                if(p.tc9_ti__Paycode__c == 'EXP')
                    exp++;
                else if (p.tc9_ti__Paycode__c == 'ALW')
                    alw++;
            }
        }
        if(exp == 0)
            insert Expense;     
        

        Allowance.tc9_ti__Paycode__c = 'ALW';
        Allowance.Name = 'Allowance';
        if(alw == 0)
            insert Allowance;

    }   
    
    
    //create a new account
    public Account getAClientAccount(Id marketId){
        Account acc = new Account();
        acc.name    = 'Test Account';
        acc.RecordTypeId    = UtilClass1.getRecordTypeId('Account','Candidate');
        acc.tc9_ti__InvoiceCycle__c = 'Weekly';
        acc.BillingStreet   = 'Str';
        acc.BillingCity     = 'Melbourne';
        acc.BillingState    = 'Victoria';
        acc.BillingPostalCode    = '645';
        acc.BillingCountry  = 'Australia';
        acc.tc9_ti__Market__c       = marketId;
        acc.ts2__Invoice_Terms__c = '15';
        acc.tc9_ti__Invoice_Group_By__c = 'Placement'; 
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
        c.State__c = 'AZ';
        insert c;
        return c;
    }
    
    //create a candidate
    public Contact getACandidate(String contactName){
        Account acc = new Account();
        acc.name    = 'Test Candidate Account';
        acc.RecordTypeId    = UtilClass1.getRecordTypeId('Account','Candidate');
        insert acc;
        
        Contact c = new Contact();
        c.FirstName = 'test';
        c.lastName  = contactName;
        c.RecordTypeId  = UtilClass1.getRecordTypeId('Contact', 'Candidate');
        c.AccountID = acc.Id;
        c.email = contactName + '.test@xx.abc.com';
        insert c;
        return c;
    }
    
    public User getCustomerPortalUser(Contact portalContact){
        //create customer portal candidate
        Profile px = [select id from profile where name like '%Customer Portal Manager Custom%' limit 1];
        User usr = new User(alias = 'standt', email=portalContact.email,
            emailencodingkey='UTF-8', lastname=portalContact.lastname, languagelocalekey='en_US',
            localesidkey='en_US', profileid = px.id, contactId=portalContact.Id, Location__c ='New York',
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
    
    //create a public holiday calander
    public tc9_ti__Public_Holiday_Calendar__c getPublicHolidayCal(){
        
        tc9_ti__Public_Holiday_Calendar__c clndr = new tc9_ti__Public_Holiday_Calendar__c();
        clndr.tc9_ti__Year__c = '2012';
        clndr.Name = 'Australia - Vic';
        insert clndr;
        return clndr;
    }
    
    //add a holiday in the given calander, for the given start and end time
    public void addHoliday(Id calID,Date startDate,Date endDate){
        
        tc9_ti__Public_Holiday_Calendar_Item__c clndrItem = new tc9_ti__Public_Holiday_Calendar_Item__c ();
        clndrItem.tc9_ti__Start_Date__c = startDate;
        clndrItem.tc9_ti__Public_Holiday_Calendar__c = calID;
        clndrItem.tc9_ti__End_Date__c = endDate;
        insert clndrItem;
    }
    
    public tc9_ti__Site__c getASite(String siteName, String siteURL){
        //insert a new site
        tc9_ti__Site__c sit = new tc9_ti__Site__c(name=siteName,tc9_ti__Site_URL__c = siteURL);
        insert sit;
        return sit;
    }    
    //create a new placement for the given job, employee, start and end date, award master
    public ts2__Placement__c getAPlacement(ts2__Job__c job, Id calId, Id empId, Date startDate, Date endDate, Id awrdMasterID , String recordTypeName){
        
        ts2__Placement__c plc               = new ts2__Placement__c();
        
        //basic details
        plc.ts2__Start_Date__c              = startDate;
        plc.ts2__End_Date__c                = endDate;
        plc.RecordTypeId                    = UtilClass.getRecordTypeId('ts2__Placement__c', 'Perm');
        system.debug('Accccount '+job.ts2__Account__c);
        //from job 
        plc.ts2__Job__c        = job.Id;
      //  system.debug('jobname-->'+job.ts2__Client__r.name);
        plc.ts2__Client__c                  = job.ts2__Account__c;
        plc.tc9_ti__Bill_To_Account__c              = job.ts2__Account__c;
        plc.tc9_ti__Bill_To_Contact__c              = job.tc9_ti__Bill_To_Contact__c;
        
        plc.tc9_ti__TimeSheetApprover__c            = job.ts2__Contact__c;
        plc.tc9_ti__AlternativeTimeSheetApprover__c = job.ts2__Contact__c;
        plc.tc9_ti__Market__c                       = job.tc9_ti__Market__c;
      //  plc.CurrencyISOCode                 = job.CurrencyISOCode ;
        plc.tc9_ti__Timesheet_Frequency__c          = 'Weekly'; 
        
        //rate
        plc.ts2__Bill_Rate__c               = 10;
        plc.ts2__Pay_Rate__c                = 10;
        plc.tc9_ti__Base_Bill_Rate__c               = 10;
        plc.tc9_ti__Base_Pay_Rate__c                = 10;
        plc.tc9_ti__Award_Master__c                 = awrdMasterID;
        plc.ts2__Salary__c                  = 100;
        plc.tc9_ti__Conversion_Fee__c                   =100;
        plc.tc9_ti__Conversion_Fee_Pct__c           = 100;
            
        //calendar
        plc.tc9_ti__Public_Holiday_Calendar__c  = calId;
        
        //candidate
        plc.ts2__Employee__c            = empId; 
       
        plc.tc9_ti__Hours_Wednesday__c = 8;
        plc.tc9_ti__Hours_Tuesday__c = 8; 
        plc.tc9_ti__Hours_Thursday__c = 8; 
        plc.tc9_ti__Hours_Sunday__c = 0;
        plc.tc9_ti__Hours_Saturday__c = 0;
        plc.tc9_ti__Hours_Monday__c = 8;
        plc.tc9_ti__Hours_Friday__c = 8;
        
     	ts2__Application__c app=new ts2__Application__c(ts2__Job__c=job.Id,ts2__Candidate_Contact__c=empId);
        insert app;
        
   		plc.ts2__Related_Application__c=app.Id;
        plc.tc9_ti__Purchase_Order_Number__c = '12345';
        
        insert plc;
        return plc;
    }
    
    public ts2__Placement__c getPlacementFields(Id plcId){
        
        ts2__Placement__c plc = [Select Name,tc9_ti__Rate_calculator__c, ts2__Related_Application__r.ts2__Candidate_Contact__r.Id, ts2__Start_Date__c, ts2__End_Date__c, tc9_ti__Public_Holiday_Calendar__c, CurrencyISOCode,
                                  tc9_ti__Hours_Monday__c, tc9_ti__Hours_Tuesday__c, tc9_ti__Hours_Wednesday__c, tc9_ti__Hours_Thursday__c, tc9_ti__Hours_Friday__c, tc9_ti__Hours_Saturday__c,  tc9_ti__WorkingPublicHolidays__c, 
                                  tc9_ti__Hours_Sunday__c, tc9_ti__Is_timesheet_created__c, ts2__Job__r.tc9_ti__Public_Holiday_Calendar__c, tc9_ti__Exclude_from_Auto_Timesheet_Creation__c,
                                  tc9_ti__Award_Master__c, tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_Start_Time__c,tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_End_Time__c, tc9_ti__Market__c,tc9_ti__Timesheets_Pending_Creation__c,
                                  tc9_ti__AlternativeTimeSheetApprover__c,ts2__Salary__c,tc9_ti__Is_Transaction_Created__c,ts2__job__r.tc9_ti__Site__c, ts2__job__r.tc9_ti__Week_Start_Day__c,ts2__Client__r.tc9_ti__Invoice_Group_By__c,
                                  ts2__Client__r.tc9_ti__Week_Start_Day__c,tc9_ti__Timesheet_Frequency__c,tc9_ti__Conversion_Fee_Pct__c,ts2__Fee_Pct__c,tc9_ti__occupation__c,tc9_ti__Bill_To_Account__c, tc9_ti__Bill_To_Contact__c, tc9_ti__Bill_To_Account__r.tc9_ti__Billing_Entity__c,
                                  recordType.Name,ts2__Employee__c, tc9_ti__Base_Pay_Rate__c, tc9_ti__Base_Bill_Rate__c ,ts2__Job__r.tc9_ti__Site__r.tc9_ti__Portal_Profile_Name__c,tc9_ti__Split_Timesheets_Over_Months__c , tc9_ti__AlternativeTimeSheetApprover__r.LastName,
                                  tc9_ti__AlternativeTimeSheetApprover__r.FirstName, tc9_ti__Client_Hiring_Manager__c, tc9_ti__Purchase_Order_Number__c                                  
                                From ts2__Placement__c Where id =: plcId];

         return plc;
    }
    
    //insert a new award master
    public tc9_ti__Award_Master__c getAnAwardMaster(Decimal ordWeekly, Decimal minWeekly, Decimal minSunday, Decimal minSaturday, Decimal minPubHol, Boolean interpretation){
        
        tc9_ti__Award_Master__c awrdMaster  = new tc9_ti__Award_Master__c();
        awrdMaster.tc9_ti__Ordinary_Weekly_Hours__c             = ordWeekly;
        awrdMaster.tc9_ti__Minimum_Weekly_Paid_Hours__c         = minWeekly;
        awrdMaster.tc9_ti__Minimum_Sunday_Paid_Hours__c         = minSunday;
        awrdMaster.tc9_ti__Minimum_Saturday_Paid_Hours__c       = minSaturday;
        awrdMaster.tc9_ti__Minimum_Public_Holiday_Paid_Hours__c = minPubHol;
        awrdMaster.tc9_ti__Interpret_On_Weekly_Totals__c        = interpretation;
        awrdMaster.tc9_ti__Hourly_Standard_Rate__c              = 10;
        awrdMaster.RecordTypeId                         = awardMasterID;
        
        insert awrdMaster;
        return awrdMaster;
    }
    
    
    //for threshold based rules
    public tc9_ti__Rule__c getThresholdRule(String name, Id awrdID, String ruleType, Decimal startT, Decimal endT, Decimal billMul, Decimal payMul, Id paycodeId, Decimal discount){
        tc9_ti__Rule__c rule = new tc9_ti__Rule__c();
        rule.Name    = name;
        rule.tc9_ti__Award_Master__c     = awrdID;
        rule.tc9_ti__Type__c    = ruleType;
        rule.tc9_ti__Start_Threshold__c = startT;
        rule.tc9_ti__End_Threshold__c   = endT;
        rule.tc9_ti__Bill_Multiplier__c = billMul;
        rule.tc9_ti__Pay_Multiplier__c  = payMul;
        rule.tc9_ti__Paycode__c         = paycodeId;
        rule.tc9_ti__Discount_Percentage__c = discount;
        
        return rule;
    }
    
    //for time based rules
    public tc9_ti__Rule__c getTimeRule(String name, Id awrdID, String ruleType, String startT, String endT, Decimal billMul, Decimal payMul, Id paycodeId, Decimal discount){
        tc9_ti__Rule__c rule = new tc9_ti__Rule__c();
        rule.Name    = name;
        rule.tc9_ti__Award_Master__c     = awrdID;
        rule.tc9_ti__Type__c    = ruleType;
        rule.tc9_ti__Start_Time__c  = startT;
        rule.tc9_ti__End_Time__c    = endT;
        rule.tc9_ti__Bill_Multiplier__c = billMul;
        rule.tc9_ti__Pay_Multiplier__c  = payMul;
        rule.tc9_ti__Paycode__c         = paycodeId;
        rule.tc9_ti__Discount_Percentage__c = discount;
        
        return rule;
    }
    
    //for amount based rules
    public tc9_ti__Rule__c getAllowanceRule(String name, Id awrdID, String ruleType, Decimal endT,Decimal amount){
        
        tc9_ti__Rule__c rule = new tc9_ti__Rule__c();
        rule.Name    = name;
        rule.tc9_ti__End_Threshold__c = endT;
        rule.tc9_ti__Award_Master__c     = awrdID;
        rule.tc9_ti__Type__c    = ruleType;
        rule.tc9_ti__Amount__c  = amount;
        
        return rule;
    }
    
 /*  Not used in code
     public tc9_ti__Rule__c getAllowanceRule(String name, Id awrdID, String ruleType, Decimal endT,Decimal amount, Id paycodeId){
        
        tc9_ti__Rule__c rule = new tc9_ti__Rule__c();
        rule.Name    = name;
        rule.tc9_ti__End_Threshold__c = endT;
        rule.tc9_ti__Award_Master__c     = awrdID;
        rule.tc9_ti__Type__c    = ruleType;
        rule.tc9_ti__Amount__c  = amount;
        rule.tc9_ti__Paycode__c = paycodeId;
        
        return rule;
    }*/
    
 /*  Not used in code
    //create a rate calculator
    public tc9_ti__Rate_Calculator__c getRateCalculator(id contid,id awrdId) {
        tc9_ti__Rate_Calculator__c rateCalc = new tc9_ti__Rate_Calculator__c();
        rateCalc.tc9_ti__Candidate__c=contid;
        rateCalc.tc9_ti__Award_Master__c=awrdId;
        rateCalc.tc9_ti__Calculation_Period_Start__c= date.today().addDays(-1);
        rateCalc.tc9_ti__Calculation_Period_End__c= date.today().addDays(1);
        ratecalc.RecordTypeId=UtilClass1.getRecordTypeId((NamespaceUtil1.getObjectName(rateCalc)),'Candidate Specific');
        
        return rateCalc;
    }*/
    
     
 /*  Not used in code
    // create a Mark up/Margin Rate Record
    public tc9_ti__Mark_Up_Margin_Rate_Record__c getMarkUpMarginRateRec(id RateCalc, id CalcMethod) {        
        tc9_ti__Mark_Up_Margin_Rate_Record__c mark      = new tc9_ti__Mark_Up_Margin_Rate_Record__c();
        mark.tc9_ti__Rate_Calculator__c                 = RateCalc;
        mark.tc9_ti__Effective_Date__c                  = date.today();
        mark.tc9_ti__Calculation_Method1__c             = CalcMethod;
        mark.tc9_ti__Calculation_Method__c              = 'Mark Up - Fixed $';        
        return mark;
    }*/
     /*  Not used in code
    //create a Rate Record
    public tc9_ti__Rate_Record__c getRateRec(id cont,id rateCalc) {
        tc9_ti__Rate_Record__c rateRec = new tc9_ti__Rate_Record__c();
        rateRec.tc9_ti__Candidate__c = cont;
        rateRec.tc9_ti__Rate_Calculator__c = rateCalc;
        return rateRec;
    }*/
    
    /*  Not used in code
    //return a Rate Calculator Line 
    public tc9_ti__Rate_Calculator_Line__c getRateCalcLine(id cont, id rateCalc) {
        tc9_ti__Rate_Calculator_Line__c rateCalcLine = new tc9_ti__Rate_Calculator_Line__c();
        rateCalcLine.tc9_ti__Candidate__c = cont;
        rateCalcLine.tc9_ti__Rate_Calculator__c = rateCalc;
        return rateCalcLine;
    }*/
	
    /*  Not used in code
    //return a Pay Rate Loading 
    public tc9_ti__Pay_Rate_Loading__c getPayRateLoading(id awrdMaster) {
        tc9_ti__Pay_Rate_Loading__c prl = new tc9_ti__Pay_Rate_Loading__c ();
        prl.tc9_ti__Award_Master__c = awrdMaster;
        return prl;
    }*/
        /*  Not used in code
    //create a Calculation Method
    public tc9_ti__Calculation_Method__c getCalcMethod() {
        tc9_ti__Calculation_Method__c calcMeth = new tc9_ti__Calculation_Method__c();
        calcMeth.tc9_ti__Description__c='Test Description';
        calcMeth.tc9_ti__Type__c='Margin';
        return calcMeth;
    }*/
      /*  Not used in code
//Create a Calculation Rates Master
    public tc9_ti__Calculation_Rates_Master__c getCalcRatesMaster() {
        tc9_ti__Calculation_Rates_Master__c crm = new tc9_ti__Calculation_Rates_Master__c();
        crm.tc9_ti__Calculation_Rates_Master_Name__c='test Name';
        return crm;
    }*/
    /*  Not used in code
    //create a Calculation Rates Item
    public tc9_ti__Calculation_Rates_Item__c getCalcRatesItem(id master) {
        tc9_ti__Calculation_Rates_Item__c cri = new tc9_ti__Calculation_Rates_Item__c();
        cri.tc9_ti__Calculation_Rates_Master__c = master;
        return cri;
    }*/
    
      /*  Not used in code
    public tc9_ti__Rate_Calculation_Rules__c getRateCalcRule(tc9_ti__Calculation_Method__c calcMethod){
        tc9_ti__Rate_Calculation_Rules__c newRule       = new tc9_ti__Rate_Calculation_Rules__c();
        newRule.tc9_ti__Level_1_Calculation_Method__c   = calcMethod.Id;
        newRule.tc9_ti__Level_1_Standard_Rate_1__c      = 10;
        newRule.tc9_ti__Level_1_Standard_Rate_2__c      = 10;
        return newRule;     
    }*/
    
    public void createRules(Id awrdMaster){
        
        //create pay code
        tc9_ti__PayCodeMaster__c pycode = new tc9_ti__PayCodeMaster__c(RecordTypeId = UtilClass.getRecordTypeId(NamespaceUtil1.getObjectName(new tc9_ti__PayCodeMaster__c()), 'TimeSheet'), tc9_ti__Paycode__c='PayCode1' , tc9_ti__Description__c = 'PayCode1', name = 'PayCode 1');
        insert pycode;
        
        List<tc9_ti__Rule__c> rules1 = new List<tc9_ti__Rule__c>();
        
        //add Rules to the Award Master
        rules1.add( getThresholdRule('Daily BP 1', awrdMaster, AwardMasterRecord.DAILY_HOURS_BREAKPOINT_RULE,  0.0, 10.0, 1.0, 1.0, pycode.Id, 0.0));
        rules1.add( getThresholdRule('Daily BP 2',awrdMaster, AwardMasterRecord.DAILY_HOURS_BREAKPOINT_RULE, 10.0, 12.0, 1.5, 1.5, pycode.Id, 0.0));
        rules1.add( getThresholdRule('Daily BP 2',awrdMaster, AwardMasterRecord.DAILY_HOURS_BREAKPOINT_RULE, 12.0, 24.0, 2.0, 2.0, pycode.Id, 0.0));
        
        rules1.add( getThresholdRule('Daily T BP 1', awrdMaster, AwardMasterRecord.DAILY_TIME_BREAKPOINT_RULE,  0.0, 2.0, 1.5, 1.5, pycode.Id, 0.0));
        rules1.add( getThresholdRule('Daily T BP 2',awrdMaster, AwardMasterRecord.DAILY_TIME_BREAKPOINT_RULE, 2.0, 24.0, 2.0, 2.0, pycode.Id, 0.0));
        
        rules1.add( getThresholdRule('Wk BP 1',awrdMaster, AwardMasterRecord.WEEKLY_BREAKPOINT_RULE,  0.0,  38.0, 1.0, 1.0, pycode.Id, 0.0));
        rules1.add( getThresholdRule('Wk BP 2',awrdMaster, AwardMasterRecord.WEEKLY_BREAKPOINT_RULE, 38.0,  40.0, 1.5, 1.5, pycode.Id, 0.0));
        rules1.add( getThresholdRule('Wk BP 3',awrdMaster, AwardMasterRecord.WEEKLY_BREAKPOINT_RULE, 40.0, 168.0, 2.0, 2.0, pycode.Id, 0.0));
        
        rules1.add( getTimeRule('Saturday Rule'     ,awrdMaster, AwardMasterRecord.SATURDAY_RULE            , '09:00', '17:00', 1.5, 1.5, pycode.Id, 0.0));
        rules1.add( getTimeRule('Sunday Rule'       ,awrdMaster, AwardMasterRecord.SUNDAY_RULE              , '09:00', '17:00', 1.5, 1.5, pycode.Id, 0.0));
        rules1.add( getTimeRule('Outside Saturday Rule',awrdMaster, AwardMasterRecord.OUTSIDE_SATURDAY_RULE , '00:00', '00:00',   2,   2, pycode.Id, 0.0));
        rules1.add( getTimeRule('Outside Sunday Rule'  ,awrdMaster, AwardMasterRecord.OUTSIDE_SUNDAY_RULE   , '00:00', '00:00',   2,   2, pycode.Id, 0.0));
        rules1.add( getTimeRule('Public Hol'            ,awrdMaster, AwardMasterRecord.PUBLIC_HOLIDAY_RULE      , '00:00', '00:00',   2.5,   2.5, pycode.Id, 0.0));
        
        rules1.add( getAllowanceRule('Meal',awrdMaster, AwardMasterRecord.MEAL_RULE, 0, 20.0));
        rules1.add( getAllowanceRule('Allowance BP 1',awrdMaster, AwardMasterRecord.ALLOWANCE_BREAKPOINT,10, 15.0));
        rules1.add( getAllowanceRule('Allowance BP 2',awrdMaster, AwardMasterRecord.ALLOWANCE_BREAKPOINT,12, 20.0));
        rules1.add( getAllowanceRule('Allowance BP 3',awrdMaster, AwardMasterRecord.ALLOWANCE_BREAKPOINT,13, 25.0));
        
        insert rules1;
    }
   
    /* Not used in code
    public tc9_ti__Deduction__c getDeduction(Id template) {
        tc9_ti__Deduction__c newDeduction = new tc9_ti__Deduction__c();
        newDeduction.Name = 'Test Deduction';
        newDeduction.tc9_ti__Deduction_Template__c = template;
        newDeduction.tc9_ti__Status__c = 'Active';
        
        return newDeduction;        
    } 
    
    public tc9_ti__Deduction_Template__c getDeductionTemplate() {
        tc9_ti__Deduction_Template__c newTemplate = new tc9_ti__Deduction_Template__c();
        newTemplate.Name = 'Test Deduction Template';
        newTemplate.tc9_ti__Status__c = 'Active';
        
        return newTemplate;
    }  
    
    public tc9_ti__PayCodeMaster__c getPayCode() {
        tc9_ti__PayCodeMaster__c newPayCode = new tc9_ti__PayCodeMaster__c();
        newPayCode.Name = 'Test Pay Code';
        newPayCode.tc9_ti__Paycode__c='PayCode1' ;
        newPayCode.tc9_ti__Description__c = 'PayCode1';
        
        return newPayCode;
    }
    
    public tc9_ti__Payrun__c getPayrun(){
        tc9_ti__Payrun__c oPayrun = new tc9_ti__Payrun__c();
        oPayrun.tc9_ti__Status__c          = 'Open';
        oPayrun.tc9_ti__Payrun_Name__c      = 'Test';
        oPayrun.tc9_ti__Creation_Date__c   = DateTime.now();

        return oPayrun;
    }*/
    
   /* not used in code 
     public tc9_ti__Payrun_Record__c getPayrunRecord(Id Payrun) {
        tc9_ti__Payrun_Record__c oPayRecord = new tc9_ti__Payrun_Record__c ();
        oPayRecord.tc9_ti__Payrun__c        = Payrun;        
        oPayRecord.tc9_ti__Status__c        = 'Open'; 
        
        return oPayRecord;             
*/
    
    public tc9_ti__Project_Code__c getProjectCode(Id accId) {
        tc9_ti__Project_Code__c oProCode = new tc9_ti__Project_Code__c(Name = 'TestProjectCode', tc9_ti__Client__c = accId, tc9_ti__Status__c = 'Active');
        return oProCode;
    }
    
    /*public tc9_ti__Job_Project_Code__c getJobProjectCode(Id jobId, Id proId) {
        tc9_ti__Job_Project_Code__c oJobProCode = new tc9_ti__Job_Project_Code__c(tc9_ti__Job_Order__c = jobId, tc9_ti__Project_Code__c = proId);
        return oJobProCode;
    }
    
    public tc9_ti__Client_Group__c getClientGroup() {
        tc9_ti__Client_Group__c oGrp = new tc9_ti__Client_Group__c(Name = 'Test Group');
        return oGrp;
    } 
    public tc9_ti__Occupation__c getOccupation() {
        tc9_ti__Occupation__c oOccupation = new tc9_ti__Occupation__c();
        oOccupation.Name = 'Test Occupation';
        for(Schema.PicklistEntry pE : oOccupation.getSObjectType().getDescribe().fields.getMap().get('tc9_ti__Classification__c').getDescribe().getPickListValues()) {
            oOccupation.tc9_ti__Classification__c = pE.getLabel();
            break;
        }
        
        return oOccupation;
    }
    
    public tc9_ti__Rate_Card__c getRateCard() {
        tc9_ti__Rate_Card__c oRateCard = new tc9_ti__Rate_Card__c(Name = 'Test Rate Card');
        return oRateCard;       
    }*/
    
    //create a new job for the given client
    public ts2__Job__c  getAJob(Id accntId, Id contID,Id marketID, Id siteId){
        ts2__Job__c job             = new ts2__Job__c();
        job.Name                    = 'Test Job';
        job.ts2__Account__c         = accntId;
        job.ts2__Contact__c         = contID;
        job.ts2__Job_Function__c    ='FunABC';
        job.ts2__Department__c      ='DepABC';
        job.ts2__Location__c        ='LocAC';
        job.ts2__Recruiter__c       = UserInfo.getUserId();
        job.tc9_ti__Market__c               = marketID;
        job.tc9_ti__Site__c                 = siteId;
        job.RecordTypeId            = UtilClass1.getTypeId_ByDeveloperName('ts2__Job__c','Temp');
        job.tc9_ti__Job_Start_Date__c       = date.parse('07/23/2012');
        job.tc9_ti__Job_End_Date__c         = date.parse('07/23/2012').addDays(12);
        job.tc9_ti__Job_Start_Date_custom__c = date.parse('07/23/2012');
        job.tc9_ti__Job_End_Date_custom__c   =  date.parse('07/23/2012').addDays(12);
        job.tc9_ti__Bill_To_Account__c       = accntId;
        job.tc9_ti__Bill_To_Contact__c      = contId; 
      //  job.currencyISOCode = 'USD';   
       
        insert job;
        return job;
    }
    
    //insert a new award master
    public tc9_ti__Award_Master__c getAnAwardMaster(Decimal ordWeekly, Decimal minWeekly, Decimal minSunday, Decimal minSaturday, Decimal minPubHol, String stdStartTime, String stdEndTime, Boolean interpretation, Id recTypeID){
        
        tc9_ti__Award_Master__c awrdMaster  = new tc9_ti__Award_Master__c();
        awrdMaster.tc9_ti__Ordinary_Weekly_Hours__c             = ordWeekly;
        awrdMaster.tc9_ti__Minimum_Weekly_Paid_Hours__c         = minWeekly;
        awrdMaster.tc9_ti__Minimum_Sunday_Paid_Hours__c         = minSunday;
        awrdMaster.tc9_ti__Minimum_Saturday_Paid_Hours__c       = minSaturday;
        awrdMaster.tc9_ti__Minimum_Public_Holiday_Paid_Hours__c = minPubHol;
        awrdMaster.tc9_ti__Interpret_On_Weekly_Totals__c        = interpretation;
        awrdMaster.tc9_ti__Hourly_Standard_Rate__c              = 10;
        awrdMaster.tc9_ti__Standard_Daily_Start_Time__c         = stdStartTime;
        awrdMaster.tc9_ti__Standard_Daily_End_Time__c           = stdEndTime;
        awrdMaster.RecordTypeId                         = recTypeID;
        awrdMaster.tc9_ti__Days_Weekly_Break_Applies__c         = 'Monday;Tuesday;Wednesday;Thursday;Friday;Saturday;Sunday';
        
        insert awrdMaster;
        return awrdMaster;
    }
    
 /* Not used in code
     public void createAwardRules(Id awrdMaster){
        
        //create pay code
        tc9_ti__PayCodeMaster__c pycode = new tc9_ti__PayCodeMaster__c(RecordTypeId = UtilClass1.getTypeId_ByDeveloperName(NamespaceUtil1.getObjectName(new tc9_ti__PayCodeMaster__c()), 'TimeSheet'), tc9_ti__Paycode__c='PayCode1' , tc9_ti__Description__c = 'PayCode1', name = 'PayCode 1');
        insert pycode;
        
        List<tc9_ti__Rule__c> rules1 = new List<tc9_ti__Rule__c>();
        
        //add Rules to the Award Master
        rules1.add( getThresholdRule('Daily BP 1', awrdMaster, AwardMasterRecord.DAILY_HOURS_BREAKPOINT_RULE,  0.0, 10.0, 1.0, 1.0, pycode.Id, 0.0));
        rules1.add( getThresholdRule('Daily BP 2',awrdMaster, AwardMasterRecord.DAILY_HOURS_BREAKPOINT_RULE, 10.0, 12.0, 1.5, 1.5, pycode.Id, 0.0));
        rules1.add( getThresholdRule('Daily BP 2',awrdMaster, AwardMasterRecord.DAILY_HOURS_BREAKPOINT_RULE, 12.0, 24.0, 2.0, 2.0, pycode.Id, 0.0));
        
        rules1.add( getThresholdRule('Daily T BP 1', awrdMaster, AwardMasterRecord.DAILY_TIME_BREAKPOINT_RULE,  0.0, 2.0, 1.5, 1.5, pycode.Id, 0.0));
        rules1.add( getThresholdRule('Daily T BP 2',awrdMaster, AwardMasterRecord.DAILY_TIME_BREAKPOINT_RULE, 2.0, 24.0, 2.0, 2.0, pycode.Id, 0.0));
        
        rules1.add( getThresholdRule('Wk BP 1',awrdMaster, AwardMasterRecord.WEEKLY_BREAKPOINT_RULE,  0.0,  38.0, 1.0, 1.0, pycode.Id, 0.0));
        rules1.add( getThresholdRule('Wk BP 2',awrdMaster, AwardMasterRecord.WEEKLY_BREAKPOINT_RULE, 38.0,  40.0, 1.5, 1.5, pycode.Id, 0.0));
        rules1.add( getThresholdRule('Wk BP 3',awrdMaster, AwardMasterRecord.WEEKLY_BREAKPOINT_RULE, 40.0, 168.0, 2.0, 2.0, pycode.Id, 0.0));
        
        rules1.add( getTimeRule('Saturday Rule'     ,awrdMaster, AwardMasterRecord.SATURDAY_RULE            , '09:00', '17:00', 1.5, 1.5, pycode.Id, 0.0));
        rules1.add( getTimeRule('Sunday Rule'       ,awrdMaster, AwardMasterRecord.SUNDAY_RULE              , '09:00', '17:00', 1.5, 1.5, pycode.Id, 0.0));
        rules1.add( getTimeRule('Public Hol'            ,awrdMaster, AwardMasterRecord.PUBLIC_HOLIDAY_RULE      , '00:00', '00:00',   2.5,   2.5, pycode.Id, 0.0));
        
        rules1.add( getThresholdRule('Outside Saturday Rule'  ,awrdMaster, AwardMasterRecord.OUTSIDE_SATURDAY_RULE  , 0,  2,     2,     2, pycode.Id, 0.0));
        rules1.add( getThresholdRule('Outside Saturday Rule 2',awrdMaster, AwardMasterRecord.OUTSIDE_SATURDAY_RULE  , 2, 24,   2.5,   2.5, pycode.Id, 0.0));
        rules1.add( getThresholdRule('Outside Sunday Rule',awrdMaster, AwardMasterRecord.OUTSIDE_SUNDAY_RULE    , 0, 2,   2,   2, pycode.Id, 0.0));
        rules1.add( getThresholdRule('Outside Sunday Rule',awrdMaster, AwardMasterRecord.OUTSIDE_SUNDAY_RULE    , 2, 24,   2.5,   2.5, pycode.Id, 0.0));
        
        rules1.add( getAllowanceRule('Meal',awrdMaster, AwardMasterRecord.MEAL_RULE, 0, 20.0, pycode.Id));
        rules1.add( getAllowanceRule('Allowance BP 1',awrdMaster, AwardMasterRecord.ALLOWANCE_BREAKPOINT,10, 15.0, pycode.Id));
        rules1.add( getAllowanceRule('Allowance BP 2',awrdMaster, AwardMasterRecord.ALLOWANCE_BREAKPOINT,12, 20.0, pycode.Id));
        rules1.add( getAllowanceRule('Allowance BP 3',awrdMaster, AwardMasterRecord.ALLOWANCE_BREAKPOINT,13, 25.0, pycode.Id));
        
        Schema.Sobjectfield typeOfLeaveField    = Schema.getGlobalDescribe().get('tc9_ti__Time_Sheet_Entry__c').getDescribe().fields.getMap().get('tc9_ti__Type_Of_Leave__c');
        List<Schema.Picklistentry> typesOfLeave = typeOfLeaveField.getDescribe().getPicklistValues();
        
        for(Schema.Picklistentry pickVal : typesOfLeave)
            rules1.add( getThresholdRule(pickVal.getValue(),awrdMaster, AwardMasterRecord.LEAVE_RULE, 0,  0, 0, 0, pycode.Id, 0.0));
        
        insert rules1;
    }*/
   /* Not used in code 
    public void createRulesStartTimes(Id awrdMaster){
        //create pay code
        tc9_ti__PayCodeMaster__c pycode = new tc9_ti__PayCodeMaster__c(RecordTypeId = UtilClass1.getTypeId_ByDeveloperName(NamespaceUtil1.getObjectName(new tc9_ti__PayCodeMaster__c()), 'TimeSheet'), tc9_ti__Paycode__c='PayCode1' , tc9_ti__Description__c = 'PayCode1', name = 'PayCode 1');
        insert pycode;
        
        List<tc9_ti__Rule__c> rules1 = new List<tc9_ti__Rule__c>();
        
        //add daily start time rules
        rules1.add( getTimeRule('Daily Start Time BP 1' ,awrdMaster, AwardMasterRecord.DAILY_START_TIME_BREAKPOINT_RULE, '00:00', '09:00', 1, 1, pycode.Id, 0.0));
        rules1.add( getTimeRule('Daily Start Time BP 2' ,awrdMaster, AwardMasterRecord.DAILY_START_TIME_BREAKPOINT_RULE, '09:00', '20:00', 1.5, 1.5, pycode.Id, 0.0));
         rules1.add( getTimeRule('Daily Start Time BP 3',awrdMaster, AwardMasterRecord.DAILY_START_TIME_BREAKPOINT_RULE, '20:00', '23:59', 2, 2, pycode.Id, 0.0));
        
        //add Rules to the Award Master
        rules1.add( getThresholdRule('Daily BP 1', awrdMaster, AwardMasterRecord.DAILY_HOURS_BREAKPOINT_RULE,  0.0, 4, 1.0, 1.0, pycode.Id, 0.0));
        rules1.add( getThresholdRule('Daily BP 2',awrdMaster, AwardMasterRecord.DAILY_HOURS_BREAKPOINT_RULE, 4, 12.0, 1.5, 1.5, pycode.Id, 0.0));
        rules1.add( getThresholdRule('Daily BP 2',awrdMaster, AwardMasterRecord.DAILY_HOURS_BREAKPOINT_RULE, 12.0, 24.0, 2.0, 2.0, pycode.Id, 0.0));
        
        //weeky breakpoints
        rules1.add( getThresholdRule('Wk BP 1',awrdMaster, AwardMasterRecord.WEEKLY_BREAKPOINT_RULE,  0.0,  70, 1.0, 1.0, pycode.Id, 0.0));
        rules1.add( getThresholdRule('Wk BP 2',awrdMaster, AwardMasterRecord.WEEKLY_BREAKPOINT_RULE, 70,  80, 1.5, 1.5, pycode.Id, 0.0));
        rules1.add( getThresholdRule('Wk BP 3',awrdMaster, AwardMasterRecord.WEEKLY_BREAKPOINT_RULE, 80, 168.0, 2.0, 2.0, pycode.Id, 0.0));
        
        //saturday start time breakpoint
        rules1.add( getTimeRule('Saturday Start Time BP 1'  ,awrdMaster, AwardMasterRecord.SATURDAY_START_TIME_BREAKPOINT_RULE, '00:00', '12:00', 1.25, 1.25, pycode.Id, 0.0));
        rules1.add( getTimeRule('Saturday Start Time BP 2'  ,awrdMaster, AwardMasterRecord.SATURDAY_START_TIME_BREAKPOINT_RULE, '12:00', '23:59', 1.75, 1.75, pycode.Id, 0.0));
        
        //standard sunday & public holiday
        rules1.add( getTimeRule('Sunday Rule'   ,awrdMaster, AwardMasterRecord.SUNDAY_RULE              , '09:00', '17:00', 1.5, 1.5, pycode.Id, 0.0));
        rules1.add( getTimeRule('Public Hol'    ,awrdMaster, AwardMasterRecord.PUBLIC_HOLIDAY_RULE      , '00:00', '00:00',   2.5,   2.5, pycode.Id, 0.0));
        
        //outside weekend rules
        rules1.add( getThresholdRule('Outside Saturday Rule'  ,awrdMaster, AwardMasterRecord.OUTSIDE_SATURDAY_RULE  , 0,  2,     2.25,     2.25, pycode.Id, 0.0));
        rules1.add( getThresholdRule('Outside Saturday Rule 2',awrdMaster, AwardMasterRecord.OUTSIDE_SATURDAY_RULE  , 2, 24,   2.75,   2.75, pycode.Id, 0.0));
        rules1.add( getThresholdRule('Outside Sunday Rule',awrdMaster, AwardMasterRecord.OUTSIDE_SUNDAY_RULE    , 0, 2,   2.25,   2.25, pycode.Id, 0.0));
        rules1.add( getThresholdRule('Outside Sunday Rule',awrdMaster, AwardMasterRecord.OUTSIDE_SUNDAY_RULE    , 2, 24,   2.75,   2.75, pycode.Id, 0.0));
        
        Schema.Sobjectfield typeOfLeaveField    = Schema.getGlobalDescribe().get('Time_Sheet_Entry__c').getDescribe().fields.getMap().get('Type_Of_Leave__c');
        List<Schema.Picklistentry> typesOfLeave = typeOfLeaveField.getDescribe().getPicklistValues();
        
        for(Schema.Picklistentry pickVal : typesOfLeave)
            rules1.add( getThresholdRule(pickVal.getValue(),awrdMaster, AwardMasterRecord.LEAVE_RULE, 0,  0, 0, 0, pycode.Id, 0.0));
            
        insert rules1;
    }*/ 
    
    /* Not used in code
    public void createUSRules(Id awrdMaster){
        //create pay code
        tc9_ti__PayCodeMaster__c pycode = new tc9_ti__PayCodeMaster__c(RecordTypeId = UtilClass1.getTypeId_ByDeveloperName(NamespaceUtil1.getObjectName(new tc9_ti__PayCodeMaster__c()), 'TimeSheet'), tc9_ti__Paycode__c='PayCode1' , tc9_ti__Description__c = 'PayCode1', name = 'PayCode 1');
        insert pycode;
        
        List<tc9_ti__Rule__c> rules1 = new List<tc9_ti__Rule__c>();
        
        //add Rules to the Award Master
        rules1.add( getThresholdRule('Daily BP 1', awrdMaster, AwardMasterRecord.DAILY_HOURS_BREAKPOINT_RULE,  0.0, 8.0, 1.0, 1.0, pycode.Id, 0.0));
        rules1.add( getThresholdRule('Daily BP 2',awrdMaster, AwardMasterRecord.DAILY_HOURS_BREAKPOINT_RULE, 8.0, 12.0, 1.5, 1.5, pycode.Id, 0.0));
        rules1.add( getThresholdRule('Daily BP 2',awrdMaster, AwardMasterRecord.DAILY_HOURS_BREAKPOINT_RULE, 12.0, 24.0, 2.0, 2.0, pycode.Id, 0.0));
        
        rules1.add( getThresholdRule('spcl 1',awrdMaster, AwardMasterRecord.DAILY_BREAKPOINT_ABOVE_ORD_WEEKLY,  0.0,  8.0, 1.5, 1.5, pycode.Id, 0.0));
        rules1.add( getThresholdRule('spcl 2',awrdMaster, AwardMasterRecord.DAILY_BREAKPOINT_ABOVE_ORD_WEEKLY, 8.0,  24.0, 2.0, 2.0, pycode.Id, 0.0));
        
        rules1.add( getThresholdRule('7th day BP 1',awrdMaster, AwardMasterRecord.X_7TH_DAY_RULE,  0.0,  8.0, 1.5, 1.5, pycode.Id, 0.0));
        rules1.add( getThresholdRule('7th day BP 1',awrdMaster, AwardMasterRecord.X_7TH_DAY_RULE, 8.0,  24.0, 2.0, 2.0, pycode.Id, 0.0));
        
        Schema.Sobjectfield typeOfLeaveField    = Schema.getGlobalDescribe().get('tc9_ti__Time_Sheet_Entry__c').getDescribe().fields.getMap().get('Type_Of_Leave__c');
        List<Schema.Picklistentry> typesOfLeave = typeOfLeaveField.getDescribe().getPicklistValues();
        
        for(Schema.Picklistentry pickVal : typesOfLeave)
            rules1.add( getThresholdRule(pickVal.getValue(),awrdMaster, AwardMasterRecord.LEAVE_RULE, 0,  0, 0, 0, pycode.Id, 0.0));
        
        insert rules1;
    }*/
    
   /*Not used in code 
     public void createDailyRules(Id awrdMaster){
        //create pay code
        tc9_ti__PayCodeMaster__c pycode = new tc9_ti__PayCodeMaster__c(RecordTypeId = UtilClass1.getTypeId_ByDeveloperName(NamespaceUtil1.getObjectName(new tc9_ti__PayCodeMaster__c()), 'TimeSheet'), tc9_ti__Paycode__c='PayCode1' , tc9_ti__Description__c = 'PayCode1', name = 'PayCode 1');
        insert pycode;
        
        List<tc9_ti__Rule__c> rules1 = new List<tc9_ti__Rule__c>();
        rules1.add( getAllowanceRule('Meal',awrdMaster, AwardMasterRecord.MEAL_RULE, 0, 20.0, pycode.Id));
        rules1.add( getAllowanceRule('Allowance BP 1',awrdMaster, AwardMasterRecord.ALLOWANCE_BREAKPOINT,0, 15.0, pycode.Id));
        rules1.add( getAllowanceRule('Allowance BP 2',awrdMaster, AwardMasterRecord.ALLOWANCE_BREAKPOINT,4, 20.0, pycode.Id));
        rules1.add( getThresholdRule('Daily', awrdMaster, AwardMasterRecord.WORK_DAY_RULE,  0.0, 0, 1.0, 1.0, pycode.Id, 0.0));
        insert rules1;
    }*/
       public tc9_ti__Time_Sheet__c getATimesheet(Id plcId, Id candidateId, Date startDate, Date endDate, String status){

        tc9_ti__Time_Sheet__c ts = new tc9_ti__Time_Sheet__c();

        ts.tc9_ti__Placement__c  = plcId;
        ts.tc9_ti__Candidate__c  = candidateId;
        ts.tc9_ti__Start_Date__c = startDate;
        ts.tc9_ti__End_Date__c   = endDate;
        ts.tc9_ti__Status__c = status;
        insert ts;
        return ts;
    }
/* Not used in code
    public tc9_ti__Time_Sheet_Entry__c createTSE(tc9_ti__Time_Sheet__c ts, Date workDate, String startT, String endT , boolean isLeave){
        tc9_ti__Time_Sheet_Entry__c tse         = new tc9_ti__Time_Sheet_Entry__c();
        tse.tc9_ti__Time_Sheet__c               = ts.Id;
        //tse.Placement__c  = ts.Placement__c;
        tse.tc9_ti__StartTime__c                = startT;
        tse.tc9_ti__EndTime__c                  = endT;
        tse.tc9_ti__Status__c                   = 'Submitted';
        tse.tc9_ti__WorkDate__c                 = workDate;
        String [] starttime             = tse.tc9_ti__StartTime__c.split(':'); 
        tse.tc9_ti__Start__c                    = DateTime.newInstance( tse.tc9_ti__WorkDate__c.year(), tse.tc9_ti__WorkDate__c.month(), tse.tc9_ti__WorkDate__c.day(), Integer.valueOf(starttime[0]), Integer.valueOf(starttime[1]), 0);
        String [] endtime               = tse.tc9_ti__EndTime__c.split(':');
        tse.tc9_ti__End__c                      = DateTime.newInstance( tse.tc9_ti__WorkDate__c.year(), tse.tc9_ti__WorkDate__c.month(), tse.tc9_ti__WorkDate__c.day(), Integer.valueOf(endtime[0]), Integer.valueOf(endtime[1]), 0);
        
        if(isLeave)
            tse.tc9_ti__Type_of_Leave__c = 'Sick Leave';
        return tse;
    }
    
    //change the start and end time for a given timesheet entry record
    public tc9_ti__Time_Sheet_Entry__c changeTime(tc9_ti__Time_Sheet_Entry__c tse , String newStart, String newEnd){
        
        tse.tc9_ti__StartTime__c        = newStart;
        tse.tc9_ti__EndTime__c          = newEnd;
        String [] starttime     = tse.tc9_ti__StartTime__c.split(':'); 
        tse.tc9_ti__Start__c            = DateTime.newInstance( tse.tc9_ti__WorkDate__c.year(), tse.tc9_ti__WorkDate__c.month(), tse.tc9_ti__WorkDate__c.day(), Integer.valueOf(starttime[0]), Integer.valueOf(starttime[1]), 0);
        String [] endtime       = tse.tc9_ti__EndTime__c.split(':');
        tse.tc9_ti__End__c              = DateTime.newInstance( tse.tc9_ti__WorkDate__c.year(), tse.tc9_ti__WorkDate__c.month(), tse.tc9_ti__WorkDate__c.day(), Integer.valueOf(endtime[0]), Integer.valueOf(endtime[1]), 0);
        
        return tse; 
    }

    public tc9_ti__Invoice_Template__c getInvoiceTemplate(String recordType){
        tc9_ti__Invoice_Template__c invtemp     = new tc9_ti__Invoice_Template__c();
        invtemp.Name                    = 'Test invoice';
        invtemp.tc9_ti__Default__c              = true;
        invtemp.tc9_ti__EmailTemplate_Online__c = 'Invoice Template';
        invtemp.tc9_ti__EmailTemplate_PDF__c    = 'Invoice Template';
        invtemp.tc9_ti__Record_Type__c          = recordType;
        invtemp.tc9_ti__Page_Name__c            = 'TempInvoice';
        return invtemp;
    }

    public tc9_ti__Expense_Claim__c getExpenseClaims(Id plcId, Id candidateId){
        tc9_ti__Expense_Claim__c expClaim = new tc9_ti__Expense_Claim__c();
        expClaim.tc9_ti__Placement__c     = plcId;
        expClaim.tc9_ti__Candidate__c     = candidateId;
        expClaim.tc9_ti__Claim_Date__c    = Date.today();
        expClaim.tc9_ti__Status__c        = 'New';
        expClaim.tc9_ti__Generate_Transaction__c = '2';
        return expClaim;

    }*/

    public List<tc9_ti__Expense__c> getExpenses(Id expClaimId, Integer noOfExpenses){
        
        List<tc9_ti__Expense__c> listOfExpenses = new List<tc9_ti__Expense__c>();
        for(Integer i=0; i<noOfExpenses ; i++ ){
            tc9_ti__Expense__c exp       = new tc9_ti__Expense__c();
            exp.tc9_ti__Expense_Claim__c = expClaimId;
            exp.tc9_ti__Status__c        = 'New';
            exp.tc9_ti__Title__c         = 'Test Expemse ' + i+1;
            exp.tc9_ti__Value__c         =  100.0;
            exp.tc9_ti__Date_Incurred__c = Date.today();
            exp.tc9_ti__Type__c          = 'Travel';
            listOfExpenses.add(exp); 
        }
        return listOfExpenses;
    }
    
}