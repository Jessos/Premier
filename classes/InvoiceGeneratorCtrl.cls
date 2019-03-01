public with sharing class InvoiceGeneratorCtrl {
list<Placement> list_placement = new list<Placement>();
public tc9_ti__Transaction__c dummyTransaction {get;set;}

public InvoiceGeneratorCtrl(){
    
    dummyTransaction = new tc9_ti__Transaction__c();
}
    public class Placement{ 
    public String Customer ='' ;
        public id PlacementId ;
        
        public String RefNumber ='' ;
        public String ClassRef ='' ;
        public String ToBePrinted ='' ;
        public String BillToLine1 ='' ;
        public String BillToLine2 ='' ;
        public String BillToLine3 ='' ;
        public String BillToCity ='Melbourne' ;
        public String BillToState ='Victoria' ;
        public String BillToPostalCode ='3000' ;
        public String BillToCountry ='Australia' ;
        public String Item ='' ;
        public Decimal Quantity =0.0 ;
        public String Description ='' ;
        public Decimal Price =0.0 ;
        public String ItemLineClass ='' ;
        public String ToBeEMailed ='' ;
        public String TempService ='' ;
        public String PONumber ='' ;
    
    public Placement(id PlaceId,String CustomerN,String BillToLine1N,String ToBePrintedN,String itemN,Decimal QuantityN,String DescriptionN,Decimal PriceN,String ToBeEMailedN,String BillToCityN,String BillToStateN,String BillToPostalCodeN,String BillToCountryN,String BillingStreetN,String BillToLine2N,String ClassRefN,String PONumberN){
        Customer= CustomerN;    
        Quantity= QuantityN;
        BillToLine1=BillToLine1N;
        ToBePrinted=ToBePrintedN;
        item=itemN;
        PlacementId=PlaceId;
        Description=DescriptionN;
        Price= PriceN;
        PONumber= PONumberN;
        ToBeEMailed=ToBeEMailedN;
        TempService= 'Temp Service';
        BillToCity=BillToCityN;
        BillToState=BillToStateN;
        BillToPostalCode=BillToPostalCodeN;
        BillToCountry=BillToCountryN;
        BillToLine3=BillingStreetN;
        BillToLine2=BillToLine2N;
        ClassRef = ClassRefN;
    }
    
}

        public PageReference extractInformation()
        {
          InvoiceGenerator_Batch csvBatchInstance;
          System.debug('Abcd1--');
          if(dummyTransaction.StartDate__c != null && dummyTransaction.EndDate__c != null )
          {
            System.debug('Abcd2--');
            if(dummyTransaction.StartDate__c == dummyTransaction.EndDate__c)
            {   
                System.debug('Abcd3--');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please ensure that from and to dates are not the same value'));
                return null;
            }
            else if(dummyTransaction.StartDate__c > dummyTransaction.EndDate__c)
            {
                System.debug('Abcd4--');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please ensure that to date is greater than from date'));
                return null;
            }
            else
            {   
                System.debug('Abcd5--');
                csvBatchInstance = new InvoiceGenerator_Batch(dummyTransaction.StartDate__c, dummyTransaction.EndDate__c);
            }
          }
          else if(dummyTransaction.StartDate__c != null)
          {
            System.debug('Abcd6--');
            csvBatchInstance = new InvoiceGenerator_Batch(dummyTransaction.StartDate__c , null);
          }
          else
          {
            System.debug('Abcd7--'); 
            csvBatchInstance = new InvoiceGenerator_Batch(null, null);
          }
           
           System.debug('Abcd8--');
           Database.BatchableContext BC;
          // csvBatchInstance.execute(BC,new List<tc9_ti__Transaction__c>{dummyTransaction});
          Database.executeBatch(csvBatchInstance, 100);//change back to 100 when bug fixing done
          return null;  
            
        }
        
        
        
        /*********************** test methods *********************************************/
        //test method for VF Page controller
        static testmethod void testPageController ()
        {
            
            ToC9_TestDataDump testData = new ToC9_TestDataDump();
            Date plcStartDate    = date.parse('12/10/2012');
            Date plcEndDate      = plcStartDate.addDays(9);  //placement spanning two weeks (till 01/08/2012)
            
            tc9_ti__TaxID__c taxID  = testData.getTaxID();
            tc9_ti__Market__c market= testData.getMarket(taxID.Id);  
            
            Account accnt      = testData.getAClientAccount(market.Id);
            accnt.Invoice_Delivery_Temps__c = 'Email';
            accnt.tc9_ti__Invoice_Group_By__c ='Client';
            accnt.ts2__Invoice_Terms__c ='10';
            update accnt;
            
            Contact clientContact  = testData.getAClientContact(accnt.Id);
            
            tc9_ti__Site__c sit    = testData.getASite('Test Site', 'http://www.test.com/');
            
            ts2__Job__c  job1     = testData.getAJob(accnt.Id, clientContact.Id, market.Id,sit.Id);
            job1.CostCenter__c = 'Test';
            job1.tc9_ti__PurchaseOrderNumber__c = '12345';
            job1.ts2__Department__c = 'Doctor';
            update job1;
            
            Contact candidate    = testData.getACandidate('TestCandidate');  
            candidate.email      = 'canemail@email.test.com';
            candidate.State__c = 'AL' ;
            candidate.accountid = accnt.id;
           
            update candidate;
            
            
            tc9_ti__Award_Master__c awrdMaster = new tc9_ti__Award_Master__c();
            awrdMaster.tc9_ti__Ordinary_Weekly_Hours__c    = 12.5;
            awrdMaster.tc9_ti__Minimum_Weekly_Paid_Hours__c   = 10;
            awrdMaster.tc9_ti__Minimum_Sunday_Paid_Hours__c   = 2;
            awrdMaster.tc9_ti__Minimum_Saturday_Paid_Hours__c  = 1;
            awrdMaster.tc9_ti__Minimum_Public_Holiday_Paid_Hours__c = 1;
            awrdMaster.tc9_ti__Interpret_On_Weekly_Totals__c   = true;
            awrdMaster.tc9_ti__Hourly_Standard_Rate__c    = 10;
            insert awrdMaster;
            RecordType rt = [select id,Name from RecordType where SobjectType='ts2__Placement__c' and Name='Perm' Limit 1];
            
           /* ts2__Placement__c plcRec1  = testData.getAPlacement(job1, null, candidate.Id, plcStartDate, plcEndDate, awrdMaster.Id, 'Temp'); 
            plcRec1.tc9_ti__Base_Pay_Rate__c = 22;
            plcRec1.recordtypeid = rt.id;
            plcRec1.ts2__Employee__c = candidate.id;
            plcRec1.tc9_ti__Base_Bill_Rate__c = 10;
            plcRec1.Billing_Address_1__c = 'MGR Salai';
            plcRec1.Billing_Address_2__c = 'Chennai';
            plcRec1.Billing_State__c = 'Tamil Nadu';
            plcRec1.Billing_ZIP__c = '630885';
            plcRec1.ts2__Accounts_Payable__c = clientContact.Id;
            update plcRec1;
            
            ts2__Placement__c plc  = testData.getAPlacement(job1, null, candidate.Id, plcStartDate, plcEndDate, awrdMaster.Id, 'PayRoll'); 
            plc.tc9_ti__Base_Pay_Rate__c = 22;
            plc.recordtypeid = rt.id;
            plc.ts2__Employee__c = candidate.id;
            plc.Billing_Address_1__c = 'MGR Salai';
            plc.Billing_Address_2__c = 'Chennai';
            plc.Billing_State__c = 'Tamil Nadu';
            plc.Billing_ZIP__c = '630885';
            
            
            update plc;
            
            //cloning the existing placement
            ts2__Placement__c plcRec2 = plcRec1.clone();
            plcRec2.recordtypeid = rt.id;
            plcRec2.ts2__Employee__c = candidate.id;
            plcRec2.tc9_ti__Base_Pay_Rate__c = 10;
            plcRec2.tc9_ti__Base_Bill_Rate__c = 10;
            plcRec2.Billing_Address_1__c = 'MGR Salai';
            plcRec2.Billing_Address_2__c = 'Chennai';
            plcRec2.Billing_State__c = 'Tamil Nadu';
            plcRec2.Billing_ZIP__c = '630885';
            plcRec2.ts2__Accounts_Payable__c = clientContact.Id;
            insert plcRec2;
            system.assertNotEquals(null, plcRec2.Id);
            system.assertEquals(10,plcRec2.tc9_ti__Base_Pay_Rate__c);
            
            
            ts2__Placement__c plcRec3 = plcRec1.clone();
            plcRec3.tc9_ti__Base_Pay_Rate__c = 15;
            plcRec3.recordtypeid = rt.id;
            plcRec3.ts2__Employee__c = candidate.id;
            plcRec3.tc9_ti__Base_Bill_Rate__c = 10;
            plcRec3.Billing_Address_1__c = 'MGR Salai';
            plcRec3.Billing_Address_2__c = 'Chennai';
            plcRec3.Billing_State__c = 'Tamil Nadu';
            plcRec3.Billing_ZIP__c = '630885';
            plcRec3.ts2__Accounts_Payable__c = clientContact.Id;
            insert plcRec3;
            system.assertNotEquals(null, plcRec3.Id);
            //system.assertEquals(15,plcRec2.tc9_ti__Base_Pay_Rate__c);*/
            
            tc9_ti__PayCodeMaster__c pay = new tc9_ti__PayCodeMaster__c();
            pay.Name = 'Test 1';
            pay.tc9_ti__Paycode__c = 'REG';
            pay.Paycom_Earning_Code__c = 'RGT';
            insert pay;
            
            tc9_ti__PayCodeMaster__c pay4 = new tc9_ti__PayCodeMaster__c();
            pay4.Name = 'Test 1';
            pay4.tc9_ti__Paycode__c = 'Sick';
            pay4.Paycom_Earning_Code__c = 'STT';
            insert pay4;
            
            tc9_ti__PayCodeMaster__c pay5 = new tc9_ti__PayCodeMaster__c();
            pay5.Name = 'Test 1';
            pay5.tc9_ti__Paycode__c = 'Holiday';
            pay5.Paycom_Earning_Code__c = 'HTT';
            insert pay5;
            
            tc9_ti__PayCodeMaster__c pay1 = new tc9_ti__PayCodeMaster__c();
            pay1.Name = 'Test 2';
            pay1.tc9_ti__Paycode__c = 'OT';
            pay1.Paycom_Earning_Code__c = 'OTT';
            insert pay1;
            
            tc9_ti__PayCodeMaster__c pay2 = new tc9_ti__PayCodeMaster__c();
            pay2.Name = 'Test 3';
            pay2.tc9_ti__Paycode__c = 'DT';
            pay2.Paycom_Earning_Code__c = 'DTT';
            insert pay2;
            
            tc9_ti__Rule__c rule = new tc9_ti__Rule__c();
            rule.Name    = 'Test Rule';
            rule.tc9_ti__Award_Master__c     = awrdMaster.id;
            rule.tc9_ti__Type__c    = 'Weekly Breakpoint';
            rule.tc9_ti__Start_Threshold__c = 10;
            rule.tc9_ti__End_Threshold__c   = 20;
            rule.tc9_ti__Bill_Multiplier__c = 1;
            rule.tc9_ti__Pay_Multiplier__c  = 1;
            rule.tc9_ti__Paycode__c         = pay.id;
            rule.tc9_ti__Discount_Percentage__c = 10;
            insert rule;
            
            tc9_ti__Rule__c rule1 = new tc9_ti__Rule__c();
            rule1.Name   = 'Test Rule';
            rule1.tc9_ti__Award_Master__c    = awrdMaster.id;
            rule1.tc9_ti__Type__c   = 'Weekly Breakpoint';
            rule1.tc9_ti__Start_Threshold__c    = 10;
            rule1.tc9_ti__End_Threshold__c  = 20;
            rule1.tc9_ti__Bill_Multiplier__c    = 2;
            rule1.tc9_ti__Pay_Multiplier__c = 1;
            rule1.tc9_ti__Paycode__c            = pay1.id;
            rule1.tc9_ti__Discount_Percentage__c    = 10;
            insert rule1;
            
            tc9_ti__Rule__c rule2 = new tc9_ti__Rule__c();
            rule2.Name   = 'Test Rule';
            rule2.tc9_ti__Award_Master__c = awrdMaster.id;
            rule2.tc9_ti__Type__c   = 'Weekly Breakpoint';
            rule2.tc9_ti__Start_Threshold__c    = 10;
            rule2.tc9_ti__End_Threshold__c  = 20;
            rule2.tc9_ti__Bill_Multiplier__c    = 2;
            rule2.tc9_ti__Pay_Multiplier__c = 1;
            rule2.tc9_ti__Paycode__c            = pay2.id;
            rule2.tc9_ti__Discount_Percentage__c    = 10;
            insert rule2;
            
            
            rule = new tc9_ti__Rule__c();
            rule.Name    = 'Test Rule';
            rule.tc9_ti__Award_Master__c     = awrdMaster.id;
            rule.tc9_ti__Type__c    = 'Weekly Breakpoint';
            rule.tc9_ti__Start_Threshold__c = 10;
            rule.tc9_ti__End_Threshold__c   = 20;
            rule.tc9_ti__Bill_Multiplier__c = 1;
            rule.tc9_ti__Pay_Multiplier__c  = 1;
            rule.tc9_ti__Paycode__c         = pay4.id;
            rule.tc9_ti__Discount_Percentage__c = 10;
            insert rule;
            
            rule = new tc9_ti__Rule__c();
            rule.Name    = 'Test Rule';
            rule.tc9_ti__Award_Master__c     = awrdMaster.id;
            rule.tc9_ti__Type__c    = 'Weekly Breakpoint';
            rule.tc9_ti__Start_Threshold__c = 10;
            rule.tc9_ti__End_Threshold__c   = 20;
            rule.tc9_ti__Bill_Multiplier__c = 1;
            rule.tc9_ti__Pay_Multiplier__c  = 1;
            rule.tc9_ti__Paycode__c         = pay5.id;
            rule.tc9_ti__Discount_Percentage__c = 10;
            insert rule;
          //  tc9_ti__Time_Sheet__c testTimesheet = testData.getATimesheet(plc.Id, clientContact.Id , Date.Today().toStartOfWeek().addDays(-10), Date.Today().toStartOfWeek().addDays(-1));
           // testTimesheet.tc9_ti__End_Date__c = Date.today().addDays(10);
           // insert testTimesheet;
            
            List<tc9_ti__Transaction__c> tranlist = new List<tc9_ti__Transaction__c>();
            
            Id TranExpRecordTypeId = [Select r.SobjectType, r.DeveloperName, r.Name From RecordType r where r.SobjectType = 'tc9_ti__Transaction__c' and DeveloperName != 'Temp' and DeveloperName != 'Payroll' limit 1 ].Id;
            for (integer i = 0; i < 15; i++)
            {
               // tc9_ti__Transaction__c tran = new tc9_ti__Transaction__c(tc9_ti__EntryDate__c = plcStartDate.addDays(i), 
              //  tc9_ti__SentToPayroll__c = '',
              //  tc9_ti__Adjusted_PayRate__c = 30,tc9_ti__PayRate__c = 30, tc9_ti__HoursActutal__c = 1,  tc9_ti__Multiplier__c = 1,tc9_ti__Time_Sheet__c = testTimesheet.Id); 
                
                if(i>5 && i<10)
                {
                    //tran.RecordTypeId = Map_Of_RecordtypeId_to_Name.get('Temp');
                   // tran.RecordTypeId = TranExpRecordTypeId;
                   // tran.tc9_ti__Placement__c = plcRec2.id;
                    
                    if(i==6)
                    {
                       // tran.tc9_ti__Paycode__c = 'REG';
                       // tran.Paycom_Earning_Code__c = 'RGT';
                    }
                    else if(i==8)
                    {
                       // tran.tc9_ti__Paycode__c = 'Sick';
                       // tran.Paycom_Earning_Code__c = 'STT';
                    }
                    else if(i==9)
                    {
                       // tran.tc9_ti__Paycode__c = 'Holiday';
                       // tran.Paycom_Earning_Code__c = 'HTT';
                    }
                    else if(i==7)
                    {
                        //tran.tc9_ti__Paycode__c = 'OT';
                        //tran.Paycom_Earning_Code__c = 'OTT';
                    }
                    else
                    {
                       // tran.tc9_ti__Paycode__c = 'DT';
                       // tran.Paycom_Earning_Code__c = 'DTT';
                    }
                }
                else if(i<5)
                {
                    //tran.RecordTypeId = Map_Of_RecordtypeId_to_Name.get('Payroll');
                  //  tran.RecordTypeId = TranExpRecordTypeId;
                   // tran.tc9_ti__Placement__c = plcRec3.id;
                    
                    if(i==1)
                    {
                       // tran.tc9_ti__Paycode__c = 'REG';
                      //  tran.Paycom_Earning_Code__c = 'RGT';
                    }
                    else if(i==2)
                    {
                       // tran.tc9_ti__Paycode__c = 'OT';
                       // tran.Paycom_Earning_Code__c = 'OTT';
                    }
                    else if(i==3)
                    {
                      //  tran.tc9_ti__Paycode__c = 'Sick';
                      //  tran.Paycom_Earning_Code__c = 'STT';
                    }
                    else if(i==4)
                    {
                     //   tran.tc9_ti__Paycode__c = 'Holiday';
                      //  tran.Paycom_Earning_Code__c = 'HTT';
                    }
                    else
                    {
                       // tran.tc9_ti__Paycode__c = 'DT';
                       // tran.Paycom_Earning_Code__c = 'DTT';
                    }
                }
                else
                {
                  //  tran.RecordTypeId = TranExpRecordTypeId;
                  //  tran.tc9_ti__Placement__c = plcRec1.id;
                    
                    if(i==11)
                    {
                      //  tran.tc9_ti__Paycode__c = 'REG';
                       // tran.Paycom_Earning_Code__c = 'RGT';
                    }
                    else if(i==12)
                    {
                       // tran.tc9_ti__Paycode__c = 'OT';
                       // tran.Paycom_Earning_Code__c = 'OTT';
                    }
                    else if(i==13)
                    {
                      //  tran.tc9_ti__Paycode__c = 'Sick';
                       // tran.Paycom_Earning_Code__c = 'STT';
                    }
                    else if(i==14)
                    {
                       // tran.tc9_ti__Paycode__c = 'Holiday';
                       // tran.Paycom_Earning_Code__c = 'HTT';
                    }
                    else
                    {
                       // tran.tc9_ti__Paycode__c = 'DT';
                       // tran.Paycom_Earning_Code__c = 'DTT';
                    }
                }
               // tranlist.add(tran);
            }
            
           // insert tranlist;
            
            //setting current page reference to Invoice Extraction
            PageReference testpageRef = new PageReference('/apex/InvoiceExtract');
            Test.setCurrentPageReference(testpageRef);
            InvoiceGeneratorCtrl invoiceController = new InvoiceGeneratorCtrl();
            
            //testing without any values for the dates (From and To date)
          
        /*    //first we test with from and to date to be the same value
            invoiceController.dummyTransaction.StartDate__c  = DateTime.Now();
            invoiceController.dummyTransaction.EndDate__c  = DateTime.Now();            
             //invoiceController.extractInformation();
//           system.assertEquals(1,Apexpages.getMessages().size());
            
            //Now we test with the from date greater than to date
            invoiceController.dummyTransaction.StartDate__c  = DateTime.Now().addDays(1);
            invoiceController.dummyTransaction.EndDate__c  = DateTime.Now();            
             //invoiceController.extractInformation();
//          system.assertEquals(2,Apexpages.getMessages().size());
            
            //Now we test with just the from date value
            invoiceController.dummyTransaction.StartDate__c  = DateTime.Now().addDays(-3);
            invoiceController.dummyTransaction.EndDate__c  = null;            
            // invoiceController.extractInformation();
//            system.assertEquals(2,Apexpages.getMessages().size());//No new page message as the date values are provided
            
            //Now we give the correct from and to date values
            invoiceController.dummyTransaction.StartDate__c  = DateTime.Now().addDays(-3);
            invoiceController.dummyTransaction.EndDate__c  = DateTime.Now();*/            
            // invoiceController.extractInformation();
//            system.assertEquals(2,Apexpages.getMessages().size());//No new page message as the date values are provided
              Test.StartTest();
             invoiceController.extractInformation();
             
            Test.StopTest();
        }
}