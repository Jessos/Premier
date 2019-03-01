/**
 * Created by Adelaide Greenaway on 6/12/17.
 *
 * Copyright © 2017 2cloudnine Pty Ltd - Strictly Confidential.
 * Not to be distributed without authorisation
 *
 * Controller to support the 2c9 Timesheet Entry Pages
 *
 * The Timesheet Entry Page is accessible to the user if:
 *  - Timesheets have been generated for the Placement
 *  - 2c9 Portal Community User has been granted access to complete timesheets for that Placement
 * Test Class:
 *
 * May 2018 AG: SC-18288 - add Break Start/End Times logic
 * May 2018 AG: SC-18014 - add Leave Timesheet Entry type
 * May 2018 AG: SC-17980 - add Adhoc Allowances
 *
 * REMINDER: The changes for breaks, leave and allowances are only done for desktop, mobile changes are still to be done!!!
 */

public class Portal_TimesheetEntry_Controller extends Portal_Base_Controller{

    public Id tsId {get;set;}
    public Id tsJob {get;set;}
    public String tsStatus {get;set;}
    public Id tsPlc {get;set;}
    public String tsName {get;set;}

    public Datetime tsStartDate {get;set;}

    public Boolean resubmitDisabled {get;set;}
    public String tsRejectionReason {get;set;}
    public Boolean enableBreakSE {get;set;}

    public List<tc9_ti__Time_Sheet_Entry__c> tsEntries {get;set;}
    public List<Attachment> tsAttachments {get;set;}
    public List<Adhoc_Allowances__c> allowances {get;set;}

    public List<Portal_TSE_Wrapper> tseList_Day1 {get;set;}
    public List<Portal_TSE_Wrapper> tseList_Day2 {get;set;}
    public List<Portal_TSE_Wrapper> tseList_Day3 {get;set;}
    public List<Portal_TSE_Wrapper> tseList_Day4 {get;set;}
    public List<Portal_TSE_Wrapper> tseList_Day5 {get;set;}
    public List<Portal_TSE_Wrapper> tseList_Day6 {get;set;}
    public List<Portal_TSE_Wrapper> tseList_Day7 {get;set;}

    public List<Portal_TSE_Wrapper> tseLeaveList_Day1 {get;set;}
    public List<Portal_TSE_Wrapper> tseLeaveList_Day2 {get;set;}
    public List<Portal_TSE_Wrapper> tseLeaveList_Day3 {get;set;}
    public List<Portal_TSE_Wrapper> tseLeaveList_Day4 {get;set;}
    public List<Portal_TSE_Wrapper> tseLeaveList_Day5 {get;set;}
    public List<Portal_TSE_Wrapper> tseLeaveList_Day6 {get;set;}
    public List<Portal_TSE_Wrapper> tseLeaveList_Day7 {get;set;}

    public List<Portal_TSE_Wrapper> mobSelectedDay1 {get;set;}
    public List<Portal_TSE_Wrapper> mobSelectedDay2 {get;set;}
    public List<Portal_TSE_Wrapper> mobSelectedDay3 {get;set;}
    public List<Portal_TSE_Wrapper> mobSelectedDay4 {get;set;}
    public List<Portal_TSE_Wrapper> mobSelectedDay5 {get;set;}
    public List<Portal_TSE_Wrapper> mobSelectedDay6 {get;set;}
    public List<Portal_TSE_Wrapper> mobSelectedDay7 {get;set;}

    public List<Portal_Allowance_Wrapper> allowanceListDay1 {get;set;}
    public List<Portal_Allowance_Wrapper> allowanceListDay2 {get;set;}
    public List<Portal_Allowance_Wrapper> allowanceListDay3 {get;set;}
    public List<Portal_Allowance_Wrapper> allowanceListDay4 {get;set;}
    public List<Portal_Allowance_Wrapper> allowanceListDay5 {get;set;}
    public List<Portal_Allowance_Wrapper> allowanceListDay6 {get;set;}
    public List<Portal_Allowance_Wrapper> allowanceListDay7 {get;set;}

    public List<Portal_Allowance_Wrapper> mobSelectedAlwDay1 {get;set;}
    public List<Portal_Allowance_Wrapper> mobSelectedAlwDay2 {get;set;}
    public List<Portal_Allowance_Wrapper> mobSelectedAlwDay3 {get;set;}
    public List<Portal_Allowance_Wrapper> mobSelectedAlwDay4 {get;set;}
    public List<Portal_Allowance_Wrapper> mobSelectedAlwDay5 {get;set;}
    public List<Portal_Allowance_Wrapper> mobSelectedAlwDay6 {get;set;}
    public List<Portal_Allowance_Wrapper> mobSelectedAlwDay7 {get;set;}

    public Decimal day1TotalHours {get;set;}
    public Decimal day2TotalHours {get;set;}
    public Decimal day3TotalHours {get;set;}
    public Decimal day4TotalHours {get;set;}
    public Decimal day5TotalHours {get;set;}
    public Decimal day6TotalHours {get;set;}
    public Decimal day7TotalHours {get;set;}

    public Boolean day1PH {get;set;}
    public Boolean day2PH {get;set;}
    public Boolean day3PH {get;set;}
    public Boolean day4PH {get;set;}
    public Boolean day5PH {get;set;}
    public Boolean day6PH {get;set;}
    public Boolean day7PH {get;set;}


    public Decimal day1TotalEntries {get;set;}
    public Decimal day2TotalEntries {get;set;}
    public Decimal day3TotalEntries {get;set;}
    public Decimal day4TotalEntries {get;set;}
    public Decimal day5TotalEntries {get;set;}
    public Decimal day6TotalEntries {get;set;}
    public Decimal day7TotalEntries {get;set;}

    public Date day1Date {get;set;}
    public Date day2Date {get;set;}
    public Date day3Date {get;set;}
    public Date day4Date {get;set;}
    public Date day5Date {get;set;}
    public Date day6Date {get;set;}
    public Date day7Date {get;set;}

    public List<SelectOption> ProjectCodes{get;private set;}
    public List<SelectOption> AdhocAllowances {get;private set;}

    public List<SelectOption> leaveTypes{get;private set;}

    public tc9_ti__ToCloudNineConfig__c tcsConfig = tc9_ti__ToCloudNineConfig__c.getOrgDefaults();

    public String projectCode {get;set;}
    public String leaveType {get;set;}
    public String adhocAllowance {get;set;}

    public Boolean displayPC {get;set;}
    public Boolean displayBreak2 {get;set;}
    public Boolean displayAddButtons {get;set;}

    public String startTimeHrs {get;set;}
    public String startTimeMins {get;set;}
    public String endTimeHrs {get;set;}
    public String endTimeMins {get;set;}

    public String day_1 {get;set;}
    public String day_2 {get;set;}
    public String day_3 {get;set;}
    public String day_4 {get;set;}
    public String day_5 {get;set;}
    public String day_6 {get;set;}
    public String day_7 {get;set;}

    public Decimal weeklyTotalHrs {get;set;}

    public String chosenAttId {get;set;}
    public String chosenTSEId {get;set;}
    public String chosenALWId {get;set;}
    public Date chosenEntryDate {get;set;}

    public Boolean canEdit {get;set;}
    public Boolean autoApprove {get;set;}

    public Portal_TimesheetEntry_Controller(){

        tsId = ApexPages.currentPage().getParameters().get('Id');
        system.debug('the Timesheet: '+tsId);
        displayBreak2 = false;
        displayPC = false;
        resubmitDisabled = false;
        enableBreakSE = false;
        displayAddButtons = true;

        getTimesheetEntries();
        getProjectCodes();
        getLeaveTypes();
        getAdhocAllowances();
    }

