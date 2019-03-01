/*
        Class           :   Ctrl_FillTimeSheet_v2.cls
        @Author:        :   Ponni Priyadharshni
        @Description    :   Controller for FillTimesheet_Page_v2 
        @TestClass:         TestCtrl_FillTimeSheet_v2
        
     Change History 
    
    *************************************************************************************************************************************************************************************
        SCRUM        ModifiedBy       Date            Requested By                                       Description                                                Tag
    *************************************************************************************************************************************************************************************
       SC-8799       Khushboo.B     05/08/2015        David Levy                Adding option to enable leave display based on custom setting
       SC-10111      Srinidhi.R     10/12/2015        Michelle Cole             Auto Approve Timesheet Submitted IF Timesheets = 0
       SC-10160      Srinidhi.R     04/01/2016        Jacob Mortan              Error upon landing on ApproverDetailPage when clicking on Timesheet in Approval Portal
       SC-10382      Srinidhi.R     16/02/2016        David Levy                If User Is AUD and TSE is USD...and i add TSE line in portal or TSM...= currency issue
       SC-10633      Jagadeswary.S  28/03/2016        David Levy                Display Candidate Name in Approver detail page
       SC-10675      Jagadeswary.S  01/04/2016        Jacob Morton              Timesheets + Timesheet entries reverting statuses from Approved to Submitted
       SC-10803      Khushboo.B     24/05/2016        Michelle Cole             Updating the entry type based on the related placement for the approverDetail and Filltimesheet page v2
       SC-11221      Khushboo.B     16/06/2016        Angela Sutherland         Resolving the invalid date error on portal screen
       SC-11622      Jagadeswary    22/09/2016        Michelle                  candidates view/change attachments via communities
       SC-10841      Jagadeswary    23/09/2016        Guy Baxter                Flag for Timesheet Entries created by standard tcs timesheet generation process
       SC-13999      Jagadeswary    01/11/2016         Michelle Cole            Timesheet Manager Attachments
       SC-14595      Jagadeswary    20/03/2017        David Levy                Approver Email does not populate on TImesheet 
       SC-17381      Jagadeswary    18/08/2017         Michelle Cole        tax treatment for Expenses 
       
*/
public class Ctrl_FillTimeSheet_v2{
    
    public Map<String,boolean> showSection {get;set;}
    public Boolean projCodeView {get;set;}
    public boolean isNext{get;set;}
    public boolean isPrev{get;set;}
    public boolean toDisplay12HourFormat {get;set;}
    public String hide12HourToggle {get;set;}
    public String UserTimeFormat{get;set;}
    public String UserTimesheetFormat {get;set;}
    public String TimesheetFormatFromPage {get;set;}
    private boolean is12HourFormatConfig;
    public String PageName_Notes_TS{get;set;}
    public List<SelectOption> leaveList{get;set;}
    public List<SelectOption> options{get;set;}
    public String reason {get;set;}
    public list<tc9_ti__Rule__c> typeOfLeaves {get;set;}
    public String ApproverLogo {get;set;}
    public boolean showCustomizedResource{get;set;}
    public boolean isLogout {get;set;}
    public boolean displayPopup {get; set;}     
    //data entities
    public tc9_ti__Time_Sheet__c timesheet{get;set;}
    public List<tc9_ti__Time_Sheet_Entry__c> tseList{get;set;}
    public List<ExpensesWrapper> expenseWList{get;set;}
    public Contact currentContact {get;set;}
    //string holders
    public String JobName {get;set;}
    public String ClientName {get;set;}
    public String CandidateName {get;set;}
    public String strCustomExpensePage {get;set;}
    public String strCustomExpenseButtonLabel {get;set;}
    public boolean controlPageMsg {get;set;}
    private String TSSTATUSSUBMITTED = 'Submitted';
    private String TSSTATUSNEW = 'New';
    private String TSSTATUSREJECTED = 'Rejected';
    private String TSSTATUSAPPROVED = 'Approved';
    public List<Attachment> listOfAttachmentsToBeDisplayed {get;set;}
    String manualReason;
    public Boolean isTseAvail {get;set;}
    public String leaveName {get;set;}
    public List<SelectOption> ProjectCodes{get;private set;}
    public Integer index{get; set;}
    public String expenseIdForAttach {get;set;}
    public String PageName_AddAttachment{get;set;}
    public String PageName_CustomExpensePage{get;set;}
    public String Page_FillTimeSheet {get;set;}
    public String Page_PrintTimeSheetEntry {get;set;}
    public String PageName_ApproverDetail {get;set;}
    public String Locale{get;set;}
    
    public tc9_ti__ToCloudNineConfig__c conf {get;set;}
    private Id plctId;
    
