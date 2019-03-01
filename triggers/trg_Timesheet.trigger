/**
    Author  :   2C9 Dharshni
    Purpose :   Whenever a timesheet is submitted, a workflow rule sends email to approvers with link token in it.
                This trigger checks if the approver has a valid link token and generates if needed
**/
trigger trg_Timesheet on tc9_ti__Time_Sheet__c (after insert, after update) {
    
    Set<Id> plcIds = new Set<Id>();
    Set<Id> approverIds = new Set<Id>();
    
    List<tc9_ti__Site__c> defaultSite = [SELECT id,tc9_ti__default__c,tc9_ti__Site_URL__c FROM tc9_ti__Site__c WHERE tc9_ti__default__c = true];
        
    //if the timesheet's status is Submitted, consider its approver for check
    for(tc9_ti__Time_Sheet__c ts : Trigger.new){
        if(ts.tc9_ti__Status__c == 'Submitted' && (Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(ts.Id).tc9_ti__Status__c != 'Submitted')))
            plcIds.add(ts.tc9_ti__Placement__c);
    }
    
    if(plcIds.isEmpty())
        return;
    
    system.debug('** ' + plcIds);
    
    for(ts2__Placement__c plc : [SELECT id, tc9_ti__TimeSheetApprover__c FROM ts2__Placement__c WHERE id in : plcIds])
        if(plc.tc9_ti__TimeSheetApprover__c != null)
            approverIds.add(plc.tc9_ti__TimeSheetApprover__c);
    
    system.debug('** ' + approverIds);
    
    Date tDay = Date.today();
    List<Contact> approversToUpdate = new List<Contact>();
    
    //for the approver, the link token should be updated 
    // 1) if the token/expiry is null
    // 2) if the token has expired already 
    for(Contact c : [SELECT id, tc9_ti__Link_Token__c, tc9_ti__Link_Token_Expiry__c 
                        FROM Contact 
                        WHERE id in : approverIds]){
        if(c.tc9_ti__Link_Token__c == null || c.tc9_ti__Link_Token_Expiry__c == null ){
            approversToUpdate.add(c);
            continue;
        }
        
        Date expiryDate = c.tc9_ti__Link_Token_Expiry__c.date();
        if(tDay.daysBetween(expiryDate) < 0){
            approversToUpdate.add(c);
        }   
    }
    
    //next wednesday should be set as the next expiry date
    Date nextWednesday  = Date.today().toStartOfWeek().addDays(10);
    Time endOfDay       = Time.newInstance(23, 59, 59, 0);
    DateTime nextWednesdayDT = DateTime.newInstance(nextWednesday, endOfDay);
    
    for(Contact c : approversToUpdate)
        setApproveURL(c);
    system.debug('*** ' + approversToUpdate);
    update approversToUpdate;
    
    Contact setApproveURL(Contact con) {
        String salt1 = String.valueOf(Crypto.getRandomLong() * Crypto.getRandomLong());
        String salt2 = Datetime.now().addDays(Crypto.getRandomInteger()).format('yyyyMMddHHmmssSSS');
        Blob hashValue = Crypto.generateDigest('SHA-512', Blob.valueOf(con.Id + salt1 + salt2));
        //system.debug('**********  ******BEF ' + con.tc9_ti__Link_Token__c);
        if(!defaultSite.isEmpty())
            con.tc9_ti__Link_Token__c = defaultSite.get(0).tc9_ti__Site_URL__c + '/apex/tc9_ti__ApproveTimesheet?v='+EncodingUtil.urlEncode ( EncodingUtil.base64Encode(hashValue), 'UTF-8');
        else
            con.tc9_ti__Link_Token__c = 'http://tctest-premierstaffing.cs16.force.com/ClientPortal/apex/tc9_ti__ApproveTimesheet?v='+EncodingUtil.urlEncode ( EncodingUtil.base64Encode(hashValue), 'UTF-8');
        con.tc9_ti__Link_Token_Expiry__c = nextWednesdayDT;
        return con;
    }
    
}