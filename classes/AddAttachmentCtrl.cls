/*
 Author     : 2C9 Dharshni
 Purpose    : Controller for AddAttachmentsPage
 
 Modified on : 20/02/14 - SC-2724
 Modified on : 14/11/14 - SC-4532
 
   Change History  
    ******************************************************************************************************************************************
         SCRUM        ModifiedBy        Date            Requested By                           Description                              Tag
    ******************************************************************************************************************************************
        Sc-9991     Srinidhi.R      23/11/2015          David Levy               Timesheet Manager - Expense Attachment Popup explanation not correct
        SC-13999    Jagadeswary     01/11/2016         Michelle Cole             Timesheet Manager Attachments
        SC-10798    Srinidhi.R      02/11/2016         Michelle Cole             Expense Claim Manager vf page
        SC-14064    Jagadeswary     10/11/2016          David Levy               Attachment deletion        
        SC-14063    Jagadeswary     10/11/2016          DAvid Levy               updating selectedtype parameter
        SC-14539    Srinidhi.R      03/02/2017          David Levy               Expense Manager - Refresh issue
        SC-14603    Jagadeswary     14/02/2017          David Levy               Dont appear able to edit attachment where status
*/
global with sharing class AddAttachmentCtrl {
    
    global boolean attachmentAvailable{get;set;}
    global Attachment receipt{get;set;}
    global tc9_ti__Expense__c expense{get;set;}
    global tc9_ti__Time_Sheet__c timesheet{get;set;}

    public tc9_ti__Expense_Claim__c expClaim {get;set;}

    global Boolean isExpense{get;set;}
    global Boolean isOnLoad{get;set;}
    global List<Selectoption> listOfAttachmentTypes{get;set;}
    global String selectedType{get;set;}
    
    public Boolean isTimesheet{get;set;}
    public String locale{get;set;}
    public Set<String> allowedTypes;
    public tc9_ti__ToCloudNineConfig__c conf {get;set;}
    public Boolean toDispDelete {get;set;}
  public Boolean isTSM {get;set;}
    public Boolean isExpenseClaim {get;set;}
    //Sc-9991
    public boolean isFileUploaded{get;set;}

    
    //input parameter
    global String parentID {
        get {return parentID;}
        set {parentID =value;} 
    }
    
    /*constructor*/
    global AddAttachmentCtrl(){
      
        isFileUploaded = false;
        isExpense               = false;
        parentID                = ApexPages.currentPage().getParameters().get('parentId');
        selectedType            = ApexPages.currentPage().getParameters().get('selectedType');
        listOfAttachmentTypes   = new List<Selectoption>(); 
        timesheet               = new tc9_ti__Time_Sheet__c();
        isOnLoad                = true;
        toDispDelete            = true; 

        isTSM           = false;
        //Sc-4532
        isTimesheet             = false;
        isExpenseClaim          = false;
        
        //Sc-2721
        String UserId = Userinfo.getUserId();
        User userlocale = [select Localesidkey from user where id =: UserId];
        if(userlocale != null)
            locale = userlocale.LocaleSidKey;
        else
            locale = 'en_US';
        ////
        PopulateAttachmentTypes();
        
        if(ApexPages.currentPage().getParameters().get('isExpense') == 'true'){
            isExpense = true;
        }
        System.debug('@@@@ istsm '+ApexPages.currentPage().getParameters().get('isTSM'));
        if(ApexPages.currentPage().getParameters().get('isTSM') == 'true'){
            toDispDelete = false;
            isTSM = true;
            System.debug('@@@@ istsm '+isTSM); 
        }

        if(ApexPages.currentPage().getParameters().get('isExpenseClaim') == 'true'){
            isExpenseClaim = true;
        }

        if(isExpense){
        
            List<tc9_ti__Expense__c> expenseToRetreive = [SELECT id, tc9_ti__Date_Incurred__c,tc9_ti__Title__c, tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Job__r.Name, tc9_ti__Value__c
                                                FROM tc9_ti__Expense__c 
                                                WHERE id=: parentId];
            expense = expenseToRetreive.get(0);

        }

        else {
            if(!isExpenseClaim ){                
                timesheet = [SELECT Id, tc9_ti__Placement__r.Name, tc9_ti__Placement__r.ts2__Job__r.Name, tc9_ti__End_Date__c, tc9_ti__Candidate__r.Name, tc9_ti__Candidate__c, Name From tc9_ti__Time_Sheet__c WHERE Id=: parentID];
            }            
            else {
                expClaim = [SELECT Id, Name, tc9_ti__Rejection_Reason__c, tc9_ti__Claim_Date__c, tc9_ti__Candidate__c, tc9_ti__Placement__r.Name, tc9_ti__Candidate__r.Name  from tc9_ti__Expense_Claim__c where Id = :parentID];
            }
        }
        fetchAttachment();
        
        allowedTypes = new Set<String>();
        Set<String> caseSensitiveAllowedtypes = new Set<String>(); 
        conf   = tc9_ti__ToCloudNineConfig__c.getInstance();
        if(conf.tc9_ti__Allowed_File_Types__c != null)
            caseSensitiveAllowedtypes.addAll(conf.tc9_ti__Allowed_File_Types__c.split(','));    
        
        for(String iterString : caseSensitiveAllowedtypes){
            allowedTypes.add(iterString.toUpperCase());
        }  
        system.debug('allowedTypes' +allowedTypes);    
            
    }
    
    global void PopulateAttachmentTypes(){
        for(tc9_ti__TypesofAttachments__c iteratingAttachmentType : tc9_ti__TypesofAttachments__c.getAll().values()){
            listOfAttachmentTypes.add(new Selectoption(iteratingAttachmentType.Name, iteratingAttachmentType.tc9_ti__Label__c));
        }
        if(tc9_ti__TypesofAttachments__c.getAll().values().size() > 0 && (selectedType== null || selectedType== '')){
            selectedType = tc9_ti__TypesofAttachments__c.getAll().values()[0].Name;
        }
        System.debug('@@@@ PopulateAttachmentTypes '+selectedType);         
    }
    
    global void fetchAttachment(){
        System.debug('@@@@ istsm '+isTSM); 
        System.debug('@@@@ isExpenseClaim '+isExpenseClaim); 
        List<Attachment> attachments = NEW List<Attachment>();
        if(!isTimesheet) {
            if(isOnLoad && !isExpense && !isTSM && !isExpenseClaim){
                if(ApexPages.currentPage().getParameters().get('attId') != ''){
                    attachments = [SELECT id,Name,ContentType FROM Attachment WHERE Id= : ApexPages.currentPage().getParameters().get('attId')];
                    if(attachments[0].Name.contains('_'))
                      selectedType = attachments[0].Name.substring(0, attachments[0].Name.indexOf('_'));
                    System.debug('@@@@ fetchAttachment onload '+selectedType);
                }
                isOnLoad = false;
                System.debug('@@@@ fetchAttachment '+selectedType);         
            }else if(isExpense || isExpenseClaim){
                System.debug('###in here'+isExpenseClaim);
                attachments = [SELECT id,Name,ContentType FROM Attachment WHERE Parentid= : parentId];
            }
            
            if(!isExpense && !isExpenseClaim && (!isOnLoad || isTSM)){
                String strQueryFilter = selectedType+'%';
                System.debug('@@@@ strQueryFilter '+strQueryFilter);        
                System.debug('@@@@ parentId '+parentId);        
                attachments = [SELECT id,Name,ContentType FROM Attachment WHERE Parentid= : parentId AND Name like :strQueryFilter];
                System.debug('@@@@ attachments '+attachments);  
            }
            
            attachmentAvailable          = !attachments.isEmpty();
            receipt                      = new Attachment(ParentId= parentId);
            
            if(attachmentAvailable){
                receipt = attachments.get(0);
                System.debug('@@@@ attachment '+attachments);       
            }   
        }
        else {
            System.debug('@@@@@!@#$%');
            receipt     = new Attachment(ParentId= parentId);
        }
    }
    
    /*insert attachment to the parent*/
    global void saveAttachment(){
        
        //Check if the file is selected
        if(receipt.body==null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please choose a file and click upload'));
            return;
        }
        
        List<Attachment> attachments;
        if(!isTimesheet) {
            //if Invoice or Timesheet, delete only the timesheet or invoice using filter
            
            List<String> splitFileName = new List<String>();
            splitFileName.addAll(String.valueOf(receipt.Name).split('\\.'));
            system.debug('splitFileName' +splitFileName + 'test ' +receipt.Name);
            String receiptFileType = '';
            if(splitFileName != null && splitFileName.size()>1)
                receiptFileType = splitFileName[splitFileName.size()-1];
            
            if(allowedTypes.size() == 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please fill in the \'Allowed File Types\' field in the Timecards config custom settings.'));
                receipt.body = null;
                return;
            }
            if(receiptFileType == '' || !(allowedTypes.contains(receiptFileType.toUpperCase()))) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Label.Unsupported_File_types+' '+conf.tc9_ti__Allowed_File_Types__c));
                receipt.body = null;
                return;
            }
            if(!isExpense && !isExpenseClaim){

                
                //Formatted Name
                receipt.Name = selectedType +'_'+ timesheet.tc9_ti__Candidate__r.Name + '_'+ UtilClass1.GetFormattedDate(timesheet.tc9_ti__End_Date__c)+'.'+receiptFileType;
                receipt.Description = selectedType; 
            }           
            system.debug('*** attachment' + receipt.name  );   
            if(!isExpense && !isExpenseClaim){
                String strQueryFilter = selectedType+'%';
                attachments = [SELECT id,Name,ContentType FROM Attachment WHERE Parentid= : parentId AND Name like :strQueryFilter];
            } 
            else{
                attachments = [SELECT id FROM Attachment WHERE Parentid= : parentId];
            } 
            try{
                if(!attachments.isEmpty())
                    delete attachments;
                
            }
            catch(Exception e){ 
                receipt.body =null;
                if(e.getmessage().contains('INSUFFICIENT_ACCESS_OR_READONLY'))
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'You do not have permission to update this attachment.'));
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getmessage()));
               
                return;
            }
        }
        else {          
            //Do checks in future if necessary
        }
        if(isTimesheet){
            System.debug('@@@@@!@#$%'+receipt.Name);
            //to achieve required naming format.
            receipt.Name = selectedType +'_'+ timesheet.tc9_ti__Candidate__r.Name + '_'+ UtilClass1.GetFormattedDate(timesheet.tc9_ti__End_Date__c)+ '_' + receipt.Name ;
            receipt.Description = selectedType;
            System.debug('@@@@@!@#$%'+receipt.Name);
        }
        if(isExpense){
            System.debug('@@@@@!@#$%'+receipt.Name);
            //to achieve required naming format.
            receipt.Name = 'Expense_'+ receipt.Name ;
            receipt.Description = 'Expense';
            System.debug('@@@@@!@#$%'+receipt.Name);
        }
        
        if(isExpenseClaim){
            receipt.Name = 'ExpenseClaim_'+ receipt.Name ;
            receipt.Description = 'Expense Claim';

        }

        insert receipt;
        
        receipt.body = null;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'The attachment has been added successfully. Click Close to return to the page'));
        attachmentAvailable = true;
        
    }
    
    global void editAttachment(){
        receipt = new Attachment(ParentId = parentId);
        attachmentAvailable = false;
    }
    
    global void deleteAttachment(){
        System.debug('!!!deleteAttachment:');
        
        List<Attachment> attachments;
        if(isExpense || isExpenseClaim){
            attachments = [SELECT id FROM Attachment WHERE Parentid= : parentId];
        }
        else{
            System.debug('In here!');
            String strQueryFilter = selectedType+'%';
            attachments = [SELECT id FROM Attachment WHERE Parentid= : parentId  AND Name like :strQueryFilter];
        }
        
        System.debug('attachments:'+attachments);
        if(!attachments.isEmpty())  
            delete attachments;
    
        receipt = new Attachment(ParentId = parentId);
        attachmentAvailable = false;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'The attachment is deleted. Please click cancel to close the window'));
    }
    
   /* static testmethod void testAddAttachmentAsExpense(){
        ToCloudNineConfig__c conf   = new ToCloudNineConfig__c();
        conf.Allowed_File_Types__c = 'pdf,xls,jpeg,jpg';
        conf.Portal_Profile_Name__c = 'High Volume Customer Portal';
        conf.Auto_Create_Portal_User__c = false;
        insert conf;
        
        Maximum_licence_limit__c l = new Maximum_licence_limit__c();
        l.Name = 'High Volume Customer Portal';
        l.Licence_Name__c = 'High Volume Customer Portal';
        l.Maximum_licence_number__c = 10;
        insert l;
        
        TestDataDump testData = new TestDataDump();
        Date plcStartDate       = date.parse('23/07/2012');
        Date plcEndDate         = plcStartDate.addDays(12); //placement spanning two weeks (till 03/08/2012)
        
        TaxID__c taxID          = testData.getTaxID();
        Market__c market        = testData.getMarket(taxID.Id); 
        Account accnt           = testData.getAClientAccount(market.Id);
        Contact clientContact   = testData.getAClientContact(accnt.Id);
            
        Site__c sit             = testData.getASite('Test Site', 'http://www.test.com/');
        
        ts2__Job__c job1        = testData.getAJob(accnt.Id, clientContact.Id, market.Id,sit.Id);
        
        //insert a public holiday calander
        Public_Holiday_Calendar__c cal = testData.getPublicHolidayCal();
        
        //create a holidate entry
        testData.addHoliday(cal.Id,plcStartDate.addDays(7),plcStartDate.addDays(8));
        
        Contact candidate       = testData.getACandidate('TestCandidate');  
        User usr                = testData.getCustomerPortalUser(candidate);
        
        //insert a new award Master
        Award_Master__c awrdMaster1 = testData.getAnAwardMaster(38.0, 15.0, 5.0, 5.0, 5.0, false);
        testData.createRules(awrdMaster1.Id);
        
        ts2__Placement__c plc   = testData.getAPlacement(job1, cal.Id, candidate.Id, plcStartDate, plcEndDate, awrdMaster1.Id, 'Temp'); //till next friday
        
        plc = testData.getPlacementFields(plc.Id);
        plc.Does_Not_Use_Online_Timesheets__c = true;
        update plc;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(plc);
        CreateTimeSheetExt controller = new CreateTimeSheetExt(sc);
        controller.create();
        
        //get the timesheets created
        List<Time_Sheet__c> tsList = [SELECT id,End_Date__c,Status__c,Placement__c FROM Time_Sheet__c where Placement__c=:plc.Id order by Start_Date__c];
        
        List<Expense__c> expenses = new List<Expense__c>();
        Expense__c exp1 = new Expense__c(Time_Sheet__c = tsList.get(0).Id, Date_Incurred__c = plcStartDate.addDays(1),Type__c='Education',Value__c=10,Title__c='test 1');
        Expense__c exp2 = new Expense__c(Time_Sheet__c = tsList.get(0).Id, Date_Incurred__c = plcStartDate.addDays(3),Type__c='Clothing',Value__c=10,Title__c='test 2');
        expenses.add(exp1);
        expenses.add(exp2);
        insert expenses;
        
        Test.startTest();
            
            Test.setCurrentPage(Page.AddAttachments );
            ApexPages.currentPage().getParameters().put('parentId',exp1.Id);
            ApexPages.currentPage().getParameters().put('isExpense','true');
            AddAttachmentCtrl ctrl  = new AddAttachmentCtrl();
            
            //initially there is no attachment
            system.assertEquals(ctrl.attachmentAvailable, false);
            
            //create an attachment
            ctrl.receipt.Name = 'Test 1.pdf';
            ctrl.receipt.Body =  Blob.valueOf('Unit Test Attachment Body');
            ctrl.receipt.ContentType = 'pdf';
            ctrl.saveAttachment();
            
            //attachment added, and flag set
            System.assertEquals([SELECT Name FROM Attachment WHERE Parentid= : exp1.Id].Name, 'Expense_Test 1.pdf');
            system.assertEquals(ctrl.attachmentAvailable, true);
            
            //flag reset on Edit
            ctrl.editAttachment();
            system.assertEquals(ctrl.attachmentAvailable, false);
            
            //add new attachment
            ctrl.receipt.Name = 'Test 2.pdf';
            ctrl.receipt.Body = Blob.valueOf('Another');
            ctrl.receipt.ContentType = 'pdf';
            ctrl.saveAttachment();
            
            //attachment added and flag set
            System.assertEquals([SELECT Name FROM Attachment WHERE Parentid= : exp1.Id].Name, 'Expense_Test 2.pdf');
            system.assertEquals(ctrl.attachmentAvailable, true);
            
            //delete attachment and assert deletion
            ctrl.deleteAttachment();
            System.assertEquals([SELECT count() FROM Attachment WHERE Parentid= : exp1.Id], 0);
            system.assertEquals(ctrl.attachmentAvailable, false);
            
            //start a fresh session and test
            ctrl = new AddAttachmentCtrl();
            ctrl.saveAttachment();
            system.assertEquals(ctrl.attachmentAvailable, false);
                        
            Test.stopTest();
        
    }
    
    static testmethod void testAddAttachmentAsAttachment(){
        ToCloudNineConfig__c conf   = new ToCloudNineConfig__c();
        conf.Allowed_File_Types__c = 'pdf,xls,jpeg,jpg';
        conf.Portal_Profile_Name__c = 'High Volume Customer Portal';
        conf.Auto_Create_Portal_User__c = false;
        insert conf;
        
        Maximum_licence_limit__c l = new Maximum_licence_limit__c();
        l.Name = 'High Volume Customer Portal';
        l.Licence_Name__c = 'High Volume Customer Portal';
        l.Maximum_licence_number__c = 10;
        insert l;
        
        TestDataDump testData = new TestDataDump();
        Date plcStartDate       = date.parse('23/07/2012');
        Date plcEndDate         = plcStartDate.addDays(12); //placement spanning two weeks (till 03/08/2012)
        
        TaxID__c taxID          = testData.getTaxID();
        Market__c market        = testData.getMarket(taxID.Id); 
        Account accnt           = testData.getAClientAccount(market.Id);
        Contact clientContact   = testData.getAClientContact(accnt.Id);
            
        Site__c sit             = testData.getASite('Test Site', 'http://www.test.com/');
        
        ts2__Job__c job1        = testData.getAJob(accnt.Id, clientContact.Id, market.Id,sit.Id);
        
        //insert a public holiday calander
        Public_Holiday_Calendar__c cal = testData.getPublicHolidayCal();
        
        //create a holidate entry
        testData.addHoliday(cal.Id,plcStartDate.addDays(7),plcStartDate.addDays(8));
        
        Contact candidate       = testData.getACandidate('TestCandidate');  
        User usr                = testData.getCustomerPortalUser(candidate);
        
        //insert a new award Master
        Award_Master__c awrdMaster1 = testData.getAnAwardMaster(38.0, 15.0, 5.0, 5.0, 5.0, false);
        testData.createRules(awrdMaster1.Id);
        
        ts2__Placement__c plc   = testData.getAPlacement(job1, cal.Id, candidate.Id, plcStartDate, plcEndDate, awrdMaster1.Id, 'Temp'); //till next friday
        
        plc = testData.getPlacementFields(plc.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(plc);
        CreateTimeSheetExt controller = new CreateTimeSheetExt(sc);
        controller.create();
        
        //get the timesheets created
        List<Time_Sheet__c> tsList = [SELECT id,End_Date__c,Status__c,Placement__c FROM Time_Sheet__c where Placement__c=:plc.Id order by Start_Date__c];
        
        Attachment testAttachment = new Attachment(ParentId = tsList.get(0).Id, Body = Blob.valueOf('Test'), Name='Invoice_Test');
        insert testAttachment;
        
        Test.startTest();
            
            Test.setCurrentPage(Page.AddAttachments );
            ApexPages.currentPage().getParameters().put('parentId',tsList[0].Id);
            ApexPages.currentPage().getParameters().put('isExpense','false');
            ApexPages.currentPage().getParameters().put('attId','');
            ApexPages.currentPage().getParameters().put('isTSM','true'); 
            ApexPages.currentPage().getParameters().put('selectedType','Invoice'); 
            AddAttachmentCtrl ctrl  = new AddAttachmentCtrl();
            //initially there is no attachment
            system.assertEquals(ctrl.attachmentAvailable, true);
            ctrl.deleteAttachment();
            ctrl.selectedType = 'Timesheet';
            
            //create an attachment
            ctrl.receipt.Name = 'Test.pdf';
            ctrl.receipt.Body =  Blob.valueOf('Unit Test Attachment Body');
            ctrl.receipt.ContentType = 'pdf';
            ctrl.saveAttachment();
            
            //attachment added, and flag set
            //System.assertEquals([SELECT Name FROM Attachment WHERE Parentid= : tsList[0].Id].Name, 'Invoice_Test');
            system.assertEquals(ctrl.attachmentAvailable, true);
            
            //flag reset on Edit
            ctrl.editAttachment();
            system.assertEquals(ctrl.attachmentAvailable, false);
            
            //add new attachment
            ctrl.receipt.Name = 'Invoice_Test.pdf';
            ctrl.receipt.Body = Blob.valueOf('Another');
            ctrl.receipt.ContentType = 'pdf';
            ctrl.saveAttachment();
            
            //attachment added and flag set
            //System.assertEquals([SELECT Name FROM Attachment WHERE Parentid= : tsList[0].Id].Name, 'Invoice_Test');
            system.assertEquals(ctrl.attachmentAvailable, true);
            
            //delete attachment and assert deletion
            ctrl.deleteAttachment();
            System.assertEquals([SELECT count() FROM Attachment WHERE Parentid= : tsList[0].Id], 0);
            system.assertEquals(ctrl.attachmentAvailable, false);
            
            //start a fresh session and test
            ctrl = new AddAttachmentCtrl();
            ctrl.saveAttachment();
            system.assertEquals(ctrl.attachmentAvailable, false);
                        
            Test.stopTest();
        
    }*/
}