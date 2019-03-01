public class SubmittalsEmailPageHelper {

    public static Id logEmail(

      String emailSubject,

      String emailBody,

      Id relatedRecordId,

      Id contactId,

      String[] toAddresses,

      String[] ccAddresses,

      String[] bccAddresses,

      List<ts2__Submittal__c> submittals,

      String lightningBaseUrl)

    {

      EmailMessage emailMessage = new EmailMessage();

      if(bccAddresses.size() > 0) {emailMessage.BccAddress = bccAddresses[0];}

      if(ccAddresses.size() > 0) {emailMessage.CcAddress = ccAddresses[0];}

      User currentUser = [SELECT Name,Email FROM User WHERE Id =: UserInfo.getUserId()];

      emailMessage.FromAddress = currentUser.Email;

      emailMessage.FromName = currentUser.Name;

      emailMessage.HtmlBody = emailBody;

      emailMessage.RelatedToId = relatedRecordId;

      emailMessage.Subject = emailSubject;

      emailMessage.ToAddress = toAddresses[0];

      String submitalsIncludedString = '';

      for(ts2__Submittal__c s : submittals) {

        submitalsIncludedString = submitalsIncludedString + s.ts2__Candidate__r.Name + ' (' + lightningBaseUrl + s.Id + ')' + '\r\n';

      }

      emailMessage.submittalsIncluded__c = submitalsIncludedString;

      insert emailMessage;

      List<EmailMessageRelation> emailMessageRelations = new List<EmailMessageRelation>();

      EmailMessageRelation emailMessageRelation = new EmailMessageRelation();

      emailMessageRelation.EmailMessageId = emailMessage.Id;

      emailMessageRelation.RelationAddress = currentUser.Email;

      emailMessageRelation.RelationId = currentUser.Id;

      emailMessageRelation.RelationType = 'FromAddress';

      emailMessageRelations.add(emailMessageRelation);

      emailMessageRelation = new EmailMessageRelation();

      emailMessageRelation.EmailMessageId = emailMessage.Id;  

      emailMessageRelation.RelationAddress = currentUser.Email;

      emailMessageRelation.RelationId = contactId;

      emailMessageRelation.RelationType = 'ToAddress';      

      emailMessageRelations.add(emailMessageRelation);

      insert emailMessageRelations;

      return emailMessage.Id;

    }           

    @future

    public static void createContentDocumentLinks(Id emailMessageId, Set<Id> contentVersionIds, Set<Id> attachmentIds) {

      List<Attachment> attachments = [SELECT Name,Body FROM Attachment WHERE Id IN: attachmentIds];

      if(attachments.size() > 0) {

        List<ContentVersion> contentVersions = new List<ContentVersion>();

        for(Attachment a : attachments) {

          ContentVersion contentVersion = new ContentVersion(VersionData = a.Body, Title = a.Name, PathOnClient = a.Name);

          contentVersions.add(contentVersion);

        }

        insert contentVersions;

        Set<Id> newContentVersionIds = (new Map<Id,ContentVersion>(contentVersions)).keySet();

        contentVersionIds.addAll(newContentVersionIds);

      }

      List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();

      Map<Id,ContentVersion> contentVersionMap = new Map<Id,ContentVersion>([SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionIds]);

      for(Id id : contentVersionIds) {

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();

        contentDocumentLink.ContentDocumentId = contentVersionMap.get(id).ContentDocumentId;

        contentDocumentLink.LinkedEntityId = emailMessageId;

        contentDocumentLink.ShareType = 'V';

        contentDocumentLinks.add(contentDocumentLink);

      } 

      insert contentDocumentLinks;

      System.debug('contentDocumentLinks: ' + contentDocumentLinks);

      EmailMessage emailMessage = new EmailMessage(Id = emailMessageId, Status = '3');

      update emailMessage;

      System.debug('emailMessage: ' + emailMessage);

    }

    public static String[] getCcOrBccAddress(String userOrContactIdString, Boolean isUserId) {

      String[] bccOrCcAddresses = new String[]{};

      Id userOrContactId;

      if(userOrContactIdString != null) {

        if(userOrContactIdString.length() == 18) {

          userOrContactId = Id.valueOf(userOrContactIdString.subString(0,15));

        }

        else {userOrContactId = Id.valueOf(userOrContactIdString);}

      }

      if(isUserId) {

        List<User> users = [SELECT Email FROM User WHERE Id =: userOrContactId LIMIT 1];

        if(users.size() == 1) {bccOrCcAddresses.add((String)users[0].Email);}

      }

      else {

        List<Contact> users = [SELECT Email FROM Contact WHERE Id =: userOrContactId LIMIT 1];

        if(users.size() == 1) {bccOrCcAddresses.add((String)users[0].Email);}

      }

      return bccOrCcAddresses;

    }

    public static String formatHtml(Object fieldValue, String fieldLabel) {

      String divOpen = '<div style="font-family:Verdana; font-size:11.5px; font-weight:bold; margin-top:0px; padding: 0px; border:none;">';

      String spanOpen = '<span style="font-weight:normal; margin-top:0px; padding: 0px; border:none;">';      

      String spanCloseDivClose = '</span></div>';

      Map<String, Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get('ts2__Application__c').getDescribe().fields.getMap();

      String billRateLabel = objectFieldMap.get('Application_Bill_Rate__c').getDescribe().getLabel();

      if(fieldValue != null) {

        String rawFieldValue = String.valueOf(fieldValue);

        System.debug('rawFieldValue: ' + rawFieldValue);

        String formattedHtml = fixStyling(rawFieldValue);

        if(fieldLabel == billRateLabel) {formattedHtml = '$' + formattedHtml + '/hr';}

        return (divOpen + fieldLabel + ': ' + spanOpen + formattedHtml + spanCloseDivClose);

      }

      else {

        return (divOpen + fieldLabel + ': ' + spanOpen + 'None specified' + spanCloseDivClose);

      }

    }

    public static String fixStyling(String htmlBody) {

      if(htmlBody != null) {

        htmlBody = htmlBody.replace('<ul>', '<ul style="font-family:Verdana; font-size:11.5px; margin-top:0px; padding: 0px; border:none; list-style-type: circle;">');

        htmlBody = htmlBody.replace('<li>', '<li style="margin-top:0px; font-size:11.5px; margin-left:30px; margin-top:0px; padding: 0px; border:none;">');

        htmlBody = htmlBody.replace('span style="font-size: 14px;','span style="font-size: 11.5px; margin-top:0px; padding: 0px; border:none;');            

      }

      return htmlBody;

    }

    public static List<String> getApplicationFieldApiNames(String templateUniqueName) {

      List<String> applicationFieldApiNames = new List<String>();

      System.debug('templateUniqueName: ' + templateUniqueName);

      List<TemplateFieldMapping__mdt> mappingTmp = [SELECT Id,submittalFieldNames__c FROM TemplateFieldMapping__mdt WHERE templateUniqueName__c =: templateUniqueName];

      if(mappingTmp.size() == 1) {

        TemplateFieldMapping__mdt templateFieldMapping = mappingTmp[0];

        String fieldNames = templateFieldMapping.submittalFieldNames__c;

        Integer i = 0;

        while( i < fieldNames.length() ) {
            
          if(fieldNames.charAt(i) == 10 || fieldNames.charAt(i) == 13) {

            fieldNames = fieldNames.replace(fieldNames.subString(i,i+1),';');

            Integer lengthBefore = fieldNames.length();

            fieldNames = fieldNames.replace(';;',';');

            Integer lengthAfter = fieldNames.length();

            if(lengthAfter < lengthBefore) {i = i - 1;}

          }

          i = i + 1;        

        }

        applicationFieldApiNames = fieldNames.split(';');

        applicationFieldApiNames.add(String.valueOf(templateFieldMapping.Id));
      
      }

      System.debug('applicationFieldApiNames: ' + applicationFieldApiNames);

      return applicationFieldApiNames;

    } 

    public static String getCandidateNameString(List<ts2__Submittal__c> submittals) {

      String candidateNameString = '';

      for(ts2__Submittal__c  submittal : submittals) {

        candidateNameString = candidateNameString + submittal.ts2__Candidate__r.Name + ', ';

      }

      candidateNameString = candidateNameString.removeEnd(', ');

      if(candidateNameString.contains(',')) {

        String lastCandidateName = candidateNameString.substringAfterLast(', ');

        candidateNameString = candidateNameString.subStringBeforeLast(', ') + ' and ' + lastCandidateName;

      }      

      return candidateNameString;

    }

    public static List<Task> createCandidateTasks(List<ts2__Submittal__c> submittals, Id jobOrderId, String lightningBaseUrl) {

      List<Task> tasks = new List<Task>();

      for(ts2__Submittal__c  submittal : submittals) {

        Task task = new Task();

        task.ActivityDate = System.today();

        task.Subject='Application Sent for Review';

        String linkToApplication = lightningBaseUrl + String.valueOf(submittal.ts2__Related_Application__c);

        String dateFormatString = 'MM/dd/yyyy hh:mm aaa zz ';

        String timeZoneString = UserInfo.getTimeZone().toString();

        DateTime currentDateTime = DateTime.now();

        String dateTimeString = currentDateTime.format(dateFormatString,timeZoneString);              

        task.Description = 'The Application ' + '(' +  linkToApplication + ') for ' + submittal.ts2__Candidate__r.name  + ' was sent for review on ' + dateTimeString;

        task.Status= 'Completed';

        task.WhatId = jobOrderId;

        task.WhoId = submittal.ts2__Candidate__c;

        tasks.add(task);

      }

      return tasks;

    }

    public static Task createContactTask(List<ts2__Submittal__c> submittals, Id jobOrderId, Id contactId, String contactName, String lightningBaseUrl) {

      Task task = new Task();

      task.ActivityDate = System.today();

      String subject = 'Review Application';

      task.Status = 'Completed';

      task.WhatId = jobOrderId;

      task.WhoId = contactId;

      String descriptionStart = 'The application';

      String descriptionEnd = '';      

      if(submittals.size() > 1) {

        descriptionStart = descriptionStart + 's for candidates ';

        descriptionEnd = ' were sent to ' + contactName + ' for review.';

        subject = subject + 's';

      }

      else if(submittals.size() == 1) {

        descriptionStart = descriptionStart + ' for candidate ';

        descriptionEnd = ' was sent to ' + contactName + ' for review.';

      }

      task.Subject = subject;      

      String candidateNameString = getCandidateNameString(submittals);

      task.Description = descriptionStart + candidateNameString + descriptionEnd;

      return task;

    }      

}