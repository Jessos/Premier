/*
    Class      : PortalFillTimesheetController
    Test class : 
    Purpose    : Controller for the FillTimesheet Page
    Author     : Ying Liu
    Change History 
    ******************************************************************************************************************************************
         SCRUM        ModifiedBy        Date            Requested By                           Description                              Tag
    ******************************************************************************************************************************************
        CR 096          2C9
        SC-0601         2C9
        SC-0698         2C9
        SC-2724         2C9
        SC-2706         2C9
        SC-6854       Khushboo
        SC-6844       Khushboo
        Sc-10803      Khushboo       27/05/2016         Michelle Cole       Updating the entry type based on the related placement
*/
global with sharing class PortalFillTimesheetController extends PortalBaseClass {
    
    public String helptext {get;set;}
    public List<tc9_ti__Talent_Help_Page_Settings__c> ListOfUrls {get;set;}
    global User theUser {get {return currentUser;}}
    public String usrLang {get {return UserInfo.getLanguage();}}
    public String StringId {get;set;}  
    public boolean Isexception{get;set;}  
    public boolean isTimeSheetEntryInHours;         
    //project codes
    global Map<Id, List<SelectOption>> job_ProjectCodes{get;set;}            
    
    /*********************************************** Booleans controlling sections that are displayed ************************/
    global Boolean isEdit {get; private set;}
    global Boolean isSubmit {get; private set;}
    global Boolean displayBreakEntry {get;set;}
    global Map<String,boolean> showSection {get;set;}
    
    global String strCustomExpensePage {get;set;}
    global String strCustomExpenseButtonLabel {get;set;}
    global String strTimesheetId {get;set;}
    
    
    /********************************************** Data displayed *************************/
    //list of wrappers
    global List<JobWrapper> jobWList{get;set;}
    global Map<String,String> PageAPIName { get;set; }
    global Integer nCount {get;set;}
    
    public List<tc9_ti__Time_Sheet__c> tsList;
    
    private Date toDay = Date.today();
    private integer pageSize = 20;
    private final integer numsworkingday = 7;
    
    private String TSSTATUSSUBMITTED = 'Submitted';
    private String TSSTATUSNEW = 'New';
    private String TSSTATUSREJECTED = 'Rejected';
    private Set<String> showableTsSet = new Set<String>{TSSTATUSSUBMITTED, TSSTATUSNEW, TSSTATUSREJECTED};    
    private Id conId;   
    
    /************************ RELATED TO BREAKPOINT TABLE ***********************************/
    //Timesheet_Transactions Of a type for each day in the week
    private Map<Id, Map<Date,TransactionSimulatorWrapper.Simulator>> simulatorMap;
    
    //map of timesheetId, AwardMaster Id
    private Map<Id,Id> ts_AwardMaster;
        
    //awardMaster records
    private Map<Id, List<String>> awardMaster_Breakpoints;
    private Map<Id, tc9_ti__Award_Master__c> awardMasterMap;
    
    //wrapper for relevant breakpoints and breakpoint details in a week
    global Map<Id,TransactionSimulatorWrapper> simWrapMap {get;set;}
    
    /************************************************** WRAPPER CLASSES ***********************************/
    /************************************************** EXPENSE WRAPPER & its CRUD Operation***********************************/
    //wrapper class for expense record
    //holds the record and determines if the record is in edit mode or not
    global class ExpensesWrapper{
            global tc9_ti__Expense__c expense{get;set;}
        global boolean editable{get;set;}
        
        global ExpensesWrapper(tc9_ti__Expense__c exp,boolean edit){
            this.expense = exp;
            this.editable = edit;
            
            //IE-11 fix - https://success.salesforce.com/issues_view?id=a1p30000000T3CeAAK
            if(this.expense.tc9_ti__Title__c == NULL || this.expense.tc9_ti__Title__c == '')
                this.expense.tc9_ti__Title__c = '.';
        }
    }
    
    
    
    /**
        save a particular expense after edit/add
    **/
    global void saveEditDeleteExpense(){

        //get the page parameters
        Integer jobRow = Integer.valueOf( ApexPages.currentPage().getParameters().get('jobNumber'));
        Integer tsRow = Integer.valueOf( ApexPages.currentPage().getParameters().get('tsNumber'));
        Integer expRow = Integer.valueOf( ApexPages.currentPage().getParameters().get('expNumber'))-1;
        String actionToDo  = ApexPages.currentPage().getParameters().get('actionToDo');
        
        if(actionToDo != null){
            actionToDo = String.escapeSingleQuotes(actionToDo);
        }
        
        system.debug('** ' + actionToDo);
        
        //retreive the job,timesheet and the expense clicked
        JobWrapper thisJob =  jobWList.get(jobRow);
        TimeSheetWrapper thisTS = thisJob.timeSheetWList.get(tsRow);
        ExpensesWrapper thisExp = thisTS.expenseWList.get(expRow);
        tc9_ti__Expense__c updateExp = thisExp.expense;
        if(actionToDo=='save'){
            if(updateExp.tc9_ti__Type__c==null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.Expense_Type_required));
                return;
            }
            //if(updateExp.Date_Incurred__c < thisTS.timeSheet.Start_Date__c || updateExp.Date_Incurred__c > thisTS.timeSheet.End_Date__c){
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.Expense_Date_Range));
                //return;
            //}
            updateExp.tc9_ti__Time_Sheet__c = thisTS.timeSheet.Id;
            upsert updateExp;
            tc9_ti__Expense__c exp = [SELECT id,tc9_ti__Date_Incurred__c,
                                            tc9_ti__Title__c,tc9_ti__Type__c,tc9_ti__Taxable__c,
                                            tc9_ti__Value__c,tc9_ti__Tax_Amount__c,tc9_ti__Time_Sheet__c
                                   FROM tc9_ti__Expense__c 
                                   WHERE id = : updateExp.Id];
      thisTs.expenseWList.add(expRow,new ExpensesWrapper(exp,false));
            thisTs.expenseWList.remove(expRow+1);                                   
        }
        else if(actionToDo == 'edit'){
            thisExp.editable = true;
        }
        else if(actionToDo == 'cancel'){
            if(updateExp.Id!=null){
                tc9_ti__Expense__c exp = [SELECT id,tc9_ti__Date_Incurred__c,
                                            tc9_ti__Title__c,tc9_ti__Type__c,tc9_ti__Taxable__c,
                                            tc9_ti__Value__c,tc9_ti__Tax_Amount__c,tc9_ti__Time_Sheet__c
                                   FROM tc9_ti__Expense__c 
                                   WHERE id = : updateExp.Id];
                thisTs.expenseWList.add(expRow,new ExpensesWrapper(exp,false));
                thisTs.expenseWList.remove(expRow+1);
            }
            else{   //SC-1033
                thisTs.expenseWList.remove(expRow);
            }
        }
        else if(actionToDo == 'delete'){
            updateExp.tc9_ti__Time_Sheet__c = thisTS.timeSheet.Id;
            delete updateExp;
            thisTs.expenseWList.remove(expRow);
        }
    }
    
    /**
        add a new expense record to a particular TS
    **/
    global PageReference addExpense(){
        Integer jobRow = Integer.valueOf( ApexPages.currentPage().getParameters().get('jobNumber'));
        Integer tsRow = Integer.valueOf( ApexPages.currentPage().getParameters().get('tsNumber'));

        JobWrapper thisJob =  jobWList.get(jobRow);
        TimeSheetWrapper thisTS = thisJob.timeSheetWList.get(tsRow);
        thisTS.expenseWList.add(new ExpensesWrapper(new tc9_ti__Expense__c(),true));
        system.debug('***** Expense added ***********');
        return null;
    }
    
    /************************************************** Attachment & its CRUD Operation***********************************/
    
    //Dummy function for rerender
    global Pagereference reload(){
        getTsList();
        return null;
    }
    
    //wrapper class for expense record
    //holds the record and determines if the record is in edit mode or not
    global class AttachmentWrapper{
        global Attachment attachment{get;set;}
        global boolean editable{get;set;}
        
        global AttachmentWrapper(Attachment attachment,boolean edit){
            this.attachment = attachment;
            this.editable = edit;
        }
    }
    
    /**
        save a particular attachment after edit/add
    **/
    global void saveEditDeleteAttachment(){

        //get the page parameters
        Integer jobRow = Integer.valueOf( ApexPages.currentPage().getParameters().get('jobNumber'));
        Integer tsRow = Integer.valueOf( ApexPages.currentPage().getParameters().get('tsNumber'));
        Integer attRow = Integer.valueOf( ApexPages.currentPage().getParameters().get('attNumber'))-1;
        String actionToDo  = ApexPages.currentPage().getParameters().get('actionToDo');
        
        if(actionToDo != null){
            actionToDo = String.escapeSingleQuotes(actionToDo);
        }
        
        system.debug('** ' + actionToDo);
        
        //retreive the job,timesheet and the expense clicked
        JobWrapper thisJob =  jobWList.get(jobRow);
        TimeSheetWrapper thisTS = thisJob.timeSheetWList.get(tsRow);
        AttachmentWrapper thisAtt = thisTS.attachmentWList.get(attRow);
        Attachment updateAttachment = thisAtt.attachment;
        
        if(actionToDo=='save'){
            /*if(updateExp.Type__c==null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.Expense_Type_required));
                return;
            }*/
            //if(updateExp.Date_Incurred__c < thisTS.timeSheet.Start_Date__c || updateExp.Date_Incurred__c > thisTS.timeSheet.End_Date__c){
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.Expense_Date_Range));
                //return;
            //}
            updateAttachment.ParentId = thisTS.timeSheet.Id;
            upsert updateAttachment;
            Attachment attachment = [SELECT id, Name, ParentId 
                                           FROM Attachment 
                                           WHERE id = : updateAttachment.Id];
            thisTs.attachmentWList.add(attRow,new AttachmentWrapper(attachment,false));
            thisTs.attachmentWList.remove(attRow+1);                                   
        }
        else if(actionToDo == 'edit'){
            thisAtt.editable = true;
        }
        else if(actionToDo == 'cancel'){
            if(updateAttachment.Id != null){
                Attachment attachment = [SELECT id, Name, ParentId 
                                           FROM Attachment 
                                           WHERE id = : updateAttachment.Id];
        thisTs.attachmentWList.add(attRow,new AttachmentWrapper(attachment,false));
              thisTs.attachmentWList.remove(attRow+1);          
            }
            else{
                thisTs.attachmentWList.remove(attRow);
            }
        }
        else if(actionToDo == 'delete'){
            //updateAttachment.ParentId = thisTS.timeSheet.Id;
            delete updateAttachment;
            thisTs.attachmentWList.remove(attRow);
        }
    }
    
    /**
        add a new Attachment record to a particular TS
    **/
    global PageReference addAttachment(){
        Integer jobRow = Integer.valueOf( ApexPages.currentPage().getParameters().get('jobNumber'));
        Integer tsRow = Integer.valueOf( ApexPages.currentPage().getParameters().get('tsNumber'));

        JobWrapper thisJob =  jobWList.get(jobRow);
        TimeSheetWrapper thisTS = thisJob.timeSheetWList.get(tsRow);
        thisTS.attachmentWList.add(new AttachmentWrapper(new Attachment(),true));
        system.debug('***** Attachment added ***********');
        return null;
    }
    
    /************************************************** TIME SHEET WRAPPER ***********************************/
    //wrapper for TimeSheet
    //holds TS,TSE and ExpenseWrapper
    global class TimeSheetWrapper{

        global tc9_ti__Time_Sheet__c timeSheet{get;set;}
        global List<tc9_ti__Time_Sheet_Entry__c> tseList{get;set;}
        global List<ExpensesWrapper> expenseWList{get;set;}
        global List<AttachmentWrapper> attachmentWList{get;set;}
        public Boolean isHours {get;set;}

        global TimeSheetWrapper(tc9_ti__Time_Sheet__c ts,List<tc9_ti__Expense__c> exp, List<Attachment> att){
            this.timeSheet = ts;
            this.expenseWList  = new List<ExpensesWrapper>();
            this.attachmentWList  = new List<AttachmentWrapper>();
            for(tc9_ti__Expense__c   e :  exp)
                this.expenseWList.add(new ExpensesWrapper(e,false));
            for(Attachment a :  att)
                this.attachmentWList.add(new AttachmentWrapper(a,false));
            this.tseList = new List<tc9_ti__Time_Sheet_Entry__c>();
            this.tseList.addAll(ts.tc9_ti__Time_Sheet_Entries__r);            
        }
    }
    
    /************************************************** JOB ORDER WRAPPER & its related Operations ***********************************/
    //wrapper class to include job and its TSWrapper
    //provides the lasttimesheet's detail(to display in section header)
    //provides total hours the candidate has logged for the hob
    global class JobWrapper{

        global String jobName{get;set;}
        global String clientName {get;set;}
        global ID jobID {get;set;}
        global List<tc9_ti__Time_Sheet__c> timsheetList{get;set;}
        global List<TimeSheetWrapper> timeSheetWList{get;set;}
        global Decimal tsTotalHours{get;set;}

        //the current week's timesheet for this candidate under the job
        global tc9_ti__Time_Sheet__c lastTimeSheet{
            get{
                return this.timeSheetWList.get(timeSheetWList.size() - 1).timeSheet;
            }set{
                lastTimeSheet = value;
            }
        }
        //the total hours under this timesheet
        global Decimal totalTSHours{
            get{
                return this.timeSheetWList.get(timeSheetWList.size() - 1).timesheet.tc9_ti__WeeklyActualHours__c;
            }
            set{
                totalTSHours = value;
            }
        }

        global JobWrapper(TimeSheetWrapper tsWrap){
            this.jobID = tsWrap.timeSheet.tc9_ti__Placement__r.ts2__Job__c;
            this.jobName = tsWrap.timeSheet.tc9_ti__Placement__r.ts2__Job__r.Name;
            this.clientName = tsWrap.timeSheet.tc9_ti__Placement__r.ts2__Job__r.tc9_ti__Client_Name__c;
            this.timeSheetWList = new List<TimeSheetWrapper>{tsWrap};
        }
    }
    
    private void populateWrapperList(TimeSheetWrapper tsWrap){
        boolean addedToList = false;

        //add to an existing wrapper object,if one already exists for the job
        for(JobWrapper jbWrap : jobWList)
            if(jbWrap.jobID==tsWrap.timeSheet.tc9_ti__Placement__r.ts2__Job__c){
                jbWrap.timeSheetWList.add(tsWrap);
                addedToList = true;
            }

          if(!addedToList)
            jobWList.add(new JobWrapper(tsWrap));       
    }
    
    /************************************************** Constructor ***********************************/
    // The constructor passes in the standard controller defined below  
    // in the Visualforce markup
    global  PortalFillTimesheetController(){

        //initialize   
        jobWList            = new List<JobWrapper>();

        nCount              = 0;

        strCustomExpensePage= '';
        strCustomExpenseButtonLabel = '';
        strTimesheetId      = '';
        
        nCount = tc9_ti__TypesofAttachments__c.getAll().values().size();
        //displayBreakEntry = false;
        //get current contact
        conId = currentUser.ContactId;
        //get the details from custom settings
        tc9_ti__ToCloudNineConfig__c conf   = tc9_ti__ToCloudNineConfig__c.getInstance();
        system.debug('INSIDE CONTROLLER !!!!!!!!!!!!!!' + conf + ' ***** ');
        showSection                     = new Map<String,boolean>();
        showSection.put('Enable Expense', conf.tc9_ti__Include_Expense__c);
        showSection.put('Enable Attachments', conf.tc9_ti__Include_Attachments_for_Timesheet__c);
        showSection.put('BreakpointTable', conf.tc9_ti__Display_Breakpoint_Table__c);
        showSection.put('ProjectCodes',conf.tc9_ti__Enable_Project_Codes__c);
        showSection.put('ProjectCodeButton',conf.tc9_ti__Display_Add_Project_Codes_Button__c);
        //showSection.put('Hours',conf.TimeSheet_Entry_Hours__c);
        //Added to change the display of the buttons
        showSection.put('NewButton',conf.tc9_ti__Enable_New_for_Portal__c);
        showSection.put('LeaveButton',conf.tc9_ti__Enable_Leave_for_Portal__c);
        
        //SC-2706 - Vignesh
        showSection.put('EnableCustomExpense',conf.tc9_ti__Enable_Custom_Expense_Page__c);
        showSection.put('EnableCustomExpenseInViewMode',conf.tc9_ti__Enable_custom_Expense_page_in_view_mode__c);
        
        system.debug('&&&&'+showSection);
        
        isTimeSheetEntryInHours = conf.tc9_ti__TimeSheet_Entry_Hours__c;
        if(conf.tc9_ti__Custom_Expense_Page_Name__c != NULL){
            strCustomExpensePage = conf.tc9_ti__Custom_Expense_Page_Name__c;
        }else if(conf.tc9_ti__Enable_Custom_Expense_Page__c){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Custom_Expenses_Page_Not_Defined_Error));
        }
        


        if(conf.tc9_ti__Custom_Expense_Page_Name__c != NULL){
            strCustomExpenseButtonLabel = conf.tc9_ti__Custom_Timesheet_Page_Button_Label__c;
        }else if(conf.tc9_ti__Enable_Custom_Expense_Page__c){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Custom_Expenses_Page_Not_Defined_Error)); 

        }

        
        //Added as per  SC-1339 by Akash(Lister)
         showSection.put('BreakEntryTable', conf.tc9_ti__Display_Break2__c);
         displayBreakEntry = conf.tc9_ti__Display_Break2__c;
         
         tc9_ti__Talent_Help_Page_Settings__c helpconf = tc9_ti__Talent_Help_Page_Settings__c.getInstance('');
        ListOfUrls = new List<tc9_ti__Talent_Help_Page_Settings__c>();
        ListOfUrls = tc9_ti__Talent_Help_Page_Settings__c.getAll().values();
        List<EmailTemplate> helpList = [Select e.HtmlValue From EmailTemplate e where e.DeveloperName = 'Help_Page_Content'];
        helptext = '';
        for(EmailTemplate eT : helpList){
            helptext += et.HtmlValue;
        }


         // ********************* POPULATE TIMESHEET ENTRIES ********************   
        getTsList(); 


        isEdit = false;
        isSubmit = false;
        
        //set page to edit/save mode based on parameters
        String strIsEdit = ApexPages.currentPage().getParameters().get('isEdit');
        if(strIsEdit != null)
            strIsEdit = String.escapeSingleQuotes(strIsEdit);
        
        if ( strIsEdit != null && strIsEdit.equals('false')){
            isEdit = false;
            isSubmit = true;
            for (tc9_ti__Time_Sheet__c ts: tsList){
                if ( ts.tc9_ti__Status__c.equals(TSSTATUSNEW) || ts.tc9_ti__Status__c.equals(TSSTATUSREJECTED)){
                    isSubmit = false; 
                    break;   
                }
            }
        }else{
            // if all the selected timesheet's status are submitted, then the page should be in view mode
            // else, it should in edit mode
            for (tc9_ti__Time_Sheet__c ts: tsList){
                if (ts.tc9_ti__Status__c.equals(TSSTATUSNEW) || ts.tc9_ti__Status__c.equals(TSSTATUSREJECTED)){
                    isEdit = true; 
                    break;   
                }
            }
            if (!isEdit){
                isSubmit = true;    
            }
        }


        // ********************* PAGE Names ********************    //SC-0601 - getting API name
        PageAPIName = new Map<String,String>();
        PageAPIName.put('PageName_Notes',UtilClass1.getAPIName('AddTalentNoteOnTse'));
        PageAPIName.put('PageName_PrintTs',UtilClass1.getAPIName('PrintTimeSheetEntry'));
        PageAPIName.put('PageName_AddTSE',UtilClass1.getAPIName('AddTimeSheetEntry'));
        PageAPIName.put('PageName_AddAttachment',UtilClass1.getAPIName('AddAttachments'));
        PageAPIName.put('PageName_ShowLeaveEntries',UtilClass1.getAPIName('ListLeaveEntries'));
        
        //SC-SC-2706 
        PageAPIName.put('PageName_CustomExpensePage',UtilClass1.getAPIName(strCustomExpensePage));
        PageAPIName.put('PageName_ClientProjectCode',UtilClass1.getAPIName('ClientProjectCode'));
        
        // ********************* RELATED TO BREAKPOINT TABLE ********************
        simWrapMap   = new Map<Id, TransactionSimulatorWrapper>();
        awardMasterMap  = new Map<Id, tc9_ti__Award_Master__c>();
        awardMaster_Breakpoints = new Map<Id,List<String>>();
        ts_AwardMaster = new Map<ID,Id>();


        //only if breakpoint table is needed, perform related action
        if(showSection.get('BreakpointTable') || Test.isRunningTest()){

            try{

                Set<ID> awardMasterIds = new Set<ID>();
                
                //get timesheets 
                for(tc9_ti__Time_Sheet_Entry__c tse : [SELECT id,tc9_ti__Time_Sheet__c,tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Award_Master__c From tc9_ti__Time_Sheet_Entry__c WHERE tc9_ti__Time_Sheet__c in :tsList]){
                    awardMasterIds.add(tse.tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Award_Master__c);
                    ts_AwardMaster.put(tse.tc9_ti__Time_Sheet__c,tse.tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Award_Master__c );
                }
                
                //get award master
                awardMasterMap  = new Map<Id, tc9_ti__Award_Master__c>([SELECT id,Name, (SELECT tc9_ti__Pay_Multiplier__c From tc9_ti__Rules__r) From tc9_ti__Award_Master__c Where id in: awardMasterIds]);
                for(tc9_ti__Award_Master__c awrdMaster : awardMasterMap.values())
                    awardMaster_Breakpoints.put(awrdMaster.Id, getBreakpointsInOrder(awrdMaster.Id));


                updateAllBPTables();
            }


            catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + '- Line :' + e.getLineNumber()));
            }

        }        
        else{

            for(tc9_ti__Time_Sheet__c ts : tsList)
            simWrapMap.put(ts.Id, new TransactionSimulatorWrapper());

        }
        
        
        //project codes
        job_ProjectCodes = new Map<Id, List<SelectOption>>();
        
        //if the section is to be displayed, get the project codes relevent to the job orders
        if(showSection.get('ProjectCodes')){
            for(JobWrapper jobWrap : jobWList)
                job_ProjectCodes.put(jobWrap.jobId, new List<SelectOption>{new SelectOption('', '-None-')});
            for(tc9_ti__Job_Project_Code__c projCode : [SELECT id, tc9_ti__Project_Code__c, tc9_ti__Project_Code__r.Name , tc9_ti__Job_Order__c
                                                  FROM tc9_ti__Job_Project_Code__c 
                                                  WHERE tc9_ti__Job_Order__c in: job_ProjectCodes.keySet()
                                                    AND tc9_ti__Project_Code__r.tc9_ti__Status__c = 'Active'
                                                  order by tc9_ti__Project_Code__r.Name])
                job_ProjectCodes.get(projCode.tc9_ti__Job_Order__c).add(new SelectOption(projCode.tc9_ti__Project_Code__r.Id, projCode.tc9_ti__Project_Code__r.Name));
        }
        
        system.debug('******* ISEDIT ' + isEdit);

    }
    
    /**
        For all the timesheets in the tsList (refreshed initially & during save action), populate the bp values
    **/
    private void updateAllBPTables(){
        
        //get Timesheet entry Ids from the newly queried timesheets list
        Set<ID> tseId= new Set<ID>();
        for(tc9_ti__Time_Sheet__c ts : tsList){
            if(ts.tc9_ti__Time_Sheet_Entries__r != null && ts.tc9_ti__Time_Sheet_Entries__r.size()>0){
                for(tc9_ti__Time_Sheet_Entry__c tse :ts.tc9_ti__Time_Sheet_Entries__r )
                    tseId.add(tse.Id);
            }
        }
        
        //simulate transaction creation
        AwardHelper awf             = new AwardHelper();
        List<tc9_ti__Transaction__c> trans = awf.simulateTransactionsForTSE(tseId);
        System.debug('$$$$ Constructor Pringting transaction records - Start' + trans.size());
        for(tc9_ti__Transaction__c t : trans) {
            System.debug(t);
        }
        System.debug('$$$$ Constructor Pringting transaction records - End');
        if(trans == null){
            system.debug('ERROR message -- : ' + awf.getErrorString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error : ' + awf.getErrorString()));
        }
        else{
            Map<Id, Map<Date,TransactionSimulatorWrapper.Simulator>> simulatorMap   = AwardHelper.getTransactionForTimesheets(trans);
            fillAllBPValues(simulatorMap);
        }
        system.debug('**' + simWrapMap);
    }
    
    /**
        For the selected timesheet, populate the bp values
    **/
    public void getUpdateTable(){
        
        //get the page parameters
        Integer jobRow = Integer.valueOf( ApexPages.currentPage().getParameters().get('jobNumber'));
        Integer tsRow = Integer.valueOf( ApexPages.currentPage().getParameters().get('tsNumber'));
        
        //retreive the job,timesheet and the expense clicked
        JobWrapper thisJob =  jobWList.get(jobRow);
        TimeSheetWrapper thisTS = thisJob.timeSheetWList.get(tsRow);
        
        upsert thisTs.tseList;
        
        Set<Id> tseId = new Set<Id>();
        for(tc9_ti__Time_Sheet_Entry__c tse : thisTs.tseList)
            tseId.add(tse.Id);
        
        AwardHelper awf             = new AwardHelper();
        List<tc9_ti__Transaction__c> trans  = awf.simulateTransactionsForTSE(tseId);
        System.debug('$$$$ Pringting transaction records - Start' + trans);
        for(tc9_ti__Transaction__c t : trans) {
            System.debug(t);
        }
        System.debug('$$$$ Pringting transaction records - End');
        if(trans == null){
            system.debug('ERROR message -- : ' + awf.getErrorString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error : ' + awf.getErrorString()));
        }
        else{
            Map<Id, Map<Date,TransactionSimulatorWrapper.Simulator>> simulatorMap   = AwardHelper.getTransactionForTimesheets(trans);
            fillAllBPValues(simulatorMap);
        }
    }
    
    /**
        For the calculations map passed, populate the displayed map
    **/
    void fillAllBPValues(Map<Id, Map<Date,TransactionSimulatorWrapper.Simulator>> simulatorMap){
        
        //for each timesheet details
        system.debug('TESTTTTTTTMap: '+simulatorMap);
        system.debug('ts_AwardMaster '+ts_AwardMaster);
        system.debug('awardMaster_Breakpoints '+awardMaster_Breakpoints);
        for(Id tsId : simulatorMap.keySet()){
            
            //new wrapper
            TransactionSimulatorWrapper simWrapObj  = new TransactionSimulatorWrapper();
            
            //get the map, and add '0' against undefined breakpoints
            Map<Date,TransactionSimulatorWrapper.Simulator> mapForATS = simulatorMap.get(tsId);

            List<String> allBreakpoints         = new List<String>();
            
            if(ts_AwardMaster.containsKey(tsId) && awardMaster_Breakpoints.containsKey(ts_AwardMaster.get(tsId))){
                allBreakpoints         = awardMaster_Breakpoints.get(ts_AwardMaster.get(tsId));
            }
            system.debug('allBreakpoints '+ allBreakpoints);
            
            for(TransactionSimulatorWrapper.Simulator simulatorObj : mapForATS.values()){
                
                //get breakpoints map               
                Set<String> calculatedBreakpoints   = simulatorObj.type_Hours.keySet();
                
                //get all relevant breakpoints for the timesheet and add missing values in map
                for(String s : allBreakpoints)
                    if(!calculatedBreakpoints.contains(s))
                        simulatorObj.type_Hours.put(s, 0);
            }
            
            //add it to simulator object
            simWrapObj.breakpoints  = allBreakpoints;
            simWrapObj.simMap       = mapForATS;
            
            simWrapMap.put(tsId, simWrapObj);
        }
        
        list <tc9_ti__Time_Sheet_Entry__c> timesheetEntries = new list <tc9_ti__Time_Sheet_Entry__c>();
            
         for(tc9_ti__Time_Sheet__c ts : tsList){
            
            Date sDate;
            List<String> allBreakpoints         = new List<String>();
            if(ts_AwardMaster.containsKey(ts.Id) && awardMaster_Breakpoints.containsKey(ts_AwardMaster.get(ts.Id)))
                allBreakpoints = awardMaster_Breakpoints.get(ts_AwardMaster.get(ts.Id));
            timesheetEntries = [select tc9_ti__WorkDate__c, tc9_ti__Work_Week_End_Date__c from tc9_ti__Time_Sheet_Entry__c where tc9_ti__Time_Sheet__c =: ts.id order by  tc9_ti__WorkDate__c];
            Integer numberOfEntries = timesheetEntries.size(); 
            if(numberOfEntries > 0)   
                sDate = timesheetEntries[0].tc9_ti__WorkDate__c;
            if(!simWrapMap.keySet().contains(ts.Id)){
                //new wrapper
                TransactionSimulatorWrapper simWrapObj  = new TransactionSimulatorWrapper();
                
                //get the map, and add '0' against undefined breakpoints
                Map<Date,TransactionSimulatorWrapper.Simulator> mapForATS = new Map<Date, TransactionSimulatorWrapper.Simulator>();
                
                if(numberOfEntries > 0) {
                Date startDate = timesheetEntries[0].tc9_ti__WorkDate__c;
                Date endDate = startDate.addDays(timesheetEntries.size()-1);

                

                Integer i =0;

                

                system.debug('startDateeee '+startDate); 
                system.debug('endDateeeee '+endDate); 

                

                for(;startDate <= endDate ;){
                    TransactionSimulatorWrapper.Simulator simulatorObj = new TransactionSimulatorWrapper.Simulator();
                    simulatorObj.workDate = startDate;
                    simulatorObj.type_Hours = new Map<String, Decimal >();

                    

                    startDate = startDate.addDays(1);

                    

                    system.debug('startDateeee '+startDate); 
                    system.debug('simulatorObj.workDateDateeeee '+simulatorObj.workDate);
                    //get all relevant breakpoints for the timesheet and add missing values in map
                    for(String s : allBreakpoints)                 
                        simulatorObj.type_Hours.put(s, 0);
                    mapForATS.put(simulatorObj.workDate,simulatorObj);

                }

                
                
                //add it to simulator object
                simWrapObj.breakpoints  = allBreakpoints;
                simWrapObj.simMap       = mapForATS;
                
                simWrapMap.put(ts.Id, simWrapObj);
                }
            }

            else if(simWrapMap.containsKey(ts.Id)) {
                TransactionSimulatorWrapper simObj = simWrapMap.get(ts.Id);
                
                //new wrapper
                Map<Date,TransactionSimulatorWrapper.Simulator> mapForATS  = simObj.simMap;
                
                for(Integer i=0;i<numberOfEntries;i++){
                    if(sDate != null && !mapForATS.containsKey(sDate.addDays(i))){
                        
                        TransactionSimulatorWrapper.Simulator simulatorObj = new TransactionSimulatorWrapper.Simulator();
                        
                        simulatorObj.workDate = ts.tc9_ti__Start_Date__c.addDays(i);
                        simulatorObj.type_Hours = new Map<String, Decimal >();
                        
                        //get all relevant breakpoints for the timesheet and add missing values in map
                        for(String s : allBreakpoints)                  
                            simulatorObj.type_Hours.put(s, 0);
                        mapForATS.put(simulatorObj.workDate,simulatorObj);
                    }
                }
            }
        }
    }
    
    /**
        For a given award master, return the list of unique breakpoints under its rules + leave types
    **/
    public List<String> getBreakpointsInOrder(Id awrdMasterId){
        
        Set<String> tempString = new Set<String>();
        List<String> bpListInOrder = new List<String>();


        List<tc9_ti__Rule__c> rulesSortedByMultiplier = new List<tc9_ti__Rule__c>();
        
        if(awardMasterMap.containskey(awrdMasterId)) {
            rulesSortedByMultiplier = AwardHelper.sortRulesByAField(awardMasterMap.get(awrdMasterId).tc9_ti__Rules__r, 'Pay_Multiplier__c');
        }
        for(tc9_ti__Rule__c rule : rulesSortedByMultiplier){
            
            String multiplierStr = rule.tc9_ti__Pay_Multiplier__c + 'x';
            if(multiplierStr=='0.00x' || multiplierStr=='nullx')
                continue;
            if(multiplierStr == '1.00x')
                multiplierStr = 'REG';
            else if(multiplierStr == '1.50x')
                multiplierStr = 'OT';
            else if(multiplierStr == '2.00x')
                multiplierStr = 'DT';
            
            if(!tempString.contains(multiplierStr))
                bpListInOrder.add(multiplierStr);
            
            tempString.add(multiplierStr);
        }
        
        String namespace = ''; 
        if(Schema.getGlobalDescribe().get('Time_Sheet_Entry__c') == null)
            namespace   = 'tc9_ti__';
        
       list<tc9_ti__Rule__c> typeOfLeaves ;
        typeOfLeaves = new list<tc9_ti__Rule__c>([select Id, Name ,tc9_ti__Award_Master__c,tc9_ti__Award_Master__r.tc9_ti__Restrict_Leave_Types__c,tc9_ti__Hide_Option_In_Portal__c from tc9_ti__Rule__c where tc9_ti__Hide_Option_In_Portal__c = false and tc9_ti__Award_Master__c =:awrdMasterId]);
           Schema.DescribeFieldResult fieldResult = tc9_ti__Time_Sheet_Entry__c.tc9_ti__Type_of_Leave__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            set<String> typeOfLeavesInTimeSheetEntry = new set<String> ();  
            for (Schema.PicklistEntry a : ple ) { 
              typeOfLeavesInTimeSheetEntry.add(a.getValue());//add the value  to our list


           }
            


            system.debug('leaveeeeee1 '+typeOfLeavesInTimeSheetEntry);
           
            if(typeOfLeaves[0].tc9_ti__Award_Master__r.tc9_ti__Restrict_Leave_Types__c){
                for(tc9_ti__Rule__c temp :typeOfLeaves){
                    if(typeOfLeavesInTimeSheetEntry.contains(temp.Name)){
                        bpListInOrder.add(temp.Name);


                    }
                }   


            }
            else if(!typeOfLeaves[0].tc9_ti__Award_Master__r.tc9_ti__Restrict_Leave_Types__c){
                for(String s : typeOfLeavesInTimeSheetEntry){
                    bpListInOrder.add(s);


                }
                    


            }
            return bpListInOrder;
    }        
    
    private void getTsList(){
        
        Integer daysFrom;
        Date targetDate;
        //get the details from custom settings
        tc9_ti__ToCloudNineConfig__c conf   = tc9_ti__ToCloudNineConfig__c.getInstance();
        if(conf != null)
            daysFrom            = (Integer)conf.tc9_ti__Days_til_Current_Timesheet_Visible__c;
        
        //fix the day, untill which timesheet headers should be queried
        if(daysFrom == null || daysFrom == 0 )
            targetDate      = toDay;
        else
            targetDate      = toDay.addDays(-daysFrom);
            
        Id shiftPlcId = UtilClass1.getTypeId_ByDeveloperName('ts2__Placement__c','Shift');
        
        // get all the timesheet list which are able to view or editable
        // As timesheet which status are rejected and new should be able to edit and status is submitted should be able to view. 
        tsList = [Select tc9_ti__Start_Date__c, Id, tc9_ti__End_Date__c, tc9_ti__Candidate__c, tc9_ti__Candidate__r.tc9_ti__TaxFileNum__c, tc9_ti__Status__c, tc9_ti__WeeklyActualHours__c,
                         tc9_ti__Placement__c, tc9_ti__Placement__r.ts2__Job__c, tc9_ti__Placement__r.ts2__Job__r.Name, tc9_ti__Placement__r.ts2__Job__r.tc9_ti__Client_Name__c,
                         tc9_ti__Placement__r.tc9_ti__Timesheet_Entry_Format__c, Name, 
                         (Select Id, Name, tc9_ti__Start__c, tc9_ti__End__c, tc9_ti__EndTime__c, tc9_ti__StartTime__c, tc9_ti__Status__c, tc9_ti__IsPublicHoliday__c, 
                                tc9_ti__Notes_Talent__c, tc9_ti__WorkDate__c, tc9_ti__BreakTime__c, tc9_ti__BreakTime2__c, tc9_ti__HoursAcutal__c, tc9_ti__WorkDay__c, tc9_ti__ViewFlag__c, 
                                tc9_ti__Hours_Expected__c,tc9_ti__Total_Time_hours__c,tc9_ti__Total_Time_mins__c, tc9_ti__Total_Hours__c, 
                                tc9_ti__Type_of_Leave__c,
                                tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Job__r.Name,
                                tc9_ti__Project_Code__c, tc9_ti__Project_Code_Name__c
                          from tc9_ti__Time_Sheet_Entries__r 
                          where tc9_ti__Status__c in : showableTsSet
                          order by tc9_ti__WorkDate__c  
                         )     
                  From tc9_ti__Time_Sheet__c 
                  Where tc9_ti__Status__c in : showableTsSet AND tc9_ti__Candidate__c = :conId AND tc9_ti__Start_Date__c <= : targetDate 
                        AND tc9_ti__Placement__r.RecordTypeId != : shiftPlcId
                  order by tc9_ti__Time_Sheet__c.tc9_ti__Start_Date__c];
        
        //collect job and timesheet IDs
        Set<Id> jobIds  = new Set<Id>();
        Set<ID> tsIDs   = new Set<ID>(); 
        for(tc9_ti__Time_Sheet__c objTEst : tsList){
            jobIds.add(objTEst.tc9_ti__Placement__r.ts2__Job__c);
            tsIDs.add(objTest.Id);
        }
        
        //get the existing expenses and build a map of timesheet and expenses
        Map<ID,List<tc9_ti__Expense__c>> ts_expense = new Map<ID,List<tc9_ti__Expense__c>>();
        for(tc9_ti__Expense__c   exp : [SELECT id,tc9_ti__Date_Incurred__c,
                                        tc9_ti__Title__c,tc9_ti__Type__c,tc9_ti__Taxable__c,
                                        tc9_ti__Value__c,tc9_ti__Tax_Amount__c,
                                        tc9_ti__Time_Sheet__c
                               FROM tc9_ti__Expense__c 
                               WHERE tc9_ti__Time_Sheet__c in :tsIDs
                               order by createdDate]){
            if(ts_expense.containsKey(exp.tc9_ti__Time_Sheet__c))
                ts_expense.get(exp.tc9_ti__Time_Sheet__c).add(exp);
            else

                ts_expense.put(exp.tc9_ti__Time_Sheet__c,new List<tc9_ti__Expense__c>{exp});                                
        }
        
        //get the existing Attachments and build a map of timesheet and attachments
        Map<ID,List<Attachment>> ts_attachments = new Map<ID,List<Attachment>>();
        for(Attachment att : [SELECT id, Name, Body, ParentId
                               FROM Attachment 
                               WHERE ParentId in :tsIDs
                               order by createdDate]){
            if(ts_attachments.containsKey(att.ParentId))
                ts_attachments.get(att.ParentId).add(att);
            else

                ts_attachments.put(att.ParentId, new List<Attachment>{att});                                
        }
                                                  
        jobWList = new List<JobWrapper>();
        
        TimeSheetWrapper tempTSWrap; 
        for(tc9_ti__Time_Sheet__c objTEst : tsList){
            
            //initialize a new wrapper for TimeSheet with TS,TSE,Expenses
            if(ts_expense.containsKey(objTest.Id)){
                if(ts_attachments.containsKey(objTest.Id)){                
                    tempTSWrap = new TimeSheetWrapper(objTest,ts_expense.get(objTest.Id), ts_attachments.get(objTest.Id));                
                }else{                
                    tempTSWrap = new TimeSheetWrapper(objTest,ts_expense.get(objTest.Id), new List<Attachment>());
                }
            }else{
                if(ts_attachments.containsKey(objTest.Id)){                
                    tempTSWrap = new TimeSheetWrapper(objTest,new List<tc9_ti__Expense__c>(), ts_attachments.get(objTest.Id));
                }else{                
                    tempTSWrap = new TimeSheetWrapper(objTest,new List<tc9_ti__Expense__c>(), new List<Attachment>());
                }
            }
            tempTSWrap.isHours = UtilClass1.setEntryType(isTimeSheetEntryInHours, objTest.tc9_ti__Placement__r.tc9_ti__Timesheet_Entry_Format__c);
            //populate the list
            populateWrapperList(tempTSWrap);
        }
    }
    
    //change mode to edit from save
    global PageReference EditPage(){
        isEdit = true;
        return null;
    }  
    
    //take User to Custom Expense Page
    global PageReference GoToCustomExpensePage(){

        

        Integer jobRow = Integer.valueOf( ApexPages.currentPage().getParameters().get('jobNumber'));
        Integer tsRow = Integer.valueOf( ApexPages.currentPage().getParameters().get('tsNumber'));

        JobWrapper thisJob =  jobWList.get(jobRow);
        TimeSheetWrapper thisTS = thisJob.timeSheetWList.get(tsRow);
        
        if(strCustomExpensePage != ''){
            strTimesheetId = thisTS.timeSheet.Id;           
        }else{

            

        }
        return NULL;
    }     
    
    //submit a particular timesheet
    //submission changes the status of TS,TSE
    global PageReference doSubmit(){
        String strId = ApexPages.currentPage().getParameters().get('one'); // get submitted Id from page
        if(strId != null)
            strId = String.escapeSingleQuotes(strId);

        //get the details of the timesheet and update the statuses
        List<tc9_ti__Time_Sheet__c> submittedTsList = [Select tc9_ti__Status__c, 
                                                  ( Select Id, Name, tc9_ti__Status__c,  
                                                        tc9_ti__ViewFlag__c 
                                                       FROM tc9_ti__Time_Sheet_Entries__r order by tc9_ti__WorkDate__c
                                                  )     
                                              From tc9_ti__Time_Sheet__c 
                                              Where Id =: strId];
        
        //list to update
        List<tc9_ti__Time_Sheet_Entry__c> tSEUpdateList = new List<tc9_ti__Time_Sheet_Entry__c>();
        List<tc9_ti__Time_Sheet__c> tsUpdateList = new List<tc9_ti__Time_Sheet__c>();

        //change the status
        for (tc9_ti__Time_Sheet__c ts : submittedTsList ){
            for (tc9_ti__Time_Sheet_Entry__c tse : ts.tc9_ti__Time_Sheet_Entries__r){
                if (tse.tc9_ti__Status__c.equals(TSSTATUSNEW) || tse.tc9_ti__Status__c.equals(TSSTATUSREJECTED)){
                    tse.tc9_ti__ViewFlag__c = 0;     // set the timesheet entry is not been viewd               
                    tse.tc9_ti__Status__c = TSSTATUSSUBMITTED; //set timesheet entry status is submitted
                    tSEUpdateList.add(tse);
                }
            }
            ts.tc9_ti__Status__c = TSSTATUSSUBMITTED;
            tsUpdateList.add(ts);
        }    
        Savepoint sp;  
               
        try{
            sp = Database.setSavepoint();
            update tSEUpdateList;   //first update the TSE, then TS
            update tsUpdateList;
            isSubmit = true;
            
            String pageURL = Page.PortalFillTimesheet.getUrl();           //updated in Sprint-2
            if(pageURL.startsWith('/'))
                pageURL = pageURL.subString(1);
            PageReference pageRef = new PageReference(Site.getBaseUrl()+pageURL); 
            pageRef.setRedirect(true);
            return pageRef;
            
        }catch(DMLException e){
                system.debug( e.getMessage());
                Database.rollback(sp);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
                ApexPages.addMessage(myMsg); 
        }

        return null;
    }
    
    //method called to save all the timesheet entries updated with times
    global PageReference Save(){
        system.debug('@@@@@@ '+StringId);
        boolean error = false;
        Isexception = false;
        String errMsg = '';
        
        //list of TSE to be updated
        List<tc9_ti__Time_Sheet_Entry__c    > updateList = new List<tc9_ti__Time_Sheet_Entry__c >();
        
        //update the TSE,iterating through Job,TS,TSE
        for(JobWrapper jWrap : jobWList)
            for (TimeSheetWrapper tsWrap : jWrap.timeSheetWList ){
                for (tc9_ti__Time_Sheet_Entry__c tse : tsWrap.tseList){
                    updateList.add(tse);
                }
            }

        if (error)
            return null; 
        
        //save the timesheets if there is not error
        Savepoint sp;
        try{
            sp = Database.setSavepoint();
            update updateList;
            system.debug('@@@@@@ ');
            //query all data again
            getTsList(); 
            isEdit = false;
            
            if(showSection.get('BreakpointTable'))
                updateAllBPTables();
        }catch(DMLException e){
            Database.rollback(sp);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(myMsg); 
            Isexception = true;
        }
        return null; 
    }
}