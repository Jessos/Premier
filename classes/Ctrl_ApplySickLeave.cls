/*
Change History 
*********************************************************************************************************************************************
    SCRUM       ModifiedBy      Date            Requested By            Description                                               Tag
*********************************************************************************************************************************************
    SC-11634    Sethu           03/10/2016      Jacob Morton            Pass tsid parameter in cancel button                      <T01>
    SC-14330    Sethu           23/01/2017      Jacob Morton            Store AM/PM in timesheet entry                            <T02>
    SC-14685    Sethu           09/03/2017      Jacob Morton            Handled empty start/end time                              <T03>
*/


/**
* @author Vignesh Damodharan
* @date 03/02/2014
* @description This is the controller for the Sick Leave Apply Page
*/

public with sharing class Ctrl_ApplySickLeave{
    
    public boolean isMoreHoursEntered {get;set;}
    public boolean isHoursEntered {get;set;}
    public boolean isSaved {get;set;}
    public boolean isError {get;set;}
    public String selList1{get;set;}
    public String selList2{get;set;}
    public Contact oContact {get;set;}
    public tc9_ti__Time_Sheet__c oTimesheet {get;set;}
    public tc9_ti__Time_Sheet_Entry__c oTimesheetEntry {get;set;}
    
    public Id conId; 
    public String usrLang {get{
        return UserInfo.getLanguage();}}
    public String strTimesheetId{get;set;}
    public Decimal nHoursRemainingForTheDay {get;set;}
    public Decimal nHoursApplied{get;set;}
    private Set <Date> plcPublicHoliday = new Set <Date>();
    
    public Ctrl_ApplySickLeave(){
        Initialize();       
                       
    }
    
/**
* @author Vignesh Damodharan
* @date 25/02/2014
* @description This method Initializes the page
* @param 
* @return 
*/      
    private void Initialize(){
        
        isMoreHoursEntered          = false;
        isHoursEntered              = false;
        isSaved                     = false;
        isError                     = false;
        
        strTimesheetId              ='';
        nHoursApplied               = 0;
        oTimesheetEntry             = new tc9_ti__Time_Sheet_Entry__c();
        oTimesheet                  = new tc9_ti__Time_Sheet__c();
        oContact                    = new Contact();
        
        User currentUser = [SELECT Id, contactId FROM User WHERE Id =: UserInfo.getUserId()];
        system.debug('userrrrr '+currentUser);
        
        conId = currentUser.contactId; //get current user's contact id
        system.debug('conIdddd '+conId);
        if(ApexPages.currentPage().getParameters().get('tsId') != NULL){
            
            //get the parameter which determines the timesheet
            strTimesheetId = ApexPages.currentPage().getParameters().get('tsId');
            
            oTimesheet = [select tc9_ti__Placement__r.tc9_ti__Public_Holiday_Calendar__c, tc9_ti__Status__c, tc9_ti__Start_Date__c, tc9_ti__End_Date__c, tc9_ti__Candidate__c, Id, Client_Name__c From tc9_ti__Time_Sheet__c t
                                            where Id =: strTimesheetId LIMIT 1];
            
            system.debug('*** ' + oTimesheet);
                                            
            if(oTimesheet.tc9_ti__Status__c != 'New' && oTimesheet.tc9_ti__Status__c != 'Rejected'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Cannot_edit_an_approved_Timesheet));
            }                                
            
            //get all plcPublicHoliday for the placment 
            plcPublicHoliday    = getPublicHoliday();
            
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Associate_a_Timesheet_in_the_page));
        } 
    }
    
