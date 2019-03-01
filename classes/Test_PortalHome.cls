/**
 * Created by Adelaide Greenaway on 1/03/2018.
 * This class contains unit test for validating the behaviour of the
 * Trialforce Portal Home, Base & Agreement Base controllers:
 *      Portal_Home_Controller
 *      Portal_Base_Controller
 *      Portal_AgreementBase_Controller
 */

@isTest(SeeAllData=false)
private class Test_PortalHome {
    private static Account acc;
    private static Contact emp;
    private static Profile prof;
    private static User usr;
    private static tc9_p__Payee__c payee;
    private static Account client;
    private static tc9_ti__Market__c mkt;
    private static tc9_ti__TaxID__c tax;
    private static Account billingEntity;
    private static Contact invCon;
    private static tc9_ti__PaymentTerm__c paymentTerm;
    private static ts2__Job__c job;
    private static ts2__Placement__c plcAgree;
    private static ts2__Placement__c plcNoAgree;
    private static tc9_ti__Site__c site;
    private static tc9_ti__Award_Master__c awdMaster;
    private static tc9_ti__Public_Holiday_Calendar__c phCal;
    private static Task task;
    private static tc9_ti__Time_Sheet__c timeSheet;
    private static Attachment att;
    private static cloudNineSettings__c esignSettings;
    private static echosign_dev1__SIGN_Agreement__c agreement1;
    private static echosign_dev1__SIGN_Agreement__c agreement2;
    private static echosign_dev1__SIGN_Agreement__c agreement3;
    private static echosign_dev1__SIGN_Agreement__c agreement4;

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
        payee = testData.getAPayee(emp,'PAYG',true, true);
        insert payee;

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
        site = testData.getASite('theSite','www.theSite.com');
        insert site;
        awdMaster = testData.getAnAward();
        insert awdMaster;
        phCal = testData.getPublicHolidayCal('2018');
        insert phCal;
        job = testData.getAJob(client.Id, emp.Id, mkt.Id, site.Id);
        insert job;
        ts2__Application__c app=new ts2__Application__c(ts2__Job__c=job.Id,ts2__Candidate_Contact__c=emp.Id);
        insert app;
        plcAgree = testData.getAPlacement(job, phCal.Id, emp.Id, payee.Id, Date.today().addDays(-20), Date.today().addDays(30), awdMaster.Id, true, true);
        plcAgree.ts2__Employee__c=emp.Id;
        plcAgree.ts2__Related_Application__c=app.Id;
        insert plcAgree;
        plcNoAgree = testData.getAPlacement(job, phCal.Id, emp.Id, payee.Id, Date.today().addDays(-20), Date.today().addDays(30), awdMaster.Id, false, false);
        plcNoAgree.ts2__Employee__c=emp.Id;
        plcNoAgree.ts2__Related_Application__c=app.Id;
        insert plcNoAgree;

