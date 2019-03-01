/**
* @author Vignesh Damodharan
* @date 25/02/2014
* @description This is the trigger for Time Sheet Entry Object
*/
public class TimeSheetEntry_Trigger_Utility {
    
    public final static String APPROVED_STATUS = 'Approved';
    public final static String APPLIED_STATUS = 'Submitted';
    public final static String DELETED_STATUS = 'Deleted';
    
/**
* @author Vignesh Damodharan
* @date 25/02/2014
* @description This method populate First Day Worked for Candidates
* @param List of Timesheet entries
* @return none
*/ 
    public static void PopulateFirstDayWorkedForCandidates(List<tc9_ti__Time_Sheet_Entry__c> listOfTimesheetEntries){
        
        Map<Id, Contact> mapOfContactIdToContact    = new Map<Id, Contact> ();
        Set<Id> setOfCandidateIds                   = new Set<Id>();
        List<Contact> listOfCandidatesToBeUpdated   = new List<Contact>();
        
        //re fetch the timesheet entries with the needed data
        listOfTimesheetEntries = [SELECT Id, Name, tc9_ti__WorkDate__c, tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c, tc9_ti__HoursAcutal__c, 
                                         tc9_ti__Time_Sheet__r.tc9_ti__Candidate__r.First_Day_Worked__c, 
                                         tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Job__r.ts2__Location__c 
                                  FROM tc9_ti__Time_Sheet_Entry__c 
                                  WHERE Id IN: listOfTimesheetEntries];
        
        //Iterate and fetch all the Candidates for the related timesheet Entries
        for(tc9_ti__Time_Sheet_Entry__c iteratingTimesheetEntry : listOfTimesheetEntries){
            
            System.debug('@@@ '+iteratingTimesheetEntry.Name);
            System.debug('@@@ '+iteratingTimesheetEntry.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c);
            System.debug('@@@ '+iteratingTimesheetEntry.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__r.First_Day_Worked__c);
            
            //If the contact exists, and the first start date is empty, fect the ids of the contacts to update
            if(iteratingTimesheetEntry.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c != NULL &&
               iteratingTimesheetEntry.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__r.First_Day_Worked__c == NULL && 
               iteratingTimesheetEntry.tc9_ti__HoursAcutal__c > 0){
                
                setOfCandidateIds.add(iteratingTimesheetEntry.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c);
                
                //set the work date as the first work date
                Date firstWorkDate = iteratingTimesheetEntry.tc9_ti__WorkDate__c;
                
                //If already found in map and map date is less than the first date, update the first date to first date
                if(mapOfContactIdToContact.get(iteratingTimesheetEntry.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c) != NULL){
                    if(firstWorkDate > mapOfContactIdToContact.get(iteratingTimesheetEntry.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c).First_Day_Worked__c){
                        firstWorkDate = mapOfContactIdToContact.get(iteratingTimesheetEntry.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c).First_Day_Worked__c;
                    }   
                }
                
                //Populate the map of contact id to first Date
                mapOfContactIdToContact.put(iteratingTimesheetEntry.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c,new Contact(Id= iteratingTimesheetEntry.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c, First_Day_Worked__c = firstWorkDate));
            }
        }
        
        //Update the contacts with the first work date
        if(!mapOfContactIdToContact.values().isEmpty()){
            
            SavePoint sp = Database.setSavepoint();
            try{
                update mapOfContactIdToContact.values();
            }
            catch(Exception e){
                listOfTimesheetEntries[0].addError('Unable to update contacts : '+e.getMessage());  
                Database.rollback(sp);          
            }
        }
    }
    
/**
* @author Vignesh Damodharan
* @date 27/02/2014
* @description This method creates Leave Ledger for Leave Timesheet Entries
* @param List of Timesheet entries
* @return none
*/ 
    public static void CreateSickLeaveLedger(List<tc9_ti__Time_Sheet_Entry__c> listOfTimesheetEntries){
        
        List<Leave_Ledger__c> listOfLeaveLedgersToBeInserted = new List<Leave_Ledger__c>();
        
        listOfTimesheetEntries = [SELECT ID, Name, tc9_ti__WorkDate__c, tc9_ti__HoursAcutal__c, tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c, Employee_Name__c FROM tc9_ti__Time_Sheet_Entry__c WHERE Id IN: listOfTimesheetEntries];
        
        System.debug('@@@ listOfTimesheetEntries :'+listOfTimesheetEntries);
        
        //Iterate and create leave ledgers for the TimesheetEntries
        for(tc9_ti__Time_Sheet_Entry__c iteratingTSE : listOfTimesheetEntries){
            
            String formattedLeaveString = 'Sick Leave';
            Leave_Ledger__c iteratingLeaveLedger    = new Leave_Ledger__c();
                
            iteratingLeaveLedger.Type__c            = formattedLeaveString;
            iteratingLeaveLedger.Date_Incurred__c   = iteratingTSE.tc9_ti__WorkDate__c;
            iteratingLeaveLedger.Timesheet_Entry__c = iteratingTSE.Id;
            iteratingLeaveLedger.Contact__c         = iteratingTSE.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c;
            
            if(iteratingTSE.tc9_ti__HoursAcutal__c != NULL){
                
                //Since mandatory fields, no null check
                iteratingLeaveLedger.Leave_Hours__c     = iteratingTSE.tc9_ti__HoursAcutal__c;
                iteratingLeaveLedger.Reason__c          = formattedLeaveString +' - ' + iteratingTSE.Name;
                iteratingLeaveLedger.Name               = formattedLeaveString +' - ' + iteratingTSE.Name;
                iteratingLeaveLedger.Date_Incurred__c   = Date.today();
                iteratingLeaveLedger.Status__c          = APPLIED_STATUS;
                listOfLeaveLedgersToBeInserted.add(iteratingLeaveLedger);
            }
        }   
        
        System.debug('listOfLeaveLedgersToBeInserted :: '+listOfLeaveLedgersToBeInserted);
        
        if(!listOfLeaveLedgersToBeInserted.isEmpty()){
            insert listOfLeaveLedgersToBeInserted;
        }
    }
    
/**
* @author Vignesh Damodharan
* @date 27/02/2014
* @description This method updates Leave Ledger for Leave Timesheet Entries
* @param List of Timesheet entries
* @return none
*/ 
    public static void UpdateSickLeaveLedger(Map<Id,tc9_ti__Time_Sheet_Entry__c> newMap, Map<Id,tc9_ti__Time_Sheet_Entry__c> oldMap){
        
        List<Id> listofTimesheetEntriesApproved = new List<Id>();
        
        //Fetch the related Leave ledgers for the corresponding approved 
        for(Id iteratingTSEId : newMap.keyset()){
            
            if(newMap.get(iteratingTSEId).tc9_ti__Status__c == APPROVED_STATUS && 
               newMap.get(iteratingTSEId).tc9_ti__Status__c != oldMap.get(iteratingTSEId).tc9_ti__Status__c){
                listofTimesheetEntriesApproved.add(iteratingTSEId);  
            }
        }
            
        System.debug('@@@ '+listofTimesheetEntriesApproved);
        
        if(!listofTimesheetEntriesApproved.isEmpty()){
            
            List<Leave_Ledger__c> listOfLeaveLedgersTobeUpdated = [SELECT Id FROM Leave_Ledger__c WHERE Timesheet_Entry__c IN: listofTimesheetEntriesApproved];
            
            for(Leave_Ledger__c iteratingLedger : listOfLeaveLedgersTobeUpdated){
                iteratingLedger.Status__c = APPROVED_STATUS;
            }
            
            update listOfLeaveLedgersTobeUpdated;
        }
        
    }   

/**
* @author Vignesh Damodharan
* @date 27/02/2014
* @description This method updates Leave Ledger for Leave Timesheet Entries
* @param List of Timesheet entries
* @return none
*/ 
    public static void UpdateSickLeaveLedgerAsDeleted(List<tc9_ti__Time_Sheet_Entry__c> listofTimesheetEntries){
        
        List<Id> listofTimesheetEntriesDeleted = new List<Id>();
        
        //Fetch the related Leave ledgers for the corresponding approved 
        for(tc9_ti__Time_Sheet_Entry__c iteratingTSE : listofTimesheetEntries){
            
            listofTimesheetEntriesDeleted.add(iteratingTSE.Id);  
        }
            
        System.debug('@@@ '+listofTimesheetEntriesDeleted);
        
        if(!listofTimesheetEntriesDeleted.isEmpty()){
            
            List<Leave_Ledger__c> listOfLeaveLedgersTobeUpdated = [SELECT Id FROM Leave_Ledger__c WHERE Timesheet_Entry__c IN: listofTimesheetEntriesDeleted];
            
            for(Leave_Ledger__c iteratingLedger : listOfLeaveLedgersTobeUpdated){
                iteratingLedger.Status__c = DELETED_STATUS;
            }
            
            update listOfLeaveLedgersTobeUpdated;
        }
    }            
}