    public void getTimesheetEntries(){

        for(tc9_ti__Time_Sheet__c timesheet : [SELECT Id, Name, tc9_ti__Status__c, tc9_ti__Manual_Approval_Reason__c, tc9_ti__Rejection_Reason__c, tc9_ti__Placement__r.ts2__Job__r.Id,
                tc9_ti__Placement__r.ts2__Client__r.tc9_ti__Week_Start_Day__c, tc9_ti__Placement__r.ts2__Job__r.tc9_ti__Week_Start_Day__c,
                tc9_ti__Placement__r.Use_2c9_Portal_Agreement_Logic__c, tc9_ti__Placement__r.X2c9_Portal_Placement_Agreement_Status__c,
                tc9_ti__Placement__r.tc9_ti__Timesheet_Entry_Format__c, tc9_ti__Start_Date__c, tc9_ti__Placement__r.tc9_ti__Auto_Approve_0_Timesheets__c
        FROM tc9_ti__Time_Sheet__c
        WHERE Id =: tsId]){
            tsJob = timesheet.tc9_ti__Placement__r.ts2__Job__r.Id;
            tsStatus = timesheet.tc9_ti__Status__c;
            tsPlc = timesheet.tc9_ti__Placement__r.Id;
            tsName = timesheet.Name;
            //tsStartDate = timesheet.tc9_ti__Start_Date__c; //to check against available Allowances on the placement
            //autoApprove = timesheet.tc9_ti__Placement__r.tc9_ti__Auto_Approve_0_Timesheets__c;

            system.debug('AUTO APPROVE: autoApprove: '+autoApprove+'  field: '+timesheet.tc9_ti__Placement__r.tc9_ti__Auto_Approve_0_Timesheets__c);

//            if(timesheet.tc9_ti__Manual_Approval_Reason__c != null){
//                tsRejectionReason = timesheet.tc9_ti__Manual_Approval_Reason__c;
//            }
            if(timesheet.tc9_ti__Rejection_Reason__c != null){
                tsRejectionReason = timesheet.tc9_ti__Rejection_Reason__c;
            }

            //SC-18288, if tc9_ti__Placement__r.tc9_ti__Timesheet_Entry_Format__c == 'Start/End Times', enableBreakSE = true.
            if(timesheet.tc9_ti__Placement__r.tc9_ti__Timesheet_Entry_Format__c == 'Start/End Times'){
                enableBreakSE = true;
            }else{
                enableBreakSE = false;
            }

            system.debug('Status: '+tsStatus+'Rejection Reason::'+tsRejectionReason);

            if(timesheet.tc9_ti__Placement__r.Use_2c9_Portal_Agreement_Logic__c == true && timesheet.tc9_ti__Placement__r.X2c9_Portal_Placement_Agreement_Status__c == 'Complete'){
                canEdit = true;
            }else if(timesheet.tc9_ti__Placement__r.Use_2c9_Portal_Agreement_Logic__c == false){
                canEdit = true;
            }else {
                canEdit = false;
            }

            //Pick up the Week Start Day by first seeing if it's captured on the Job
            //otherwise look at the Client, otherwise look at the Custom Setting if no
            //Custom Setting than day_1 = 'Monday'
            if(timesheet.tc9_ti__Placement__r.ts2__Job__r.tc9_ti__Week_Start_Day__c != null){
                day_1 = timesheet.tc9_ti__Placement__r.ts2__Job__r.tc9_ti__Week_Start_Day__c;
            }else if(timesheet.tc9_ti__Placement__r.ts2__Client__r.tc9_ti__Week_Start_Day__c != null){
                day_1 = timesheet.tc9_ti__Placement__r.ts2__Client__r.tc9_ti__Week_Start_Day__c;
            }else if(tcsConfig.tc9_ti__Week_Start_Day__c != null){
                day_1 = tcsConfig.tc9_ti__Week_Start_Day__c;
            }else{
                day_1 = 'Monday';
            }
        }

        //get adhoc allowances for this timesheet
        allowances = [SELECT Id, Name, Placement__c, Timesheet__c, Pay_Code__c, Approval_Status__c, Candidates_Notes__c,
                Quantity__c, Pay_Code__r.Id, Pay_Code__r.Name, Entry_Date__c, Effective_Date__c, Expiry_Date__c
        FROM Adhoc_Allowances__c
        WHERE Timesheet__c =: tsId ORDER BY Entry_Date__c ASC ];
        system.debug('allowances'+allowances);

        //get timesheet attachments
        tsAttachments = [SELECT Id, Name, ParentId, Description
        FROM Attachment
        WHERE ParentId =: tsId];
        //AND Description LIKE 'Portal Timesheet Entry supporting attachment'];

        for(tc9_ti__Job_Project_Code__c jbPC :[SELECT Id, Name, tc9_ti__Job_Order__c FROM tc9_ti__Job_Project_Code__c WHERE tc9_ti__Job_Order__c =: tsJob LIMIT 1]){
            displayPC = true;
        }

        if(tcsConfig.tc9_ti__Display_Break2__c == true){
            displayBreak2 = true;
        }

        if(tcsConfig.CUSTOM_Disable_Resubmit__c == true){
            resubmitDisabled = true;
        }

        if(day_1 == 'Sunday'){
            day_1 = 'Sun'; day_2 = 'Mon'; day_3 = 'Tue'; day_4 = 'Wed'; day_5 = 'Thu'; day_6 = 'Fri'; day_7 = 'Sat';
        }else if(day_1 == 'Monday'){
            day_1 = 'Mon'; day_2 = 'Tue'; day_3 = 'Wed'; day_4 = 'Thu'; day_5 = 'Fri'; day_6 = 'Sat'; day_7 = 'Sun';
        }else if(day_1 == 'Tuesday'){
            day_1= 'Tue'; day_2 = 'Wed'; day_3 = 'Thu'; day_4 = 'Fri'; day_5 = 'Sat'; day_6 = 'Sun'; day_7 = 'Mon';
        }
        else if(day_1 == 'Wednesday'){
            day_1 = 'Wed'; day_2 = 'Thu'; day_3 = 'Fri'; day_4 = 'Sat'; day_5 = 'Sun'; day_6 = 'Mon'; day_7 = 'Tue';
        }
        else if(day_1 == 'Thursday'){
            day_1='Thu'; day_2 = 'Fri'; day_3 = 'Sat'; day_4 = 'Sun'; day_5 = 'Mon'; day_6 = 'Tue'; day_7 = 'Wed';
        }
        else if(day_1 == 'Friday'){
            day_1='Fri'; day_2 = 'Sat'; day_3 = 'Sun'; day_4 = 'Mon'; day_5 = 'Tue'; day_6 = 'Wed'; day_7 = 'Thu';
        }
        else if(day_1 == 'Saturday'){
            day_1 = 'Sat'; day_2 = 'Sun'; day_3 = 'Mon'; day_4 = 'Tue'; day_5 = 'Wed'; day_6 = 'Thu'; day_7 = 'Fri';
        }

        day1TotalHours = 0.00;
        day2TotalHours = 0.00;
        day3TotalHours = 0.00;
        day4TotalHours = 0.00;
        day5TotalHours = 0.00;
        day6TotalHours = 0.00;
        day7TotalHours = 0.00;

        day1TotalEntries = 0;
        day2TotalEntries = 0;
        day3TotalEntries = 0;
        day4TotalEntries = 0;
        day5TotalEntries = 0;
        day6TotalEntries = 0;
        day7TotalEntries = 0;

        weeklyTotalHrs = 0.00;

        day1PH = false;
        day2PH = false;
        day3PH = false;
        day4PH = false;
        day5PH = false;
        day6PH = false;
        day7PH = false;

    tsEntries = [SELECT Id, Name, tc9_ti__Start__c, tc9_ti__End__c, tc9_ti__StartTime__c, tc9_ti__EndTime__c, tc9_ti__Status__c,
                tc9_ti__IsPublicHoliday__c, tc9_ti__Notes_Talent__c, tc9_ti__WorkDate__c, tc9_ti__BreakTime__c, tc9_ti__BreakTime2__c, tc9_ti__HoursAcutal__c, tc9_ti__WorkDay__c, tc9_ti__ViewFlag__c,
                tc9_ti__Flagged__c, tc9_ti__Hours_Expected__c, tc9_ti__Total_Time_hours__c, tc9_ti__Total_Time_mins__c, tc9_ti__Total_Hours__c, tc9_ti__Type_of_Leave__c,
                tc9_ti__Project_Code__c, tc9_ti__Project_Code__r.Name, tc9_ti__Project_Code_Name__c, tc9_ti__End_Meridian__c, tc9_ti__Start_Meridian__c, tc9_ti__StartTime12Hour__c, tc9_ti__EndTime12Hour__c,
                tc9_ti__Time_Sheet__c, tc9_ti__Time_Sheet__r.Id, tc9_ti__Time_Sheet__r.Name, tc9_ti__Time_Sheet__r.RecordType.DeveloperName,
                tc9_ti__Time_Sheet__r.tc9_ti__Start_Date__c, tc9_ti__Time_Sheet__r.tc9_ti__End_Date__c, tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c, tc9_ti__Time_Sheet__r.tc9_ti__Candidate__r.Name,
                tc9_ti__Time_Sheet__r.tc9_ti__Status__c, tc9_ti__Time_Sheet__r.tc9_ti__WeeklyActualHours__c, tc9_ti__Time_Sheet__r.CurrencyIsoCode, tc9_ti__Time_Sheet__r.tc9_ti__Rejection_Reason__c,
                tc9_ti__Time_Sheet__r.tc9_ti__Manual_Approval_Reason__c, tc9_ti__Time_Sheet__r.tc9_ti__Comments__c, tc9_ti__Time_Sheet__r.tc9_ti__Notify_Approver__c, tc9_ti__Time_Sheet__r.tc9_ti__Notify_Candidate_on_Approval__c,
                tc9_ti__Time_Sheet__r.tc9_ti__Notes_Customer__c, tc9_ti__Time_Sheet__r.tc9_ti__Placement__c, tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Job__c, tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Job__r.Name,
                tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Employee__r.Name, tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Job__r.tc9_ti__Client_Name__c, tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Job__r.ts2__Account__c,
                tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Award_Master__c, tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Award_Master__r.RecordTypeId,
                tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Timesheet_Entry_Format__c,
                tc9_ti__Time_Sheet__r.ST_Client__c,
                Break_Start_Time__c, Break_End_Time__c, Break_Alert__c
        FROM tc9_ti__Time_Sheet_Entry__c
        WHERE tc9_ti__Time_Sheet__r.Id =: tsId
        ORDER BY tc9_ti__WorkDate__c];

        tseList_Day1 = new List<Portal_TSE_Wrapper>();
        tseList_Day2 = new List<Portal_TSE_Wrapper>();
        tseList_Day3 = new List<Portal_TSE_Wrapper>();
        tseList_Day4 = new List<Portal_TSE_Wrapper>();
        tseList_Day5 = new List<Portal_TSE_Wrapper>();
        tseList_Day6 = new List<Portal_TSE_Wrapper>();
        tseList_Day7 = new List<Portal_TSE_Wrapper>();

        tseLeaveList_Day1 = new List<Portal_TSE_Wrapper>();
        tseLeaveList_Day2 = new List<Portal_TSE_Wrapper>();
        tseLeaveList_Day3 = new List<Portal_TSE_Wrapper>();
        tseLeaveList_Day4 = new List<Portal_TSE_Wrapper>();
        tseLeaveList_Day5 = new List<Portal_TSE_Wrapper>();
        tseLeaveList_Day6 = new List<Portal_TSE_Wrapper>();
        tseLeaveList_Day7 = new List<Portal_TSE_Wrapper>();

        allowanceListDay1 = new List<Portal_Allowance_Wrapper>();
        allowanceListDay2 = new List<Portal_Allowance_Wrapper>();
        allowanceListDay3 = new List<Portal_Allowance_Wrapper>();
        allowanceListDay4 = new List<Portal_Allowance_Wrapper>();
        allowanceListDay5 = new List<Portal_Allowance_Wrapper>();
        allowanceListDay6 = new List<Portal_Allowance_Wrapper>();
        allowanceListDay7 = new List<Portal_Allowance_Wrapper>();

        mobSelectedDay1 = new List<Portal_TSE_Wrapper>();
        mobSelectedDay2 = new List<Portal_TSE_Wrapper>();
        mobSelectedDay3 = new List<Portal_TSE_Wrapper>();
        mobSelectedDay4 = new List<Portal_TSE_Wrapper>();
        mobSelectedDay5 = new List<Portal_TSE_Wrapper>();
        mobSelectedDay6 = new List<Portal_TSE_Wrapper>();
        mobSelectedDay7 = new List<Portal_TSE_Wrapper>();

        mobSelectedAlwDay1 = new List<Portal_Allowance_Wrapper>();
        mobSelectedAlwDay2 = new List<Portal_Allowance_Wrapper>();
        mobSelectedAlwDay3 = new List<Portal_Allowance_Wrapper>();
        mobSelectedAlwDay4 = new List<Portal_Allowance_Wrapper>();
        mobSelectedAlwDay5 = new List<Portal_Allowance_Wrapper>();
        mobSelectedAlwDay6 = new List<Portal_Allowance_Wrapper>();
        mobSelectedAlwDay7 = new List<Portal_Allowance_Wrapper>();

        for(tc9_ti__Time_Sheet_Entry__c tse :  tsEntries){
            system.debug('day_1: '+day_1+' day_2: '+day_2+' day_3: '+day_3+' day_4: '+day_4+' day_5: '+day_5+' day_6: '+day_6+' day_7: '+day_7);
            system.debug('tse.tc9_ti__WorkDay__c: '+tse.tc9_ti__WorkDay__c);
//            system.debug('tse.Break_Start_Time__c: '+tse.Break_Start_Time__c);
//            system.debug('tse.Break_End_Time__c: '+tse.Break_End_Time__c);

            if(day_1 == tse.tc9_ti__WorkDay__c){
                if(tse.tc9_ti__Type_of_Leave__c == null || tse.tc9_ti__Type_of_Leave__c == ''){
                    system.debug('tse.tc9_ti__StartTime__c: '+tse.tc9_ti__StartTime__c);
                    system.debug('tse.tc9_ti__EndTime__c: '+tse.tc9_ti__EndTime__c);
                    tseList_Day1.add(new Portal_TSE_Wrapper(tse, false));
                }else if(tse.tc9_ti__Type_of_Leave__c != null){
                    tseLeaveList_Day1.add(new Portal_TSE_Wrapper(tse, false));
                }
                day1Date = tse.tc9_ti__WorkDate__c;
                day1TotalHours += tse.tc9_ti__HoursAcutal__c;
                if(tse.tc9_ti__IsPublicHoliday__c){
                    day1PH = true;
                }else{
                    day1PH = false;
                }
                system.debug('tse.tc9_ti__IsPublicHoliday__c: '+tse.tc9_ti__IsPublicHoliday__c+'  day1PublicHoliday: '+day1PH);
            }
            if(day_2 == tse.tc9_ti__WorkDay__c){
                if(tse.tc9_ti__Type_of_Leave__c == null || tse.tc9_ti__Type_of_Leave__c == ''){
                    tseList_Day2.add(new Portal_TSE_Wrapper(tse, false));

                }else if(tse.tc9_ti__Type_of_Leave__c != null){
                    tseLeaveList_Day2.add(new Portal_TSE_Wrapper(tse, false));

                }
                day2Date = tse.tc9_ti__WorkDate__c;
                day2TotalHours += tse.tc9_ti__HoursAcutal__c;
                if(tse.tc9_ti__IsPublicHoliday__c){
                    day2PH = true;
                }else{
                    day2PH = false;
                }
            }
            if(day_3 == tse.tc9_ti__WorkDay__c){
                if(tse.tc9_ti__Type_of_Leave__c == null || tse.tc9_ti__Type_of_Leave__c == ''){
                    tseList_Day3.add(new Portal_TSE_Wrapper(tse, false));

                }else if(tse.tc9_ti__Type_of_Leave__c != null){
                    tseLeaveList_Day3.add(new Portal_TSE_Wrapper(tse, false));

                }
                day3Date = tse.tc9_ti__WorkDate__c;
                day3TotalHours += tse.tc9_ti__HoursAcutal__c;
                if(tse.tc9_ti__IsPublicHoliday__c){
                    day3PH = true;
                }else{
                    day3PH = false;
                }
            }
            if(day_4 == tse.tc9_ti__WorkDay__c){
                if(tse.tc9_ti__Type_of_Leave__c == null || tse.tc9_ti__Type_of_Leave__c == ''){
                    tseList_Day4.add(new Portal_TSE_Wrapper(tse, false));

                }else if(tse.tc9_ti__Type_of_Leave__c != null){
                    tseLeaveList_Day4.add(new Portal_TSE_Wrapper(tse, false));

                }
                day4Date = tse.tc9_ti__WorkDate__c;
                day4TotalHours += tse.tc9_ti__HoursAcutal__c;
                if(tse.tc9_ti__IsPublicHoliday__c){
                    day4PH = true;
                }else{
                    day4PH = false;
                }
            }
            if(day_5 == tse.tc9_ti__WorkDay__c){
                if(tse.tc9_ti__Type_of_Leave__c == null || tse.tc9_ti__Type_of_Leave__c == ''){
                    tseList_Day5.add(new Portal_TSE_Wrapper(tse, false));

                }else if(tse.tc9_ti__Type_of_Leave__c != null){
                    tseLeaveList_Day5.add(new Portal_TSE_Wrapper(tse, false));

                }
                day5Date = tse.tc9_ti__WorkDate__c;
                day5TotalHours += tse.tc9_ti__HoursAcutal__c;
                if(tse.tc9_ti__IsPublicHoliday__c){
                    day5PH = true;
                }else{
                    day5PH = false;
                }
            }
            if(day_6 == tse.tc9_ti__WorkDay__c){
                if(tse.tc9_ti__Type_of_Leave__c == null || tse.tc9_ti__Type_of_Leave__c == ''){
                    tseList_Day6.add(new Portal_TSE_Wrapper(tse, false));

                }else if(tse.tc9_ti__Type_of_Leave__c != null){
                    tseLeaveList_Day6.add(new Portal_TSE_Wrapper(tse, false));

                }
                day6Date = tse.tc9_ti__WorkDate__c;
                day6TotalHours += tse.tc9_ti__HoursAcutal__c;
                if(tse.tc9_ti__IsPublicHoliday__c){
                    day6PH = true;
                }else{
                    day6PH = false;
                }
            }
            if(day_7 == tse.tc9_ti__WorkDay__c){
                if(tse.tc9_ti__Type_of_Leave__c == null || tse.tc9_ti__Type_of_Leave__c == ''){
                    tseList_Day7.add(new Portal_TSE_Wrapper(tse, false));

                }else if(tse.tc9_ti__Type_of_Leave__c != null){
                    tseLeaveList_Day7.add(new Portal_TSE_Wrapper(tse, false));

                }
                day7Date = tse.tc9_ti__WorkDate__c;
                day7TotalHours += tse.tc9_ti__HoursAcutal__c;
                if(tse.tc9_ti__IsPublicHoliday__c){
                    day7PH = true;
                }else{
                    day7PH = false;
                }
            }
        }

        for(Adhoc_Allowances__c alw : allowances){

            if(alw.Entry_Date__c == day1Date){
                allowanceListDay1.add(new Portal_Allowance_Wrapper(alw,false));
            }
            if(alw.Entry_Date__c == day2Date){
                allowanceListDay2.add(new Portal_Allowance_Wrapper(alw,false));
            }
            if(alw.Entry_Date__c == day3Date){
                allowanceListDay3.add(new Portal_Allowance_Wrapper(alw,false));
            }
            if(alw.Entry_Date__c == day4Date){
                allowanceListDay4.add(new Portal_Allowance_Wrapper(alw,false));
            }
            if(alw.Entry_Date__c == day5Date){
                allowanceListDay5.add(new Portal_Allowance_Wrapper(alw,false));
            }
            if(alw.Entry_Date__c == day6Date){
                allowanceListDay6.add(new Portal_Allowance_Wrapper(alw,false));
            }
            if(alw.Entry_Date__c == day7Date){
                allowanceListDay7.add(new Portal_Allowance_Wrapper(alw,false));
            }
        }

        day1TotalEntries = tseList_Day1.size() + tseLeaveList_Day1.size() + allowanceListDay1.size();
        day2TotalEntries = tseList_Day2.size() + tseLeaveList_Day2.size() + allowanceListDay2.size();
        day3TotalEntries = tseList_Day3.size() + tseLeaveList_Day3.size() + allowanceListDay3.size();
        day4TotalEntries = tseList_Day4.size() + tseLeaveList_Day4.size() + allowanceListDay4.size();
        day5TotalEntries = tseList_Day5.size() + tseLeaveList_Day5.size() + allowanceListDay5.size();
        day6TotalEntries = tseList_Day6.size() + tseLeaveList_Day6.size() + allowanceListDay6.size();
        day7TotalEntries = tseList_Day7.size() + tseLeaveList_Day7.size() + allowanceListDay7.size();


        weeklyTotalHrs = day1TotalHours + day2TotalHours + day3TotalHours + day4TotalHours + day5TotalHours + day6TotalHours + day7TotalHours;
//        system.debug('tseList_Day1: '+tseList_Day1);
//        system.debug('tseList_Day2: '+tseList_Day2);
//        system.debug('tseList_Day3: '+tseList_Day3);
//        system.debug('tseList_Day4: '+tseList_Day4);
//        system.debug('tseList_Day5: '+tseList_Day5);
//        system.debug('tseList_Day6: '+tseList_Day6);
//        system.debug('tseList_Day7: '+tseList_Day7);
//        system.debug('weeklyTotalhrs:'+weeklyTotalHrs);
    }