    public List<tc9_ti__Time_Sheet__c> allTSListofCand;
    public List<tc9_ti__Time_Sheet__c> currentNavList;
    public List<tc9_ti__Time_Sheet__c> oDueNavList;
    public List<tc9_ti__Time_Sheet__c> TSHNavList;
    public List<tc9_ti__Time_Sheet__c> SUBNavList;
    public string BaseURL{get;set;}
    public Set<Id> expIds;
    public String currentAttachId {get;set;}
    public Ctrl_FillTimeSheet_v2(){
        isLogout = false;
        try{
            BaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            leaveName = '';
            Id tsId = ApexPages.currentPage().getParameters().get('tsId');
            //system.debug('!!tsid:'+tsId);
            timesheet = new tc9_ti__Time_Sheet__c(id=tsId);
            system.debug('timesheeeeetId '+timesheet);
            PageName_Notes_TS =UtilClass1.getAPIName('AddNotesCustomer');
            String UserId = Userinfo.getUserId();
            User userlocale = [select Localesidkey,tc9_ti__Timesheet_Time_Format__c,Contact.tc9_ti__Timesheet_Time_Format__c from user where id =: UserId];
            if(userlocale != null)
                Locale = userlocale.LocaleSidKey;
            else
                Locale = 'en_US';
            controlPageMsg = false;
            UserTimeFormat = userlocale.Contact.tc9_ti__Timesheet_Time_Format__c;
            //system.debug('!!!user:'+userlocale);
            if(UserTimeFormat == null)
                UserTimeFormat = 'Default';
            listOfAttachmentsToBeDisplayed = new List<Attachment>();    
            projCodeView = false;
            strCustomExpensePage= '';
            strCustomExpenseButtonLabel = '';
            //expenseIdForAttach = 'something';
            //get the details from custom settings
            conf   = tc9_ti__ToCloudNineConfig__c.getInstance();
            showSection                     = new Map<String,boolean>();
            showSection.put('Enable Expense', conf.tc9_ti__Include_Expense__c);
            showSection.put('BreakpointTable', conf.tc9_ti__Display_Breakpoint_Table__c);
            showSection.put('ProjectCodes',conf.tc9_ti__Enable_Project_Codes__c);
            showSection.put('ProjectCodesButton', conf.tc9_ti__Display_Add_Project_Codes_Button__c);
            showSection.put('IncludeAttachForTS', conf.tc9_ti__Include_Attachments_for_Timesheet__c);
            showSection.put('Break2',conf.tc9_ti__Display_Break2__c);
            showSection.put('IsManualReasonPresent', conf.tc9_ti__Manual_Approval_Reason__c == null ? false : true);
            showSection.put('EnableCustomExpense',conf.tc9_ti__Enable_Custom_Expense_Page__c);
            showSection.put('NewButton',conf.tc9_ti__Enable_New_for_Portal__c);
            showSection.put('LeaveButton',conf.tc9_ti__Enable_Leave_for_Portal__c);
            ApproverLogo = conf.tc9_ti__Approver_Page_Logo__c;  
            showCustomizedResource =false;

            List<StaticResource> staticResource;
            Set <String> resourceTypeList = new Set<String> {'JPEG','JPG','PNG','jpeg','jpg','png'};
            if(ApproverLogo != '' || ApproverLogo != null){
                staticResource = new List<StaticResource >([select Id, BodyLength, ContentType from StaticResource where Name =: ApproverLogo]);
                if(!staticResource.isEmpty() && (staticResource[0].BodyLength <= 1048576 || resourceTypeList.contains(staticResource[0].ContentType))){
                    showCustomizedResource = true;
                }
            }
            Boolean hide12Hour = conf.tc9_ti__Hide_Time_Format_Toggle__c;
            if(hide12Hour)
                hide12HourToggle = 'Yes';
            else
                hide12HourToggle = 'No';
            is12HourFormatConfig = conf.tc9_ti__X12_Hour_Timesheet_Format__c;
            if(UserTimeFormat=='24 Hour')
                toDisplay12HourFormat = false;
                
            else if(UserTimeFormat == '12 Hour')
                toDisplay12HourFormat = true;
                   
            else if(UserTimeFormat == 'Default' && is12HourFormatConfig == false)
                toDisplay12HourFormat = false;
                 
            else if(UserTimeFormat == 'Default' && is12HourFormatConfig == true)
                toDisplay12HourFormat = true;
               
           if(toDisplay12HourFormat == true)
                UserTimesheetFormat = '12 Hour';
            else
                UserTimesheetFormat = '24 Hour';
               
                System.debug('&&&toDisplay12HourFormat--->'+toDisplay12HourFormat);
            manualReason = conf.tc9_ti__Manual_Approval_Reason__c;
            // ********************* POPULATE TIMESHEET ENTRIES ********************    
            getTsList(); 
            
            showSection.put('Time',UtilClass1.setEntryType(conf.tc9_ti__TimeSheet_Entry_Hours__c, timesheet.tc9_ti__Placement__r.tc9_ti__Timesheet_Entry_Format__c));    
            
            projectCodeOption();
                
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
               
            PageName_AddAttachment = UtilClass1.getAPIName('Community_AddAttachments');
            PageName_CustomExpensePage = UtilClass1.getAPIName(strCustomExpensePage);
            Page_FillTimeSheet = UtilClass1.getAPIName('FillTimesheet_Page');
            Page_PrintTimeSheetEntry = UtilClass1.getAPIName('PrintTimeSheetEntry'); 
            PageName_ApproverDetail =UtilClass1.getAPIName('ApproverDetailPage');
            
            String token = ApexPages.currentPage().getParameters().get('token');
            system.debug('tokennn '+token);
            if(token!= null){
                currentContact = [Select Id,Name,Email, FirstName,tc9_ti__Link_Token__c, LastName, Account.Name, AccountId, tc9_ti__Link_Token_Expiry__c from Contact where Id =: token];    
            }
            
                
            if(timesheet != null){
                allTSListofCand = new List<tc9_ti__Time_Sheet__c>();
                currentNavList = new List<tc9_ti__Time_Sheet__c>();
                oDueNavList = new List<tc9_ti__Time_Sheet__c>();
                TSHNavList = new List<tc9_ti__Time_Sheet__c>();
                SUBNavList = new List<tc9_ti__Time_Sheet__c>();    
                plctId = timesheet.tc9_ti__Placement__c;
                Id candId = timesheet.tc9_ti__Candidate__c;
                if(currentContact!= null)
                Id contId = currentContact.Id;
                String strQuery ;
                if(ApexPages.currentPage().getParameters().get('list')=='SUB'){
                    strQuery = ' SELECT Id, tc9_ti__Start_Date__c, Name, tc9_ti__End_Date__c, tc9_ti__Status__c, tc9_ti__Placement__c ';
                    strQuery        += ' FROM tc9_ti__Time_Sheet__c ';
                    strQuery        += ' WHERE (tc9_ti__Placement__r.tc9_ti__TimeSheetApprover__c =: contId OR tc9_ti__Placement__r.tc9_ti__AlternativeTimeSheetApprover__c =: contId) ';
                    strQuery        += ' AND  tc9_ti__Status__c =: TSSTATUSSUBMITTED ';
                    
                    strQuery        += ' ORDER BY tc9_ti__Start_date__c ';
                }
                else{
                    strQuery  = ' SELECT Id, tc9_ti__Start_Date__c, Name, tc9_ti__End_Date__c, tc9_ti__Status__c, tc9_ti__Placement__c ';
                    strQuery        += ' FROM tc9_ti__Time_Sheet__c ';
                    strQuery        += ' WHERE tc9_ti__Candidate__c =: candId AND tc9_ti__Placement__c =: plctId ';
                    if(ApexPages.currentPage().getParameters().get('list')!='TSH')
                        strQuery        += ' AND ( tc9_ti__Status__c =: TSSTATUSNEW OR tc9_ti__Status__c =: TSSTATUSSUBMITTED OR tc9_ti__Status__c =: TSSTATUSREJECTED ) ';
                    else
                        strQuery        += ' AND ( tc9_ti__Status__c =: TSSTATUSAPPROVED ) ';
                    strQuery        += ' ORDER BY tc9_ti__Start_date__c ';
                }
                
                //system.debug('!@#$% strQuery '+strQuery);
                    
                allTSListofCand = Database.query(strQuery);
                system.debug('!allTSListofCand'+allTSListofCand );
                Date thisDate = date.today();
                if(!allTSListofCand.isEmpty()){
                    if(ApexPages.currentPage().getParameters().get('list')!='TSH'){
                        for(tc9_ti__Time_Sheet__c thisTS: allTSListofCand){
                            if(thisTS.tc9_ti__Status__c == TSSTATUSSUBMITTED || thisTS.tc9_ti__Status__c == TSSTATUSNEW || thisTS.tc9_ti__Status__c == TSSTATUSREJECTED){
                                SUBNavList.add(thisTS);
                                if(thisTS.tc9_ti__Start_Date__c <= thisDate){
                                    if(thisTS.tc9_ti__End_Date__c >= thisDate){
                                        currentNavList.add(thisTS);
                                    }
                                    else{
                                        oDueNavList.add(thisTS);
                                    }
                                }
                            }
                        }
                    }
                    else{
                        TSHNavList.addall(allTSListofCand);
                    }
                    system.debug('SubLissst '+SUBNavList);    
                    if(ApexPages.currentPage().getParameters().get('list')!='TSH'){
                        if(ApexPages.currentPage().getParameters().get('list')=='CU'){
                            navBoolean(currentNavList,'CU');
                        }
                        if(ApexPages.currentPage().getParameters().get('list')=='OD'){
                            navBoolean(oDueNavList,'OD');
                        }
                    }
                    if(ApexPages.currentPage().getParameters().get('list')=='TSH'){
                        navBoolean(TSHNavList,'TSH');
                    }
                    if(ApexPages.currentPage().getParameters().get('list')=='SUB'){
                         system.debug('**SUB.size()'+SUBNavList.size());          
                        navBoolean(SUBNavList,'SUB');
                    }
                        
                }
            }
            //system.debug('**TSHNavList.size()'+TSHNavList.size());        
            fetchAttachments();      
            displayLeaveList();
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }        
    }
    
