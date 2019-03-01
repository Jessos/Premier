trigger PlacementAllTrigger on ts2__Placement__c (after delete, after insert, after undelete,
after update, before delete, before insert, before update) {


    if(trigger.isBefore && trigger.isInsert){

        Set<Id> employeeIds = new Set<Id>();
        for(ts2__Placement__c place : trigger.new)
            employeeIds.add(place.ts2__Employee__c);
        List<Contact> EmployeeList = [select Ref_Recruiter__c from Contact where Id in :employeeIds];
        Map<Id, Contact> EmployeeMap = new Map<Id,Contact>();
        for(Contact cont : EmployeeList)
             EmployeeMap.put(cont.Id, cont);
        for(ts2__Placement__c placement : trigger.new)
            if(EmployeeMap.get(placement.ts2__Employee__c) != null)
                placement.ts2__Filled_By_2__c = EmployeeMap.get(placement.ts2__Employee__c).Ref_Recruiter__c;
    }
    
   /* if(trigger.isAfter && trigger.isInsert)
    {
    CreateBillingFromPlacment.CreateUpdateBillling(trigger.new,null);
    }*/
    if(trigger.isAfter && trigger.isUpdate)
    {
     CreateBillingFromPlacment.CreateUpdateBillling(trigger.new,trigger.oldmap);
    }
}