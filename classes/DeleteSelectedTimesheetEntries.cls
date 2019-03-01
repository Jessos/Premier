global class DeleteSelectedTimesheetEntries {
	webservice static void deleteEntries(List<Id> tseID){
		delete [SELECT id from tc9_ti__Time_Sheet_Entry__c WHERE id in : tseID];
	}
}