/**
* @author Vignesh Damodharan
* @date 25/02/2014
* @description This method creates timesheetentry for the selected workdate
* @param 
* @return PageReference
*/        
    public PageReference Validate(){
         
        isError             = false;
        isMoreHoursEntered  = false;
        isHoursEntered      = false;
        nHoursApplied = 0.0;
        
        //get the balance from the contact
        
        oContact = [SELECT Id, Available_Sick_Leave_Balance__c FROM Contact WHERE Id=: conId];
        
        nHoursRemainingForTheDay    = oContact.Available_Sick_Leave_Balance__c;
        
        system.debug('*** ' + oTimesheet);
        
        system.debug('*** ' + oTimesheetEntry.tc9_ti__StartTime__c + ' - ' + oTimesheetEntry.tc9_ti__EndTime__c);
        system.debug('*** ' + oTimesheetEntry.tc9_ti__WorkDate__c + ' - ' + oTimesheet.tc9_ti__Start_Date__c+ ' - ' + oTimesheet.tc9_ti__End_Date__c);
        System.debug('&&&&&&'+selList1+'****'+selList2);
        
        if (oTimesheetEntry.tc9_ti__WorkDate__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter a date.'));
            isError = true;
        }
        
        if ((oTimesheetEntry.tc9_ti__StartTime__c == null || oTimesheetEntry.tc9_ti__StartTime__c=='') || (oTimesheetEntry.tc9_ti__EndTime__c == null  || oTimesheetEntry.tc9_ti__EndTime__c=='')){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter StartTime and EndTime.'));
            isError = true;
        }
        
        if ((oTimesheetEntry.tc9_ti__WorkDate__c < oTimesheet.tc9_ti__Start_Date__c) || (oTimesheetEntry.tc9_ti__WorkDate__c > oTimesheet.tc9_ti__End_Date__c)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter Date within the time range of timesheet.'));
            isError = true;
        }
        
        //</T03>***********************************************
        if(isError)
            return null;
        
        if(!isError){
            nHoursApplied = CalculateHoursDifference( oTimesheetEntry.tc9_ti__StartTime__c, oTimesheetEntry.tc9_ti__EndTime__c);
            System.debug('!!!! '+nHoursApplied);
        }
        
        if (nHoursApplied <= 0 ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You have applied for zero hours.'));
            isError = true;
        }       
        //</T03>***********************************************
        
        if(oTimesheetEntry.tc9_ti__StartTime__c != null && oTimesheetEntry.tc9_ti__StartTime__c !=''){ //T03
            decimal sTimeHours = decimal.valueOf(oTimesheetEntry.tc9_ti__StartTime__c.substring(0,2));
            decimal sTimeMins = decimal.valueOf(oTimesheetEntry.tc9_ti__StartTime__c.substring(3,5));
        }
        
        if(oTimesheetEntry.tc9_ti__EndTime__c != null && oTimesheetEntry.tc9_ti__EndTime__c !=''){ //T03
            decimal eTimeHours = decimal.valueOf(oTimesheetEntry.tc9_ti__EndTime__c.substring(0,2));
            decimal eTimeMins = decimal.valueOf(oTimesheetEntry.tc9_ti__EndTime__c.substring(3,5));
        }
        
        
        
      if(nHoursRemainingForTheDay < 0){
            isHoursEntered = true;
        }
    
        System.debug('@@@@ '+nHoursApplied);
        System.debug('@@@@ '+nHoursRemainingForTheDay);
        System.debug('@@@@ '+oContact.Available_Sick_Leave_Balance__c);
        
        if(nHoursApplied > oContact.Available_Sick_Leave_Balance__c){
            isHoursEntered = true;
            nHoursRemainingForTheDay =  oContact.Available_Sick_Leave_Balance__c;           
        }
        if(isHoursEntered) 
            isError= true;
        
        System.debug('@@@@ '+nHoursApplied);
        System.debug('@@@@ '+nHoursRemainingForTheDay);
        
        return null;
    }     

