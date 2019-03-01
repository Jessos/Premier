global class AutoUpdateStatus implements Database.Batchable<sObject>{
  //variable declaration....
  
    global final String Query, query1;
    global list<contact> contactlist =new list<contact>();  
    global date num=Date.Today();
   global date finaldate=num.addDays(-120);

    global Database.QueryLocator start(Database.BatchableContext bc){
       return Database.getQueryLocator(Query);
    }
     global AutoUpdateStatus (String q){
        Query = q;   
    }
    
   global void execute(Database.BatchableContext BC, List<Contact> scope){  
               
    //    contactlist=[select id, ts2__People_Status__c from contact where LastActivityDate<=:finaldate AND Employment_Status__c <> 'On Premier Assignment' AND ts2__People_Status__c <> 'Inactive' Limit 10000];
     system.debug('==========scope.size()================='+scope.size());
     system.debug('=============scope================'+scope);
        if(scope.size()<>0 && scope <> Null){
            for(contact con: scope){                   
                con.ts2__People_Status__c='Inactive';                                        
            }
       }
  
          try{        
              update scope;
          }
          catch(Exception e){
          
          }
      }
      
     global void finish(Database.BatchableContext BC){
        system.debug('Apex Job is Done');
       }
        
 }