    public PageReference cancelMobEditDay1(){
        cancelEditMobile(mobSelectedDay1);
        return null;
    }
    public PageReference cancelMobEditDay2(){
        cancelEditMobile(mobSelectedDay2);
        return null;
    }
    public PageReference cancelMobEditDay3(){
        cancelEditMobile(mobSelectedDay3);
        return null;
    }
    public PageReference cancelMobEditDay4(){
        cancelEditMobile(mobSelectedDay4);
        return null;
    }
    public PageReference cancelMobEditDay5(){
        cancelEditMobile(mobSelectedDay5);
        return null;
    }
    public PageReference cancelMobEditDay6(){
        cancelEditMobile(mobSelectedDay6);
        return null;
    }
    public PageReference cancelMobEditDay7(){
        cancelEditMobile(mobSelectedDay7);
        return null;
    }

    public PageReference cancelMobEditAlwDay1(){
        cancelMobAlwEdit(mobSelectedAlwDay1);
        return null;
    }
    public PageReference cancelMobEditAlwDay2(){
        cancelMobAlwEdit(mobSelectedAlwDay2);
        return null;
    }
    public PageReference cancelMobEditAlwDay3(){
        cancelMobAlwEdit(mobSelectedAlwDay3);
        return null;
    }
    public PageReference cancelMobEditAlwDay4(){
        cancelMobAlwEdit(mobSelectedAlwDay4);
        return null;
    }
    public PageReference cancelMobEditAlwDay5(){
        cancelMobAlwEdit(mobSelectedAlwDay5);
        return null;
    }
    public PageReference cancelMobEditAlwDay6(){
        cancelMobAlwEdit(mobSelectedAlwDay6);
        return null;
    }
    public PageReference cancelMobEditAlwDay7(){
        cancelMobAlwEdit(mobSelectedAlwDay7);
        return null;
    }

