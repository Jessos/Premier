trigger SendEmailOnIncoming on smagicinteract__Incoming_SMS__c (before insert) {

    List<smagicinteract__Incoming_SMS__c> incmgSMSList = trigger.new;
    set<Id> incomingIdsSet = new set<Id>();
    
    Map<String, smagicinteract__Incoming_SMS__c> searchQueryAndIncomingMap = new Map<String, smagicinteract__Incoming_SMS__c>();
    Map<String,String> s = new Map<String,String>();
    
    Map<String,List<User>> searchQueryAndResultSetMap = new Map<String,List<User>>();
    
    for(smagicinteract__Incoming_SMS__c incmgSMS :incmgSMSList){
        
        String searchQuery = IncomingTriggerHelper.getSearchQuery(incmgSMS.smagicinteract__Mobile_Number__c);
        List<User> sList = IncomingTriggerHelper.getResultSet(searchQuery);
        searchQueryAndResultSetMap.put(searchQuery,sList);
        searchQueryAndIncomingMap.put(searchQuery,incmgSMS);
        
     }
     
     for(String query : searchQueryAndIncomingMap.keyset()){
        
        smagicinteract__Incoming_SMS__c incmObj = searchQueryAndIncomingMap.get(query);
        String smsText = incmObj.smagicinteract__SMS_Text__c;
        String incmgNumber = incmObj.smagicinteract__Mobile_Number__c;
        String emailId;
        List<User> resultList = searchQueryAndResultSetMap.get(query);
        if(resultList.size()>0){
            system.debug(logginglevel.info,'Came in if');
            incmObj.User__c = resultList[0].Id;
            emailId = resultList[0].Email;
                
        }else{
           
            
           /**
            Commented this out and added email id of Nicolas as per request.
            
            profile adminProfile = [select id from profile where name='System Administrator'];
            User adminUser = [select id,Email from User where profileId =: adminProfile.Id and IsActive = true limit 1];
            incmObj.User__c = adminUser.Id;
            
           */
           
            emailId = 'NicoW@pstaffing.com';
              
        }
        
        IncomingTriggerHelper.sendEmail(emailId,smsText,incmgNumber);
     }
    
}