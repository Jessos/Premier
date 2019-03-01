global with sharing class InvoiceGenerator_Batch  implements Database.batchable<sObject>, Database.Stateful{
    public  Date fromDate;
    public  Date toDate;
    public list<Placement> Placement;
    list<Placement> list_placement = new list<Placement>();
    map<String, Placement> mapIdNPlace ;
    map<Id, Integer> acc_RefNumber;
    Integer refCount = 10000;
    
    public InvoiceGenerator_Batch(Date fromDateParam,Date toDateParam) 
    {   
        mapIdNPlace   = new  map<String, Placement>() ;
        acc_RefNumber   = new Map<Id, Integer>();
        
        //Map_Of_RecordtypeId_to_Name = new Map<Id,String>();
        //csv_rows_groupedBy_Employee = new Map<Id,List<csvRowWrapper>>();
        fromDate = fromDateParam;
        toDate   = toDateParam; 
        system.debug('from date--'+fromDate+'to date--'+toDate);
    }
    
    global Database.QueryLocator start(Database.batchableContext batchableContext)
   {
      system.debug('from date--'+fromDate+'to date--'+toDate);
      String queryString  = 'Select t.tc9_ti__Placement__r.PO_number__c, t.tc9_ti__InvoiceItem__r.tc9_ti__Consolidated_Line__r.tc9_ti__Consolidated_Invoice__r.name, t.tc9_ti__Unit__c, tc9_ti__Placement__r.Cost_Center__c, t.tc9_ti__TotalTax__c, t.tc9_ti__TotalPay__c, t.tc9_ti__TotalBill__c, t.tc9_ti__TotalBillIncTax__c,t.tc9_ti__Time_Sheet__c,t.tc9_ti__Time_Sheet__r.tc9_ti__End_Date__c, '; 
       queryString += 't.tc9_ti__Time_Sheet_Entry__c, t.tc9_ti__Taxable__c, t.tc9_ti__TaxRate__c, t.tc9_ti__TaxID__c,t.tc9_ti__Status__c, t.tc9_ti__SentToPayroll__c,'; 
       queryString += 't.tc9_ti__SentToPayRollDate__c, t.tc9_ti__Placement__c, t.tc9_ti__Paycode__c, t.Paycom_Earning_Code__c, t.tc9_ti__PaycodeRecordType__c, t.tc9_ti__PayRate__c, t.tc9_ti__Multiplier__c,';
       queryString += 't.tc9_ti__Market__c, t.tc9_ti__Invoiced__c,t.tc9_ti__InvoiceDate__c, t.tc9_ti__HoursActutal__c, t.tc9_ti__Expense__c, t.tc9_ti__EntryDate__c, t.tc9_ti__Description__c,';
       queryString += 't.tc9_ti__Bill_Multiplier__c, t.tc9_ti__BillRate__c, t.tc9_ti__Adjusted_PayRate__c, t.tc9_ti__Adjusted_BillRate__c,t.SystemModstamp, t.RecordTypeId, t.Name,'; 
       queryString += 't.Legacy_Transaction_ID__c, t.LastModifiedDate, t.LastModifiedById, t.IsDeleted,t.Id, t.CurrencyIsoCode, t.CreatedDate,t.tc9_ti__Placement__r.ts2__Client__c,t.tc9_ti__Placement__r.Department__c,';
       queryString += 't.tc9_ti__Placement__r.ts2__Client__r.Invoice_Delivery_Temps__c,t.tc9_ti__Placement__r.RecordType.Name,t.tc9_ti__Placement__r.RecordType.DeveloperName ,';
       queryString += 't.tc9_ti__Placement__r.ts2__Client__r.Name, t.tc9_ti__Placement__r.ts2__Hiring_Manager__c, t.tc9_ti__Placement__r.ts2__Hiring_Manager__r.Name, t.tc9_ti__Placement__r.ts2__Employee__r.Name,t.tc9_ti__Placement__r.ts2__Job__r.Name,t.tc9_ti__Placement__r.ts2__Job__r.CostCenter__c,tc9_ti__Placement__r.ts2__Client__r.BillingCity,';
       queryString += 'tc9_ti__Placement__r.ts2__Client__r.BillingState,tc9_ti__Placement__r.ts2__Client__r.BillingPostalCode,tc9_ti__Placement__r.ts2__Client__r.BillingCountry,';
       queryString += 'tc9_ti__Placement__r.ts2__Client__r.BillingStreet,tc9_ti__Placement__r.ts2__Accounts_Payable__r.Name,  tc9_ti__Placement__r.ts2__Client__r.ts2__Accounts_Payable__r.Name,t.CreatedById, ';
       queryString += 'tc9_ti__Placement__r.ts2__Job__r.tc9_ti__PurchaseOrderNumber__c,tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingCity, ';
       queryString += 'tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingState,tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingPostalCode,';
       queryString += 'tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingCountry,tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingStreet,';
       queryString += 'tc9_ti__Placement__r.Billing_Address_1__c, tc9_ti__Placement__r.Billing_Address_2__c, tc9_ti__Placement__r.Billing_State__c, tc9_ti__Placement__r.Billing_ZIP__c, tc9_ti__Placement__r.City__c,';
       queryString += 'tc9_ti__Placement__r.ts2__Client__r.ts2__Accounts_Payable__r.MailingCity,tc9_ti__Placement__r.ts2__Client__r.ts2__Accounts_Payable__r.MailingState,';
       queryString += 'tc9_ti__Placement__r.ts2__Client__r.ts2__Accounts_Payable__r.MailingPostalCode,tc9_ti__Placement__r.ts2__Client__r.ts2__Accounts_Payable__r.MailingCountry,';
       queryString += 'tc9_ti__Placement__r.ts2__Client__r.ts2__Accounts_Payable__r.MailingStreet,t.Invoice_Extract_First_Run__c,t.Invoice_Extract_Last_Run__c,t.Invoice_Extract_Status__c,';
       queryString += 't.tc9_ti__Placement__r.ts2__Employee__c From tc9_ti__Transaction__c t';
        //queryString += ' where t.tc9_ti__Placement__c != null and t.tc9_ti__Placement__c != \'\' ';
                   
       if(fromDate != null && toDate != null){
          queryString += ' where t.Invoice_Extract_First_Run__c = null '; 
          queryString += ' and t.tc9_ti__EntryDate__c >= :fromDate and t.tc9_ti__EntryDate__c <= :toDate '; 
       }
           
       else if(fromDate != null){
         queryString += ' where t.Invoice_Extract_First_Run__c = null '; 
         queryString += ' and t.tc9_ti__EntryDate__c >= :fromDate';

       }
   
      //add any filter conditions if    
      system.debug('query--'+queryString);             
      return Database.getQueryLocator(queryString);       
      //return null;       
   }
   
   global void execute(Database.BatchableContext batchableContext, List<tc9_ti__Transaction__c> scope) 
   {
       System.debug('debug_scope ---> ' + scope.size());
        String Customer='';
        Date TransactionDate;
        String ToBePrinted='';
        String BillToLine1='';
        String BillToLine2='';
        String BillToLine3='';
        String BillToLine4='';
        String Item='';
        String Description='';
        Decimal Quantity=0.0;
        Decimal Price=0.0;
        String ToBeEMailed='';
        String BillToCity='';
        String BillToState='';
        String BillToPostalCode='';
        String BillToCountry='';
        String ClassRef;
        String PONumber='';
        Decimal tempQuantity=0.0;
        String RefNumber;
        String dept;
        
        id placeidN;
    list<tc9_ti__Transaction__c> list_transact = new list<tc9_ti__Transaction__c>();                                                                 
        Map<id,list<tc9_ti__Transaction__c>> mapPlaceNTrans = new Map<id,list<tc9_ti__Transaction__c>>();
        map<String, Placement> mapitemNPlace = new map<String, Placement>();
        list<tc9_ti__Transaction__c> list_initial = new list<tc9_ti__Transaction__c>();
        list<tc9_ti__Transaction__c> list_REG ;
        list<tc9_ti__Transaction__c> list_DT = new list<tc9_ti__Transaction__c>();
        list<tc9_ti__Transaction__c> list_OT = new list<tc9_ti__Transaction__c>();
        list<tc9_ti__Transaction__c> list_transac = new list<tc9_ti__Transaction__c>(); 
        Placement TempPlacement = new Placement(placeidN,Customer,BillToLine1,ToBePrinted,item,Quantity,Description,Price,ToBeEMailed,BillToCity,BillToState,
                                                    BillToPostalCode,BillToCountry,BillToLine4,BillToLine3,BillToLine2,ClassRef,PONumber,RefNumber,'');
        list<tc9_ti__Transaction__c> list_formal = new list<tc9_ti__Transaction__c>();                                              
        
        list_transac = scope;
        
        for(tc9_ti__Transaction__c trans : list_transac){
          if(mapPlaceNTrans.containsKey(trans.tc9_ti__Placement__c))
            mapPlaceNTrans.get(trans.tc9_ti__Placement__c).add(trans);
          else
            mapPlaceNTrans.put(trans.tc9_ti__Placement__c, new List<tc9_ti__Transaction__c>{trans});
          
          if(!acc_RefNumber.containsKey(trans.tc9_ti__Placement__r.ts2__Client__c))
            acc_RefNumber.put(trans.tc9_ti__Placement__r.ts2__Client__c, ++refCount);
      }
    
      if(mapPlaceNTrans.size() >0){
          for(Id placeid : mapPlaceNTrans.keyset()){
              list_initial= mapPlaceNTrans.get(placeid);
              list_REG = new list<tc9_ti__Transaction__c>();
              list_DT=new list<tc9_ti__Transaction__c>();
              list_OT=new list<tc9_ti__Transaction__c>();
              String placeitem='';
              system.debug('list_initialllllll '+ list_initial);
              Set<Integer> regpriceSet = new Set<Integer>();
              Set<Integer> OTpriceSet = new Set<Integer>();
              Set<Integer> STpriceSet = new Set<Integer>();
              Set<Integer> DTpriceSet = new Set<Integer>();
              Set<Integer> HTLpriceSet = new Set<Integer>();

              for(tc9_ti__Transaction__c trans : list_initial){
                DateTime dt;
                system.debug('listtttt '+ trans.tc9_ti__Time_Sheet__r.tc9_ti__End_Date__c);
                if(trans.tc9_ti__Time_Sheet__r.tc9_ti__End_Date__c != null)
                  dt = Datetime.newInstance(trans.tc9_ti__Time_Sheet__r.tc9_ti__End_Date__c, Time.newInstance(0,0,0,0));
                  //string.containsIgnoreCase(searchStr)
                  system.debug('*** Transaction_ID ----------> ' + trans.Id );
                  system.debug('*** Paycom_Earning_Code ----------> ' + trans.Paycom_Earning_Code__c );
                  system.debug('*** Paycode ----------> ' + trans.tc9_ti__Paycode__c );
                  if((trans.Paycom_Earning_Code__c != null && trans.Paycom_Earning_Code__c.equalsIgnoreCase('RGT')) || (trans.tc9_ti__Paycode__c != null && trans.tc9_ti__Paycode__c.equalsIgnoreCase('RT'))){
                      System.debug('In_the_1st_if');
                      
                      if(trans.Invoice_Extract_First_Run__c == Null){
                          trans.Invoice_Extract_First_Run__c = DateTime.Now();
                      }
                      else{
                          trans.Invoice_Extract_Last_Run__c = DateTime.Now();
                      }
                    trans.Invoice_Extract_Status__c='Exported';
                  
                          if(trans.tc9_ti__Placement__r.RecordType.Name =='Payroll')                              
                              item='TEMPORARY PLACEMENT:Payroll Temp:Reg Hrs-Payroll';
                          else
                            item='TEMPORARY PLACEMENT:Core Temp:Reg Hrs';
                          
                          /*if(trans.tc9_ti__Placement__r.Cost_Center__c != null)
                            RefNumber = trans.tc9_ti__Placement__r.Cost_Center__c;
                          else
                            RefNumber = ''+acc_RefNumber.get(trans.tc9_ti__Placement__r.ts2__Client__c);
                          */
                          //PONumber= trans.tc9_ti__Placement__r.PO_number__c;
                          PONumber  = trans.tc9_ti__Placement__r.PO_number__c;
                          RefNumber = trans.tc9_ti__InvoiceItem__r.tc9_ti__Consolidated_Line__r.tc9_ti__Consolidated_Invoice__r.name;

                          Customer=trans.tc9_ti__Placement__r.ts2__Client__r.Name;
                          
                          if(trans.tc9_ti__Placement__r.ts2__Client__r.Invoice_Delivery_Temps__c =='Email'){
                            ToBeEMailed='Y';
                            ToBePrinted='N';
                          }
                          else if(trans.tc9_ti__Placement__r.ts2__Client__r.Invoice_Delivery_Temps__c =='Print' || trans.tc9_ti__Placement__r.ts2__Client__r.Invoice_Delivery_Temps__c == null){
                            ToBeEMailed='N';
                            ToBePrinted='Y';
                          }
                          else if(trans.tc9_ti__Placement__r.ts2__Client__r.Invoice_Delivery_Temps__c =='Both'){
                            ToBeEMailed='Y';
                            ToBePrinted='Y';
                          }
                          
                          BillToLine1   = Customer;
                          BillToLine2   = trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.Name;
                          if (trans.tc9_ti__Placement__r.Billing_Address_1__c != null ){
                            BillToLine3 = trans.tc9_ti__Placement__r.Billing_Address_1__c;
                            BillToLine4 = trans.tc9_ti__Placement__r.Billing_Address_2__c;
                            BillToCity=trans.tc9_ti__Placement__r.City__c;
                            BillToState=trans.tc9_ti__Placement__r.Billing_State__c;
                            BillToPostalCode=trans.tc9_ti__Placement__r.Billing_ZIP__c;
                            //BillToCountry=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingCountry;
                          }
                          else if(trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingStreet != null){
                            BillToLine3 = trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingStreet;
                            //BillToLine3 = trans.tc9_ti__Placement__r.Billing_Address_2__c;
                            BillToCity=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingCity;
                            BillToState=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingState;
                            BillToPostalCode=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingPostalCode;
                            //BillToCountry=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingCountry;
                          }
                          else{
                            BillToLine2 ='';BillToLine3 ='';BillToLine4 ='';BillToCity ='';BillToState ='';BillToPostalCode ='';
                          }
                          
                          dept = trans.tc9_ti__Placement__r.Department__c;
                          
                          ClassRef = trans.tc9_ti__Placement__r.RecordType.Name + ' Service';
                          Description = (dt==null ? '' : dt.format('MM/dd/yyyy')) + ' ' +  trans.tc9_ti__Placement__r.ts2__Employee__r.Name + ' - ' + trans.tc9_ti__Placement__r.ts2__Job__r.Name;
                          
                          if(trans.tc9_ti__BillRate__c != null && trans.tc9_ti__Bill_Multiplier__c != null)
                            Price=trans.tc9_ti__BillRate__c * trans.tc9_ti__Bill_Multiplier__c;
                          else
                            Price=0.0;
                          //regpriceSet.put(Price);
                          placeitem=placeid+'-'+item + '-' + trans.tc9_ti__Time_Sheet__r.tc9_ti__End_Date__c+Price;
                          
                          system.debug('PONumber==== '+PONumber);
                          system.debug('placeitemmmmm '+placeitem);
                          system.debug('mapitemNPlaceeee '+mapitemNPlace);
                          System.debug('******'+trans.tc9_ti__HoursActutal__c);
                          
                          tempPlacement=mapitemNPlace.get(placeitem);
                          if(tempPlacement != null && Price>0.0){
                              tempQuantity +=trans.tc9_ti__HoursActutal__c;
                              tempPlacement.Quantity += trans.tc9_ti__HoursActutal__c;
                              mapitemNPlace.put(placeitem,tempPlacement);
                              System.debug(Price+'$$************'+tempQuantity+'************'+tempPlacement.Quantity);
                          }
                          else if(tempPlacement == null && Price>0.0){
                              tempQuantity =trans.tc9_ti__HoursActutal__c ;
                              tempPlacement = new Placement(placeid,Customer,BillToLine1,ToBePrinted,item,tempQuantity,Description,Price,ToBeEMailed,BillToCity,BillToState,
                                                          BillToPostalCode,BillToCountry,BillToLine4,BillToLine3,BillToLine2,ClassRef,PONumber,RefNumber,dept);
                              mapitemNPlace.put(placeitem,tempPlacement);
                              System.debug(Price+'************'+tempQuantity+'************'+tempPlacement.Quantity);


                          }
                  }
                  else if((trans.Paycom_Earning_Code__c != null && trans.Paycom_Earning_Code__c.equalsIgnoreCase('DTT')) || (trans.tc9_ti__Paycode__c != null && trans.tc9_ti__Paycode__c.equalsIgnoreCase('DT'))){
					
                      System.debug('In_the_2nd_if');
                      
                        if(trans.Invoice_Extract_First_Run__c == Null){
                            trans.Invoice_Extract_First_Run__c = DateTime.Now();
                            }
                          else{
                            trans.Invoice_Extract_Last_Run__c = DateTime.Now();
                          }
                        
                        trans.Invoice_Extract_Status__c='Exported';
                        
                        if(trans.tc9_ti__Placement__r.RecordType.Name =='Payroll')
                          item='TEMPORARY PLACEMENT:Payroll Temp:Double Time-Payroll';
                        else
                          item='TEMPORARY PLACEMENT:Core Temp:Double Time';
                        /*  
                        if(trans.tc9_ti__Placement__r.Cost_Center__c!= null)
                          RefNumber = trans.tc9_ti__Placement__r.Cost_Center__c;
                        else
                          RefNumber = ''+acc_RefNumber.get(trans.tc9_ti__Placement__r.ts2__Client__c);
                        */
                        //PONumber= trans.tc9_ti__Placement__r.PO_number__c;
                        PONumber  = trans.tc9_ti__Placement__r.PO_number__c;
                        RefNumber = trans.tc9_ti__InvoiceItem__r.tc9_ti__Consolidated_Line__r.tc9_ti__Consolidated_Invoice__r.name;

                        Customer=trans.tc9_ti__Placement__r.ts2__Client__r.Name;
                        
                        if(trans.tc9_ti__BillRate__c != null && trans.tc9_ti__Bill_Multiplier__c != null)
                          Price=trans.tc9_ti__BillRate__c * trans.tc9_ti__Bill_Multiplier__c;
                        else
                          Price=0.0;
                                                
                        if(trans.tc9_ti__Placement__r.ts2__Client__r.Invoice_Delivery_Temps__c =='Email'){
                            ToBeEMailed='Y';
                            ToBePrinted='N';
                        }
                        else if(trans.tc9_ti__Placement__r.ts2__Client__r.Invoice_Delivery_Temps__c =='Print' || trans.tc9_ti__Placement__r.ts2__Client__r.Invoice_Delivery_Temps__c == null){
                            ToBeEMailed='N';
                            ToBePrinted='Y';
                        }
                        else if(trans.tc9_ti__Placement__r.ts2__Client__r.Invoice_Delivery_Temps__c =='Both'){
                            ToBeEMailed='Y';
                            ToBePrinted='Y';
                        }
                        
                        BillToLine1 = Customer;
                        BillToLine2 = trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.Name;
                        if (trans.tc9_ti__Placement__r.Billing_Address_1__c != null ){
                            BillToLine3 = trans.tc9_ti__Placement__r.Billing_Address_1__c;
                            BillToLine4 = trans.tc9_ti__Placement__r.Billing_Address_2__c;
                            BillToCity=trans.tc9_ti__Placement__r.City__c;
                            BillToState=trans.tc9_ti__Placement__r.Billing_State__c;
                            BillToPostalCode=trans.tc9_ti__Placement__r.Billing_ZIP__c;
                            //BillToCountry=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingCountry;
                        }
                        else if(trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingStreet != null){
                            BillToLine3 = trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingStreet;
                            //BillToLine3 = trans.tc9_ti__Placement__r.Billing_Address_2__c;
                            BillToCity=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingCity;
                            BillToState=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingState;
                            BillToPostalCode=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingPostalCode;
                            //BillToCountry=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingCountry;
                        }
                        else{
                            BillToLine2 ='';BillToLine3 ='';BillToLine4 ='';BillToCity ='';BillToState ='';BillToPostalCode ='';
                        }
                        
                        dept = trans.tc9_ti__Placement__r.Department__c;
                        
                        ClassRef = trans.tc9_ti__Placement__r.RecordType.Name + ' Service';

                        Description= (dt==null ? '' : dt.format('MM/dd/yyyy')) + ' ' +  trans.tc9_ti__Placement__r.ts2__Employee__r.Name + ' - ' + trans.tc9_ti__Placement__r.ts2__Job__r.Name;
                        placeitem=placeid+'-'+item + '-' + trans.tc9_ti__Time_Sheet__r.tc9_ti__End_Date__c+Price;
                        
                        tempPlacement=mapitemNPlace.get(placeitem);
                        if(tempPlacement != null && Price>0.0){
                                                          if(trans.tc9_ti__Bill_Multiplier__c>0)

                            tempQuantity +=trans.tc9_ti__HoursActutal__c;
                                                          if(trans.tc9_ti__Bill_Multiplier__c>0)

                            TempPlacement.Quantity += trans.tc9_ti__HoursActutal__c;
                            mapitemNPlace.put(placeitem,TempPlacement);
                            System.debug(tempQuantity+'222222222222'+TempPlacement.Quantity);

                        }
                        else if(tempPlacement == null && Price>0.0){
                            tempQuantity  = trans.tc9_ti__HoursActutal__c ;
                            TempPlacement = new Placement(placeid,Customer,BillToLine1,ToBePrinted,item,tempQuantity,Description,Price,ToBeEMailed,BillToCity,BillToState,
                                                        BillToPostalCode,BillToCountry,BillToLine4,BillToLine3,BillToLine2,ClassRef,PONumber,RefNumber,dept);
                            mapitemNPlace.put(placeitem,TempPlacement);
                        }
                  }
                  else if((trans.Paycom_Earning_Code__c != null && trans.Paycom_Earning_Code__c.equalsIgnoreCase('OTT')) || (trans.tc9_ti__Paycode__c != null && trans.tc9_ti__Paycode__c.equalsIgnoreCase('OT'))){
                    
					             System.debug('In_the_3rd_if');                      
                      
                      if(trans.Invoice_Extract_First_Run__c == Null){
                        trans.Invoice_Extract_First_Run__c = DateTime.Now();
                        }
                      else{
                        trans.Invoice_Extract_Last_Run__c = DateTime.Now();
                      }
                    
                      trans.Invoice_Extract_Status__c='Exported';
                      if(trans.tc9_ti__Placement__r.RecordType.Name =='Payroll')
                          item='TEMPORARY PLACEMENT:Payroll Temp:Overtime (1.5) - Payroll';
                        else
                          item='TEMPORARY PLACEMENT:Core Temp:Overtime (1.5)';
                        
                      if(trans.tc9_ti__HoursActutal__c != null)

                          Quantity +=trans.tc9_ti__HoursActutal__c ;
                      else
                          Quantity += 0;
                      System.debug('Quantity ========'+Quantity);
                        Customer=trans.tc9_ti__Placement__r.ts2__Client__r.Name;
                        PONumber  = trans.tc9_ti__Placement__r.PO_number__c;
                        RefNumber = trans.tc9_ti__InvoiceItem__r.tc9_ti__Consolidated_Line__r.tc9_ti__Consolidated_Invoice__r.name;

                        //PONumber= trans.tc9_ti__Placement__r.PO_number__c;
                        //PONumber = trans.tc9_ti__Consolidated_Invoice__r.name;
                        /*
                        if(trans.tc9_ti__Placement__r.Cost_Center__c != null)
                          RefNumber = trans.tc9_ti__Placement__r.Cost_Center__c;
                        else
                          RefNumber = ''+acc_RefNumber.get(trans.tc9_ti__Placement__r.ts2__Client__c);
                        */
                        if(trans.tc9_ti__Placement__r.ts2__Client__r.Invoice_Delivery_Temps__c =='Email'){
                            ToBeEMailed='Y';
                            ToBePrinted='N';
                        }
                        else if(trans.tc9_ti__Placement__r.ts2__Client__r.Invoice_Delivery_Temps__c =='Print' || trans.tc9_ti__Placement__r.ts2__Client__r.Invoice_Delivery_Temps__c == null){
                            ToBeEMailed='N';
                            ToBePrinted='Y';
                        }
                        else if(trans.tc9_ti__Placement__r.ts2__Client__r.Invoice_Delivery_Temps__c =='Both'){
                            ToBeEMailed='Y';
                            ToBePrinted='Y';
                        }
                        
                        BillToLine1 = Customer;
                        BillToLine2 = trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.Name;
                        if (trans.tc9_ti__Placement__r.Billing_Address_1__c != null ){
                            BillToLine3 = trans.tc9_ti__Placement__r.Billing_Address_1__c;
                            BillToLine4 = trans.tc9_ti__Placement__r.Billing_Address_2__c;
                            BillToCity=trans.tc9_ti__Placement__r.City__c;
                            BillToState=trans.tc9_ti__Placement__r.Billing_State__c;
                            BillToPostalCode=trans.tc9_ti__Placement__r.Billing_ZIP__c;
                            //BillToCountry=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingCountry;
                        }
                        else if(trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingStreet != null){
                            BillToLine3 = trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingStreet;
                            //BillToLine3 = trans.tc9_ti__Placement__r.Billing_Address_2__c;
                            BillToCity=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingCity;
                            BillToState=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingState;
                            BillToPostalCode=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingPostalCode;
                            //BillToCountry=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingCountry;
                        }
                        else{
                            BillToLine2 ='';BillToLine3 ='';BillToLine4 ='';BillToCity ='';BillToState ='';BillToPostalCode ='';
                        }
                        
                        dept = trans.tc9_ti__Placement__r.Department__c;
                        
                        ClassRef = trans.tc9_ti__Placement__r.RecordType.Name + ' Service';
                        
                        Description= (dt==null ? '' : dt.format('MM/dd/yyyy')) + ' ' +  trans.tc9_ti__Placement__r.ts2__Employee__r.Name + ' - ' + trans.tc9_ti__Placement__r.ts2__Job__r.Name;
                        if(trans.tc9_ti__BillRate__c != null && trans.tc9_ti__Bill_Multiplier__c != null)
                          Price=trans.tc9_ti__BillRate__c * trans.tc9_ti__Bill_Multiplier__c;
                        else
                          Price=0.0;
                        
                        placeitem=placeid+'-'+item + '-' + trans.tc9_ti__Time_Sheet__r.tc9_ti__End_Date__c+Price;
                        
                        tempPlacement=mapitemNPlace.get(placeitem);
                        if(tempPlacement != null && Price>0.0){
                                                        if(trans.tc9_ti__Bill_Multiplier__c>0)

                            tempQuantity +=trans.tc9_ti__HoursActutal__c;
                                                          if(trans.tc9_ti__Bill_Multiplier__c>0)

                            TempPlacement.Quantity += trans.tc9_ti__HoursActutal__c;
                            mapitemNPlace.put(placeitem,TempPlacement);
                           System.debug(tempQuantity+'3333333333333333'+TempPlacement.Quantity);

                        }
                        else if(tempPlacement == null && Price>0.0){
                          tempQuantity  = trans.tc9_ti__HoursActutal__c ;
                            TempPlacement = new Placement(placeid,Customer,BillToLine1,ToBePrinted,item,tempQuantity,Description,Price,ToBeEMailed,BillToCity,BillToState,
                                                        BillToPostalCode,BillToCountry,BillToLine4,BillToLine3,BillToLine2,ClassRef,PONumber,RefNumber,dept);
                            mapitemNPlace.put(placeitem,TempPlacement);
                        }
                  }
                  else if((trans.Paycom_Earning_Code__c != null && trans.Paycom_Earning_Code__c.equalsIgnoreCase('HLT')) || (trans.tc9_ti__Paycode__c != null && trans.tc9_ti__Paycode__c.containsIgnoreCase('Holiday'))){
                    
                      System.debug('In_the_4th_if');
                      
                        if(trans.Invoice_Extract_First_Run__c == Null){
                            trans.Invoice_Extract_First_Run__c = DateTime.Now();
                            }
                          else{
                            trans.Invoice_Extract_Last_Run__c = DateTime.Now();
                          }
                        
                        trans.Invoice_Extract_Status__c='Exported';
                        
                        if(trans.tc9_ti__Placement__r.RecordType.Name =='Payroll')
                          item='TEMPORARY PLACEMENT:Payroll Temp:Holiday Hrs-Payroll';
                        else
                          item='TEMPORARY PLACEMENT:Core Temp:Holiday';
                        /*  
                        if(trans.tc9_ti__Placement__r.Cost_Center__c != null)
                          RefNumber = trans.tc9_ti__Placement__r.Cost_Center__c;
                        else
                          RefNumber = ''+acc_RefNumber.get(trans.tc9_ti__Placement__r.ts2__Client__c);
                        */
                        //PONumber= trans.tc9_ti__Placement__r.PO_number__c;
                       
                        //PONumber = trans.tc9_ti__Consolidated_Invoice__r.name;
                        
                        PONumber  = trans.tc9_ti__Placement__r.PO_number__c;
                        RefNumber = trans.tc9_ti__InvoiceItem__r.tc9_ti__Consolidated_Line__r.tc9_ti__Consolidated_Invoice__r.name;

                        Customer=trans.tc9_ti__Placement__r.ts2__Client__r.Name;
                        
                        if(trans.tc9_ti__BillRate__c != null && trans.tc9_ti__Bill_Multiplier__c != null)
                          Price=trans.tc9_ti__BillRate__c * trans.tc9_ti__Bill_Multiplier__c;
                        else
                          Price=0.0;
                                                
                        if(trans.tc9_ti__Placement__r.ts2__Client__r.Invoice_Delivery_Temps__c =='Email'){
                            ToBeEMailed='Y';
                            ToBePrinted='N';
                        }
                        else if(trans.tc9_ti__Placement__r.ts2__Client__r.Invoice_Delivery_Temps__c =='Print' || trans.tc9_ti__Placement__r.ts2__Client__r.Invoice_Delivery_Temps__c == null){
                            ToBeEMailed='N';
                            ToBePrinted='Y';
                        }
                        else if(trans.tc9_ti__Placement__r.ts2__Client__r.Invoice_Delivery_Temps__c =='Both'){
                            ToBeEMailed='Y';
                            ToBePrinted='Y';
                        }
                        
                        BillToLine1 = Customer;
                        BillToLine2 = trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.Name;
                        if (trans.tc9_ti__Placement__r.Billing_Address_1__c != null ){
                            BillToLine3 = trans.tc9_ti__Placement__r.Billing_Address_1__c;
                            BillToLine4 = trans.tc9_ti__Placement__r.Billing_Address_2__c;
                            BillToCity=trans.tc9_ti__Placement__r.City__c;
                            BillToState=trans.tc9_ti__Placement__r.Billing_State__c;
                            BillToPostalCode=trans.tc9_ti__Placement__r.Billing_ZIP__c;
                            //BillToCountry=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingCountry;
                        }
                        else if(trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingStreet != null){
                            BillToLine3 = trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingStreet;
                            //BillToLine3 = trans.tc9_ti__Placement__r.Billing_Address_2__c;
                            BillToCity=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingCity;
                            BillToState=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingState;
                            BillToPostalCode=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingPostalCode;
                            //BillToCountry=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingCountry;
                        }
                        else{
                            BillToLine2 ='';BillToLine3 ='';BillToLine4 ='';BillToCity ='';BillToState ='';BillToPostalCode ='';
                        }
                        
                        dept = trans.tc9_ti__Placement__r.Department__c;
                        
                        ClassRef = trans.tc9_ti__Placement__r.RecordType.Name + ' Service';

                        Description= (dt==null ? '' : dt.format('MM/dd/yyyy')) + ' ' +  trans.tc9_ti__Placement__r.ts2__Employee__r.Name + ' - ' + trans.tc9_ti__Placement__r.ts2__Job__r.Name;
                        placeitem=placeid+'-'+item + '-' + trans.tc9_ti__Time_Sheet__r.tc9_ti__End_Date__c+Price;
                        
                        tempPlacement=mapitemNPlace.get(placeitem);
                        if(tempPlacement != null && Price>0.0){
                                                        if(trans.tc9_ti__Bill_Multiplier__c>0)

                            tempQuantity +=trans.tc9_ti__HoursActutal__c;
                                                          if(trans.tc9_ti__Bill_Multiplier__c>0)

                            TempPlacement.Quantity += trans.tc9_ti__HoursActutal__c;
                            mapitemNPlace.put(placeitem,TempPlacement);
                            System.debug(tempQuantity+'444444444444'+TempPlacement.Quantity);

                        }
                        else if(tempPlacement == null && Price>0.0){
                            tempQuantity  = trans.tc9_ti__HoursActutal__c ;
                            TempPlacement = new Placement(placeid,Customer,BillToLine1,ToBePrinted,item,tempQuantity,Description,Price,ToBeEMailed,BillToCity,BillToState,
                                                        BillToPostalCode,BillToCountry,BillToLine4,BillToLine3,BillToLine2,ClassRef,PONumber,RefNumber,dept);
                            mapitemNPlace.put(placeitem,TempPlacement);
                        }
                  }
                  else if(((trans.Paycom_Earning_Code__c != null && trans.Paycom_Earning_Code__c.equalsIgnoreCase('STT')) || (trans.tc9_ti__Paycode__c != null && trans.tc9_ti__Paycode__c.equalsIgnoreCase('Sick'))) && (!trans.tc9_ti__Placement__r.RecordType.Name.containsIgnoreCase('Temp'))){
                    
                      System.debug('In_the_last_if');
                      
                        if(trans.Invoice_Extract_First_Run__c == Null){
                            trans.Invoice_Extract_First_Run__c = DateTime.Now();
                            }
                          else{
                            trans.Invoice_Extract_Last_Run__c = DateTime.Now();
                          }
                        
                        trans.Invoice_Extract_Status__c='Exported';
                        
                        if(trans.tc9_ti__Placement__r.RecordType.Name =='Payroll')
                          item='TEMPORARY PLACEMENT:Payroll Temp:Sick Hrs-Payroll';
                        else
                          item='TEMPORARY PLACEMENT:Payroll Temp:Sick Hrs';
                          
                       /* if(trans.tc9_ti__Placement__r.Cost_Center__c != null)
                          RefNumber = trans.tc9_ti__Placement__r.Cost_Center__c;
                        else
                          RefNumber = ''+acc_RefNumber.get(trans.tc9_ti__Placement__r.ts2__Client__c);
                        */
                        //PONumber= trans.tc9_ti__Placement__r.PO_number__c;
                        //RefNumber == trans.tc9_ti__Placement__r.PO_number__c;
                        //PONumber = trans.tc9_ti__Consolidated_Invoice__r.name;
                        PONumber  = trans.tc9_ti__Placement__r.PO_number__c;
                        RefNumber = trans.tc9_ti__InvoiceItem__r.tc9_ti__Consolidated_Line__r.tc9_ti__Consolidated_Invoice__r.name;

                        Customer=trans.tc9_ti__Placement__r.ts2__Client__r.Name;
                        
                        if(trans.tc9_ti__BillRate__c != null && trans.tc9_ti__Bill_Multiplier__c != null)
                          Price=trans.tc9_ti__BillRate__c * trans.tc9_ti__Bill_Multiplier__c;
                        else
                          Price=0.0;
                                                
                        if(trans.tc9_ti__Placement__r.ts2__Client__r.Invoice_Delivery_Temps__c =='Email'){
                            ToBeEMailed='Y';
                            ToBePrinted='N';
                        }
                        else if(trans.tc9_ti__Placement__r.ts2__Client__r.Invoice_Delivery_Temps__c =='Print' || trans.tc9_ti__Placement__r.ts2__Client__r.Invoice_Delivery_Temps__c == null){
                            ToBeEMailed='N';
                            ToBePrinted='Y';
                        }
                        else if(trans.tc9_ti__Placement__r.ts2__Client__r.Invoice_Delivery_Temps__c =='Both'){
                            ToBeEMailed='Y';
                            ToBePrinted='Y';
                        }
                        
                        BillToLine1 = Customer;
                        BillToLine2 = trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.Name;
                        if (trans.tc9_ti__Placement__r.Billing_Address_1__c != null ){
                            BillToLine3 = trans.tc9_ti__Placement__r.Billing_Address_1__c;
                            BillToLine4 = trans.tc9_ti__Placement__r.Billing_Address_2__c;
                            BillToCity=trans.tc9_ti__Placement__r.City__c;
                            BillToState=trans.tc9_ti__Placement__r.Billing_State__c;
                            BillToPostalCode=trans.tc9_ti__Placement__r.Billing_ZIP__c;
                            //BillToCountry=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingCountry;
                        }
                        else if(trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingStreet != null){
                            BillToLine3 = trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingStreet;
                            //BillToLine3 = trans.tc9_ti__Placement__r.Billing_Address_2__c;
                            BillToCity=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingCity;
                            BillToState=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingState;
                            BillToPostalCode=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingPostalCode;
                            //BillToCountry=trans.tc9_ti__Placement__r.ts2__Accounts_Payable__r.MailingCountry;
                        }
                        else{
                            BillToLine2 ='';BillToLine3 ='';BillToLine4 ='';BillToCity ='';BillToState ='';BillToPostalCode ='';
                        }
                        
                        dept = trans.tc9_ti__Placement__r.Department__c;
                        
                        ClassRef = trans.tc9_ti__Placement__r.RecordType.Name + ' Service';

                        Description= (dt==null ? '' : dt.format('MM/dd/yyyy')) + ' ' +  trans.tc9_ti__Placement__r.ts2__Employee__r.Name + ' - ' + trans.tc9_ti__Placement__r.ts2__Job__r.Name;
                        placeitem=placeid+'-'+item + '-' + trans.tc9_ti__Time_Sheet__r.tc9_ti__End_Date__c+Price;
                        
                        tempPlacement=mapitemNPlace.get(placeitem);                      	
                        if(tempPlacement != null && Price>0.0){
                                                        if(trans.tc9_ti__Bill_Multiplier__c>0)

                            tempQuantity +=trans.tc9_ti__HoursActutal__c;
                                                          if(trans.tc9_ti__Bill_Multiplier__c>0)

                            TempPlacement.Quantity += trans.tc9_ti__HoursActutal__c;
                            mapitemNPlace.put(placeitem,TempPlacement);
                            System.debug(tempQuantity+'55555555555555'+TempPlacement.Quantity);

                        }
                       else if(tempPlacement == null && Price>0.0){
                            tempQuantity  = trans.tc9_ti__HoursActutal__c ;
                            TempPlacement = new Placement(placeid,Customer,BillToLine1,ToBePrinted,item,tempQuantity,Description,Price,ToBeEMailed,BillToCity,BillToState,
                                                        BillToPostalCode,BillToCountry,BillToLine4,BillToLine3,BillToLine2,ClassRef,PONumber,RefNumber,dept);
                            mapitemNPlace.put(placeitem,TempPlacement);
                        }
                  }
                  
                  //for resetting values
                  /*trans.Invoice_Extract_First_Run__c = null;
                  trans.Invoice_Extract_Last_Run__c = null;
                  trans.Invoice_Extract_Status__c = null; */                 
                  
                  list_transact.add(trans);   
              }   
          } 
          
          System.debug('debug_mapitemNPlace ---> ' + mapitemNPlace.size());//0
          System.debug('debug_mapitemNPlace_values ---> ' + mapitemNPlace.values().size());//0
          
            if(mapitemNPlace.values().size()>0){
                for(String m : mapitemNPlace.keyset()){
                  Placement p  = mapitemNPlace.get(m);
                    if(!mapIdNPlace.containsKey(m)){
                        mapIdNPlace.put(m,p);
                  }
                  else{
                    Placement plc = mapIdNPlace.get(m);
                   
                    plc.Quantity += p.Quantity;
                    mapIdNPlace.put(m, plc);
                    System.debug('qUANTITY=='+ plc.Quantity);
                  }
                }
            }
        //tc9_ti.Transaction_Trigger_Utility.            
        if(list_transact != null && list_transact.size()>0){
                update list_transact;
             }
      }
       System.debug('debug_mapIdNPlace ---> ' + mapIdNPlace.size());//0
   }
   
    global void finish(Database.BatchableContext batchableContext)
   {  
      String bodyCSV = '';
      //bodyCSV += 'Placement,' ; 
      bodyCSV += 'Customer,' ;  
      bodyCSV += 'Transaction Date ,' ;  
      bodyCSV += 'RefNumber,' ;  
      bodyCSV += 'PO Number,' ;  
      bodyCSV += 'Terms,' ;  
      bodyCSV += 'Class,' ;  
      bodyCSV += 'Template Name,' ;  
      bodyCSV += 'To Be Printed,' ;  
      bodyCSV += 'Ship Date,' ;  
      bodyCSV += 'BillTo Line1,' ;  
      bodyCSV += 'BillTo Line2,' ;  
      bodyCSV += 'BillTo Line3,' ;  
      bodyCSV += 'BillTo Line4,' ;  
      bodyCSV += 'BillTo City,' ;  
      bodyCSV += 'BillTo State,' ;  
      bodyCSV += 'BillTo PostalCode,' ;  
      bodyCSV += 'BillTo Country,' ;  
      bodyCSV += 'ShipTo Line1,' ;  
      bodyCSV += 'ShipTo Line2,' ;  
      bodyCSV += 'ShipTo Line3,' ;  
      bodyCSV += 'ShipTo Line4,' ;  
      bodyCSV += 'ShipTo City,' ;  
      bodyCSV += 'ShipTo State,' ;  
      bodyCSV += 'ShipTo PostalCode,' ;  
      bodyCSV += 'ShipTo Country,' ;  
      bodyCSV += 'Phone,' ;  
      bodyCSV += 'Fax,' ;  
      bodyCSV += 'Email,' ;  
      bodyCSV += 'Contact Name,' ;  
      bodyCSV += 'First Name,' ;  
      bodyCSV += 'Last Name,' ; 
      bodyCSV += 'Rep,' ;  
      bodyCSV += 'Due Date,' ;  
      bodyCSV += 'Ship Method,' ;  
      bodyCSV += 'Customer Message,' ;  
      bodyCSV += 'Memo,' ;  
      bodyCSV += 'Item,' ;  
      bodyCSV += 'Quantity,' ;  
      bodyCSV += 'Description,' ;  
      bodyCSV += 'Price,' ;  
      bodyCSV += 'Temp,' ;
      bodyCSV += 'Is Pending,' ;  
      bodyCSV += 'Item Line Class,' ;  
      bodyCSV += 'Service Date,' ;  
      bodyCSV += 'FOB,' ;   
      bodyCSV += 'Customer Acct No,' ;  
      bodyCSV += 'Sales Tax Item,' ;  
      bodyCSV += 'To Be E-Mailed,' ;  
      bodyCSV += 'Other,' ;  
      bodyCSV += 'Other1,' ;  
      bodyCSV += 'Other2,' ;  
      bodyCSV += 'AR Account,' ;  
      bodyCSV += 'Sales Tax Code,';
      //inserting new line
      //bodyCSV += '\n';
        List<Placement> sortedPlacements = mapIdNPlace.values();
        mapIdNPlace.clear();
        sortedPlacements.sort();
       System.debug('debug_sortedPlacements ---> ' + sortedPlacements.size());//0
        for(Placement plac : sortedPlacements)
        { 
            
            //SC-3129 : Prevent transactions for 'Premier Staffing' from the extract. 
            //Note that the restriction is not done at query level, since we need fields like "First extracted" to be populated
            if(plac.Customer.startsWith('Premier Staffing'))    
                continue;
                
            //SC-3219
            plac.BillToLine4 = ((plac.BillToLine4 == 'US' || plac.BillToLine4 == '0') ? '' : plac.BillToLine4);
            
            //bodyCSV += '\n'+plac.PlacementId+',' ; 
            bodyCSV += '\n\"'+plac.Customer + '\",';
            bodyCSV += ' ,';
            bodyCSV += '\"'+plac.RefNumber + '\",';
            bodyCSV += '\"'+plac.PONumber  + '\",';
            bodyCSV += ' ,';
            bodyCSV += '\"'+plac.ClassRef + '\",';
            bodyCSV += ' ,';
            bodyCSV += '\"'+plac.ToBePrinted + '\",';
            bodyCSV += ' ,';
            bodyCSV += '\"'+ plac.BillToLine1 + '\",';
            bodyCSV += '\"'+ plac.BillToLine2 + '\",';
            bodyCSV += '\"'+ plac.BillToLine3 + '\",';
            bodyCSV += '\"'+ plac.BillToLine4 + '\",';
            bodyCSV += '\"'+ plac.BillToCity  + '\",';
            bodyCSV += '\"'+ plac.BillToState + '\",';
            bodyCSV += '\"'+ plac.BillToPostalCode + '\",';
            bodyCSV +=  ' ,';
            bodyCSV +=  ' ,';
            bodyCSV +=  ' ,';
            bodyCSV +=  ' ,';
            bodyCSV +=  ' ,';
            bodyCSV +=  ' ,';
            bodyCSV +=  ' ,';
            bodyCSV +=  ' ,';
            bodyCSV +=  ' ,';
            bodyCSV +=  ' ,';
            bodyCSV +=  ' ,';
            bodyCSV +=  ' ,';
            bodyCSV +=  ' ,';
            bodyCSV +=  ' ,';
            bodyCSV +=  ' ,';
            bodyCSV +=  ' ,';
            bodyCSV +=  ' ,';
            bodyCSV +=  ' ,';
            bodyCSV +=  ' ,';
            bodyCSV +=  ' ,';
            bodyCSV += '\"'+plac.Item + '\",';
            bodyCSV += '\"'+plac.Quantity + '\",';
            bodyCSV += '\"'+plac.Description.replace(',',' ') + '\",';
            bodyCSV += '\"'+plac.Price + '\",';
            bodyCSV += '\"'+plac.TempService + '\",';
            bodyCSV +=  ' ,';
            bodyCSV += '\"'+plac.ServiceDate + '\",';  
            bodyCSV +=  ' ,';          
            bodyCSV +=  ' ,';
            bodyCSV +=  ' ,';   
            bodyCSV +=  ' ,';   
            bodyCSV +=  '\"'+plac.ToBeEMailed + '\",';
            bodyCSV +=  ' ,';   
            bodyCSV +=  ' ,';       
            bodyCSV +=  ' ,';   
            bodyCSV +=  ' ,';
            bodyCSV +=  ' ,';
        }
      Document doc=new Document();
      doc.Name='InvoiceExtract_'+DateTime.now();
      doc.body=Blob.valueOf(bodycsv);
      
      //Selecting the folder where the document has to be stored 
      id folderid=[SELECT id,name from folder where developerName='Invoice_Extract'].id;
      doc.FolderId =folderid;
      doc.Contenttype = 'Text/csv';
      doc.Type='csv'; 
      insert doc;
   }
}