@isTest
public with sharing class TestCtrlTempInv {
    
    static Id candidateId;
  static testMethod void createData() {
    
   Map<Id, tc9_ti__Invoice__c> invoices = new Map<Id, tc9_ti__Invoice__c>();
             
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
        Account acc = testDataDump.getAClientAccount(testMarket.Id);
        acc.Name = 'Premier Staffing, Inc';
        acc.BillingStreet = 'BillingStreet';
        acc.BillingCity = 'Melbourne';
        acc.BillingState = 'Victoria';
        acc.BillingPostalCode = '3000';
        acc.BillingCountry = 'Australia';
        acc.Phone = '1234567899';
        acc.Fax = '90000';
        acc.Website = 'www.test.com';
        acc.tc9_ti__Invoice_Group_By__c = 'Placement';
        acc.ts2__Invoice_Terms__c = '10';
        acc.tc9_ti__PaymentTerm__c = paymentTerm.Id;
        acc.tc9_ti__GST_Reg_Number__c = 'test';
        update acc;
          
        //create a client contact
        Contact testContact = testDataDump.getAClientContact(acc.Id);
        testContact.Salutation  = 'Mr';
        testContact.State__c = 'AL';
        update testContact;
        
        //Update Contact with Account Payable Lookup
        acc.ts2__Accounts_Payable__c = testContact.Id;
        update acc;
        
        //create an Employee
        Contact con = testDataDump.getAClientContact(acc.Id);
        con.First_Day_Worked__c = Date.today().addDays(-200);
        con.State__c = 'AL';
        update con;
        
        candidateId = con.Id;
        
        //Create an Award
        tc9_ti__Award_Master__c testAwardMaster = testDataDump.getAnAward();
        testAwardMaster.Name = 'Test';
        insert testAwardMaster;
        
        //Create a Job
        ts2__Job__c job = testDataDump.getAJob(acc.Id, testContact.Id, testMarket.Id, testSites.Id);
        job.ts2__Location__c = 'San Francisco';
        job.tc9_ti__PaymentTerm__c = paymentTerm.Id;
        update job;
         //create a public holiday calander
        tc9_ti__Public_Holiday_Calendar__c testCalendar = new tc9_ti__Public_Holiday_Calendar__c();
        testCalendar.tc9_ti__Year__c = String.valueOf(Date.today().year());
        testCalendar.Name = 'Australia - Vic';
        insert testCalendar;
       
                    
            Date startDate = system.today();
            Date endDate = system.today()+4;
             //Placement 
             ts2__Placement__c plc = new ts2__Placement__c();
             plc.ts2__Start_Date__c         = startDate;
             plc.ts2__End_Date__c        = endDate;
             plc.tc9_ti__Auto_Approve_0_Timesheets__c = true;
             plc.ts2__Job__c = job.id;
             plc.ts2__Client__c = acc.id;
             plc.ts2__Employee__c = con.id;
             //plc.Migrated_AU_Placement__c = false; 
             //plc.Migrated_NZ_Placement__c  = false;
                plc.tc9_ti__Hours_Wednesday__c   = 8;
                plc.tc9_ti__Hours_Tuesday__c   = 8; 
                plc.tc9_ti__Hours_Thursday__c   = 8; 
                plc.tc9_ti__Hours_Sunday__c   = 0;
                plc.tc9_ti__Hours_Saturday__c   = 0;
                plc.tc9_ti__Hours_Monday__c   = 8;
                plc.tc9_ti__Hours_Friday__c   = 8;
                plc.CurrencyIsoCode           = 'USD';
                plc.tc9_ti__Award_Master__c = testAwardMaster.id;
               // plc.tc9_ti__Award_Master__r.Name  = 'Test';
                plc.tc9_ti__TimeSheetApprover__c        = job.ts2__Contact__c;
                plc.tc9_ti__Market__c        = testMarket.Id;
                plc.tc9_ti__Public_Holiday_Calendar__c  = testCalendar.id;
             insert plc;
            
             tc9_ti__Time_Sheet__c ts = new tc9_ti__Time_Sheet__c();
             ts.tc9_ti__Candidate__c  = con.id;
             ts.tc9_ti__Start_Date__c = system.today();
             ts.tc9_ti__End_Date__c   = system.today()+1;
             ts.tc9_ti__Generate_Transaction__c = '1';
             ts.tc9_ti__Placement__c = plc.Id;
             insert ts;
            
            tc9_ti__Invoice_Template__c  invTem = new tc9_ti__Invoice_Template__c();
            invTem.Name = 'Test';
           // invTem.tc9_ti__Account__c = acc.id;
            insert invTem;
            
            tc9_ti__Consolidated_Invoice__c conInv = new tc9_ti__Consolidated_Invoice__c();
            conInv.tc9_ti__Delivery_Method_Token_Available__c = 'test';
            conInv.tc9_ti__Invoice_Template__c = invTem.id;
            conInv.tc9_ti__Billing_Entity__c = acc.id;
            conInv.tc9_ti__Invoice_Message__c = 'Testing';
            insert conInv;
            
            conInv.tc9_ti__Bill_To_Account__c = acc.id;
            update conInv;
            
          system.debug('Consolidated Invoice'+conInv);
            
            tc9_ti__Time_Sheet_Entry__c testTimesheetEntry = testDataDump.getATimesheetEntry(ts.Id,  Date.today().addDays(-10), '00:00', '08:00');
            insert testTimesheetEntry;
            
            tc9_ti__Invoice__c inv = new tc9_ti__Invoice__c();//Invoice
             inv.tc9_ti__ARContact_Ext__c = 'asd';
             insert inv;
             List<tc9_ti__InvoiceItem__c> lstInvitm = new List<tc9_ti__InvoiceItem__c>();
             tc9_ti__InvoiceItem__c invItm = new tc9_ti__InvoiceItem__c();//Invoice Item
             invItm.tc9_ti__TalentLastName__c = 'Qwe';
             invItm.tc9_ti__Invoice__c = inv.id;
             invItm.tc9_ti__Quantity__c       = 2;
             invItm.tc9_ti__TotalBillIncTax__c  = 23;
             invItm.tc9_ti__Time_Sheet_Entry__c = testTimesheetEntry.id;
             lstInvitm.add(invItm);
             insert lstInvitm;
             
             // tc9_ti__Consolidated_Line__c conLn = new tc9_ti__Consolidated_Line__c();
            //conLn.tc9_ti__Consolidated_Invoice__c = conInv.id;
            //conLn.tc9_ti__Invoice__c = inv.id;
            
            insert new tc9_ti__Consolidated_Line__c(tc9_ti__Consolidated_Invoice__c=conInv.id,tc9_ti__Invoice__c =inv.id) ;
            Attachment attach = new Attachment();

        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=acc.id;
        insert attach;
         
            
           // system.debug('Consolidated Line'+conLn);
            
             tc9_ti__Transaction__c trans = new tc9_ti__Transaction__c();
             trans.tc9_ti__Placement__c =plc.id;
             trans.tc9_ti__InvoiceItem__c = lstInvitm[0].id;
             trans.Payroll_Extract_First_Run__c = system.now();
             trans.tc9_ti__Bill_Multiplier__c = 1.65;
             trans.tc9_ti__Multiplier__c = 1.65;
             trans.tc9_ti__Time_Sheet_Entry__c = testTimesheetEntry.id;
             insert trans;
                
             List<tc9_ti__Time_Sheet__History> lstTSH = new List<tc9_ti__Time_Sheet__History>();
             tc9_ti__Time_Sheet__History tsh = new tc9_ti__Time_Sheet__History();
             lstTSH.add(tsh);
                             
             map<id,tc9_ti__Time_Sheet_Entry__c> mapTSE = new map<id,tc9_ti__Time_Sheet_Entry__c>();
             mapTSE.put(testTimesheetEntry.id,testTimesheetEntry);
                
             map<id,list<tc9_ti__Time_Sheet__History>> mapTSH = new map<id,list<tc9_ti__Time_Sheet__History>>();
             mapTSH.put(lstTSH[0].id,lstTSH);
                
             map<id,List<tc9_ti__Time_Sheet_Entry__c>> mapTSEL = new map<id,List<tc9_ti__Time_Sheet_Entry__c>>();
             mapTSEL.put(testTimesheetEntry.id,new List<tc9_ti__Time_Sheet_Entry__c>{testTimesheetEntry});   
            
           List<InvoiceRecord> invRecords = new List<InvoiceRecord>();
           

             boolean breakpage = true;
             invoices.put(inv.id,inv); 

              tc9_ti__Invoice_Template__c invtemp = new tc9_ti__Invoice_Template__c();
            invtemp.Name = 'Test invoice';
            invtemp.tc9_ti__Default__c = true;
            invtemp.tc9_ti__EmailTemplate_Online__c = 'Test Template';
            invtemp.tc9_ti__EmailTemplate_PDF__c = 'Test Template';
            invtemp.tc9_ti__Record_Type__c = 'Temp';
            invtemp.tc9_ti__Page_Name__c = 'TempInvoice';
            insert invtemp;
             //Consolidated Invoice
             List<tc9_ti__Consolidated_Invoice__c> lstCI =  new List<tc9_ti__Consolidated_Invoice__c>();
             tc9_ti__Consolidated_Invoice__c conIn =  new tc9_ti__Consolidated_Invoice__c();
             conIn.tc9_ti__PaymentTerm__c = paymentTerm.Id;
             conIn.tc9_ti__Invoice_Payment_Status_Updated__c = true;
             conIn.tc9_ti__Delivery_Method_Token_Available__c = 'ABC';
             conIn.tc9_ti__Bill_To_Account__c = acc.id;
             conIn.tc9_ti__Invoiced_Date__c  =date.today();
             conIn.tc9_ti__Invoice_Template__c = invtemp.id;
             conIn.tc9_ti__Invoice_Message__c= 'Test';
             conIn.tc9_ti__Billing_Entity__c = acc.id;
             lstCI.add(conIn);
             insert lstCI;
            
            
           List<tc9_ti__Consolidated_Invoice__c> conInvoices = [SELECT id , Name,  tc9_ti__PaymentTerm__c, tc9_ti__Invoice_Total_Inc__c,CurrencyIsoCode,  
                                tc9_ti__DueDate__c, tc9_ti__Invoiced_Date__c,tc9_ti__Link_Token__c,tc9_ti__Invoice_Message__c,
                                tc9_ti__Client__c, tc9_ti__Billing_Entity__c,tc9_ti__Credit_Reason__c,
                                tc9_ti__Bill_To_Account__c, tc9_ti__Bill_To_Account__r.tc9_ti__Backing_Sheet_Exception__c, 
                                tc9_ti__Bill_To_Contact__c, tc9_ti__Bill_To_Contact__r.Name, tc9_ti__Bill_To_Contact__r.Email,
                                tc9_ti__Original_Invoice__c, tc9_ti__Original_Invoice__r.tc9_ti__Invoice_Total_Inc__c, tc9_ti__Original_Invoice__r.Name,
                                tc9_ti__PurchaseOrderNumber__c, tc9_ti__Grouped_By_Project_Code__c,RecordTypeId, RecordType.DeveloperName,  
                               (Select id, tc9_ti__Invoice__c FROM tc9_ti__Consolidated_Lines__r)
                               FROM tc9_ti__Consolidated_Invoice__c 
                            WHERE id =: conInv.id OR tc9_ti__Link_Token__c =: conInv.id];
            system.debug('**Query***'+conInvoices[0].tc9_ti__Consolidated_Lines__r);
             test.starttest();
             PageReference pageRef = Page.TempInvoice_v3;
             Test.setCurrentPage(pageRef);
             ApexPages.currentPage().getParameters().put('printId',conInv.id);
             ApexPages.currentPage().getParameters().put('token',conInv.id);
             Ctrl_TempInv_v3 oCEE = new Ctrl_TempInv_v3(new ApexPages.StandardSetController(new List<tc9_ti__Consolidated_Invoice__c>{conInv}));
            // oCEE.conInvoices = conInvoices;
             Ctrl_TempInv_v3.getNumericString('Test');
             Ctrl_TempInv_v3.TotalWrapper wrap = new Ctrl_TempInv_v3.TotalWrapper();
             Ctrl_TempInv_v3.formatAccNumber('Test','Test','Test');
             wrap.getPageCount();
             oCEE.getObjectName(ts);
             oCEE.getObjectLabel(ts);
             //oCEE.getFieldDescribe(ts,'Test');
             
             wrap.addBackingSheets(new List<tc9_ti__Time_Sheet__c>{ts},mapTSEL ,mapTSH,True,True );
             Ctrl_TempInv_v3.TimesheetEntryWrapper tshWrap = new Ctrl_TempInv_v3.TimesheetEntryWrapper(testTimesheetEntry);
             tshWrap.compareTo(tshWrap);
             
             Ctrl_TempInv_v3.InvoiceRecordWrapper wrap1 = new Ctrl_TempInv_v3.InvoiceRecordWrapper(invRecords,breakpage); 
             oCEE.getInvoicesPaginated(invRecords);
             boolean showheader = true;
             wrap.getBSPagesCount();
            // wrap.addBackingSheets(new List<tc9_ti__Time_Sheet__c>{ts},mapTSEL ,mapTSH);
            
            
             Ctrl_TempInv_v3.BackingSheetWrapper wrapBack = new Ctrl_TempInv_v3.BackingSheetWrapper(ts,true,true);
             Ctrl_TempInv_v3.BackingSheetWrapper wrapBack1 = new Ctrl_TempInv_v3.BackingSheetWrapper(ts,lstTSH,True,True);
             Ctrl_TempInv_v3.BackingSheetWrapper wrapBack2 = new Ctrl_TempInv_v3.BackingSheetWrapper(ts,new List<tc9_ti__Time_Sheet_Entry__c>{testTimesheetEntry},lstTSH);
             wrapBack1.addTimesheetHistory(lstTSH);
             
             Object wrapperobj;
             wrapBack1.addTimesheetEntry(tshWrap);
             
             wrapBack1.compareTo(wrapBack2);
             //Ctrl_TempInv_v3.BackingSheetWrapper wrapBack2 = new Ctrl_TempInv_v3.BackingSheetWrapper(ts,lstTSE,lstTSH);
             test.stoptest();
  }
   static testMethod void createData1() {
    Map<Id, tc9_ti__Invoice__c> invoices = new Map<Id, tc9_ti__Invoice__c>();
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
        Account acc = testDataDump.getAClientAccount(testMarket.Id);
        acc.Name = 'Premier Staffing, Inc';
        acc.BillingStreet = 'BillingStreet';
        acc.BillingCity = 'Melbourne';
        acc.BillingState = 'Victoria';
        acc.BillingPostalCode = '3000';
        acc.BillingCountry = 'Australia';
        acc.Phone = '1234567899';
        acc.Fax = '90000';
        acc.Website = 'www.test.com';
        acc.tc9_ti__Invoice_Group_By__c = 'Placement';
        acc.ts2__Invoice_Terms__c = '10';
        acc.tc9_ti__PaymentTerm__c = paymentTerm.Id;
        update acc;
          
        //create a client contact
        Contact testContact = testDataDump.getAClientContact(acc.Id);
        testContact.Salutation  = 'Mr';
        testContact.State__c = 'AL';
        update testContact;
        
        //Update Contact with Account Payable Lookup
        acc.ts2__Accounts_Payable__c = testContact.Id;
        update acc;
        
        //create an Employee
        Contact con = testDataDump.getAClientContact(acc.Id);
        con.First_Day_Worked__c = Date.today().addDays(-200);
        con.State__c = 'AL';
        update con;
        
        candidateId = con.Id;
        
        //Create an Award
        tc9_ti__Award_Master__c testAwardMaster = testDataDump.getAnAward();
        insert testAwardMaster;
        
        //Create a Job
        ts2__Job__c job = testDataDump.getAJob(acc.Id, testContact.Id, testMarket.Id, testSites.Id);
        job.ts2__Location__c = 'San Francisco';
        job.tc9_ti__PaymentTerm__c = paymentTerm.Id;
        update job;
         //create a public holiday calander
        tc9_ti__Public_Holiday_Calendar__c testCalendar = new tc9_ti__Public_Holiday_Calendar__c();
        testCalendar.tc9_ti__Year__c = String.valueOf(Date.today().year());
        testCalendar.Name = 'Australia - Vic';
        insert testCalendar;
       
                    
            Date startDate = system.today();
            Date endDate = system.today()+4;
             //Placement 
             ts2__Placement__c plc = new ts2__Placement__c();
             plc.ts2__Start_Date__c         = startDate;
             plc.ts2__End_Date__c        = endDate;
             plc.tc9_ti__Auto_Approve_0_Timesheets__c = true;
             plc.ts2__Job__c = job.id;
             plc.ts2__Client__c = acc.id;
             plc.ts2__Employee__c = con.id;
             //plc.Migrated_AU_Placement__c = false; 
             //plc.Migrated_NZ_Placement__c  = false;
                plc.tc9_ti__Hours_Wednesday__c   = 8;
                plc.tc9_ti__Hours_Tuesday__c   = 8; 
                plc.tc9_ti__Hours_Thursday__c   = 8; 
                plc.tc9_ti__Hours_Sunday__c   = 0;
                plc.tc9_ti__Hours_Saturday__c   = 0;
                plc.tc9_ti__Hours_Monday__c   = 8;
                plc.tc9_ti__Hours_Friday__c   = 8;
                plc.CurrencyIsoCode           = 'USD';
                plc.tc9_ti__TimeSheetApprover__c        = job.ts2__Contact__c;
                plc.tc9_ti__Market__c        = testMarket.Id;
                plc.tc9_ti__Public_Holiday_Calendar__c  = testCalendar.id;
             insert plc;
            
             tc9_ti__Time_Sheet__c ts = new tc9_ti__Time_Sheet__c();
             ts.tc9_ti__Candidate__c  = con.id;
             ts.tc9_ti__Start_Date__c = system.today();
             ts.tc9_ti__End_Date__c   = system.today()+1;
             ts.tc9_ti__Generate_Transaction__c = '1';
             ts.tc9_ti__Placement__c = plc.Id;
             insert ts;
            
            tc9_ti__Invoice_Template__c  invTem = new tc9_ti__Invoice_Template__c();
            invTem.Name = 'Test';
           // invTem.tc9_ti__Account__c = acc.id;
            insert invTem;
            
            tc9_ti__Consolidated_Invoice__c conInv = new tc9_ti__Consolidated_Invoice__c();
            conInv.tc9_ti__Delivery_Method_Token_Available__c = 'test';
            conInv.tc9_ti__Invoice_Template__c = invTem.id;
            insert conInv;
            
          
            
            tc9_ti__Time_Sheet_Entry__c testTimesheetEntry = testDataDump.getATimesheetEntry(ts.Id,  Date.today().addDays(-10), '00:00', '08:00');
            insert testTimesheetEntry;
            
            tc9_ti__Invoice__c inv = new tc9_ti__Invoice__c();//Invoice
             inv.tc9_ti__ARContact_Ext__c = 'asd';
             insert inv;
             List<tc9_ti__InvoiceItem__c> lstInvitm = new List<tc9_ti__InvoiceItem__c>();
             tc9_ti__InvoiceItem__c invItm = new tc9_ti__InvoiceItem__c();//Invoice Item
             invItm.tc9_ti__TalentLastName__c = 'Qwe';
             invItm.tc9_ti__Invoice__c = inv.id;
             invItm.tc9_ti__Quantity__c       = 2;
             invItm.tc9_ti__TotalTax__c  =3;
             invItm.tc9_ti__TotalBillIncTax__c  = 23;
             invItm.tc9_ti__TotalBillExTax__c =45;
             invItm.tc9_ti__Time_Sheet_Entry__c = testTimesheetEntry.id;
             lstInvitm.add(invItm);
             insert lstInvitm;
             
               tc9_ti__Consolidated_Line__c conLn = new tc9_ti__Consolidated_Line__c();
            conLn.tc9_ti__Consolidated_Invoice__c = conInv.id;
            conLn.tc9_ti__Invoice__c = inv.id;
            insert conLn;
            
                
             List<tc9_ti__Time_Sheet__History> lstTSH = new List<tc9_ti__Time_Sheet__History>();
             tc9_ti__Time_Sheet__History tsh = new tc9_ti__Time_Sheet__History();
             lstTSH.add(tsh);
                             
             map<id,tc9_ti__Time_Sheet_Entry__c> mapTSE = new map<id,tc9_ti__Time_Sheet_Entry__c>();
             mapTSE.put(testTimesheetEntry.id,testTimesheetEntry);
                
             map<id,list<tc9_ti__Time_Sheet__History>> mapTSH = new map<id,list<tc9_ti__Time_Sheet__History>>();
             mapTSH.put(lstTSH[0].id,lstTSH);
                
             map<id,List<tc9_ti__Time_Sheet_Entry__c>> mapTSEL = new map<id,List<tc9_ti__Time_Sheet_Entry__c>>();
             mapTSEL.put(testTimesheetEntry.id,new List<tc9_ti__Time_Sheet_Entry__c>{testTimesheetEntry});   
            
              List<InvoiceRecord> invRecords = new List<InvoiceRecord>();
            InvoiceRecord invR = new InvoiceRecord( lstInvitm[0], inv ,conInv);
             invR.showInvoiceDetails = true;
             invRecords.add(invR);
             invRecords[0].compareTo(invRecords[0]);
             

             InvoiceRecord.InvoiceItemByPaycode invItempaycode = new InvoiceRecord.InvoiceItemByPaycode(lstInvitm[0]);
             invItempaycode.addInvoiceItem(lstInvitm[0]);
             invItempaycode.compareTo(invItempaycode);

           
             //insert invRecords;
             
             boolean breakpage = true;
             invoices.put(inv.id,inv); 

              tc9_ti__Invoice_Template__c invtemp = new tc9_ti__Invoice_Template__c();
            invtemp.Name = 'Test invoice';
            invtemp.tc9_ti__Default__c = true;
            invtemp.tc9_ti__EmailTemplate_Online__c = 'Test Template';
            invtemp.tc9_ti__EmailTemplate_PDF__c = 'Test Template';
            invtemp.tc9_ti__Record_Type__c = 'Temp';
            invtemp.tc9_ti__Page_Name__c = 'TempInvoice';
            insert invtemp;
             //Consolidated Invoice
             List<tc9_ti__Consolidated_Invoice__c> lstCI =  new List<tc9_ti__Consolidated_Invoice__c>();
             tc9_ti__Consolidated_Invoice__c conIn =  new tc9_ti__Consolidated_Invoice__c();
             conIn.tc9_ti__PaymentTerm__c = paymentTerm.Id;
             conIn.tc9_ti__Invoice_Payment_Status_Updated__c = true;
             conIn.tc9_ti__Delivery_Method_Token_Available__c = 'ABC';
             conIn.tc9_ti__Bill_To_Account__c = acc.id;
             conIn.tc9_ti__Invoiced_Date__c  =date.today();
             conIn.tc9_ti__Invoice_Template__c = invtemp.id;
             conIn.tc9_ti__Invoice_Message__c= 'Test';
             conIn.tc9_ti__Billing_Entity__c = acc.id;
             lstCI.add(conIn);
             insert lstCI;
  
   ApexPages.currentPage().getParameters().put('printId',null);
             ApexPages.currentPage().getParameters().put('token',null);
             Ctrl_TempInv_v3 oCEE = new Ctrl_TempInv_v3(new ApexPages.StandardSetController(lstCI));
             }
  
}