/**
* @author Vignesh Damodharan
* @date 25/02/2014
* @description This method creates timesheetentry for the selected workdate
* @param 
* @return PageReference
*/        
    public PageReference Save(){
         
        isError     = false;
        System.debug('selList1=='+selList1+'selList2=='+selList2);
        System.debug('oTimesheetEntry.tc9_ti__StartTime__c=='+oTimesheetEntry.tc9_ti__StartTime__c);
        if(oTimesheetEntry.tc9_ti__StartTime__c == null || oTimesheetEntry.tc9_ti__EndTime__c == null || oTimesheetEntry.tc9_ti__StartTime__c == '' || oTimesheetEntry.tc9_ti__EndTime__c == '') {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please ensure all fields (date and time) are populated. Please enter time for HH:MM, thank you'));
            return null;
        }
        
        Validate();
        
        if(isError){
            return null;
        }
        
        Time sTime = Time.newInstance(Integer.valueOf(oTimesheetEntry.tc9_ti__StartTime__c.substring(0,2)), Integer.valueOf(oTimesheetEntry.tc9_ti__StartTime__c.substring(3,4)), 0, 0);
        Time eTime = Time.newInstance(Integer.valueOf(oTimesheetEntry.tc9_ti__EndTime__c.substring(0,2)), Integer.valueOf(oTimesheetEntry.tc9_ti__EndTime__c.substring(3,4)), 0, 0);
        
        Datetime startTime  = Datetime.newInstance(Date.today(), sTime);
        Datetime endTime    = Datetime.newInstance(Date.today(), eTime);    
        
        //check workdate is a public holiday or not 
        Boolean isPublicHoliday = plcPublicHoliday.contains(oTimesheetEntry.tc9_ti__WorkDate__c);
        
        Savepoint sp = Database.setSavepoint();
        
        isSaved= true;
         Leave_Ledger__c newLeave  = null;
        try{
            //Create Timesheet Entry
            oTimesheetEntry.tc9_ti__Time_Sheet__c       = oTimesheet.Id;
            oTimesheetEntry.tc9_ti__NormalStart__c      = startTime;
            oTimesheetEntry.tc9_ti__NormalEnd__c        = endTime;
            oTimesheetEntry.tc9_ti__IsPublicHoliday__c  = isPublicHoliday;
            oTimesheetEntry.tc9_ti__Type_of_Leave__c    = 'Sick';
            
            //<T02>*********************************
            oTimesheetEntry.tc9_ti__Start_Meridian__c = selList1;
            oTimesheetEntry.tc9_ti__End_Meridian__c = selList2;
            //</T02>*********************************
            
            insert oTimesheetEntry;
            
            oTimesheetEntry = [SELECT Id, Name, tc9_ti__WorkDate__c FROM tc9_ti__Time_Sheet_Entry__c WHERE Id=: oTimesheetEntry.id];
            
            newLeave  = new Leave_Ledger__c();
            newLeave.Contact__c         = oContact.id;
            newLeave.Leave_Hours__c     = -nHoursApplied;
            newLeave.Type__c            = 'Sick Leave';
            newLeave.Reason__c          = 'Sick Leave - '+oTimesheetEntry.Name;
            newLeave.Name               = 'Sick Leave - '+oTimesheetEntry.Name;
            newLeave.Timesheet_Entry__c = oTimesheetEntry.Id; 
            newLeave.Date_Incurred__c   = oTimesheetEntry.tc9_ti__WorkDate__c; 
            newLeave.Status__c          = 'Submitted';
            insert newLeave;
        }
        catch(Exception e){
            System.debug('-nHoursApplied=='+-nHoursApplied);
            isSaved = false;
            String error = e.getMessage();
            String[] errors = error.split(',');
            String substr = errors[1].substring(0,errors[1].length()-2);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,substr)); 
            Database.rollback(sp);
        }
        
        if(isSaved == true){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Your sick leave was successfully saved. Enter another sick leave time or press \'Cancel\' to return to Timesheet.'));
        }
        
        Initialize();
           
        return null;
    }

