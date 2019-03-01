global class ScheduleAutoUpdateStatus implements Schedulable {
global String Query;
global date num=Date.Today();
  global date finaldate=num.addDays(-120);
     global void execute(SchedulableContext SC) { 
       //  Query ='select id, ts2__People_Status__c, Employment_Status__c, LastActivityDate from contact Limit 1 ';
         Query ='select id, ts2__People_Status__c from contact where LastActivityDate <=:finaldate AND Employment_Status__c <> \'On Premier Assignment\' AND ts2__People_Status__c <> \'Inactive\' Limit 10000';
        
         AutoUpdateStatus b = new AutoUpdateStatus (Query);
        
          ID Batchprocessid = Database.executeBatch(b,100);
          
        
         
     } 
     }