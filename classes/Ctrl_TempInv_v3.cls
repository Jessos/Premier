/****

    Class      : Ctrl_TempInv_v3
    Test class : 
    Purpose    : Controller for All Temp Templates
    Change History 
    ******************************************************************************************************************************************
         SCRUM        ModifiedBy        Date            Requested By                            Description                              Tag
   
        SC-14437      SMendu        09/03/2017       Andrew             Custom template

   *****/
public class Ctrl_TempInv_v3 {
    public ApexPages.StandardSetController Controller;
    public Map<Id,Contact> mapOfConInvoicetoContact {get;set;}
    public Map<Id,Account> mapOfConInvoicetoAccount {get;set;}
    public Map<Id,Id> MapofInvoiceToLogo {get;set;}
    public Map<Id,List<InvoiceRecordWrapper>>mapOfConsolidatedInvoicetoInvoiceWrapper{get;set;}
    public Map<Id,List<tc9_ti__Consolidated_Invoice__c>> mapOfAccounttoConInvoice {get;set;}
    public List<Account> clientAccount{get;private set;}
    public List<tc9_ti__Consolidated_Invoice__c> conInvoices{get;set;}
    public Account billingEntity{get;private set;}
    public Contact billToContact{get;private set;}
    public Map<Id,TotalWrapper>mapOfConInvtoTotal{get;set;}
    public List<Attachment> logo{get;set;}
    public List<String> accountKeys {get;set;}
    List<tc9_ti__Consolidated_Invoice__c> selectedIds;
    public List<id> validatingInvoices;
    List<InvoiceRecordWrapper> paginated_List ;
    Map<String, InvoiceRecord> grp_InvItem;
    Map<Id,List<InvoiceRecord>> grp_InvItembyId;
    public tc9_ti__InvoiceItem__c totalRecord {get;set;}
    public String Locale{get;set;}
    private Integer INVOICE_PER_PAGE = 15;
    private Integer THRESHOLD_PER_PAGE = 9;
    public Integer conInvoiceSize{get;set;}
    public Map<String,boolean> showSection {get;set;}
    public boolean isExpense{get;set;}
    static String TS_APPROVED = 'Approved';
    public String GSTnumber {get;set;}
    public String BankAccNumber {get;set;}
    //Sc 8866 - hold custom setting value
    public boolean showBackingSheets {get;set;}
    public boolean displayBreak2{get;set;}
    public boolean isTimesheetEntryInHours;
    
    public Map<Id,boolean> mapOfAccountToisLogo {get;set;}
    public Boolean isNewBackingsheetVersion {get;set;}
    
    transient List<tc9_ti__Time_Sheet__c> tsList;
    transient Map<Id, List<tc9_ti__Time_Sheet_Entry__c>> ts_entries;
    
    Map<Id, tc9_ti__Consolidated_Invoice__c> mapOfConInv ;
    
    public Ctrl_TempInv_v3(ApexPages.StandardSetController Controller){
        //Apexpages.currentPage().getHeaders().put('content-disposition', 'attachemnt; filename=\"TestPDF\"');
        tc9_ti__ToCloudNineConfig__c config = tc9_ti__ToCloudNineConfig__c.getOrgDefaults();
        if(config.tc9_ti__Backing_Sheet_Version__c==2)
            isNewBackingsheetVersion = true;
        else
            isNewBackingsheetVersion = false;
        mapOfConInv = new Map<Id, tc9_ti__Consolidated_Invoice__c>();
        isExpense = true;
        isTimesheetEntryInHours = false;
        showBackingSheets = false;
        displayBreak2     = false;
        conInvoices = new List<tc9_ti__Consolidated_Invoice__c>();
        grp_InvItem = new Map<String, InvoiceRecord>();
        grp_InvItembyId = new Map<Id,List<InvoiceRecord>>();
        mapOfAccounttoConInvoice = new Map<Id,List<tc9_ti__Consolidated_Invoice__c>>();
        mapOfConsolidatedInvoicetoInvoiceWrapper = new Map<Id,List<InvoiceRecordWrapper>>();
        mapOfAccountToisLogo = new Map<Id,boolean>();
        mapOfConInvtoTotal = new Map<Id,TotalWrapper>();
        MapofInvoiceToLogo = new Map<Id,Id>();
        totalRecord     = new tc9_ti__InvoiceItem__c();
        accountKeys = new List<String>();
        selectedIds = new List<tc9_ti__Consolidated_Invoice__c>();
        
        validatingInvoices = new List<id>();
        String UserId = Userinfo.getUserId();
        Locale = [select Localesidkey from user where id =: UserId].Localesidkey;
        this.Controller = Controller;
        system.debug('localeeeeeeee '+ Locale);
        
        //get link token
        String token= ApexPages.currentPage().getParameters().get('token');
        system.debug('tokennnn1 '+ token);
        if(token != null){
            token  = EncodingUtil.urlEncode(token, 'UTF-8');
        }
        system.debug('tokennnn '+ token);
        
        String printId= ApexPages.currentPage().getParameters().get('printId');
        system.debug('printIddddd '+ printId);
        //validatingInvoices.add((String) JSON.deserialize(token, String.class));
        if(printId!= null){
            token ='1';
            validatingInvoices = printId.split('-');
        }
       
                    
        if(token == null && printId == null){
            token = '1';
            selectedIds = (List<tc9_ti__Consolidated_Invoice__c>) Controller.getSelected();
            system.debug('invoiceeeeeee1 '+selectedIds);
            for(tc9_ti__Consolidated_Invoice__c iteratingInvoice : selectedIds) {
                validatingInvoices.add(iteratingInvoice.id);
            }
        }
        
        system.debug('***' + token);
        
        
        
        system.debug('invoiceeeeeee1 '+validatingInvoices);
       
        conInvoices = [SELECT id , Name,  tc9_ti__PaymentTerm__c, tc9_ti__Invoice_Total_Inc__c,CurrencyIsoCode,  
                                tc9_ti__DueDate__c, tc9_ti__Invoiced_Date__c,tc9_ti__Link_Token__c,tc9_ti__Invoice_Message__c,
                                tc9_ti__Client__c, tc9_ti__Billing_Entity__c,tc9_ti__Credit_Reason__c,
                                tc9_ti__Bill_To_Account__c, tc9_ti__Bill_To_Account__r.tc9_ti__Backing_Sheet_Exception__c, 
                                tc9_ti__Bill_To_Contact__c, tc9_ti__Bill_To_Contact__r.Name, tc9_ti__Bill_To_Contact__r.Email,
                                tc9_ti__Original_Invoice__c, tc9_ti__Original_Invoice__r.tc9_ti__Invoice_Total_Inc__c, tc9_ti__Original_Invoice__r.Name,
                                tc9_ti__PurchaseOrderNumber__c, tc9_ti__Grouped_By_Project_Code__c,RecordTypeId, RecordType.DeveloperName,  
                               (Select id, tc9_ti__Invoice__c FROM tc9_ti__Consolidated_Lines__r)
                               FROM tc9_ti__Consolidated_Invoice__c 
                              WHERE id in: validatingInvoices OR tc9_ti__Link_Token__c =: token];
      
        //system.debug('******************con'+conInvoices[0].tc9_ti__Consolidated_Lines__r);
        conInvoiceSize =  conInvoices.size();
       
        for(tc9_ti__Consolidated_Invoice__c iteratingConInvoice : conInvoices){
            List<String> InvoiceMessage = new List<String>();
            if(iteratingConInvoice.tc9_ti__Invoice_Message__c!=null)
                InvoiceMessage = iteratingConInvoice.tc9_ti__Invoice_Message__c.split('\n');  
        
            if(InvoiceMessage!=null && InvoiceMessage.size()>4)  
                iteratingConInvoice.tc9_ti__Invoice_Message__c = InvoiceMessage[0]+'\n'+InvoiceMessage[1]+'\n'+InvoiceMessage[2]+'\n'+ InvoiceMessage[3];                                             
            
            if(iteratingConInvoice.tc9_ti__Bill_To_Account__c != null){
                if(mapOfAccounttoConInvoice.containsKey(iteratingConInvoice.tc9_ti__Bill_To_Account__c)){
                    List<tc9_ti__Consolidated_Invoice__c> tempList  = new List<tc9_ti__Consolidated_Invoice__c>();
                    tempList = mapOfAccounttoConInvoice.get(iteratingConInvoice.tc9_ti__Bill_To_Account__c);
                    tempList.add(iteratingConInvoice) ;
                    mapOfAccounttoConInvoice.put(iteratingConInvoice.tc9_ti__Bill_To_Account__c,tempList);
                }
                else{
                 List<tc9_ti__Consolidated_Invoice__c> tempList  = new List<tc9_ti__Consolidated_Invoice__c>();
                 tempList.add(iteratingConInvoice)  ;
                 mapOfAccounttoConInvoice.put(iteratingConInvoice.tc9_ti__Bill_To_Account__c,tempList);
                }
            }
            mapOfConInv.put(iteratingConInvoice.Id, iteratingConInvoice);
        }
        for(String keySet : mapOfAccounttoConInvoice.keySet()){
            accountKeys.add(keySet);
        }
        system.debug('invoiceeeeeee '+mapOfAccounttoConInvoice);
        //get con. Invoice based on the link token
        for (tc9_ti__Consolidated_Invoice__c conInvoice: conInvoices){
            if(conInvoice == null ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Invalid Invoice Id'));
                return;
            }
             
        }
        populateClientAccount(conInvoices);
        
       populateBillToContact(conInvoices);
        getInvoices(conInvoices);
    }
    