/**
* @author Vignesh Damodharan
* @date 25/02/2014
* @description This method calculates the Hours Difference between the start and end time in HH:MM format
* @param 
* @return Decimal time difference
*/     
    private Decimal CalculateHoursDifference(String strStart, String strEnd){
        
        /* Start Time Calculations - Start*/
        //<T03>****************************************
        decimal sTimeHours = 0.0;
        decimal sTimeMins = 0.0;
        decimal TotalsMins = 0.0;
        if(strStart != null && strStart != ''){
        //</T03>****************************************
            sTimeHours = decimal.valueOf(strStart.substring(0,2));
            sTimeMins = decimal.valueOf(strStart.substring(3,5));
            System.debug('sTimeHours=='+sTimeHours+'sTimeMins=='+sTimeMins);
            if(selList1 == 'PM'){
                if(sTimeHours < 12)
                    sTimeHours += 12;
            } else if(sTimeHours == 12){
                sTimeHours -= 12;
            }    
            System.debug('sTimeHours=='+sTimeHours+'sTimeMins=='+sTimeMins);
            TotalsMins = (sTimeHours*60)+sTimeMins;
        }
        /* Start Time Calculations - End*/
        
        
        /* End Time Calculations - Start*/
        //<T03>****************************************
        decimal eTimeHours = 0.0;
        decimal eTimeMins = 0.0;
        decimal TotaleMins = 0.0;
        if(strEnd != null && strEnd != ''){
        //<T03>****************************************
            eTimeHours = decimal.valueOf(strEnd.substring(0,2));
            eTimeMins = decimal.valueOf(strEnd.substring(3,5));       
            System.debug('eTimeHours=='+eTimeHours+'eTimeMins=='+eTimeMins);
             if(selList2 == 'PM')
             {
                if(eTimeHours < 12)
                {
                    eTimeHours +=  12;
                }
            }else if(eTimeHours == 12){
                eTimeHours -= 12;
            }
            System.debug('eTimeHours=='+eTimeHours+'eTimeMins=='+eTimeMins);
            TotaleMins = (eTimeHours*60)+eTimeMins;
        }
        /* Start Time Calculations - End*/
        
        
        decimal diff = (TotaleMins - TotalsMins)/60;
        
        if(diff<0)
        {
             TotaleMins = (24*60)+(eTimeHours*60)+eTimeMins;
        
             diff = (TotaleMins - TotalsMins)/60;
        }
        system.debug('timeeeee '+TotaleMins);    
        system.debug('timeeeee '+TotalsMins);    
        
            
        
        decimal nHoursApplied = (diff).setScale(2);

        
        system.debug('nHoursApplied '+nHoursApplied);    
        return nHoursApplied;
    }
    
/**
* @author Vignesh Damodharan
* @date 25/02/2014
* @description This method gets and populates the Public Holiday in a set
* @param 
* @return Set<Date> holidays
*/ 
    private Set <Date> getPublicHoliday(){
                
        Set <Date> holidays = new Set<Date>();  // inital a set for a calendar;
        
        //get calender records
        for (tc9_ti__Public_Holiday_Calendar__c cal : [SELECT Id, (SELECT Id, tc9_ti__Start_Date__c, tc9_ti__End_Date__c 
                                                         FROM tc9_ti__Public_Holiday_Calendar_Items__r)   
                                             FROM  tc9_ti__Public_Holiday_Calendar__c 
                                             WHERE id = :oTimesheet.tc9_ti__Placement__r.tc9_ti__Public_Holiday_Calendar__c]){
            for (tc9_ti__Public_Holiday_Calendar_Item__c calItem : cal.tc9_ti__Public_Holiday_Calendar_Items__r ){
                
                //add start date
                if(calItem.tc9_ti__Start_Date__c != null)
                    holidays.add(calItem.tc9_ti__Start_Date__c);
                    
                //add following dates till end date
                if(calItem.tc9_ti__End_Date__c != null && calItem.tc9_ti__Start_Date__c != null && calItem.tc9_ti__Start_Date__c < calItem.tc9_ti__End_Date__c){
                    for(Date d = calItem.tc9_ti__Start_Date__c + 1; d <= calItem.tc9_ti__End_Date__c ; d = d+1)
                        holidays.add(d);
                }
            }                       
        }
        return holidays;
    }
    
/**
* @author Vignesh Damodharan
* @date 25/02/2014
* @description This method creates timesheetentry for the selected workdate
* @param 
* @return PageReference
*/        
    public PageReference Cancel(){
         
        Pagereference page = new Pagereference('/apex/tc9_ti__FillTimesheet_Page_v2?tsId=' + strTimesheetId); //T01
        page.setRedirect(true);
           
        return page;
    }  
}