global class UpdateSubmittalBatch implements Database.Batchable<sObject>{

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator('select ts2__PrimaryRecruiter__c, ts2__Job__r.ts2__Recruiter__c from ts2__Submittal__c');
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
      for(Sobject s : scope){
         ts2__Submittal__c obj = (ts2__Submittal__c)s;
         if(obj.ts2__PrimaryRecruiter__c!=obj.ts2__Job__r.ts2__Recruiter__c)
         {
            obj.ts2__PrimaryRecruiter__c = obj.ts2__Job__r.ts2__Recruiter__c;
         }
      }
      update scope;
   }

   global void finish(Database.BatchableContext BC){

   }
   
   private static testMethod void testBatch()
   {
      
      ts2__Job__c job = new ts2__Job__c();
      job.ts2__Recruiter__c = UserInfo.getUserId();
      job.ts2__Department__c = 'Sales';
      job.Name = 'SF Dev';
      insert job;
      
      Contact c = new Contact(LastName='Test');
      insert c;
      
      ts2__Submittal__c obj = new ts2__Submittal__c();
      obj.ts2__Job__c = job.Id;
      obj.ts2__Candidate__c = c.Id;
      insert obj;
      
      Database.executeBatch(new UpdateSubmittalBatch());
   }

}