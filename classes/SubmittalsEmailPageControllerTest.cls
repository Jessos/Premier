@isTest (seeAllData=false)

private class SubmittalsEmailPageControllerTest {

    @testSetup static void createTestData() {

        Account account = new Account(Name = 'myTestAccountName346723');

        insert account;

        Contact contact = new Contact(AccountId=account.Id, LastName='lastName', FirstName='firstName', Email='mailinatorEmailNice@mailinator.com');

        insert contact;

        ts2__Job__c jobOrder = new ts2__Job__c(Name = 'testJob', tc9_ti__Bill_To_Contact__c = contact.Id);

        insert jobOrder;        

        ts2__Application__c application = new ts2__Application__c(ts2__Candidate_Contact__c = contact.Id, ts2__Job__c = jobOrder.Id);

        insert application;     

        Attachment attachment = new Attachment(Name = 'testAttachment', Body = Blob.valueof('text'), ParentId = application.Id);

        insert attachment;      

        ContentVersion contentVersion = new ContentVersion(VersionData = attachment.Body, Title = attachment.Name, PathOnClient = attachment.Name);

        insert contentVersion;

        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id].ContentDocumentId;

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();

        contentDocumentLink.ContentDocumentId = contentDocumentId;

        contentDocumentLink.LinkedEntityId = application.Id;

        contentDocumentLink.ShareType = 'I';

        insert contentDocumentLink;     

        ts2__Submittal__c submittal = new ts2__Submittal__c(ts2__Candidate__c = contact.Id, ts2__Related_Application__c = application.Id, ts2__Job__c = jobOrder.Id);

        insert submittal;

    }

    @isTest static void testSendEmail() {

        PageReference pageReference = Page.tc9_Forward_Candidates;

        Test.setCurrentPage(pageReference);

        List<ts2__Submittal__c> submittals = [SELECT Id FROM ts2__Submittal__c];

        ApexPages.StandardSetController standardSetController = new ApexPages.StandardSetController(submittals);

        standardSetController.setSelected(submittals);

        SubmittalsEmailPageController pageController = new SubmittalsEmailPageController(standardSetController);

        Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;

        pageController.jobOrder.ts2__Contact__c = contactId;

        pageController.unselectAllAttachments();

        pageController.selectAllAttachments();

        pageController.getEmailFolderOptions();

        pageController.getEmailTemplateOptions();

        Id selectedFolderId = pagecontroller.selectedEmailFolderId;

        pageController.selectedEmailTemplateId = [SELECT Id FROM EmailTemplate WHERE FolderId =: selectedFolderId AND IsActive = TRUE LIMIT 1].Id;

        pageController.loadSubjectAndBody();

        pageController.editOrSaveEmailBody();

        pageController.editOrSaveEmailBody();

        pageController.additionalEmails = 'niceMailinator4u@mailinator.com;superGreatMailinator4u@mailinator.com;';

        Test.startTest();

        pageController.sendEmail(); 

        Test.stopTest();

        List<Task> tasks = [SELECT Id,Status,Subject,Description FROM Task];

        System.debug('tasks: ' + tasks);

        List<EmailMessage> emailMessages = [SELECT Id FROM EmailMessage];

        Id jobOrderContactId = pageController.jobOrder.ts2__Contact__c;

        List<Contact> contacts = [SELECT Id FROM Contact WHERE Id =: jobOrderContactId];

        Integer expectedTaskCount = contacts.size() + pageController.submittals.size() + emailMessages.size();

        System.assertEquals(emailMessages.size(),1);

        System.assertEquals(tasks.size(),expectedTaskCount);

    }

    @isTest static void testPageLoadWithoutData() {

        PageReference pageReference = Page.tc9_Forward_Candidates;

        Test.setCurrentPage(pageReference);

        List<ts2__Submittal__c> submittals = new List<ts2__Submittal__c>();

        ApexPages.StandardSetController standardSetController = new ApexPages.StandardSetController(submittals);

        standardSetController.setSelected(submittals);

        SubmittalsEmailPageController pageController = new SubmittalsEmailPageController(standardSetController);

    }    

}