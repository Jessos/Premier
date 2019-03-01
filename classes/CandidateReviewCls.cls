public with sharing class CandidateReviewCls{
  public id Jobset;
  public string JobContactname;
  public string JobContactFullname;
  public string JobAccount;
  public String JObtitle{get;set;}
  public string EmailContact;
  public String CandidateName;    
  public boolean Completed{get;set;}
  public List<Attachment> AttachmentList{get;set;}
  transient List<Attachment> InsertAttachmentList{get;set;}
  public ts2__Application__c appnn{get;set;}
  public Contact cntct{get;set;}
  public Contact BCCCntct{get;set;}
  public Group Grp{get;set;}
  public string AdditionalTo{get;set;}
  public string BCCMail{get;set;}
  public boolean AllowEmailEdit{get;set;}
  public id IsSelected{get;set;}
  public string EmailSubject{get;set;}
  public string EmailBody{get;set;}
  public boolean showvf{get;set;}
  public boolean HtmlView{get;set;}
  String[] emailarray = new String[]{};
  public List<Attachment> NewAttachment {get;set;}
  public static String Var01 {get;set;} 
  public boolean LimitAttachment{get;set;}
  public id SelectedEmailFolder{get;set;}
  public id SelectedEmailTemplate{get;set;}
  public List<EmailTemplate > SelectedTemplateList = new List<EmailTemplate>();
  public List<Task> taskList = new List<Task>();
  public List<Folder> FolderList = new List<Folder>();
  public List<EmailTemplate > EmailTemplateList= new List<EmailTemplate>();
  public list<ts2__Application__c> applist{get;set;}
  public list<ts2__Submittal__c> SubMittalList = new  list<ts2__Submittal__c>();
  public list<ts2__Job__c> joblist = new list<ts2__Job__c>();
  public set<string> AppSet = new set<string>();
  public set<string> SubMittalSet = new set<string>();
  public set<string> EmailIdset =new set<string>();
  public list<SelectedApplicant__c> jobapplicantlist = new list<SelectedApplicant__c>();
  public set<string> allGroupIDs = new set<string>();
  public set<string> roleRelatedGroupIds = new set<string>();
  public set<string> allMembersIDs = new set<string>();
  public set<String> Attachmentset = new set<String>();
  public String htmlBody;
  public String plainBody;
  String[] CcMail = new String[]{};
  String[] BCCArray= new String[]{};

  public CandidateReviewCls() {}
     
  public void actionclass()
  {
    emailbody = '';
    JobContactname = '';
    JobContactFullname = '';
    NewAttachment = new List<Attachment>();
    applist = new list<ts2__Application__c>();
    showvf = false;

    Var01 = Apexpages.currentPage().getParameters().get('SApps');
    system.debug('Var01.................'+Var01);
    if(Var01 <> null)
    {
      for(string s: Var01.Split('~'))
      {
        s= s.deleteWhitespace();
        if(s <> null && s <> '')
        {
          SubMittalSet.add(s);
        }
      }
    }

    Completed = false;
    appnn = new ts2__Application__c();
    cntct= new Contact ();
    BCCCntct= new Contact();
    Grp = new Group();
    set<id> ParentSet = new set<id>();
    AllowEmailEdit = true; 
    SubMittalList  = [Select id,name,ts2__Job__c,ts2__Job__r.Name,ts2__Related_Application__c,ts2__Candidate__c,ts2__Candidate__r.name from ts2__Submittal__c where id In: SubMittalSet];
    for(ts2__Submittal__c sub : SubMittalList)
    {
      if(sub.ts2__Related_Application__c <> null || sub.ts2__Related_Application__c <> '')
      {
        AppSet.add(sub.ts2__Related_Application__c); 
      }
    
      Jobset = sub.ts2__Job__c;
      JObtitle =  sub.ts2__Job__r.Name;
    }

    system.debug('Jobset.............'+Jobset);
    joblist = [select id,name,ts2__Contact__c from ts2__Job__c where id =:Jobset];
    system.debug('joblist .............'+joblist);
    for(ts2__Job__c  ap : joblist)
    {
      appnn.ts2__Candidate_Contact__c = ap.ts2__Contact__c;
    }

    BCCCntct.ownerId = UserInfo.getUserId();
    system.debug('JObtitle .............'+JObtitle );
    list<Group> grp = [SELECT id, RelatedId, Type FROM Group where RelatedId= :UserInfo.getUserRoleId()];
    system.debug('grp ...........................'+grp );
    for(Group g : [SELECT id, RelatedId, Type FROM Group where RelatedId= :UserInfo.getUserRoleId()])
    {
      roleRelatedGroupIds.add(g.id);
    }
    
    system.debug('roleRelatedGroupIds..........'+roleRelatedGroupIds);
    List<String> allGroupIDs = new List<String>();
    for (GroupMember gm : [SELECT Id, userOrGroupId,group.id, group.name, group.type FROM GroupMember where (UserOrGroupId IN :roleRelatedGroupIds)])
    {
      allGroupIDs.add(gm.group.id);
      allMembersIDs.add(gm.userOrGroupId);
    }
           
    system.debug('allGroupIDs..........'+allGroupIDs);
    system.debug('allMembersIDs..........'+allMembersIDs);
    applist  = [select ts2__Candidate_Contact__r.name,id,ts2__Job__c,Bio__c,Application_Bill_Rate__c,Salary__c,LinkedIn_Profile2__c from ts2__Application__c where id IN: AppSet];
    system.debug('applist  ...........'+applist); 

    SelectedEmailFolder = system.label.PerFolder;
    ChangeEmailFolderAction();
    SelectedEmailTemplate = system.label.PremierTemplate;

           
    AttachmentList= [SELECT Id,Name,ParentId,CreatedDate,IsPrivate,Parent.Name,parent.type FROM Attachment WHERE ParentId IN :AppSet order by Parent.Name limit 100];
    Map<id,ts2__Application__c> AppMap = new Map<id,ts2__Application__c>(applist);
    if(AttachmentList.size() >= 100)
    {
      LimitAttachment = true;
    }

    for(Attachment  at:AttachmentList)
    {    
      at.Description = AppMap.get(at.ParentId).ts2__Candidate_Contact__r.name;
      at.IsPrivate = true;   
    }   
              
    jobapplicantlist = [Select id,name,Applicants__c from SelectedApplicant__c where name =:'JobOrder'];

    if(jobapplicantlist.isempty() == false)
    {
      for(SelectedApplicant__c jb :jobapplicantlist)
      {
          jb.Applicants__c = Var01;
      }   

      update jobapplicantlist;
    }
    else
    {
      SelectedApplicant__c  selapp = new SelectedApplicant__c();
      selapp.name = 'JobOrder';
      selapp.Applicants__c  = Var01;
      insert selapp;
    }
  }

  public list<ts2__Application__c> getApplicantBios()
  {
    system.debug('applist.......'+applist);
    return applist;
  }
    
     
  public List<SelectOption> getEmailFoldersList()
  {
    FolderList = [select Id,Name from Folder where Type = 'Email' order by Name];
    List<SelectOption> EmailFoldersOptions= new List<SelectOption>();
    integer i;
    string value;
    EmailFoldersOptions.add(new SelectOption('','--None--'));
    for(i=0;i<FolderList.size();i++)
    {
      string str;
      if(FolderList[i].Name <> null)
      { 
        str = string.valueof(FolderList[i].Name);

        value = string.valueof(FolderList[i].id);                           
        EmailFoldersOptions.add(new SelectOption(value,str));
      }
    }

    return EmailFoldersOptions;     
  }
    
  public void ChangeEmailFolderAction()
  {
    EmailTemplateList =[select Id,Name,TemplateType,Description from EmailTemplate where (FolderId = :SelectedEmailFolder and IsActive = true) order by Name];
    EmailSubject = '';
    emailbody ='';
  }
       
  public List<SelectOption> getEmailTemplates()
  {    
    List<SelectOption> TemplateOptions= new List<SelectOption>();
    integer i;
    string value;
    TemplateOptions.add(new SelectOption('','--None--'));
    for(i=0;i<EmailTemplateList.size();i++)
    {
      system.debug('EmailTemplateList[i].....'+EmailTemplateList[i]); 
      string str = string.valueof(EmailTemplateList[i].Name);
      value = string.valueof(EmailTemplateList[i].id);                           
      TemplateOptions.add(new SelectOption(value,str));
    }

    return TemplateOptions;          
  }
       
  public void SelectTemplateAction()
  {
    system.debug('SelectedEmailTemplate............'+SelectedEmailTemplate);
    EmailSubject = '';
    emailbody ='';
    JobContactname ='';
    JobContactFullname = '';
    HtmlView = false;
    SelectedTemplateList=[select Id,Subject,body,Name,markup,HtmlValue,TemplateType,Description from EmailTemplate where (id = :SelectedEmailTemplate)];

    for(Contact cc : [SELECT Id,Name,Email,Firstname  FROM Contact WHERE id =: appnn.ts2__Candidate_Contact__c])
    {
      if(cc.Firstname != null){ 
      	JobContactname = cc.Firstname;
      }
      if(cc.name != null){
      	JobContactFullname = cc.name;
      }
    }
	
    if(SelectedTemplateList.isempty() == false)
    {
      /*if(SelectedTemplateList[0].TemplateType == 'Custom'){
        HtmlView = true;
      }*/
          
      if((SelectedTemplateList[0].TemplateType == 'Custom') && 
         (SelectedTemplateList[0].Name == 'Single Candidate Submittal - DH'))
      {
      
        string ConBody;
        showvf = false;
        //HtmlView = true;
        EmailSubject = SelectedTemplateList[0].Subject;
        EmailBody = SelectedTemplateList[0].htmlValue;
        
        if(EmailBody != null){
	        if(EmailBody.contains('{!Contact.FirstName}')){
	                EmailBody = EmailBody.replace('{!Contact.FirstName}', JobContactname);
	        }
	        if(EmailSubject.contains('{!ts2__Job__c.Name}')){
	                EmailSubject = EmailSubject.replace('{!ts2__Job__c.Name}', Jobtitle);
	        }
     
	        ConBody = EmailBody;
	            for(ts2__Application__c  ap : applist)
	            {
	                  if(ap.Bio__c == null)
	                  {
	                    ap.Bio__c = '';
	                  }
	                  
	                  ConBody = ConBody + '\r\n'+ '<br>\r\n' + '<b>Candidate Name :</b> '+ ap.ts2__Candidate_Contact__r.name + '<br>\r\n' +'<b>Bio : </b>'+ '<br>\r\n'+ ap.Bio__c;
	            }
	         EmailBody = ConBody;
        }    
         
         
      }
      if((SelectedTemplateList[0].TemplateType == 'Custom') && 
         (SelectedTemplateList[0].Name == 'CT - Single Candidate Submittal'))
      {
      
        string ConBody;
        showvf = false;
        //HtmlView = true;
        EmailSubject = SelectedTemplateList[0].Subject;
        EmailBody = SelectedTemplateList[0].htmlValue;
	        if(EmailBody != null){
		        if(EmailBody.contains('{!Contact.FirstName}')){
		                EmailBody = EmailBody.replace('{!Contact.FirstName}', JobContactname);
		        }
	            if(EmailSubject.contains('{!ts2__Job__c.Name}')){
	                EmailSubject = EmailSubject.replace('{!ts2__Job__c.Name}', Jobtitle);
	            }
        
		        ConBody = EmailBody;
		            for(ts2__Application__c  ap : applist)
		            {
		                  if(ap.Bio__c == null)
		                  {
		                    ap.Bio__c = '';
		                  }
		                  
		                  ConBody = ConBody + '\r\n'+ '<br>\r\n' + '<b>Candidate Name :</b> '+ ap.ts2__Candidate_Contact__r.name + '<br>\r\n' +'<b>Bio : </b>'+ '<br>\r\n'+ ap.Bio__c + '<br>' + '<b>Bill Rate : </b>$' + ap.Application_Bill_Rate__c;
		            }
		         EmailBody = ConBody;
	        }
         
      }
      else if((SelectedTemplateList[0].TemplateType == 'Custom') && 
         (SelectedTemplateList[0].Name == 'Confirm Candidate Submittal'))
      {
      
        string ConBody;
        showvf = false;
        //HtmlView = true;
        EmailSubject = SelectedTemplateList[0].Subject;
         EmailBody = SelectedTemplateList[0].htmlValue;
	       if(EmailBody != null){ 
		        if(EmailBody.contains('{!Contact.FirstName}')){
		                EmailBody = EmailBody.replace('{!Contact.FirstName}', JobContactname);
		        }
		        if(EmailSubject.contains('{!ts2__Job__c.Name}')){
		                EmailSubject = EmailSubject.replace('{!ts2__Job__c.Name}', Jobtitle);
		        } 
	        
		        ConBody = EmailBody;
		            for(ts2__Application__c  ap : applist)
		            {
		                  if(ap.Bio__c == null)
		                  {
		                    ap.Bio__c = '';
		                  }
		                  
		                  ConBody = ConBody +'\r\n'+ '<br>\r\n' +'<b>Candidate Name:</b> '+ ap.ts2__Candidate_Contact__r.name + '<br>\r\n' +'<b>Bio:</b> '+ '<br>\r\n'+ ap.Bio__c + '<br>' + '<b>Bill Rate : </b>$' + ap.Application_Bill_Rate__c;
		            }
		         EmailBody = ConBody;
	       }
         
      }
      else if((SelectedTemplateList[0].TemplateType == 'custom') && 
      (SelectedTemplateList[0].Name == 'CT - Panel Candidate Submittal')){
            string ConBody;
            showvf = false;
            //HtmlView = true;
            EmailSubject = SelectedTemplateList[0].Subject;
            EmailBody = SelectedTemplateList[0].htmlValue;
            if(EmailBody != null){
		            if(EmailBody.contains('{!Contact.FirstName}')){
		                EmailBody = EmailBody.replace('{!Contact.FirstName}', JobContactname);
		            }
		            if(EmailSubject.contains('{!ts2__Job__c.Name}')){
		                EmailSubject = EmailSubject.replace('{!ts2__Job__c.Name}', Jobtitle);
		        	}
		            ConBody = EmailBody;
		            for(ts2__Application__c  ap : applist)
		            {
		                  if(ap.Bio__c == null)
		                  {
		                    ap.Bio__c = '';
		                  }
		                  
		                  ConBody = Conbody + '<br><br>\r\n'+ '\r\n' + '<b>Candidate Name :</b> '+ ap.ts2__Candidate_Contact__r.name + '<br>\r\n' +'<b>Bio :</b> '+ '<br>\r\n'+ ap.Bio__c + '<br>' + '<b>Bill Rate : </b>$' + ap.Application_Bill_Rate__c;
		            }
		         EmailBody = ConBody;
            }
         
      }
      else if((SelectedTemplateList[0].TemplateType == 'custom') && 
      		 (SelectedTemplateList[0].Name == 'DH - Panel Candidate Submittal')){
            string ConBody;
            showvf = false;
            //HtmlView = true;
            EmailSubject = SelectedTemplateList[0].Subject;
            EmailBody = SelectedTemplateList[0].htmlValue;
            if(EmailBody != null){
		            if(EmailBody.contains('{!Contact.FirstName}')){
		                EmailBody = EmailBody.replace('{!Contact.FirstName}', JobContactname);
		            }
		            if(EmailSubject.contains('{!ts2__Job__c.Name}')){
		                EmailSubject = EmailSubject.replace('{!ts2__Job__c.Name}', Jobtitle);
			        }
		            ConBody = EmailBody;
		            for(ts2__Application__c  ap : applist)
		            {
		                  if(ap.Bio__c == null)
		                  {
		                    ap.Bio__c = '';
		                  }
		                  if(ap.Salary__c == null)
		                  {
		                    ap.Salary__c = '';
		                  }
		                   
		                  ConBody = Conbody + '<br><br>\r\n'+ '\r\n' + '<b>Candidate Name :</b> '+ ap.ts2__Candidate_Contact__r.name + '<br>\r\n' +'<b>Bio :</b> '+ '<br>\r\n'+ ap.Bio__c + '<br>' + '<b>Salary :</b> ' + ap.Salary__c + '<br>' + '<b>LinkedIn Profile :</b> ' + ap.LinkedIn_Profile2__c;
		            }
		         EmailBody = ConBody;
            }
         
         
      }
            else if((SelectedTemplateList[0].TemplateType == 'custom') && 
      			(SelectedTemplateList[0].Name == 'DH - Single Candidate Submittal')){
	            string ConBody;
	            showvf = false;
	            //HtmlView = true;
	            EmailSubject = SelectedTemplateList[0].Subject;
	            EmailBody = SelectedTemplateList[0].htmlValue;
	            if(EmailBody != null){
		            if(EmailBody.contains('{!Contact.FirstName}')){
		                EmailBody = EmailBody.replace('{!Contact.FirstName}', JobContactname);
		            }
		            if(EmailSubject.contains('{!ts2__Job__c.Name}')){
		                EmailSubject = EmailSubject.replace('{!ts2__Job__c.Name}', Jobtitle);
		        	}
		        	if(EmailSubject.contains('{!tc9_ti__Client_Name__c}')){
		                EmailSubject = EmailSubject.replace('{!tc9_ti__Client_Name__c}', JobAccount);
		        	}
		            ConBody = EmailBody;
		            for(ts2__Application__c  ap : applist)
		            {
		                  if(ap.Bio__c == null)
		                  {
		                    ap.Bio__c = '';
		                  }
		                    if(ap.Salary__c == null)
		                  {
		                    ap.Salary__c = '';
		                  }
		                
		                  ConBody = Conbody + '<br><br>\r\n'+ '\r\n' + '<b>Candidate Name :</b> '+ ap.ts2__Candidate_Contact__r.name + '<br>\r\n' +'<b>Bio :</b> '+ '<br>\r\n'+ ap.Bio__c + '<br>' + '<b>Salary :</b> ' + ap.Salary__c + '<br>' + '<b>LinkedIn Profile :</b> ' + ap.LinkedIn_Profile2__c;
		            }
		         EmailBody = ConBody;
         
	            }
      }
         else if((SelectedTemplateList[0].TemplateType == 'custom') && 
      (SelectedTemplateList[0].Name == 'CT - T-P Panel Candidate Submittal')){
            string ConBody;
            showvf = false;
            //HtmlView = true;
            EmailSubject = SelectedTemplateList[0].Subject;
            EmailBody = SelectedTemplateList[0].htmlValue;
            if(EmailBody != null){
		            if(EmailBody.contains('{!Contact.FirstName}')){
		                EmailBody = EmailBody.replace('{!Contact.FirstName}', JobContactname);
		            }
		            if(EmailSubject.contains('{!ts2__Job__c.Name}')){
		                EmailSubject = EmailSubject.replace('{!ts2__Job__c.Name}', Jobtitle);
		        	}
		            ConBody = EmailBody;
		            for(ts2__Application__c  ap : applist)
		            {
		                  if(ap.Bio__c == null)
		                  {
		                    ap.Bio__c = '';
		                  }
		                  if(ap.Salary__c == null)
		                  {
		                    ap.Salary__c = '';
		                  }
		                  ConBody = Conbody + '<br><br>\r\n'+ '\r\n' + '<b>Candidate Name :</b> '+ ap.ts2__Candidate_Contact__r.name + '<br>\r\n' +'<b>Bio :</b> '+ '<br>\r\n'+ ap.Bio__c + '<br>' + '<b>Bill Rate : </b>$' + ap.Application_Bill_Rate__c +'<br>'+ '<b>Salary :</b> ' + ap.Salary__c;
		            }
		         EmailBody = ConBody;
            }
      }
       else if((SelectedTemplateList[0].TemplateType == 'custom') && 
      (SelectedTemplateList[0].Name == 'CT - T-P Single Candidate Submittal')){
            string ConBody;
            showvf = false;
            //HtmlView = true;
            EmailSubject = SelectedTemplateList[0].Subject;
            EmailBody = SelectedTemplateList[0].htmlValue;
            if(EmailBody != null){
	            if(EmailBody.contains('{!Contact.FirstName}')){
	                EmailBody = EmailBody.replace('{!Contact.FirstName}', JobContactname);
	            }
	            if(EmailSubject.contains('{!ts2__Job__c.Name}')){
	                EmailSubject = EmailSubject.replace('{!ts2__Job__c.Name}', Jobtitle);
	        	}
	            ConBody = EmailBody;
	            for(ts2__Application__c  ap : applist)
	            {
	                  if(ap.Bio__c == null)
	                  {
	                    ap.Bio__c = '';
	                  }
	                  if(ap.Salary__c == null)
	                  {
	                    ap.Salary__c = '';
	                  }
	                  ConBody = Conbody + '<br><br>\r\n'+ '\r\n' + '<b>Candidate Name :</b> '+ ap.ts2__Candidate_Contact__r.name + '<br>\r\n' +'<b>Bio :</b> '+ '<br>\r\n'+ ap.Bio__c + '<br>' + '<b>Bill Rate : </b>$' + ap.Application_Bill_Rate__c +'<br>'+ '<b>Salary :</b> ' + ap.Salary__c;
	            }
	         EmailBody = ConBody;
            }
      }  
            
      // Modified on 30th of Nov
      else if((SelectedTemplateList[0].TemplateType == 'HTML') && 
      (SelectedTemplateList[0].Name == 'Single Candidate Submittal')){
            string ConBody;
            //showvf = false;
            //HtmlView = true;
            EmailSubject = SelectedTemplateList[0].Subject;
            EmailBody = SelectedTemplateList[0].body;
            if(EmailBody != null){
	            if(EmailBody.contains('{!Contact.Name}')){
	                EmailBody = EmailBody.replace('{!Contact.Name}', JobContactFullname);
	            }
	            
	            ConBody = EmailBody;
	            
	            for(ts2__Application__c  ap : applist)
	            {
	                  if(ap.ts2__Candidate_Contact__c != null){
	                      if(ap.Bio__c == null)
	                      {
	                        ap.Bio__c = '';
	                      }
	                      ConBody = ConBody.replace('{!ts2__Application__c.Bio__c}' , ap.Bio__c);
	                      ConBody = ConBody.replace('{!ts2__Application__c.ts2__Candidate_Contact__c}' , ap.ts2__Candidate_Contact__r.name);    
	                      EmailBody = ConBody; 
	                      break;
	                  }
	            }  
            }  
      }
      
      else
      {
        if(SelectedTemplateList[0].TemplateType == 'visualforce'){
            showvf = true;
        }
        else if(SelectedTemplateList[0].TemplateType == 'Custom' || SelectedTemplateList[0].TemplateType == 'HTML'){
            showvf = false;
        }
        EmailSubject = SelectedTemplateList[0].Subject;
        //EmailSubject = JObtitle ;
        if(SelectedTemplateList[0].TemplateType == 'HTML' || SelectedTemplateList[0].TemplateType == 'custom'){
            EmailBody = SelectedTemplateList[0].htmlValue;
        }
        else{
            EmailBody = SelectedTemplateList[0].body;
        }
        /*Just for check*/
        
	        if(EmailBody != null){
		        system.debug('-------EmailBody------'+EmailBody);
		        
		        if(EmailBody.contains('{!Contact.FirstName}')){
		            EmailBody = EmailBody.replace('{!Contact.FirstName}', JobContactname);
		        }
		        if(EmailBody.contains('{!Contact.Name}')){
		            EmailBody = EmailBody.replace('{!Contact.Name}', JobContactFullname);
		        }
		        if(EmailBody.contains('{!Contact.Name}')){
		            EmailBody = EmailBody.replace('{!Contact.Name}', JobContactFullname);
		        }
		        if(EmailBody.contains('{!User.FirstName}') || EmailBody.contains('{!User.LastName}') || EmailBody.contains('{!User.Title}') || EmailBody.contains('{!User.Phone}') || EmailBody.contains('{!User.Email}')){
		            list<user> userInfoList = [select id , FirstName , LastName , Title , Phone , Email from user where id =: UserInfo.getUserId()];
		            EmailBody = EmailBody.replace('{!User.FirstName}', UserInfo.getFirstName());
		            EmailBody = EmailBody.replace('{!User.LastName}' , UserInfo.getLastName());
		            EmailBody = EmailBody.replace('{!User.Email}' , UserInfo.getUserEmail());
		            if(!userInfoList.isEmpty()){
		                if(userInfoList.get(0).Title != null){
		                    EmailBody = EmailBody.replace('{!User.Title}' , userInfoList.get(0).Title);
		                }
		                else{
		                    EmailBody = EmailBody.remove('{!User.Title}');
		                }
		                if(userInfoList.get(0).Phone != null){
		                    EmailBody = EmailBody.replace('{!User.Phone}' , userInfoList.get(0).Phone);
		                }
		                else{
		                    EmailBody = EmailBody.remove('{!User.Phone}');
		                }
		            }
		        }
	      	}
      }

      if(SelectedTemplateList[0].TemplateType == 'HTML' || SelectedTemplateList[0].TemplateType == 'custom'){
        //HtmlView = true;
      }
      system.debug('----SelectedTemplateList[0].htmlValue----'+SelectedTemplateList[0].htmlValue);
      system.debug('----SelectedTemplateList[0].body----'+SelectedTemplateList[0].body);
      system.debug('----HtmlView----'+HtmlView);
      system.debug('----showvf----'+showvf);
      
      /*Working on exception cases*/
      if(EmailBody == null){
      		system.debug('----EmailBody----'+EmailBody);
      		if(SelectedTemplateList[0].htmlValue != null && SelectedTemplateList[0].body == null){
      			EmailBody = SelectedTemplateList[0].htmlValue;
      			//HtmlView = true;
      		}
      		else if(SelectedTemplateList[0].htmlValue == null && SelectedTemplateList[0].body != null){
      			EmailBody = SelectedTemplateList[0].body;
      			//HtmlView = false;
      		}
      }
      system.debug('----EmailBody----'+EmailBody);
      
    }         
  }

  public void send()
  {
    try
    {
      for (Attachment aht: AttachmentList)
      {
        if(aht.IsPrivate == true)
        {
          Attachmentset.add(aht.id);
        }
      }
         
      InsertAttachmentList = [SELECT Id,Name,ParentId,CreatedDate,Parent.Name,body,parent.type FROM Attachment WHERE ParentId IN :AppSet AND id IN:Attachmentset order by Parent.Name ];
      String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
      Pattern MyPattern = Pattern.compile(emailRegex);
      if(AdditionalTo <> null)
      {
        for(string s: AdditionalTo.Split(','))
        {
          s = s.deleteWhitespace();
          if(s <> null && s <> '')
          {
            EmailIdSet.add(s);
          }
        }
      }

      for(string eo : EmailIdSet) 
      {
        Matcher MyMatcher = MyPattern.matcher(eo);
        system.debug('eo ........'+eo );
        if((!MyMatcher.matches()) && (eo  <> null && eo  <> '')) 
        {
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.info,'Invalid E-Mail Address')); 
          return ;
        }
      
        emailarray.add(eo);
      } 

      system.debug('BCCMail ...............'+BCCMail );

      for(Contact cc : [SELECT Id,Name,Email FROM Contact WHERE id =: appnn.ts2__Candidate_Contact__c])
      {
        if(cc.Email <> null || cc.Email <> '')
        {
          EmailContact = cc.Email;
        }
      }

      system.debug('EmailContact ...........'+EmailContact );
      emailarray.add(EmailContact);
      Messaging.reserveSingleEmailCapacity(1);
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      mail.setToAddresses(emailarray);
      system.debug('BCCArray...............'+BCCArray);
      system.debug('BCCArray...............'+BCCArray);
      
      if(cntct.ownerId <> null)
      {
        string CCMailId;

        for(User cm : [SELECT Id,Name,Email FROM user WHERE id =: cntct.ownerId])
        {
          system.debug('cm ...............'+cm);
          if(cm.Email <> null || cm.Email <> '')
          {
            CCMailId = cm.Email;
            system.debug('CCMailId ...............'+CCMailId);
          }
        }

        CcMail.add(CCMailId);
        system.debug('CcMail...............'+CcMail);
      }

      if(BCCCntct.ownerId <> null)
      {
        string BccMailid;
        for(User bmm: [SELECT Id,Name,Email FROM user WHERE id =: BCCCntct.ownerId])
        {
          system.debug('bmm...............'+bmm);
          if(bmm.Email <> null || bmm.Email <> '')
          {
            BccMailid = bmm.Email;
            system.debug('BccMailid...............'+BccMailid);
          }
        }

        BCCArray.add(BccMailid);
        system.debug('BCCArray...............'+BCCArray);
      }

      mail.setBccAddresses(BCCArray);
      mail.setCcAddresses(CcMail);
      mail.setTargetObjectId(appnn.ts2__Candidate_Contact__c);
      mail.setwhatId(Jobset);
      mail.setSaveAsActivity(false);
      mail.setUseSignature(true);
      if(SelectedTemplateList.isempty() == true)
      {
        mail.setHtmlBody(+EmailBody ); 
        mail.setSubject(+EmailSubject);
      }
      else
      { 
        //mail.setPlainTextBody(+EmailBody );
        if(SelectedTemplateList[0].htmlValue == null && SelectedTemplateList[0].body != null){
        	HtmlView = false;
        }
        else{
        	HtmlView = true;
        }
        
        
        
        
        if(HtmlView){
        	system.debug('----EmailBody----'+EmailBody);
            mail.setHtmlBody(+EmailBody);
        } 
        else{
            mail.setPlainTextBody(+EmailBody );
        }
        mail.setSubject(+EmailSubject);
      } 

      List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
      for (Attachment att : InsertAttachmentList)
      {
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(att.name);
        efa.setBody(att.body);
        efaList.add( efa );
      }

      if(AttachmentList.isempty()==false)
      {
        mail.setFileAttachments(efaList);
      }  

      system.debug('mail.............'+mail);
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
      system.debug('SubMittalList .............'+SubMittalList);
      for(ts2__Submittal__c  ap : SubMittalList)
      {
        Task ActivityRow = new Task();
        ActivityRow.ActivityDate = system.today();
        ActivityRow.Subject='Application Sent For Review';
        ActivityRow.Description = 'The Application (https://cs15.salesforce.com/' + ap.ts2__Related_Application__c + ') for ' + ap.ts2__Candidate__r.name  + ' was sent for review on ' + system.today();
        system.debug('Jobset..........'+Jobset);
        ActivityRow.WhatId = Jobset;
        ActivityRow.Status= 'Completed';
        ActivityRow.WhoId = ap.ts2__Candidate__c;
        TaskList.add(ActivityRow);
      }

      // Task for recieptent To Contact
      if(appnn.ts2__Candidate_Contact__c <> null )
      {
        Task ReciptActivity = new Task();
        ReciptActivity.ActivityDate = system.today();
        ReciptActivity.Subject='Review Application';
        ReciptActivity.Description = 'The Application for ' + CandidateName + 'was sent for review by Jobscience Admin.';
        system.debug('Jobset..........'+Jobset);
        ReciptActivity .Status= 'Completed';
        ReciptActivity .WhoId = appnn.ts2__Candidate_Contact__c;
        TaskList.add(ReciptActivity);
      } 

      insert TaskList;
      Completed = true;
    }
    catch(System.DmlException e) 
    {
      for(Integer i = 0; i < e.getNumDml(); i++) 
      {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(i))); 
      }
    }
    finally
    {
      AttachmentList.clear();
    }
  }
}