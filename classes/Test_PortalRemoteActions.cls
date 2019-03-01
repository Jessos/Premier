/**
 * Created by Adelaide Greenaway on 6/03/2018.
 * This class contains unit test for validating the behaviour of the
 * Trialforce Portal Remote Actions in the following Controllers:
 *      Portal_Expense_Controller
 *      Portal_Expense_Creation_Controller
 *
 */
@isTest(SeeAllData=false)
private class Test_PortalRemoteActions {
    private static Account acc;
    private static Contact emp;
    private static Profile prof;
    private static User usr;
    private static tc9_p__Payee__c payee;
    private static tc9_p__Payments_Configuration__c payconfig;
    private static Attachment att;

    private static Account client;
    private static tc9_ti__Market__c mkt;
    private static tc9_ti__TaxID__c tax;
    private static Account billingEntity;
    private static Contact invCon;
    private static tc9_ti__PaymentTerm__c paymentTerm;
    private static ts2__Job__c job;
    private static ts2__Placement__c plc;
    private static tc9_ti__Site__c site;
    private static tc9_ti__Award_Master__c awdMaster;
    private static tc9_ti__Public_Holiday_Calendar__c phCal;
    private static customTFPortalSettings__c portalSettings;
    private static List<tc9_ti__Expense_Claim__c> expenseClaims;
    private static tc9_ti__Expense_Claim__c expenseClaim;
    private static tc9_ti__Expense__c expense;
    private static tc9_p__Superannuation_Fund__c apraFund;

    private static Test_PortalDataFactory testData;


    private static void createData() {
        testData = new Test_PortalDataFactory();

        //create/setup Portal User
        acc = testData.getACandidateAccount('Test Account 4567');
        insert acc;
        emp = testData.getAnEmployeeContact(acc.Id, 'Jane', 'Lane');
        emp.ts2__People_Status__c='On Premier Assignment';
        emp.I_9_Review_Status_is_Completed__c=True;
        emp.State__c='AL'; 
        insert emp;
        prof = testData.getProfileByName('Jobseeker Portal Profile');
        usr = testData.getAPortalUser(prof, emp);
        insert usr;
        payee = testData.getAPayee(emp, 'PAYG', true, true);
        insert payee;
        payconfig = testData.getPaymentsSettings();
        insert payconfig;


        //create/setup Client Account
        tax = testData.getTaxID();
        insert tax;
        mkt = testData.getMarket(tax.Id);
        insert mkt;
        billingEntity = testData.getABillingEntity();
        insert billingEntity;
        paymentTerm = testData.getAPaymentTerm();
        insert paymentTerm;
        invCon = testData.getAClientContact(billingEntity.Id);
        insert invCon;
        client = testData.getAClientAccount(mkt.Id, billingEntity.Id, invCon.Id, 'Monday', paymentTerm.Id);
        insert client;

        //create/setup Placement
        site = testData.getASite('theSite', 'www.theSite.com');
        insert site;
        awdMaster = testData.getAnAward();
        insert awdMaster;
        phCal = testData.getPublicHolidayCal('2018');
        insert phCal;
        job = testData.getAJob(client.Id, emp.Id, mkt.Id, site.Id);
        insert job;
        
        ts2__Application__c app=new ts2__Application__c(ts2__Job__c=job.Id,ts2__Candidate_Contact__c=emp.Id);
        insert app;
        
        plc = testData.getAPlacement(job, phCal.Id, emp.Id, payee.Id, Date.today().addDays(-20), Date.today().addDays(30), awdMaster.Id, true, true);
       	plc.ts2__Employee__c=emp.Id;
   		plc.ts2__Related_Application__c=app.Id;
        insert plc;

    }

    static testMethod void testPortalUploadAtt() {
        createData();

        test.startTest();

            //create Expense Claims and Expenses
            expenseClaim = testData.getAnExpenseClaim(plc.Id, Date.today(), emp.Id, 'New');
            insert expenseClaim;

            att = testData.getAttachment('portalAvatarTest', 'the image of avatar', expenseClaim.Id);
            insert att;
            String attId = att.Id;

            String parentId = expenseClaim.id;
            //jpg
            Portal_Expense_Creation_Controller.doUploadAttachment(parentId, 'attachment string stuff', 'theName.jpg', null, 'desc');

            //gif
            Portal_Expense_Creation_Controller.doUploadAttachment(parentId, 'attachment string stuff', 'theName.GIF', null, 'desc');

            //pdf
            Portal_Expense_Creation_Controller.doUploadAttachment(parentId, 'attachment string stuff', 'theName.pdf', null, 'desc');

            //doc
            Portal_TimesheetEntry_Controller.doUploadAttachment(parentId, 'attachment string stuff', 'theName.DOC', null, 'desc');

            //doc
            Portal_TimesheetEntry_Controller.doUploadAttachment(parentId, 'attachment string stuff', 'theName.DOC', attId, 'desc');

            //xls
            Portal_ProfileSuperDetails_Controller.doUploadAttachment(parentId, 'attachment string stuff', 'theName.xls', null, 'desc');

            //portal avatar
            Portal_Home_Controller.doUploadAttachment(parentId, 'attachment string stuff', 'portalAvatar.jpg', null, 'desc');

        test.stopTest();
    }
    static testMethod void testPortalSearchFund() {
       // createData();

        test.startTest();
        testData = new Test_PortalDataFactory();
        apraFund = testData.getAFundAPRA();
        insert apraFund;

        Portal_ProfileSuperDetails_Controller.searchFund('Test fund');

        test.stopTest();
    }
}