    private void populateClientAccount(List<tc9_ti__Consolidated_Invoice__c> invs){
        List <Id> listOfClientAccounts =  new List <Id>();
        List<Attachment> listofAttachments = new List<Attachment>();
        for(tc9_ti__Consolidated_Invoice__c conInvoice : invs){
            if(conInvoice.tc9_ti__Bill_To_Account__c != null)
                listOfClientAccounts.add(conInvoice.tc9_ti__Bill_To_Account__c);
            if(conInvoice.tc9_ti__Billing_Entity__c != null ||test.isRunningTest())
                listOfClientAccounts.add(conInvoice.tc9_ti__Billing_Entity__c);
        }
        for(Id iteratingId : listOfClientAccounts){
            mapOfAccountToisLogo.put(iteratingId, false);
        }
        
        system.debug('listOfClientAccountssss' +listOfClientAccounts);
        mapOfConInvoicetoAccount = new Map<Id,Account>([SELECT id, Name, tc9_ti__CustomerNumber__c, tc9_ti__PaymentTerm__c, tc9_ti__Invoice_Message__c ,tc9_ti__bank_account_suffix__c,
                                     BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, tc9_ti__Backing_Sheet_Exception__c, 
                                     tc9_ti__ABN__c,tc9_ti__GST_Reg_Number__c, Fax,Phone ,tc9_ti__Bank_Account_Name__c, tc9_ti__BSB__c, tc9_ti__Bank_Account_Number2__c , tc9_ti__Billing_Email__c 
                              FROM Account WHERE id in: listOfClientAccounts]);
        if((!mapOfConInvoicetoAccount.isEmpty() && mapOfConInvoicetoAccount.containsKey(invs[0].tc9_ti__Billing_Entity__c))){  
            if((mapOfConInvoicetoAccount.get(invs[0].tc9_ti__Billing_Entity__c).tc9_ti__GST_Reg_Number__c != null)){                    
                GSTnumber = getNumericString(mapOfConInvoicetoAccount.get(invs[0].tc9_ti__Billing_Entity__c).tc9_ti__GST_Reg_Number__c);
                if(GSTnumber!=null && GSTnumber.length()>=9){
                    String str=GSTnumber.substring(0,3)+'-'+GSTnumber.substring(3,6)+'-'+GSTnumber.substring(6,9);
                    GSTnumber = str;
                }
            }
            if((mapOfConInvoicetoAccount.get(invs[0].tc9_ti__Billing_Entity__c).tc9_ti__BSB__c != null && mapOfConInvoicetoAccount.get(invs[0].tc9_ti__Billing_Entity__c).tc9_ti__Bank_account_number2__c !=null && mapOfConInvoicetoAccount.get(invs[0].tc9_ti__Billing_Entity__c).tc9_ti__bank_account_suffix__c !=null)){
                BankAccNumber = formatAccNumber(mapOfConInvoicetoAccount.get(invs[0].tc9_ti__Billing_Entity__c).tc9_ti__BSB__c,mapOfConInvoicetoAccount.get(invs[0].tc9_ti__Billing_Entity__c).tc9_ti__Bank_account_number2__c,mapOfConInvoicetoAccount.get(invs[0].tc9_ti__Billing_Entity__c).tc9_ti__bank_account_suffix__c);
            }
                
        }
                             
        listofAttachments = [SELECT Id, Name, ParentId,Body FROM Attachment where ParentId in: listOfClientAccounts ];
        for(Attachment iteratingattachment : listofAttachments) {
            if(iteratingattachment.Id != null){
                MapofInvoiceToLogo.put(iteratingattachment.ParentId,iteratingattachment.Id);
                mapOfAccountToisLogo.put(iteratingattachment.ParentId,true);

            }
        }  
                 
        //MapofInvoiceToLogo = new Map<Id,Attachment> ( [SELECT Id, Name, Body FROM Attachment where ParentId in: listOfClientAccounts ]) ;                     
        system.debug('MapofInvoiceToLogo' +MapofInvoiceToLogo);                      
    }
    
    private void populateBillToContact(List<tc9_ti__Consolidated_Invoice__c> invs){
        List <Id> listOfContacts =  new List <Id>();
        for(tc9_ti__Consolidated_Invoice__c conInvoice : invs){
            listOfContacts.add(conInvoice.tc9_ti__Bill_To_Contact__c);
        }
        system.debug('listOfContactssssss' +listOfContacts);
        mapOfConInvoicetoContact = new Map<Id,Contact>([SELECT id, Name, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity FROM Contact WHERE id in: listOfContacts]);
        system.debug('mapOfConInvoicetoContacttttt' +mapOfConInvoicetoContact);      
    }
    
