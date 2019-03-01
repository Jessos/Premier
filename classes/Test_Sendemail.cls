@Istest
Public class Test_Sendemail {
@IsTest(SeeAllData = true) 
    static  void Sendemail(){
      Account testAccount = new Account(Name = 'TestAccount');
      insert testAccount;
      Contact contct = new Contact(AccountId=testAccount.id,LastName='last',email='ab@gmail.com');
      insert contct ;
       ts2__Job__c jobor = new ts2__Job__c(Name = 'job',ts2__Contact__c =contct.id);

        Integer times = 0;
        Integer maxtimes = 10;
        do{
            System.debug(jobor);
            try{
               // insert jobor;
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
      
        ts2__Application__c sendemail = new ts2__Application__c (Send_Email__c = true,ts2__Candidate_Contact__c=contct .id,ts2__Job__c=jobor.id);
      //insert  sendemail ;
     // update sendemail;
    // Sendemail dummydata = new Sendemail ();
       
        ApexPages.StandardController sc = new ApexPages.StandardController(sendemail );
        Sendemail  send = new Sendemail(sc);
         send.SendEmail();
      }
     }