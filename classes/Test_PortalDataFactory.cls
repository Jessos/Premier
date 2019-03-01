/**
 * Created by Adelaide Greenaway on 15/01/2018.
 * Data Factory for all data used by the Trialforce Custom Portal test classes
 */
/*Change History
******************************************************************************************************************************************
         SCRUM        ModifiedBy        Date            Requested By                           Description                              Tag
******************************************************************************************************************************************
       SC-17990       Ramya           5/2/2018       Lorelle Hargreaves           Increase the Code Coverage in Production to             T01
                                                                                 allow the validation and deployment of Inbound Change 
                                                                                Set named "Expenses Entry Format
*/
public with sharing class Test_PortalDataFactory {

    public String uniqueName {get;set;}
    public Integer randomInt {get;set;}
    public Integer noOfEntries = 1;

    public void getUniqueString(){

        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');

        randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        uniqueName = orgId + dateString + randomInt;

    }

    public Profile getProfileByName(String profileName)
    {
        Profile myProfile = [Select Name, Id From Profile p where name =: profileName];
        return myProfile;
    }

    public User getAUser(Profile myProfile, String fName, String lName) {

        getUniqueString();

        User tUser = new User();

        tUser.firstname = fName;
        tUser.lastName = lName;
        tUser.email = uniqueName + '@test' + randomInt + '.org';
        tUser.Username = uniqueName + '@test' + randomInt + '.org';
        tUser.EmailEncodingKey = 'ISO-8859-1';
        tUser.Alias = uniqueName.substring(18, 23);
        tUser.TimeZoneSidKey = 'Australia/Sydney';
        tUser.LocaleSidKey = 'en_AU';
        tUser.LanguageLocaleKey = 'en_AU';
        tUser.Location__c = 'New York';
        tUser.ProfileId = myProfile.id;
        tUser.isActive = true;

        return tUser;
    }

    public User getAPortalUser(Profile myProfile, Contact con){
        getUniqueString();

        User pUser = new User();

        pUser.ContactId = con.Id;
        pUser.Alias = uniqueName.substring(18,23);
        pUser.Email = uniqueName+'@test'+randomInt+'.com';
        pUser.EmailEncodingKey = 'UTF-8';
        pUser.FirstName = con.FirstName;
        pUser.LastName = con.LastName;
        pUser.LanguageLocaleKey = 'en_US';
        pUser.LocaleSidKey = 'en_AU';
        pUser.ProfileId = myProfile.Id;
        pUser.TimeZoneSidKey = 'Australia/Sydney';
        pUser.Username = uniqueName+'@test'+randomInt+'.org';

        return pUser;
    }

    public tc9_ti__ToCloudNineConfig__c timecardsCustomSetting(String wkStartDay,Boolean displayBrk2, Boolean disableResubmit){

        getUniqueString();

        tc9_ti__ToCloudNineConfig__c tc = new tc9_ti__ToCloudNineConfig__c();

        tc.tc9_ti__Week_Start_Day__c = wkStartDay;
        tc.tc9_ti__Display_Break2__c = displayBrk2;
        tc.CUSTOM_Disable_Resubmit__c = disableResubmit;

        return tc;
    }

    //create a new tax record
    public tc9_ti__TaxID__c getTaxID(){

        tc9_ti__TaxID__C tax = new tc9_ti__TaxID__c ();

        tax.tc9_ti__Rate__c = 0.1;
        tax.tc9_ti__TaxID__c='tax';

        return tax;
    }

    //create a new Award Master
    public tc9_ti__Award_Master__c getAnAward(){

        tc9_ti__Award_Master__c awrdMaster = new tc9_ti__Award_Master__c();

        awrdMaster.tc9_ti__Ordinary_Weekly_Hours__c    = 1;
        awrdMaster.tc9_ti__Minimum_Weekly_Paid_Hours__c   = 1;
        awrdMaster.tc9_ti__Minimum_Sunday_Paid_Hours__c   = 1;
        awrdMaster.tc9_ti__Minimum_Saturday_Paid_Hours__c  = 1;
        awrdMaster.tc9_ti__Minimum_Public_Holiday_Paid_Hours__c = 1;
        awrdMaster.tc9_ti__Interpret_On_Weekly_Totals__c   = true;
        awrdMaster.tc9_ti__Hourly_Standard_Rate__c    = 10;
        awrdMaster.Name = 'Hourly';

        return awrdMaster;
    }

    //create a new market
    public tc9_ti__Market__c getMarket(ID taxID){

        tc9_ti__Market__c market = new tc9_ti__Market__c();

        market.tc9_ti__MarketName__c = 'MarketName';
        market.tc9_ti__TaxID__c = taxID;

        return market;
    }

    public tc9_ti__Site__c getASite(String siteName, String siteURL){

        tc9_ti__Site__c site = new tc9_ti__Site__c();
        site.name=siteName;
        site.tc9_ti__Site_URL__c = siteURL;

        return site;
    }

    public tc9_ti__PaymentTerm__c getAPaymentTerm (){
        getUniqueString();

        tc9_ti__PaymentTerm__c pt = new tc9_ti__PaymentTerm__c();
        pt.tc9_ti__DueFrom__c = 'End Of Month';

        return pt;
    }

    //create a new Payment Entity
    public Account getAPaymentEntity(){
        Account acc = new Account();
        acc.Name = 'PE'+uniqueName;
        acc.tc9_p__Financial_Cycle__c    = 'June';
        acc.RecordTypeId = UtilClass.getRecordTypeId('Account', 'Payment Entity');

        return acc;
    }

    //create a new Billing Entity
    public Account getABillingEntity(){
        Account acc = new Account();
        acc.Name = 'BE'+uniqueName;
        acc.tc9_p__Financial_Cycle__c    = 'June';
        acc.RecordTypeId = UtilClass.getRecordTypeId('Account', 'Billing Entity');

        return acc;
    }

    //create a new Client account
    public Account getAClientAccount(Id marketId, Id billingEntityId, Id invoiceConId, String workWeekStartDay, Id paymentTerm){

        Account acc = new Account();
        acc.name    = 'Test Portal Client';
        acc.RecordTypeId    = UtilClass.getRecordTypeId('Account','Candidate');
        acc.tc9_ti__Billing_Entity__c = billingEntityId;
        acc.tc9_ti__Market__c       = marketId;
        acc.tc9_ti__Invoice_Contact__c = invoiceConId;
        acc.tc9_ti__Pay_Schedule__c = 'Weekly';
        acc.tc9_ti__Week_Start_Day__c = workWeekStartDay;
        acc.tc9_ti__Invoice_Group_By__c = 'Client';
        acc.tc9_ti__InvoiceCycle__c = 'Weekly';
        acc.tc9_ti__PaymentTerm__c = paymentTerm;
        acc.ts2__Invoice_Terms__c = '15';
        acc.tc9_ti__Delivery_Method__c = 'Email with URL Online Link';
        acc.BillingStreet   = '123 Melbourne Street';
        acc.BillingCity     = 'Melbourne';
        acc.BillingState    = 'Victoria';
        acc.BillingPostalCode    = '3000';
        acc.BillingCountry  = 'Australia';

        return acc;
    }

    //create a client contact
    public Contact getAClientContact(ID accntID){
        getUniqueString();

        Contact clCon = new Contact();

        clCon.AccountID   = accntID;
        clCon.lastName   = 'Test';
        clCon.Salutation = 'Ms';
        clCon.FirstName  = 'Client';
        clCon.LastName = 'Test Contact'+randomInt;
        clCon.Email      = 'test@test.com';
        clCon.Birthdate     = Date.parse('2/2/1980');
        clCon.MailingStreet = 'Test';
        clCon.MailingCity = 'Melbourne';
        clCon.MailingState = 'Victoria';
        clCon.MailingCountry = 'Australia';
        clCon.MailingPostalCode = '3000';

        return clCon;
    }

    //create a new Employee (Candidate) account
    public Account getACandidateAccount(String accName){

        Account acc = new Account();
        acc.name    = accName;
        acc.RecordTypeId = UtilClass.getRecordTypeId('Account','Candidate');

        return acc;
    }

    //create an employee contact
    public Contact getAnEmployeeContact(Id accntId, String fname, String lname){
        getUniqueString();

        Contact eCon = new Contact();

        eCon.AccountID   = accntID;
        eCon.Salutation = 'Ms';
        eCon.FirstName  = fname;
        eCon.LastName = lname;
        eCon.Email      = fname+'@test.com';
        eCon.Birthdate     = Date.parse('2/2/1982');
        eCon.MailingStreet = '1 Spring Street';
        eCon.MailingCity = 'Melbourne';
        eCon.MailingState = 'Victoria';
        eCon.MailingCountry = 'Australia';
        eCon.MailingPostalCode = '3000';
        eCon.State__c = 'AZ';
        eCon.ts2__People_Status__c = 'CT PPW Incomplete';

        return eCon;
    }

    public tc9_p__Superannuation_Fund__c getAFundSMSF()
    {

        tc9_p__Superannuation_Fund__c testFund = new tc9_p__Superannuation_Fund__c();

        testFund.tc9_p__Fund_Account_Name__c = 'Test account';
        testFund.tc9_p__Fund_Account_Number__c = '1234567890';
        testFund.tc9_p__Fund_Name__c = 'Test fund';
        testFund.tc9_p__Fund_Email__c= 'Test@test.com';
        testFund.tc9_p__KeyPay_ID__c = '0123';
        testFund.tc9_p__Fund_Branch__c= '123456';
        testFund.tc9_p__Fund_City__c= 'Test';
        testFund.tc9_p__Fund_Street__c= 'Test';
        testFund.tc9_p__Fund_State_Province__c= 'Test';
        testFund.tc9_p__Fund_Country__c= 'Test';
        testFund.tc9_p__Fund_Zip_Postal_Code__c= 'Test';
        testFund.tc9_p__Fund_Phone__c= 'Test';
        testFund.tc9_p__Unique_Superannuation_Identifier__c= '1';
        testFund.tc9_p__Status__c = 'Validation Pending';
        testFund.RecordTypeId = UtilClass.getRecordTypeId('tc9_p__Superannuation_Fund__c','Self Managed');
        testFund.tc9_p__Fund_ABN__c = '27007176481';
        testFund.tc9_p__Fund_Electronic_Service_Address__c = '1234618';
        testFund.tc9_p__Status__c = 'Active';

        return testFund;
    }

    public tc9_p__Superannuation_Fund__c getAFundAPRA()
    {

        tc9_p__Superannuation_Fund__c testFund = new tc9_p__Superannuation_Fund__c();

        testFund.tc9_p__Fund_Account_Name__c = 'Test account';
        testFund.tc9_p__Fund_Account_Number__c = '1234567890';
        testFund.tc9_p__Fund_Name__c = 'Test fund';
        testFund.tc9_p__Fund_Email__c= 'Test@test.com';
        testFund.tc9_p__KeyPay_ID__c = '0123';
        testFund.tc9_p__Fund_Branch__c= '123456';
        testFund.tc9_p__Fund_City__c= 'Test';
        testFund.tc9_p__Fund_Street__c= 'Test';
        testFund.tc9_p__Fund_State_Province__c= 'Test';
        testFund.tc9_p__Fund_Country__c= 'Test';
        testFund.tc9_p__Fund_Zip_Postal_Code__c= 'Test';
        testFund.tc9_p__Fund_Phone__c= 'Test';
        testFund.tc9_p__Unique_Superannuation_Identifier__c= '1';
        testFund.tc9_p__Status__c = 'Validation Pending';
        testFund.RecordTypeId = UtilClass.getRecordTypeId('tc9_p__Superannuation_Fund__c','APRA and RSA Funds');
        testFund.tc9_p__Fund_ABN__c = '27007176481';
        testFund.tc9_p__Fund_Electronic_Service_Address__c = '1234618';
        //testFund.tc9_p__Status__c = 'Active';

        return testFund;
    }



    public tc9_ti__Public_Holiday_Calendar__c getPublicHolidayCal(String year){
        tc9_ti__Public_Holiday_Calendar__c clndr = new tc9_ti__Public_Holiday_Calendar__c();

        clndr.tc9_ti__Year__c = year;
        clndr.Name = 'Australia - Vic';

        return clndr;
    }

    public tc9_ti__PayCodeMaster__c getAPaycode(String name, String code){

        tc9_ti__PayCodeMaster__c paycode = new tc9_ti__PayCodeMaster__c();

        paycode.Name = name;
        paycode.tc9_ti__Paycode__c = code;
        paycode.Pay_Code_Type__c = code;

        return paycode;
    }

    public tc9_p__Payee__c getAPayee (Contact c, String earnerType, Boolean agreeLogic, Boolean agreeVisable)
    {

        tc9_p__Payee__c testPayee                      = new tc9_p__Payee__c();
        testPayee.tc9_p__Tax_File_Number__c            = '111111111';
        testPayee.tc9_p__Employment_Type__c            = 'Part Time';
        testPayee.tc9_p__Primary_Pay_Category__c       = 'Part Time - Week Days';
        testPayee.tc9_p__Payslip_Notification__c       = 'Email';
        testPayee.tc9_p__Payroll_Start_Date__c         = Date.today().addDays(-30);
        testPayee.tc9_p__Tax_Rate__c                   = 10.00;
        testPayee.tc9_p__Australian_Resident__c        = false;
        testPayee.tc9_p__Business_Telephone_Number__c  = '888888888';
        testPayee.tc9_p__Pay_Schedule__c               = 'Weekly';
        testPayee.tc9_p__Trading_Name__c               = 'Michelle Contracting Company';
        testPayee.tc9_p__AFS_Debt__c                   = false;
        testPayee.tc9_p__Payroll_System__c             = '12345';
        testPayee.tc9_p__GST_Registered__c             = true;
        testPayee.tc9_p__Exempt_From_Payroll_Tax__c    = false;
        testPayee.tc9_p__Business_Street__c            = 'Test Street';
        testPayee.tc9_p__Business_City__c              = 'Test Street';
        testPayee.tc9_p__Business_Country__c           = 'Test Street';
        testPayee.tc9_p__Business_State_Province__c    = 'Test Street';
        testPayee.tc9_p__Other_Tax_Offset__c           = false;
        testPayee.tc9_p__Seniors_Tax_Offset__c         = false;
        testPayee.tc9_p__Earner_Type__c                = earnerType;
        testPayee.tc9_p__Contact__c                    = c.Id;
        testPayee.tc9_p__Claim_Tax_Free__c             = false;
        testPayee.tc9_p__HELP_Debt__c                  = false;
        testPayee.tc9_p__Pay_Advice_Delivery_Method__c = 'Email as PDF';
        testPayee.tc9_p__Status__c                     = 'Active';
        testPayee.tc9_p__Super_Fund_1_Name__c          = 'Test Fund name';
        testPayee.tc9_p__Super_Fund_1_Member_Number__c = 'Test member';
        testPayee.tc9_p__Super_Fund_1_Allocated_Percentage__c = 100;
        testPayee.tc9_p__Super_Fund_1__c = getAFundAPRA().Id;
        testPayee.tc9_p__Bank_Account_1_Allocated_Percentage__c = 20;
        testPayee.tc9_p__Bank_Account_1_Code__c = '123456';
        testPayee.tc9_p__Bank_Account_1_Fixed_Amount__c = 1.0;
        testPayee.tc9_p__Bank_Account_1_Name__c = 'Acc Name';
        testPayee.tc9_p__Bank_Account_1_Number__c = '123456';
        testPayee.tc9_p__Bank_Account_1_Suffix__c = 'TES1';
        testPayee.tc9_p__Bank_Account_2_Allocated_Percentage__c = 30;
        testPayee.tc9_p__Bank_Account_2_Code__c = '123456';
        testPayee.tc9_p__Bank_Account_2_Fixed_Amount__c = 2.0;
        testPayee.tc9_p__Bank_Account_2_Name__c = 'Acc Name';
        testPayee.tc9_p__Bank_Account_2_Number__c = '123456';
        testPayee.tc9_p__Bank_Account_2_Suffix__c = 'TES2';
        testPayee.tc9_p__Bank_Account_3_Allocated_Percentage__c = 50;
        testPayee.tc9_p__Bank_Account_3_Code__c = '123456';
        testPayee.tc9_p__Bank_Account_3_Fixed_Amount__c = 500.0;
        testPayee.tc9_p__Bank_Account_3_Name__c = 'Acc Name';
        testPayee.tc9_p__Bank_Account_3_Number__c = '123456';
        testPayee.tc9_p__Bank_Account_3_Suffix__c = 'TES3';
        testPayee.tc9_p__Payroll_Id__c = '23456';
        testPayee.Use_2c9_Portal_Agreement_Logic__c = agreeLogic;
        testPayee.x2c9_Portal_Payee_Agreement_Visible__c = agreeVisable;
        testPayee.Bank_Type_Selected__c = 'Australian';
        testPayee.Fund_Option_Selected__c = 'APRA/RSA';
        testPayee.tc9_p__Australian_Resident__c = true;
        testPayee.tc9_p__Is_approved_working_holiday_maker__c = false;

        return testPayee;
    }

    //create a new job for the given client
    public ts2__Job__c  getAJob(Id accntId, Id contID,Id marketID, Id siteId){

        ts2__Job__c testJob = new ts2__Job__c();

        testJob.Name    = 'Test Job';
        testJob.ts2__Account__c = accntId;
        testJob.ts2__Contact__c = contID;
        testJob.tc9_ti__Bill_To_Account__c  = accntId;
        testJob.tc9_ti__Bill_To_Contact__c  = contId;
        testJob.ts2__Job_Function__c='FunABC';
        testJob.ts2__Department__c='DepABC';
        testJob.ts2__Location__c='LocAC';
        testJob.ts2__Recruiter__c = UserInfo.getUserId();
        testJob.tc9_ti__Market__c   = marketID;
        testJob.tc9_ti__Site__c     = siteId;
        testJob.tc9_ti__Base_Bill_Rate__c   = 17;
        testJob.tc9_ti__Base_Pay_Rate__c    = 15;
        testJob.RecordTypeId = UtilClass.getRecordTypeId('ts2__Job__c','Temp');
        testJob.ts2__Estimated_Start_Date__c = Date.today().addDays(-5);
        testJob.ts2__Estimated_End_Date__c  = Date.today().addDays(30);
        testJob.tc9_ti__Public_Holiday_Calendar__c = getPublicHolidayCal('2015').Id;
        testJob.ts2__Fee_Pct__c = 50;
        testJob.City__c = 'Test';
        testJob.State__c = 'AL';
        testJob.Street__c = 'Test';
        testJob.Postal_Code__c ='3030';
       
        testJob.tc9_ti__PurchaseOrderNumber__c = 'Po num';
        testJob.tc9_ti__Week_Start_Day__c = 'Monday';

        return testJob;
    }

    //create a new placement for the given job, employee, start and end date, award master
    public ts2__Placement__c getAPlacement(ts2__Job__c job, Id calId, Id empId, Id payeeId, Date startDate, Date endDate, Id awrdMasterID, Boolean agreeLogic, Boolean agreeVisable){

        ts2__Placement__c plc         = new ts2__Placement__c();

        //basic details
        plc.ts2__Start_Date__c         = startDate;
        plc.ts2__End_Date__c        = endDate;
        plc.RecordTypeId          = UtilClass.getRecordTypeId('ts2__Placement__c', 'Temp');
        plc.currencyISOCode       = 'USD';

        //from job
        plc.ts2__Job__c              = job.Id;
        plc.ts2__Client__c            = job.ts2__Account__c;
        plc.tc9_ti__TimeSheetApprover__c        = job.ts2__Contact__c;
        plc.tc9_ti__AlternativeTimeSheetApprover__c  = job.ts2__Contact__c;
        plc.tc9_ti__Market__c        = job.tc9_ti__Market__c;

        plc.ts2__Sales_Rep_Pct__c = 100;
        plc.ts2__Filled_Pct__c = 100;

        //rate
        plc.ts2__Bill_Rate__c        = 10;
        plc.ts2__Pay_Rate__c        = 10;
        plc.tc9_ti__Base_Bill_Rate__c = 10;
        plc.tc9_ti__Base_Pay_Rate__c  = 10;
        plc.tc9_ti__Award_Master__c      = awrdMasterID;
        plc.ts2__Salary__c          = 100;
        //T01 start  This field has been created recently. So added this in order to pass the "Test_PortalExpense" test method.
        plc.Expenses_Entry_Method__c = 'Portal';
        //T01 End
        plc.tc9_ti__Conversion_Fee_Pct__c  = 100;

        //calendar
        plc.tc9_ti__Public_Holiday_Calendar__c  = calId;

        //candidate
        plc.ts2__Employee__c      = empId;
       // plc.ts2__Employee__r.Email='test@jhfgsd.com';
        plc.Payee__c = payeeId;

        plc.tc9_ti__Hours_Wednesday__c   = 8;
        plc.tc9_ti__Hours_Tuesday__c   = 8;
        plc.tc9_ti__Hours_Thursday__c   = 8;
        plc.tc9_ti__Hours_Sunday__c   = 0;
        plc.tc9_ti__Hours_Saturday__c   = 0;
        plc.tc9_ti__Hours_Monday__c   = 8;
        plc.tc9_ti__Hours_Friday__c   = 8;
        plc.CT_Candidate_Mgr_Team_Members__c = 9;
        //plc.CurrencyIsoCode           = 'AUD';
        plc.tc9_ti__Timesheet_Frequency__c = 'Weekly';
        plc.x2c9_Portal_Placement_Agreement_Visible__c = agreeLogic;
        plc.Use_2c9_Portal_Agreement_Logic__c = agreeVisable;
     
        return plc;
    }


    public tc9_ti__Time_Sheet__c getATimesheet(Id plcId, Id candidateId, Date startDate, Date endDate, String status){

        tc9_ti__Time_Sheet__c ts = new tc9_ti__Time_Sheet__c();

        ts.tc9_ti__Placement__c  = plcId;
        ts.tc9_ti__Candidate__c  = candidateId;
        ts.tc9_ti__Start_Date__c = startDate;
        ts.tc9_ti__End_Date__c   = endDate;
        ts.tc9_ti__Status__c = status;

        return ts;
    }

    public tc9_ti__Time_Sheet_Entry__c getATimesheetEntry(Id tsId, Date workdate, String startTime, String endTime){

        tc9_ti__Time_Sheet_Entry__c entry = new tc9_ti__Time_Sheet_Entry__c();

        entry.tc9_ti__Time_Sheet__c = tsId;
        entry.tc9_ti__WorkDate__c   = workDate;
        entry.tc9_ti__StartTime__c  = startTime;
        entry.tc9_ti__EndTime__c    = endTime;
        entry.CurrencyIsoCode          = 'USD';

        return entry;
    }

    public tc9_ti__Expense_Claim__c getAnExpenseClaim (Id plcId, Date claimDate, Id empId, String expStatus){
        tc9_ti__Expense_Claim__c expenseClaim = new tc9_ti__Expense_Claim__c();

        expenseClaim.tc9_ti__Claim_Date__c = claimDate;
        expenseClaim.tc9_ti__Candidate__c = empId;
        expenseClaim.tc9_ti__Placement__c = plcId;
        expenseClaim.tc9_ti__Status__c = expStatus;

        return expenseClaim;
    }

    public tc9_ti__Expense__c getAnExpense (Id expClaimId, Date dateIncurred, String title, String type, Decimal preTaxVal, Decimal taxAmt, Boolean taxable){
        tc9_ti__Expense__c expense = new tc9_ti__Expense__c();

        expense.tc9_ti__Status__c = 'New';
        expense.tc9_ti__Tax_Amount__c = taxAmt;
        expense.tc9_ti__Value__c = preTaxVal;
        expense.tc9_ti__Expense_Total_including_Tax__c = preTaxVal + taxAmt;
        expense.tc9_ti__Taxable__c = taxable;
        expense.tc9_ti__Title__c = title;
        expense.tc9_ti__Expense_Claim__c = expClaimId;
        expense.tc9_ti__Date_Incurred__c = dateIncurred;

        return expense;
    }

    public Task getATask (Id taskRT, Id whatid, Date activityDate, Id whoid, Id ownerid){
        Task task = new Task();
        task.Status = 'In Progress';
        task.Priority = 'Normal';
        task.RecordTypeId = taskRT;
        task.WhatId = whatid;
        task.ActivityDate = activityDate;
        task.Description = 'Testing Testing this is a test';
        task.Subject = 'Test Subject';
        task.WhoId = whoid;
        task.OwnerId = ownerid;

        return task;
    }

    public Attachment getAttachment (String fileName, String body, Id parentId){
        Attachment att = new Attachment();
        att.Name = fileName;
        att.Body = Blob.valueOf(body);
        att.ParentId = parentId;

        return att;
    }

    public customTFPortalSettings__c getCustomTFPortalSettings (Boolean useEsign){
        customTFPortalSettings__c customTFP = new customTFPortalSettings__c();
        customTFP.Use_Echosign__c = useEsign;
        customTFP.AddressAutocompleteGoogleKey__c = 'AIzaSyCNElTSb4WBZxsrlLWKEXVMd7SIyGN9fOY';

        return customTFP;
    }
    public tc9_ti__ToCloudNineConfig__c getTimecardsSettings(){
        getUniqueString();

        tc9_ti__ToCloudNineConfig__c tc = new tc9_ti__ToCloudNineConfig__c();
        tc.tc9_ti__Enable_Bridging__c = true;
        tc.tc9_ti__Send_Invoice_Emails_From_Email__c = uniqueName+'@testing.com';
        tc.CUSTOM_Disable_Resubmit__c = true;
        tc.tc9_ti__Display_Break2__c = true;

        return tc;
    }

    public tc9_p__Payments_Configuration__c getPaymentsSettings(){
        //getUniqueString();

        tc9_p__Payments_Configuration__c pc = new tc9_p__Payments_Configuration__c();
        pc.tc9_p__Enable_International_Banking__c = true;
        pc.tc9_p__Disable_FLS_CRUD_Validation__c = true;

        return pc;
    }

    public cloudNineSettings__c getEsignSettings(){
        cloudNineSettings__c esignSettings = new cloudNineSettings__c();
        esignSettings.eSign_Services_Integration_Key__c = '3AAABLblqZhDI_pTt8BiQnQyvvEGSyZvmeNzeRQYzSfPtC6wLVVNFxdiRVWZQQwSMxoKfFE5Jx3fjIu72iomL8yerP8wHHu0g';
        esignSettings.eSign_Services_Integration_URL__c = 'https://api.na1.echosign.com:443/api/rest/v5/agreements/';
        return esignSettings;
    }

    public echosign_dev1__SIGN_Agreement__c getAgreement(Id payeeId, Id plcId, String status){

        // Create test Agreement record
        echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c();
        agreement.Name = 'Test Agreement';
        agreement.echosign_dev1__Document_Key__c='3AAABLblqZhBh2LjAhC1faPsDh1Ves5ONGYiZZPIwtEzcsxbBPn0YWniwJivh2SCIjC_zX17oTxZuA2mlXIPnRnOQ2r9ylTfI';
        agreement.echosign_dev1__Status__c = status;//'Draft';
        agreement.Payee__c = payeeId;
        agreement.Placement__c = plcId;
        Test.setMock(HttpCalloutMock.class, new echosignAPIMock());
        return agreement;
    }

    public tc9_p__Pay_Advice__c getAPayAdvice(Id paymentEntityId, Date startDate, Date endDate, Date datePaid, Id empId){

        tc9_p__Pay_Advice__c padv = new tc9_p__Pay_Advice__c();

       // padv.tc9_p__Payment_Entity__c = paymentEntityId;
        padv.tc9_p__Period_Start_Date__c = startDate;
        padv.tc9_p__Period_End_Date__c = endDate;
        padv.tc9_p__Date_Paid__c = datePaid;
        padv.tc9_p__Contact__c = empId;
        padv.tc9_p__Net_Earnings__c = 12;
        padv.tc9_p__Gross_Earnings__c = 10;
        padv.tc9_p__Status__c = 'Paid';

//        insert padv;
//
//        Attachment att = getAttachment('payadvice','the pay advice', padv.Id);
//        insert att;

        return padv;
    }

    public tc9_p__Contractor_Invoice__c getAnRCTI(Id paymentEntityId, Date startDate, Date endDate, Date invDate, Id empId) {
        tc9_p__Contractor_Invoice__c rcti = new tc9_p__Contractor_Invoice__c();

        rcti.tc9_p__Period_Start_Date__c = startDate;
        rcti.tc9_p__Period_End_Date__c = endDate;
        rcti.tc9_p__Invoice_Date__c = invDate;
        rcti.tc9_p__Contact__c = empId;
        rcti.tc9_p__Payment_Entity__c = paymentEntityId;

//        insert rcti;
//        Attachment att = getAttachment('rcti','the rcti', rcti.Id);
//        insert att;

        return rcti;
    }

    public Adhoc_Allowances__c getAnAdhocAllowance(Id payId, Id plcId, Id tsId, Id conId, Date workDate){
        Adhoc_Allowances__c adAl = new Adhoc_Allowances__c();

        adAl.Placement__c = plcId;
        adAl.Contact__c = conId;
        adAl.Pay_Code__c = payId;
        adAl.Timesheet__c = tsId;
        adAl.Quantity__c = 200;
        adAl.Entry_Date__c = workDate;

        return adAl;

    }
}