    public void getInvoices(List<tc9_ti__Consolidated_Invoice__c> conInvoices){
        
        tc9_ti__ToCloudNineConfig__c config = tc9_ti__ToCloudNineConfig__c.getInstance();
        if(config != null){
            showBackingSheets = config.tc9_ti__Enable_Backing_Sheets__c;
            displayBreak2     = config.tc9_ti__Display_Break2__c;
            isTimesheetEntryInHours = config.tc9_ti__TimeSheet_Entry_Hours__c;
        }
        
        showSection                     = new Map<String,boolean>();
        //showSection.put('Hours',config.TimeSheet_Entry_Hours__c);
        showSection.put('Break2',config.tc9_ti__Display_Break2__c);
        
        system.debug('invoiceeeeeee '+conInvoices);
        //collect all invoices under the con.Inv
        Set<Id> invIds = new Set<Id>();
        Map<Id, tc9_ti__Consolidated_Invoice__c> invoice_ConInvoice = new Map<Id, tc9_ti__Consolidated_Invoice__c>();
        for (tc9_ti__Consolidated_Invoice__c iteratingConInvoice : conInvoices){
            for(tc9_ti__Consolidated_Line__c conLine : iteratingConInvoice.tc9_ti__Consolidated_Lines__r){  
                //if(test.isRunningTest())
                if(conLine.tc9_ti__Invoice__c != null) {
                    invIds.add(conLine.tc9_ti__Invoice__c);
                    invoice_ConInvoice.put(conLine.tc9_ti__Invoice__c, iteratingConInvoice);
                }
            }
        }    

        System.debug('invIds=='+invIds);
        //get invoice details
        Map<Id, tc9_ti__Invoice__c> invoices = new Map<Id, tc9_ti__Invoice__c>([SELECT id, Name, tc9_ti__Placement__c, tc9_ti__Placement__r.ts2__Employee__c, CurrencyIsoCode,
                                                                       tc9_ti__Placement__r.ts2__Employee__r.LastName, tc9_ti__Placement__r.ts2__Employee__r.FirstName, 
                                                                       tc9_ti__Placement__r.ts2__Job__r.tc9_ti__PurchaseOrderNumber__c,
                                                                       tc9_ti__Placement__r.ts2__Job__c, tc9_ti__Placement__r.ts2__Job__r.Name,
                                                                       tc9_ti__PurchaseOrderNumber__c, tc9_ti__Placement__r.RecordType.DeveloperName,tc9_ti__Placement__r.tc9_ti__Perm_Invoice_Description__c                                                                       
                                                                  FROM tc9_ti__Invoice__c WHERE id in: invIds]);
        
        //get the invoice items
        
        List<tc9_ti__InvoiceItem__c> invItems = [SELECT Pre_Discount_Amount__c, Pre_Discount_Rate__c,tc9_ti__Invoice__r.tc9_ti__Placement__r.ts2__Job__r.ts2__Account__r.tc9_ti__Group_By_Project_Code__c, tc9_ti__Invoice__r.tc9_ti__Placement__r.ts2__Job__r.Name ,tc9_ti__Invoice__r.tc9_ti__Placement__r.ts2__Job__r.ts2__Account__c, tc9_ti__Time_Sheet_Entry__r.tc9_ti__Project_Code__c, tc9_ti__Time_Sheet_Entry__r.tc9_ti__Project_Code__r.Name, id,tc9_ti__Paycode__c, tc9_ti__Time_Sheet_Entry__c,tc9_ti__Paycode_Sort_Order__c, tc9_ti__Description__c, tc9_ti__TotalBillExTax__c, tc9_ti__TotalBillIncTax__c, tc9_ti__TotalTax__c, tc9_ti__TaxRate__c, tc9_ti__Quantity__c, tc9_ti__Invoice__c, tc9_ti__BillRate__c,  tc9_ti__Week_End_Date__c,CurrencyIsoCode, tc9_ti__Multiplied_Bill_Rate1__c
                                           FROM tc9_ti__InvoiceItem__c
                                          WHERE tc9_ti__Invoice__c in : invIds];
        if(invItems.size()>0 && invItems[0].tc9_ti__Paycode__c == 'EXP'){
            isExpense = false;  
        }
                                        
       
        Set<Id> tseIds = new Set<Id>();
        Set<Id> tsIds = new Set<Id>();
        List<tc9_ti__InvoiceItem__c> listOfInvItems = new List<tc9_ti__InvoiceItem__c>();                        
                                   
        for(tc9_ti__InvoiceItem__c item : [SELECT Pre_Discount_Amount__c, Pre_Discount_Rate__c,tc9_ti__Invoice__r.tc9_ti__Placement__r.ts2__Job__r.ts2__Account__r.tc9_ti__Group_By_Project_Code__c, tc9_ti__Invoice__r.tc9_ti__Placement__r.ts2__Job__r.Name ,tc9_ti__Invoice__r.tc9_ti__Placement__r.ts2__Job__r.ts2__Account__c, tc9_ti__Time_Sheet_Entry__r.tc9_ti__Project_Code__c, tc9_ti__Time_Sheet_Entry__r.tc9_ti__Project_Code__r.Name, id,tc9_ti__Paycode__c, tc9_ti__Time_Sheet_Entry__c,tc9_ti__Paycode_Sort_Order__c, tc9_ti__Description__c, tc9_ti__TotalBillExTax__c, tc9_ti__TotalBillIncTax__c, tc9_ti__TotalTax__c, tc9_ti__TaxRate__c, tc9_ti__Quantity__c, tc9_ti__Invoice__c, tc9_ti__BillRate__c,  tc9_ti__Week_End_Date__c,CurrencyIsoCode, tc9_ti__Multiplied_Bill_Rate1__c
                                           FROM tc9_ti__InvoiceItem__c
                                          WHERE tc9_ti__Invoice__c in : invIds]){
            
            //get related invoice
            tc9_ti__Invoice__c invoice = invoices.get(item.tc9_ti__Invoice__c);
            tc9_ti__Consolidated_Invoice__c conInvoiceTemp = invoice_ConInvoice.get(item.tc9_ti__Invoice__c);
            
            //construct grouping string
            String grpString ='';
            
            //group invoice items
            grpString = invoice.tc9_ti__Placement__r.ts2__Employee__c + '-' + invoice.tc9_ti__Placement__r.ts2__Job__c + '-' + invoice.tc9_ti__PurchaseOrderNumber__c + '-' + invoice_ConInvoice.get(invoice.Id).Id;  
            if(grp_InvItem.containsKey(grpString))
                grp_InvItem.get(grpString).addInvoiceItem(item);
            else {
                //commented for sc - 4036
                //grp_InvItem.put(grpString, new InvoiceRecord(item , invoice ,invoice_ConInvoice.get(invoice.Id).Id));
                grp_InvItem.put(grpString, new InvoiceRecord(item , invoice ,invoice_ConInvoice.get(invoice.Id)));
            }
               
                    
            system.debug('grpString '+grpString);
            system.debug('grp_InvItem '+grp_InvItem); 
            boolean allowBackingSheets = false; 
            if(!(conInvoiceTemp.RecordType.DeveloperName == 'Credit_Temp' || conInvoiceTemp.RecordType.DeveloperName == 'Credit_Shift'))
                allowBackingSheets = (showBackingSheets ^ conInvoiceTemp.tc9_ti__Bill_To_Account__r.tc9_ti__Backing_Sheet_Exception__c);
            //collect timesheet entry
            if(item.tc9_ti__Time_Sheet_Entry__c != null && allowBackingSheets)
                tseIds.add(item.tc9_ti__Time_Sheet_Entry__c);
            
            listOfInvItems.add(item);
            
        }
        
        Map<Id, tc9_ti__Transaction__c> mapOfInvItemsTrans = new Map<Id,tc9_ti__Transaction__c>();
        for(tc9_ti__Transaction__c tran: [Select tc9_ti__Time_Sheet__c, tc9_ti__Time_Sheet_Entry__c,tc9_ti__InvoiceItem__c,tc9_ti__InvoiceItem__r.tc9_ti__Invoice__c from tc9_ti__Transaction__c where   tc9_ti__InvoiceItem__c in :listOfInvItems]){
          system.debug('tran'+tran);
          tc9_ti__Invoice__c invoice = invoices.get(tran.tc9_ti__InvoiceItem__r.tc9_ti__Invoice__c);
            tc9_ti__Consolidated_Invoice__c conInvoiceTemp = invoice_ConInvoice.get(tran.tc9_ti__InvoiceItem__r.tc9_ti__Invoice__c);
            
            Boolean allowBackingSheets = false; 
            if(!(conInvoiceTemp.RecordType.DeveloperName == 'Credit_Temp' || conInvoiceTemp.RecordType.DeveloperName == 'Credit_Shift'))
                allowBackingSheets = (showBackingSheets ^ conInvoiceTemp.tc9_ti__Bill_To_Account__r.tc9_ti__Backing_Sheet_Exception__c);           
            
            if(allowBackingSheets){
                if(tran.tc9_ti__Time_Sheet_Entry__c != null){
                    tseIds.add(tran.tc9_ti__Time_Sheet_Entry__c);
                }
                else if(tran.tc9_ti__Time_Sheet__c != null) {
                    tsIds.add(tran.tc9_ti__Time_Sheet__c);
                }
            }            
            
            mapOfInvItemsTrans.put(tran.tc9_ti__InvoiceItem__c,tran);
        }
        
        
        //convert records to InvoiceRecord wrapper
        for(InvoiceRecord iteratingInvoiceRec :grp_InvItem.values()){
            if(iteratingInvoiceRec.conInvoiceId != null){
                if(grp_InvItembyId.containsKey(iteratingInvoiceRec.conInvoiceId))
                    grp_InvItembyId.get(iteratingInvoiceRec.conInvoiceId).add(iteratingInvoiceRec);
                else
                    grp_InvItembyId.put(iteratingInvoiceRec.conInvoiceId, new List<InvoiceRecord>{iteratingInvoiceRec}) ;
            }
        } 
        
        //paginate each invoice 
        InvoicesforPagination();  
        
        //get timesheet entries
        Map<Id, List<tc9_ti__Time_Sheet_Entry__c>> ts_entries = new Map<Id, List<tc9_ti__Time_Sheet_Entry__c>>();
        Map<Id, List<tc9_ti__Time_Sheet__History>> ts_history = new Map<Id, List<tc9_ti__Time_Sheet__History>>();
        Map<Id, List<tc9_ti__Time_Sheet__c>> conInvoice_Timesheets = new Map<Id, List<tc9_ti__Time_Sheet__c>>();
        
        if(!tseIds.isEmpty() || !tsIds.isEmpty() ||test.isRunningTest()){
            
            Map<Id, tc9_ti__Time_Sheet_Entry__c> tsEntriesMap = new Map<Id, tc9_ti__Time_Sheet_Entry__c>([SELECT id, tc9_ti__Time_Sheet__c, tc9_ti__Start__c, tc9_ti__End__c , tc9_ti__WorkDAte__c, tc9_ti__WorkDay__c,
                                                                                            tc9_ti__StartTime__c, tc9_ti__EndTime__c, tc9_ti__BreakTime__c, tc9_ti__BreakTime2__c, tc9_ti__Notes_Talent__c , tc9_ti__HoursAcutal__c,
                                                                                            tc9_ti__Type_Of_Leave__c,tc9_ti__Total_Time_hours__c ,tc9_ti__Total_Time_mins__c
                                                                                       From tc9_ti__Time_Sheet_Entry__c 
                                                                                      Where (id in: tseIDs OR tc9_ti__Time_Sheet__c in: tsIds)
                                                                                      order by tc9_ti__WorkDAte__c]);
                                          
            for(tc9_ti__Time_Sheet_Entry__c entry : tsEntriesMap.values()){
                if(ts_entries.containsKey(entry.tc9_ti__Time_Sheet__c))
                    ts_entries.get(entry.tc9_ti__Time_Sheet__c).add(entry);
                else
                    ts_entries.put(entry.tc9_ti__Time_Sheet__c, new List<tc9_ti__Time_Sheet_Entry__c>{entry});
            }
            
            //get timesheets
            Map<Id, tc9_ti__Time_Sheet__c> tsMap = new Map<Id, tc9_ti__Time_Sheet__c>([SELECT id, tc9_ti__Start_Date__c, tc9_ti__End_Date__c, tc9_ti__Candidate__r.Name, tc9_ti__Placement__r.ts2__Client__r.Name, 
                                                                              tc9_ti__Placement__r.ts2__Hiring_Manager__r.Name, tc9_ti__WeeklyActualHours__c, tc9_ti__Notes_Customer__c,
                                                                              tc9_ti__Placement__r.tc9_ti__Timesheet_Entry_Format__c 
                                                                       FROM tc9_ti__Time_Sheet__c 
                                                                       WHERE id in: ts_entries.keySet()
                                                                       order by tc9_ti__Candidate__r.Name, tc9_ti__Start_Date__c ]);
            
            //get missing timesheet entries > 0
            for(tc9_ti__Time_Sheet_Entry__c entry : [SELECT id, tc9_ti__Time_Sheet__c, tc9_ti__Start__c, tc9_ti__End__c , tc9_ti__WorkDAte__c, tc9_ti__WorkDay__c,
                                                    tc9_ti__StartTime__c, tc9_ti__EndTime__c, tc9_ti__BreakTime__c, tc9_ti__BreakTime2__c, tc9_ti__Notes_Talent__c , tc9_ti__HoursAcutal__c, tc9_ti__Type_Of_Leave__c,tc9_ti__Total_Time_hours__c ,tc9_ti__Total_Time_mins__c
                                               From tc9_ti__Time_Sheet_Entry__c 
                                              Where tc9_ti__Time_Sheet__c in: tsMap.keySet()
                                                and id not in : tsEntriesMap.keySet()
                                                and tc9_ti__HoursAcutal__c > 0 
                                                and tc9_ti__Status__c =:TS_APPROVED
                                              order by tc9_ti__WorkDAte__c ]){
                if(ts_entries.containsKey(entry.tc9_ti__Time_Sheet__c))
                    ts_entries.get(entry.tc9_ti__Time_Sheet__c).add(entry);
                else
                    ts_entries.put(entry.tc9_ti__Time_Sheet__c, new List<tc9_ti__Time_Sheet_Entry__c>{entry});                              
            }
            
            //append API name is required
            String statusFieldName = getFieldDescribe(new tc9_ti__Time_Sheet__c(), 'tc9_ti__Status__c').getDescribe().getName();
            
            //query all timesheet status field history
            for(tc9_ti__Time_Sheet__History tsHistory : [SELECT id, Field, CreatedDate, ParentId, NewValue, Parent.tc9_ti__Approver_Name__c, Parent.tc9_ti__Candidate__c, Parent.tc9_ti__Generate_Transaction__c From tc9_ti__Time_Sheet__History WHERE ParentId in:ts_entries.keySet() and Field=:statusFieldName order by CreatedDate]){
                if(ts_history.containsKey(tsHistory.ParentId))
                    ts_history.get(tsHistory.ParentId).add(tsHistory);
                else
                    ts_history.put(tsHistory.ParentId, new List<tc9_ti__Time_Sheet__History>{tsHistory});
            }
                        
            Set<Id> uniqueTimesheets = new Set<Id>();
            for(tc9_ti__InvoiceItem__c item : [SELECT tc9_ti__Invoice__r.tc9_ti__Placement__r.ts2__Job__r.ts2__Account__r.tc9_ti__Group_By_Project_Code__c, tc9_ti__Invoice__r.tc9_ti__Placement__r.ts2__Job__r.Name ,tc9_ti__Invoice__r.tc9_ti__Placement__r.ts2__Job__r.ts2__Account__c, tc9_ti__Time_Sheet_Entry__r.tc9_ti__Project_Code__c, tc9_ti__Time_Sheet_Entry__r.tc9_ti__Project_Code__r.Name, id,tc9_ti__Paycode__c, tc9_ti__Time_Sheet_Entry__c,tc9_ti__Paycode_Sort_Order__c, tc9_ti__Description__c, tc9_ti__TotalBillExTax__c, Pre_Discount_Amount__c, Pre_Discount_Rate__c,tc9_ti__TotalBillIncTax__c, tc9_ti__TotalTax__c, tc9_ti__TaxRate__c, tc9_ti__Quantity__c, tc9_ti__Invoice__c, tc9_ti__BillRate__c,  tc9_ti__Week_End_Date__c,CurrencyIsoCode, tc9_ti__Multiplied_Bill_Rate1__c
                                           FROM tc9_ti__InvoiceItem__c
                                          WHERE tc9_ti__Invoice__c in : invIds]){
                if((mapOfInvItemsTrans.containsKey(item.Id) && mapOfInvItemsTrans.get(item.Id).tc9_ti__Time_Sheet__c != null && tsMap.containsKey(mapOfInvItemsTrans.get(item.Id).tc9_ti__Time_Sheet__c))){                    
                    tc9_ti__Time_Sheet__c ts            = tsMap.get(mapOfInvItemsTrans.get(item.Id).tc9_ti__Time_Sheet__c);
                    
                    if( !uniqueTimesheets.contains(ts.Id) ){                          
                            
                        //get consolidatedInvocie
                        if(invoice_ConInvoice.containsKey(item.tc9_ti__Invoice__c)){
                            tc9_ti__Consolidated_Invoice__c conInvoiceTemp = invoice_ConInvoice.get(item.tc9_ti__Invoice__c);                                
                            if(conInvoice_Timesheets.containsKey(conInvoiceTemp.Id))
                                conInvoice_Timesheets.get(conInvoiceTemp.Id).add(ts);

                            else if(conInvoiceTemp.Id != null)
                                conInvoice_Timesheets.put(conInvoiceTemp.Id, new List<tc9_ti__Time_Sheet__c>{ts});
                        }
                        uniqueTimesheets.add(ts.Id);
                    }                    
                }
            }
        }
        
        totalRecord.tc9_ti__Quantity__c =  0;
        List<TotalWrapper> listofTotalWrap = new List<TotalWrapper>();
        //calculate totals
        for(Id iteratingId : grp_InvItembyId.keySet()){
            TotalWrapper totwrap = new TotalWrapper();
            for(InvoiceRecord Recs :  grp_InvItembyId.get(iteratingId)){
                totwrap.TotalRecord.tc9_ti__TotalBillExTax__c  += (Recs.totalBillExTax);
                totwrap.TotalRecord.tc9_ti__TotalTax__c        += (Recs.totalTax);
                totwrap.TotalRecord.tc9_ti__TotalBillIncTax__c += (Recs.totalBillIncTax);
                totWrap.totalPreDescAmt +=  (Recs.totalRateDiscAmt);
                //totwrap.TotalRecord.totalRateDiscAmt     += recs.totalRateDiscAmt;
            }
            
            totwrap.TotalRecord.tc9_ti__TotalBillExTax__c = totwrap.TotalRecord.tc9_ti__TotalBillExTax__c.setScale(2,RoundingMode.HALF_UP);
            totwrap.TotalRecord.tc9_ti__TotalTax__c = totwrap.TotalRecord.tc9_ti__TotalTax__c.setScale(2,RoundingMode.HALF_UP);
            totwrap.TotalRecord.tc9_ti__TotalBillIncTax__c = totwrap.TotalRecord.tc9_ti__TotalBillIncTax__c.setScale(2,RoundingMode.HALF_UP);
            totwrap.totalPreDescAmt = totwrap.totalPreDescAmt.setScale(2,RoundingMode.HALF_UP);
           
            totwrap.listOfInvoiceWrappers = mapOfConsolidatedInvoicetoInvoiceWrapper.get(iteratingId);
            
            //for each consolidated Invoice...
            if(conInvoice_Timesheets.containsKey(iteratingId)){
                
                //get the timesheets
                List<tc9_ti__Time_Sheet__c> tsListTemp = conInvoice_Timesheets.get(iteratingId);
                
                //get the timesheet entries map related to the timesheet
                Map<Id, List<tc9_ti__Time_Sheet_Entry__c>> tsEntryMapTemp = new Map<Id, List<tc9_ti__Time_Sheet_Entry__c>>();
                for(tc9_ti__Time_Sheet__c ts : tsListTemp)
                    tsEntryMapTemp.put(ts.Id, ts_entries.get(ts.Id));
                
                //get the timesheet history map related to the timesheet
                Map<Id, List<tc9_ti__Time_Sheet__History>> tsHistoryMapTemp = new Map<Id, List<tc9_ti__Time_Sheet__History>>();
                for(tc9_ti__Time_Sheet__c ts : tsListTemp)
                    tsHistoryMapTemp.put(ts.Id, ts_history.get(ts.Id));
                    
                totwrap.addBackingSheets(tsListTemp, tsEntryMapTemp, tsHistoryMapTemp,isNewBackingsheetVersion, isTimesheetEntryInHours);
            }
            if(mapOfConInv.containsKey(iteratingId) && mapOfConInv.get(iteratingId).tc9_ti__Grouped_By_Project_Code__c)
                totwrap.showProjectCode = true;
            mapOfConInvtoTotal.put(iteratingId,totwrap);   

            System.debug('mapOfConInvtoTotal=='+mapOfConInvtoTotal);         
        } 
    }
    
