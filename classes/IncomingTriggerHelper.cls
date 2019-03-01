public with sharing class IncomingTriggerHelper {

    public static String getSearchQuery(String incmgNumber){
        
        String mobileNo = null;
        String mobileNo1 = null;
        List<String> args = new List<String>();
        String searchqueryStr = '';
        mobileNo = incmgNumber;
        mobileNo1 = mobileNo;
        args.add(mobileNo);
        
        if(mobileNo1.length() == 12){
            mobileNo1 = mobileNo.substring(2);
        }
        
        if(mobileNo1.length() == 14){
            mobileNo1 = mobileNo.substring(4);
        }
        
        if(mobileNo1.length() == 11){
            mobileNo1 = mobileNo.substring(1);
        }
        
        args.add(mobileNo1);
                
        if(mobileNo1.length() == 10){
            mobileNo1 = '('+mobileNo1.substring(0, 3)+') '+mobileNo1.substring(3, 6)+'-'+mobileNo1.substring(6, 10);
        }
        
        args.add(mobileNo1);
        searchqueryStr ='{0} OR {1} OR {2}';
        searchqueryStr = String.format(searchqueryStr, args);
        system.debug(logginglevel.info,'searchqueryStr :'+searchqueryStr);
        return searchqueryStr;
    }

    public static List<User> getResultSet(String searchQuery){
        List<String> sList = searchQuery.split('OR');
        
        List<Id> idList = new List<Id>();
        List<User> resultList = new List<User>();
        system.debug(logginglevel.info,'searchQuery :'+searchQuery);
        //List<List<MobileAndUserMapObject__c>> historyList = [FIND :searchQuery IN ALL FIELDS returning MobileAndUserMapObject__c(Id,User__c)];
        List<MobileAndUserMapObject__c> historyList = [select Id,User__c from MobileAndUserMapObject__c where Mobile_Number__c =: sList[0].trim() OR Mobile_Number__c = : sList[1].trim()  order by createdDate desc limit 1];
        if(historyList.size()>0){
        for(MobileAndUserMapObject__c user : historyList){
        idList.add(user.User__c);
        }       
        
        resultList =[ SELECT Id, Name, Email FROM User where Id in : idList];
        }
        return resultList;
        
    }

    public static void sendEmail(String emailId,String smsText,String mobileNumber){
        
            system.debug(logginglevel.info,'emailId :'+emailId);
            emailId = 'adnan@screen-magic.com';
            String[] emailAddrs = null;
            String userId = UserInfo.getUserId();
            String userName = UserInfo.getUserName();
            List<String> args = new List<String>();
            //args.add(recordName);
            args.add(String.valueOf(system.now()));
            args.add(smsText);
            //args.add(recordUrl);
            String emailBody = 'Date Time : {0} \n';
            emailBody += 'Message : {1} \n';

            
            emailBody = String.format(emailBody, args); 
            Messaging.SingleEmailMessage mail = null;   
            Integer sendEmailLimit = Limits.getLimitEmailInvocations();
            Integer currentSendEmailCount = Limits.getEmailInvocations();
            if(currentSendEmailCount == sendEmailLimit)
                return;
            emailAddrs = new String[] {emailId};
            mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(emailAddrs);    
            mail.setSaveAsActivity(false);
            mail.setSenderDisplayName(userName);
            mail.setSubject('New Incoming SMS Message from '+mobileNumber);
            mail.setUseSignature(false);
            mail.setPlainTextBody(emailBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}