/**
 * Created by Adelaide Greenaway on 6/03/2018.
 * This class contains unit test for validating the behaviour of the
 * Trialforce Portal Payment History Controllers:
 *      Portal_PaymentHistory_Controller
 */
@isTest(SeeAllData=false)
private class Test_PortalPaymentHistory {
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
    private static Account paymentEntity;
    private static Contact invCon;
    private static tc9_ti__PaymentTerm__c paymentTerm;
    private static ts2__Job__c job;
    private static ts2__Placement__c plc;
    private static tc9_ti__Site__c site;
    private static tc9_ti__Award_Master__c awdMaster;
    private static tc9_ti__Public_Holiday_Calendar__c phCal;
    private static customTFPortalSettings__c portalSettings;
    private static List<tc9_p__Pay_Advice__c> payAdvices;
    private static tc9_p__Pay_Advice__c payAdvice;
    private static List<tc9_p__Contractor_Invoice__c> rctiAdvices;
    private static tc9_p__Contractor_Invoice__c rctiAdvice;

    private static Test_PortalDataFactory testData;


    private static void createData() {
        testData = new Test_PortalDataFactory();

        //create/setup Portal User
        acc = testData.getACandidateAccount('Test Account 4567');
        insert acc;
        emp = testData.getAnEmployeeContact(acc.Id, 'Jane', 'Lane');
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
        paymentEntity = testData.getAPaymentEntity();
        insert paymentEntity;
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

        //create some Pay Advices
        payAdvices = new List<tc9_p__Pay_Advice__c>();
        rctiAdvices = new List<tc9_p__Contractor_Invoice__c>();

        for(Integer i=0; i<20; i++){
            payAdvice = testData.getAPayAdvice(paymentEntity.Id, Date.today().addDays(7), Date.today().addDays(7), Date.today().addDays(6), emp.Id);

            payAdvices.add(payAdvice);

            rctiAdvice = testData.getAnRCTI(paymentEntity.Id, Date.today().addDays(-14), Date.today().addDays(-7), Date.today().addDays(-6), emp.Id);

            rctiAdvices.add(rctiAdvice);
        }
        insert payAdvices;
        insert rctiAdvices;
    }

    static testMethod void testPortalPaymentHistory() {
        createData();

        test.startTest();
        system.runAs(usr) {
            Portal_PaymentHistory_Controller payHis = new Portal_PaymentHistory_Controller();

            payHis.next();
            payHis.previous();
            payHis.getDisableNext();
            payHis.getDisableNext();

        }
        test.stopTest();
    }

}