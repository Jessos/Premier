@isTest (seeAllData=false)

private class FileDissociationPageControllerTest {

    @testSetup static void createTestData() {

        Account account = new Account(Name = 'myTestAccountName346723');

        insert account;

        Contact contact = new Contact(AccountId=account.Id, LastName='lastName');

        insert contact;

        Attachment attachment = new Attachment(Name = 'testAttachment', Body = Blob.valueof('text'), ParentId=contact.Id);

        insert attachment;

        ts2__Job__c jobOrder = new ts2__Job__c(Name = 'testJob', tc9_ti__Bill_To_Contact__c = contact.Id);

        insert jobOrder;        

        ts2__Application__c application = new ts2__Application__c(ts2__Candidate_Contact__c = contact.Id, ts2__Job__c = jobOrder.Id);

        insert application;

        ContentVersion contentVersion = new ContentVersion(VersionData = attachment.Body, Title = attachment.Name, PathOnClient = attachment.Name);

        insert contentVersion;

        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id].ContentDocumentId;

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();

        contentDocumentLink.ContentDocumentId = contentDocumentId;

        contentDocumentLink.LinkedEntityId = application.Id;

        contentDocumentLink.ShareType = 'I';

        insert contentDocumentLink;     

    }

    @isTest static void testFileDissociation() {

        List<ts2__Application__c> applications = [SELECT Id FROM ts2__Application__c LIMIT 1];

        String recordId = String.valueOf(applications[0].Id);

        System.assertEquals(applications.size(),1);

        PageReference pageReference = Page.FileDissociationPage;

        pageReference.getParameters().put('recordId',recordId);

        Test.setCurrentPage(pageReference);

        FileDissociationPageController fileDissociationPageController = new FileDissociationPageController();    	

        for(AttachmentWrapper aw : fileDissociationPageController.attachmentWrappers) {

            aw.remove = true;

        }        

        fileDissociationPageController.deleteContentDocumentLinks();

    }

}