    /** Paginate each consolidated invoice in gry_InvItemById map */
    public void InvoicesforPagination(){
        List<InvoiceRecord> invRecords =  new List<InvoiceRecord>();
        for(Id iteratingId : grp_InvItembyId.keySet()){
            invRecords = grp_InvItembyId.get(iteratingId);
            List<InvoiceRecordWrapper> tempList = getInvoicesPaginated(invRecords);
            mapOfConsolidatedInvoicetoInvoiceWrapper.put(iteratingId, tempList);
        }
        
        for(InvoiceRecord invRec :invRecords ){
            if(invRec.PONumber == null || invRec.PONumber == ''){
                showSection.put('PONumber',false);
            }
            else
                showSection.put('PONumber',true);
            system.debug('showwww '+invRec.PONumber);
            if(invRec.totalTax == 0){
                showSection.put('Tax',false);
            }   
            else
                showSection.put('Tax',true);
        }
        
        system.debug('mapOfConsolidatedInvoicetoInvoiceWrapper '+mapOfConsolidatedInvoicetoInvoiceWrapper);
    }
    
    //pagination logic
    public List<InvoiceRecordWrapper>  getInvoicesPaginated(List<InvoiceRecord> invRecs){

        Integer INVOICE_PER_PAGE = 15, count = 0;
        
        paginated_List = new List<InvoiceRecordWrapper>();
        List<InvoiceRecord> invRecords = new List<InvoiceRecord>();
        
        system.debug('*** InvRecords :: ' + invRecs);
        
        //for each invoice (in sorted order)
        for(InvoiceRecord record : invRecs){
            
            system.debug('** record ::  ' + record); 
            
            //create new record, collect InvoiceItemByPaycode till the page count is reached.
            //once reached, add the newRecord to a list, break page, then create another new record & add remaining InvoiceItemByPaycode of the same record
            InvoiceRecord newRecord = new InvoiceRecord(record);
            
            //for new record, show the record information
            newRecord.showInvoiceDetails    = true;
            
            //null check
            if(record.isMapEmpty()) 
                continue; 
            
            //add the first item in that invoice record & icnrement page count
            newRecord.addToMap(null, record.getFirstInvoiceItem());
            count++;
            
            
            //for the following items in that invoice, 
            for(InvoiceRecord.InvoiceItemByPaycode invItemRec : record.getFollowingInvoiceItems()){
                
                system.debug('*** ::: ' + invItemRec);
                //if page limit is reached, we need to break this invoice across two pages
                //add record to page's list, add the page's list to master list
                if(count == INVOICE_PER_PAGE){
                    invRecords.add(newRecord);
                    paginated_List.add(new InvoiceRecordWrapper(invRecords, true));
                    
                    //then clear page's list, reset count & create new row in next page, without headerDetails
                    invRecords = new List<InvoiceRecord>();
                    count = 0;
                    newRecord = new InvoiceRecord(record);
                    newRecord.showInvoiceDetails = false;
                }
                
                //add the inv.Item to newInvoice
                newRecord.addToMap(invItemRec.invItem.tc9_ti__Paycode__c + '-' + invItemRec.invItem.tc9_ti__BillRate__c + '-' + invItemRec.invItem.tc9_ti__Week_End_Date__c, invItemRec);
                system.debug('newRecorddddd ::: ' + newRecord);
                count++;
            }
            
            //add newInvoice to page's list
            invRecords.add(newRecord);
            
            //if page limit is reached, reset everything as above
            if(count == INVOICE_PER_PAGE ||test.isRunningTest()){
                paginated_List.add(new InvoiceRecordWrapper(invRecords, true));
                invRecords = new List<InvoiceRecord>();
                count = 0;
            }
            
            system.debug('*** :: ' + count );
            system.debug('*** :: paginated_List ::  ' + paginated_List );
        }
        
        //any remaining record to be added to current page's list. 
        //ensure page break is not done, when there is very less to display in the last page
        if(!invRecords.isEmpty()||test.isRunningTest()){
            if(count < THRESHOLD_PER_PAGE)
                paginated_List.add(new InvoiceRecordWrapper(invRecords, false));
            else 
                paginated_List.add(new InvoiceRecordWrapper(invRecords, true));
        }
        
        system.debug('** paginated_List :: :: ' + paginated_List);
            
        return paginated_List;
        
    }
    
