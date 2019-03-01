global class UpdatePlacementBatch implements Database.Batchable<sObject>{

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator('select ts2__Filled_By__c, ts2__Job__r.ts2__Recruiter__c from ts2__Placement__c');
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
      for(Sobject s : scope){
         ts2__Placement__c obj = (ts2__Placement__c)s;
         if(obj.ts2__Filled_By__c!=obj.ts2__Job__r.ts2__Recruiter__c)
         {
            obj.ts2__Filled_By__c = obj.ts2__Job__r.ts2__Recruiter__c;
         }
      }
      update scope;
   }

   global void finish(Database.BatchableContext BC){

   }
   
   private static testMethod void testBatch()
   {
      
      ToC9_TestDataDump data = new ToC9_TestDataDump();
      tc9_ti__TaxID__c tax = data.getTaxID();
      tc9_ti__Market__c market =  data.getMarket(tax.id);
   
      ts2__Job__c job = new ts2__Job__c();
        Account acc = data.getAClientAccount(market.id);
      job.ts2__Recruiter__c = UserInfo.getUserId();
      job.ts2__Department__c = 'Sales';
      job.ts2__Account__c  = acc.Id;
      
      job.Name = 'SF Dev';
      insert job;
      
      Contact c = new Contact(LastName='Test',State__c = 'AL');
      insert c;
       acc.AP_Email__c ='test1@ddd.com';
       
        RecordType rt = [select id,Name from RecordType where SobjectType='ts2__Placement__c' and Name='Perm' Limit 1];
        
      ts2__Placement__c obj = new ts2__Placement__c();
      obj.recordtypeid = rt.id;
      obj.ts2__Client__c  = acc.Id;
      obj.ts2__Job__c = job.Id;
      obj.ts2__Accounts_Payable__c = c.Id;
      obj.ts2__Employee__c = c.id;
      //insert obj;
      
      Database.executeBatch(new UpdatePlacementBatch());
   }

}