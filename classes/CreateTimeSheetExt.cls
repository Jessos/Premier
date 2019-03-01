/**
* CreateTimeSheetExt: create time sheet and time sheet entry for a selected placement. 
* If there is not any time sheet and time sheet entry created for the placment, 
* then time sheet and related time sheet entry are created.
* If there is time sheet and time sheet entry created for the placement, the code will 
*       (1) delete all the time sheet entry after the last edited time sheet entry, 
*       (2) create new time sheet entry for based the placment 
*
* Author: Ying Liu
//////////////////////////////////////////////////////////////
*   Name                        |Date           |Scrum/CI
    Ying Liu                    |06/Apr/2012    |SC-0576
    Dharshni                    |01/Jan/2014    |SC-2653 - Changed the entire class
*   Vignesh@2CN                 |20/Feb/2014    |SC-2653
//////////////////////////////////////////////////////////////

  Change History 
    
    ********************************************************************************************************************************************************************
        SCRUM        ModifiedBy       Date            Requested By                                       Description                                                Tag
    ********************************************************************************************************************************************************************
       SC-8924       Srinidhi.R     20/08/2015        Michelle Cole                         Placement setting to not create portal user                             <T1>
       Sc-7045       Srinidhi.R     10/12/2015        David Levy                            TImesheet Entries Currency should be the same as TImesheet
       Sc-10137      Srinidhi.R     31/12/2015        David Levy                            Licence Limit impacts Batch_GenerateTimesheet
       Sc-10138      Srinidhi.R     04/01/2015        David Levy                            Licence Limit impacts Generate TImesheets using placement
       Sc-10191      Srinidhi.R     08/01/2016        David Levy
       SC-11234      Jagadeswary    03/07/2016        Michelle Cole                         Creation of monthly Timesheet
       SC-11478      Srinidhi.R     05/07/2016        Benoit Legalant                       New Award Interpreter and legacy data
       SC-10841      Jagadeswary    23/09/2016        Guy Baxter                            Flag for Timesheet Entries created by standard tcs timesheet generation process
       SC-11788      Jagadeswary    06/06/2017        David Levy                            Consistency when reporting debug link on ProcessIvoice VF page
       SC-14893      Jagadeswary    20/06/2017        David Levy                            Need validation rule to prevent End Date on Placement being earlier than Start Date
       SC-17279      Ieswarya J     27/09/2017        Michelle Cole                         Transactions from Rate Calculator-Updating In Code Validations to check Rate Calculator instead of Base pay and bill rate
*/ 

