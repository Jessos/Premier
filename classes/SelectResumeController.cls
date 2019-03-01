global without sharing class SelectResumeController {

  public ts2__Application__c application {get;set;}

  public List<AttachmentWrapper> attachmentWrappers {get;set;}

  public String wrapperJsonObject {get;set;}

  public String errorMessage {get;set;}

  public String lightningBaseUrl {get;set;}

  public SelectResumeController(ApexPages.StandardController stdController) {

    this.attachmentWrappers = new List<AttachmentWrapper>();

    List<CustomPageSettings__mdt> settingsTmp = [SELECT

      lightningBaseUrl__c

      FROM CustomPageSettings__mdt

      WHERE DeveloperName = 'Active_Settings'

      LIMIT 1

    ];

    if(settingsTmp.size() == 1) {this.lightningBaseUrl = settingsTmp[0].lightningBaseUrl__c;}

    Id applicationId = ((ts2__Application__c)stdController.getRecord()).Id;

    this.application = [SELECT

      Id,Name,ts2__Candidate_Contact__c,ts2__Candidate_Contact__r.Name

      FROM ts2__Application__c

      WHERE Id =: applicationId

    ];   

    List<ContentDocumentLink> contentDocumentLinks = [

      SELECT LinkedEntityId,ContentDocumentId,ContentDocument.Title,ContentDocument.CreatedDate,ContentDocument.FileExtension
          
      FROM ContentDocumentLink
          
      WHERE LinkedEntityId =: application.ts2__Candidate_Contact__c

      ORDER BY ContentDocument.CreatedDate DESC LIMIT 100
          
    ];

    for(ContentDocumentLink cdl : contentDocumentLinks) {

      String fileName = cdl.ContentDocument.Title;

      String fileExtensionSubstring = String.valueOf(cdl.ContentDocument.FileExtension);

      if(fileExtensionSubString != null && !fileName.substringAfterLast('.').contains(fileExtensionSubstring)) {

        fileName = fileName + '.' + cdl.ContentDocument.FileExtension;

      }

      AttachmentWrapper attachmentWrapper = new AttachmentWrapper(cdl.ContentDocumentId,null,fileName,cdl.ContentDocument.CreatedDate);

      this.attachmentWrappers.add(attachmentWrapper);

    }     

    List<Attachment> attachments = [SELECT

      Id,Name,CreatedDate

      FROM Attachment

      WHERE ParentId =: application.ts2__Candidate_Contact__c

      ORDER BY CreatedDate DESC LIMIT 100

    ];

    for(Attachment a : attachments) {

      AttachmentWrapper attachmentWrapper = new AttachmentWrapper(null,a.Id,a.Name,a.CreatedDate);

      this.attachmentWrappers.add(attachmentWrapper);

    }

    this.wrapperJsonObject = JSON.serialize(attachmentWrappers);
     
  }

  public PageReference insertAttachments() {

    List<ContentVersion> contentVersions = new List<ContentVersion>();

    Set<Id> attachmentIds = new Set<Id>();

    Set<Id> contentDocumentIds = new Set<Id>();

    for(AttachmentWrapper aw : attachmentWrappers) {

      if(aw.attach) {

        if(aw.attachmentId != null) {attachmentIds.add(aw.attachmentId);}

        else {contentDocumentIds.add(aw.contentDocumentId);}

      }

    }

    if(attachmentIds.size() > 0) {

      for(Attachment a : [SELECT Id,Name,Body FROM Attachment WHERE Id IN: attachmentIds]) {
           
        ContentVersion contentVersion = new ContentVersion(VersionData = a.Body, Title = a.Name, PathOnClient = a.Name);

        contentVersions.add(contentVersion);      

      }

      try {

        insert contentVersions;

        Set<Id> contentVersionIds = (new Map<Id,ContentVersion>(contentVersions)).keySet();

        for(ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionIds]) {

          contentDocumentIds.add(cv.ContentDocumentId);

        }

      }

      catch(Exception e) {this.errorMessage = 'An error occurred; ' + e.getMessage() + '; ' + e.getCause() + '; ' + e.getStackTraceString();}

    }

    List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();

    List<ContentDocument> contentDocuments = new List<ContentDocument>();

    for(ContentDocument cd : [SELECT Id,Title,LatestPublishedVersion.FileExtension FROM ContentDocument WHERE Id IN: contentDocumentIds]) {

      contentDocuments.add(cd);

      ContentDocumentLink contentDocumentLink = new ContentDocumentLink();

      contentDocumentLink.ContentDocumentId = cd.Id;

      contentDocumentLink.LinkedEntityId = this.application.Id;

      contentDocumentLink.ShareType = 'I';

      contentDocumentLinks.add(contentDocumentLink);
      
    }

    if(contentDocumentLinks.size() > 0 && contentDocumentLinks.size() < 4) {

      try {

        update contentDocuments;

        insert contentDocumentLinks;

        Boolean successfulSoFar = true;

        for(ContentDocumentLink cd :contentDocumentLinks) {

          if (cd.Id == null) {successfulSoFar = false;}

        }

        if(successfulSoFar) {

          String originalRecordUrl = lightningBaseUrl + String.valueOf(application.Id);

          PageReference pageReference = new PageReference(originalRecordUrl + '?reloadPage=yes');

          pageReference.setRedirect(true);

          return pageReference;

        } 

      }  

      catch(Exception e) {this.errorMessage = 'An error occurred; ' + e.getMessage() + '; ' + e.getCause() + '; ' + e.getStackTraceString();}   

    }

    else {this.errorMessage = 'Please select between 1 and 3 attachments';}

    return null;
       
  }     

}