        //set up esign settings and create agreements
        esignSettings = testData.getEsignSettings();
        insert esignSettings;


    }

    static testMethod void testPortalHome_1() {
        createData();

        test.startTest();
        system.runAs(usr) {
            Portal_Home_Controller home = new Portal_Home_Controller();
           // system.assertEquals(home.currentPayee.Id, payee.Id);
          //**  system.assertEquals(home.notificationCount, 1);
            system.assertEquals(home.personalIncomplete, true);
            //system.assertEquals(home.superIncomplete, true);
            //system.assertEquals(home.taxIncomplete, true);
            //system.assertEquals(home.bankIncomplete, true);
            system.assertEquals(home.tsOutstanding, false);
            system.assertEquals(home.agreeOutstanding, false);
            //system.assertEquals(home.showAnnouncements, false);
           //** system.assertEquals(home.detailsIncomplete, true);
        }
        test.stopTest();
    }
    static testMethod void testPortalHome_2() {
        createData();

        //retest incompletes and notification counts
        payee.TFN_Provided__c = true;
        payee.Super_Details_Provided__c = true;
        payee.Bank_Details_Provided__c = true;
        emp.Personal_Details_Provided__c = true;
        update payee;
        update emp;

        //add overdue timesheets to placement
        timeSheet = testData.getATimesheet(plcAgree.Id, emp.Id, Date.today().addDays(-14), Date.today().addDays(-7), 'New');
        insert timeSheet;

        test.startTest();
        system.runAs(usr) {
            Portal_Home_Controller home = new Portal_Home_Controller();

            //system.assertEquals(home.currentPayee.Id, payee.Id);
            //**system.assertEquals(home.notificationCount, 1);
            system.assertEquals(home.personalIncomplete, false);
            //system.assertEquals(home.superIncomplete, false);
            //system.assertEquals(home.taxIncomplete, false);
            //system.assertEquals(home.bankIncomplete, false);
            system.assertEquals(home.tsOutstanding, true);
            system.assertEquals(home.agreeOutstanding, false);
            //system.assertEquals(home.showAnnouncements, false);
            system.assertEquals(home.detailsIncomplete, false);

        }
        test.stopTest();
    }

    static testMethod void testPortalHome_3() {

        createData();

        //create general announcement

        Id taskRT = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Portal Message').getRecordTypeId();
        task = testData.getATask(taskRT, payee.Id, Date.today().addDays(10), emp.Id, usr.Id);
        //insert task;

        //system.debug('TASK RECORD TYPE NAME:: '+getTask.RecordType.Name);
        test.startTest();
        system.runAs(usr) {
            Portal_Home_Controller home = new Portal_Home_Controller();

            //system.assertEquals(home.showAnnouncements, true);
        }
        test.stopTest();

    }
    static testMethod void testPortalHome_4() {

        createData();

        //create general announcement
        Id taskRT = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Portal Message').getRecordTypeId();
        task = testData.getATask(taskRT, payee.Id, Date.today().addDays(10), emp.Id, usr.Id);
        //insert task;

        task.Description='Lorem ipsum dolor sit amet, nonummy ligula volutpat ' +
                'hac integer nonummy. Suspendisse ultricies, congue etiam tellus, ' +
                'erat libero, nulla eleifend, mauris pellentesque. Suspendisse integer ' +
                'praesent vel, integer gravida mauris, fringilla vehicula lacinia ' +
                'nonLorem ipsum dolor sit amet, nonummy ligula volutpat hac integer ' +
                'nonummy. Suspendisse ultricies, congue etiam tellus, erat libero, ' +
                'nulla eleifend, mauris pellentesque. Suspendisse integer praesent ' +
                'vel, integer gravida mauris, fringilla vehicula lacinia non' +
                'Lorem ipsum dolor sit amet, nonummy ligula volutpat ' +
                'hac integer nonummy. Suspendisse ultricies, congue etiam tellus, ' +
                'erat libero, nulla eleifend, mauris pellentesque. Suspendisse integer ' +
                'praesent vel, integer gravida mauris, fringilla vehicula lacinia ' +
                'nonLorem ipsum dolor sit amet, nonummy ligula volutpat hac integer ' +
                'nonummy. Suspendisse ultricies, congue etiam tellus, erat libero, ' +
                'nulla eleifend, mauris pellentesque. Suspendisse integer praesent ' +
                'vel, integer gravida mauris, fringilla vehicula lacinia non';
        //update task;

        test.startTest();
        system.runAs(usr) {
            Portal_Home_Controller home = new Portal_Home_Controller();
            home.paylocityportal();
            home.paylocityonboarding();
           // system.assertEquals(home.showAnnouncements, true);
        }
        test.stopTest();
    }
    static testMethod void testPortalBase() {

        createData();
        att = testData.getAttachment('portalAvatarTest', 'the image of avatar', emp.Id);
        insert att;

        test.startTest();
        system.runAs(usr) {
            Portal_Base_Controller base = new Portal_Base_Controller();
            base.showContent = true;
            base.showMenu = true;
            base.showConfirmation = true;
            base.showError = true;
            base.Error = 'an error string';

            base.toggleContent();
            system.assertEquals(base.showContent, false);
            base.toggleContent();
            system.assertEquals(base.showContent, true);
        }
        test.stopTest();

    }
    static testMethod void testPortalAgreementBase() {

        createData();
        customTFPortalSettings__c settings = testData.getCustomTFPortalSettings(false);
        insert settings;

        payee.Use_2c9_Portal_Agreement_Logic__c = false;
        payee.x2c9_Portal_Payee_Agreement_Visible__c = false;
        update payee;

        test.startTest();
        system.runAs(usr) {

            Portal_AgreementBase_Controller agbase = new Portal_AgreementBase_Controller();
            system.assertEquals(agbase.stopTSEntryPayee, false);
        }
        test.stopTest();
    }
    static testMethod void testPortalAgreementBase2() {

        createData();
        customTFPortalSettings__c settings = testData.getCustomTFPortalSettings(true);
        insert settings;

        test.startTest();
        system.runAs(usr) {

            Portal_AgreementBase_Controller agbase = new Portal_AgreementBase_Controller();
            system.assertEquals(agbase.stopTSEntryPayee, false);
        }
        test.stopTest();

    }
    static testMethod void testPortalAgreementBase2a() {

        createData();
        customTFPortalSettings__c settings = testData.getCustomTFPortalSettings(true);
        insert settings;

        payee.Use_2c9_Portal_Agreement_Logic__c = false;
        payee.x2c9_Portal_Payee_Agreement_Visible__c = false;
        update payee;

        test.startTest();
        system.runAs(usr) {

            Portal_AgreementBase_Controller agbase = new Portal_AgreementBase_Controller();
            system.assertEquals(agbase.stopTSEntryPayee, false);
        }
        test.stopTest();

    }
    static testMethod void testPortalAgreementBase3() {

        createData();
        agreement1 = testData.getAgreement(payee.Id, plcNoAgree.Id, 'Draft');
        insert agreement1;
        agreement2 = testData.getAgreement(payee.Id, plcAgree.Id, 'Signed');
        insert agreement2;

        agreement3 = testData.getAgreement(payee.Id, plcNoAgree.Id, 'Signed');
        insert agreement3;
        agreement4 = testData.getAgreement(payee.Id, plcAgree.Id, 'Draft');
        insert agreement4;

        customTFPortalSettings__c settings = testData.getCustomTFPortalSettings(true);
        insert settings;

        test.startTest();
        system.runAs(usr) {

            Portal_AgreementBase_Controller agbase = new Portal_AgreementBase_Controller();
            system.assertEquals(agbase.stopTSEntryPayee, true);
            system.assertEquals(agbase.agreeOutstanding, true);

            system.assertEquals(agbase.payeeAgreementsExist, true);
            system.assertEquals(agbase.plcAgreementsExist, true);

            system.assertEquals(agbase.agreeOutstanding, true);

        }
        test.stopTest();
    }
    static testMethod void testPortalAgreementBase3a() {

        createData();
        agreement1 = testData.getAgreement(payee.Id, plcNoAgree.Id, 'Draft');
        insert agreement1;
        agreement4 = testData.getAgreement(payee.Id, plcAgree.Id, 'Draft');
        insert agreement4;

        customTFPortalSettings__c settings = testData.getCustomTFPortalSettings(true);
        insert settings;

        payee.Use_2c9_Portal_Agreement_Logic__c = false;
        update payee;

        test.startTest();
        system.runAs(usr) {

            Portal_AgreementBase_Controller agbase = new Portal_AgreementBase_Controller();
            system.assertEquals(agbase.stopTSEntryPayee, false);

        }
        
        test.stopTest();
    }

}