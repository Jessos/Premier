@isTest
public class ApplicationTriggerTest{
@isTest(seealldata = true)
        static void myUnitTest() {
        Test.startTest();
        List<User> userlist = new List<User>();
        set<Id> NewUserId = new Set<Id>();
        List<ts2__Application__c> ApplicationList = new List<ts2__Application__c>();
        
        Contact dummyCntct = new Contact(lastname ='lastanmemy');
        insert dummyCntct ;
       // userlist  = [select id,name,UserRoleId,ProfileId from user where UserRoleId =: system.label.CandidatesCustomerUserId AND ProfileId =:system.label.Jobseeker_Portal_ProfileId];
           // ts2__Job__c dummyjob = new ts2__Job__c(Name = 'Administrative Name', ts2__Contact__c = dummyCntct.id, ts2__Department__c = 'Administrative');

        Integer times = 0;
        Integer maxtimes = 10;
        do{
           // System.debug(dummyjob);
            try{
               // insert dummyjob;
               // if(dummyjob.id != null)
                   // break;
            }
            catch(Exception ex)
            {
                System.debug('Error \''+ ex.getMessage() +'\' occured in line \''+ ex.getLineNumber() +'\'. Stack Trace String: \''+ ex.getStackTraceString() +'\'.');
                continue;
            }   
            times++;
        }
        while(times < maxtimes);            

              //  ts2__Application__c DummyApp = new ts2__Application__c(ts2__Candidate_Contact__c = dummyCntct.id,ts2__Job__c = dummyjob.id,ts2__Internally_Applied__c = false);
              //  insert DummyApp ;
                //  ApplicationList.add(DummyApp);
                TriggerUtil.AssignManagerToCandidate(ApplicationList);
  

          Test.stopTest();
        }
         
}

/*@isTest
private class ApplicationTriggerTest{

    static testMethod void myUnitTest() {
        Test.startTest();
        
        List<ts2__Job__c> jobList = new List<ts2__Job__c>();
        ts2__Job__c jobitem = new ts2__Job__c();
         jobitem.Name = 'Administrative Name';
        jobitem.ts2__Department__c = 'Administrative';
        jobList.add(jobitem);
            
        jobitem = new ts2__Job__c();
        jobitem.Name = 'Sales Name';
        jobitem.ts2__Department__c = 'Sales';
        jobList.add(jobitem);
        
        jobitem = new ts2__Job__c();
        jobitem.Name = 'Technology Name';
        jobitem.ts2__Department__c = 'Technology';
        
        jobList.add(jobitem);jobitem = new ts2__Job__c();
        jobitem.Name = 'Temporary Name';
        jobitem.ts2__Department__c = 'Temporary';
        jobList.add(jobitem);
        insert jobList;
        
        //create user 
        List<User> updateList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        for(ts2__Job__c jobItemTmp:jobList )
        {
            User item = new User();
            item.CommunityNickname = 'Name ' +  jobItemTmp.ts2__Department__c;
            item.Department = jobItemTmp.ts2__Department__c;
            
            system.debug('jobItemTmp.ts2__Department__c=' + jobItemTmp.ts2__Department__c);
            
            item.Username = 'Username@' + jobItemTmp.ts2__Department__c + '.com';
         item.LastName =  'LastName' + jobItemTmp.ts2__Department__c;
         item.Email = 'Email@'+ jobItemTmp.ts2__Department__c + '.com';
         item.Alias =  'Alias';
         item.TimeZoneSidKey = 'America/Los_Angeles';
         item.LocaleSidKey ='en_US'; 
         item.EmailEncodingKey = 'ISO-8859-1';
         item.ProfileId = p.id;
         item.LanguageLocaleKey = 'en_US';
            updateList.add(item);
        }
        insert updateList;
        
        List<Contact> ctList = new List<Contact>();
        Contact c = new Contact (LastName = 'Test Contact 1');
         ctList.add(c);
        
         c = new Contact (LastName = 'Test Contact 2');
         ctList.add(c);
        
         c = new Contact (LastName = 'Test Contact 3');
         ctList.add(c);
        
         c = new Contact (LastName = 'Test Contact 4');
         ctList.add(c);        
        insert ctList;
        
        List<ts2__Application__c> appList = new List<ts2__Application__c>();
        ts2__Application__c appItem =new ts2__Application__c();
        appItem.ts2__Job__c = jobList[0].id;
        appItem.ts2__Candidate_Contact__c  = ctList[0].id;
        appList.add(appItem);
        
        appItem =new ts2__Application__c();
        appItem.ts2__Job__c = jobList[1].id;
        appItem.ts2__Candidate_Contact__c  = ctList[1].id;
        appList.add(appItem);
        
        appItem =new ts2__Application__c();
        appItem.ts2__Job__c = jobList[2].id;
        appItem.ts2__Candidate_Contact__c  = ctList[2].id;
        appList.add(appItem);
        
        appItem =new ts2__Application__c();
        appItem.ts2__Job__c = jobList[3].id;
        appItem.ts2__Candidate_Contact__c  = ctList[3].id;
        appList.add(appItem);
        
        insert appList;
        TriggerUtil.AssignManagerToCandidate(appList);
        
        Test.stopTest();
    }
}*/