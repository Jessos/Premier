@isTest
private class TestJobAllTriggers {

   static testMethod void myUnitTest() {
      Test.startTest();
      
      List<ts2__Job__c> jobList = new List<ts2__Job__c>();
      
      ts2__Job__c job            = new ts2__Job__c();
      job.Name                   = 'Administrative Name';
      job.ts2__Department__c     = 'Administrative';
      job.ts2__Min_Pay_Rate__c   = 20;
      job.ts2__Max_Pay_Rate__c   = 30;
      job.ts2__Markup_Pct__c     = 50;
      
      jobList.add(job);
      
      ts2__Job__c job2           = new ts2__Job__c();
      job2.Name                  = 'Administrative Name';
      job2.ts2__Department__c    = 'Administrative';
      job2.ts2__Min_Pay_Rate__c  = 20;
      job2.ts2__Min_Bill_Rate__c  = 30;
      job2.ts2__Max_Pay_Rate__c  = 30;
      
      jobList.add(job2);
      
      ts2__Job__c job3           = new ts2__Job__c();
      job3.Name                  = 'Administrative Name';
      job3.ts2__Department__c    = 'Administrative';
      job3.ts2__Min_Pay_Rate__c  = 20;
      job3.ts2__Max_Pay_Rate__c  = 30;
      job3.ts2__Max_Bill_Rate__c  = 45;
      
      jobList.add(job3);
      
      insert jobList;
      
      Test.stopTest();
   }
}