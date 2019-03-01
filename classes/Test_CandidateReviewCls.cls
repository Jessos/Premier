@Istest
Public class Test_CandidateReviewCls{
@IsTest(SeeAllData = true) 
    static  void CandidateReviewCls(){  
     ID Foldid ;
     Id Templateid;
      PageReference PageRef = Page.CandidateReview;
      Account testAccount = new Account(Name = 'TestAccount');
      insert testAccount;
    
      Contact contct = new Contact(AccountId=testAccount.id,LastName='last',email='ab@gmail.com');
      insert contct ;
      Contact newcontct = new Contact(AccountId=testAccount.id,LastName='lastname',email='bc@gmail.com');
      insert newcontct ;
      Contact newctct= new Contact(AccountId=testAccount.id,LastName='namelast',email='cd@gmail.com');
      insert newctct;
      ts2__Job__c jobor = new ts2__Job__c(Name = 'job',ts2__Contact__c =contct .id);
        
        Integer times = 0;
        Integer maxtimes = 10;
        do{
            System.debug(jobor);
            try{
                //insert jobor;
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
        
     // ts2__Application__c appli = new ts2__Application__c(ts2__Candidate_Contact__c = contct.id,ts2__Job__c=jobor.id);  
       //insert appli ;
      //  ts2__Application__c appli1 = new ts2__Application__c(ts2__Candidate_Contact__c = newcontct.id,ts2__Job__c=jobor.id);  
      // insert appli1 ;
      // ApexPages.CurrentPage().getParameters().put('id',appli.id);
      // Attachment att = new Attachment(Name='newatt',Body=blob.valueof('text'),ParentId=appli.id);
      //  insert att ;
      //   System.assertEquals(att.name,'newatt');
      
       List<Folder> FolderList = new List<Folder>();
       List<EmailTemplate> SelectedTemplateList = new List<EmailTemplate>();
       
     
       
      // EmailTemplate newtemp = new EmailTemplate (Subject='mysub',body='mybody',Name='mytemplate',Description ='mydesp',FolderId = Foldid  );
       //insert newtemp ;
      FolderList = [select Id,Name from Folder where Type = 'Email' AND name= 'All' order by Name limit 1];
      for(Folder  fd :FolderList){
        Foldid  = fd.id;
      }
      
    
        SelectedTemplateList=[select Id,Subject,body,Name,HtmlValue,TemplateType,Description from EmailTemplate where (FolderId = :Foldid AND IsActive  = :true) limit 1];
       for(EmailTemplate  fd :SelectedTemplateList){
         Templateid = fd.id;
      }
      
        Task Newtask = new Task(ActivityDate = system.today(),Subject='Application Sent For Review',WhatId = jobor.id,Status= 'Completed',WhoId = contct.id);
         insert Newtask ;

       CandidateReviewCls dummydata = new CandidateReviewCls();   
       // Apexpages.currentPage().getParameters().put('SApps',appli.id+'~'+appli1.id);
       // dummydata.appnn = appli;
      //  dummydata.appnn =  new ts2__Application__c(ts2__Candidate_Contact__c = contct.id,ts2__Job__c=jobor.id);  
        dummydata.cntct = contct ;
     //   dummydata.appnn.ts2__Candidate_Contact__c = contct.id;
        dummydata.cntct.ownerId = newctct.id;
        dummydata.SelectedEmailFolder = Foldid  ;
        dummydata.SelectedEmailTemplate = Templateid ;
        dummydata.AdditionalTo = 'ac@gmail.com,ab@gmail.com';
        dummydata.BCCMail = 'a@gmail.com';
        dummydata.actionclass();
        //dummydata.appnn = appli;
        dummydata.appnn.ts2__Candidate_Contact__c = contct.id;
        dummydata.getEmailFoldersList();
        dummydata.ChangeEmailFolderAction();
        dummydata.getEmailTemplates();
        dummydata.SelectTemplateAction();
        dummydata.SelectTemplateAction();
        try{
      //  system.assertequals(appli.ts2__Candidate_Contact__c ,null);
          dummydata.send();
         
         }
        catch(Exception e){
         }                
        }
    }