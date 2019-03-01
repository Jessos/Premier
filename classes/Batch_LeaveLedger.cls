/*
        @Description:       Batch job to update Leave ledger either expire them or make it eligible for use
        @Scrum:             SC-11619
        @TestClass:         TestScheduler_Batch_LeaveLedger
        @CreatedBy:         Sethuraman

Change History 
***************************************************************************************************************
    SCRUM          ModifiedBy          Date            Requested By            Description                   Tag
***************************************************************************************************************

*/

global class Batch_LeaveLedger implements Database.Batchable<sObject>{
    
    global String query;
    
    global Batch_LeaveLedger(){
        query = 'Select Status__c, Contact__r.Sick_Leave_Reset_Date__c, Eligible_for_use__c, Contact__r.Sick_Pay_Eligibility_Date__c From Leave_Ledger__c Where  Status__c = \'Accrued\' And Contact__r.Sick_Leave_Reset_Date__c != NULL';
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

   global void execute(Database.BatchableContext BC, List<Leave_Ledger__c> listOfLeaveLedgers){
       List<Leave_Ledger__c> listOfLeaveLedgersToUpdate = new List<Leave_Ledger__c>();
        for(Leave_Ledger__c leaveLedger : listOfLeaveLedgers){
            if(leaveLedger.Status__c == 'Accrued'){
                if(Date.Today() > leaveLedger.Contact__r.Sick_Leave_Reset_Date__c){
                    leaveLedger.Status__c = 'Expired'; 
                    leaveLedger.Eligible_for_use__c = false;
                    listOfLeaveLedgersToUpdate.add(leaveLedger);
                    system.debug('to be expired' + leaveLedger);
                }
                if(leaveLedger.Eligible_for_use__c == false && leaveLedger.Contact__r.Sick_Pay_Eligibility_Date__c != NULL && Date.Today() >= leaveLedger.Contact__r.Sick_Pay_Eligibility_Date__c && Date.Today() < leaveLedger.Contact__r.Sick_Leave_Reset_Date__c){
                    leaveLedger.Eligible_for_use__c = true;
                    listOfLeaveLedgersToUpdate.add(leaveLedger);
                    system.debug('eligible for use' + leaveLedger);
                }
            }
        }
        if(!listOfLeaveLedgersToUpdate.isEmpty()){
            Database.update(listOfLeaveLedgersToUpdate, false);
        }
   }
 
   global void finish(Database.BatchableContext BC){
        
   }
}