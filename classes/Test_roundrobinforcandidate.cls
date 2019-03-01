@istest
public class Test_roundrobinforcandidate{
//@istest(seealldata=true)
@istest
static void fun_round(){
contact dummycontact=new contact(lastname='dummyname',Categories__c='Admin',Division__c='Admin');
insert dummycontact;
update dummycontact;



  ts2__Job__c jobor = new ts2__Job__c(Name = 'job',ts2__Contact__c =dummycontact.id,ts2__Department__c = 'San Francisco Administrative');
      jobor.ts2__Min_Pay_Rate__c   = 20000;
      jobor.ts2__Max_Pay_Rate__c   = 20;
      jobor.ts2__Max_Bill_Rate__c   = 3000;
      jobor.ts2__Markup_Pct__c     = 0;

      //insert jobor ;

   ts2__Job__c jobor1 = new ts2__Job__c(Name = 'job',ts2__Contact__c =dummycontact.id,ts2__Department__c = 'San Francisco Sales');
      jobor1.ts2__Min_Pay_Rate__c   = 100;
      jobor1.ts2__Max_Pay_Rate__c   = 20;
      jobor.ts2__Max_Bill_Rate__c   = 3000;
      jobor1.ts2__Markup_Pct__c     = 0;
      jobor1.ts2__Min_Bill_Rate__c = 4000;

      //insert jobor1;

       ts2__Job__c jobor2 = new ts2__Job__c(Name = 'job',ts2__Contact__c =dummycontact.id,ts2__Department__c = 'San Francisco Administrative');
      jobor2.ts2__Min_Pay_Rate__c   = 10;
      jobor2.ts2__Max_Pay_Rate__c   = 0;
      jobor2.ts2__Max_Bill_Rate__c   = 3000;
      jobor2.ts2__Markup_Pct__c     = 0;

      //insert jobor2;

      List<ts2__Job__c> jobOrders = new List<ts2__Job__c>();

      jobOrders.add(jobor);

      jobOrders.add(jobor1);

      jobOrders.add(jobor2);

      insert jobOrders;
      
      
      List<String> Departemntlist = new List<String>();
      Departemntlist.add('Finance');
      Departemntlist.add('East Bay Sales');
      
      
       list<User> UserList  =    [SELECT id, name, Department,Last_Assign_Date__c FROM User 
                  where ((Department ='San Francisco Administrative') /*OR (Department ='East Bay Administrative') OR (Department ='East Bay Contract/Temp')*/)  
                  and Available_for_Round_Robin_Assignment__c=True
                  and isActive = true];

      if(UserList.size() > 0) {

        UserList[0].Available_for_Round_Robin_Assignment__c=true;
        update UserList;

      }

        
      list<User> UserList1  =    [SELECT id, name, Department,Last_Assign_Date__c FROM User 
                  where ((Department ='San Francisco Sales') )  
                  and Available_for_Round_Robin_Assignment__c=false
                  and isActive = true];

      if(UserList1.size() > 0) {
                   
        UserList1[0].Available_for_Round_Robin_Assignment__c=true;
        update UserList1;

      }
       
       list<User> UserList2  =    [SELECT id, name, Department,Last_Assign_Date__c FROM User 
                  where ((Department ='San Francisco Administrative'))  
                  and Available_for_Round_Robin_Assignment__c=false
                  and isActive = true];

      if(UserList2.size() > 0) {

        UserList2[0].Available_for_Round_Robin_Assignment__c=true;
        update UserList2;

      }

      List<ts2__Application__c> applications = new List<ts2__Application__c>();
      
 ts2__Application__c appli = new ts2__Application__c(ts2__Candidate_Contact__c = dummycontact.id,ts2__Job__c=jobOrders[0].id);  
 //insert appli ;

 
 
 ts2__Application__c appli1 = new ts2__Application__c(ts2__Candidate_Contact__c = dummycontact.id,ts2__Job__c=jobOrders[1].id);  
 //insert appli1 ;

 
 
 ts2__Application__c appli11 = new ts2__Application__c(ts2__Candidate_Contact__c = dummycontact.id,ts2__Job__c=jobOrders[2].id);  
 //insert appli11 ;

applications.add(appli);

applications.add(appli1);

applications.add(appli11);

insert applications;

 list<ts2__Application__c>dummylist=[select id from ts2__Application__c where id=:appli.id];
   TriggerUtil.AssignManagerToCandidate(dummylist);
  
    TriggerUtil.updateMarkup(jobor);
     TriggerUtil.updateMarkup(jobor1);
    TriggerUtil.calcRate(jobor,true);
    TriggerUtil.calcRate(jobor1,true);
    TriggerUtil.calcMarkup(5000.00,2000.00);
 // TriggerUtil.sendNewApplicationEmails(dummylist);
    TriggerUtil.GetUserList(Departemntlist );
}
}