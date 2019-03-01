/**
 * Created by Adelaide Greenaway on 6/03/2018.
 * This class contains unit test for validating the behaviour of the
 * Trialforce Portal Expense Controllers:
 *      Portal_Expense_Controller
 *      Portal_Expense_Creation_Controller
 *
 */
@isTest(SeeAllData=false)
private class Test_PortalExpense {
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
        emp.Email='test@jhfgsd.com';
        insert emp;
         //T01 R  
        //prof = testData.getProfileByName('Timecards Community User');
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

    static testMethod void testPortalExpenseHome1() {
        createData();
        //create Expense Claims and Expenses
        expenseClaims = new List<tc9_ti__Expense_Claim__c>();

        for(Integer i=0; i<80; i++){
            if(i<=20){
                //Current New
                expenseClaim = testData.getAnExpenseClaim(plc.Id, Date.today(), emp.Id, 'New');
            }else if(i>20 && i<=40)
            {
                //Rejected
                expenseClaim = testData.getAnExpenseClaim(plc.Id, Date.today(), emp.Id, 'Rejected');
            }else if(i>40 && i<=60){
                //Submitted
                expenseClaim = testData.getAnExpenseClaim(plc.Id, Date.today(), emp.Id, 'Submitted');
            }else if(i>60){
                //Approved
                expenseClaim = testData.getAnExpenseClaim(plc.Id, Date.today(), emp.Id, 'Approved');
            }
            expenseClaims.add(expenseClaim);
        }
        insert expenseClaims;

        test.startTest();
        system.runAs(usr) {
            Portal_Expense_Controller expHome = new Portal_Expense_Controller();

            expHome.initialisePageTurns();
            expHome.nextApproved();
            expHome.previousApproved();
            expHome.nextApproved();
            expHome.getDisableNextApproved();
            expHome.getDisablePreviousApproved();
            expHome.nextNew();
            expHome.previousNew();
            expHome.nextNew();
            expHome.getDisableNextNew();
            expHome.getDisablePreviousNew();
            expHome.nextRejected();
            expHome.previousRejected();
            expHome.nextRejected();
            expHome.getDisableNextRejected();
            expHome.getDisablePreviousRejected();
            expHome.nextSubmitted();
            expHome.previousSubmitted();
            expHome.nextSubmitted();
            expHome.getDisableNextSubmitted();
            expHome.getDisablePreviousSubmitted();

            expHome.chosenPlcId = plc.Id;
            expHome.setupNewExpClaim();
            expHome.createNew();

        }
        test.stopTest();
    }
 /*   static testMethod void testPortalExpenseHome2() {
        createData();

        test.startTest();
        system.runAs(usr) {
            Portal_Expense_Controller expHome = new Portal_Expense_Controller();

            expHome.chosenPlcId = plc.Id;
            expHome.setupNewExpClaim();
            expHome.createNew();

        }
        test.stopTest();
    }*/
    static testMethod void testPortalExpenses1() {
        createData();

        //create Expense Claims and Expenses
        expenseClaim = testData.getAnExpenseClaim(plc.Id, Date.today(), emp.Id, 'New');
        insert expenseClaim;

        test.startTest();
        system.runAs(usr) {
            ApexPages.currentPage().getParameters().put('Id',expenseClaim.Id);
            Portal_Expense_Creation_Controller exp = new Portal_Expense_Creation_Controller();

            //create Expense Claims and Expenses
            expenseClaim = testData.getAnExpenseClaim(plc.Id, Date.today(), emp.Id, 'New');
            insert expenseClaim;

            expense = testData.getAnExpense(expenseClaim.Id, Date.today(), 'Car Expense', 'Travel', 10, 2, true);
            insert expense;
            att = testData.getAttachment('TestFileExp','this is a test', expenseClaim.Id);
            insert att;

            exp.expClaimID = expenseClaim.Id;
            exp.preTaxAmount = 1;
            exp.taxAmount = 2;
            exp.toggleContent();
            exp.cancelEdit();
            //exp.sumTotal();
            exp.getTypes();

            exp.saveExpenses();
            exp.chosenExpId = expense.Id;
            exp.expClaimID = expenseClaim.Id;
            exp.addNewExp();
            exp.selectToEdit();
            exp.saveMobExp();
            exp.submitExp();
            exp.resubmitExp();

//            exp.chosenAttId = att.Id;
//            exp.deleteAtt();

            exp.deleteExp();

            String parentId = expenseClaim.id;
            Portal_Expense_Creation_Controller.doUploadAttachment(parentId, 'attachment string stuff', 'theName.jpg', null, 'desc');

        }
        test.stopTest();
    }
    static testMethod void testPortalExpenses2() {
        createData();
        //create Expense Claims and Expenses
        expenseClaim = testData.getAnExpenseClaim(plc.Id, Date.today(), emp.Id, 'New');
        insert expenseClaim;

        test.startTest();
        system.runAs(usr) {
            ApexPages.currentPage().getParameters().put('Id',expenseClaim.Id);
            Portal_Expense_Creation_Controller exp = new Portal_Expense_Creation_Controller();


            exp.expClaimID = expenseClaim.Id;
            exp.deleteExpClaim();
        }
        test.stopTest();
    }
}