public with sharing class CreateTimeSheetExt {  
    
    private ts2__Placement__c plc ;
    private final integer numsworkingday = 6;
    private Date plcFirstWeekStartDay;
    private Date plcLastWeekEndDay;
    private boolean isAcrossDaysTimings;
    public boolean isFlagged;
    public boolean isBatch;
    private List<tc9_ti__Rule__c> saturdayRule = new List<tc9_ti__Rule__c>();
    private List<tc9_ti__Rule__c> sundayRule   = new List<tc9_ti__Rule__c>();
    
    private String SATURDAY_RULE = 'Saturday';
    private String SUNDAY_RULE = 'Sunday';
    
    public Integer weekStartDay = 1; // default Monday
    public String strWeekDay = 'Monday'; // used to populate in Timesheet
    public String entryType = '';
    Map<Date, tc9_ti__Time_Sheet__c> startDate_Timesheet;   //startDate_timesheet
    
    private Set <Date> plcPublicHoliday = new Set <Date>(); //public holidays of the placement
    public List<ts2__Placement__c> listOfPlacements = new List<ts2__Placement__c>();
    public String errMsg {get; private set;}
    public String usrLang {get{
        return UserInfo.getLanguage();}}
    List<tc9_ti__Debug_Log__c> listOfDebugs;
    map<String, set<Id>> mapOfErrorAndIDs = new map<String, set<Id>>();
    set<Id> setOfPlcToBeUpdated = new set<Id>();
    List<ts2__Placement__c> setOfPlcToBeProcessed;
    public List<tc9_ti__Time_Sheet_Entry__c> timesheetEntriesToBeinserted ;
    public List<ts2__Placement__c> PlcToBeUpdated;
    public tc9_ti__Debug_Header__c dHead;
    public Map<Id,String> mapOfPlcAndError = new Map<Id,String>();
    public Map<Id,Id> mapOfTsToPlc = new Map<Id,Id>();
    tc9_ti__ToCloudNineConfig__c custSetting    = tc9_ti__ToCloudNineConfig__c.getInstance();
    public boolean isGenericException;
    private static DateTime getDateTime(Date dat, String time1){
        String[] theTime =  time1.split(':'); 
        DateTime dt = DateTime.newInstance( dat.year(), dat.month(), dat.day(), Integer.valueOf(theTime[0]), Integer.valueOf(theTime[1]), 0);
        return dt;
    }
    
    public CreateTimeSheetExt(ApexPages.StandardController stdController) {
        
        //placement record
        this.plc = (ts2__Placement__c)stdController.getRecord();
        //System.debug('***currency:'+this.plc.CurrencyISOCode);
        System.debug('***currency:'+this.plc.tc9_ti__Exclude_from_Auto_Timesheet_Creation__c);
        listOfPlacements.add(this.plc);
        isBatch = false;
        dHead = new tc9_ti__Debug_Header__c();
        isGenericException = false;
    timesheetEntriesToBeinserted = new List<tc9_ti__Time_Sheet_Entry__c>();
        PlcToBeUpdated = new List<ts2__Placement__c>();
    }  
    
    public CreateTimeSheetExt(List<ts2__Placement__c> listOfPlcs, tc9_ti__Debug_Header__c dHead) {
        
        //placement record
        //this.plc = (ts2__Placement__c)stdController.getRecord();
        system.debug('Plccccccc '+listOfPlcs + 'Lisssssst '+ this.listOfPlacements);
        this.listOfPlacements = listOfPlcs;
        setOfPlcToBeProcessed = new List<ts2__Placement__c>();
        isBatch = true;
        this.dHead = dHead;
        isGenericException = false;
    } 
     /**
    * validate the required fields
    **/
    
    public Map<Id,String> validateRequiredFields(List<ts2__Placement__c> listOfPlcs){
        
           Map<Id,String> PlacementToValidation = new Map<Id,String>(); 
           
            for(ts2__Placement__c pl:listOfPlcs){
                String errMsg = '';
                if (pl.ts2__Employee__c == null){
                        errMsg += ' ' + ts2__Placement__c.ts2__Employee__c.getDescribe().getLabel() + ',';
                }
                if (pl.tc9_ti__Award_Master__c == null){
                        errMsg += ' ' + ts2__Placement__c.tc9_ti__Award_Master__c.getDescribe().getLabel() + ',';
                }
                if (pl.ts2__Start_Date__c == null){
                        errMsg += ' '+ ts2__Placement__c.ts2__Start_Date__c.getDescribe().getLabel() + ',';
                }
                if (pl.ts2__End_Date__c == null){
                        errMsg += ' '+ ts2__Placement__c.ts2__End_Date__c.getDescribe().getLabel() + ',';
                }
                if (pl.tc9_ti__Market__c == null){
                        errMsg += ' '+ ts2__Placement__c.tc9_ti__Market__c.getDescribe().getLabel() + ',';
                }
              if(custSetting.Enable_Rate_Calculator__c == false){
                if(pl.tc9_ti__Base_Bill_Rate__c == null){
                    errMsg += ' '+ ts2__Placement__c.tc9_ti__Base_Bill_Rate__c.getDescribe().getLabel() + ',';
                }
                if(pl.tc9_ti__Base_Pay_Rate__c == null){
                    errMsg += ' '+ ts2__Placement__c.tc9_ti__Base_Pay_Rate__c.getDescribe().getLabel() + ',';
                }
              }
               else{                
                 if(pl.tc9_ti__Rate_Calculator__c == null){
                    errMsg += ' '+ ts2__Placement__c.tc9_ti__Rate_Calculator__c.getDescribe().getLabel() + ',';                    
                  }
                }
                if (errMsg.length() > 1){
                    errMsg = errMsg.substring(0, errMsg.length()-1) + ' '+Label.NullErrorMsg;
                } 
                
                if(errMsg!='')
                    PlacementToValidation.put(pl.Id,errMsg);
            }
            return PlacementToValidation;
    }
     
     public PageReference create(){
        savepoint sp = Database.setSavepoint();
        try{
            ConstantsClass.Is_New_Award_Interpreter_Flag = false;
            System.debug('@@@In create');
            set<ts2__Placement__c> setOfNonUserPlcs = new set<ts2__Placement__c>();         
            
           
            String namespace = custSetting.tc9_ti__Namespace__c;
            if(namespace != null ){  
                namespace = 'tc9_ti';
            }  
            if(!listOfPlacements[0].tc9_ti__Exclude_from_Auto_Timesheet_Creation__c && !isBatch){
                List<AsyncApexJob> GenerateTimesheetJob = new List<AsyncApexJob>([Select Id, ApexClassId from AsyncApexJob where ApexClass.Name = 'Batch_GenerateTimesheets' AND JobType = 'BatchApex' AND ApexClass.Namespaceprefix =: namespace and (Status = 'Processing' OR Status = 'Preparing' OR Status = 'Queued' OR Status = 'Holding')]);//Check if there is a Batch_GenerteTiemsheets job already running
                if(!GenerateTimesheetJob.isEmpty()){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'There is already a batch job in progress to create the Timesheets. Please try after sometime.'));
                    return null;
                }
            }
            system.debug('Creatinggggg-1 ');
            if(!isBatch){
                String returnMsg =WS_InviteTalent.sendInviteToTalent(plc.Id);
                if(returnMsg.contains('ERROR')){
                    returnMsg = returnMsg.replace('ERROR','Portal User Creation : ');
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,returnMsg));
                    return null;
                }
                errMsg = '';
                Map<Id,String> returnMap = validateRequiredFields(new List<ts2__Placement__c>{plc});
                if(!returnMap.isEmpty())
                    errMsg = returnMap.get(plc.id);
                if (errMsg.length() >  0){
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,errMsg));
                    return null; 
                }
                if(plc.ts2__Start_Date__c>plc.ts2__End_Date__c){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'The Start Date of the Placement must be equal to or earlier than the Placement\'s End Date.'));
                    return null; 
                }
            }
            else{
                Map<Id,ts2__Placement__c> mapOfContactAndPlc = new Map<Id,ts2__Placement__c>();
                List<ts2__Placement__c> eligiblePlcForUserCreation = new List<ts2__Placement__c>();
                set<Id> userEnabledContIds = new set<Id>();
                set<Id> validOwner = new set<Id>();
                set<Id> setOfOwnerIds = new set<Id>();
                List<String> validProfiles = new List<String>();
                
                //Sc 8924 - Inclusion of the Does_Not_Use_Online_Timesheets__c check before creating a new Portal user
                for(ts2__Placement__c plc : listOfPlacements){
                    if(custSetting!= null && custSetting.tc9_ti__Auto_Create_Portal_User__c && (!plc.tc9_ti__Does_Not_Use_Online_Timesheets__c)){  
                        mapOfContactAndPlc.put(plc.ts2__Employee__c, plc);
                        if(plc.ts2__Employee__r.Account.OwnerId != null)
                            setOfOwnerIds.add(plc.ts2__Employee__r.Account.OwnerId);
                        if(plc.ts2__Job__r.tc9_ti__Site__r.tc9_ti__Portal_Profile_Name__c != null)  
                            validProfiles.add(plc.ts2__Job__r.tc9_ti__Site__r.tc9_ti__Portal_Profile_Name__c );
                    } 
                    else
                        setOfNonUserPlcs.add(plc);
                   
                }
                System.debug('@@@In setOfOwnerIds'+setOfOwnerIds);
                System.debug('@@@In validProfiles'+validProfiles);
                //check if the contact is a portal user
                for( User u:  [SELECT id,contactId,email,username FROM User WHERE contactId in:mapOfContactAndPlc.keySet()]){
                    userEnabledContIds.add(u.contactId);
                }
                System.debug('@@@In userEnabledContIds'+userEnabledContIds);
                for( User u : [select Id, UserRoleId from User where Id in: setOfOwnerIds AND UserRoleId != null]){
                    validOwner.add(u.Id);
                }
                System.debug('@@@In validOwner'+validOwner);
                for(ts2__Placement__c plc : mapOfContactAndPlc.values()){
                    if(validOwner.contains(plc.ts2__Employee__r.Account.OwnerId)){
                        if(!userEnabledContIds.contains(plc.ts2__Employee__c)){
                            eligiblePlcForUserCreation.add(mapOfContactAndPlc.get(plc.ts2__Employee__c));
                        }
                    }
                    else {
                        if(mapOfErrorAndIDs.containsKey('Please Fill in the Role of the Employee\'s Account Owner')) {     
                            mapOfErrorAndIDs.get('Please Fill in the Role of the Employee\'s Account Owner').add(plc.Id);
                        }
                        else{
                            mapOfErrorAndIDs.put('Please Fill in the Role of the Employee\'s Account Owner', new set<Id>{plc.Id});
                        }
                    }
                    
                }
                system.debug('Creatinggggg ');
                if(!eligiblePlcForUserCreation.isEmpty()) {
                    listOfPlacements = WS_InviteTalent.sendInviteToTalentForBatchLicenceLimit(eligiblePlcForUserCreation,validProfiles,dhead);
                    listOfPlacements.addAll(setOfNonUserPlcs);     
                }
                
                    
                
                
                //Validate Placements
                //listOfPlacements = validateRequiredFieldForBatch();
            } 
            
            /******************************************</T1>************************************************************/
            system.debug('GooDList' +listOfPlacements);
            Map<String,List<Id>> MapOfAwardMastersAndPlc = new Map<String,List<Id>>();
            Map<Id,tc9_ti__Rule__c> MapOfSaturDayRule = new Map<Id,tc9_ti__Rule__c>();
            Map<Id,tc9_ti__Rule__c> MapOfSunDayRule = new Map<Id,tc9_ti__Rule__c>();
            Map<Id,List<tc9_ti__Time_sheet__c>> mapOfPlcToTs = new Map<Id,List<tc9_ti__Time_sheet__c>>();
            Map<Id,List<Id>> mapOfPublicHolAndPlc = new Map<Id,List<Id>>();
            Map<id,List<tc9_ti__Public_Holiday_Calendar__c>> mapOfPlcAndPublicHol = new Map<id,List<tc9_ti__Public_Holiday_Calendar__c>>();
            
            //Get the WeekendRule
            for(ts2__Placement__c plc : listOfPlacements){
                 System.debug('&&&ts.placement__r.Currencyisocode'+plc.Currencyisocode);
                if(MapOfAwardMastersAndPlc.containsKey(plc.tc9_ti__Award_Master__c)){
                    MapOfAwardMastersAndPlc.get(plc.tc9_ti__Award_Master__c).add(plc.Id);
                }
                else{
                    MapOfAwardMastersAndPlc.put(plc.tc9_ti__Award_Master__c,new List<Id>{plc.Id});
                }
                
                if(mapOfPublicHolAndPlc.containsKey(plc.tc9_ti__Public_Holiday_Calendar__c)){
                    mapOfPublicHolAndPlc.get(plc.tc9_ti__Public_Holiday_Calendar__c).add(plc.Id);
                } 
                else{
                    mapOfPublicHolAndPlc.put(plc.tc9_ti__Public_Holiday_Calendar__c,new List<Id>{plc.Id});
                }
            }
            
            for(tc9_ti__Rule__c iterRule : [SELECT id,tc9_ti__Start_Time__c,tc9_ti__End_Time__c,tc9_ti__type__c,tc9_ti__Award_Master__c From tc9_ti__Rule__c 
                                    WHERE (tc9_ti__type__c =: SATURDAY_RULE OR tc9_ti__type__c =: SUNDAY_RULE)
                                    and tc9_ti__Award_Master__c in: MapOfAwardMastersAndPlc.keySet()]){
            
                for(Id iterPlc : MapOfAwardMastersAndPlc.get(iterRule.tc9_ti__Award_Master__c)){
                    if(iterRule.tc9_ti__type__c == SATURDAY_RULE)
                        MapOfSaturDayRule.put(iterPlc, iterRule);
                    else if(iterRule.tc9_ti__type__c == SUNDAY_RULE)
                        MapOfSunDayRule.put(iterPlc, iterRule); 
                }
            }
            
            for(tc9_ti__Public_Holiday_Calendar__c pub : [SELECT Id, (SELECT Id, tc9_ti__Start_Date__c, tc9_ti__End_Date__c 
                                                         FROM tc9_ti__Public_Holiday_Calendar_Items__r)   
                                             FROM  tc9_ti__Public_Holiday_Calendar__c 
                                             WHERE id in: mapOfPublicHolAndPlc.keySet()]){
                for(Id iterPlc : mapOfPublicHolAndPlc.get(pub.Id)){
                    if(mapOfPlcAndPublicHol.containsKey(iterPlc)){
                        mapOfPlcAndPublicHol.get(iterPlc).add(pub);
                    }
                    else{
                        mapOfPlcAndPublicHol.put(iterPlc,new List<tc9_ti__Public_Holiday_Calendar__c >{pub});
                    }
                } 
            }            
            //Get the Existing  Timesheets
            for(tc9_ti__Time_Sheet__c ts : [SELECT id, tc9_ti__Start_Date__c, tc9_ti__End_Date__c,tc9_ti__Status__c,tc9_ti__Flagged__c,tc9_ti__Placement__c FROM tc9_ti__Time_Sheet__c where tc9_ti__Placement__c in: listOfPlacements]){
                
                if(mapOfPlcToTs.containsKey(ts.tc9_ti__Placement__c)){
                    mapOfPlcToTs.get(ts.tc9_ti__Placement__c).add(ts);
                }
                else{ 
                    mapOfPlcToTs.put(ts.tc9_ti__Placement__c,new List<tc9_ti__Time_Sheet__c>{ts});
                }
            }
            
                                               
            if(!Test.isRunningTest()){
                timesheetEntriesToBeinserted = new List<tc9_ti__Time_Sheet_Entry__c>();
                PlcToBeUpdated = new List<ts2__Placement__c>();
            }
            
            TimesheetGeneration_Weekly weeklyTimesheets;
            TimesheetGeneration_Fortnightly fortnightlyTimesheets;
            BiMonthlyTimesheets biMonthlyTimesheets;
            TimesheetGeneration_Monthly MonthlyTimesheets;
            mapOfPlcAndError =  new Map<Id,String>();
            mapOfTsToPlc = new Map<Id,Id>();
             for(ts2__Placement__c iterPlc : listOfPlacements){
                
                system.debug('iterPlc.Timesheet_Frequency__c '+iterPlc.tc9_ti__Timesheet_Frequency__c);
                if(iterPlc.tc9_ti__Timesheet_Frequency__c == 'Weekly' || iterPlc.tc9_ti__Timesheet_Frequency__c == null){
                    System.debug('In here' + mapOfPlcToTs.get(iterPlc.Id));
                    weeklyTimesheets = new TimesheetGeneration_Weekly(iterPlc,MapOfSaturDayRule.get(iterPlc.Id),MapOfSunDayRule.get(iterPlc.Id), mapOfPlcToTs.get(iterPlc.Id),mapOfPlcAndPublicHol.get(iterPlc.Id),dHead);
                    if(isBatch)
                        weeklyTimesheets.isScheduledJob = true;
                    else
                        weeklyTimesheets.isScheduledJob = false;
                    weeklyTimesheets.createTimesheets();
                    if(iterPlc.tc9_ti__Is_timesheet_created__c || mapOfPlcToTs.containsKey(iterPlc.Id)){
                        timesheetEntriesToBeinserted.addAll(weeklyTimesheets.updateOldTimeSheetEntrys());
                        PlcToBeUpdated.add(weeklyTimesheets.updatePlacementStatus());
                    }
                    else{
                        timesheetEntriesToBeinserted.addAll(weeklyTimesheets.createTimeSheetEntrys(iterPlc.ts2__Start_Date__c, iterPlc.ts2__End_Date__c));
                        system.debug('ISTimesheeeeet '+PlcToBeUpdated);
                        PlcToBeUpdated.add(weeklyTimesheets.updatePlacementStatus());
                        
                    }
                     mapOfPlcAndError.putAll(weeklyTimesheets.mapOfPlcAndError);
                     mapOfTsToPlc.putAll(weeklyTimesheets.mapOfTsToPlc);
                        
                }
                
                if(iterPlc.tc9_ti__Timesheet_Frequency__c == 'Fortnightly-1' || iterPlc.tc9_ti__Timesheet_Frequency__c == 'Fortnightly-2'){
                    System.debug('In here' + mapOfPlcToTs.get(iterPlc.Id));
                    fortnightlyTimesheets = new TimesheetGeneration_Fortnightly(iterPlc,MapOfSaturDayRule.get(iterPlc.Id),MapOfSunDayRule.get(iterPlc.Id), mapOfPlcToTs.get(iterPlc.Id),mapOfPlcAndPublicHol.get(iterPlc.Id),dHead);
                    if(isBatch)
                        fortnightlyTimesheets.isScheduledJob = true;
                    else
                        fortnightlyTimesheets.isScheduledJob = false;
                    
                    fortnightlyTimesheets.createTimesheets();
                    
                    if(iterPlc.tc9_ti__Is_timesheet_created__c || mapOfPlcToTs.containsKey(iterPlc.Id)){
                        timesheetEntriesToBeinserted.addAll(fortnightlyTimesheets.updateOldTimeSheetEntrys());
                        PlcToBeUpdated.add(fortnightlyTimesheets.updatePlacementStatus());
                        
                    }
                    else{
                        timesheetEntriesToBeinserted.addAll(fortnightlyTimesheets.createTimeSheetEntrys(iterPlc.ts2__Start_Date__c, iterPlc.ts2__End_Date__c));
                        system.debug('ISTimesheeeeet '+PlcToBeUpdated);
                        PlcToBeUpdated.add(fortnightlyTimesheets.updatePlacementStatus());
                    }
                     mapOfPlcAndError.putAll(fortnightlyTimesheets.mapOfPlcAndError);
                     mapOfTsToPlc.putAll(fortnightlyTimesheets.mapOfTsToPlc); 
                        
                }
                if(iterPlc.tc9_ti__Timesheet_Frequency__c == 'Bi-Monthly'){ 
                    System.debug('In here' + mapOfPlcToTs.get(iterPlc.Id));
                    biMonthlyTimesheets = new BiMonthlyTimesheets(iterPlc,MapOfSaturDayRule.get(iterPlc.Id),MapOfSunDayRule.get(iterPlc.Id), mapOfPlcToTs.get(iterPlc.Id),mapOfPlcAndPublicHol.get(iterPlc.Id),dHead);
                    if(isBatch)
                        biMonthlyTimesheets.isScheduledJob = true;
                     else
                        biMonthlyTimesheets.isScheduledJob = false;
                    
                    //biMonthlyTimesheets.createTimesheets();
                    
                    if(iterPlc.tc9_ti__Is_timesheet_created__c || mapOfPlcToTs.containsKey(iterPlc.Id)){
                        timesheetEntriesToBeinserted.addAll(biMonthlyTimesheets.updateOldTimeSheetEntrys());
                        PlcToBeUpdated.add(biMonthlyTimesheets.updatePlacementStatus());
                    }
                    else{
                        timesheetEntriesToBeinserted.addAll(biMonthlyTimesheets.createTimeSheetEntrys(iterPlc.ts2__Start_Date__c, iterPlc.ts2__End_Date__c));
                        system.debug('ISTimesheeeeet '+PlcToBeUpdated);
                        PlcToBeUpdated.add(biMonthlyTimesheets.updatePlacementStatus());
                        
                    }
                     mapOfPlcAndError.putAll(biMonthlyTimesheets.mapOfPlcAndError);
                     mapOfTsToPlc.putAll(biMonthlyTimesheets.mapOfTsToPlc);
                        
                }
                 if(iterPlc.tc9_ti__Timesheet_Frequency__c == 'Monthly'){ 
                    MonthlyTimesheets = new TimesheetGeneration_Monthly(iterPlc,MapOfSaturDayRule.get(iterPlc.Id),MapOfSunDayRule.get(iterPlc.Id), mapOfPlcToTs.get(iterPlc.Id),mapOfPlcAndPublicHol.get(iterPlc.Id),dHead);
                    if(isBatch)
                        MonthlyTimesheets.isScheduledJob = true;
                     else
                        MonthlyTimesheets.isScheduledJob = false;
                    
                    MonthlyTimesheets.createTimesheets();
                    
                    if(iterPlc.tc9_ti__Is_timesheet_created__c || mapOfPlcToTs.containsKey(iterPlc.Id)){
                        timesheetEntriesToBeinserted.addAll(MonthlyTimesheets.updateOldTimeSheetEntrys());
                        PlcToBeUpdated.add(MonthlyTimesheets.updatePlacementStatus());
                    }
                    else{
                        timesheetEntriesToBeinserted.addAll(MonthlyTimesheets.createTimeSheetEntrys(iterPlc.ts2__Start_Date__c, iterPlc.ts2__End_Date__c));
                        system.debug('ISTimesheeeeet '+PlcToBeUpdated);
                        PlcToBeUpdated.add(MonthlyTimesheets.updatePlacementStatus());
                        
                    }
                     mapOfPlcAndError.putAll(MonthlyTimesheets.mapOfPlcAndError);
                     mapOfTsToPlc.putAll(MonthlyTimesheets.mapOfTsToPlc);
                        
                }
                system.debug('weeklyTimesheetsss '+weeklyTimesheets +'fortnightlyTimesheetsss '+fortnightlyTimesheets);
                
            }
            system.debug('timesheetEntriesToBeinserted '+timesheetEntriesToBeinserted +'fortnightlyTimesheetsss '+fortnightlyTimesheets);
            Database.SaveResult[] srList = Database.insert(timesheetEntriesToBeinserted,false);     
            for(Integer i=0;i<srList.size();i++){
                
                if (!srList.get(i).isSuccess()){
                    // DML operation failed
                    Database.Error error = srList.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    if(timesheetEntriesToBeinserted.get(i).tc9_ti__Time_Sheet__c != null && mapOfTsToPlc.containsKey(timesheetEntriesToBeinserted.get(i).tc9_ti__Time_Sheet__c)){
                        mapOfPlcAndError.put(mapOfTsToPlc.get(timesheetEntriesToBeinserted.get(i).tc9_ti__Time_Sheet__c),failedDML);//map of entries and error message
                    }
                 }
        
            } 
            system.debug('mapOfPlcAndErrorrrrrrrEXT '+mapOfPlcAndError);
            Database.SaveResult[] plcUpdateList = Database.update(PlcToBeUpdated,false);   
            for(Integer i=0;i<plcUpdateList.size();i++){
                
                if (!plcUpdateList.get(i).isSuccess()){
                    // DML operation failed
                    Database.Error error = plcUpdateList.get(i).getErrors().get(0);
                    String failedDML = error.getMessage();
                    
                    system.debug('Failed ID'+PlcToBeUpdated.get(i).Id);
                    mapOfPlcAndError.put(PlcToBeUpdated.get(i).Id,failedDML);//map of entries and error message
                              
                }
        
            }   
                       
            List<tc9_ti__Time_Sheet__c> emptyTS = new List<tc9_ti__Time_Sheet__c>();
           //get all the timeSheets for the placements and delete the empty headers
           for(tc9_ti__Time_Sheet__c timeSheet : [SELECT id,(SELECT id FROM tc9_ti__Time_Sheet_Entries__r) 
                                          FROM tc9_ti__Time_Sheet__c 
                                          WHERE tc9_ti__Placement__c in: listOfPlacements]){
                    if(timeSheet.tc9_ti__Time_Sheet_Entries__r!=null && timeSheet.tc9_ti__Time_Sheet_Entries__r.size()==0)
                            emptyTS.add(timeSheet);                             
           }
          if(!emptyTS.isEmpty())
            delete emptyTS; 
            
            system.debug('mapppppp '+mapOfPlcAndError);
           /* if(plc.Timesheet_Frequency__c == 'Weekly' || plc.Timesheet_Frequency__c == null){
                System.debug('In here');
                TimesheetGeneration_Weekly weeklyTimesheets = new TimesheetGeneration_Weekly(plc);
            }
                  else if(plc.Timesheet_Frequency__c == 'Fortnightly-1' || plc.Timesheet_Frequency__c == 'Fortnightly-2'){
                TimesheetGeneration_Fortnightly fortNight = new TimesheetGeneration_Fortnightly(plc);
                
            } */
            
      
            system.debug('Querieeees '+Limits.getQueries());
            List<tc9_ti__Debug_Log__c> listOfDebugsForPage = new List<tc9_ti__Debug_Log__c>();
            if(!isBatch && !mapOfPlcAndError.values().isEmpty()){
                for(Id iterId : mapOfPlcAndError.keySet()){
                    if(dHead != null ){
                        dHead.tc9_ti__Area__c = 'CreateTimesheetExt';
                        dHead.tc9_ti__Description__c ='One or more errors from Batch_GenerateTimesheets. See Debug Lines for details.';
                        dHead.tc9_ti__Source__c = 'Time Cards';
                        upsert dHead;
                    }
                    tc9_ti__Debug_Log__c debug = new tc9_ti__Debug_Log__c(); 
                    debug.tc9_ti__Debug_Header__c = dHead.id;
                    debug.tc9_ti__Area__c = 'Batch_GenerateTimesheets';
                    debug.tc9_ti__Description__c = mapOfPlcAndError.get(iterId);
                    debug.tc9_ti__Exception_Type__c = 'DML Exception';
                    debug.tc9_ti__Record_Details__c = '<a href="' + '/'+iterId + '">'+iterId+'</a> ';
                    debug.tc9_ti__Record_Type__c = 'Placement';
                    debug.tc9_ti__source__c = 'Time Cards';
                    listOfDebugsForPage.add(debug);
                    
                }
                if(!listOfDebugsForPage.isEmpty()){
                    insert listOfDebugsForPage;
                }
                List<ts2__Placement__c> placementToBeUpdated = new List<ts2__Placement__c>();
                for(ts2__Placement__c plc : [select Id, tc9_ti__Auto_Timesheet_Creation_Failed__c,tc9_ti__Is_timesheet_created__c,tc9_ti__Last_Timesheet_Creation_Date__c from ts2__Placement__c where Id in: mapOfPlcAndError.keySet()]){
                    plc.tc9_ti__Auto_Timesheet_Creation_Failed__c = true;
                    Plc.tc9_ti__Is_timesheet_created__c = false;
                    Plc.tc9_ti__Last_Timesheet_Creation_Date__c = null;
                    placementToBeUpdated.add(plc);
                }
                system.debug('mapppppp1 '+mapOfTsToPlc.keySet());
                List<tc9_ti__Time_Sheet__c> timesheetsToBeDeleted = new List<tc9_ti__Time_Sheet__c>([select Id from tc9_ti__Time_Sheet__c where Id in: mapOfTsToPlc.keySet()]);
                if(!timesheetsToBeDeleted.isEmpty()){
                    delete timesheetsToBeDeleted;
                }
                if(!placementToBeUpdated.isEmpty()){
                    update placementToBeUpdated;
                }
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'An error occurred during Timesheet Generation. Please review the debug header by following the link <a href="' + '/'+dHead.Id + '">Debug Header</a> for further details.'));
                return null;
            }
            
            if(!isBatch){
                PageReference pageRef = new PageReference('/' + plc.id);
                pageRef.setRedirect(true);
                return pageRef;
            }
            else
                return null;         // SC-0576
            
        }catch(Exception ex) 
        {
            isGenericException =true;   

            //String headId= dhead.Id;
            Database.rollback( sp );
            if(!isBatch){
                    dHead = new tc9_ti__Debug_Header__c();
                    dHead.tc9_ti__Area__c = 'CreateTimesheetExt';
                    dHead.tc9_ti__Description__c ='One or more errors from Batch_GenerateTimesheets. See Debug Lines for details.';
                    dHead.tc9_ti__Source__c = 'Time Cards';
                    insert dHead;
                
                tc9_ti__Debug_Log__c debug = new tc9_ti__Debug_Log__c(); 
                debug.tc9_ti__Debug_Header__c = dHead.id;
                debug.tc9_ti__Area__c = 'CreateTimesheetExt';
                debug.tc9_ti__Description__c = ex.getMessage();
                debug.tc9_ti__Exception_Type__c = ex.getTypeName();
                debug.tc9_ti__Line_Number__c    = ex.getLineNumber();
                debug.tc9_ti__Record_Details__c = '';
                for(ts2__Placement__c iterPlc : listOfPlacements){
                    debug.tc9_ti__Record_Details__c += iterPlc.Id + '\n';
                }
                debug.tc9_ti__Record_Type__c = 'Placement';
                debug.tc9_ti__source__c = 'Time Cards';
                insert debug;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            }   
            else {
                if(dHead != null){
                    dHead.tc9_ti__Description__c = 'One or more errors from Batch_GenerateTimesheets. See Debug Lines for details.';
                    upsert dHead;
                }
                tc9_ti__Debug_Log__c debug = new tc9_ti__Debug_Log__c(); 
                debug.tc9_ti__Debug_Header__c = dHead.id;
                debug.tc9_ti__Area__c = 'CreateTimesheetExt';
                debug.tc9_ti__Description__c = ex.getMessage();
                debug.tc9_ti__Exception_Type__c = ex.getTypeName();
                debug.tc9_ti__Line_Number__c    = ex.getLineNumber();
                debug.tc9_ti__Record_Details__c = '';
                for(ts2__Placement__c iterPlc : listOfPlacements){
                    debug.tc9_ti__Record_Details__c += iterPlc.Id + '\n';
                }
                debug.tc9_ti__Record_Type__c = 'Placement';
                debug.tc9_ti__source__c = 'Time Cards';
                insert debug;
            }
            
            //Update the Placements for Batch
            List<ts2__Placement__c> placementToBeUpdated = new List<ts2__Placement__c>();
            for(ts2__Placement__c plc : [select Id, tc9_ti__Auto_Timesheet_Creation_Failed__c,tc9_ti__Is_timesheet_created__c,tc9_ti__Last_Timesheet_Creation_Date__c from ts2__Placement__c where Id in: listOfPlacements]){
                plc.tc9_ti__Auto_Timesheet_Creation_Failed__c = true;
                Plc.tc9_ti__Is_timesheet_created__c = false;
                Plc.tc9_ti__Last_Timesheet_Creation_Date__c = null;
                placementToBeUpdated.add(plc);
            }
            if(!placementToBeUpdated.isEmpty()){
                update placementToBeUpdated;
            }
            return null; 
        }
     }
     
     
}