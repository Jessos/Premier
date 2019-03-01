/*
        Class           :   Ctrl_CommunityTSPage.cls
        @Author         :   Ponni Priyadharshni
        @TestClass:     :   TestCtrl_CommunityTSPage.cls
 Change History 
    ******************************************************************************************************************************************
         SCRUM        ModifiedBy        Date            Requested By                           Description                              Tag
    ******************************************************************************************************************************************
       SC-16170      Jagadeswary      07/06/2017        Michelle Cole       Field: Days til Current Timesheet Visible Not Available for Communities
       SC-16171      Jagadeswary      09/06/2017        Michelle Cole       Communities Portal: Managing Focus of Overdue Timesheets
*/

public with sharing class Ctrl_CommunityTSPage {
    
    public Id uId {get;set;}
    public Id contactId;
    
    public Integer overDueSum {get;set;}
    public Integer currentSum {get;set;}
    
    public String TS_NEW_STATUS = 'New';
    public String TS_SUBMIT_STATUS = 'Submitted';
    public String TS_APPROVED_STATUS = 'Approved';
    public String TS_REJECTED_STATUS = 'Rejected';
    
    public User currentUser;
    
    public List<tc9_ti__Time_Sheet__c> allTSListofCand;
    public List<tc9_ti__Time_Sheet__c> timeSheetHistoryList {get;set;}
    public map<Id,placementWrapper> mapOfPlctToTSCurrent;
    public map<Id,placementWrapper> mapOfPlctToTSOverDue;
    public map<Id,placementWrapper> mapOfTSH;
    public List<placementWrapper> currentList {get;set;}
    public List<placementWrapper> overdueList {get;set;}
    public List<placementWrapper> TSHList {get;set;}
    public tc9_ti__ToCloudNineConfig__c conf {get;set;}
    public String Page_FillTimeSheet {get;set;}
    public String Page_CommunityECLandingPage {get;set;}
    
    public Ctrl_CommunityTSPage(){
        
        conf   = tc9_ti__ToCloudNineConfig__c.getInstance();
        mapOfPlctToTSCurrent = new map<Id,placementWrapper>();
        mapOfPlctToTSOverDue = new map<Id,placementWrapper>();
        mapOfTSH = new map<Id,placementWrapper>();
        //timeSheetHistoryList = new List<Time_Sheet__c>();
        currentList = new List<placementWrapper>();
        overdueList = new List<placementWrapper>();
        TSHList = new List<placementWrapper>();
        overDueSum = 0;
        currentSum = 0;
        
        //Page_FillTimeSheet = UtilClass1.getAPIName('FillTimesheet_Page_v2');
        Page_CommunityECLandingPage = UtilClass1.getAPIName('CommunitiesExpenseClaimLandingPage');
        uId = UserInfo.getUserId();
        System.debug('!@#$%^&*() '+UserInfo.getUserId());
        
        if(uId!=null){
            currentUser = [Select FirstName, LastName, ContactId, Contact.FirstName, Contact.LastName from User where id =: uId limit 1];
            
            if(currentUser.ContactId != null){
                contactId = currentUser.ContactId;
                //contactId = '0032800000cDVZH';
                String strQuery  = ' SELECT tc9_ti__Start_Date__c, Name, tc9_ti__End_Date__c, tc9_ti__Status__c, tc9_ti__WeeklyActualHours__c, ';
                strQuery        += ' tc9_ti__Placement__c, tc9_ti__Placement__r.ts2__Job__c, tc9_ti__Placement__r.ts2__Job__r.Name, tc9_ti__Placement__r.ts2__Job__r.tc9_ti__Client_Name__c, tc9_ti__Placement__r.ts2__Job__r.ts2__Account__c, ';
                strQuery        += ' tc9_ti__Candidate__c, tc9_ti__Placement__r.Name, Id  ';
                strQuery        += ' FROM tc9_ti__Time_Sheet__c ';
                strQuery        += ' WHERE tc9_ti__Candidate__c =: contactId ';
                strQuery        += ' AND ( tc9_ti__Status__c =: TS_NEW_STATUS OR tc9_ti__Status__c =: TS_SUBMIT_STATUS OR tc9_ti__Status__c =: TS_APPROVED_STATUS OR tc9_ti__Status__c =: TS_REJECTED_STATUS ) ';
                strQuery        += ' ORDER BY tc9_ti__Start_date__c ';
                System.debug('!@#$% strQuery '+strQuery);
                
                allTSListofCand = Database.query(strQuery);
                
                System.debug('!@#$% allTSListofCand '+allTSListofCand);
                
                if(!allTSListofCand.isEmpty()){
                    Integer daysFrom;
                    Date thisDate;
                    //get the details from custom settings
                    tc9_ti__ToCloudNineConfig__c conf   = tc9_ti__ToCloudNineConfig__c.getInstance();
                    if(conf != null)
                        daysFrom            = (Integer)conf.tc9_ti__Days_til_Current_Timesheet_Visible__c;
                    
                    //fix the day, untill which timesheet headers should be queried
                    if(daysFrom == null || daysFrom == 0 )
                        thisDate      = Date.today();
                    else
                        thisDate      = Date.today().addDays(-daysFrom);
                        
                    Integer EndDateFilter = (conf.tc9_ti__Days_Until_Timesheet_Overdue__c==null?0:(Integer)conf.tc9_ti__Days_Until_Timesheet_Overdue__c);
                    
                    for(tc9_ti__Time_Sheet__c thisTS: allTSListofCand){
                       // if(thisTS.tc9_ti__Status__c == 'Submitted' || thisTS.tc9_ti__Status__c == 'New' || thisTS.tc9_ti__Status__c == 'Rejected'){
                            if(thisTS.tc9_ti__Status__c == 'New'){
                            if(thisTS.tc9_ti__Start_Date__c <= thisDate){
                                //if(thisTS.tc9_ti__End_Date__c.addDays(EndDateFilter) >= Date.today()){
                                    if(mapOfPlctToTSCurrent.containsKey(thisTS.tc9_ti__Placement__c)){
                                        placementWrapper thisplctWRP = mapOfPlctToTSCurrent.get(thisTS.tc9_ti__Placement__c);
                                        thisplctWRP.thisTSList.add(thisTS);
                                        thisplctWRP.numOfTS++;
                                        mapOfPlctToTSCurrent.put(thisTS.tc9_ti__Placement__c,thisplctWRP);
                                    }
                                    else{
                                        mapOfPlctToTSCurrent.put(thisTS.tc9_ti__Placement__c, new placementWrapper(thisTS));
                                    }
                                //}
                                /*else{
                                    if(mapOfPlctToTSOverDue.containsKey(thisTS.tc9_ti__Placement__c)){
                                        placementWrapper thisplctWRP = mapOfPlctToTSOverDue.get(thisTS.tc9_ti__Placement__c);
                                        thisplctWRP.thisTSList.add(thisTS);
                                        thisplctWRP.numOfTS++;
                                        mapOfPlctToTSOverDue.put(thisTS.tc9_ti__Placement__c,thisplctWRP);
                                    }
                                    else{
                                        mapOfPlctToTSOverDue.put(thisTS.tc9_ti__Placement__c, new placementWrapper(thisTS));
                                    }
                                }*/
                            }
                        }
                        else if(thisTS.tc9_ti__Status__c == 'Submitted'){
                                    if(mapOfPlctToTSOverDue.containsKey(thisTS.tc9_ti__Placement__c)){
                                        placementWrapper thisplctWRP = mapOfPlctToTSOverDue.get(thisTS.tc9_ti__Placement__c);
                                        thisplctWRP.thisTSList.add(thisTS);
                                        thisplctWRP.numOfTS++;
                                        mapOfPlctToTSOverDue.put(thisTS.tc9_ti__Placement__c,thisplctWRP);
                                    }
                                    else{
                                        mapOfPlctToTSOverDue.put(thisTS.tc9_ti__Placement__c, new placementWrapper(thisTS));
                                    }
                                }
                        else if(thisTS.tc9_ti__Status__c == 'Approved'){
                            //timeSheetHistoryList.add(thisTS);
                            if(mapOfTSH.containsKey(thisTS.tc9_ti__Placement__c)){
                                placementWrapper thisplctWRP = mapOfTSH.get(thisTS.tc9_ti__Placement__c);
                                thisplctWRP.thisTSList.add(thisTS);
                                thisplctWRP.numOfTS++;
                                mapOfTSH.put(thisTS.tc9_ti__Placement__c,thisplctWRP);
                            }
                            else{
                                mapOfTSH.put(thisTS.tc9_ti__Placement__c, new placementWrapper(thisTS));
                            }
                        }
                    }
                    if(mapOfPlctToTSCurrent.size() > 0)
                        currentList = mapOfPlctToTSCurrent.values();
                    if(mapOfPlctToTSOverDue.size() > 0){
                        overDueList = mapOfPlctToTSOverDue.values();
                        system.debug('overdue list ::: ' + overDueList);
                    }
                     for(placementWrapper plcWrap : mapOfTSH.values()){
                        if(TSHList.size()<= 100){
                            TSHList.add(plcWrap); 
                        }
                    } 
                        
                    for(placementWrapper thisWrp: overDueList){
                        overDueSum += thisWrp.numOfTS;
                    }
                    for(placementWrapper thisWrp: currentList){
                        currentSum += thisWrp.numOfTS;
                    }
                    
                    currentList.sort();
                    overDueList.sort();
                    TSHList.sort();
                }
                else{
                    //if No timesheets are there Booleans to put No records to be displayed
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No TimeSheets Available'));
                }
            }
        }
        
    }
    
    public class placementWrapper implements Comparable{
        
        public Integer numOfTS {get;set;}
        public String plctName {get;set;}
        public String clientName {get;set;}
        public String JobName {get;set;}
        public List<tc9_ti__Time_Sheet__c> thisTSList {get;set;}
        
        public placementWrapper(tc9_ti__Time_Sheet__c thisTS){
            plctName = thisTS.tc9_ti__Placement__r.Name;
            clientName = thisTS.tc9_ti__Placement__r.ts2__Job__r.tc9_ti__Client_Name__c;
            JobName = thisTS.tc9_ti__Placement__r.ts2__Job__r.Name;
            numOfTS = 1;
            thisTSList = new List<tc9_ti__Time_Sheet__c>();
            thisTSList.add(thisTS);
        }
        
        public Integer compareTo(Object wrapperObj){
            placementWrapper wrapper = (placementWrapper) wrapperObj;
            if(this.plctName > wrapper.plctName)
                return 1;
            else if(this.plctName < wrapper.plctName)
                return -1;  
            
            if(this.clientName > wrapper.clientName)
                return 1;
            else if(this.clientName < wrapper.clientName)
                return -1;
            
            
            return 0;
        }
        
    }
        
}