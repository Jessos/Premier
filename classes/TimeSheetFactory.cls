/*

	Class 	   : TimeSheetFactory
	Purpose    : Approve/Reject Timesheet entries/expenses
    Author     : 
	
    Change History 
    ******************************************************************************************************************************************
         SCRUM        ModifiedBy        Date            Requested By                           Description                              Tag
    ******************************************************************************************************************************************
		Sc-10799	  Srinidhi.R	  6/12/2016			Michelle Cole					Approver Expense Claim portal page	    	


*/

public class TimeSheetFactory {
    
    
    private Date toDay = Date.today();
    private List<tc9_ti__Time_Sheet_Entry__c> approvedTseList = new List<tc9_ti__Time_Sheet_Entry__c>(); 
    private tc9_ti__ToCloudNineConfig__c configs = tc9_ti__ToCloudNineConfig__c.getInstance();
    
    private final String APPROVE_STATUS = 'Approved';
    private final String REJECT_STATUS = 'Rejected';
    private final String SUBMITTED_STATUS = 'Submitted';
    private final Integer REVIEWED_BY_CLIENT = 1;    
    private final Integer APPROVED_BY_CLIENT = 2;    
    private final Integer REJECTED_BY_CLIENT = 1;    
    
    public static boolean firstRun = true; 
    
    /* 
* Approve selected timesheetentry for the client 
*/
    public void approveTimeSheetEntries(Set<Id> tseIdSet, Contact oContact/**Id contactId*/){
        
        List<tc9_ti__Time_Sheet_Entry__c> updateTseList = new List<tc9_ti__Time_Sheet_Entry__c>();
        List<tc9_ti__Time_Sheet_Entry__c> tseList = getTimeSheetEntry(tseIdSet, oContact.Id/*contactId*/); //retrieve timesheetentry record based on timesheet id and client contact id
        
        for (tc9_ti__Time_Sheet_Entry__c tse : tseList){
            tse.tc9_ti__ViewFlag__c = REVIEWED_BY_CLIENT;    // the timesheetentry has been reviewd by the client
            tse.tc9_ti__ApprovalFlag__c = APPROVED_BY_CLIENT;    //the timesheetentry has been approved by the client
            tse.tc9_ti__Status__c = APPROVE_STATUS; // set approve status
            tse.tc9_ti__Approver_Name__c = oContact.Name; //set approver name
            tse.tc9_ti__Approver_Timestamp__c = System.now(); //set approval time
            approvedTseList.add(tse); 
            updateTseList.add(tse);
        }
        update updateTseList;
        
        //createTrasactionEntrys(); //create transaction records 
        
    }
    
    
    /* 
* Approve selected timesheet entry  
*/
    public void approveTimeSheetEntries(Set<Id> tseIdSet){
        
        
        List<tc9_ti__Time_Sheet_Entry__c> updateTseList = new List<tc9_ti__Time_Sheet_Entry__c>();
        List<tc9_ti__Time_Sheet_Entry__c> tseList = getTimeSheetEntry(tseIdSet); //retrieve timesheetentry record based on timesheet entry ids
        
        for (tc9_ti__Time_Sheet_Entry__c tse : tseList){
            
            tse.tc9_ti__ViewFlag__c       = REVIEWED_BY_CLIENT;   // the timesheetentry has been reviewd by the client
            tse.tc9_ti__ApprovalFlag__c     = APPROVED_BY_CLIENT;   //the timesheetentry has been approved by the client
            tse.tc9_ti__Status__c         = APPROVE_STATUS;     // set approve status
            tse.tc9_ti__Approver_Name__c     = UserInfo.getName();   //set approver name  //SC-0440
            tse.tc9_ti__Approver_Timestamp__c   = System.now();     //set approval time  //SC-0440
            
            approvedTseList.add(tse); 
            updateTseList.add(tse);
        }
        update updateTseList;
        
        //createTrasactionEntrys(); //create transaction records 
        
    }
    
    /* 
* Approve selected timesheetentry for the client 
*/
    public void rejectTimeSheetEntries(Set<Id> tseIdSet, Id contactId){
        
        List<tc9_ti__Time_Sheet_Entry__c> updateTseList = new List<tc9_ti__Time_Sheet_Entry__c>();
        
        List<tc9_ti__Time_Sheet_Entry__c> tseList = getTimeSheetEntry(tseIdSet, contactId); //retrieve timesheetentry record based on timesheet id and client contact id
        
        for (tc9_ti__Time_Sheet_Entry__c tse : tseList){
            tse.tc9_ti__ViewFlag__c = REVIEWED_BY_CLIENT;    // the timesheetentry has been reviewd by the client
            tse.tc9_ti__ApprovalFlag__c = REJECTED_BY_CLIENT;    //the timesheetentry has been rejected by the client
            tse.tc9_ti__Status__c = REJECT_STATUS; // set reject status
            updateTseList.add(tse);
        }
        update updateTseList;
        
        
    }
    
