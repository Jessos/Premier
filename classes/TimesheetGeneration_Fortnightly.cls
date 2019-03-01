/*
    
     Change History 
    ******************************************************************************************************************************************************************
         SCRUM        ModifiedBy        Date            Requested By                           Description                                                      Tag
    ******************************************************************************************************************************************************************
        SC-7045         Srinidhi.R      10/12/2015      David Levy                  TImesheet Entries Currency should be the same as TImesheet
        sc-10128        Khushboo.B      24/12/2015      Michelle Cole               Splitting timesheets over month
        sc-10166        Khushboo.B      04/01/2016      Michelle Cole               Fix for missing timesheet entry
        sc-10167        Khushboo.B      05/01/2016      Michelle Cole               Duplicate timesheet entries
        SC-10781        Srinidhi.R      22/04/2016      David Levy                  Timesheet are not being created for Bi-Weekly 1 and Bi-Weekly 2
        SC-10793        Jagadeswary.S   27/05/2016      David Levy                  Solution if Work Week Start Day in CUstom Setting has a Typo
        SC-10841        Jagadeswary     23/09/2016      Guy Baxter                  Flag for Timesheet Entries created by standard tcs timesheet generation process
        SC-17572        Jagadeswary     11/10/2017      David Levy                  Defect when extending timesheet - Fortnightly 1

*/
public with sharing class TimesheetGeneration_Fortnightly {

    private ts2__Placement__c plc ;
    private final integer numsworkingday = 14;
    private Date plcFirstWeekStartDay;
    private Date plcLastWeekEndDay;
    private boolean isAcrossDaysTimings; 
    public boolean isFlagged;
    
    public tc9_ti__Debug_Header__c dHead;
    private List<tc9_ti__Rule__c> saturdayRule = new List<tc9_ti__Rule__c>();
    private List<tc9_ti__Rule__c> sundayRule   = new List<tc9_ti__Rule__c>();

    public Map<Id,String> mapOfPlcAndError = new Map<Id,String>();
    public Map<Id,Id> mapOfTsToPlc = new Map<Id,Id>();
    public boolean isGenericException;   
    
    private String SATURDAY_RULE = 'Saturday';
    private String SUNDAY_RULE = 'Sunday';
    public DateTime startDt;
    public DateTime endDt;
    public Integer weekStartDay = 1; // default Monday
    public String strWeekDay = 'Monday'; // used to populate in Timesheet
    public String entryType = '';
    Map<Date, tc9_ti__Time_Sheet__c> startDate_Timesheet;   //startDate_timesheet
    private String NON_BATCH_METHOD = 'Generate Timesheet button';
    private String BATCH_METHOD = 'Auto Generate Timesheet';
    
    private Set <Date> plcPublicHoliday = new Set <Date>(); //public holidays of the placement
    Map<id, List<tc9_ti__Time_Sheet_Entry__c>> mapOfTimeSheettoEntries;
    public Boolean isScheduledJob;    
    public String errMsg {get; private set;}
    public String usrLang {get{
        return UserInfo.getLanguage();}}
    List<tc9_ti__Time_Sheet__c> existingTS ;
    List<tc9_ti__Public_Holiday_Calendar__c> listOfPublicHols;
    private Map<String, Integer> mapOfDays= new Map<String, Integer>();
    private Map<String, String> WeekDayMap = new Map<String, String>();
    
    Date customToStartOfWeek(Date thisDate){        
        Date sundayDate = thisDate.toStartOfWeek();
        if(sundayDate.addDays(weekStartDay) <= thisDate)
            return sundayDate.addDays(weekStartDay);
        return sundayDate.addDays(weekStartDay).addDays(-7);        
    }
    
    private static DateTime getDateTime(Date dat, String time1){
        String[] theTime =  time1.split(':'); 
        DateTime dt = DateTime.newInstance( dat.year(), dat.month(), dat.day(), Integer.valueOf(theTime[0]), Integer.valueOf(theTime[1]), 0);
        return dt;
    }
    
    public TimesheetGeneration_Fortnightly(ts2__Placement__c plc, tc9_ti__Rule__c saturdayRule ,tc9_ti__Rule__c sundayRule, List<tc9_ti__Time_sheet__c> existTS, List<tc9_ti__Public_Holiday_Calendar__c> listOfPublicHolidays, tc9_ti__Debug_Header__c dHead) {
        isGenericException = false;
        existingTS = new List<tc9_ti__Time_sheet__c>();
        listOfPublicHols = new List<tc9_ti__Public_Holiday_Calendar__c>();
        //placement record
        this.plc = plc;
        if(existTS != null){
            this.existingTS = existTS;
        }
        //system.debug('existingTS2'+existingTS);
        if(listOfPublicHolidays != null && !listOfPublicHolidays.isEmpty()){
            this.listOfPublicHols  = listOfPublicHolidays;
        }
        if(saturdayRule != null){
            this.saturdayRule.add(saturdayRule); 
        }
        if(sundayRule != null)
            this.sundayRule.add(sundayRule);     
        isAcrossDaysTimings = false;
                      
        //see if the related award master has across-days timings
        startDt = getDateTime(Date.today(), plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_Start_Time__c);
        endDt   = getDateTime(Date.today(), plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_End_Time__c);
        
        if(startDt > endDt)
             isAcrossDaysTimings = true;
        
         mapOfTimeSheettoEntries = new Map<id,List<tc9_ti__Time_Sheet_Entry__c>>();
        //Create the Custom Setting Instance     
        tc9_ti__ToCloudNineConfig__c custSetting    = tc9_ti__ToCloudNineConfig__c.getInstance();
                    
        //search for week start day in order ==> Job / Client / custom settings
        strWeekDay = plc.ts2__Job__r.tc9_ti__Week_Start_Day__c;
        
        if(strWeekDay == null)  strWeekDay = plc.ts2__Client__r.tc9_ti__Week_Start_Day__c;
        if(strWeekDay == null && custSetting.tc9_ti__Week_Start_Day__c!= null && constantsClass.DAYSOFWEEK.contains(custSetting.tc9_ti__Week_Start_Day__c.toUpperCase()))
                strWeekDay=custSetting.tc9_ti__Week_Start_Day__c;
            
        if(strWeekDay == null)  strWeekDay = 'Monday';
        weekStartDay         = UtilClass1.getWeekDayNumber(strWeekDay);  //get as number
        
        if(plc.tc9_ti__Timesheet_Frequency__c == 'Fortnightly-1'){
            //plc week start date
            plcFirstWeekStartDay= customToStartOfWeek(plc.ts2__Start_Date__c);
            plcFirstWeekStartDay = plcFirstWeekStartDay.addDays(-7);
        }
        else if(plc.tc9_ti__Timesheet_Frequency__c == 'Fortnightly-2'){
            plcFirstWeekStartDay= customToStartOfWeek(plc.ts2__Start_Date__c);
        }
        
        //plc week end date
        Date plcDate = plcFirstWeekStartDay;
        system.debug('plcFirst '+plcDate);
        for(;plcDate<=plc.ts2__End_Date__c;){
            plcDate=plcDate.addDays(numsworkingday);
            plcLastWeekEndDay = plcDate;
            //system.debug('plc '+plcLastWeekEndDay);
        }
        //system.debug('plcFirstWeekStartDayyyyyyyforrrrrr '+plcLastWeekEndDay.addDays(-1));
        
        plcLastWeekEndDay   = plcLastWeekEndDay.addDays(-1);
        
        WeekDayMap.put('Sunday', 'Monday');
        WeekDayMap.put('Monday', 'Tuesday');
        WeekDayMap.put('Tuesday', 'Wednesday');
        WeekDayMap.put('Wednesday', 'Thursday');
        WeekDayMap.put('Thursday', 'Friday');
        WeekDayMap.put('Friday', 'Saturday');
        WeekDayMap.put('Saturday','Sunday');  
        
        String workweekday = strWeekDay;
        for(Integer i = 0 ; i<7; i++){
            mapOfDays.put(workweekday, i);
            workweekday = WeekDayMap.get(workweekday);
        }       
     }
     
     public ts2__Placement__c updatePlacementStatus(){
        plc.tc9_ti__Is_timesheet_created__c = true;
        plc.tc9_ti__Last_Timesheet_Creation_Date__c = DateTime.now();
        return plc;       
     }
     
     public void createTimesheets(){
        
        //get the existing timesheets
        //List<Time_Sheet__c> existingTS = [SELECT id, Start_Date__c, End_Date__c,Status__c,Flagged__c FROM Time_Sheet__c where Placement__c =: plc.Id];
        
        List<tc9_ti__Time_Sheet__c> tsToInsert      = new List<tc9_ti__Time_Sheet__c>();
        List<tc9_ti__Time_Sheet__c> tsToDelete      = new List<tc9_ti__Time_Sheet__c>();
        Map<String, List<tc9_ti__Time_Sheet__c>> splitTimes = new Map<String, List<tc9_ti__Time_Sheet__c>>();
        //clear map
        startDate_Timesheet = new Map<Date, tc9_ti__Time_Sheet__c>();
        
        //group timesheet by start date
        for(tc9_ti__Time_Sheet__c ts : existingTS){ 
            //mark timesheet for deletion
            if(ts.tc9_ti__Start_Date__c < plcFirstWeekStartDay || ts.tc9_ti__Start_Date__c > plcLastWeekEndDay)
                tsToDelete.add(ts);
            else //add it to map
                startDate_Timesheet.put(ts.tc9_ti__Start_Date__c, ts);
        }
        //create timesheets when needed
        if(plc.tc9_ti__Split_Timesheets_Over_Months__c){
            for(Date startDate = plcFirstWeekStartDay ; startDate < plcLastWeekEndDay ; startDate += 14){
                Date eDate = startDate.addDays(13);
                if(!startDate_Timesheet.containsKey(startDate) && !startDate_Timesheet.containsKey(eDate.toStartOfMonth())){
                    if(eDate.day() < startDate.day()){
                        tc9_ti__Time_Sheet__c tempTime1 = new tc9_ti__Time_Sheet__c(tc9_ti__Candidate__c = plc.ts2__Employee__c, tc9_ti__Start_Date__c = startDate, tc9_ti__End_Date__c = eDate.toStartOfMonth().addDays(-1), tc9_ti__status__c = 'New',tc9_ti__Placement__c = this.plc.Id, tc9_ti__Week_Start_Day__c = strWeekDay, tc9_ti__Generate_Transaction__c = '1', CurrencyISOCode = plc.CurrencyISOCode);
                        tc9_ti__Time_Sheet__c tempTime2 = new tc9_ti__Time_Sheet__c(tc9_ti__Candidate__c = plc.ts2__Employee__c, tc9_ti__Start_Date__c = eDate.toStartOfMonth(), tc9_ti__End_Date__c = eDate, tc9_ti__status__c = 'New',tc9_ti__Placement__c = this.plc.Id, tc9_ti__Week_Start_Day__c = strWeekDay, tc9_ti__Generate_Transaction__c = '1', CurrencyISOCode = plc.CurrencyISOCode);
                        String strKey = startDate.format()+eDate.format();
                        splitTimes.put(strKey, new List<tc9_ti__Time_Sheet__c>{tempTime1});
                        splitTimes.get(strKey).add(tempTime2);
                    }
                    else {                  
                        tsToInsert.add(new tc9_ti__Time_Sheet__c(tc9_ti__Candidate__c = plc.ts2__Employee__c, tc9_ti__Start_Date__c = startDate, tc9_ti__End_Date__c = eDate, tc9_ti__status__c = 'New',tc9_ti__Placement__c = this.plc.Id, tc9_ti__Week_Start_Day__c = strWeekDay, tc9_ti__Generate_Transaction__c = '1', CurrencyISOCode = plc.CurrencyISOCode));         
                    }
                }                               
            }
        }
        else {
            for(Date startDate = plcFirstWeekStartDay ; startDate < plcLastWeekEndDay ; startDate += 14){ 
                if(!startDate_Timesheet.containsKey(startDate) )
                    tsToInsert.add(new tc9_ti__Time_Sheet__c(  tc9_ti__Candidate__c = plc.ts2__Employee__c, tc9_ti__Start_Date__c = startDate, tc9_ti__End_Date__c = startDate.addDays(13), tc9_ti__status__c = 'New',tc9_ti__Placement__c = this.plc.Id, tc9_ti__Week_Start_Day__c = strWeekDay,tc9_ti__Generate_Transaction__c = '1', CurrencyISOCode = plc.CurrencyISOCode));
            }
        }
        
        if(!splitTimes.isEmpty()){
            for(String strKey : splitTimes.keySet()){
                tsToInsert.addAll(splitTimes.get(strKey));
            }
        }
        
        if(!existingTS.isEmpty()){
            existingTS.clear();
        }         
        
        Map<Id, tc9_ti__Time_Sheet__c> successfulTs = new Map<Id,tc9_ti__Time_Sheet__c>(); 
        if(!tsToInsert.isEmpty()){
            Database.SaveResult[] srList = Database.insert(tsToInsert,false);     
            for(Integer i=0;i<srList.size();i++){
                if(srList.get(i).isSuccess()){
                    successfulTs.put(tsToInsert.get(i).Id, tsToInsert.get(i));
                }
                else if (!srList.get(i).isSuccess()){
                    // DML operation failed
                    Database.Error error = srList.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    
                    system.debug('Failed ID'+tsToInsert.get(i).tc9_ti__Placement__c);
                    mapOfPlcAndError.put(tsToInsert.get(i).tc9_ti__Placement__c,failedDML);//map of entries and error message
                             
                }
        
            } 
        }
          
        if(!splitTimes.isEmpty()){
            List<tc9_ti__Time_Sheet__c> tstoUpdate = new List<tc9_ti__Time_Sheet__c>();
            for(String strKey : splitTimes.keySet()){
                tc9_ti__Time_Sheet__c tempTime1 = splitTimes.get(strKey).get(0);
                tc9_ti__Time_Sheet__c tempTime2 = splitTimes.get(strKey).get(1);
                if(tempTime1 != null && tempTime2 != null && tempTime1.Id != null && tempTime2.Id != null){
                    tstoUpdate.add(new tc9_ti__Time_Sheet__c(Id = tempTime1.Id, tc9_ti__Timesheet_Split_Over_Months__c = true, tc9_ti__Related_Split_Over_Month_Timesheet__c = tempTime2.Id, tc9_ti__Placement__c = tempTime1.tc9_ti__Placement__c));
                    tstoUpdate.add(new tc9_ti__Time_Sheet__c(Id = tempTime2.Id, tc9_ti__Timesheet_Split_Over_Months__c = true, tc9_ti__Related_Split_Over_Month_Timesheet__c = tempTime1.Id, tc9_ti__Placement__c = tempTime1.tc9_ti__Placement__c));
                }               
            }
            
            ConstantsClass.Is_Timesheet_Update_Allowed = false;
            
            if(!tstoUpdate.isEmpty()){
                Database.SaveResult[] srList = Database.update(tstoUpdate,false);     
                for(Integer i=0;i<srList.size();i++){
                    if (!srList.get(i).isSuccess()){
                        // DML operation failed
                        Database.Error error = srList.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();
                        mapOfPlcAndError.put(tstoUpdate.get(i).tc9_ti__Placement__c,failedDML);//map of entries and error message
                        successfulTs.remove(tstoUpdate.get(i).Id);        
                    }
            
                }
            }
            
            ConstantsClass.Is_Timesheet_Update_Allowed = true;
        }
        //add it to map
        for(tc9_ti__Time_Sheet__c ts : successfulTs.values()){
             startDate_Timesheet.put(ts.tc9_ti__Start_Date__c, ts);
             mapOfTsToPlc.put(ts.Id,ts.tc9_ti__Placement__c);
        }
        
     }  
     
     
     public List<tc9_ti__Time_Sheet_Entry__c> updateOldTimeSheetEntrys(){
                        
        
        // find the last editted records
        List <tc9_ti__Time_Sheet_Entry__c> cuttingTs = [Select tc9_ti__EndTime__c, tc9_ti__StartTime__c, tc9_ti__BreakTime__c, tc9_ti__WorkDate__c,tc9_ti__Entry_Type__c,tc9_ti__Time_Sheet__c,tc9_ti__Total_Hours__c, tc9_ti__Time_Sheet__r.tc9_ti__Start_Date__c
                                                From tc9_ti__Time_Sheet_Entry__c 
                                                Where tc9_ti__Edited__c = true And tc9_ti__Time_Sheet__r.tc9_ti__Placement__c =: plc.Id Order by tc9_ti__WorkDate__c DESC limit 1];
        system.debug('cuttingTss '+ cuttingTs);    
        List<tc9_ti__Time_Sheet_Entry__c> createdTse = new List<tc9_ti__Time_Sheet_Entry__c>();    
        // a record is already edited, then delete timesheet entries after that date    
        if (cuttingTs != null && cuttingTs.size() > 0){
            
            Date checkpoint = cuttingTs.get(0).tc9_ti__WorkDate__c;
            // delete all the records after the last modifed records
            List<tc9_ti__Time_Sheet_Entry__c> tseList = [Select Id From tc9_ti__Time_Sheet_Entry__c Where tc9_ti__Time_Sheet__r.tc9_ti__Placement__c =: plc.Id And tc9_ti__WorkDate__c > :checkpoint];
            delete tseList;
            
            Id TimeSid = cuttingTs.get(0).tc9_ti__Time_Sheet__c;
            
            List<tc9_ti__Time_Sheet_Entry__c> listOfThisTimesheet = new List<tc9_ti__Time_Sheet_Entry__c>([Select tc9_ti__EndTime__c, tc9_ti__processed_date__c, tc9_ti__Extended_After_Entry_Processed__c,tc9_ti__StartTime__c, tc9_ti__BreakTime__c, tc9_ti__WorkDate__c,tc9_ti__Entry_Type__c,tc9_ti__Time_Sheet__c,tc9_ti__Total_Hours__c From tc9_ti__Time_Sheet_Entry__c where tc9_ti__Time_Sheet__c =: TimeSid]);
            
            //Map to find duplicate and eradicate
            for(tc9_ti__Time_Sheet_Entry__c tse: listOfThisTimesheet){
                if(mapOfTimeSheettoEntries.containsKey(tse.tc9_ti__Time_Sheet__c))
                    mapOfTimeSheettoEntries.get(tse.tc9_ti__Time_Sheet__c).add(tse);
                else{
                    List<tc9_ti__Time_Sheet_Entry__c> tempList = new List<tc9_ti__Time_Sheet_Entry__c>();
                    tempList.add(tse);
                    mapOfTimeSheettoEntries.put(tse.tc9_ti__Time_Sheet__c,tempList);
                }
                if(tse.tc9_ti__Processed_Date__c != null){
                    tse.tc9_ti__Extended_After_Entry_Processed__c = true;
                }
            }
            update listOfThisTimesheet;
            
            system.debug('mapOfTimeSheettoEntries'+mapOfTimeSheettoEntries);
            
            Date stdt = cuttingTs.get(0).tc9_ti__Time_Sheet__r.tc9_ti__Start_Date__c;
            Set<Date> tsToBeRemoved = new Set<Date>(); 
            for(Date itrStartDate : startDate_Timesheet.keySet()){
                if(itrStartDate < stdt)
                    tsToBeRemoved.add(itrStartDate);
            }
            
            if(!tsToBeRemoved.isEmpty()){
                for(Date itrStartDate : tsToBeRemoved){
                    startDate_Timesheet.remove(itrStartDate);
                }
            }
            
            //create new timesheetentrys for the following days
            if(checkpoint.addDays(1) <= plc.ts2__End_Date__c)
                createdTse = createTimeSheetEntrys(cuttingTs.get(0).tc9_ti__WorkDate__c.addDays(1), plcLastWeekEndDay); 

        }
        else{   // none of the timesheet entry is edited 
            List<tc9_ti__Time_Sheet_Entry__c> tseList = [Select Id, tc9_ti__WorkDate__c From tc9_ti__Time_Sheet_Entry__c Where tc9_ti__Time_Sheet__r.tc9_ti__Placement__c =: plc.Id ];
            delete tseList;            
            //create new timesheetentrys
            createdTse = createTimeSheetEntrys(plc.ts2__Start_Date__c, plc.ts2__End_Date__c);                 
        }
        //deleteEmptyHeaders();
        return createdTse;
     }
     
     /*
        Headers should not exist if there are no children
     */
     public void deleteEmptyHeaders(ts2__Placement__c plc){
        
        List<tc9_ti__Time_Sheet__c> emptyTS = new List<tc9_ti__Time_Sheet__c>();
        //get all the timeSheets for the placements and delete the empty headers
        for(tc9_ti__Time_Sheet__c timeSheet : [SELECT id,
                                                (SELECT id FROM tc9_ti__Time_Sheet_Entries__r) 
                                                FROM tc9_ti__Time_Sheet__c 
                                                WHERE tc9_ti__Placement__c =: plc.Id]){
            if(timeSheet.tc9_ti__Time_Sheet_Entries__r!=null && timeSheet.tc9_ti__Time_Sheet_Entries__r.size()==0)
                    emptyTS.add(timeSheet);                             
        }
        if(!emptyTS.isEmpty())
            delete emptyTS; 
     }  
     
     
     
     public List<tc9_ti__Time_Sheet_Entry__c> createTimeSheetEntrys(Date startDate, Date endDate){
        system.debug('*** ' + startDate + ' --- ' + endDate);
        //get all plcPublicHoliday for the placment 
        plcPublicHoliday    = getPublicHoliday();
        
        //get weekly info
        List <WorkingDayInfo> weeklyInfo = getWeeklyInfo();
        TimesheetGeneration_Weekly tseWobj = new TimesheetGeneration_Weekly(); 
        
        //get given start date's start of week
        Date tsStart = customToStartOfWeek(startDate);
        
        //find difference between sunday and this start date
        Integer difference  = startDate.toStartOfWeek().daysBetween(tsStart);
        if(difference < 0)
            difference      = startDate.addDays(-7).toStartOfWeek().daysBetween(tsStart);
        system.debug('***difference ' + difference);
        
        List<tc9_ti__Time_Sheet_Entry__c> tseToInsert = new List<tc9_ti__Time_Sheet_Entry__c>();
        for(Date tsStartDate : startDate_Timesheet.keySet()){
            //if(tsStartDate >= tsStart){
                DateTime dt = DateTime.newInstance(tsStartDate, Time.newInstance(0, 0, 0, 0));
                String dayOfWeek=dt.format('EEEE');
                //get the week's timesheet header
                tc9_ti__Time_Sheet__c thisWeekTimeSheet = startDate_Timesheet.get(tsStartDate);
                String currencycode = plc.CurrencyISOCode;
                Integer chkcounter = 0;
                for(Integer i = mapOfDays.get(dayOfWeek) ; i < 14; i++){
                    Date entryDate = thisWeekTimeSheet.tc9_ti__Start_Date__c.addDays(chkcounter);    //get the day
                    system.debug('entryDateeee '+entryDate);
                    if(entryDate <= thisWeekTimeSheet.tc9_ti__End_Date__c && entryDate >= startDate && entryDate <= endDate && tseWobj.check4Dupes(entryDate,thisWeekTimeSheet.id, mapOfTimeSheettoEntries)){
                        Integer weekDayNumber = Math.mod(i + difference, 7);    //calculate day number with reference to the custom Start date
                        WorkingDayInfo thisDayInfo = weeklyInfo.get(weekDayNumber); // get the day's info
                        addToList(setupTimeSheetEntry(thisDayInfo.expWorkingHour, thisWeekTimeSheet.id, entryDate, thisDayInfo.ExpectdStart, thisDayInfo.ExpectedEnd,currencycode), tseToInsert);
                    }
                    chkcounter++;
                }
            //}
        }
        
        system.debug(tseToInsert);
        return tseToInsert;
        
     }
     
     
     
     private tc9_ti__Time_Sheet_Entry__c setupTimeSheetEntry(Decimal expWorkingHour, Id tsId, Date workdate, String ExpectdStart, String ExpectedEnd, String currencycode){
        system.debug('**' + ExpectdStart +' - ' + ExpectedEnd);
        //check workdate is a public holiday or not 
        Boolean isPublicHoliday = plcPublicHoliday.contains(workdate);
        
        // if there working hours for the day 
        // and the work day is before placment end, and after placment start date,  
        // and ( the workday is not public holiday or the work day is public holiday and placment requires work in public holiday  
        if ( (expWorkingHour!= null && expWorkingHour > 0) && (workdate <= plc.ts2__End_Date__c )  && workdate >= plc.ts2__Start_Date__c && ( !isPublicHoliday || (isPublicHoliday && plc.tc9_ti__WorkingPublicHolidays__c) )){
                
            system.debug('**' + ExpectdStart +' - ' + ExpectedEnd);
            String [] starttime = ExpectdStart.split(':'); 
            String [] endtime = ExpectedEnd.split(':'); 
            
            DateTime normalStart = DateTime.newInstance( workdate.year(), workdate.month(), workdate.day(), Integer.valueOf(starttime[0]), Integer.valueOf(starttime[1]), 0 );
            DateTime normalEnd = DateTime.newInstance( workdate.year(), workdate.month(), workdate.day(), Integer.valueOf(endtime[0]), Integer.valueOf(endtime[1]), 0 );
            
            if(normalStart > normalEnd)
                normalEnd = normalEnd.addDays(1);
            String methodCreated;
            if(!isScheduledJob)
                methodCreated= NON_BATCH_METHOD;
            else
                methodCreated= BATCH_METHOD;
                
            return new tc9_ti__Time_Sheet_Entry__c( tc9_ti__Time_Sheet__c = tsId, tc9_ti__Hours_Expected__c = expWorkingHour, tc9_ti__ExpectedStart__c = ExpectdStart, 
                                                                                tc9_ti__ExpectedEnd__c = ExpectedEnd, tc9_ti__WorkDate__c = workdate, tc9_ti__NormalStart__c = normalStart,tc9_ti__Method_Created__c=methodCreated, tc9_ti__NormalEnd__c = normalEnd, tc9_ti__IsPublicHoliday__c = isPublicHoliday, CurrencyISOCOde = currencycode );
        }else{
            return null;
        }            
    }

    /**
    * getPublicHoliday(): get public hoildays the placment
    **/
     private Set <Date> getPublicHoliday(){
                
        Set <Date> holidays = new Set<Date>();  // inital a set for a calendar;
        
        //get calender records
        for (tc9_ti__Public_Holiday_Calendar__c cal : listOfPublicHols){
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
        
    private void addToList(tc9_ti__Time_Sheet_Entry__c tse, list<tc9_ti__Time_Sheet_Entry__c> tseList ){
            if (tse != null)
                tseList.add(tse);
    }
     
     /**
    * get a weekly working info
    **/     
    private List <WorkingDayInfo> getWeeklyInfo(){
        
            List <WorkingDayInfo> weeklyInfo = new List <WorkingDayInfo>(); 
            // the weekly info are started from sunday to saturday
            weeklyInfo.add(new WorkingDayInfo(plc.tc9_ti__Hours_Sunday__c, (!sundayRule.isEmpty()? sundayRule.get(0).tc9_ti__Start_Time__c :plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_Start_Time__c), (!sundayRule.isEmpty()? sundayRule.get(0).tc9_ti__End_Time__c :plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_End_Time__c))); 
            weeklyInfo.add(new WorkingDayInfo(plc.tc9_ti__Hours_Monday__c, plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_Start_Time__c,  plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_End_Time__c)); 
            weeklyInfo.add(new WorkingDayInfo(plc.tc9_ti__Hours_Tuesday__c, plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_Start_Time__c, plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_End_Time__c)); 
            weeklyInfo.add(new WorkingDayInfo(plc.tc9_ti__Hours_Wednesday__c, plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_Start_Time__c,  plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_End_Time__c)); 
            weeklyInfo.add(new WorkingDayInfo(plc.tc9_ti__Hours_Thursday__c, plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_Start_Time__c,  plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_End_Time__c)); 
            weeklyInfo.add(new WorkingDayInfo(plc.tc9_ti__Hours_Friday__c, plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_Start_Time__c,  plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_End_Time__c)); 
            weeklyInfo.add(new WorkingDayInfo(plc.tc9_ti__Hours_Saturday__c,(!saturdayRule.isEmpty()? saturdayRule.get(0).tc9_ti__Start_Time__c :plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_Start_Time__c), (!saturdayRule.isEmpty()? saturdayRule.get(0).tc9_ti__End_Time__c :plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_End_Time__c))); 
            
            return  weeklyInfo;
            
    }

    /**
    *   WorkingDayInfo : expected work hours, expted start and expected end
    **/     
    class WorkingDayInfo{
            public Decimal expWorkingHour;
            public String ExpectdStart;
            public String ExpectedEnd;
            
            public WorkingDayInfo (Decimal expWorkingHour, String ExpectdStart, String ExpectedEnd){
                    this.expWorkingHour = expWorkingHour;
                    this.ExpectdStart = ExpectdStart;
                    this.ExpectedEnd = ExpectedEnd;         
            }
    
    }
     
}