    public void cancelEditMobile(List<Portal_TSE_Wrapper> cancelList){
        cancelList.clear();
        getTimesheetEntries();
    }

    public PageReference cancelMobAlwEdit(List<Portal_Allowance_Wrapper> cancelList){
        cancelList.clear();
        getTimesheetEntries();
        return null;
    }

    public PageReference cancelEdit(){
        getTimesheetEntries();
        return null;
    }

    public PageReference getSelectedAlwDay1() {
//        system.debug('Allowance Selected! '+allowanceListDay1);
        mobSelectedAlwDay1.clear();
        getSelectedALWEntry(allowanceListDay1,mobSelectedAlwDay1);
        return null;
    }
    public PageReference getSelectedAlwDay2() {
//        system.debug('Allowance Selected! '+allowanceListDay2);
        mobSelectedAlwDay2.clear();
        getSelectedALWEntry(allowanceListDay2,mobSelectedAlwDay2);
        return null;
    }
    public PageReference getSelectedAlwDay3() {
//        system.debug('Allowance Selected! '+allowanceListDay3);
        mobSelectedAlwDay3.clear();
        getSelectedALWEntry(allowanceListDay3,mobSelectedAlwDay3);
        return null;
    }
    public PageReference getSelectedAlwDay4() {
//        system.debug('Allowance Selected! '+allowanceListDay4);
        mobSelectedAlwDay4.clear();
        getSelectedALWEntry(allowanceListDay4,mobSelectedAlwDay4);
        return null;
    }
    public PageReference getSelectedAlwDay5() {
//        system.debug('Allowance Selected! '+allowanceListDay5);
        mobSelectedAlwDay5.clear();
        getSelectedALWEntry(allowanceListDay5,mobSelectedAlwDay5);
        return null;
    }
    public PageReference getSelectedAlwDay6() {
        system.debug('Allowance Selected! '+allowanceListDay6);
        mobSelectedAlwDay6.clear();
        getSelectedALWEntry(allowanceListDay6,mobSelectedAlwDay6);
        return null;
    }
    public PageReference getSelectedAlwDay7() {
//        system.debug('Allowance Selected! '+allowanceListDay7);
        mobSelectedAlwDay7.clear();
        getSelectedALWEntry(allowanceListDay7,mobSelectedAlwDay7);
        return null;
    }
    public void getSelectedALWEntry(List<Portal_Allowance_Wrapper> selectedlist, List<Portal_Allowance_Wrapper> mobSelectedList){
        for(Portal_Allowance_Wrapper tsewrapper : selectedlist){
            if(tsewrapper.selected == true){
                tsewrapper.show = false;
                displayAddButtons = false;
                mobSelectedList.add(new Portal_Allowance_Wrapper(tsewrapper.alwEntry,true));
            }
            if(tsewrapper.selected == false){
                tsewrapper.show = true;
            }
        }
    }
    public PageReference getSelectedDTDay1() {
        mobSelectedDay1.clear();
        getSelectedEntry(tseList_Day1, null,'desktop');
        return null;
    }