    public void logout(){
        isLogout = true;
        system.debug('logggg '+isLogout);
    }
    public void deleteAttach(){
    system.debug('===in');
        if(currentAttachId!=null){
            system.debug('==='+currentAttachId);
            Attachment att= new Attachment(id=currentAttachId);
            delete att;
            fetchAttachments();
            refreshExpenses();
        }
    }
    
    public void fetchAttachments(){
        List<Id> expIds = new list<Id>();
        for(ExpensesWrapper exp: expenseWList){
            expIds.add(exp.expense.id);
        }
        system.debug('Expenseeee '+expenseWList);
        system.debug('Expenseeee '+expIds);
        listOfAttachmentsToBeDisplayed = new List<Attachment>([SELECT BodyLength,ContentType,CreatedDate,Description,Id,Name,OwnerId,ParentId FROM Attachment where (parentId =: timesheet.Id OR parentId in: expIds)and OwnerId in (select Id from user where IsPortalEnabled = true)]);
        
    }
    
    public void displayLeaveList() {
        
        List<ts2__Placement__c> placement = new List<ts2__Placement__c>();
        placement = [select Id, tc9_ti__Award_Master__c from ts2__Placement__c where Id =: plctId];
        if(placement.size()>0){
            typeOfLeaves = new list<tc9_ti__Rule__c>([select Id, Name ,tc9_ti__Award_Master__c,tc9_ti__Award_Master__r.tc9_ti__Restrict_Leave_Types__c,tc9_ti__Hide_Option_In_Portal__c from tc9_ti__Rule__c where tc9_ti__Hide_Option_In_Portal__c = false and tc9_ti__Award_Master__c =:placement[0].tc9_ti__Award_Master__c]);
          
         Schema.DescribeFieldResult fieldResult = tc9_ti__Time_Sheet_Entry__c.tc9_ti__Type_of_Leave__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            set<String> typeOfLeavesInTimeSheetEntry = new set<String> ();  
            for (Schema.PicklistEntry a : ple ) { 
                typeOfLeavesInTimeSheetEntry.add(a.getValue());//add the value  to our list
            }
            //system.debug('leaveeeeee1 '+typeOfLeavesInTimeSheetEntry);
            leaveList= new List<SelectOption>{new SelectOption('', '-None-')};
            if(typeOfLeaves[0].tc9_ti__Award_Master__r.tc9_ti__Restrict_Leave_Types__c){
                for(tc9_ti__Rule__c temp :typeOfLeaves){
                    if(typeOfLeavesInTimeSheetEntry.contains(temp.Name)){
                        leaveList.add(new SelectOption(temp.Name,temp.Name));
                    }
                }   
            }
            else if(!typeOfLeaves[0].tc9_ti__Award_Master__r.tc9_ti__Restrict_Leave_Types__c){
                for(String s : typeOfLeavesInTimeSheetEntry){
                    leaveList.add(new SelectOption(s,s));
                }
            }
            //system.debug('leavvv '+leaveList);        
        }        
    }

