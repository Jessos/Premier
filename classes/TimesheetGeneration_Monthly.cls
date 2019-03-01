/*
    Class      : TimesheetGeneration_Monthly
    Test class : 
    Developer  : Jagadeswary.S
    
        
    Change History 
    ******************************************************************************************************************************************************************

         SCRUM        ModifiedBy        Date            Requested By                           Description                                                      Tag
    ******************************************************************************************************************************************************************
       SC-10841      Jagadeswary    23/09/2016        Guy Baxter                            Flag for Timesheet Entries created by standard tcs timesheet generation process
  
  */

public with sharing class TimesheetGeneration_Monthly { 
    private ts2__Placement__c plc ;
    private final integer numsworkingday = 6;
    private Date plcFirstMonthStartDay;
    private Date plcLastMonthEndDay;
    private boolean isAcrossDaysTimings;
    public boolean isFlagged;
    public DateTime startDt;
    public DateTime endDt;
    private List<tc9_ti__Rule__c> saturdayRule = new List<tc9_ti__Rule__c>();
    private List<tc9_ti__Rule__c> sundayRule   = new List<tc9_ti__Rule__c>();
    public tc9_ti__Debug_Header__c dHead;
    private String SATURDAY_RULE = 'Saturday';
    private String SUNDAY_RULE = 'Sunday';
    public Map<Id,String> mapOfPlcAndError = new Map<Id,String>();
    public Map<Id,Id> mapOfTsToPlc = new Map<Id,Id>();
    public boolean isGenericException;   
    public Integer weekStartDay = 1; // default Monday
    public String strWeekDay = 'Monday'; // used to populate in Timesheet
    public String entryType = '';
    Map<Date, tc9_ti__Time_Sheet__c> startDate_Timesheet;   //startDate_timesheet
    //private Map<String, Integer> mapOfDays= new Map<String, Integer>();
    //private Map<String, String> WeekDayMap = new Map<String, String>();
    private String NON_BATCH_METHOD = 'Generate Timesheet button';
    private String BATCH_METHOD = 'Auto Generate Timesheet';
    //Map to find duplicate and eradicate
        
    Map<id, List<tc9_ti__Time_Sheet_Entry__c>> mapOfTimeSheettoEntries;
    
    private Set <Date> plcPublicHoliday = new Set <Date>(); //public holidays of the placement
    
    public String errMsg {get; private set;}
    public String usrLang {get{
        return UserInfo.getLanguage();}}
    public Boolean isScheduledJob;
    
    List<tc9_ti__Time_Sheet__c> existingTS ;
    List<tc9_ti__Public_Holiday_Calendar__c> listOfPublicHols;
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
    
    
    public TimesheetGeneration_Monthly(ts2__Placement__c plc, tc9_ti__Rule__c saturdayRule ,tc9_ti__Rule__c sundayRule, List<tc9_ti__Time_sheet__c> existTS, List<tc9_ti__Public_Holiday_Calendar__c> listOfPublicHolidays, tc9_ti__Debug_Header__c dHead) {
        system.debug('listOfPublicHolsssssss '+listOfPublicHols);
        //placement record
        isGenericException = false;
        system.debug('existingTS1'+existingTS);
        existingTS = new List<tc9_ti__Time_sheet__c>();
        listOfPublicHols = new List<tc9_ti__Public_Holiday_Calendar__c>();
        this.plc = plc;
        if(existTS != null){
            this.existingTS = existTS;
        }
        system.debug('existingTS2'+existingTS);
        if(listOfPublicHolidays != null && !listOfPublicHolidays.isEmpty()){
            this.listOfPublicHols  = listOfPublicHolidays;
        }
        
        if(saturdayRule != null){
            this.saturdayRule.add(saturdayRule); 
        }
        if(sundayRule != null)
            this.sundayRule.add(sundayRule);
        isAcrossDaysTimings = false;
        //Map to clear duplicates
        mapOfTimeSheettoEntries = new Map<id,List<tc9_ti__Time_Sheet_Entry__c>>();
        //see if the related award master has across-days timings
        startDt = getDateTime(Date.today(), plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_Start_Time__c);
        endDt   = getDateTime(Date.today(), plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_End_Time__c);
        if(startDt > endDt)
             isAcrossDaysTimings = true;
        //Create the Custom Setting Instance     
        tc9_ti__ToCloudNineConfig__c custSetting    = tc9_ti__ToCloudNineConfig__c.getInstance();
        //search for week start day in order ==> Job / Client / custom settings
       /* strWeekDay = plc.ts2__Job__r.Week_Start_Day__c;
        
        if(strWeekDay == null)  strWeekDay = plc.ts2__Client__r.Week_Start_Day__c;
        if(strWeekDay == null && custSetting!= null && constantsClass.DAYSOFWEEK.contains(custSetting.Week_Start_Day__c.toUpperCase()))
            strWeekDay=custSetting.Week_Start_Day__c;
                if(strWeekDay == null)  strWeekDay = 'Monday';
        weekStartDay         = UtilClass.getWeekDayNumber(strWeekDay);  //get as number
        */
        //plc Month start date
        plcFirstMonthStartDay= plc.ts2__Start_Date__c.toStartOfMonth();
        
        //plc Month end date
        plcLastMonthEndDay   = plc.ts2__End_Date__c.toStartOfMonth().addMonths(1).addDays(-1);
        //create();
        
       /* WeekDayMap.put('Sunday', 'Monday');
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
        */
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
        system.debug('inhere 0'+existingTS); 
        
        //group timesheet by start date
        for(tc9_ti__Time_Sheet__c ts : existingTS){ 
            system.debug('inhere 1');            
            //mark timesheet for deletion
            if(ts.tc9_ti__Start_Date__c < plcFirstMonthStartDay || ts.tc9_ti__Start_Date__c > plcLastMonthEndDay)
                tsToDelete.add(ts);
            else //add it to map
                startDate_Timesheet.put(ts.tc9_ti__Start_Date__c, ts);
        }
        system.debug('inhere 2'+plcFirstMonthStartDay); 
        system.debug('inhere 3'+plcLastMonthEndDay); 
        
        //create timesheets when needed
        
        for(Date startDate = plcFirstMonthStartDay ; startDate <= plcLastMonthEndDay ; startDate=startDate.addMonths(1)){
            
            if(!startDate_Timesheet.containsKey(startDate) ){
                system.debug('startDate'+startDate);
                tsToInsert.add(new tc9_ti__Time_Sheet__c(tc9_ti__Candidate__c = plc.ts2__Employee__c, tc9_ti__Start_Date__c = startDate, tc9_ti__End_Date__c = startDate.addMonths(1).addDays(-1), tc9_ti__status__c = 'New',tc9_ti__Placement__c = this.plc.Id, tc9_ti__Week_Start_Day__c = strWeekDay, tc9_ti__Generate_Transaction__c = '1', CurrencyISOCode = plc.CurrencyISOCode));
            }
        }           
        
        
        if(!existingTS.isEmpty()){
            existingTS.clear();
        } 
        
        //system.debug('tsToInserttttttt '+tsToInsert);    
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
        
        for(tc9_ti__Time_Sheet__c ts : successfulTs.values()){
             startDate_Timesheet.put(ts.tc9_ti__Start_Date__c, ts);
             mapOfTsToPlc.put(ts.Id,ts.tc9_ti__Placement__c);
        }
        
     }    
     
     /**
     * updateOldTimeSheetEntrys(): delete old timesheetentry that have not be edited and create new timesheetentry
     *
     **/     
     public List<tc9_ti__Time_Sheet_Entry__c> updateOldTimeSheetEntrys(){
                        
        
        List <tc9_ti__Time_Sheet_Entry__c> cuttingTs = [Select tc9_ti__EndTime__c, tc9_ti__StartTime__c, tc9_ti__BreakTime__c, tc9_ti__WorkDate__c,tc9_ti__Entry_Type__c,tc9_ti__Time_Sheet__c,tc9_ti__Total_Hours__c, tc9_ti__Time_Sheet__r.tc9_ti__Start_Date__c From tc9_ti__Time_Sheet_Entry__c 
                                                                Where tc9_ti__Edited__c = true And 
                                                                tc9_ti__Time_Sheet__r.tc9_ti__Placement__c =: plc.Id Order by tc9_ti__WorkDate__c DESC limit 1];
        system.debug('cuttingTss '+ cuttingTs);        
        // a record is already edited, then delete timesheet entries after that date    
        List<tc9_ti__Time_Sheet_Entry__c> createdTse = new List<tc9_ti__Time_Sheet_Entry__c>();
        if (cuttingTs != null && cuttingTs.size() > 0){
            
            Date checkpoint = cuttingTs.get(0).tc9_ti__WorkDate__c;
            // delete all the records after the last modifed records
            List<tc9_ti__Time_Sheet_Entry__c> tseList = [Select Id From tc9_ti__Time_Sheet_Entry__c Where tc9_ti__Time_Sheet__r.tc9_ti__Placement__c =: plc.Id And tc9_ti__WorkDate__c > :checkpoint];
            delete tseList;
            
            Id TimeSid = cuttingTs.get(0).tc9_ti__Time_Sheet__c;
            
            List<tc9_ti__Time_Sheet_Entry__c> listOfThisTimesheet = new List<tc9_ti__Time_Sheet_Entry__c>([Select tc9_ti__EndTime__c, tc9_ti__StartTime__c,tc9_ti__processed_date__c, tc9_ti__Extended_After_Entry_Processed__c,tc9_ti__BreakTime__c, tc9_ti__WorkDate__c,tc9_ti__Entry_Type__c,tc9_ti__Time_Sheet__c,tc9_ti__Total_Hours__c From tc9_ti__Time_Sheet_Entry__c where tc9_ti__Time_Sheet__c =: TimeSid]);
            
            //Map to find duplicate and eradicate
            for(tc9_ti__Time_Sheet_Entry__c tse: listOfThisTimesheet){
                if(mapOfTimeSheettoEntries.containsKey(tse.tc9_ti__Time_Sheet__c))
                    mapOfTimeSheettoEntries.get(tse.tc9_ti__Time_Sheet__c).add(tse);
                else{
                    mapOfTimeSheettoEntries.put(tse.tc9_ti__Time_Sheet__c,new List<tc9_ti__Time_Sheet_Entry__c>{tse});
                }
                
                if(tse.tc9_ti__Processed_Date__c != null){
                    tse.tc9_ti__Extended_After_Entry_Processed__c = true; //SC-9155
                }
            }
            System.debug('!@#$%^&*()'+mapOfTimeSheettoEntries);
            update listOfThisTimesheet;
            
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
                createdTse = createTimeSheetEntrys(cuttingTs.get(0).tc9_ti__WorkDate__c.addDays(1), plcLastMonthEndDay); 

         }
        else {   // none of the timesheet entry is edited 
                List<tc9_ti__Time_Sheet_Entry__c> tseList = [Select Id, tc9_ti__WorkDate__c From tc9_ti__Time_Sheet_Entry__c Where tc9_ti__Time_Sheet__r.tc9_ti__Placement__c =: plc.Id ];
                delete tseList;
                
                //create new timesheetentrys
                createdTse = createTimeSheetEntrys(plc.ts2__Start_Date__c, plc.ts2__End_Date__c); 
                system.debug('PLCCC '+ plc);  
                system.debug('createdTse '+ createdTse);                     
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
        
        
        system.debug('startDate_Timesheet  '+startDate_Timesheet);
        
        List<tc9_ti__Time_Sheet_Entry__c> tseToInsert = new List<tc9_ti__Time_Sheet_Entry__c>();
        for(Date itrStartDate : startDate_Timesheet.keySet()){          
            //if(itrStartDate >= tsStartDate) {

                DateTime dt = DateTime.newInstance(itrStartDate, Time.newInstance(0, 0, 0, 0));
                String dayOfWeek=dt.format('EEEE');             

                //get the week's timesheet header
                tc9_ti__Time_Sheet__c thisMonthTimeSheet = startDate_Timesheet.get(itrStartDate);
                String currencycode = plc.CurrencyISOCode;
                Integer chkcounter = 0;

                for(Date iterdate = itrStartDate ; iterdate < itrStartDate.addMonths(1); iterdate=iterdate.addDays(1)){
                    system.debug('iterdate'+iterdate+'-'+chkcounter+'--'+thisMonthTimeSheet.tc9_ti__Start_Date__c);
                    Date entryDate = thisMonthTimeSheet.tc9_ti__Start_Date__c.addDays(chkcounter);    //get the day                
                    if(entryDate <= thisMonthTimeSheet.tc9_ti__End_Date__c && entryDate >= plc.ts2__Start_Date__c && entryDate <= plc.ts2__End_Date__c && check4Dupes(entryDate,thisMonthTimeSheet.id, mapOfTimeSheettoEntries)){
                        system.debug('entryDate'+entryDate);
                        Integer weekDayNumber= entryDate.toStartOfWeek().daysBetween(entryDate);
                        WorkingDayInfo thisDayInfo = weeklyInfo.get(weekDayNumber); // get the day's info
                        addToList(setupTimeSheetEntry(thisDayInfo.expWorkingHour, thisMonthTimeSheet, entryDate, thisDayInfo.ExpectdStart, thisDayInfo.ExpectedEnd,currencycode), tseToInsert);
                    }                   
                    chkcounter++;
                }               
            //}            

        }
        
        system.debug(tseToInsert);
        return tseToInsert;
        
     }
     // to check if the dupes are present if so dont create another timesheet.
     public boolean check4Dupes(Date entryDate, Id TSid, Map<id, List<tc9_ti__Time_Sheet_Entry__c>> mapOfTStoEntries){
        
        if(mapOfTStoEntries.containsKey(TSid)){
            List<tc9_ti__Time_Sheet_Entry__c> tseListForDupes = mapOfTStoEntries.get(TSid);
            for(tc9_ti__Time_Sheet_Entry__c tse: tseListForDupes){
                system.debug('entrrrry '+entryDate + 'workkk '+tse.tc9_ti__WorkDate__c);
                if(tse.tc9_ti__WorkDate__c == entryDate)
                    return false;
            }
        }
        return true;
     }
     
     private tc9_ti__Time_Sheet_Entry__c setupTimeSheetEntry(Decimal expWorkingHour, tc9_ti__Time_Sheet__c ts, Date workdate, String ExpectdStart, String ExpectedEnd,String currencycode ){
        system.debug('**ExpectdStart' + ExpectdStart +' \n - ExpectedEnd ' + ExpectedEnd);
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
            
            return new tc9_ti__Time_Sheet_Entry__c( tc9_ti__Time_Sheet__c = ts.Id, tc9_ti__Hours_Expected__c = expWorkingHour, tc9_ti__ExpectedStart__c = ExpectdStart, 
                                                                                tc9_ti__ExpectedEnd__c = ExpectedEnd, tc9_ti__WorkDate__c = workdate, tc9_ti__NormalStart__c = normalStart,tc9_ti__method_Created__c=methodCreated, tc9_ti__NormalEnd__c = normalEnd, tc9_ti__IsPublicHoliday__c = isPublicHoliday, CurrencyISOCode = currencycode);
        }else{
            return null;
        }                   
    }

    /**
    * getPublicHoliday(): get public hoildays the placment
    **/
     private Set <Date> getPublicHoliday(){
                
        Set <Date> holidays = new Set<Date>();  // inital a set for a calendar;
        system.debug('listOfPublicHolsssssss '+listOfPublicHols);
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
            system.debug('plc.Award_Master__r.Standard_Daily_End_Time__cccc  '+plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_End_Time__c);
            List <WorkingDayInfo> weeklyInfo = new List <WorkingDayInfo>(); 
            // the weekly info are started from sunday to saturday
            weeklyInfo.add(new WorkingDayInfo(plc.tc9_ti__Hours_Sunday__c, ((!sundayRule.isEmpty() && sundayRule!= null )? sundayRule.get(0).tc9_ti__Start_Time__c :plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_Start_Time__c), ((!sundayRule.isEmpty() && sundayRule!= null )? sundayRule.get(0).tc9_ti__End_Time__c :plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_End_Time__c))); 
            weeklyInfo.add(new WorkingDayInfo(plc.tc9_ti__Hours_Monday__c, plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_Start_Time__c,  plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_End_Time__c)); 
            weeklyInfo.add(new WorkingDayInfo(plc.tc9_ti__Hours_Tuesday__c, plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_Start_Time__c, plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_End_Time__c)); 
            weeklyInfo.add(new WorkingDayInfo(plc.tc9_ti__Hours_Wednesday__c, plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_Start_Time__c,  plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_End_Time__c)); 
            weeklyInfo.add(new WorkingDayInfo(plc.tc9_ti__Hours_Thursday__c, plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_Start_Time__c,  plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_End_Time__c)); 
            weeklyInfo.add(new WorkingDayInfo(plc.tc9_ti__Hours_Friday__c, plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_Start_Time__c,  plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_End_Time__c)); 
            weeklyInfo.add(new WorkingDayInfo(plc.tc9_ti__Hours_Saturday__c,((!saturdayRule.isEmpty() && saturdayRule != null )? saturdayRule.get(0).tc9_ti__Start_Time__c :plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_Start_Time__c), ((!saturdayRule.isEmpty() && saturdayRule != null )? saturdayRule.get(0).tc9_ti__End_Time__c :plc.tc9_ti__Award_Master__r.tc9_ti__Standard_Daily_End_Time__c))); 
            
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