    /* 
* Approve selected timesheetentry for the client 
*/
    public void rejectTimeSheetEntries(Set<Id> tseIdSet){
        
        List<tc9_ti__Time_Sheet_Entry__c> updateTseList = new List<tc9_ti__Time_Sheet_Entry__c>();
        
        List<tc9_ti__Time_Sheet_Entry__c> tseList = getTimeSheetEntry(tseIdSet); //retrieve timesheetentry record based on timesheet id 
        
        for (tc9_ti__Time_Sheet_Entry__c tse : tseList){
            tse.tc9_ti__ViewFlag__c = REVIEWED_BY_CLIENT;    // the timesheetentry has been reviewd by the client
            tse.tc9_ti__ApprovalFlag__c = REJECTED_BY_CLIENT;    //the timesheetentry has been rejected by the client
            tse.tc9_ti__Status__c = REJECT_STATUS; // set reject status
            updateTseList.add(tse);
        }
        update updateTseList;
        
    }
    
    /*
* retrieve timesheet record based on timesheet id
*/
    private List<tc9_ti__Time_Sheet_Entry__c> getTimeSheetEntry(Set<Id> tseIds){
        
        List<tc9_ti__Time_Sheet_Entry__c> tseList = [select tc9_ti__Status__c, tc9_ti__Start__c, tc9_ti__End__c, tc9_ti__EndTime__c, tc9_ti__StartTime__c,tc9_ti__ViewFlag__c,tc9_ti__ApprovalFlag__c,tc9_ti__Approver_Name__c,tc9_ti__Approver_Timestamp__c
                                             from tc9_ti__Time_Sheet_Entry__c Where tc9_ti__ApprovalFlag__c != :APPROVED_BY_CLIENT and tc9_ti__Status__c = :SUBMITTED_STATUS 
                                             and id in: tseIds
                                             order by tc9_ti__WorkDate__c];
        
        return tseList;
        
    }
    
    /*
* retrieve timesheet record based on timesheet id and client contact id
*/
    private List<tc9_ti__Time_Sheet_Entry__c> getTimeSheetEntry(Set<Id> tseIds, Id contactId){
        List<tc9_ti__Time_Sheet_Entry__c> tseList = [select tc9_ti__Status__c,tc9_ti__Start__c, tc9_ti__End__c, tc9_ti__EndTime__c, tc9_ti__StartTime__c,tc9_ti__ViewFlag__c,tc9_ti__ApprovalFlag__c,tc9_ti__Approver_Name__c,tc9_ti__Approver_Timestamp__c 
                                             from tc9_ti__Time_Sheet_Entry__c Where tc9_ti__ApprovalFlag__c != :APPROVED_BY_CLIENT and tc9_ti__Status__c = :SUBMITTED_STATUS 
                                             and (tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__TimeSheetApprover__c =: contactId OR tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__AlternativeTimeSheetApprover__c =: contactId) 
                                             and id in: tseIds
                                             order by tc9_ti__WorkDate__c];
        return tseList;
    }
    
    public void approveExpenses(Set<Id> expIds, Contact approver){
        List<tc9_ti__Expense__c> updateExpList = new List<tc9_ti__Expense__c>();
        List<tc9_ti__Expense__c> expList = getExpenses(expIds, approver.Id); 
        for (tc9_ti__Expense__c exp : expList){
            exp.tc9_ti__Status__c = APPROVE_STATUS; // set approve status
            updateExpList.add(exp);
        }
        update updateExpList;
    }
    
    private List<tc9_ti__Expense__c> getExpenses(Set<Id> expIds, Id contactId){
        List<tc9_ti__Expense__c> expList = [select Id, Name, tc9_ti__Status__c, tc9_ti__Expense_Claim__r.tc9_ti__Placement__c, tc9_ti__Expense_Claim__r.tc9_ti__Placement__r.tc9_ti__Expense_Claim_Approver1__c,
                                    tc9_ti__Expense_Claim__r.tc9_ti__Placement__r.tc9_ti__Alternative_Expense_Claim_Approver__c, tc9_ti__Expense_Claim__c from tc9_ti__Expense__c 
                                    where (tc9_ti__Expense_Claim__r.tc9_ti__Placement__r.tc9_ti__Expense_Claim_Approver1__c =: contactId 
                                           OR tc9_ti__Expense_Claim__r.tc9_ti__Placement__r.tc9_ti__Alternative_Expense_Claim_Approver__c =:contactId) AND Id in :expIds ];
        return expList;
    }
    
    
    /* 
* Approve selected timesheet for the client 
*/
    public void approveTimeSheet(list<tc9_ti__time_sheet__c> tslist){  
        
        
        List<tc9_ti__Time_Sheet_Entry__c> updateTseList = new List<tc9_ti__Time_Sheet_Entry__c>(); 
        
        
        for (tc9_ti__time_sheet__c ts : tslist){
            for (tc9_ti__Time_Sheet_Entry__c tse : ts.tc9_ti__Time_Sheet_Entries__r){
                if (tse.tc9_ti__Status__c != null && (tse.tc9_ti__Status__c.equals(APPROVE_STATUS) || tse.tc9_ti__Status__c.equals(REJECT_STATUS)) ){
                    tse.tc9_ti__ViewFlag__c = REVIEWED_BY_CLIENT;    // the timesheetentry has been reviewd by the client
                    if (tse.tc9_ti__Status__c.equals(APPROVE_STATUS)){
                        tse.tc9_ti__ApprovalFlag__c = APPROVED_BY_CLIENT;    //the timesheetentry has been approved by the client
                        approvedTseList.add(tse);
                    }else{
                        tse.tc9_ti__ApprovalFlag__c = REJECTED_BY_CLIENT;    //the timesheetentry has been rejected by the client
                    }
                    updateTseList.add(tse);
                }
            }
            
        }
        update updateTseList;
        
        //createTrasactionEntrys();
        
    }
    
}