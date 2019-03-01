/*
    Author   : 2C9 Dharshni
    Purpose  : 1) To autopopulate Placement fields from related Job record
    		   2) To populate the latest placement on a contact based on the placement's start date
*/

trigger trg_Placement on ts2__Placement__c (before insert, after insert, after update) {
    
    if(Trigger.isBefore && Trigger.isInsert)
    	PlacementTriggerUtility.populateFromJobOrder(Trigger.New);
	
	if(!PlacementTriggerUtility.plcAfterTrigger && Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
		PlacementTriggerUtility.populateLatestPlacementOnCandidate(Trigger.New, Trigger.oldMap, Trigger.isInsert);
		PlacementTriggerUtility.plcAfterTrigger  = true;
	}    	
    
}