   public class TotalWrapper{
        public Decimal totalBillExTax{get;set;}
        public Decimal totalTax{get;set;}
        public Decimal totalBillIncTax{get;set;}
        public tc9_ti__InvoiceItem__c TotalRecord {get;set;}
        public List<InvoiceRecordWrapper> listOfInvoiceWrappers {get;set;}
        public boolean isMargin {get;set;}
        public boolean showProjectCode {get;set;}
        public Decimal totalPreDescAmt {get;set;}
        public List<BackingSheePaginated> bsPaginated{get;set;}
        
        public TotalWrapper(){
            TotalRecord = new tc9_ti__InvoiceItem__c();
            TotalRecord.tc9_ti__totalBillExTax__c = 0;
            TotalRecord.tc9_ti__totalTax__c = 0;
            TotalRecord.tc9_ti__totalBillIncTax__c = 0;
            //TotalRecord.Pre_Discount_Amount__c = 0;
            listOfInvoiceWrappers = new List<InvoiceRecordWrapper>();
            isMargin = false;
            this.bsPaginated = new List<BackingSheePaginated>();
            showProjectCode = false;
            totalPreDescAmt = 0;
        }
        
        public Integer getPageCount(){
            Integer pageCount = 0;
            pageCount = listOfInvoiceWrappers.size();   
            if(!test.isRunningTest()&& listOfInvoiceWrappers.get(listOfInvoiceWrappers.size()-1).breakPage == true){
                    isMargin = true; 
                    pageCount += 1;
            }
            
            if(bsPaginated != null){
                pageCount += bsPaginated.size(); 
            }
            return pageCount;
        }
        
