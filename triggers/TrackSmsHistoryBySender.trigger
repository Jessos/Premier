trigger TrackSmsHistoryBySender on smagicinteract__smsMagic__c (after insert) {


    List<MobileAndUserMapObject__c> objList = new List<MobileAndUserMapObject__c>();
    List<MobileAndUserMapObject__c> updateList = new List<MobileAndUserMapObject__c>();
    for(smagicinteract__smsMagic__c smsObj : trigger.new){
        
        String query = IncomingTriggerHelper.getSearchQuery(smsObj.smagicinteract__PhoneNumber__c);
        
        List<String> sList = query.split('OR');
        
        List<MobileAndUserMapObject__c> userList= [Select Id,User__c from MobileAndUserMapObject__c where Mobile_Number__c =: sList[0].trim() OR Mobile_Number__c = : sList[1].trim()];
        String mobileNo1 =  smsObj.smagicinteract__PhoneNumber__c;
        mobileNo1 = mobileNo1.replaceAll('[^A-Za-z0-9]', '');
     
        If(userList.size() == 0){
            MobileAndUserMapObject__c obj = new MobileAndUserMapObject__c();
            obj.Mobile_Number__c = mobileNo1;
            obj.User__c = smsObj.CreatedById;
            objList.add(obj);
        }else{
            userList[0].User__c = smsObj.CreatedById;
            updateList.add(userList[0]);
        }
        
    }

    if(objList!=null && objList.size() > 0)
        insert objList;
    if(updateList!=null && updateList.size() > 0)
        update updateList;
    
}