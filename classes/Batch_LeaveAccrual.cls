/**
* @author Vignesh Damodharan
* @date 24/02/2014
* @description To generate Sick Leave Accrual Records for Contacts(Candidates)
**/

/*---------------------------------- Logic ----------------------------------------------
    This Batch class runs every week and generates Leave Accrual Records for Contacts(Candidates) based on
        - Create Weekly Leave Ledger Accrual Entries based on the transaction done last week(hours logged)
        - Max Cap of 72 hours per employee
        - Contact's eligibility
        - Job's Location Eligibility 
  ---------------------------------- Logic ----------------------------------------------*/
/*
Change History 
*************************************************************************************************************************************************
    SCRUM         ModifiedBy      Date            Requested By            Description                                                   Tag
*************************************************************************************************************************************************
    SC-11619      Sethuraman      23/09/2016      Michelle Cole         Removed Placement.Is_Eligible_for_Sick_Leave_Accrual__c         T01
                                                                        for references and process only Timesheet_Entry
                                                                        transactions
                                                                        
    SC-14577      Sethuraman        15/02/2017      JAcob Morton    To exclude alternate leave type transactions T02
    SC-14579      Sethuraman        15/02/2017      JAcob Morton    Manual vs scheduler mode of execution  T03
*/
  
global class Batch_LeaveAccrual implements Database.Batchable<sObject>, Database.Stateful{  
    
    global List<Leave_Settings__c> listOfLeaveSettings                          = Leave_Settings__c.getAll().values();
    global Map<String, Leave_Settings__c> mapOfFormattedNameToLeaveSettings     = new Map<String, Leave_Settings__c>();
    global Map<String, Decimal> mapOfUniqueContactStringToHoursAccruedLastWeek  = new Map<String, Decimal>();
    global Map<Id, Decimal> mapOfontactIdToHoursRemainingForMaxCap              = new Map<Id, Decimal>();
    global Map<Id,String> mapOfContactIdToName = new Map<Id,String>();
    global List<String> listOfErrors                                            = new List<String>();
    global final static String ACCRUED_STATUS = 'Accrued';
    global final static String VALID_TRANSACTION_UNIT = 'Hours';
    global final static Integer VALID_CAP = 72;
    global String strQuery;
    global Date fromDate;
    global Date toDate;
    List<String> listOfAlternateLeaveTypes = new List<String>(); //T02
    
    global Batch_LeaveAccrual(Date fromDate , Date toDate, String method){ //T03
        
        //Initialization
        this.fromDate           = fromDate;
        this.toDate             = toDate;
        
        //<T02>***************************************
        Alternate_Leave_Types__c alternateLeaveTypeSettings = Alternate_Leave_Types__c.getValues('DefaultSettings');
        if(alternateLeaveTypeSettings != null && alternateLeaveTypeSettings.Alternate_Pay_Excluded__c != null){
            listOfAlternateLeaveTypes = alternateLeaveTypeSettings.Alternate_Pay_Excluded__c.split(',');
        }
        //</T02>***************************************
        
        //build the query
        strQuery = 'SELECT Name, tc9_ti__Unit__c, tc9_ti__Time_Sheet__r.Job_Name__c, tc9_ti__Time_Sheet__r.tc9_ti__Status__c, tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c, tc9_ti__Time_Sheet__r.tc9_ti__Candidate__r.Name, tc9_ti__Time_Sheet__c, tc9_ti__Time_Sheet_Entry__r.tc9_ti__Status__c, tc9_ti__Time_Sheet_Entry__r.tc9_ti__Time_Sheet__c, tc9_ti__Time_Sheet_Entry__r.Id, tc9_ti__Time_Sheet_Entry__c, tc9_ti__HoursActutal__c, tc9_ti__EntryDate__c, Id, Employee__c, Accrued_Datestamp__c FROM tc9_ti__Transaction__c';
        
        //<T03>**********************************************
        strQuery += ' WHERE';
        
        strQuery += ' RecordType.DeveloperName = \'Timesheet_Entry\''; //<T01>
        
        strQuery += ' AND tc9_ti__Time_Sheet_Entry__r.tc9_ti__Type_of_Leave__c not in :listOfAlternateLeaveTypes'; //T02
        
        strQuery += ' AND Accrued_Datestamp__c = NULL';
        
        if(method == 'Manual')
            strQuery += ' AND tc9_ti__EntryDate__c >=:fromDate AND tc9_ti__EntryDate__c <=:toDate';
        //</T03>**********************************************
        
        System.debug('@@ '+strQuery);
        
        //Create a map of formattedLeaveString to Custom Setting
        if(listOfLeaveSettings.isEmpty()){
                
            //Custom Settings not set 
            listOfErrors.add('Custom Settings not set for Leave Types');
            
        }else{
            for(Leave_Settings__c iteratingCS : listOfLeaveSettings){
                mapOfFormattedNameToLeaveSettings.put(iteratingCS.Name, iteratingCS);
            }
        }
        
        System.debug('mapOfFormattedNameToLeaveSettings :'+mapOfFormattedNameToLeaveSettings);
        
    }   
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator(strQuery);
    }
   
    global void execute(Database.BatchableContext BC, List<tc9_ti__Transaction__c> listOfTransactions){
        
        Set<Id> setOfContactIds = new Set<Id>();
        
        listOfTransactions = [SELECT Name, tc9_ti__Unit__c, tc9_ti__Time_Sheet__r.Job_Name__c, tc9_ti__Time_Sheet__r.tc9_ti__Status__c, 
                                     tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c, tc9_ti__Time_Sheet__r.tc9_ti__Candidate__r.Name, tc9_ti__Time_Sheet__r.tc9_ti__Candidate__r.LastName, tc9_ti__Time_Sheet__r.tc9_ti__Candidate__r.FirstName,
                                     tc9_ti__Time_Sheet__c, tc9_ti__Time_Sheet_Entry__r.tc9_ti__Status__c, 
                                     tc9_ti__Time_Sheet_Entry__r.tc9_ti__Time_Sheet__c, tc9_ti__Time_Sheet_Entry__r.Id, tc9_ti__Time_Sheet_Entry__c, 
                                     tc9_ti__HoursActutal__c, tc9_ti__EntryDate__c, Id, Employee__c, Accrued_Datestamp__c, tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Employee__r.First_Day_Worked__c
                              FROM tc9_ti__Transaction__c WHERE Id IN: listOfTransactions];
        
        //Iterate and create a map of ContactId::ContactName and hoursActual map
        for(tc9_ti__Transaction__c iteratingTransaction : listOfTransactions){
            
            System.debug('Iterating for :: '+iteratingTransaction.Name);
            
            if(iteratingTransaction.tc9_ti__Unit__c == VALID_TRANSACTION_UNIT && iteratingTransaction.Accrued_Datestamp__c == NULL && iteratingTransaction.tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Employee__r.First_Day_Worked__c!= NULL && iteratingTransaction.tc9_ti__EntryDate__c >= iteratingTransaction.tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Employee__r.First_Day_Worked__c){
                Decimal nHoursActual = 0;
            
                //Create a unique string for key in map 
                String uniqueId = iteratingTransaction.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c + '::' + iteratingTransaction.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__r.Name;
                System.debug('@@@ uniqueId:'+uniqueId);
                
                //fetch the actuals if already in map
                if(mapOfUniqueContactStringToHoursAccruedLastWeek.get(uniqueId)!= NULL){
                    nHoursActual = mapOfUniqueContactStringToHoursAccruedLastWeek.get(uniqueId);
                }
                
                //add the hours if > 0
                if(iteratingTransaction.tc9_ti__HoursActutal__c != NULL && iteratingTransaction.tc9_ti__HoursActutal__c > 0){
                    nHoursActual += iteratingTransaction.tc9_ti__HoursActutal__c;
                }
                
                //put in the map with updated actuals
                mapOfUniqueContactStringToHoursAccruedLastWeek.put(uniqueId, nHoursActual); 
                
                if(iteratingTransaction.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__r.LastName != null){
                    mapOfContactIdToName.put(iteratingTransaction.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c,iteratingTransaction.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__r.LastName+', '+ iteratingTransaction.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__r.FirstName);
                }
                
                //Timestamp the Transactions
                iteratingTransaction.Accrued_Datestamp__c = Datetime.now();
                setOfContactIds.add( iteratingTransaction.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c);
            }           
        }
        
        update listOfTransactions;
        
        //Iterate and create a map of ContactId and remaining hours map
        for(Contact iteratingContact : [SELECT Id, Available_Sick_Leave_Balance__c FROM Contact WHERE Id IN: setOfContactIds]){
            mapOfontactIdToHoursRemainingForMaxCap.put(iteratingContact.Id, VALID_CAP - iteratingContact.Available_Sick_Leave_Balance__c);      
        }
        
        System.debug('mapOfontactIdToHoursRemainingForMaxCap :'+mapOfontactIdToHoursRemainingForMaxCap);
        System.debug('mapOfUniqueContactStringToHoursAccruedLastWeek :'+mapOfUniqueContactStringToHoursAccruedLastWeek);
    }

    global void finish(Database.BatchableContext BC){
        
        List<Leave_Ledger__c> listOfLeaveLedgersToBeInserted = new List<Leave_Ledger__c>();
        
        System.debug('@@@ mapOfUniqueContactStringToHoursAccruedLastWeek :'+mapOfUniqueContactStringToHoursAccruedLastWeek);
        
        //Iterate and create leave ledgers for the contacts
        for(String iteratingUniqueContactId : mapOfUniqueContactStringToHoursAccruedLastWeek.keyset()){
            
            String iteratingContactId   = '';
            String iteratingContactName = '';
            Boolean isCapped            = false;
            Decimal hours               = 0;
                    
            iteratingContactId      = iteratingUniqueContactId.substring(0, iteratingUniqueContactId.indexOf('::'));
            iteratingContactName    = mapOfContactIdToName.get(iteratingContactId);
            
            System.debug('iteratingContactId :: '+iteratingContactId);
            System.debug('iteratingContactName :: '+iteratingContactName);
            
            //Create Ledgers for the leave type values in Custom Setting
            for(Leave_Settings__c iteratingLeaveType : listOfLeaveSettings){
                
                hours = mapOfUniqueContactStringToHoursAccruedLastWeek.get(iteratingUniqueContactId) / iteratingLeaveType.Leave_Accrual_Ratio__c;
                
                if(mapOfontactIdToHoursRemainingForMaxCap.get(iteratingContactId) != NULL){
                    if(mapOfUniqueContactStringToHoursAccruedLastWeek.get(iteratingUniqueContactId) / iteratingLeaveType.Leave_Accrual_Ratio__c > mapOfontactIdToHoursRemainingForMaxCap.get(iteratingContactId)){
                        isCapped = true;
                        hours = mapOfontactIdToHoursRemainingForMaxCap.get(iteratingContactId);
                    }
                }
                
                String formattedLeaveString             = '';
                Leave_Ledger__c iteratingLeaveLedger    = new Leave_Ledger__c();
                
                if(iteratingLeaveType.Is_Accrued__c){
                    
                    System.debug('Contact :: '+iteratingContactId);
                    formattedLeaveString = iteratingLeaveType.Name;
                    
                    System.debug('formattedLeaveString :: '+formattedLeaveString);
                    
                    if(mapOfUniqueContactStringToHoursAccruedLastWeek.get(iteratingUniqueContactId) != NULL){
                        
                        //Since mandatory fields, no null check
                        iteratingLeaveLedger.Type__c            = iteratingLeaveType.Name;
                        iteratingLeaveLedger.Contact__c         = iteratingContactId;
                        iteratingLeaveLedger.Leave_Hours__c     = hours;
                        if(!isCapped){
                            iteratingLeaveLedger.Reason__c          = iteratingContactName + ' - ' + formattedLeaveString +' Accrual';
                            iteratingLeaveLedger.Name               = iteratingContactName + ' - ' + formattedLeaveString +' Accrual' + ' - ' + Datetime.now().format('MM/dd/YYYY');
                        }else{
                            iteratingLeaveLedger.Reason__c          = iteratingContactName + ' - ' + formattedLeaveString +' Accrual Capped';
                            iteratingLeaveLedger.Name               = iteratingContactName + ' - ' + formattedLeaveString +' Accrual Capped' + ' - ' + Datetime.now().format('MM/dd/YYYY');
                        }
                        iteratingLeaveLedger.Date_Incurred__c   = Date.today();
                        iteratingLeaveLedger.Status__c          = ACCRUED_STATUS;
                        listOfLeaveLedgersToBeInserted.add(iteratingLeaveLedger);
                    }
                }   
            }
        }
        
        System.debug('listOfLeaveLedgersToBeInserted :: '+listOfLeaveLedgersToBeInserted);
        
        if(!listOfLeaveLedgersToBeInserted.isEmpty()){
            insert listOfLeaveLedgersToBeInserted;
        }
    }
}