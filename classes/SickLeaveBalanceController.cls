public class SickLeaveBalanceController {

    private final Contact contact;

    public SickLeaveBalanceController() {
    	User currentUser = [SELECT Id, contactId FROM User WHERE Id =: UserInfo.getUserId()];

        contact = [SELECT Id, Total_Sick_Leave_Hours_Taken_Portal__c,Available_Sick_Leave_Balance__c,Total_Accrued_Sick_Leave_Hours_Portal__c  FROM Contact WHERE Id =:  currentUser.contactId];
    }

    public Contact getContact() {
        return contact;
    }
}