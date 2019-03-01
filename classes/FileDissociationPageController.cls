public class FileDissociationPageController {

	public Id recordId {get;set;}

	public List<AttachmentWrapper> attachmentWrappers {get;set;}

	public String objectLabelName {get;set;}

	public String recordName {get;set;}

	public Boolean isSuccess {get;set;}

	public String userMessage {get;set;}

	public String linkBackToRecord {get;set;}

	public FileDissociationPageController() {
		
		this.recordId = ApexPages.currentPage().getParameters().get('recordId');

		String objectApiName = this.recordId.getSObjectType().getDescribe().getName();

		this.objectLabelName = this.recordId.getSObjectType().getDescribe().getLabel();

		String queryString = 'SELECT Name FROM ' + objectApiName + ' WHERE Id = \'' + String.valueOf(this.recordId) + '\' LIMIT 1';

		SObject[] result = Database.query(queryString);

		this.recordName = String.valueOf(result[0].get('Name'));

	    List<CustomPageSettings__mdt> settingsTmp = [SELECT

	      lightningBaseUrl__c

	      FROM CustomPageSettings__mdt

	      WHERE DeveloperName = 'Active_Settings'

	      LIMIT 1

	    ];		

	    this.linkBackToRecord = settingsTmp[0].lightningBaseUrl__c + String.valueOf(this.recordId);

	    List<ContentDocumentLink> contentDocumentLinks = [

	      SELECT LinkedEntityId,ContentDocumentId,ContentDocument.Title,ContentDocument.CreatedDate,ContentDocument.FileExtension
	          
	      FROM ContentDocumentLink
	          
	      WHERE LinkedEntityId =: recordId

	      ORDER BY ContentDocument.CreatedDate DESC LIMIT 100
	          
	    ];

	    this.attachmentWrappers = new List<AttachmentWrapper>();

	    for(ContentDocumentLink cdl : contentDocumentLinks) {

	      String fileName = cdl.ContentDocument.Title;

	      String fileExtensionSubstring = String.valueOf(cdl.ContentDocument.FileExtension);

	      if(fileExtensionSubstring != null && !fileName.substringAfterLast('.').contains(fileExtensionSubstring)) {

	        fileName = fileName + '.' + cdl.ContentDocument.FileExtension;

	      }

	      AttachmentWrapper attachmentWrapper = new AttachmentWrapper(cdl.Id,fileName,cdl.ContentDocument.CreatedDate);

	      this.attachmentWrappers.add(attachmentWrapper);

	    }     	

	    if(contentDocumentLinks.size() == 0) {

			this.isSuccess = false;

			this.userMessage = 'Whoops! There are no (lightning) files to remove (dissociate) from this record. You can remove regular attachments by just deleting them (which will only delete those attachments, regardless of where else they may exist).';

	    }	

	}

	public void deleteContentDocumentLinks() {

		Set<Id> contentDocumentLinkIds = new Set<Id>();

		for(AttachmentWrapper aw : this.attachmentWrappers) {

			if(aw.remove) {contentDocumentLinkIds.add(aw.contentDocumentLinkId);}

		}

		try {

			Database.DeleteResult[] deleteResults = Database.delete([SELECT Id FROM ContentDocumentLink WHERE Id IN: contentDocumentLinkIds AND LinkedEntityId =: recordId]);

			Boolean successfulSoFar = true;

			for(Database.DeleteResult dr : deleteResults) {if(!dr.isSuccess()) {successfulSoFar = false;}}

			if(successfulSoFar) {this.isSuccess = true; this.userMessage = 'You have successfully removed ' + deleteResults.size() + ' file(s) from this record';}

			else{this.isSuccess = false; this.userMessage = 'Sorry, there was a problem and not all your files were removed.';}

		}

		catch (Exception e) {

			this.isSuccess = false;

			this.userMessage = 'Sorry, something went wrong. Here is the error report: ' + e.getCause() + '; ' + e.getMessage() + '; ' + e.getStackTraceString() + '; ' + e.getLineNumber();

		}
		
	}

}