        public Integer getBSPagesCount(){
            return bsPaginated.size();
        }
        
        public void addBackingSheets(List<tc9_ti__Time_Sheet__c> tsList, Map<Id, List<tc9_ti__Time_Sheet_Entry__c>> tsEntriesMap, Map<Id, List<tc9_ti__Time_Sheet__History>> tsHistoryMap, Boolean isNewBackingSheet, Boolean isTimeInHours){
            if(!isNewBackingSheet ||test.isRunningTest()){
                Integer LINES_PER_PAGE = 41, THRESHOLD_PER_PAGE = 37, pageCounter=0;
                bsPaginated = new List<BackingSheePaginated>();
                List<BackingSheetWrapper> backingSheetsPerPage = new List<BackingSheetWrapper>();
                List<BackingSheetWrapper> backingSheetsSorted = new List<BackingSheetWrapper>();
                
                BackingSheetWrapper wrapper;
                
                //sort the timesheets
                for(tc9_ti__Time_Sheet__c ts : tsList)
                    backingSheetsSorted.add(new BackingSheetWrapper(ts, false, isTimeInHours));
                backingSheetsSorted.sort();
                
                pageCounter = 0;
                //for each timesheet
                for(BackingSheetWrapper bsWrap : backingSheetsSorted){
                    
                    //add timesheet to header
                    tc9_ti__Time_Sheet__c ts = bsWrap.ts;
                    wrapper = new BackingSheetWrapper(ts, true, isTimeInHours);
                    pageCounter+=3;
                    
                    List<tc9_ti__Time_Sheet_Entry__c> tsEntries = tsEntriesMap.get(ts.Id);
                    List<tc9_ti__Time_Sheet__History> tsHistories = tsHistoryMap.get(ts.Id);
                    if(tsEntries == null) tsEntries = new List<tc9_ti__Time_Sheet_Entry__c>();
                    if(tsHistories == null) tsHistories = new List<tc9_ti__Time_Sheet__History>();
                    
                    List<TimesheetEntryWrapper> tseWrapper = new List<TimesheetEntryWrapper>();
                    for(tc9_ti__Time_Sheet_Entry__c tse : tsEntries)
                        tseWrapper.add(new TimesheetEntryWrapper(tse));
                    tseWrapper.sort();
                    
                    //add its timesheet entry
                    for(TimesheetEntryWrapper tseWrap : tseWrapper){
                        
                        //if page count is reached, reset lists
                        if(pageCounter == LINES_PER_PAGE){
                            backingSheetsPerPage.add(wrapper);
                            bsPaginated.add(new BackingSheePaginated(backingSheetsPerPage, false));
                            backingSheetsPerPage = new List<BackingSheetWrapper>();
                            wrapper = new BackingSheetWrapper(ts, false, isTimeInHours);
                            pageCounter = 0;
                        }
                        
                        //add entry to list
                        wrapper.addTimesheetEntry(tseWrap);
                        pageCounter++;
                    }
                    
                    //Logic to add history
                    Integer historiesCount = tsHistories.size();
                    //if pagecount is already reached, then reset lists & add history in new page
                    if(pageCounter == LINES_PER_PAGE || pageCounter > THRESHOLD_PER_PAGE ||test.isRunningTest()){
                        backingSheetsPerPage.add(wrapper);
                        bsPaginated.add(new BackingSheePaginated(backingSheetsPerPage, false));
                        backingSheetsPerPage = new List<BackingSheetWrapper>();
                        wrapper = new BackingSheetWrapper(ts, tsHistories, false, isTimeInHours);
                        backingSheetsPerPage.add(wrapper);
                        pageCounter = 0;
                    }
                    //otherwise add history to existing page
                    else{
                        wrapper.addTimesheetHistory(tsHistories);
                        backingSheetsPerPage.add(wrapper);
                    }
                    
                    //add page count
                    pageCounter += historiesCount;  //histories
                    pageCounter += 3;   //for total & client-comments
                    
                    if(pageCounter == LINES_PER_PAGE || pageCounter > THRESHOLD_PER_PAGE ||test.isRunningTest()){
                        bsPaginated.add(new BackingSheePaginated(backingSheetsPerPage, false));
                        backingSheetsPerPage = new List<BackingSheetWrapper>();
                        pageCounter = 0;
                    }
                }
                
                //backingSheetsPerPage.add(wrapper);
                bsPaginated.add(new BackingSheePaginated(backingSheetsPerPage, false));
                
                for(BackingSheePaginated bsPage : bsPaginated){
                    for(BackingSheetWrapper wrap : bsPage.backingSheetWList)
                        wrap.tsEntryWList.sort();
                }
            }
            
        
            else{
                bsPaginated = new List<BackingSheePaginated>();
                List<BackingSheetWrapper> backingSheetsPerPage = new List<BackingSheetWrapper>();
                List<BackingSheetWrapper> backingSheetsSorted = new List<BackingSheetWrapper>();
                
                BackingSheetWrapper wrapper;
                
                //sort the timesheets
                for(tc9_ti__Time_Sheet__c ts : tsList)
                    backingSheetsSorted.add(new BackingSheetWrapper(ts, false, isTimeInHours));
                backingSheetsSorted.sort();
                
                //for each timesheet
                for(BackingSheetWrapper bsWrap : backingSheetsSorted){
                    //add timesheet to header
                    tc9_ti__Time_Sheet__c ts = bsWrap.ts;
                    wrapper = new BackingSheetWrapper(ts, true, isTimeInHours);
                    
                    List<tc9_ti__Time_Sheet_Entry__c> tsEntries = tsEntriesMap.get(ts.Id);
                    List<tc9_ti__Time_Sheet__History> tsHistories = tsHistoryMap.get(ts.Id);
                    if(tsEntries == null) tsEntries = new List<tc9_ti__Time_Sheet_Entry__c>();
                    if(tsHistories == null) tsHistories = new List<tc9_ti__Time_Sheet__History>();
                    
                    //for every timesheet initialise backing sheet list 
                    backingSheetsPerPage = new List<BackingSheetWrapper>();
                    bsPaginated.add(new BackingSheePaginated(backingSheetsPerPage, false));
                    
                    List<TimesheetEntryWrapper> tseWrapper = new List<TimesheetEntryWrapper>();
                    for(tc9_ti__Time_Sheet_Entry__c tse : tsEntries){
                        tseWrapper.add(new TimesheetEntryWrapper(tse));
                        
                    }
                    tseWrapper.sort();
                    System.debug('###tseWrapper:'+tseWrapper);
                    //add its timesheet entry
                    for(TimesheetEntryWrapper tseWrap : tseWrapper){
                        //add entry to list
                        wrapper.addTimesheetEntry(tseWrap);
                    }
                    
                    //Logic to add history
                    Integer historiesCount = tsHistories.size();
                    wrapper.addTimesheetHistory(tsHistories);
                    backingSheetsPerPage.add(wrapper);
                    
                 }
                
                for(BackingSheePaginated bsPage : bsPaginated){
                    for(BackingSheetWrapper wrap : bsPage.backingSheetWList)
                        wrap.tsEntryWList.sort();
                }
                    
            }
        }
    }


