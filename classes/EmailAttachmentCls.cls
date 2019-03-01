public with sharing class EmailAttachmentCls{
    public id JobOrderId;
    public string AppCandidate;
    public string ToContact;
    public string AppBio;
    public id templateId{get;set;}
    public boolean Completed{get;set;}
    public List<Contact> ContactList{get;set;}
    public List<Attachment> AttachmentList{get;set;}
    public List<ts2__Application__c> application{get;set;}
    public Set<id> SelectedAttachmentSet = new Set<id>();
    public ts2__Application__c appnn{get;set;}
    public Contact cntct{get;set;}
    public Contact bccntct{get;set;}
    public string AdditionalTo{get;set;}
    public boolean AllowEmailEdit{get;set;}
    public id IsSelected{get;set;}
    public string EmailSubject{get;set;}
    public id SelectedEmailFolder{get;set;}
    public id SelectedEmailTemplate{get;set;}
    public string EmailBody{get;set;}
    public boolean HtmlView{get;set;}
    public ID ApplicationId;
     String[] emailarray = new String[]{};
     String[] ccemailarray = new String[]{};
     String[] bcemailarray = new String[]{};
    public List<Attachment> SelectedAttachmentList = new List<Attachment>();
    public List<Attachment> NewAttachment = new List<Attachment>();
    public List<EmailTemplate > SelectedTemplateList = new List<EmailTemplate>();
   
    public List<Folder> FolderList = new List<Folder>();
    public List<EmailTemplate > EmailTemplateList= new List<EmailTemplate>();

    public EmailAttachmentCls() {
        Completed = false;
        appnn = new ts2__Application__c();
        cntct= new Contact ();
        bccntct = new Contact ();
        AllowEmailEdit = true;   
        ApplicationId = ApexPages.CurrentPage().getParameters().get('id');
          AttachmentList= [SELECT Id,Name,body,ParentId FROM Attachment WHERE ParentId =:ApexPages.CurrentPage().getParameters().get('id')];
       //  Commented on 25 oct 2013 because of Changes to Single Record Forwarding task 
         for(ts2__Application__c  ap : [SELECT Id,Name,ts2__Candidate_Contact__r.name,ts2__Candidate_Contact__c,ts2__Job__c,Bio__c FROM ts2__Application__c WHERE id =:ApexPages.CurrentPage().getParameters().get('id')]){
            JobOrderId = ap.ts2__Job__c;
            AppCandidate = ap.ts2__Candidate_Contact__r.name;
            AppBio = ap.Bio__c ;
          /*   if(ap .Bio__c <> null){
            Attachment att = new Attachment();
            att.name = 'Bio'; 
            att.Body = Blob.valueof(ap.Bio__c);
            att.ParentId = ApexPages.CurrentPage().getParameters().get('id') ; 
            AttachmentList.add(att);
            }*/
         } 
         for(ts2__Job__c job : [select id,name,ts2__Contact__c,ts2__Contact__r.name from ts2__Job__c where id =: JobOrderId]){
            appnn.ts2__Candidate_Contact__c = job.ts2__Contact__c ;
             ToContact = job.ts2__Contact__r.name;
         }
          SelectedEmailFolder = system.label.PerFolder;
           ChangeEmailFolderAction();
          SelectedEmailTemplate = system.label.Single_Candidate_Client_template;
           SelectTemplateAction();
       system.debug('AttachmentList....'+AttachmentList);
    }

    public void SelectTemplateAction(){
      String htmlbody;
        SelectedTemplateList=[select Id,Subject,body,Name,HtmlValue,TemplateType,Description from EmailTemplate where (id = :SelectedEmailTemplate)];
        if(SelectedTemplateList.isempty() == false){
         if(SelectedTemplateList[0].TemplateType == 'HTML'){
          system.debug('SelectedTemplateList[0].TemplateType ......'+SelectedTemplateList[0].TemplateType );
           HtmlView = true;
         }
         EmailSubject = SelectedTemplateList[0].Subject;
         htmlbody = SelectedTemplateList[0].body;
     //    EmailBody = HtmlValue;
        if(htmlbody.contains('{!ts2__Application__c.ts2__Candidate_Contact__c}')){
         if(AppCandidate <>null){
              htmlbody=  htmlbody.replace('{!ts2__Application__c.ts2__Candidate_Contact__c}',+AppCandidate);
             }else{
                    htmlbody=  htmlbody.replace('{!ts2__Application__c.ts2__Candidate_Contact__c}','');
             }
         }
         if(htmlbody.contains('{!ts2__Application__c.Bio__c}')){
         if(AppBio <> null){
              htmlbody=  htmlbody.replace('{!ts2__Application__c.Bio__c}',+AppBio);
             }else{
                    htmlbody=  htmlbody.replace('{!ts2__Application__c.Bio__c}','');
             }
         }
           if(htmlbody.contains('{!Contact.Name}')){
              htmlbody=  htmlbody.replace('{!Contact.Name}','');
         }
        
          EmailBody = htmlbody;
                   if(SelectedTemplateList[0].TemplateType == 'HTML'){
          system.debug('SelectedTemplateList[0].TemplateType ......'+SelectedTemplateList[0].TemplateType );
           HtmlView = true;
         }
         }
     }
     
     public List<SelectOption> getEmailFoldersList(){
         FolderList = [select Id,Name from Folder where Type = 'Email' order by Name];
            List<SelectOption> EmailFoldersOptions= new List<SelectOption>();
            integer i;
            string value;
             EmailFoldersOptions.add(new SelectOption('','--None--'));
              for(i=0;i<FolderList.size();i++){
                   string str;
                           if(FolderList[i].Name <> null){ 
                           str = string.valueof(FolderList[i].Name);
                           
                            value = string.valueof(FolderList[i].id);                           
                            EmailFoldersOptions.add(new SelectOption(value,str));
              
                            }
            }
           return EmailFoldersOptions;     
        }
    
      public void ChangeEmailFolderAction(){
            EmailTemplateList =[select Id,Name,TemplateType,Description from EmailTemplate where (FolderId = :SelectedEmailFolder and IsActive = true) order by Name];
       }
       
       public List<SelectOption> getEmailTemplates(){    
            List<SelectOption> TemplateOptions= new List<SelectOption>();
            integer i;
            string value;
             TemplateOptions.add(new SelectOption('','--None--'));
              for(i=0;i<EmailTemplateList.size();i++){
                      system.debug('EmailTemplateList[i].....'+EmailTemplateList[i]); 
                            string str = string.valueof(EmailTemplateList[i].Name);
                            value = string.valueof(EmailTemplateList[i].id);                           
                            TemplateOptions.add(new SelectOption(value,str));
            }
          return TemplateOptions;          
       }
       
    /* public void SelectTemplateAction(){
      system.debug('SelectedEmailTemplate............'+SelectedEmailTemplate);
            SelectedTemplateList=[select Id,Subject,body,Name,markup,HtmlValue,TemplateType,Description from EmailTemplate where (id = :SelectedEmailTemplate)];
            system.debug('SelectedTemplateList............'+SelectedTemplateList);
                if(SelectedTemplateList.isempty() == false){
                     if(SelectedTemplateList[0].TemplateType == 'HTML'){
                       HtmlView = true;
                     }
                    if((SelectedTemplateList[0].TemplateType == 'visualforce') && (SelectedTemplateList[0].Name == 'Client Candidate Submittal')){
                           HtmlView = false;
                          EmailSubject = JObtitle ;
                          showvf = true;
                              }
                     else{
                       showvf = false;
                         EmailSubject = SelectedTemplateList[0].Subject;
                         EmailSubject = JObtitle ;
                         EmailBody = SelectedTemplateList[0].HtmlValue;
                     }
                     if(SelectedTemplateList[0].TemplateType == 'HTML'){
                       HtmlView = true;
                     }
             }
             
     } */

   public void send(){
    try{
        String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(AdditionalTo);
        system.debug('AdditionalTo ........'+AdditionalTo );
        if ((!MyMatcher.matches()) && (AdditionalTo <> null && AdditionalTo <> '')) {
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.info,'Invalid E-Mail Address')); 
            return ;
        }
            string TOEmail;
        //   String[] emailarray = new String[]{};
             if(appnn.ts2__Candidate_Contact__c <> null){
              for(Contact ct  : [SELECT Id,Name,Email FROM Contact WHERE id =:appnn.ts2__Candidate_Contact__c]){
                          system.debug('ct  ...............'+ct);
                          
                          ToContact = ct.name;
                              if(ct.Email <> null || ct.Email <> ''){
                                    TOEmail = ct.Email;
                                     system.debug('TOEmail...............'+TOEmail);
                               }
                            }
                       if (TOEmail == null || TOEmail == '') {
                          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.info,'Please Enter Email Id in ' + ToContact )); 
                          return ;
                        }
                emailarray.add(TOEmail);
                }
         // emailarray.add([SELECT Id,Name,Email FROM Contact WHERE id =: appnn.ts2__Candidate_Contact__c].Email);
          if(AdditionalTo <> null && AdditionalTo <> ''){
          emailarray.add(AdditionalTo);
          }
         // try{
          string CCMailId,BBcMailId;
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(emailarray);
            if(cntct.ownerId <> null){
          for(User cm : [SELECT Id,Name,Email FROM user WHERE id =: cntct.ownerId]){
                      system.debug('cm ...............'+cm);
                          if(cm.Email <> null || cm.Email <> ''){
                                CCMailId = cm.Email;
                                 system.debug('CCMailId ...............'+CCMailId);
                           }
                        }
            ccemailarray.add(CCMailId);
            mail.setCcAddresses(ccemailarray);
            }
             if(bccntct.ownerId <> null){
               for(User cm : [SELECT Id,Name,Email FROM user WHERE id =: bccntct.ownerId]){
                      system.debug('cm ...............'+cm);
                          if(cm.Email <> null || cm.Email <> ''){
                                BBcMailId = cm.Email;
                                 system.debug('CCMailId ...............'+CCMailId);
                           }
                        }
            bcemailarray.add(BBcMailId);
            mail.setBccAddresses(bcemailarray);
         
            }
            mail.setwhatId(ApplicationId);
            mail.setTargetObjectId(appnn.ts2__Candidate_Contact__c);
          //   mail.setWhatId(appnn.ts2__Account__c);
            mail.setSaveAsActivity(true);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            if(SelectedTemplateList.isempty() == true){
               mail.setHtmlBody(+EmailBody ); 
               mail.setSubject(+EmailSubject);
           }
           mail.SetTemplateid(SelectedEmailTemplate);
            system.debug('AttachmentList....'+AttachmentList);
            List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();
            for (Attachment a : AttachmentList){
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(a.name);
                efa.setBody(a.body);
                efaList.add( efa );
                system.debug('efat....'+efa);
            }
              if(AttachmentList.isempty()==false){
               mail.setFileAttachments(efaList );
               }
             system.debug('get.........'+mail.getFileAttachments());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            Completed = true;
            }
            catch (System.DmlException e) {
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(i))); 
              
               }
            }
}
}