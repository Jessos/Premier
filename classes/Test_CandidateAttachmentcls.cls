@Istest
Public class Test_CandidateAttachmentcls{
@IsTest(SeeAllData = true) 
    static  void CandidateAttachmentcls(){  
        PageReference PageRef = Page.Candidate_Attachments ;
      
      Account testAccount = new Account(Name = 'TestAccount');
      insert testAccount;
    
      Contact contct = new Contact(AccountId=testAccount.id,LastName='last');
      system.assertequals(contct.LastName,'last');
       insert contct ;
       Attachment newatt = new Attachment(Name='newatt',Body=blob.valueof('text'),ParentId=contct.id);
        insert newatt ;
     
      ts2__Job__c jobor = new ts2__Job__c(Name = 'job',tc9_ti__Bill_To_Contact__c=contct .id);

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
        
        
      ts2__Application__c appli = new ts2__Application__c(ts2__Candidate_Contact__c = contct .id,ts2__Job__c=jobor.id);  
      // insert appli ;
       
       ApexPages.CurrentPage().getParameters().put('id',appli .id);
       
      List<Attachment> Attachlist = new List<Attachment>();
      Attachlist = [Select id,name,parentid,body from Attachment where id = :newatt.id];
      for(Attachment at : Attachlist){
        Attachment att = new Attachment();
            att.Name=at.name;
            att.Body=at.body;
           // att.ParentId=appli.id;
           // insert att ;
      }
      
       //Attachment att = new Attachment(Name='newatt',Body=blob.valueof('text'),ParentId=appli.id);
       // insert att ;
        
       CandidateAttachmentcls dummydata = new CandidateAttachmentcls();    
         dummydata.getAttachmentRec();
         dummydata.Save();
 
        }
    }