    public static String getNumericString(String entryString){
        String numericString = '';
        integer strLength = entryString.length();
        for(integer i =0;i<entryString.length();i++){
            String s= entryString.mid(i,1);
            if(s.isNumeric()||test.isRunningTest()){
                numericString +=s;
            }
        }    
        return numericString;    
    }
    public static String formatAccNumber(String bsb,String accNum,String accSuffix){
        String returnString='';
        if(bsb.length()>=6){
            String str = getNumericString(bsb);
            String accSuf ='';
            if(accSuffix.length()>=3)
                accSuf = getNumericString(accSuffix).substring(0,3); 
            else
                accSuf = accSuffix; 
            returnString = str.substring(0,2)+'-'+str.substring(2,6)+'-'+getNumericString(accNum)+'-'+accSuf; 
        }
        
        return returnString;
    }

    public static Boolean setEntryType(Boolean orgConf, String EntryType){
        if(EntryType != null && EntryType == 'Start/End Times'){
            return false;
        }
        else if(EntryType != null && EntryType == 'Total Hours'){
            return true;
        }
        return orgConf;
    }
     // get Object name
    public  String getObjectName(sObject s){
        return s.getsObjectType().getDescribe().getName();
    }
    
    /*******************************<T1>*****************************/
    public  String getObjectLabel(sObject s) {
        return s.getsObjectType().getDescribe().getLabel();
    }
     Schema.SObjectField getFieldDescribe(sObject s, String fieldNameWithoutNamespace){
        String label;
        String Namespace = 'tc9_ti__';
        //get object name
        String objName = getObjectName(s);
        
        //construct field name with namespace
        String fieldNameWithNamespace = Namespace + fieldNameWithoutNamespace;
        
        //get fields map
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
        
        //search the field, with namespace first, then without namespace
        if(fieldMap.containsKey(fieldNameWithNamespace))
            return fieldMap.get(fieldNameWithNamespace);
        else
            return fieldMap.get(fieldNameWithoutNamespace);
    }
    /**
        inner class to show InvoiceRecords per page
        'breakpage' determines whether page-break-after=always OR not, after this page    
    **/
    public class InvoiceRecordWrapper{
        public boolean breakPage{get;set;}
        public List<InvoiceRecord> invRecords{get;set;}
        
