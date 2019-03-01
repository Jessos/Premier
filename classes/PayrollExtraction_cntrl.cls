/*************************************************************
Created Date : April 3rd 2012
Purpose      : To extract payroll from timsheet information and 
               generate as excel based on Extracts mapping provided  
               
**************************************************/
public with sharing class PayrollExtraction_cntrl {
        
        //map variable to hold record type information
        public Map<Id,String> Map_Of_RecordtypeId_to_Name {get;set;}
        public tc9_ti__Transaction__c dummyTransaction {get;set;}
        public tc9_ti__Transaction__c dummyTransaction_for_previousExtracts {get;set;}
        
        public PayrollExtraction_cntrl()
        {
            dummyTransaction = new tc9_ti__Transaction__c();
            dummyTransaction_for_previousExtracts = new tc9_ti__Transaction__c();
        }
        
        public PageReference extractInformation()
        {
          payrollExtratc_Batch csvBatchInstance;
          boolean inputGiven = false;
          system.debug('dates--'+dummyTransaction.StartDate__c+' *** '+dummyTransaction.EndDate__c);
          If(dummyTransaction.StartDate__c != null && dummyTransaction.EndDate__c != null )
          {
            if(dummyTransaction.StartDate__c == dummyTransaction.EndDate__c)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please ensure that From and To dates are not the same value'));
                return null;
            }
            else if(dummyTransaction.StartDate__c > dummyTransaction.EndDate__c)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please ensure that To date is greater than From date'));
                return null;
            }
            else
            {
                csvBatchInstance = new payrollExtratc_Batch(dummyTransaction.StartDate__c, dummyTransaction.EndDate__c);
            }   
            inputGiven = true;
            
          }
          else if(dummyTransaction.StartDate__c != null)
          {
            csvBatchInstance = new payrollExtratc_Batch(dummyTransaction.StartDate__c , null);
            inputGiven = true;
          }
          else
          {
            csvBatchInstance = new payrollExtratc_Batch(null, null);
            //inputGiven = true;
          }
          
          /************** handling the previous extracts between the dates specified *****************/
          If(dummyTransaction_for_previousExtracts.StartDate__c != null)
          { 
            if( dummyTransaction_for_previousExtracts.EndDate__c != null && dummyTransaction_for_previousExtracts.StartDate__c == dummyTransaction_for_previousExtracts.EndDate__c)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please ensure that From and To dates are not the same value in the previous extracts section'));
                return null;
            }
            else if(dummyTransaction_for_previousExtracts.EndDate__c != null && dummyTransaction_for_previousExtracts.StartDate__c > dummyTransaction_for_previousExtracts.EndDate__c)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please ensure that To date is greater than From date in the previous extracts section'));
                return null;
            }
            
            else
            {
                csvBatchInstance.fromDate_prev = dummyTransaction_for_previousExtracts.StartDate__c;
                csvBatchInstance.toDate_prev = dummyTransaction_for_previousExtracts.EndDate__c;
            }
            inputGiven = true;
          }
          if(!inputGiven) 
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please specify a date value for the extract to filter'));
                return null;
            }
            
            /*******************************************************************************************/
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'A batch job has been initiated to extract payroll file. The file will be available in \'Payroll Extracts\' document folder'));
          Database.executeBatch(csvBatchInstance, 100);
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
            Contact clientContact  = testData.getAClientContact(accnt.Id);
            
            tc9_ti__Site__c sit    = testData.getASite('Test Site', 'http://www.test.com/');
            
            ts2__Job__c  job1     = testData.getAJob(accnt.Id, clientContact.Id, market.Id,sit.Id);
            
            Contact candidate    = testData.getACandidate('TestCandidate');  
            candidate.email      = 'canemail@email.test.com';
            candidate.EMP_NUM__c = '555';
            update candidate;
            
            List<tc9_ti__PayCodeMaster__c> paycodes = new List<tc9_ti__PayCodeMaster__c>(); 
            paycodes.add(new tc9_ti__PayCodeMaster__c(Name='Paycode 1',tc9_ti__Paycode__c = 'REG',  Paycom_Earning_Code__c ='REG'));
            paycodes.add(new tc9_ti__PayCodeMaster__c(Name='Paycode 2',tc9_ti__Paycode__c = 'OT',   Paycom_Earning_Code__c ='OT'));
            paycodes.add(new tc9_ti__PayCodeMaster__c(Name='Paycode 3',tc9_ti__Paycode__c = 'DT',   Paycom_Earning_Code__c ='DT'));
            insert paycodes;
            
            tc9_ti__Award_Master__c awrdMaster = new tc9_ti__Award_Master__c();
            awrdMaster.tc9_ti__Ordinary_Weekly_Hours__c    = 12.5;
            awrdMaster.tc9_ti__Minimum_Weekly_Paid_Hours__c   = 10;
            awrdMaster.tc9_ti__Minimum_Sunday_Paid_Hours__c   = 2;
            awrdMaster.tc9_ti__Minimum_Saturday_Paid_Hours__c  = 1;
            awrdMaster.tc9_ti__Minimum_Public_Holiday_Paid_Hours__c = 1;
            awrdMaster.tc9_ti__Interpret_On_Weekly_Totals__c   = true;
            awrdMaster.tc9_ti__Hourly_Standard_Rate__c    = 10;
            insert awrdMaster;
    
            ts2__Placement__c plcRec1  = testData.getAPlacement(job1, null, candidate.Id, plcStartDate, plcEndDate, awrdMaster.Id, 'Temp'); 
            plcRec1.tc9_ti__Base_Pay_Rate__c = 22;
            update plcRec1;
            
            //cloning the existing placement
            ts2__Placement__c plcRec2 = plcRec1.clone();
            plcRec2.tc9_ti__Base_Pay_Rate__c = 10;
            insert plcRec2;
            system.assertNotEquals(null, plcRec2.Id);
            system.assertEquals(10,plcRec2.tc9_ti__Base_Pay_Rate__c);
            
            ts2__Placement__c plcRec3 = plcRec1.clone();
            plcRec3.tc9_ti__Base_Pay_Rate__c = 15;
            insert plcRec3;
            system.assertNotEquals(null, plcRec3.Id);
            system.assertEquals(10,plcRec2.tc9_ti__Base_Pay_Rate__c);
            
             //till next friday
            //creating the necessary transaction records
            tc9_ti__Transaction__c testTransactionRec  = new tc9_ti__Transaction__c();
            List<tc9_ti__Transaction__c> tranlist = new List<tc9_ti__Transaction__c>();
            
            Id TranExpRecordTypeId = [Select r.SobjectType, r.DeveloperName, r.Name From RecordType r where r.SobjectType = 'tc9_ti__Transaction__c' and DeveloperName != 'Temp' and DeveloperName != 'Payroll' limit 1 ].Id;
            for (integer i = 0; i < 15; i++)
            {
                tc9_ti__Transaction__c tran = new tc9_ti__Transaction__c(tc9_ti__EntryDate__c = plcStartDate.addDays(i), 
                tc9_ti__SentToPayroll__c = '',
                tc9_ti__Adjusted_PayRate__c = 30,tc9_ti__PayRate__c = 30, tc9_ti__HoursActutal__c = 1,  tc9_ti__Multiplier__c = 1); 
                tran.Payroll_Extract_Status__c  = 'New';
                tran.Payroll_Extract_First_Run__c = Date.today().addDays(-35);
                tran.tc9_ti__EntryDate__c = Date.today();
                if(i>5 && i<10)
                {
                    //tran.RecordTypeId = Map_Of_RecordtypeId_to_Name.get('Temp');
                    tran.RecordTypeId = TranExpRecordTypeId;
                    tran.tc9_ti__Placement__c = plcRec2.id;
                    
                    
                    if(i==6)
                    {
                        tran.tc9_ti__Paycode__c = 'REG';
                    }
                    else if(i==7)
                    {
                        tran.tc9_ti__Paycode__c = 'OT';
                    }
                    else
                    {
                        tran.tc9_ti__Paycode__c = 'DT';
                    }
                }
                else if(i<5)
                {
                    //tran.RecordTypeId = Map_Of_RecordtypeId_to_Name.get('Payroll');
                    tran.RecordTypeId = TranExpRecordTypeId;
                    tran.tc9_ti__Placement__c = plcRec3.id;
                    
                    if(i==1)
                    {
                        tran.tc9_ti__Paycode__c = 'REG';
                    }
                    else if(i==2)
                    {
                        tran.tc9_ti__Paycode__c = 'OT';
                    }
                    else
                    {
                        tran.tc9_ti__Paycode__c = 'DT';
                    }
                }
                else
                {
                    tran.RecordTypeId = TranExpRecordTypeId;
                    tran.tc9_ti__Placement__c = plcRec1.id;
                    
                    if(i==11)
                    {
                        tran.tc9_ti__Paycode__c = 'REG';
                    }
                    else if(i==12)
                    {
                        tran.tc9_ti__Paycode__c = 'OT';
                    }
                    else
                    {
                        tran.tc9_ti__Paycode__c = 'DT';
                    }
                }
                
                tranlist.add(tran);
            }
            
            insert tranlist;
            
            List<Id> insertedIds = new List<Id>();
            
            for(Integer i =0;i<tranlist.size();i++)
            {
                insertedIds.add(tranlist.get(i).Id);
            }
        
            //test the trg_Transaction that copies the Paycom_Earning_Code__c of paycodeMaster__c object record based on the paycode code
            boolean transAvailable = false;
            for(tc9_ti__Transaction__c transRec : [Select  t.tc9_ti__Placement__r.RecordtypeId,t.tc9_ti__Paycode__c,  t.Paycom_Earning_Code__c, tc9_ti__HoursActutal__c, t.tc9_ti__Placement__r.tc9_ti__Base_Pay_Rate__c, t.tc9_ti__Placement__c, t.tc9_ti__Placement__r.ts2__Employee__c,t.tc9_ti__EntryDate__c,t.Payroll_Extract_First_Run__c,t.Payroll_Extract_Last_Run__c,t.Payroll_Extract_Status__c From tc9_ti__Transaction__c t where t.tc9_ti__Placement__c != null and t.tc9_ti__Placement__c != '' and Id in :insertedIds])
            {
                transAvailable = true;
                //system.assertEquals(transRec.tc9_ti__Paycode__c, transRec.Paycom_Earning_Code__c);
            }   
            system.assertEquals(true, transAvailable);
            
            //setting current page reference to Payroll generator
            PageReference testpageRef = new PageReference('/apex/payrollGenerator');
            Test.setCurrentPageReference(testpageRef);
            PayrollExtraction_cntrl payrollController = new PayrollExtraction_cntrl();
            
            //testing without any values for the dates (From and To date)
             payrollController.extractInformation();
            
            //first we test with from and to date to be the same value
            payrollController.dummyTransaction.StartDate__c  = Date.Today();
            payrollController.dummyTransaction.EndDate__c  =  Date.Today();
            payrollController.dummyTransaction_for_previousExtracts.StartDate__c = Date.Today().addDays(-4);     
            payrollController.extractInformation();
           // system.assertEquals(1,Apexpages.getMessages().size());
            
            //Now we test with the from date greater than to date
            payrollController.dummyTransaction.StartDate__c  = Date.Today().addDays(1);
            payrollController.dummyTransaction.EndDate__c  = Date.Today(); 
            payrollController.dummyTransaction_for_previousExtracts.StartDate__c = Date.Today().addDays(-4);     
            payrollController.extractInformation();
           // system.assertEquals(2,Apexpages.getMessages().size());
            
            //Now we test with just the from date value
            payrollController.dummyTransaction.StartDate__c  =  Date.Today().addDays(-3);
            payrollController.dummyTransaction.EndDate__c  = null;   
            payrollController.dummyTransaction_for_previousExtracts.StartDate__c = Date.Today().addDays(-4);  
            payrollController.dummyTransaction_for_previousExtracts.EndDate__c  =  Date.Today();   
            payrollController.extractInformation();
            //system.assertEquals(2,Apexpages.getMessages().size());//No new page message as the date values are provided
            
            //Now we give the correct from and to date values with equal previous extract date values
            payrollController.dummyTransaction.StartDate__c  =  Date.Today().addDays(-3);
            payrollController.dummyTransaction.EndDate__c  =  Date.Today();
            payrollController.dummyTransaction_for_previousExtracts.StartDate__c = Date.Today();     
            payrollController.dummyTransaction_for_previousExtracts.EndDate__c  =  Date.Today();
            payrollController.extractInformation();
            
            //Now we give the correct from and to date values with only from extract date values
            payrollController.dummyTransaction.StartDate__c  =  Date.Today().addDays(-3);
            payrollController.dummyTransaction.EndDate__c  =  Date.Today();
            payrollController.dummyTransaction_for_previousExtracts.StartDate__c = Date.Today().addDays(+4);     
            payrollController.dummyTransaction_for_previousExtracts.EndDate__c  =  Date.Today();     
            payrollController.extractInformation();
            
            //Now we give the correct from and to date values along with correct extract date values
            payrollController.dummyTransaction.StartDate__c  =  Date.Today().addDays(-3);
            payrollController.dummyTransaction.EndDate__c  =  Date.Today();
            payrollController.dummyTransaction_for_previousExtracts.StartDate__c = Date.Today().addDays(-4);     
            payrollController.dummyTransaction_for_previousExtracts.EndDate__c  =  Date.Today();
            //payrollController.dummyTransaction_for_previousExtracts.EndDate__c = Date.Today().addDays(0); 
            payrollController.extractInformation();
            //system.assertEquals(2,Apexpages.getMessages().size());//No new page message as the date values are provided
            
        }
    
        //test method for VF Page controller 
        //(for case: NO EMPLOYEE NUMBER)
        static testmethod void testPageController1 ()
        {
            ToC9_TestDataDump testData = new ToC9_TestDataDump();
            Date plcStartDate    = date.parse('12/10/2012');
            Date plcEndDate      = plcStartDate.addDays(9);  //placement spanning two weeks (till 01/08/2012)
            
            tc9_ti__TaxID__c taxID  = testData.getTaxID();
            tc9_ti__Market__c market= testData.getMarket(taxID.Id);  
            Account accnt      = testData.getAClientAccount(market.Id);
            Contact clientContact  = testData.getAClientContact(accnt.Id);
            
            tc9_ti__Site__c sit    = testData.getASite('Test Site', 'http://www.test.com/');
            
            ts2__Job__c  job1     = testData.getAJob(accnt.Id, clientContact.Id, market.Id,sit.Id);
            
            Contact candidate    = testData.getACandidate('TestCandidate');  
            candidate.email      = 'canemail@email.test.com';
            //candidate.EMP_NUM__c = '555';
            update candidate;
            
            List<tc9_ti__PayCodeMaster__c> paycodes = new List<tc9_ti__PayCodeMaster__c>(); 
            paycodes.add(new tc9_ti__PayCodeMaster__c(Name='Paycode 1',tc9_ti__Paycode__c = 'REG',  Paycom_Earning_Code__c ='REG'));
            paycodes.add(new tc9_ti__PayCodeMaster__c(Name='Paycode 2',tc9_ti__Paycode__c = 'OT',   Paycom_Earning_Code__c ='OT'));
            paycodes.add(new tc9_ti__PayCodeMaster__c(Name='Paycode 3',tc9_ti__Paycode__c = 'DT',   Paycom_Earning_Code__c ='DT'));
            insert paycodes;
            
            tc9_ti__Award_Master__c awrdMaster = new tc9_ti__Award_Master__c();
            awrdMaster.tc9_ti__Ordinary_Weekly_Hours__c    = 12.5;
            awrdMaster.tc9_ti__Minimum_Weekly_Paid_Hours__c   = 10;
            awrdMaster.tc9_ti__Minimum_Sunday_Paid_Hours__c   = 2;
            awrdMaster.tc9_ti__Minimum_Saturday_Paid_Hours__c  = 1;
            awrdMaster.tc9_ti__Minimum_Public_Holiday_Paid_Hours__c = 1;
            awrdMaster.tc9_ti__Interpret_On_Weekly_Totals__c   = true;
            awrdMaster.tc9_ti__Hourly_Standard_Rate__c    = 10;
            insert awrdMaster;
    
            ts2__Placement__c plcRec1  = testData.getAPlacement(job1, null, candidate.Id, plcStartDate, plcEndDate, awrdMaster.Id, 'Temp'); 
            plcRec1.tc9_ti__Base_Pay_Rate__c = 22;
            update plcRec1;
            
            //cloning the existing placement
            ts2__Placement__c plcRec2 = plcRec1.clone();
            plcRec2.tc9_ti__Base_Pay_Rate__c = 10;
            insert plcRec2;
            system.assertNotEquals(null, plcRec2.Id);
            system.assertEquals(10,plcRec2.tc9_ti__Base_Pay_Rate__c);
            
            ts2__Placement__c plcRec3 = plcRec1.clone();
            plcRec3.tc9_ti__Base_Pay_Rate__c = 15;
            insert plcRec3;
            system.assertNotEquals(null, plcRec3.Id);
            system.assertEquals(10,plcRec2.tc9_ti__Base_Pay_Rate__c);
            
             //till next friday
            //creating the necessary transaction records
            tc9_ti__Transaction__c testTransactionRec  = new tc9_ti__Transaction__c();
            List<tc9_ti__Transaction__c> tranlist = new List<tc9_ti__Transaction__c>();
            
            Id TranExpRecordTypeId = [Select r.SobjectType, r.DeveloperName, r.Name From RecordType r where r.SobjectType = 'tc9_ti__Transaction__c' and DeveloperName != 'Temp' and DeveloperName != 'Payroll' limit 1 ].Id;
            for (integer i = 0; i < 15; i++)
            {
                tc9_ti__Transaction__c tran = new tc9_ti__Transaction__c(tc9_ti__EntryDate__c = plcStartDate.addDays(i), 
                tc9_ti__SentToPayroll__c = '',
                tc9_ti__Adjusted_PayRate__c = 30,tc9_ti__PayRate__c = 30, tc9_ti__HoursActutal__c = 1,  tc9_ti__Multiplier__c = 1); 
                tran.Payroll_Extract_Status__c  = 'New';
                tran.Payroll_Extract_First_Run__c = Date.today().addDays(-35);
                tran.tc9_ti__EntryDate__c = Date.today();
                if(i>5 && i<10)
                {
                    //tran.RecordTypeId = Map_Of_RecordtypeId_to_Name.get('Temp');
                    tran.RecordTypeId = TranExpRecordTypeId;
                    tran.tc9_ti__Placement__c = plcRec2.id;
                    
                    
                    if(i==6)
                    {
                        tran.tc9_ti__Paycode__c = 'REG';
                    }
                    else if(i==7)
                    {
                        tran.tc9_ti__Paycode__c = 'OT';
                    }
                    else
                    {
                        tran.tc9_ti__Paycode__c = 'DT';
                    }
                }
                else if(i<5)
                {
                    //tran.RecordTypeId = Map_Of_RecordtypeId_to_Name.get('Payroll');
                    tran.RecordTypeId = TranExpRecordTypeId;
                    tran.tc9_ti__Placement__c = plcRec3.id;
                    
                    if(i==1)
                    {
                        tran.tc9_ti__Paycode__c = 'REG';
                    }
                    else if(i==2)
                    {
                        tran.tc9_ti__Paycode__c = 'OT';
                    }
                    else
                    {
                        tran.tc9_ti__Paycode__c = 'DT';
                    }
                }
                else
                {
                    tran.RecordTypeId = TranExpRecordTypeId;
                    tran.tc9_ti__Placement__c = plcRec1.id;
                    
                    if(i==11)
                    {
                        tran.tc9_ti__Paycode__c = 'REG';
                    }
                    else if(i==12)
                    {
                        tran.tc9_ti__Paycode__c = 'OT';
                    }
                    else
                    {
                        tran.tc9_ti__Paycode__c = 'DT';
                    }
                }
                
                tranlist.add(tran);
            }
            
            insert tranlist;
            
            List<Id> insertedIds = new List<Id>();
            
            for(Integer i =0;i<tranlist.size();i++)
            {
                insertedIds.add(tranlist.get(i).Id);
            }
        
            //test the trg_Transaction that copies the Paycom_Earning_Code__c of paycodeMaster__c object record based on the paycode code
            boolean transAvailable = false;
            for(tc9_ti__Transaction__c transRec : [Select  t.tc9_ti__Placement__r.RecordtypeId,t.tc9_ti__Paycode__c,  t.Paycom_Earning_Code__c, tc9_ti__HoursActutal__c, t.tc9_ti__Placement__r.tc9_ti__Base_Pay_Rate__c, t.tc9_ti__Placement__c, t.tc9_ti__Placement__r.ts2__Employee__c,t.tc9_ti__EntryDate__c,t.Payroll_Extract_First_Run__c,t.Payroll_Extract_Last_Run__c,t.Payroll_Extract_Status__c From tc9_ti__Transaction__c t where t.tc9_ti__Placement__c != null and t.tc9_ti__Placement__c != '' and Id in :insertedIds])
            {
                transAvailable = true;
                //system.assertEquals(transRec.tc9_ti__Paycode__c, transRec.Paycom_Earning_Code__c);
            }   
            system.assertEquals(true, transAvailable);
            
            //setting current page reference to Payroll generator
            PageReference testpageRef = new PageReference('/apex/payrollGenerator');
            Test.setCurrentPageReference(testpageRef);
            PayrollExtraction_cntrl payrollController = new PayrollExtraction_cntrl();
            
            //testing without any values for the dates (From and To date)
             payrollController.extractInformation();
            
            //first we test with from and to date to be the same value
            payrollController.dummyTransaction.StartDate__c  = Date.Today();
            payrollController.dummyTransaction.EndDate__c  =  Date.Today();
            payrollController.dummyTransaction_for_previousExtracts.StartDate__c = Date.Today().addDays(-4);     
            payrollController.extractInformation();
           // system.assertEquals(1,Apexpages.getMessages().size());
            
            //Now we test with the from date greater than to date
            payrollController.dummyTransaction.StartDate__c  = Date.Today().addDays(1);
            payrollController.dummyTransaction.EndDate__c  = Date.Today(); 
            payrollController.dummyTransaction_for_previousExtracts.StartDate__c = Date.Today().addDays(-4);     
            payrollController.extractInformation();
           // system.assertEquals(2,Apexpages.getMessages().size());
            
            //Now we test with just the from date value
            payrollController.dummyTransaction.StartDate__c  =  Date.Today().addDays(-3);
            payrollController.dummyTransaction.EndDate__c  = null;   
            payrollController.dummyTransaction_for_previousExtracts.StartDate__c = Date.Today().addDays(-4);  
            payrollController.dummyTransaction_for_previousExtracts.EndDate__c  =  Date.Today();   
            payrollController.extractInformation();
            //system.assertEquals(2,Apexpages.getMessages().size());//No new page message as the date values are provided
            
            //Now we give the correct from and to date values with equal previous extract date values
            payrollController.dummyTransaction.StartDate__c  =  Date.Today().addDays(-3);
            payrollController.dummyTransaction.EndDate__c  =  Date.Today();
            payrollController.dummyTransaction_for_previousExtracts.StartDate__c = Date.Today();     
            payrollController.dummyTransaction_for_previousExtracts.EndDate__c  =  Date.Today();
            payrollController.extractInformation();
            
            //Now we give the correct from and to date values with only from extract date values
            payrollController.dummyTransaction.StartDate__c  =  Date.Today().addDays(-3);
            payrollController.dummyTransaction.EndDate__c  =  Date.Today();
            payrollController.dummyTransaction_for_previousExtracts.StartDate__c = Date.Today().addDays(+4);     
            payrollController.dummyTransaction_for_previousExtracts.EndDate__c  =  Date.Today();     
            payrollController.extractInformation();
            
            //Now we give the correct from and to date values along with correct extract date values
            payrollController.dummyTransaction.StartDate__c  =  Date.Today().addDays(-3);
            payrollController.dummyTransaction.EndDate__c  =  Date.Today();
            payrollController.dummyTransaction_for_previousExtracts.StartDate__c = Date.Today().addDays(-4);     
            payrollController.dummyTransaction_for_previousExtracts.EndDate__c  =  Date.Today();
            //payrollController.dummyTransaction_for_previousExtracts.EndDate__c = Date.Today().addDays(0); 
            payrollController.extractInformation();
            //system.assertEquals(2,Apexpages.getMessages().size());//No new page message as the date values are provided
            
        }    
}