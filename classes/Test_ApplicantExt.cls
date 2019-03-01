@Istest
Public class Test_ApplicantExt {
@IsTest(SeeAllData = true) 
    static  void ApplicantExt (){  
    //TMA        
    Test.startTest();
     ID Foldid ;
     Id Templateid;
     list<SelectedApplicant__c> jobapplicantlist = new list<SelectedApplicant__c>();
    
      jobapplicantlist = [select id,name,Applicants__c from SelectedApplicant__c where name = 'JobOrder'];
       for(SelectedApplicant__c slt : jobapplicantlist){
          if(slt.Applicants__c == null){
           slt.Applicants__c = 'ab~bs';
          }
        }
      Account testAccount = new Account(Name = 'TestAccount');
      insert testAccount;
      Contact contct = new Contact(AccountId=testAccount.id,LastName='last',email='ab@gmail.com');
      insert contct ;
      
      ts2__Job__c jobor = new ts2__Job__c(Name = 'job',ts2__Contact__c =contct .id);

        Integer times = 0;
        Integer maxtimes = 10;
        do{
            System.debug(jobor);
            try{
              //  insert jobor;
                if(jobor.id != null)
                    break;
            }
            catch(Exception ex)
            {
                System.debug('Error \''+ ex.getMessage() +'\' occured in line \''+ ex.getLineNumber() +'\'. Stack Trace String: \''+ ex.getStackTraceString() +'\'.');
                continue;
            }   
            times++;
        }
        while(times < maxtimes); 
                
      ts2__Application__c appli = new ts2__Application__c(ts2__Candidate_Contact__c = contct.id,ts2__Job__c=jobor.id);  
       //insert appli ;
      
       ApplicantExt dummydata = new ApplicantExt ();   

        dummydata.getApplicantBios();
    //TMA
    Test.stopTest();
    }
    }