    public PageReference getSelectedDTLeaveDay1() {
        mobSelectedDay1.clear();
        getSelectedEntry(tseLeaveList_Day1, null,'desktop');
        return null;
    }

    public PageReference getSelectedDTDay2() {
        mobSelectedDay2.clear();
        getSelectedEntry(tseList_Day2, null,'desktop');
        return null;
    }

    public PageReference getSelectedDTLeaveDay2() {
        mobSelectedDay2.clear();
        getSelectedEntry(tseLeaveList_Day2, null,'desktop');
        return null;
    }

    public PageReference getSelectedDTDay3() {
        mobSelectedDay3.clear();
        getSelectedEntry(tseList_Day3, null,'desktop');
        return null;
    }

    public PageReference getSelectedDTLeaveDay3() {
        mobSelectedDay3.clear();
        getSelectedEntry(tseLeaveList_Day3, null,'desktop');
        return null;
    }

    public PageReference getSelectedDTDay4() {
        mobSelectedDay4.clear();
        getSelectedEntry(tseList_Day4, null,'desktop');
        return null;
    }

    public PageReference getSelectedDTLeaveDay4() {
        mobSelectedDay4.clear();
        getSelectedEntry(tseLeaveList_Day4, null,'desktop');
        return null;
    }

    public PageReference getSelectedDTDay5() {
        mobSelectedDay5.clear();
        getSelectedEntry(tseList_Day5, null,'desktop');
        return null;
    }

    public PageReference getSelectedDTLeaveDay5() {
        mobSelectedDay5.clear();
        getSelectedEntry(tseLeaveList_Day5, null,'desktop');
        return null;
    }

    public PageReference getSelectedDTDay6() {
        mobSelectedDay6.clear();
        getSelectedEntry(tseList_Day6, null,'desktop');
        return null;
    }

    public PageReference getSelectedDTLeaveDay6() {
        mobSelectedDay6.clear();
        getSelectedEntry(tseLeaveList_Day6, null,'desktop');
        return null;
    }

    public PageReference getSelectedDTDay7() {
        mobSelectedDay7.clear();
        getSelectedEntry(tseList_Day7, null,'desktop');
        return null;
    }

    public PageReference getSelectedDTLeaveDay7() {
        mobSelectedDay7.clear();
        getSelectedEntry(tseLeaveList_Day7, null,'desktop');
        return null;
    }

    public PageReference getSelectedDay1() {
        mobSelectedDay1.clear();
        getSelectedEntry(tseList_Day1, mobSelectedDay1,'mobile');
        return null;
    }

    public PageReference getSelectedLeaveDay1() {
        mobSelectedDay1.clear();
        getSelectedEntry(tseLeaveList_Day1, mobSelectedDay1,'mobile');
        return null;
    }

    public PageReference getSelectedDay2() {
       mobSelectedDay2.clear();
        getSelectedEntry(tseList_Day2, mobSelectedDay2,'mobile');
        return null;
    }

    public PageReference getSelectedLeaveDay2() {
        mobSelectedDay2.clear();
        getSelectedEntry(tseLeaveList_Day2, mobSelectedDay2,'mobile');
        return null;
    }

    public PageReference getSelectedDay3() {
        mobSelectedDay3.clear();
        getSelectedEntry(tseList_Day3, mobSelectedDay3,'mobile');
        return null;
    }

    public PageReference getSelectedLeaveDay3() {
        mobSelectedDay3.clear();
        getSelectedEntry(tseLeaveList_Day3,mobSelectedDay3,'mobile');
        return null;
    }

    public PageReference getSelectedDay4() {
        mobSelectedDay4.clear();
        getSelectedEntry(tseList_Day4,mobSelectedDay4,'mobile');
        return null;
    }

    public PageReference getSelectedLeaveDay4() {
       mobSelectedDay4.clear();
        getSelectedEntry(tseLeaveList_Day4,mobSelectedDay4,'mobile');
        return null;
    }

    public PageReference getSelectedDay5() {
        mobSelectedDay5.clear();
        getSelectedEntry(tseList_Day5,mobSelectedDay5,'mobile');
        return null;
    }

    public PageReference getSelectedLeaveDay5() {
        mobSelectedDay5.clear();
        getSelectedEntry(tseLeaveList_Day5,mobSelectedDay5,'mobile');
        return null;
    }

    public PageReference getSelectedDay6() {
        mobSelectedDay6.clear();
        getSelectedEntry(tseList_Day6,mobSelectedDay6,'mobile');
        return null;
    }

    public PageReference getSelectedLeaveDay6() {
        mobSelectedDay6.clear();
        getSelectedEntry(tseLeaveList_Day6,mobSelectedDay6,'mobile');
        return null;
    }

    public PageReference getSelectedDay7() {
        mobSelectedDay7.clear();
        getSelectedEntry(tseList_Day7,mobSelectedDay7,'mobile');
        return null;
    }

    public PageReference getSelectedLeaveDay7() {
        mobSelectedDay7.clear();
        getSelectedEntry(tseLeaveList_Day7,mobSelectedDay7,'mobile');
        return null;
    }

    public void getSelectedEntry(List<Portal_TSE_Wrapper> selectedlist, List<Portal_TSE_Wrapper> mobSelectedList, String type){
        if(type == 'mobile'){
            system.debug('getSelectedEntry selectedlist: '+selectedlist);

            for(Portal_TSE_Wrapper tsewrapper : selectedlist){
                if(tsewrapper.selected == true){
                    tsewrapper.show = false;
                    displayAddButtons = false;
                    mobSelectedList.add(new Portal_TSE_Wrapper(tsewrapper.tsEntry,true));
                    system.debug('getSelectedEntry mobSelectedList: '+mobSelectedList);
                }
                if(tsewrapper.selected == false){
                    tsewrapper.show = true;
                }
            }
        }else if(type == 'desktop'){
            system.debug('CHOSEN TO EDIT'+chosenTSEId);
            for(Portal_TSE_Wrapper tseWrapper : selectedlist){
                if(tseWrapper.tsEntry.Id == chosenTSEId){
                    tseWrapper.show = false;
                    tseWrapper.selected = true;
                    system.debug('getSelectedEntry : '+selectedlist);
                }else{
                    tseWrapper.show = true;
                    tseWrapper.selected = false;
                }
            }
        }

    }

    public PageReference deleteTSE(){
        system.debug('CHOSEN TO DELETE'+chosenTSEId);
        tc9_ti__Time_Sheet_Entry__c toDel = new tc9_ti__Time_Sheet_Entry__c(id=chosenTSEId);
        delete toDel;

        displayAddButtons = true;

        getTimesheetEntries();

        return null;
    }

    public PageReference deleteALW(){
        system.debug('CHOSEN TO DELETE'+chosenALWId);
        Adhoc_Allowances__c toDel = new Adhoc_Allowances__c(id=chosenALWId);
        delete toDel;

        displayAddButtons = true;

        getTimesheetEntries();

        return null;
    }

    public PageReference deleteAtt(){
        Attachment toDel = new Attachment(id=chosenAttId);
        delete toDel;

        displayAddButtons = true;

        getTimesheetEntries();
        return null;
    }
    public void addNewTSEntry_Day1() {
//        newEntryDate = day1Date;
        insertNewTSEntry(day1Date,false);
        getSelectedDay1();
    }
    public void addNewTSEntry_Day2() {
//        newEntryDate = day2Date;
        insertNewTSEntry(day2Date,false);
        getSelectedDay2();
    }
    public void addNewTSEntry_Day3() {
//        newEntryDate = day3Date;
        insertNewTSEntry(day3Date,false);
        getSelectedDay3();
    }
    public void addNewTSEntry_Day4() {
//        newEntryDate = day4Date;
        insertNewTSEntry(day4Date,false);
        getSelectedDay4();
    }
    public void addNewTSEntry_Day5() {
//        newEntryDate = day5Date;
        insertNewTSEntry(day5Date,false);
        getSelectedDay5();
    }
    public void addNewTSEntry_Day6() {
//        newEntryDate = day6Date;
        insertNewTSEntry(day6Date,false);
        getSelectedDay6();
    }
    public void addNewTSEntry_Day7() {
//        newEntryDate = day7Date;
        insertNewTSEntry(day7Date,false);
        getSelectedDay7();
    }

