/*
    Purpose : Webservice methods for the buttons - 'Submit Time Reminder','Approve on Behalf' and 'Send Approval Reminder' 
              on timesheet
    Author  : 2C9 Dharshni
*/
global class RequestTimeSheetUpdate {
    
    //SC-1076
     webservice static String sendCandidateEmail(List<ID> tsIds){
        
        //get last week's timesheet
        Date thisWeekStart  = Date.today().toStartOfWeek();
        system.debug(thisWeekStart);
        Datetime dtnow          = DateTime.now();
        
        List<tc9_ti__Time_Sheet__c> timesheetsNotSubmitted = [SELECT id,Name, tc9_ti__ContactEmail__c, tc9_ti__Candidate__r.Email,tc9_ti__Candidate__r.Name
                                                                FROM tc9_ti__Time_Sheet__c 
                                                                WHERE tc9_ti__Status__c = 'New'
                                                                //And tc9_ti__Start_Date__c <:thisWeekStart 
                                                                and id in : tsIds
                                                              ];
        
        String candidatesWithoutEmail   = '';
        List<tc9_ti__Time_Sheet__c> tsToUpdate = new List<tc9_ti__Time_Sheet__c>();
        Set<Id> uniqueCandidates = new Set<Id>();
        //update candidate email and the notification field
        //changes in the notification field fires the workflow - 'NotifyCandidateToFillTimeSheets'
        for(tc9_ti__Time_Sheet__c ts : timesheetsNotSubmitted){
            
            if(ts.tc9_ti__Candidate__r.Email == null){
                
                if(uniqueCandidates.contains(ts.tc9_ti__Candidate__c))
                    continue;
                uniqueCandidates.add(ts.tc9_ti__Candidate__c);
                
                candidatesWithoutEmail += ts.tc9_ti__Candidate__r.Name + ' , ';
            }
            else{
                ts.Last_Candidate_Notification__c   = dtnow;
                ts.tc9_ti__ContactEmail__c          = ts.tc9_ti__Candidate__r.Email;
                tsToUpdate.add(ts);
            }
        }
        
        system.debug('*** invalid candidates ' + candidatesWithoutEmail);
        system.debug('*** valid timesheets' + tsToUpdate);
        
        try{
            if(candidatesWithoutEmail != ''){
                if(tsToUpdate.isEmpty())
                    return 'None of the associated candidates have a valid email address';
                else{
                    update tsToUpdate;
                    return 'Not all reminders sent successfully. Please review the below Contact records, which do not contain a valid email address :\n\n' + (candidatesWithoutEmail.subString(0,candidatesWithoutEmail.length()-2));  
                }
            }
            
            if(!tsToUpdate.isEmpty()){
                update tsToUpdate;
                return 'Email successfully sent';
            }
            return 'Please select timesheets in \'New\' Status';
        }
        catch(Exception e){
            return 'ERROR :' + e.getMessage();
        }                       
    }
    
    //SC-1074
    webservice static String autoApproveTimesheets(List<ID> tsIds){
        
        //get last week's timesheet
        Date lastWeekStartDate  = Date.today().toStartOfWeek().addDays(1).addDays(-7);
        
        String SUBMITTED_STATUS = 'Submitted';
        String APPROVE_STATUS = 'Approved';
        Integer APPROVED_BY_CLIENT = 2;  
        Integer REVIEWED_BY_CLIENT = 1;    
        
        User currentUser = [SELECT Name From User Where id=:UserInfo.getUserId()];
        Datetime nowDT   = DateTime.now();
        
        List<tc9_ti__Time_Sheet_Entry__c> tseToUpdate = new List<tc9_ti__Time_Sheet_Entry__c>();
        List<Contact> approvers     =  new List<Contact>();
        Set<ID> uniqueApprover      =  new Set<ID>();
        Set<ID> uniqueInvalidApprovers = new Set<ID>();
        
        String approversWithoutEmailStr = '';
        
        for(tc9_ti__Time_Sheet__c ts : [SELECT id,(SELECT id, tc9_ti__Status__c, tc9_ti__Start__c, tc9_ti__End__c, tc9_ti__EndTime__c, tc9_ti__StartTime__c,tc9_ti__ViewFlag__c,tc9_ti__ApprovalFlag__c,tc9_ti__Approver_Name__c,tc9_ti__Approver_Timestamp__c
                                                    From tc9_ti__Time_Sheet_Entries__r 
                                                    Where tc9_ti__ApprovalFlag__c != :APPROVED_BY_CLIENT and tc9_ti__Status__c = :SUBMITTED_STATUS )
                                                ,tc9_ti__Status__c
                                                ,tc9_ti__Placement__r.tc9_ti__TimeSheetApprover__c
                                                ,tc9_ti__Placement__r.tc9_ti__TimeSheetApprover__r.Name 
                                                ,tc9_ti__Placement__r.tc9_ti__TimeSheetApprover__r.Email
                                            FROM tc9_ti__Time_Sheet__c
                                            WHERE tc9_ti__Status__c=:SUBMITTED_STATUS
                                            //and tc9_ti__Start_Date__c = :lastWeekStartDate
                                            and id in : tsIds
                                            ]){
            //process only if the timesheet has entries awating approval
            if(ts.tc9_ti__Time_Sheet_Entries__r!=null && ts.tc9_ti__Time_Sheet_Entries__r.size()>0){
                
                if(ts.tc9_ti__Placement__r.tc9_ti__TimeSheetApprover__r.Email == null){
                    
                    //check if the string already has the invalid approver and add
                    if(!uniqueInvalidApprovers.contains(ts.tc9_ti__Placement__r.tc9_ti__TimeSheetApprover__c))
                        approversWithoutEmailStr += ts.tc9_ti__Placement__r.tc9_ti__TimeSheetApprover__r.Name + ' , ';
                    
                    //add to list
                    uniqueInvalidApprovers.add(ts.tc9_ti__Placement__r.tc9_ti__TimeSheetApprover__c);
                    continue;
                }
                
                for(tc9_ti__Time_Sheet_Entry__c tse : ts.tc9_ti__Time_Sheet_Entries__r){
                    tse.tc9_ti__ViewFlag__c         = REVIEWED_BY_CLIENT;   // the timesheetentry has been reviewd by the client
                    tse.tc9_ti__ApprovalFlag__c     = APPROVED_BY_CLIENT;   //the timesheetentry has been approved by the client
                    tse.tc9_ti__Status__c           = APPROVE_STATUS;       // set approve status
                    tse.tc9_ti__Approver_Name__c    = currentUser.Name;     //set approver name
                    tse.tc9_ti__Approver_Timestamp__c = System.now();       //set approval time
                    tseToUpdate.add(tse);   
                }
                
                //add approver to list, avoid duplicates in the list to update
                if(!uniqueApprover.contains(ts.tc9_ti__Placement__r.tc9_ti__TimeSheetApprover__c))
                    approvers.add(new Contact(id=ts.tc9_ti__Placement__r.tc9_ti__TimeSheetApprover__c,Last_Auto_Approval__c=nowDT));
                
                uniqueApprover.add(ts.tc9_ti__Placement__r.tc9_ti__TimeSheetApprover__c);
            }
        }
    
        Savepoint sp  = Database.setSavepoint();
        try{
            
            if(approversWithoutEmailStr != ''){
                if(tseToUpdate.isEmpty())
                    return 'None of the timesheets could be approved. Please provide a valid email address for the approvers inorder to notify them';
                else{
                    update tseToUpdate;
                    update approvers;
                    return 'Not all timesheets could be approved. Please review the below Contact records, which do not contain a valid email address :\n\n' + (approversWithoutEmailStr.subString(0,approversWithoutEmailStr.length()-2)); 
                }
            }
            
            //update timesheet and approver records
            if(!tseToUpdate.isEmpty()){
                update tseToUpdate;
                update approvers;
                return 'Approval successful';
            }
            
            return 'Please select timesheets with \'Submitted\' entries';
        }
        catch(Exception e){
            Database.rollback(sp);
            return 'ERROR :' + e.getMessage();
        }
        return 'Approval successful';
    }
    
    //SC-1115
    webservice static String sendReminderToApprover(List<ID> tsIds){
        
        String SUBMITTED_STATUS = 'Submitted';
        String APPROVE_STATUS = 'Approved';
        Integer APPROVED_BY_CLIENT = 2;  
        Integer REVIEWED_BY_CLIENT = 1;    
        
        User currentUser = [SELECT Name From User Where id=:UserInfo.getUserId()];
        Datetime nowDT   = DateTime.now();
        
        List<tc9_ti__Time_Sheet_Entry__c> tseToUpdate = new List<tc9_ti__Time_Sheet_Entry__c>();
        List<Contact> approvers     =  new List<Contact>();
        Set<ID> uniqueApprover      =  new Set<ID>();
        String approversWithoutEmailStr = '';
        
        for(tc9_ti__Time_Sheet__c ts : [SELECT id,(SELECT id
                                                    From tc9_ti__Time_Sheet_Entries__r 
                                                    Where tc9_ti__ApprovalFlag__c != :APPROVED_BY_CLIENT and tc9_ti__Status__c = :SUBMITTED_STATUS )
                                                ,tc9_ti__Status__c
                                                ,tc9_ti__Placement__r.tc9_ti__TimeSheetApprover__c
                                                ,tc9_ti__Placement__r.tc9_ti__TimeSheetApprover__r.Name
                                                ,tc9_ti__Placement__r.tc9_ti__TimeSheetApprover__r.Email
                                            FROM tc9_ti__Time_Sheet__c
                                            WHERE tc9_ti__Status__c=:SUBMITTED_STATUS
                                            //and tc9_ti__Start_Date__c = :lastWeekStartDate
                                            and id in : tsIds
                                            ]){
            //process only if the timesheet has entries awating approval
            if(ts.tc9_ti__Time_Sheet_Entries__r!=null && ts.tc9_ti__Time_Sheet_Entries__r.size()>0){
                
                if(uniqueApprover.contains(ts.tc9_ti__Placement__r.tc9_ti__TimeSheetApprover__c))
                    continue;
                uniqueApprover.add(ts.tc9_ti__Placement__r.tc9_ti__TimeSheetApprover__c);
                
                //if the approver doesn't have a valid email address add to list
                //else add approver to list, avoid duplicates in the list to update
                if(ts.tc9_ti__Placement__r.tc9_ti__TimeSheetApprover__r.Email == null)
                    approversWithoutEmailStr += ts.tc9_ti__Placement__r.tc9_ti__TimeSheetApprover__r.Name +' , ';
                else
                    approvers.add(new Contact(id=ts.tc9_ti__Placement__r.tc9_ti__TimeSheetApprover__c,Last_Approval_Reminder__c=nowDT));
            }
        }
        
        system.debug('*** Valid approvers : ' + approvers);
        system.debug('*** Approvers with no Email : ' + approversWithoutEmailStr);
        Savepoint sp  = Database.setSavepoint();
        try{
            
            if(approversWithoutEmailStr != ''){
                if(approvers.isEmpty())
                    return 'None of the reminders could be sent, as the associated approver(s) do not have a valid email address';
                else{
                    update approvers;
                    return 'Not all reminders sent successfully. Please review the below Contact records, which do not contain a valid email address :\n\n' + (approversWithoutEmailStr.subString(0,approversWithoutEmailStr.length()-2)); 
                }
            }
            
            if(!approvers.isEmpty()){
                update approvers;
                return 'Reminder sent successfully';
            }
            return 'Please select timesheets with \'Submitted\' entries';
        }
        catch(Exception e){
            Database.rollback(sp);
            return 'ERROR :' + e.getMessage();
        }
        
    }
    
    webservice static String submitTimesheet(Id tsId){
        system.debug('** ' + tsId);
        tc9_ti__Time_Sheet__c timesheet = [SELECT id, tc9_ti__Status__c FROM tc9_ti__Time_Sheet__c 
                                            WHERE id = : tsId];
        
        if(timesheet.tc9_ti__Status__c == 'New' || timesheet.tc9_ti__Status__c == 'Rejected' || timesheet.tc9_ti__Status__c == 'Submitted'){
            List<tc9_ti__Time_Sheet_Entry__c> tses = [SELECT id,tc9_ti__Status__c, tc9_ti__ViewFlag__c, tc9_ti__ApprovalFlag__c 
                                                        FROM tc9_ti__Time_Sheet_Entry__c
                                                        WHERE tc9_ti__Time_Sheet__c =: tsId];
            for(tc9_ti__Time_Sheet_Entry__c tse : tses){
                tse.tc9_ti__ViewFlag__c     = null;
                tse.tc9_ti__ApprovalFlag__c = null;
                tse.tc9_ti__Status__c       = 'Submitted';
            }
            
            try{
                update tses;
                
                timesheet.tc9_ti__Status__c     = 'Submitted';
                update timesheet;
            }
            catch(DMLException e){
                if(e.getDMLType(0) == StatusCode.REQUIRED_FIELD_MISSING)
                    return 'Required Field Missing ' +  e.getDmlFieldNames(0);
                else if(e.getDmlType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION)
                    return e.getDmlMessage(0);
                else
                    return e.getMessage();
            }
            catch(Exception e){
                return e.getMessage();
            }
            return 'SUCCESS';
        }
        return 'Timesheet status should either be \'New\' or \'Rejected\'';

    }
    
    webservice static String revertTimesheetToNew(Id tsId){
        
        tc9_ti__Time_Sheet__c timesheet = [SELECT id, tc9_ti__Status__c FROM tc9_ti__Time_Sheet__c 
                                            WHERE id = : tsId];
        
        if(timesheet.tc9_ti__Status__c == 'New' || timesheet.tc9_ti__Status__c == 'Rejected' || timesheet.tc9_ti__Status__c == 'Submitted'){
            List<tc9_ti__Time_Sheet_Entry__c> tses = [SELECT id,tc9_ti__Status__c, tc9_ti__ViewFlag__c, tc9_ti__ApprovalFlag__c 
                                                        FROM tc9_ti__Time_Sheet_Entry__c
                                                        WHERE tc9_ti__Time_Sheet__c =: tsId];
            for(tc9_ti__Time_Sheet_Entry__c tse : tses){
                tse.tc9_ti__ViewFlag__c     = null;
                tse.tc9_ti__ApprovalFlag__c = null;
                tse.tc9_ti__Status__c       = 'New';
            }
            
            try{
                update tses;
                
                timesheet.tc9_ti__Status__c     = 'New';
                update timesheet;
                return 'SUCCESS';
            }
            catch(DMLException e){
                if(e.getDMLType(0) == StatusCode.REQUIRED_FIELD_MISSING)
                    return 'Required Field Missing ' +  e.getDmlFieldNames(0);
                else if(e.getDmlType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION)
                    return e.getDmlMessage(0);
                else
                    return e.getMessage();
            }
            catch(Exception e){
                return e.getMessage();
            }
        }
        return 'Timesheet status should either be \'Submitted\' or \'Rejected\'';
        
    }
    
    static testmethod void testWS(){
        
        ToC9_TestDataDump testData = new ToC9_TestDataDump();
        Date plcStartDate       = date.parse('12/10/2012');
        Date plcEndDate         = plcStartDate.addDays(9);  //placement spanning two weeks (till 01/08/2012)
        
        tc9_ti__TaxID__c taxID  = testData.getTaxID();
        tc9_ti__Market__c market= testData.getMarket(taxID.Id); 
        Account accnt           = testData.getAClientAccount(market.Id);
        accnt.tc9_ti__Invoice_Group_By__c ='Client';
        accnt.ts2__Invoice_Terms__c ='10';
        update accnt;
        
        Contact clientContact   = testData.getAClientContact(accnt.Id);
        
        tc9_ti__Site__c sit     = testData.getASite('Test Site', 'http://www.test.com/');
        
        ts2__Job__c job1        = testData.getAJob(accnt.Id, clientContact.Id, market.Id,sit.Id);
        
        Contact candidate       = testData.getACandidate('TestCandidate');  
        candidate.email         = 'canemail@email.test.com';
        candidate.State__c = 'AL';
        candidate.accountid = accnt.id;
        update candidate;
        RecordType rt = [select id,Name from RecordType where SobjectType='ts2__Placement__c' and Name='Perm' Limit 1];
       // ts2__Placement__c plc   = testData.getAPlacement(job1, null, candidate.Id, plcStartDate, plcEndDate, null, 'Temp'); //till next friday
       // plc.recordtypeid = rt.id;
       // plc.ts2__Employee__c = candidate.id;
       // update plc;
        
      //  plc = [Select tc9_ti__Base_Bill_Rate__c,tc9_ti__Base_Pay_Rate__c
                            //    From ts2__Placement__c Where id =: plc.Id];
        
        String NEW_STATUS = 'New';
        String SUBMITTED_STATUS = 'Submitted';
        String APPROVE_STATUS = 'Approved';
        Integer APPROVED_BY_CLIENT = 2;  
        Integer REVIEWED_BY_CLIENT = 1;  
        
        tc9_ti__Time_Sheet__c ts = new tc9_ti__Time_Sheet__c();
        ts.tc9_ti__Start_Date__c = plcStartDate;
        ts.tc9_ti__End_Date__c   = plcStartDate.addDays(7);
       // ts.tc9_ti__Placement__c  = plc.Id;
        ts.tc9_ti__Candidate__c  = candidate.Id;
       // insert ts;
        
        tc9_ti__Time_Sheet_Entry__c entry1  = new tc9_ti__Time_Sheet_Entry__c();
        entry1.tc9_ti__Time_Sheet__c        = ts.Id;
        entry1.tc9_ti__WorkDate__c          = plcStartDate;
        entry1.tc9_ti__Status__c            = NEW_STATUS;
        entry1.tc9_ti__EndTime__c           = '10:00';
        entry1.tc9_ti__StartTime__c         = '10:00';
       // insert entry1;
        
        candidate.Email = null;
        update candidate;
        //send notification to candidate
       // RequestTimeSheetUpdate.sendCandidateEmail(new List<Id>{ts.Id});
      //  ts = [SELECT id,Last_Candidate_Notification__c,tc9_ti__ContactEmail__c ,tc9_ti__Status__c
                               // FROM tc9_ti__Time_Sheet__c
                               // WHERE id=:ts.Id];
        
        candidate.Email = 'testemail@email.com.abc';
        update candidate;
        //send notification to candidate
       // RequestTimeSheetUpdate.sendCandidateEmail(new List<Id>{ts.Id});
       // ts = [SELECT id,Last_Candidate_Notification__c,tc9_ti__ContactEmail__c ,tc9_ti__Status__c
                               // FROM tc9_ti__Time_Sheet__c
                               // WHERE id=:ts.Id];
        
        
        //check if email is updated in timesheet
       // System.assertEquals(ts.tc9_ti__ContactEmail__c,candidate.email);
        //check if workflow fired
        //System.assertNotEquals(ts.Last_Candidate_Notification__c,null);
        
       // RequestTimeSheetUpdate.submitTimesheet(ts.Id);
       // ts = [SELECT id,tc9_ti__Status__c 
                              //  FROM tc9_ti__Time_Sheet__c
                              //  WHERE id=:ts.Id];
        //check if timesheet is submitted
        //System.assertEquals(ts.tc9_ti__Status__c,SUBMITTED_STATUS);
        
       // RequestTimeSheetUpdate.revertTimesheetToNew(ts.Id);
       // ts = [SELECT id,tc9_ti__Status__c 
                              //  FROM tc9_ti__Time_Sheet__c
                               // WHERE id=:ts.Id];
        //check if timesheet is new
       // System.assertEquals(ts.tc9_ti__Status__c,NEW_STATUS);
        
       // RequestTimeSheetUpdate.submitTimesheet(ts.Id);
        //ts = [SELECT id,tc9_ti__Status__c 
                               // FROM tc9_ti__Time_Sheet__c
                               // WHERE id=:ts.Id];
        //check if timesheet is submitted
       // System.assertEquals(ts.tc9_ti__Status__c,SUBMITTED_STATUS);
        
        clientContact.Email = null;
        update clientContact;
        
         //auto approve
       // RequestTimeSheetUpdate.sendReminderToApprover(new List<Id>{ts.Id});
        
        //auto approve
       // RequestTimeSheetUpdate.autoApproveTimesheets(new List<Id>{ts.Id});
        
        clientContact.Email = 'testclientcont@email.com.abc';
        update clientContact;
        
         //auto approve
       // RequestTimeSheetUpdate.sendReminderToApprover(new List<Id>{ts.Id});
        
        //auto approve
       // RequestTimeSheetUpdate.autoApproveTimesheets(new List<Id>{ts.Id});
        
       // ts = [SELECT id,tc9_ti__Status__c 
                              //  FROM tc9_ti__Time_Sheet__c
                              //  WHERE id=:ts.Id];
        //check if timesheet is approved
        //System.assertEquals(ts.tc9_ti__Status__c,APPROVE_STATUS);
        
        clientContact = [SELECT id,Last_Auto_Approval__c,Last_Approval_Reminder__c
                            FROM Contact
                            WHERE id=: clientContact.Id];
        
        //assert the two workflow fields are not null
       // System.assertNotEquals(clientContact.Last_Auto_Approval__c,null);
        //System.assertNotEquals(clientContact.Last_Approval_Reminder__c,null);
        
    }
    
}