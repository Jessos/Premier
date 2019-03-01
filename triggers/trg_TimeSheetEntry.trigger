/**
* @author Vignesh Damodharan
* @date 25/02/2014
* @description This is the trigger for Time Sheet Entry Object
*
* @Modified Included Create and Update Sick Leave Entry methods - 27/02/2014
* @Modified Included Deleted Sick Leave Entry methods - 06/03/2014
*/
trigger trg_TimeSheetEntry on tc9_ti__Time_Sheet_Entry__c (after insert, after update, after delete) {

	if(Trigger.isAfter && !Trigger.isDelete){
    	TimeSheetEntry_Trigger_Utility.PopulateFirstDayWorkedForCandidates(Trigger.new);
        TimeSheetEntry_Trigger_Utility.UpdateSickLeaveLedger(Trigger.newMap, Trigger.oldMap);
    }else if (Trigger.isDelete){
    	TimeSheetEntry_Trigger_Utility.UpdateSickLeaveLedgerAsDeleted(Trigger.old);
    }
    
}