    //public class accountfiltercon {
    Public string selectedname{get;set;}
    public List<SelectOption> getBreakReasons()
    {
    
    List<SelectOption> options = new List<SelectOption>();    
    Schema.DescribeFieldResult fieldResult =
    tc9_ti__Time_Sheet_Entry__c.Missed_Break_Reason__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for( Schema.PicklistEntry f : ple)
        {
      options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
   return options;
    }

//}
    
    public void setUserTimesheetFormat(){
        String UserId = Userinfo.getUserId();
        Contact userContact = [select Localesidkey,tc9_ti__Timesheet_Time_Format__c,Contact.tc9_ti__Timesheet_Time_Format__c from user where id =: UserId].Contact;
        if(TimesheetFormatFromPage == 'true' )
            UserTimesheetFormat = '12 Hour';
        else
            UserTimesheetFormat = '24 Hour';
        if(userContact!=null){  
          userContact.tc9_ti__Timesheet_Time_Format__c = UserTimesheetFormat;          
          update userContact;          
        }        
    }
    
    /*************** for setting the boolean for Navigation buttons *************************/
    public void navBoolean(List<tc9_ti__Time_Sheet__c> thisTSList, String tableIndex){
        String getStr = 'TSIndex'+tableIndex;
        system.debug('%$%'+thisTSList);
        if(thisTSList.size() > 1){
        system.debug('%$%'+ApexPages.currentPage().getParameters().get(getStr));
       system.debug('%@%'+thisTSList.size());
            if(Integer.valueOf(ApexPages.currentPage().getParameters().get(getStr)) == (thisTSList.size() - 1)){
                isNext = false;
                isPrev = true;
            }
            else if(Integer.valueOf(ApexPages.currentPage().getParameters().get(getStr)) == 0){
                isNext = true;
                isPrev = false;
            }
            else{
                isNext = true;
                isPrev = true;
            }
        }
        else{
            isNext = false;
            isPrev = false;
        }
    }
    
    public void projectCodeOption(){
       //project codes
        if(showSection.get('ProjectCodes') && timeSheet.Id != null){
            projectCodes     = new  List<SelectOption>{new SelectOption('', '--None--')};
            for(tc9_ti__Job_Project_Code__c projCode : [SELECT id, tc9_ti__Project_Code__c, tc9_ti__Project_Code__r.Name , tc9_ti__Job_Order__c
                                                FROM tc9_ti__Job_Project_Code__c 
                                                WHERE tc9_ti__Job_Order__c =: timesheet.tc9_ti__Placement__r.ts2__Job__c
                                                      AND tc9_ti__Project_Code__r.tc9_ti__Status__c = 'Active'
                                                      order by tc9_ti__Project_Code__r.Name])
                projectCodes.add(new SelectOption(projCode.tc9_ti__Project_Code__r.Id, projCode.tc9_ti__Project_Code__r.Name));
                
           
        }
                
    }
    /*************************************** populating TSE table ******************************/
    public void getTsList(){
        
        // get the timesheet details
        refreshTimesheet();        
        expenseWList    = new List<ExpensesWrapper>();        
        if(timesheet.Id == null)
            return;            
        refreshExpenses();
       
    }
    
    private void refreshTimesheet(){
        // get the timesheet details
        Id testId = timesheet.Id;
        String strQuery = 'Select tc9_ti__Start_Date__c,Id, Name,tc9_ti__End_Date__c, tc9_ti__Candidate__c, tc9_ti__Candidate__r.Name, tc9_ti__Status__c,tc9_ti__WeeklyActualHours__c,CurrencyISOCode, ';
        strQuery += 'tc9_ti__Rejection_Reason__c, tc9_ti__Manual_Approval_Reason__c, tc9_ti__Comments__c, tc9_ti__Notify_Approver__c, tc9_ti__Notify_Candidate_on_Approval__c, tc9_ti__Notes_Customer__c, ';
        strQuery += 'tc9_ti__Placement__c, tc9_ti__Placement__r.ts2__Job__c, tc9_ti__Placement__r.ts2__Job__r.Name,tc9_ti__Placement__r.ts2__Employee__r.Name, tc9_ti__Placement__r.ts2__Job__r.tc9_ti__Client_Name__c, ';
        strQuery += 'tc9_ti__Placement__r.ts2__Job__r.ts2__Account__c, tc9_ti__Placement__r.tc9_ti__Award_Master__c, tc9_ti__Placement__r.tc9_ti__Timesheet_Entry_Format__c, ';
        
        for(Schema.FieldSetMember f : SObjectType.tc9_ti__Time_Sheet__c.FieldSets.tc9_ti__Time_Sheet_Manager.getFields()){
          string tempStr = String.valueOf(f.getFieldPath()).replaceAll('tc9_ti__','');
          if(!strQuery.contains(tempStr)) {
            strQuery += f.getFieldPath() + ', ';
          }
        }
        strQuery += '( Select Id,test_popup__c, Name, Break_End_Time__c,tc9_ti__ProjectCode__c,tc9_ti__Start__c, tc9_ti__End__c, tc9_ti__EndTime__c, tc9_ti__StartTime__c, tc9_ti__Status__c, tc9_ti__IsPublicHoliday__c,  tc9_ti__Notes_Talent__c, tc9_ti__WorkDate__c, tc9_ti__BreakTime__c, ';
        strQuery += 'tc9_ti__BreakTime2__c, Missed_Break_Reason__c, tc9_ti__Type_of_Leave__c,tc9_ti__HoursAcutal__c, tc9_ti__WorkDay__c, tc9_ti__ViewFlag__c,tc9_ti__Flagged__c, tc9_ti__Hours_Expected__c,tc9_ti__Total_Time_hours__c ,tc9_ti__Total_Time_mins__c,tc9_ti__Total_Hours__c, ';
        strQuery += ' tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Job__r.Name, tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Award_Master__r.RecordTypeId, tc9_ti__Time_Sheet__r.RecordType.DeveloperName, ';
        strQuery += 'tc9_ti__Project_Code__c,tc9_ti__Project_Code_Name__c,tc9_ti__End_Meridian__c,tc9_ti__Start_Meridian__c, tc9_ti__StartTime12Hour__c ,tc9_ti__EndTime12Hour__c,tc9_ti__Method_Created__c   from tc9_ti__Time_Sheet_Entries__r order by tc9_ti__WorkDate__c ) From tc9_ti__Time_Sheet__c ';
        strQuery += 'Where id =: testId';
        
        List<tc9_ti__Time_Sheet__c> tsList = Database.query(strQuery);
         
        timesheet       = new tc9_ti__Time_Sheet__c();
        tseList         = new List<tc9_ti__Time_Sheet_Entry__c>();
        if(!tsList.isEmpty())  {
            timesheet = tsList.get(0);
            if(timesheet.tc9_ti__Time_Sheet_Entries__r != null && timesheet.tc9_ti__Time_Sheet_Entries__r.size() > 0 )
                tseList         = timesheet.tc9_ti__Time_Sheet_Entries__r;
        }
        System.debug('$Time sheet Entry List$-->'+tseList);
        
        if(tseList != null && tseList.size() > 0){
            isTseAvail = true;
        }
        else{
            isTseAvail = false;
        }   
        
        if(timesheet != null){
            JobName = timesheet.tc9_ti__Placement__r.ts2__Job__r.Name;
            CandidateName = timesheet.tc9_ti__Placement__r.ts2__Employee__r.Name;
            Clientname = timesheet.tc9_ti__Placement__r.ts2__Job__r.tc9_ti__Client_Name__c;
        }
    }
    
    public void addNewTSEntry(){
        
        try{
            Integer index = Integer.valueOf(ApexPages.currentPage().getParameters().get('entryNumber')) - 1;
            
            system.debug('index :: ' + index);
            if(index >=0 && index < tseList.size()) {
                system.debug('inside if');
                tseList.add(new tc9_ti__Time_Sheet_Entry__c());
            }
            
            system.debug('tse ::: ' + tseList.size());
            
            for(Integer i= tseList.size()-1; i > index+1 ; i--) {
                tseList.set(i, tseList[i-1]);
            }
            tc9_ti__Time_Sheet_Entry__c tEntry = new tc9_ti__Time_Sheet_Entry__c(tc9_ti__Time_Sheet__c=timesheet.Id,tc9_ti__Status__c=TSSTATUSNEW, tc9_ti__WorkDate__c = tseList.get(index).tc9_ti__WorkDate__c, tc9_ti__Project_Code__c = tseList.get(index).tc9_ti__Project_Code__c,tc9_ti__Method_Created__c = 'Candidate Page Add', tc9_ti__StartTime__c = tseList.get(index).tc9_ti__StartTime__c, tc9_ti__EndTime__c = tseList.get(index).tc9_ti__EndTime__c,CurrencyISOCode=timesheet.CurrencyISOCode);
            tseList[index+1] = tEntry;     
            system.debug('final list ::: '  + tseList);       
        }
        
        
        catch(Exception e){
            system.debug('exception :: ' + e.getmessage()   + e.getlinenumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An error has occurred while creating a new Timesheet Entry. Please contact your Administrator.'));
        }
    }

    
    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {    
    
      index       = Integer.valueOf(ApexPages.currentPage().getParameters().get('entryNumber')) - 1;
        system.debug('***' +  index );    
        displayPopup = true;    
    }
    
    public PageReference SaveN(){
     
     system.debug('in pop up save');
     // system.debug('***' +  tse.Id);
      
       //Integer index = Integer.valueOf(ApexPages.currentPage().getParameters().get('entryNumber')) - 1;
        system.debug('***' +  index );
     tc9_ti__Time_Sheet_Entry__c fromEntry = tseList.get(index);
     system.debug('enrty ::: ' + fromEntry );
     update fromEntry;
     closePopup() ;
     return null;
     
     }
     
    public void fillDown(){
        Integer index       = Integer.valueOf(ApexPages.currentPage().getParameters().get('entryNumber'))-1;
        system.debug('***' +  index );
        if(index+1 <  tseList.size()){
            tc9_ti__Time_Sheet_Entry__c fromEntry = tseList.get(index);
            for(Integer i = index + 1;i < tseList.size();i++){
                //system.debug('fromEntry.StartTime__c'+fromEntry.StartTime__c);
                tc9_ti__Time_Sheet_Entry__c toEntry = tseList.get(i);
                toEntry.tc9_ti__StartTime__c        = fromEntry.tc9_ti__StartTime__c;
                toEntry.tc9_ti__EndTime__c          = fromEntry.tc9_ti__EndTime__c;
                toEntry.tc9_ti__BreakTime__c        = fromEntry.tc9_ti__BreakTime__c;
                toEntry.tc9_ti__BreakTime2__c       = fromEntry.tc9_ti__BreakTime2__c;
                toEntry.tc9_ti__Total_Time_hours__c = fromEntry.tc9_ti__Total_Time_hours__c;
                toEntry.tc9_ti__Total_Time_mins__c  = fromEntry.tc9_ti__Total_Time_mins__c;
                toEntry.tc9_ti__Project_Code__c     = fromEntry.tc9_ti__Project_Code__c;  
                toEntry.tc9_ti__Start_Meridian__c   = fromEntry.tc9_ti__Start_Meridian__c;
                toEntry.tc9_ti__End_Meridian__c     = fromEntry.tc9_ti__end_Meridian__c;  
                toEntry.Missed_Break_Reason__c      = fromEntry.Missed_Break_Reason__c;  //Added by Sruthi
                toEntry.tc9_ti__Type_of_Leave__c   = fromEntry.tc9_ti__Type_of_Leave__c;
                system.debug('fromEntry.Missed_Break_Reason__c'+fromEntry.Missed_Break_Reason__c);                            
                tseList.add(i, toEntry);                
                tseList.remove(i+1);
            }
            
            //system.debug(tseList);            
        }
     }
     
     public void deleteTSEntry(){
        
        try{
            Integer index = Integer.valueOf(ApexPages.currentPage().getParameters().get('entryNumber'))-1;
            
            tc9_ti__Time_Sheet_Entry__c entry = tseList.get(index);
            if(entry.id != null)
                delete entry;
            tseList.remove(index);           
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An error has occurred while deleting the Timesheet Entry. Please contact your Administrator. '));
        }
    }
    
    
    public PageReference verifydate(){
        //get the date range of current timesheet
        Integer tsIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('tsIndex'));
        
        if(tseList[tsIndex].tc9_ti__WorkDate__c < timesheet.tc9_ti__Start_Date__c ||  tseList[tsIndex].tc9_ti__WorkDate__c > timesheet.tc9_ti__End_Date__c){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a valid date within the date range of the timesheet'));
        }
        /*if(dt<timesheet.Start_Date__c ||  dt > timesheet.End_Date__c){
            ApexPages.Message myMsg;
            myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a valid date within the date range of the timesheet');
            ApexPages.addMessage(myMsg);
        }*/
        return null;
     }
     
     /***************************** CRUD operations of TSE table *******************************/
     //over all save
     public PageReference saveAll(){
        List<tc9_ti__Time_Sheet_Entry__c> toCheckApproved = new List<tc9_ti__Time_Sheet_Entry__c>();
        toCheckApproved =  [Select Id,test_popup__c,Break_End_Time__c, tc9_ti__ProjectCode__c,Name,tc9_ti__Method_Created__c , tc9_ti__Start__c, tc9_ti__End__c, tc9_ti__EndTime__c, tc9_ti__StartTime__c, tc9_ti__Status__c, tc9_ti__IsPublicHoliday__c,  tc9_ti__Notes_Talent__c, tc9_ti__WorkDate__c, tc9_ti__BreakTime__c, Missed_Break_Reason__c,    
                                tc9_ti__BreakTime2__c, tc9_ti__HoursAcutal__c, tc9_ti__WorkDay__c, tc9_ti__ViewFlag__c,tc9_ti__Flagged__c, tc9_ti__Hours_Expected__c,tc9_ti__Total_Time_hours__c ,tc9_ti__Total_Time_mins__c,tc9_ti__Total_Hours__c, tc9_ti__Time_Sheet__r.tc9_ti__Status__c,
                                tc9_ti__Type_of_Leave__c, tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Job__r.Name, tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Award_Master__r.RecordTypeId, tc9_ti__Time_Sheet__r.RecordType.DeveloperName, 
                                tc9_ti__Project_Code__c, tc9_ti__Project_Code_Name__c,tc9_ti__Processed_Date__c, CurrencyIsoCode from tc9_ti__Time_Sheet_Entry__c where Id in: tseList order by tc9_ti__WorkDate__c ];


       
       if(toCheckApproved[0].tc9_ti__Time_Sheet__r.tc9_ti__Status__c != 'Approved' && toCheckApproved[0].tc9_ti__Time_Sheet__r.tc9_ti__Status__c != 'Submitted'){
         
        saveExpenses();
        saveTimeSheetEntries();  
       }
       else{
         
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This timesheet has been '+ toCheckApproved[0].tc9_ti__Time_Sheet__r.tc9_ti__Status__c +' already.'));          
       }      
        return null;
    }     
     //method to save the timesheet entries
     public PageReference saveTimeSheetEntries(){
         try{
            system.debug('inside submit');
            List<tc9_ti__Time_Sheet_Entry__c> listToUpsert = new List<tc9_ti__Time_Sheet_Entry__c>();
            
            listToUpsert.addAll(tseList);
            system.debug('@@@@tseList:'+tseList);
            if(listToUpsert.size() > 0){
                boolean error = false;
                Integer i=1;
                for(tc9_ti__Time_Sheet_Entry__c entry : listToUpsert){
                    if(entry.tc9_ti__WorkDate__c == null ){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Entry '+i+': Date, Start & End time are mandatory'));
                        error = true;
                    }
                    else if(!verifydate(entry.tc9_ti__WorkDate__c)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Entry '+i+': Date outside timesheet date range'));
                        error = true;
                    }
                    i++;
                }
                
                if(error)
                    return null;
    system.debug('@@@@tseList:'+listToUpsert);
                upsert  listToUpsert;
                //system.debug('***' + tseList);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Timesheet Entries have been saved '));
                refreshTimesheet();
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Timesheet Entries to be saved '));
            }
            
        }
        catch(Exception e){
            //system.debug('!@#$% Timesheet entries trouble '+e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ''+e.getdmlMessage(0)+''));
        }
        return null;
    }
    
    private boolean verifyDate(Date dt){
        if(dt == null || dt<timesheet.tc9_ti__Start_Date__c ||  dt > timesheet.tc9_ti__End_Date__c)
            return false;
        return true;
     }
     
     
    
    public PageReference doSubmit(){
        system.debug('inside submit');
        List<tc9_ti__Time_Sheet_Entry__c> toCheckApproved = new List<tc9_ti__Time_Sheet_Entry__c>();
        List<tc9_ti__Time_Sheet_Entry__c> listToUpsert = new List<tc9_ti__Time_Sheet_Entry__c>();
        
        toCheckApproved =  [Select Id, Name,Break_End_Time__c,test_popup__c,tc9_ti__ProjectCode__c,tc9_ti__Method_Created__c , tc9_ti__Start__c, tc9_ti__End__c, tc9_ti__EndTime__c, tc9_ti__StartTime__c, tc9_ti__Status__c, tc9_ti__IsPublicHoliday__c,  tc9_ti__Notes_Talent__c, tc9_ti__WorkDate__c, tc9_ti__BreakTime__c, Missed_Break_Reason__c, 
                                tc9_ti__BreakTime2__c, tc9_ti__HoursAcutal__c, tc9_ti__WorkDay__c, tc9_ti__ViewFlag__c,tc9_ti__Flagged__c, tc9_ti__Hours_Expected__c,tc9_ti__Total_Time_hours__c ,tc9_ti__Total_Time_mins__c,tc9_ti__Total_Hours__c, tc9_ti__Time_Sheet__r.tc9_ti__Status__c,
                                tc9_ti__Type_of_Leave__c, tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Job__r.Name, tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Award_Master__r.RecordTypeId, tc9_ti__Time_Sheet__r.RecordType.DeveloperName, 
                                tc9_ti__Project_Code__c, tc9_ti__Project_Code_Name__c,tc9_ti__Processed_Date__c, CurrencyIsoCode from tc9_ti__Time_Sheet_Entry__c where Id in: tseList order by tc9_ti__WorkDate__c ];
       
         Savepoint sp;
         if(toCheckApproved[0].tc9_ti__Time_Sheet__r.tc9_ti__Status__c != 'Approved' && toCheckApproved[0].tc9_ti__Time_Sheet__r.tc9_ti__Status__c != 'Submitted'){
          try{
             
            
              Set<Id> timesheetEntryIds = new Set<Id>();
              system.debug('!!!tseList'+tseList);
               system.debug('!!!tseList1'+tseList[0].tc9_ti__Type_of_Leave__c);
              listToUpsert.addAll(tseList);
              
                system.debug('inside submit');
                //saveTimeSheetEntries();
                  if(listToUpsert.size() > 0){  
                       for(tc9_ti__Time_Sheet_Entry__c ts : listToUpsert){
                            if (ts.tc9_ti__Status__c.equals(TSSTATUSNEW) || ts.tc9_ti__Status__c.equals(TSSTATUSREJECTED)){
                                ts.tc9_ti__ViewFlag__c = 0;     // set the timesheet entry is not been viewd               
                                ts.tc9_ti__Status__c = TSSTATUSSUBMITTED; //set timesheet entry status is submitted
                            }
    
                            timesheetEntryIds.add(ts.Id);
                       }   
                        //update timesheet
                        tc9_ti__Time_Sheet__c ts = new tc9_ti__Time_Sheet__c(id=timesheet.Id,tc9_ti__Status__c=TSSTATUSSUBMITTED);  
                        sp = Database.setSavepoint(); 
                        
                        upsert listToUpsert;
                        update ts;
                        List<tc9_ti__Time_sheet__c> listOfSubmittedTimesheets = new List<tc9_ti__Time_sheet__c>([Select Id, tc9_ti__WeeklyActualHours__c,tc9_ti__Placement__r.tc9_ti__Auto_Approve_0_Timesheets__c, tc9_ti__Status__c, (select Id, tc9_ti__Value__c from tc9_ti__Expenses__r where tc9_ti__Time_Sheet__c =:ts.Id AND tc9_ti__Value__c > 0)from tc9_ti__Time_Sheet__c where Id =: ts.Id]);
                        if(!listOfSubmittedTimesheets.isEmpty() && listOfSubmittedTimesheets[0].tc9_ti__Placement__r.tc9_ti__Auto_Approve_0_Timesheets__c && 
                            listOfSubmittedTimesheets[0].tc9_ti__WeeklyActualHours__c ==0 && listOfSubmittedTimesheets[0].tc9_ti__Status__c == 'Submitted' && 
                            listOfSubmittedTimesheets[0].tc9_ti__Expenses__r.isEmpty()){
                            //approve the timesheet entrys of the timesheet
                            TimeSheetFactory tsf = new TimeSheetFactory();
                            tsf.approveTimeSheetEntries(timesheetEntryIds);
                            ApexPages.Message myMsg;
                            myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'The approval process has been successful');
                            ApexPages.addMessage(myMsg);
                        }
                        else
                          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'The timesheet entries are submitted successfully. '));
                        
                        refreshTimesheet();
                        
                  }
                  else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Timesheet Entries to be submitted '));
                  }
              
              
            }catch(Exception e){
                    Database.rollback(sp);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occurred while Submitting Timesheets and Expenses. Please refresh the Page and try again, and if it still persists, please contact your Administrator.'+e.getMessage())); 
            }
         }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This timesheet has been '+ toCheckApproved[0].tc9_ti__Time_Sheet__r.tc9_ti__Status__c +' already.'));                 
              }
       return null;
    }
     
     
     /************************************************** EXPENSE WRAPPER & its CRUD Operation***********************************/
    
     /************************ populating Expense Table *******************************/
    public void refreshExpenses(){
        
        //Expenses  
        expIds = new Set<Id>();
        expenseWList    = new List<ExpensesWrapper>();
        map<Id,List<Attachment>> mapOfExpToAttach = new Map<Id,List<Attachment>>();
        for(tc9_ti__Expense__c exp : [SELECT id,tc9_ti__Date_Incurred__c,
                                        tc9_ti__Title__c,tc9_ti__Type__c,tc9_ti__Taxable__c,
                                        tc9_ti__Value__c,tc9_ti__Tax_Amount__c,tc9_ti__Expense_Total_including_Tax__c,
                                        tc9_ti__Time_Sheet__c
                               FROM tc9_ti__Expense__c 
                               WHERE tc9_ti__Time_Sheet__c =: timesheet.Id
                               order by createdDate]){
            expIds.add(exp.Id);
            expenseWList.add(new ExpensesWrapper(exp, 'Attach'));       
        }
        List<Attachment> attachmentsAll = new List<Attachment>([SELECT id,Name,ContentType, ParentId FROM Attachment WHERE ParentId in: expIds]);
        
        for(Attachment thisAttach : attachmentsAll){
            if(mapOfExpToAttach.containsKey(thisAttach.ParentId)){
                mapOfExpToAttach.get(thisAttach.ParentId).add(thisAttach);
            }
            else{
                mapOfExpToAttach.put(thisAttach.ParentId, new List<Attachment>{thisAttach});
            }
        }
        for(ExpensesWrapper thisExpWrp: expenseWList){
            if(mapOfExpToAttach.containsKey(thisExpWrp.expense.Id)){
                List<Attachment> thisAttachmentList = mapOfExpToAttach.get(thisExpWrp.expense.Id);
                if(thisAttachmentList.size() > 0)
                    thisExpWrp.isAttach = 'Attached';
            }
        }
        
    }
    
    
    //wrapper class for expense record
    //holds the record and determines if the record is in edit mode or not
    public class ExpensesWrapper{
        public tc9_ti__Expense__c expense{get;set;}
        public String isAttach{get;set;}
        
        public ExpensesWrapper(tc9_ti__Expense__c exp, String attach){
            this.expense = exp;
            this.isAttach = attach;
        }
    }
    
    
    public PageReference addExpense(){
        expenseWList.add(new ExpensesWrapper(new tc9_ti__Expense__c(tc9_ti__Time_Sheet__c=timesheet.Id),'Attach'));
        return null;
    }
    
    public void saveExpenses(){
            tc9_ti__Time_Sheet__c toCheckApproved = [select id,tc9_ti__status__c from tc9_ti__Time_Sheet__c where id =:timesheet.Id];
        
          if(toCheckApproved.tc9_ti__status__c!='Approved' && toCheckApproved.tc9_ti__status__c!='Submitted'){
            //system.debug('*** EXPENSES '  + expenseWList);
            Integer i=1;
            boolean error = false;
            List<tc9_ti__Expense__c> expenses = new List<tc9_ti__Expense__c>();
            for(ExpensesWrapper wrap : expenseWList){
                if(wrap.expense.tc9_ti__Type__c == null || wrap.expense.tc9_ti__Type__c == ''){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Expense '+i+': Enter a value for Type'));
                    error = true;
                }
                else
                    expenses.add(wrap.expense);
                i++;
            }
            if(error)
                return;
            try{
                //system.debug('*** EXPENSES '  + expenseWList);
                // CI - 150670
                if(expenses.size() > 0){
                    upsert expenses;
                    refreshExpenses();
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Expenses added successfully'));
                }           
            }
            catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An error occurred while saving the expenses. Please contact your system administrator.'));
            } 
          }
          else{
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This timesheet has been '+ toCheckApproved.tc9_ti__status__c +' already.'));         
          }  
    }
    
    public void saveEditDeleteExpense(){
        tc9_ti__Time_Sheet__c toCheckApproved = [select id,tc9_ti__status__c from tc9_ti__Time_Sheet__c where id =:timesheet.Id];
        
         if(toCheckApproved.tc9_ti__status__c!='Approved' && toCheckApproved.tc9_ti__status__c!='Submitted'){
          
        //get the page parameters
        Integer expRow = Integer.valueOf( ApexPages.currentPage().getParameters().get('expNumber'))-1;
        String actionToDo  = ApexPages.currentPage().getParameters().get('actionToDo');
        if(actionToDo != null)
            actionToDo = String.escapeSingleQuotes(actionToDo);
        
        //system.debug('** ' + actionToDo);
        
        ExpensesWrapper thisExp = expenseWList.get(expRow);
        tc9_ti__Expense__c updateExp = thisExp.expense;
        if(actionToDo == 'attachSave'){ 
            expenseIdForAttach = '';
            if(updateExp.tc9_ti__Type__c == null || updateExp.tc9_ti__Type__c == ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Expense '+(expRow+1)+': Enter a value for Type'));
                return;
            }
            else{
                try{
                    upsert updateExp;
                    expenseIdForAttach = (String)updateExp.Id;
                }
                catch(Exception e){
                    expenseIdForAttach = '';
                }
            }
        }
        else if(actionToDo == 'delete'){
            if(updateExp.Id != null)
                delete updateExp;
            expenseWList.remove(expRow);
        }
         }
         else{
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This timesheet has been '+ toCheckApproved.tc9_ti__status__c +' already.'));         
            
         }
         fetchAttachments();
    }
    
    
    public void Approve(){
        system.debug('timeeeetId '+timesheet.Id);
        tc9_ti__Time_Sheet__c toCheckApproved = [select id,tc9_ti__status__c from tc9_ti__Time_Sheet__c where id =:timesheet.Id];
        if(toCheckApproved.tc9_ti__status__c!='Approved'){
            try{ 
                
                controlPageMsg = true;
                tc9_ti__Time_Sheet__c updateTimesheet = new tc9_ti__Time_Sheet__c(id=timesheet.Id, tc9_ti__Approver_Name__c = currentContact.Name,tc9_ti__Approver_Email__c = currentContact.Email);
                update updateTimesheet; 
                
                TimeSheetFactory tf = new TimeSheetFactory();
                List<tc9_ti__Time_Sheet_Entry__c> listTSE = new List<tc9_ti__Time_Sheet_Entry__c>([select Id from tc9_ti__Time_Sheet_Entry__c where tc9_ti__Time_Sheet__c =: timesheet.Id]);
                Set<Id> tseIdSet = new Set<Id>();
                for(tc9_ti__Time_Sheet_Entry__c tse: listTSE){
                    tseIdSet.add(tse.Id);
                }
                tf.approveTimeSheetEntries(tseIdSet, currentContact) ; //Passing the entire object to have approval name
                system.debug('**** completed');
                refreshTimesheet();
                
            }catch(Exception e){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
                ApexPages.addMessage(myMsg); 
            }
        }
        else{
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This timesheet has been Approved already.')); 
            
        }
    }
    
    public void saveTimesheetComment(){
        
        tc9_ti__Time_Sheet__c toCheckApproved = [select id,tc9_ti__status__c from tc9_ti__Time_Sheet__c where id =:timesheet.Id];
        
        if(toCheckApproved.tc9_ti__status__c!='Approved'){
        
            system.debug('commenttt '+timesheet.tc9_ti__Notes_Customer__c);
            update timesheet;
        }
        else{
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This timesheet has been Approved already.')); 
            
        }
    }
    
    public void saveRejection(){
        
        tc9_ti__Time_Sheet__c toCheckApproved = [select id,tc9_ti__status__c from tc9_ti__Time_Sheet__c where id =:timesheet.Id];
        
        if(toCheckApproved.tc9_ti__status__c!='Approved'){
            update timesheet;
            
            try{
                controlPageMsg = true;
                //Set rejection reason for the time sheet
                tc9_ti__Time_Sheet__c timesheetUpdate = new tc9_ti__Time_Sheet__c(id=timesheet.Id,tc9_ti__rejection_reason__c=timesheet.tc9_ti__Rejection_Reason__c, tc9_ti__Approver_Name__c = currentContact.Name);
                update timesheetUpdate;
                
                TimeSheetFactory tf = new TimeSheetFactory();
                List<tc9_ti__Time_Sheet_Entry__c> listTSE = new List<tc9_ti__Time_Sheet_Entry__c>([select Id from tc9_ti__Time_Sheet_Entry__c where tc9_ti__Time_Sheet__c =: timesheet.Id]);
                Set<Id> tseIdSet = new Set<Id>();
                for(tc9_ti__Time_Sheet_Entry__c tse: listTSE){
                    tseIdSet.add(tse.Id);
                }
                tf.rejectTimeSheetEntries(tseIdSet, currentContact.id) ;
                
                refreshTimesheet();
                
            }catch(Exception e){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
                ApexPages.addMessage(myMsg); 
            }
       }
        else{
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This timesheet has been Approved already.')); 
            
        }
    }
    /*************************** Project Code operations ****************************/
    
    public void toggleProjComponent(){
        if(projCodeView)
            projCodeView = false;
        else
            projCodeView = true;
        
    }
    
    /*************************** Next Time Sheet ****************************/
    public PageReference next(){
            
        PageReference nextPage;
        if(ApexPages.currentPage().getParameters().get('list') != null){
            String tabIndex = 'TSIndex'+ApexPages.currentPage().getParameters().get('list');
            Integer index = Integer.valueOf(ApexPages.currentPage().getParameters().get(tabIndex));
            //system.debug('$$index'+index);
            //system.debug('^^tabIndex'+tabIndex);
            system.debug('!@#$% nextPage '+ ApexPages.currentPage().getParameters().get('list'));
            if(ApexPages.currentPage().getParameters().get('list') !='TSH'){    
                if(ApexPages.currentPage().getParameters().get('list') == 'CU'){
                    nextPage = nextPage(currentNavList, index, tabIndex);
                }
                else if(ApexPages.currentPage().getParameters().get('list') == 'OD'){
                    nextPage = nextPage(oDueNavList, index, tabIndex);
                }
            }
            if(ApexPages.currentPage().getParameters().get('list') =='TSH'){
                nextPage = nextPage(TSHNavList, index, tabIndex);
            }
            if(ApexPages.currentPage().getParameters().get('list') =='SUB'){
                
                nextPage = nextPage(SUBNavList, index, tabIndex);
            }
        }
        //system.debug('!@#$% nextPage '+ nextPage);
        return nextPage;
    }
    public PageReference prev(){
        PageReference prevPage;
        if(ApexPages.currentPage().getParameters().get('list') != null){
            String tabIndex = 'TSIndex'+ApexPages.currentPage().getParameters().get('list');
            Integer index = Integer.valueOf(ApexPages.currentPage().getParameters().get(tabIndex));
            //system.debug('$$index'+index);
            //system.debug('^^tabIndex'+tabIndex);
            if(ApexPages.currentPage().getParameters().get('list') !='TSH'){    
                if(ApexPages.currentPage().getParameters().get('list') == 'CU'){
                    prevPage = prevPage(currentNavList, index, tabIndex);
                }
                else if(ApexPages.currentPage().getParameters().get('list') == 'OD'){
                    prevPage = prevPage(oDueNavList, index, tabIndex);
                }
            }
            if(ApexPages.currentPage().getParameters().get('list') =='TSH'){
                prevPage = prevPage(TSHNavList, index, tabIndex);
            }
            if(ApexPages.currentPage().getParameters().get('list') =='SUB'){
                prevPage = prevPage(SUBNavList, index, tabIndex);
            }
        }
        return prevPage;
    }
    
    public PageReference nextPage(List<tc9_ti__Time_Sheet__c> thisTSList, Integer index, String tabIndex){
        system.debug('SubLissst '+thisTSList);
        String pageName;
        if(thisTSList.get(index) != null){
            index++;
            timesheet = thisTSList.get(index);
            refreshTimesheet();
            refreshExpenses();
            String strurl = ApexPages.currentPage().getUrl();
            system.debug('SubLissst '+strurl);
            if(strurl.contains('ApproverDetailPage')){
                pageName = Site.getBaseUrl()+PageName_ApproverDetail+'?tsId='+timesheet.Id+'&list='+ApexPages.currentPage().getParameters().get('list')+'&'+tabIndex+'='+index+'&&token='+currentContact.Id;
            }
            else
                pageName = Site.getBaseUrl()+Page_FillTimeSheet+'?tsId='+timesheet.Id+'&list='+ApexPages.currentPage().getParameters().get('list')+'&'+tabIndex+'='+index;
            system.debug('!@#$% pageBName '+ pageName);
            PageReference readPage = new PageReference(pageName);
            //readPage.setRedirect(true);
            return readPage;
        }
        return null;
    }
    public PageReference prevPage(List<tc9_ti__Time_Sheet__c> thisTSList, Integer index, String tabIndex){
        String pageName;
        if(thisTSList.get(index) != null){
            index--;
            timesheet = thisTSList.get(index);
            refreshTimesheet();
            refreshExpenses();
            String strurl = ApexPages.currentPage().getUrl();
            system.debug('SubLissst '+strurl);
            if(strurl.contains('ApproverDetailPage')){
                pageName = Site.getBaseUrl()+PageName_ApproverDetail+'?tsId='+timesheet.Id+'&list='+ApexPages.currentPage().getParameters().get('list')+'&'+tabIndex+'='+index+'&&token='+currentContact.Id;
            }
            else
                pageName = Site.getBaseUrl()+Page_FillTimeSheet+'?tsId='+timesheet.Id+'&list='+ApexPages.currentPage().getParameters().get('list')+'&'+tabIndex+'='+index;
            system.debug('!@#$% pageBName '+ pageName);
            PageReference readPage = new PageReference(pageName);
            //readPage.setRedirect(true);
            return readPage;
        }
        return null;
    }
    
}