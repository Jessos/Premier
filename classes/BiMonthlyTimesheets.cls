/*
    
     Change History 
    ******************************************************************************************************************************************************************
         SCRUM        ModifiedBy        Date            Requested By                           Description                                                      Tag
    ******************************************************************************************************************************************************************
        SC-7045         Srinidhi.R      10/12/2015      David Levy                  TImesheet Entries Currency should be the same as TImesheet
       SC-10841      Jagadeswary    23/09/2016        Guy Baxter                            Flag for Timesheet Entries created by standard tcs timesheet generation process

*/
public with sharing class BiMonthlyTimesheets {
    
    private ts2__Placement__c plc ;
    public Date firstDayOfMonth ;
    public Date lastDayOfMonth ; 
    public String strWeekDay = '';
    public Integer weekStartDay = 1; // default Monday
    private List<tc9_ti__Rule__c> saturdayRule = new List<tc9_ti__Rule__c>();
    private List<tc9_ti__Rule__c> sundayRule   = new List<tc9_ti__Rule__c>();
    private boolean isAcrossDaysTimings;
    private String SATURDAY_RULE = 'Saturday';
    private String SUNDAY_RULE = 'Sunday';
    private String NON_BATCH_METHOD = 'Generate Timesheet button';
    private String BATCH_METHOD = 'Auto Generate Timesheet';
    public Boolean isScheduledJob;
    
    private Map<String, Integer> mapOfDays= new Map<String, Integer>();
    public Map<Id,String> mapOfPlcAndError = new Map<Id,String>();
    public Map<Id,Id> mapOfTsToPlc = new Map<Id,Id>();
    public boolean isGenericException;
    //Map to find duplicate and eradicate 
    Map<id, List<tc9_ti__Time_Sheet_Entry__c>> mapOfTimeSheettoEntries;
    public DateTime startDt;
    public DateTime endDt;
    List<tc9_ti__Time_Sheet__c> existingTS ;
    List<tc9_ti__Public_Holiday_Calendar__c> listOfPublicHols;
    Map<Date, tc9_ti__Time_Sheet__c> startDate_Timesheet;  
    private Set <Date> plcPublicHoliday = new Set <Date>(); //public holidays of the placement
    public tc9_ti__Debug_Header__c dHead;
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
    
    public BiMonthlyTimesheets(ts2__Placement__c plc, tc9_ti__Rule__c saturdayRule ,tc9_ti__Rule__c sundayRule, List<tc9_ti__Time_sheet__c> existTS, List<tc9_ti__Public_Holiday_Calendar__c> listOfPublicHolidays, tc9_ti__Debug_Header__c dHead){
        mapOfDays.put('Sunday', 6);
        mapOfDays.put('Monday', 0);
        mapOfDays.put('Tuesday', 1);
        mapOfDays.put('Wednesday',2);
        mapOfDays.put('Thursday', 3);
        mapOfDays.put('Friday', 4);
        mapOfDays.put('Saturday', 5);
        
        this.plc = plc;
        isGenericException = false;
        system.debug('existingTS1'+existingTS);
        existingTS = new List<tc9_ti__Time_sheet__c>();
        listOfPublicHols = new List<tc9_ti__Public_Holiday_Calendar__c>();
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
             
        
        //To get the first day of the month
        firstDayOfMonth = plc.ts2__Start_Date__c.toStartOfMonth();
        system.debug('firssssttttt '+firstDayOfMonth);
        
        //To get the last day of the month
        Integer numberOfDays = Date.daysInMonth(plc.ts2__End_Date__c.year(), plc.ts2__End_Date__c.month());
        lastDayOfMonth = Date.newInstance(plc.ts2__End_Date__c.year(), plc.ts2__End_Date__c.month(), numberOfDays);
        system.debug('lasssssttttt '+lastDayOfMonth);
        
        //List<Time_Sheet__c> existingTS = [SELECT id, Start_Date__c, End_Date__c,Status__c,Flagged__c FROM Time_Sheet__c where Placement__c =: plc.Id];
        List<tc9_ti__Time_Sheet__c> tsToInsert      = new List<tc9_ti__Time_Sheet__c>();
        List<tc9_ti__Time_Sheet__c> tsToDelete      = new List<tc9_ti__Time_Sheet__c>();
        
        //clear map
        startDate_Timesheet = new Map<Date, tc9_ti__Time_Sheet__c>();
        
        strWeekDay = plc.ts2__Job__r.tc9_ti__Week_Start_Day__c;
        
        //group timesheet by start date
        for(tc9_ti__Time_Sheet__c ts : existingTS){
            //mark timesheet for deletion
            if(ts.tc9_ti__Start_Date__c < firstDayOfMonth || ts.tc9_ti__Start_Date__c > lastDayOfMonth)
                tsToDelete.add(ts);
            else //add it to map
                startDate_Timesheet.put(ts.tc9_ti__Start_Date__c, ts);
         }
        //creating Timesheets
        Date tsStartDate = firstDayOfMonth;
        Date tsEndDate ;
        for(; tsStartDate <= plc.ts2__End_Date__c ;){
            
            if (tsStartDate.day()==1){
                    tsEndDate = tsStartDate.addDays(14);
                }
                else {
                    tsEndDate = tsStartDate.addMonths(1).toStartOfMonth()-1;
                }
            if(!startDate_Timesheet.containsKey(tsStartDate) )
            {
                tsToInsert.add(new tc9_ti__Time_Sheet__c( tc9_ti__Candidate__c = plc.ts2__Employee__c, tc9_ti__Start_Date__c = tsStartDate, tc9_ti__End_Date__c = tsEndDate, tc9_ti__status__c = 'New',tc9_ti__Placement__c = plc.Id, tc9_ti__Week_Start_Day__c = strWeekDay,tc9_ti__Generate_Transaction__c = '1', CurrencyISOCode = plc.CurrencyISOCode));
                
            }
            tsStartDate = tsEndDate+1;
                
        }
        system.debug('tsToInserttt '+tsToInsert);
        if(!existingTS.isEmpty()){

            existingTS.clear();
        }
        
        List<tc9_ti__Time_Sheet__c> successfulTs = new List<tc9_ti__Time_Sheet__c>(); 
        if(!tsToInsert.isEmpty()){
            Database.SaveResult[] srList = Database.insert(tsToInsert,false);     
            for(Integer i=0;i<srList.size();i++){
                if(srList.get(i).isSuccess()){
                    successfulTs.add(tsToInsert.get(i));
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

          
        system.debug('successfulTsssss '+successfulTs);
        //add it to map
        for(tc9_ti__Time_Sheet__c ts : successfulTs){
             startDate_Timesheet.put(ts.tc9_ti__Start_Date__c, ts);
             mapOfTsToPlc.put(ts.Id,ts.tc9_ti__Placement__c);
        }
        
    }
    
    public List<tc9_ti__Time_Sheet_Entry__c> createTimeSheetEntrys(Date startDate, Date endDate){
        //get all plcPublicHoliday for the placment 
        plcPublicHoliday    = getPublicHoliday();
        
        //get weekly info
        List <WorkingDayInfo> weeklyInfo = getWeeklyInfo();
        
        system.debug('******weeklyInfo '+weeklyInfo);
        
        //get given start date's start of week
        Date tsStartDate = customToStartOfWeek(startDate);
        system.debug('*** ' + tsStartDate);
        system.debug('startDate '+startDate);
        system.debug('startDate.toStartOfWeek() '+ startDate.toStartOfWeek());
        system.debug('startDate '+startDate.addDays(-7));
        system.debug('startDate.toStartOfWeek() '+ startDate.addDays(-7).toStartOfWeek());
        //find difference between sunday and this start date
        Integer difference  = startDate.toStartOfWeek().daysBetween(tsStartDate);
        system.debug('*** ' + difference);
        if(difference < 0)
            difference      = startDate.addDays(-7).toStartOfWeek().daysBetween(tsStartDate);
        system.debug('*** ' + difference);
        
        Date tsStart = firstDayOfMonth;
        Date tsEnd = lastDayOfMonth;
        
        List<tc9_ti__Time_Sheet_Entry__c> tseToInsert = new List<tc9_ti__Time_Sheet_Entry__c>();
        TimesheetGeneration_Weekly tseWobj = new TimesheetGeneration_Weekly(); 
        for(; tsStart <= endDate; ){
            DateTime dt = DateTime.newInstance(tsStart, Time.newInstance(0, 0, 0, 0));
            String dayOfWeek=dt.format('EEEE');
            System.debug('dayOfWeek'+dayOfWeek);
            if (tsStart.day()==1){
                    tsEnd = tsStart.addDays(14);
            }
            else {
                tsEnd = tsStart.addMonths(1).toStartOfMonth()-1; 
            }
           
            //get the week's timesheet header
            tc9_ti__Time_Sheet__c thisWeekTimeSheet = new tc9_ti__Time_Sheet__c ();
            if(startDate_Timesheet.containsKey(tsStart)){
                thisWeekTimeSheet = startDate_Timesheet.get(tsStart);
            }
            String currencycode = plc.CurrencyISOCode;        
            Integer i=mapOfDays.get(dayOfWeek);
            if(thisWeekTimeSheet!=null){
                for(Date entryDate = tsStart; entryDate <= tsEnd; entryDate = entryDate.addDays(1)){
                
                    system.debug('*** eee' + entryDate);   //get the day
                    if(entryDate >= startDate && entryDate <= endDate && tseWobj.check4Dupes(entryDate,thisWeekTimeSheet.id, mapOfTimeSheettoEntries)){
                        Integer weekDayNumber = Math.mod(i + difference, 7);    //calculate day number with reference to the custom Start date
                        WorkingDayInfo thisDayInfo = weeklyInfo.get(weekDayNumber); // get the day's info
                        addToList(setupTimeSheetEntry(thisDayInfo.expWorkingHour, thisWeekTimeSheet.id, entryDate, thisDayInfo.ExpectdStart, thisDayInfo.ExpectedEnd,currencycode), tseToInsert);
                    }
                i++;
                }
                tsStart = tsEnd+1;
            }
        }
        
            system.debug('entrieeeeees '+tseToInsert);
            return tseToInsert;
        
        
    }
    
    public ts2__Placement__c updatePlacementStatus(){
        plc.tc9_ti__Is_timesheet_created__c = true;
        plc.tc9_ti__Last_Timesheet_Creation_Date__c = DateTime.now();
        return plc;
        

    }
    
    /**
     * updateOldTimeSheetEntrys(): delete old timesheetentry that have not be edited and create new timesheetentry
     *
     **/     
     public List<tc9_ti__Time_Sheet_Entry__c> updateOldTimeSheetEntrys(){
         system.debug('insideeeeee ');       
        // find the last editted records
        List <tc9_ti__Time_Sheet_Entry__c> cuttingTs = [Select tc9_ti__EndTime__c, tc9_ti__StartTime__C, tc9_ti__BreakTime__c, tc9_ti__WorkDate__c,tc9_ti__Entry_Type__c,tc9_ti__Total_Hours__c,tc9_ti__Time_Sheet__c From tc9_ti__Time_Sheet_Entry__c 
                                                                Where tc9_ti__Edited__c = true And 
                                                                tc9_ti__Time_Sheet__r.tc9_ti__Placement__c =: plc.Id Order by tc9_ti__WorkDate__c DESC limit 1];
         List<tc9_ti__Time_Sheet_Entry__c> createdTse = new List<tc9_ti__Time_Sheet_Entry__c>();           
        // a record is already edited, then delete timesheet entries after that date    
        if (cuttingTs != null && cuttingTs.size() > 0){
            
            Date checkpoint = cuttingTs.get(0).tc9_ti__WorkDate__c;
            // delete all the records after the last modifed records
            List<tc9_ti__Time_Sheet_Entry__c> tseList = [Select Id From tc9_ti__Time_Sheet_Entry__c Where tc9_ti__Time_Sheet__r.tc9_ti__Placement__c =: plc.Id And tc9_ti__WorkDate__c > :checkpoint];
            delete tseList;
            ///Map to find duplicate and eradicate
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
            System.debug('!@#$%^&*()'+mapOfTimeSheettoEntries);
            update listOfThisTimesheet;
            
            //create new timesheetentrys for the following days
            if(checkpoint.addDays(1) <= plc.ts2__End_Date__c)
               createdTse =createTimeSheetEntrys(cuttingTs.get(0).tc9_ti__WorkDate__c.addDays(1), plc.ts2__End_Date__c); 

         }
        else {   // none of the timesheet entry is edited 
                List<tc9_ti__Time_Sheet_Entry__c> tseList = [Select Id, tc9_ti__WorkDate__c From tc9_ti__Time_Sheet_Entry__c Where tc9_ti__Time_Sheet__r.tc9_ti__Placement__c =: plc.Id ];
                delete tseList;
                
                //create new timesheetentrys
                createdTse =createTimeSheetEntrys(plc.ts2__Start_Date__c, plc.ts2__End_Date__c);                 
        }
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
     private tc9_ti__Time_Sheet_Entry__c setupTimeSheetEntry(Decimal expWorkingHour, Id tsId, Date workdate, String ExpectdStart, String ExpectedEnd, String currencycode){
        system.debug('**' + ExpectdStart +' - ' + ExpectedEnd);
        system.debug('!!!' + expWorkingHour +' - ' + tsId);
        system.debug('###' + workdate +' - ' + tsId);
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
                                                                                tc9_ti__ExpectedEnd__c = ExpectedEnd, tc9_ti__WorkDate__c = workdate,tc9_ti__Method_Created__c=methodCreated, tc9_ti__NormalStart__c = normalStart, tc9_ti__NormalEnd__c = normalEnd, tc9_ti__IsPublicHoliday__c = isPublicHoliday, CurrencyISOCode = currencycode );
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
                    system.debug('tssssss '+ tse +'tseeeeeeee '+ tseList);
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