    public void addNewTSLeaveEntry_Day1() {
//        newEntryDate = day1Date;
        insertNewTSEntry(day1Date,true);
        getSelectedDay1();
    }
    public void addNewTSLeaveEntry_Day2() {
//        newEntryDate = day2Date;
        insertNewTSEntry(day2Date,true);
        getSelectedDay2();
    }
    public void addNewTSLeaveEntry_Day3() {
//        newEntryDate = day3Date;
        insertNewTSEntry(day3Date,true);
        getSelectedDay3();
    }
    public void addNewTSLeaveEntry_Day4() {
//        newEntryDate = day4Date;
        insertNewTSEntry(day4Date,true);
        getSelectedDay4();
    }
    public void addNewTSLeaveEntry_Day5() {
//        newEntryDate = day5Date;
        insertNewTSEntry(day5Date,true);
        getSelectedDay5();
    }
    public void addNewTSLeaveEntry_Day6() {
//        newEntryDate = day6Date;
        insertNewTSEntry(day6Date,true);
        getSelectedDay6();
    }
    public void addNewTSLeaveEntry_Day7() {
//        newEntryDate = day7Date;
        insertNewTSEntry(day7Date,true);
        getSelectedDay7();
    }

    public void addNewAlw_Day1(){
//        newEntryDate = day1Date;
        insertNewAllowance(day1Date);
        getSelectedAlwDay1();
    }
    public void addNewAlw_Day2(){
//        newEntryDate = day2Date;
        insertNewAllowance(day2Date);
        getSelectedAlwDay2();
    }
    public void addNewAlw_Day3(){
        insertNewAllowance(day3Date);
        getSelectedAlwDay3();
    }
    public void addNewAlw_Day4(){
        insertNewAllowance(day4Date);
        getSelectedAlwDay4();
    }
    public void addNewAlw_Day5(){
        insertNewAllowance(day5Date);
        getSelectedAlwDay5();
    }
    public void addNewAlw_Day6(){
        insertNewAllowance(day6Date);
        getSelectedAlwDay6();
    }
    public void addNewAlw_Day7(){
        insertNewAllowance(day7Date);
        getSelectedAlwDay7();
    }