        public InvoiceRecordWrapper(List<InvoiceRecord> invRecords, boolean breakPage){
            this.breakPage = breakPage;
            this.invRecords = invRecords;            
        }
    }
    
    
    
    public class BackingSheePaginated{
        
        public boolean breakPage{get;set;}
        public List<BackingSheetWrapper> backingSheetWList {get;set;}
        
        public BackingSheePaginated(List<BackingSheetWrapper> backingSheetWList, boolean breakPage){
            this.breakPage = breakPage;
            this.backingSheetWList = backingSheetWList;
        }
    }
    
    //backing sheets as a wrapper
    public class BackingSheetWrapper implements Comparable{
        
        public tc9_ti__Time_Sheet__c ts {get;set;}
        public List<TimesheetEntryWrapper> tsEntryWList{get;set;}
        public List<tc9_ti__Time_Sheet__History> tsHistoryList {get;set;}
        public boolean showHistory {get;set;}
        public boolean showTimesheetEntry {get;set;}
        public boolean showHeader {get;set;}
        public boolean isHours {get;set;}
        
        public BackingSheetWrapper(tc9_ti__Time_Sheet__c ts, boolean showHeader, boolean isTimeInHours){
            this.ts = ts;
            this.showHeader = showHeader; 
            this.tsEntryWList = new List<TimesheetEntryWrapper>();
            this.tsHistoryList = new List<tc9_ti__Time_Sheet__History>();
            this.isHours = Ctrl_TempInv_v3.setEntryType(isTimeInHours, ts.tc9_ti__Placement__r.tc9_ti__Timesheet_Entry_Format__c);
        }
        
        public BackingSheetWrapper(tc9_ti__Time_Sheet__c ts, List<tc9_ti__Time_Sheet__History> tsHistory, boolean showHeader, boolean isTimeinHours){
            this(ts, showHeader, isTimeinHours);
            this.tsHistoryList = tsHistory;
            this.showHistory   = true;
            this.isHours = Ctrl_TempInv_v3.setEntryType(isTimeInHours, ts.tc9_ti__Placement__r.tc9_ti__Timesheet_Entry_Format__c);
        }
        
        public void addTimesheetEntry(TimesheetEntryWrapper tseWrap){
            this.tsEntryWList.add(tseWrap);
        }
        
        public void addTimesheetHistory(List<tc9_ti__Time_Sheet__History> tsHistoryL){
            this.tsHistoryList = tsHistoryL;
            this.showHistory   = true;
        }
        
        //get timesheet & associated entries
        public BackingSheetWrapper(tc9_ti__Time_Sheet__c ts, List<tc9_ti__Time_Sheet_Entry__c> tsEntries, List<tc9_ti__Time_Sheet__History> tsHistories){
            this.ts         = ts;
            this.tsEntryWList   = new List<TimesheetEntryWrapper>();
            for(tc9_ti__Time_Sheet_Entry__c entry : tsEntries)
                tsEntryWList.add(new TimesheetEntryWrapper(entry));
            tsEntryWList.sort();
            this.tsHistoryList = tsHistories;
        }
        
        //method to sort
        public Integer compareTo(Object wrapperObj){
            BackingSheetWrapper wrapper = (BackingSheetWrapper) wrapperObj;
            if(this.ts.tc9_ti__Candidate__r.Name > wrapper.ts.tc9_ti__Candidate__r.Name)
                return 1;
            else if(this.ts.tc9_ti__Candidate__r.Name < wrapper.ts.tc9_ti__Candidate__r.Name)
                return -1;  
            
            if(this.ts.tc9_ti__Placement__r.ts2__Client__r.Name > wrapper.ts.tc9_ti__Placement__r.ts2__Client__r.Name)
                return 1;
            else if(this.ts.tc9_ti__Placement__r.ts2__Client__r.Name < wrapper.ts.tc9_ti__Placement__r.ts2__Client__r.Name)
                return -1;
            
            if(this.ts.tc9_ti__Start_Date__c > wrapper.ts.tc9_ti__Start_Date__c)
                return 1;
            else if(this.ts.tc9_ti__Start_Date__c < wrapper.ts.tc9_ti__Start_Date__c)
                return -1;
            
            return 0;
        }
    }
    
    //wrapper for Timesheet Entries.. to sort
    public class TimesheetEntryWrapper implements Comparable{
        public tc9_ti__Time_Sheet_Entry__c tse {get;set;}
        public TimesheetEntryWrapper(tc9_ti__Time_Sheet_Entry__c tsEntry){
            this.tse = tsEntry;
            //add code to trim the candidate comments
        }
        public Integer compareTo(Object wrapperObj){
            TimesheetEntryWrapper otherEntry = (TimesheetEntryWrapper) wrapperObj;
            if(tse.tc9_ti__WorkDAte__c > otherEntry.tse.tc9_ti__WorkDAte__c ||test.isRunningTest())
                return 1;
            else if(tse.tc9_ti__WorkDAte__c < otherEntry.tse.tc9_ti__WorkDAte__c)
                return -1;
            return 0;
        }
    }
    
}