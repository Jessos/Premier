trigger JobAllTriggers on ts2__Job__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

  // boolean triggersEnabled = Trigger_Settings__c.getInstance().Triggers_Enabled__c;
   
   //if(triggersEnabled){
   
      if(trigger.isBefore)
      {
          if(trigger.isUpdate || trigger.isInsert){
             //Case 925: Set primary recruiter
             for(ts2__Job__c job : trigger.new){
                 if(job.ts2__Recruiter__c == null){
                     job.ts2__Recruiter__c = userInfo.getUserId();
                 }
             }
            
            //Case 926 : Auto Calculate markup
            for(integer i = 0; i < trigger.new.size(); i++)
            {
               TriggerUtil.updateMarkup(trigger.new[i]);
            }
            
         }
      }
      
      //Create Chatter updates
      /*
      //Get all mappings
      Map<string, Job_Chatter_Updates_Settings__c> groupMappings = Job_Chatter_Updates_Settings__c.getAll();
      
      //Set of group names
      set<string> groupNames = new set<string>();
      for(Job_Chatter_Updates_Settings__c s : groupMappings.values()){
         groupNames.add(s.Chatter_Group_Name__c);
      }
      
      //Get those groups
      List<CollaborationGroup> chatterGroups = [SELECT Id, Name FROM CollaborationGroup WHERE Name IN :groupNames];
      Map<string,CollaborationGroup> chatterGroupsMap = new Map<string,CollaborationGroup>();
      for(CollaborationGroup c : chatterGroups){
         chatterGroupsMap.put(c.Name, c);
      }
      
      //Create mapping - Department Name, Chatter Group
      Map<string,Id> departmentGroupsMap = new Map<string,Id>();
      for(Job_Chatter_Updates_Settings__c s : groupMappings.values()){
         CollaborationGroup cg = chatterGroupsMap.get(s.Chatter_Group_Name__c);
         if(cg != null){
            departmentGroupsMap.put(s.Name, cg.Id);
         }
      }
      
      //Create new posts
      List<FeedItem> newFeeds = new List<FeedItem>();
      if(trigger.isInsert){
         for(ts2__Job__c job : trigger.new){
            String department = job.ts2__Department__c; 
            if(department != null){
               CollaborationGroup cg = chatterGroupsMap.get(department);
               if(cg != null){
                  FeedItem fi = new FeedItem(Body = 'New Job Order has been created.',
                                                ParentId = cg.Id,
                                          LinkUrl = '/' + job.Id,
                                             Title = job.Name,
                                             Type = 'LinkPost');
                  newFeeds.add(fi);                            
               }
            }
         }
      }
      insert newFeeds;
      */
   //}
   
}