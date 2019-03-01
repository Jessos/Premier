public class SubmittalsEmailPageController {

    public List<ts2__Submittal__c> submittals {get;set;}

    public Boolean showEmailBodyEdit {get;set;}

    public ts2__Job__c jobOrder {get;set;}

    public ts2__Job__c ccContactJobOrder {get;set;}

    public Contact bccContact {get;set;}

    public Id selectedEmailFolderId {get;set;}

    public Id selectedEmailTemplateId {get;set;}

    public String emailSubject {get;set;}

    public String emailBody {get;set;}

    public String editOrSave {get;set;}

    public Set<Id> attachmentIds {get;set;}

    public List<AttachmentWrapper> attachmentWrappers {get;set;}

    public Set<Id> applicationIds {get;set;}

    public Boolean showSendEmailButton {get;set;}

    public String additionalEmails {get;set;}

    public String linkBackToJobOrder {get;set;}

    public Boolean showSelectAll {get;set;}

    public Boolean showUnselectAll {get;set;}

    public String lightningBaseUrl {get;set;}
    
    public SubmittalsEmailPageController(ApexPages.StandardSetController standardSetController) {

        System.debug('Constructor code started...');    

        Set<Id> submittalIds = (new Map<Id,SObject>(standardSetController.getSelected())).keySet();

        this.submittals  = [SELECT

            Id,Name,ts2__Job__c,ts2__Job__r.Name,ts2__Related_Application__c,ts2__Related_Application__r.Application_Bill_Rate__c,ts2__Related_Application__r.richBio__c,ts2__Related_Application__r.Salary__c,ts2__Related_Application__r.LinkedIn_Profile2__c,ts2__Candidate__c,ts2__Candidate__r.name,ts2__Candidate__r.FirstName
              
            FROM ts2__Submittal__c

            WHERE Id IN: submittalIds

        ];

        List<CustomPageSettings__mdt> settingsTmp = [SELECT

            lightningBaseUrl__c,preferredFolderDeveloperName__c

            FROM CustomPageSettings__mdt

            WHERE DeveloperName = 'Active_Settings'

            LIMIT 1

        ];

        if(settingsTmp.size() == 1) {

          this.lightningBaseUrl = settingsTmp[0].lightningBaseUrl__c;

          String folderDeveloperName = settingsTmp[0].preferredFolderDeveloperName__c;

          List<Folder> folderTmp = [SELECT Id FROM Folder WHERE DeveloperName =: folderDeveloperName];

          if(folderTmp.size() == 1) {this.selectedEmailFolderId = folderTmp[0].Id;}

        }        

        Id jobOrderId;

        this.applicationIds = new Set<Id>();

        if(submittals.size() > 0) {

            jobOrderId = submittals[0].ts2__Job__c;

            this.jobOrder = [SELECT

                Id,Name,ts2__Status__c,RecordType.Name,ts2__Account__r.Name,ts2__Stage__c,ts2__Recruiter__r.Name,ts2__Department__c,ts2__Contact__c,ts2__Contact__r.Email,ts2__Contact__r.Name,ts2__Contact__r.FirstName

                FROM ts2__Job__c

                WHERE Id =: jobOrderId

            ];

            this.linkBackToJobOrder = this.lightningBaseUrl + jobOrderId;

        }

        else {

            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'You did not select any submittals. You will not be able to load any email templates. Please navigate back to your job order by clicking the below link. Your job order should be at the top of the recent job order list.'));

            this.linkBackToJobOrder = this.lightningBaseUrl + 'ts2__Job__c/list?filterName=Recent';

        }

        for(ts2__Submittal__c sub: submittals) {this.applicationIds.add(sub.ts2__Related_Application__c);}     

        Map<Id,ts2__Application__c> applicationMap = new Map<Id,ts2__Application__c>([SELECT

          ts2__Candidate_Contact__r.Name

          FROM ts2__Application__c

          WHERE Id IN: applicationIds

        ]);

        this.attachmentWrappers = new List<AttachmentWrapper>();           

        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();

        if(applicationIds.size() > 0) {contentDocumentLinks = [SELECT

          LinkedEntityId,ContentDocumentId

          FROM ContentDocumentLink

          WHERE LinkedEntityId IN: applicationIds 

          ORDER BY ContentDocument.CreatedDate DESC LIMIT 100

        ];}

        Map<Id,String> contentDocumentIdToCandidateName = new Map<Id,String>();

        for(ContentDocumentLink cdl: contentDocumentLinks) {

          Id contentDocumentId = cdl.ContentDocumentId;

          String candidateName = applicationMap.get(cdl.LinkedEntityId).ts2__Candidate_Contact__r.name;

          contentDocumentIdToCandidateName.put(contentDocumentId,candidateName);

        }

        List<ContentVersion> contentVersions = [SELECT

          Id,Title,ContentDocumentId,FileExtension,ContentDocument.CreatedDate

          FROM ContentVersion

          WHERE ContentDocumentId IN: contentDocumentIdToCandidateName.keySet()

          ORDER BY ContentDocument.CreatedDate DESC LIMIT 100

        ];
        
        for(ContentVersion cv : contentVersions) {

          String candidateName = contentDocumentIdToCandidateName.get(cv.ContentDocumentId);

          String fileName = cv.Title;

          String fileExtensionSubstring = String.valueOf(cv.FileExtension);

          if(fileExtensionSubstring != null && !fileName.substringAfterLast('.').contains(fileExtensionSubstring)) {

            fileName = fileName + '.' + fileExtensionSubstring;

          } 

          AttachmentWrapper attachmentWrapper = new AttachmentWrapper(cv.Id,null,candidateName,fileName,cv.ContentDocument.CreatedDate);

          this.attachmentWrappers.add(attachmentWrapper);          

        }

        List<Attachment> attachments = [SELECT

          Id,Name,ParentId,CreatedDate

          FROM Attachment

          WHERE ParentId IN: applicationIds

          ORDER BY CreatedDate DESC LIMIT 100 

        ];

        this.attachmentIds = (new Map<Id,Attachment>(attachments)).keySet();

        for(Attachment a : attachments) {

          String candidateName = applicationMap.get(a.ParentId).ts2__Candidate_Contact__r.Name;

          AttachmentWrapper attachmentWrapper = new AttachmentWrapper(null,a.Id,candidateName,a.Name,a.CreatedDate);

          attachmentWrappers.add(attachmentWrapper);

        }

        this.showSelectAll = false;

        if(this.attachmentWrappers.size() > 0) {this.showUnselectAll = true;}

        else {this.showUnselectAll = false;}

        this.editOrSave = 'Edit';

        this.additionalEmails = 'Enter emails separated with semi-colons (no spaces)';

        this.ccContactJobOrder = new ts2__Job__c();

        this.showSendEmailButton = false;

        this.showEmailBodyEdit = false;

        this.bccContact = new Contact(OwnerId = UserInfo.getUserId());

        this.emailBody = '<i>Select a template or click Edit to continue</i>';

        System.debug('Constructor code finished...');

    }        

    public void loadSubjectAndBody() {

      List<EmailTemplate> templateTmp = [SELECT

        Id,DeveloperName,Subject,Body,HtmlValue

        FROM EmailTemplate

        WHERE Id =: selectedEmailTemplateId

        LIMIT 1

      ];

      EmailTemplate emailTemplate;

      if(templateTmp.size() == 1) {emailTemplate = templateTmp[0];}

      if(emailTemplate != null && this.jobOrder != null) {

        this.emailSubject = emailTemplate.Subject.replace('{!ts2__Job__c.Name}',this.jobOrder.Name);

        if(emailTemplate.htmlValue != null) {this.emailBody = emailTemplate.HtmlValue;}

        else if (emailTemplate.Body != null) {this.emailBody = emailTemplate.Body;}

        else {emailBody = '';}

        Id contactIdOnPage = this.jobOrder.ts2__Contact__c;

        List<Contact> contactTmp = [SELECT FirstName FROM Contact WHERE Id =: contactIdOnPage LIMIT 1];

        if(contactTmp.size() == 1) {emailBody = emailBody.replace('{!Contact.FirstName}', contactTmp[0].FirstName);}

        emailBody = '<div style="font-family:Verdana; font-size:11.5px; margin-top:0px;">' + emailBody;

        List<String> fieldsToAdd = SubmittalsEmailPageHelper.getApplicationFieldApiNames(emailTemplate.DeveloperName);

        String fieldMappingId = '';

        if(fieldsToAdd.size() > 0) {

          fieldMappingId = fieldsToAdd.remove(fieldsToAdd.size() - 1);

          String queryString = 'SELECT ';

          System.debug('before concatenating the query the fieldsToAdd list has: ' + fieldsToAdd);

          for(String s : fieldsToAdd) {queryString = queryString + s + ',';} queryString = queryString.removeEnd(',');

          queryString = queryString + ' FROM ts2__Application__c WHERE Id IN: applicationIds';

          System.debug('queryString: ' + queryString);

          Map<Id,SObject> applicationMap = new Map<Id,SObject>();

          try {applicationMap = new Map<Id,SObject>(Database.query(queryString));}

          catch(Exception e) {

            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,

            'An error occurred. Please check the custom metadata type record that has Id \'' + fieldMappingId + '\' and ensure that the template unique name and field API names are correct'));

          }

          Map<String,Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get('ts2__Application__c').getDescribe().fields.getMap();

          for(ts2__Submittal__c s : submittals) {

            emailBody = emailBody + '<br/>' + SubmittalsEmailPageHelper.formatHtml(s.ts2__Candidate__r.Name, 'Candidate Name');

            ts2__Application__c application = (ts2__Application__c)applicationMap.get(s.ts2__Related_Application__c);

            for(String str : fieldsToAdd) {

              if(application != null) {

                Object fieldValue = application.get(str);

                String fieldLabel = objectFieldMap.get(str).getDescribe().getLabel();

                String htmlToAdd = SubmittalsEmailPageHelper.formatHtml(fieldValue,fieldLabel);

                emailBody = emailBody + htmlToAdd;

                System.debug('html added for ' + str + ': ' + htmlToAdd);                

              }

            }

          }

          emailBody = emailBody + '</div>';

        }

      }

      emailBody = SubmittalsEmailPageHelper.fixStyling(emailBody);

      showSendEmailButton = true;
   
    }      

    public void sendEmail() {

      Messaging.reserveSingleEmailCapacity(1);

      Messaging.SingleEmailMessage singleEmailMessage = new Messaging.SingleEmailMessage();

      String[] toAddresses = new String[]{};

      Id toContactId = this.jobOrder.ts2__Contact__c;

      String contactName;

      singleEmailMessage.setTargetObjectId(toContactId);

      List<Contact> contactTmp = [SELECT Email,Name FROM Contact WHERE Id =: toContactId LIMIT 1];

      if(contactTmp.size() > 0) {

        toAddresses.add(contactTmp[0].Email);

        contactName = contactTmp[0].Name;

      }

      if(additionalEmails != 'Enter emails separated with semi-colons (no spaces)' && additionalEmails != null && additionalEmails != '') {

        additionalEmails = additionalEmails.deleteWhiteSpace();

        for(String s: additionalEmails.split(';')) {toAddresses.add(s);}

        if(!additionalEmails.contains(';')) {toAddresses.add(additionalEmails);}

        singleEmailMessage.setToAddresses(toAddresses);

      }

      String ccContactIdString = String.valueOf(this.ccContactJobOrder.ts2__Contact__c);

      String bccUserIdString = String.valueOf(this.bccContact.OwnerId);

      String[] ccAddresses = SubmittalsEmailPageHelper.getCcOrBccAddress(ccContactIdString,false);

      String[] bccAddresses = SubmittalsEmailPageHelper.getCcOrBccAddress(bccUserIdString,true);

      singleEmailMessage.setCcAddresses(ccAddresses);

      singleEmailMessage.setBccAddresses(bccAddresses);

      singleEmailMessage.setWhatId(jobOrder.Id);

      singleEmailMessage.setSaveAsActivity(false);

      singleEmailMessage.setUseSignature(true);

      singleEmailMessage.setSubject(emailSubject);

      singleEmailMessage.setHtmlBody(emailBody);

      Set<Id> selectedAttachmentIds = new Set<Id>();

      Set<Id> selectedContentVersionIds = new Set<Id>();

      for(AttachmentWrapper aw : attachmentWrappers) {

        if(aw.attach) {

          if(aw.attachmentId != null) {selectedAttachmentIds.add(aw.attachmentId);}

          else if (aw.contentVersionId != null) {selectedContentVersionIds.add(aw.contentVersionId);}

        }

      }

      if(selectedAttachmentIds.size() + selectedContentVersionIds.size() < 11) {

        List<Messaging.EmailFileAttachment> emailFileAttachments = new List<Messaging.EmailFileAttachment>(); 

        for(Attachment a : [SELECT Id,Name,Body,ContentType FROM Attachment WHERE Id IN: selectedAttachmentIds]) {

          Messaging.EmailFileAttachment emailFileAttachment = new Messaging.EmailFileAttachment();

          emailFileAttachment.setFileName(a.Name);

          emailFileAttachment.setBody(a.Body);

          emailFileAttachments.add(emailFileAttachment);

        }

        for(ContentVersion cv : [SELECT Id,Title,VersionData,FileType,FileExtension FROM ContentVersion WHERE Id IN: selectedContentVersionIds]) {

          Messaging.EmailFileAttachment emailFileAttachment = new Messaging.EmailFileAttachment();

          emailFileAttachment.setBody(cv.VersionData);

          String fileName = cv.Title;

          String fileExtensionSubstring = String.valueOf(cv.FileExtension);

          if(fileExtensionSubstring != null && !fileName.substringAfterLast('.').contains(fileExtensionSubstring)) {

            fileName = fileName + '.' + fileExtensionSubstring;

          }

          emailFileAttachment.setFileName(fileName);

          emailFileAttachments.add(emailFileAttachment);

        }      

        try {

          if(emailFileAttachments.size() > 0) {singleEmailMessage.setFileAttachments(emailFileAttachments);}

          Messaging.SingleEmailMessage[] singleEmailMessages = new Messaging.SingleEmailMessage[] {singleEmailMessage};

          Messaging.SendEmailResult[] sendEmailResults = Messaging.sendEmail(singleEmailMessages);

          Messaging.SendEmailResult sendEmailResult = sendEmailResults[0];

          if(sendEmailResult.isSuccess()) {

            String successMessage = 'Your e-mail was sent successfully.';

            showSendEmailButton = false;

            Id emailMessageId = SubmittalsEmailPageHelper.logEmail(this.emailSubject,this.emailBody,this.jobOrder.Id,toContactId,toAddresses,ccAddresses,bccAddresses,this.submittals,this.lightningBaseUrl);

            if(emailMessageId != null) {

                SubmittalsEmailPageHelper.createContentDocumentLinks(emailMessageId,selectedContentVersionIds,selectedAttachmentIds);

                successMessage = successMessage + ' Your e-mail was logged and its Id is \'' + emailMessageId + '\'. ';

            }

            else {ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, successMessage + 'However, your email was not successfully logged here in Salesforce.'));}            

            List<Task> tasks = SubmittalsEmailPageHelper.createCandidateTasks(this.submittals,this.jobOrder.Id,this.lightningBaseUrl);

            Task task = SubmittalsEmailPageHelper.createContactTask(this.submittals,this.jobOrder.Id,toContactId,contactName,this.lightningBaseUrl);

            tasks.add(task);

            insert tasks;

            Boolean tasksInserted = false;

            String taskIds = '';

            for(Task t : tasks) {

                if(t.Id == null) {tasksInserted = false; break;}

                else {

                tasksInserted = true;

                taskIds = taskIds + '\'' + String.valueOf(t.Id) + '\', ';

              }

            }

            taskIds.removeEnd('; ');

            if(tasksInserted) {

                successMessage = successMessage + 'Tasks were inserted for all candidates and for the contact. Their Ids are: ' + taskIds;

                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, successMessage));

            }

            else {

                successMessage = successMessage + 'However, the tasks were not properly inserted.';

                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, successMessage));

            }


          }

          else {ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'An error occurred. Your email was not sent. If this issue occurs again, please contact your Salesforce admin.'));}

        }

        catch(Exception e) {

          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,

            'An error occurred. If this seems to be a technical issue, please contact the appropriate resource with the following error message. ERROR:  ' +

            e.getMessage() + '; ' + e.getStackTraceString() + ';' + e.getCause())

          );

        }          

      }     

      else {ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Please select between 0 and 10 attachments'));}

    }    

    public void selectAllAttachments() {

      for(AttachmentWrapper aw : attachmentWrappers) {aw.attach = true;}

      showSelectAll = false; showUnselectAll = true;      

    }

    public void unselectAllAttachments() {

      for(AttachmentWrapper aw : attachmentWrappers) {aw.attach = false;}

      showSelectAll = true; showUnselectAll = false;

    }    

    public List<SelectOption> getEmailFolderOptions() {

      List<SelectOption> selectOptions= new List<SelectOption>();

      for(Folder f : [SELECT Id,Name FROM Folder WHERE Type = 'Email' ORDER BY Name]) {

        SelectOption selectOption = new SelectOption(f.Id,f.Name);

        selectOptions.add(selectOption);

      }

      return selectOptions; 

    }    

    public List<SelectOption> getEmailTemplateOptions() {    

      List<SelectOption> selectOptions= new List<SelectOption>();

      selectOptions.add(new SelectOption('','--None--'));

      for(EmailTemplate et : [SELECT Id,Name FROM EmailTemplate WHERE FolderId =: selectedEmailFolderId AND IsActive = TRUE ORDER BY Name]) {

        SelectOption selectOption = new SelectOption(et.Id,et.Name);                     

        selectOptions.add(selectOption);

      }

      return selectOptions; 

    }

    public void editOrSaveEmailBody() {

      if(emailBody == '<i>Select a template or click Edit to continue</i>') {emailBody = null;}

      if(showEmailBodyEdit == false) {

        showEmailBodyEdit = true;

        editOrSave = 'Save';

      }

      else if(showEmailBodyEdit == true) {

        editOrSave = 'Edit';

        showEmailBodyEdit = false;

      }

      emailBody = SubmittalsEmailPageHelper.fixStyling(emailBody);

      if(emailBody != null && emailBody != '' & emailBody != ' ' && showEmailBodyEdit == false){showSendEmailButton = true; }

      else {showSendEmailButton = false;}

    }

}