    public void insertNewTSEntry(Date entryDate, Boolean leaveEntry) {
        try{
            tc9_ti__Time_Sheet_Entry__c tEntry = new tc9_ti__Time_Sheet_Entry__c();
            tEntry.tc9_ti__Time_Sheet__c= tsId;
            tEntry.tc9_ti__Status__c='New';
            tEntry.tc9_ti__WorkDate__c = entryDate;
            if(leaveEntry == true) {
                tEntry.tc9_ti__Type_of_Leave__c = 'Annual Leave';
            }
            insert tEntry;

            displayAddButtons = true;

            getTimesheetEntries();
        }
        catch(Exception e){
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'An error has occurred while creating a new Timesheet Entry. Please contact your administrator or try again ');
            ApexPages.addMessage(errMsg);
        }
    }

    public void insertNewAllowance(Date entryDate) {
        // Get the Record Type for Timesheet
        system.debug('chosenEntryDate'+chosenEntryDate);
        Id alwRT = ([SELECT Id FROM RecordType WHERE SObjectType = 'Adhoc_Allowances__c' AND Name = 'Timesheet' Limit 1]).Id;

        try{
            Adhoc_Allowances__c newAlw = new Adhoc_Allowances__c();
            newAlw.RecordTypeId = alwRT;
            newAlw.Contact__c = currentPayee.tc9_p__Contact__c;
            newAlw.Entry_Date__c = entryDate;
            newAlw.Approval_Status__c = 'New';
            newAlw.Timesheet__c = tsId;
            newAlw.Placement__c = tsPlc;
            insert newAlw;

            displayAddButtons = true;

            getTimesheetEntries();

        }catch(Exception e){
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'An error has occurred while creating a new Adhoc Allowance. Please contact your administrator or try again ');
            ApexPages.addMessage(errMsg);
        }
    }

    public PageReference saveSelectedEntryDay1(){
        saveTSEntries(mobSelectedDay1);
//        system.debug('mobSelectedDay1: '+mobSelectedDay1);
//        system.debug('tseList_Day1: '+tseList_Day1);
        return null;
    }

    public PageReference saveSelectedEntryDay2(){
        saveTSEntries(mobSelectedDay2);
        return null;
    }
    public PageReference saveSelectedEntryDay3(){
        saveTSEntries(mobSelectedDay3);
        return null;
    }
    public PageReference saveSelectedEntryDay4(){
        saveTSEntries(mobSelectedDay4);
        return null;
    }
    public PageReference saveSelectedEntryDay5(){
        saveTSEntries(mobSelectedDay5);
        return null;
    }
    public PageReference saveSelectedEntryDay6(){
        saveTSEntries(mobSelectedDay6);
        return null;
    }
    public PageReference saveSelectedEntryDay7(){
        saveTSEntries(mobSelectedDay7);
        return null;
    }

    /*Save Allowances in Mobile mode */
    public PageReference saveSelectedALWDay1(){
        saveMobAlwEntries(mobSelectedAlwDay1);
        return null;
    }

    public PageReference saveSelectedALWDay2(){
        saveMobAlwEntries(mobSelectedAlwDay2);
        return null;
    }
    public PageReference saveSelectedALWDay3(){
        saveMobAlwEntries(mobSelectedAlwDay3);
        return null;
    }
    public PageReference saveSelectedALWDay4(){
        saveMobAlwEntries(mobSelectedAlwDay4);
        return null;
    }
    public PageReference saveSelectedALWDay5(){
        saveMobAlwEntries(mobSelectedAlwDay5);
        return null;
    }
    public PageReference saveSelectedALWDay6(){
        saveMobAlwEntries(mobSelectedAlwDay6);
        return null;
    }
    public PageReference saveSelectedALWDay7(){
        saveMobAlwEntries(mobSelectedAlwDay7);
        return null;
    }

    public PageReference saveTSE_Day1() {
        saveTSEntries(tseList_Day1);
        return null;
    }

    public PageReference saveTSE_Day2() {
        saveTSEntries(tseList_Day2);
        return null;
    }

    public PageReference saveTSE_Day3() {
        saveTSEntries(tseList_Day3);
        return null;
    }

    public PageReference saveTSE_Day4() {
        saveTSEntries(tseList_Day4);
        return null;
    }

    public PageReference saveTSE_Day5() {
        saveTSEntries(tseList_Day5);
        return null;
    }

    public PageReference saveTSE_Day6() {
        saveTSEntries(tseList_Day6);
        return null;
    }

    public PageReference saveTSE_Day7() {
        saveTSEntries(tseList_Day7);
        return null;
    }

    public PageReference saveLeave_Day1() {
        saveLeaveEntries(tseLeaveList_Day1);
        return null;
    }

    public PageReference saveLeave_Day2() {
        saveLeaveEntries(tseLeaveList_Day2);
        return null;
    }

    public PageReference saveLeave_Day3() {
        saveLeaveEntries(tseLeaveList_Day3);
        return null;
    }

    public PageReference saveLeave_Day4() {
        saveLeaveEntries(tseLeaveList_Day4);
        return null;
    }

    public PageReference saveLeave_Day5() {
        saveLeaveEntries(tseLeaveList_Day5);
        return null;
    }

    public PageReference saveLeave_Day6() {
        saveLeaveEntries(tseLeaveList_Day6);
        return null;
    }

    public PageReference saveLeave_Day7() {
        saveLeaveEntries(tseLeaveList_Day7);
        return null;
    }

    public PageReference saveAllowances() {
        saveAllowanceEntries(allowances);
        return null;
    }

    public PageReference saveTSEntries(List<Portal_TSE_Wrapper> listToUpdate){
        ApexPages.Message errMsg;
        String detailedErrorMsg;
        Boolean tseIsOverMidnight;

        tseIsOverMidnight = false;
        detailedErrorMsg = '';

        system.debug('updating list: '+listToUpdate);
        List<tc9_ti__Time_Sheet_Entry__c> entriesToUpdate = new List<tc9_ti__Time_Sheet_Entry__c>();

        for(Portal_TSE_Wrapper tse: listToUpdate){
            system.debug('tsEntry: '+tse);
            //save the entered start and end times from the wrapper to the records fields
            tse.tsEntry.tc9_ti__StartTime__c = tse.startTimeHrs_24 + ':' + tse.startTimeMins_24;
            tse.tsEntry.tc9_ti__EndTime__c = tse.endTimeHrs_24 + ':' + tse.endTimeMins_24;

            /* ----- SC-18288   -----*/
            //first, flag if we have an over midnight timesheet entry
            if(tse.tsEntry.tc9_ti__StartTime__c > tse.tsEntry.tc9_ti__EndTime__c){
                tseIsOverMidnight = true;
            }

            // add entered Break Start/End Times into the records fields
            tse.tsEntry.Break_Start_Time__c = tse.breakStartHrs_24 + ':' + tse.breakStartMins_24;
            tse.tsEntry.Break_End_Time__c = tse.breakEndHrs_24 + ':' + tse.breakEndMins_24;

            //now determine the minutes for the timecards product Break field
            Long minutes;
            Datetime startBreakDatetime;
            Datetime endBreakDatetime;

            Datetime workStartDatetime;

            Date breakStartDate;
            Date breakEndDate;

            //start clean with the same date as the Work Date for both break start and break end
            breakStartDate = Date.newInstance(tse.tsEntry.tc9_ti__WorkDate__c.year(), tse.tsEntry.tc9_ti__WorkDate__c.month(), tse.tsEntry.tc9_ti__WorkDate__c.day());
            breakEndDate = Date.newInstance(tse.tsEntry.tc9_ti__WorkDate__c.year(), tse.tsEntry.tc9_ti__WorkDate__c.month(), tse.tsEntry.tc9_ti__WorkDate__c.day());

            //get the work start date time, we need this for validating break start date
            workStartDatetime = breakStartDate;
            workStartDatetime = workStartDatetime.addHours(Integer.valueOf(tse.startTimeHrs_24));
            workStartDatetime = workStartDatetime.addMinutes(Integer.valueOf(tse.startTimeMins_24));

            //prepare the start and end break datetimes
            startBreakDatetime = breakStartDate;
            startBreakDatetime = startBreakDatetime.addHours(Integer.valueOf(tse.breakStartHrs_24));
            startBreakDatetime = startBreakDatetime.addMinutes(Integer.valueOf(tse.breakStartMins_24));

            endBreakDatetime = breakEndDate;
            endBreakDatetime = endBreakDatetime.addHours(Integer.valueOf(tse.breakEndHrs_24));
            endBreakDatetime = endBreakDatetime.addMinutes(Integer.valueOf(tse.breakEndMins_24));

            //if our timesheet entry is over midnight then we need to handle breaks over midnight
            if(tseIsOverMidnight == true){
                system.debug('We have a midnight situation');
                //if the break start time is less than the work Start time, we assume the break starts the next day and do the following
                if(startBreakDatetime < workStartDatetime){
                    startBreakDatetime = startBreakDatetime.addDays(1);
                    //as we can only cross one date/24hr period the break end time will definitely be on this next day date also
                    endBreakDatetime = endBreakDatetime.addDays(1);
                    system.debug('Break is starting the next day');
                    //as we are on the same day here than a end break time less than a break start time is incorrect entry by user
                }else{
                    //the start break time is before midnight so lets check if the end time is after mignight
                    if(startBreakDatetime >= workStartDatetime && tse.breakStartHrs_24 > tse.breakEndHrs_24){
                        //we have gone over midnight boundary so lets add a day to the End date
                        endBreakDatetime = endBreakDatetime.addDays(1);
                        system.debug('Break is ending the next day');
                    }
                }
            }

            system.debug('tseIsOverMidnight: '+tseIsOverMidnight);

            system.debug('tse.breakStartHrs_24: '+Integer.valueOf(tse.breakStartHrs_24));
            system.debug('tse.startTimeHrs_24: '+Integer.valueOf(tse.startTimeHrs_24));
            system.debug('tse.breakEndHrs_24: '+Integer.valueOf(tse.breakEndHrs_24));
            system.debug('tse.endTimeHrs_24: '+Integer.valueOf(tse.endTimeHrs_24));

            system.debug('startBreakDatetime: '+startBreakDatetime);
            system.debug('endBreakDatetime: '+endBreakDatetime);

            //now that we have converted Break Start and End to datetime values lets determine the difference in minutes between them
            minutes = ((endBreakDatetime.getTime() - startBreakDatetime.getTime())/1000)/60;
            system.debug('minutes between Start and End of Break: '+minutes);

            //we update the product Break Time (1) with the calculated minutes
            tse.tsEntry.tc9_ti__BreakTime__c = minutes;

            /* end of SC-18288 */

            //add this tse to the list for upsert
            entriesToUpdate.add(tse.tsEntry);
            system.debug('entriesToUpdate'+entriesToUpdate);
        }

        try{
            upsert entriesToUpdate;

            displayAddButtons = true;

            getTimesheetEntries();

            system.debug('new TOTAL: '+day1TotalHours);

            PageReference refreshExpPage = new PageReference('/PortalTimesheetViewEntry?id='+tsId);
            refreshExpPage.setRedirect(true);

            return refreshExpPage;
        } catch (Exception e) {
            system.debug('catch me!');
            //getTimesheetEntries();
            errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'There is an error saving your timesheet.'+detailedErrorMsg+' -- Please Edit, correct and Save again');
            ApexPages.addMessage(errMsg);
            system.debug('ERROR: '+errMsg);

            //this will restore values to pre save attempt
            //getTimesheetEntries();
            return null;
        }
    }

    public PageReference saveLeaveEntries(List<Portal_TSE_Wrapper> listToUpdate){
        ApexPages.Message errMsg;
        String detailedErrorMsg;
        detailedErrorMsg = '';

        system.debug('updating list: '+listToUpdate);
        List<tc9_ti__Time_Sheet_Entry__c> entriesToUpdate = new List<tc9_ti__Time_Sheet_Entry__c>();

        for(Portal_TSE_Wrapper tse: listToUpdate){
            system.debug('tsEntry: '+tse);
            //save the entered start and end times from the wrapper to the records fields
            tse.tsEntry.tc9_ti__StartTime__c = tse.startTimeHrs_24 + ':' + tse.startTimeMins_24;
            tse.tsEntry.tc9_ti__EndTime__c = tse.endTimeHrs_24 + ':' + tse.endTimeMins_24;

            if(detailedErrorMsg != ''){
                errMsg = new ApexPages.Message(ApexPages.severity.WARNING, 'WARNING: There is an issue with your timesheet.'+ detailedErrorMsg +' -- Please Edit, correct and Save again');
                ApexPages.addMessage(errMsg);
            }

            //add this tse to the list for upsert
            entriesToUpdate.add(tse.tsEntry);
            system.debug('entriesToUpdate'+entriesToUpdate);
        }

        try{
            upsert entriesToUpdate;
            displayAddButtons = true;
            getTimesheetEntries();
            system.debug('new TOTAL: '+day1TotalHours);
            PageReference refreshExpPage = new PageReference('/PortalTimesheetViewEntry?id='+tsId);
            refreshExpPage.setRedirect(true);

            return refreshExpPage;
        } catch (Exception e) {
            system.debug('catch me!');
            //getTimesheetEntries();
            errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'There is an error saving your timesheet.'+detailedErrorMsg+' -- Please Edit, correct and Save again');
            ApexPages.addMessage(errMsg);
            system.debug('ERROR: '+errMsg);

            //this will restore values to pre save attempt
            //getTimesheetEntries();
            return null;
        }
    }

    public PageReference saveMobAlwEntries(List<Portal_Allowance_Wrapper> listToUpdate){
        ApexPages.Message errMsg;
        String detailedErrorMsg;
        detailedErrorMsg = '';

        system.debug('updating list: '+listToUpdate);
        List<Adhoc_Allowances__c> entriesToUpdate = new List<Adhoc_Allowances__c>();

        for(Portal_Allowance_Wrapper alw: listToUpdate){
            //add this alw to the list for upsert
            entriesToUpdate.add(alw.alwEntry);
            system.debug('entriesToUpdate'+entriesToUpdate);
        }

        try{
            upsert entriesToUpdate;
            displayAddButtons = true;
            getTimesheetEntries();
            system.debug('new TOTAL: '+day1TotalHours);
            PageReference refreshExpPage = new PageReference('/PortalTimesheetViewEntry?id='+tsId);
            refreshExpPage.setRedirect(true);

            return refreshExpPage;
        } catch (Exception e) {
            system.debug('catch me!');
            //getTimesheetEntries();
            errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'There is an error saving your timesheet.'+detailedErrorMsg+' -- Please Edit, correct and Save again');
            ApexPages.addMessage(errMsg);
            system.debug('ERROR: '+errMsg);

            //this will restore values to pre save attempt
            //getTimesheetEntries();
            return null;
        }
    }

    public PageReference saveAllowanceEntries(List <Adhoc_Allowances__c> listToUpdate){
        ApexPages.Message errMsg;
        String detailedErrorMsg;
        detailedErrorMsg = '';

        system.debug('updating allowances: '+listToUpdate);
        system.debug('update paycode: '+listToUpdate[0].Pay_Code__c);

        try{
            upsert listToUpdate;
            displayAddButtons = true;
            getTimesheetEntries();

            PageReference refreshExpPage = new PageReference('/PortalTimesheetViewEntry?id='+tsId);
            refreshExpPage.setRedirect(true);

            return refreshExpPage;
        } catch (Exception e) {
            system.debug('catch me!');
            //getTimesheetEntries();
            errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'There is an error saving your allowance.'+detailedErrorMsg+' -- Please Edit, correct and Save again');
            ApexPages.addMessage(errMsg);
            system.debug('ERROR: '+errMsg);

            //this will restore values to pre save attempt
            //getTimesheetEntries();
            return null;
        }
    }

    public void submitTS(){

        List<tc9_ti__Time_Sheet_Entry__c> entriesToUpdate = new List<tc9_ti__Time_Sheet_Entry__c>();
        List<Adhoc_Allowances__c> allowancesToUpdate = new List<Adhoc_Allowances__c>();

        for(Adhoc_Allowances__c alw : [SELECT Id, Timesheet__c, Approval_Status__c FROM Adhoc_Allowances__c WHERE Timesheet__c =: tsId]){
            alw.Approval_Status__c = 'Submitted';
            allowancesToUpdate.add(alw);
        }

        try{

            upsert allowancesToUpdate;
            tc9_ti__Time_Sheet__c timesheet = new tc9_ti__Time_Sheet__c();
            timesheet.Id = tsId;

            for(tc9_ti__Time_Sheet__c ts : [SELECT Id, tc9_ti__Status__c, tc9_ti__Placement__r.tc9_ti__Auto_Approve_0_Timesheets__c, tc9_ti__WeeklyActualHours__c
                FROM tc9_ti__Time_Sheet__c
                WHERE Id =: tsId]){
                if(ts.tc9_ti__Placement__r.tc9_ti__Auto_Approve_0_Timesheets__c && ts.tc9_ti__WeeklyActualHours__c == 0){
                    timesheet.tc9_ti__Status__c = 'Approved';
//                    tsStatus = 'Approved';

                }else{
                    timesheet.tc9_ti__Status__c = 'Submitted';
//                    tsStatus = 'Submitted';
                }
            }
            upsert timesheet;
            
            for(tc9_ti__Time_Sheet_Entry__c tse : [SELECT Id, tc9_ti__Time_Sheet__c, tc9_ti__Status__c, tc9_ti__Time_Sheet__r.tc9_ti__Status__c
                FROM tc9_ti__Time_Sheet_Entry__c
                WHERE tc9_ti__Time_Sheet__c =: tsId]){
                if(tse.tc9_ti__Time_Sheet__r.tc9_ti__Status__c == 'Approved'){
                    tse.tc9_ti__Status__c = 'Approved';
                }else{
                    tse.tc9_ti__Status__c = 'Submitted';
                }
                entriesToUpdate.add(tse);
            }
            upsert entriesToUpdate;
            getTimesheetEntries();

        }  catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'There is an error saving your timesheet. Please contact your administrator or try again ');
            ApexPages.addMessage(errMsg);
        }
    }

    public void resubmitTS(){
        List<tc9_ti__Time_Sheet_Entry__c> entriesToUpdate = new List<tc9_ti__Time_Sheet_Entry__c>();
        List<Adhoc_Allowances__c> allowancesToUpdate = new List<Adhoc_Allowances__c>();

        for(tc9_ti__Time_Sheet_Entry__c tse : [SELECT Id, tc9_ti__Time_Sheet__c, tc9_ti__Status__c FROM tc9_ti__Time_Sheet_Entry__c WHERE tc9_ti__Time_Sheet__c =: tsId]){
            tse.tc9_ti__Status__c = 'New';
            entriesToUpdate.add(tse);
        }
        for(Adhoc_Allowances__c alw : [SELECT Id, Timesheet__c, Approval_Status__c FROM Adhoc_Allowances__c WHERE Timesheet__c =: tsId]){
            alw.Approval_Status__c = 'New';
            allowancesToUpdate.add(alw);
        }

        try{
            upsert entriesToUpdate;
            upsert allowancesToUpdate;
            tc9_ti__Time_Sheet__c timesheet = new tc9_ti__Time_Sheet__c();
            timesheet.Id = tsId;
            timesheet.tc9_ti__Status__c = 'New';
            upsert timesheet;
            getTimesheetEntries();
        }  catch (Exception e) {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'There is an error saving your timesheet. Please contact your administrator or try again ');
            ApexPages.addMessage(errMsg);
        }
    }
    public void getProjectCodes(){
        //project codes
        projectCodes     = new  List<SelectOption>{new SelectOption('', '--None--')};
        for(tc9_ti__Job_Project_Code__c projCode : [SELECT id, tc9_ti__Project_Code__c, tc9_ti__Project_Code__r.Name , tc9_ti__Job_Order__c
        FROM tc9_ti__Job_Project_Code__c
        WHERE tc9_ti__Job_Order__c =: tsJob//timesheet.tc9_ti__Placement__r.ts2__Job__c
        AND tc9_ti__Project_Code__r.tc9_ti__Status__c = 'Active'
        order by tc9_ti__Project_Code__r.Name]){
            projectCodes.add(new SelectOption(projCode.tc9_ti__Project_Code__r.Id, projCode.tc9_ti__Project_Code__r.Name));
        }
        system.debug('prjcodes: '+projectCodes);
    }
    public void getAdhocAllowances(){

        adhocAllowances = new List<SelectOption>{new SelectOption('','--None--')};
        Id alwPlcRT = ([SELECT Id FROM RecordType WHERE SObjectType = 'Adhoc_Allowances__c' AND Name = 'Placement' Limit 1]).Id;

        for(Adhoc_Allowances__c adhoc : [SELECT Id, Pay_Code__c, Pay_Code__r.Id, Pay_Code__r.Name, Placement__c, Entry_Date__c, Effective_Date__c, Expiry_Date__c, Timesheet_Start_Date__c
        FROM Adhoc_Allowances__c
        WHERE Placement__c =:tsPlc
        AND Pay_Code__c != null]){

            system.debug('adhoc PayCode: '+adhoc.Pay_Code__r.Name);
            if(adhoc.Effective_Date__c <= tsStartDate && (adhoc.Expiry_Date__c >= tsStartDate || adhoc.Expiry_Date__c == null)){
                adhocAllowances.add(new SelectOption(adhoc.Pay_Code__r.Id, adhoc.Pay_Code__r.Name));
            }
        }
        system.debug('adhoc allowance pay codes: '+adhocAllowances);
    }
    public List<SelectOption> getLeaveTypes(){

        // do a field describe of the picklist field
        Schema.DescribeFieldResult describeResult = tc9_ti__Time_Sheet_Entry__c.tc9_ti__Type_of_Leave__c.getDescribe();

        // get the picklist values from this describe result
        List<Schema.PicklistEntry> entries = describeResult.getPicklistValues();

        // list of options to be returned to the VF page
        leaveTypes = new List<SelectOption>();

        for (Schema.PicklistEntry pEntry : entries) {
            if (pEntry.isActive()) {
                leaveTypes.add(new SelectOption(pEntry.getValue(), pEntry.getLabel()));
            }
        }

        return leaveTypes;
    }

    //remote action to upload documentation and create Attachments
    @RemoteAction
    public static String doUploadAttachment(String parentId, String attachmentBody, String attachmentName, String attachmentId, String attachmentDesc) {
        return Portal_JSRemoting_FileUpload_Ctlr.doUploadAttachment(parentId, attachmentBody, attachmentName, attachmentId, attachmentDesc);
    }

}