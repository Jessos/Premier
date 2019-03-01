/**
 * Created by Adelaide Greenaway on 2/03/2018.
 * This class contains unit test for validating the behaviour of the
 * Trialforce Portal Timesheet Controllers:
 *      Portal_Timesheet_Controller
 *      Portal_TimesheetEntry_Controller
 *
 */
@isTest(SeeAllData=false)
private class Test_PortalTimesheet {
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
    private static List<tc9_ti__Time_Sheet__c> timesheets;
    private static tc9_ti__Time_Sheet__c ts;
    private static List<tc9_ti__Time_Sheet_Entry__c> tsEntries;
    private static tc9_ti__Time_Sheet_Entry__c tse;
    private static customTFPortalSettings__c portalSettings;

    private static Adhoc_Allowances__c allowance;
    private static List<Adhoc_Allowances__c> alwEntries;
    private static tc9_ti__PayCodeMaster__c payCode;

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
        att = testData.getAttachment('portalAvatarTest', 'the image of avatar', emp.Id);
        insert att;

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
        
        
        plc = testData.getAPlacement(job, phCal.Id, emp.Id, payee.Id, Date.today().addDays(-20), Date.today().addDays(30), awdMaster.Id, true, true);
       	plc.ts2__Employee__c=emp.Id;
   		plc.ts2__Related_Application__c=app.Id;
        insert plc;

        payCode = testData.getAPaycode('testPC','Test');


    }

    static testMethod void testPortalTimesheetHome1() {
        createData();

        //create Timesheets and timesheet entries
        timesheets = new List<tc9_ti__Time_Sheet__c>();

        for(Integer i=0; i<100; i++){
            if(i<=20){
                //Current New
                ts = testData.getATimesheet(plc.Id, emp.Id, Date.today().addDays(-7), Date.today(), 'New');
            }else if(i>20 && i<=40)
            {
                //Future
                ts = testData.getATimesheet(plc.Id, emp.Id, Date.today().addDays(14), Date.today().addDays(21), 'New');
            }else if(i>40 && i<=60){
                //Rejected
                ts = testData.getATimesheet(plc.Id, emp.Id, Date.today().addDays(-7), Date.today(), 'Rejected');
            }else if(i>60 && i<=80){
                //Submitted
                ts = testData.getATimesheet(plc.Id, emp.Id, Date.today().addDays(-7), Date.today(), 'Submitted');
            }else if(i>80){
                //Approved
                ts = testData.getATimesheet(plc.Id, emp.Id, Date.today().addDays(-7), Date.today(), 'Approved');
            }
            timesheets.add(ts);
        }
        insert timesheets;

        test.startTest();
        system.runAs(usr) {
            Portal_Timesheet_Controller tsHome = new Portal_Timesheet_Controller();

            tsHome.initialisePageTurns();
            tsHome.nextApproved();

            tsHome.previousApproved();
            tsHome.getDisableNextApproved();
            tsHome.getDisablePreviousApproved();

            tsHome.nextCurrent();

            tsHome.previousCurrent();
            tsHome.getDisableNextCurrent();
            tsHome.getDisablePreviousCurrent();

            tsHome.nextFuture();

            tsHome.previousFuture();
            tsHome.getDisableNextFuture();
            tsHome.getDisablePreviousFuture();

            tsHome.nextSubmitted();

            tsHome.previousSubmitted();
            tsHome.getDisableNextSubmitted();
            tsHome.getDisablePreviousSubmitted();


        }
        test.stopTest();
    }

    static testMethod void testPortalTimesheetHome2() {

        createData();

        //set up use esign
        portalSettings = testData.getCustomTFPortalSettings(true);
        insert portalSettings;

        //create Timesheets
        timesheets = new List<tc9_ti__Time_Sheet__c>();

        for(Integer i=0; i<25; i++){
            if(i<=5){
                //Current New
                ts = testData.getATimesheet(plc.Id, emp.Id, Date.today().addDays(-7), Date.today(), 'New');
            }else if(i>5 && i<=10)
            {
                //Future
                ts = testData.getATimesheet(plc.Id, emp.Id, Date.today().addDays(14), Date.today().addDays(21), 'New');
            }else if(i>10 && i<=15){
                //Rejected
                ts = testData.getATimesheet(plc.Id, emp.Id, Date.today().addDays(-7), Date.today(), 'Rejected');
            }else if(i>15 && i<=20){
                //Submitted
                ts = testData.getATimesheet(plc.Id, emp.Id, Date.today().addDays(-7), Date.today(), 'Submitted');
            }else if(i>20){
                //Approved
                ts = testData.getATimesheet(plc.Id, emp.Id, Date.today().addDays(-7), Date.today(), 'Approved');
            }
            timesheets.add(ts);
        }
        insert timesheets;

        test.startTest();
        system.runAs(usr) {
            Portal_Timesheet_Controller tsHome = new Portal_Timesheet_Controller();

            tsHome.initialisePageTurns();

            tsHome.getDisableNextApproved();
            tsHome.getDisablePreviousApproved();

            tsHome.getDisableNextCurrent();
            tsHome.getDisablePreviousCurrent();

            tsHome.getDisableNextFuture();
            tsHome.getDisablePreviousFuture();

            tsHome.getDisableNextSubmitted();
            tsHome.getDisablePreviousSubmitted();

        }
        test.stopTest();
    }
    static testMethod void testPortalTimesheetEntryDesktop() {
        createData();

        tc9_ti__ToCloudNineConfig__c tcCfg = testData.getTimecardsSettings();
        insert tcCfg;

        //create Timesheet and timesheet entries
        tc9_ti__Time_Sheet__c timesheet = testData.getATimesheet(plc.Id, emp.Id, Date.today().addDays(-7), Date.today(), 'New');
        insert timesheet;

        timesheet.tc9_ti__Rejection_Reason__c = 'test rejection';
        update timesheet;

        //create Timesheet Entries
        tsEntries = new List<tc9_ti__Time_Sheet_Entry__c>();
        alwEntries = new List<Adhoc_Allowances__c>();

        for(Integer i=0;i<8;i++){
            Date workDate = Date.today().addDays(i+1);

            tse = testData.getATimesheetEntry(timesheet.Id, workDate,'08:00','17:00');
            //add adhoc allowance
            allowance = testData.getAnAdhocAllowance(payCode.Id, plc.Id, timesheet.Id, emp.Id, workDate);

            tsEntries.add(tse);
            alwEntries.add(allowance);
        }
        insert tsEntries;
        insert alwEntries;



        tc9_ti__Time_Sheet_Entry__c tsEntryForDel = testData.getATimesheetEntry(timesheet.Id, Date.today(), '08:00', '17:00');
        insert tsEntryForDel;

        test.startTest();
        system.runAs(usr) {
            Portal_TimesheetEntry_Controller tsEntry = new Portal_TimesheetEntry_Controller();
            tsEntry.tsId = timesheet.Id;
            tsEntry.chosenALWId = allowance.Id;

            tsEntry.addNewTSEntry_Day1();
            tsEntry.addNewTSEntry_Day2();
            tsEntry.addNewTSEntry_Day3();
            tsEntry.addNewTSEntry_Day4();
            tsEntry.addNewTSEntry_Day5();
            tsEntry.addNewTSEntry_Day6();
            tsEntry.addNewTSEntry_Day7();

            tsEntry.addNewAlw_Day1();
            tsEntry.getSelectedAlwDay1();

            tsEntry.cancelEdit();
            tsEntry.chosenTSEId = tsEntryForDel.Id;
            tsEntry.deleteTSE();

            tsEntry.saveTSE_Day1();
            tsEntry.saveTSE_Day2();
            tsEntry.saveTSE_Day3();
            tsEntry.saveTSE_Day4();
            tsEntry.saveTSE_Day5();
            tsEntry.saveTSE_Day6();
            tsEntry.saveTSE_Day7();

            tsEntry.submitTS();

            tsEntry.resubmitTS();

        }
        test.stopTest();
    }
    static testMethod void testPortalTimesheetEntryMobile() {
        createData();

        tc9_ti__ToCloudNineConfig__c tcCfg = testData.getTimecardsSettings();
        insert tcCfg;

        //create Timesheet and timesheet entries
        tc9_ti__Time_Sheet__c timesheet = testData.getATimesheet(plc.Id, emp.Id, Date.today().addDays(-7), Date.today(), 'New');
        insert timesheet;

        timesheet.tc9_ti__Rejection_Reason__c = 'test rejection';
        update timesheet;

        Attachment att = testData.getAttachment ('timesheet attachment', 'the body of the timesheet attachment', timesheet.Id);
        insert att;

        //create Timesheet Entries
        tsEntries = new List<tc9_ti__Time_Sheet_Entry__c>();

        for(Integer i=0;i<8;i++){
            Date workDate = Date.today().addDays(i+1);

            tse = testData.getATimesheetEntry(timesheet.Id, workDate,'08:00','17:00');

            tsEntries.add(tse);
        }
        insert tsEntries;

        tc9_ti__Time_Sheet_Entry__c tsEntryForDel = testData.getATimesheetEntry(timesheet.Id, Date.today(), '08:00', '17:00');
        insert tsEntryForDel;

        test.startTest();
        system.runAs(usr) {
            Portal_TimesheetEntry_Controller tsEntry = new Portal_TimesheetEntry_Controller();
            tsEntry.tsId = timesheet.Id;
            tsEntry.chosenAttId = att.Id;


            tsEntry.getSelectedDay1();
            tsEntry.getSelectedDay2();
            tsEntry.getSelectedDay3();
            tsEntry.getSelectedDay4();
            tsEntry.getSelectedDay5();
            tsEntry.getSelectedDay6();
            tsEntry.getSelectedDay7();
			tsEntry.getSelectedDTLeaveDay1();
            tsEntry.getSelectedDTLeaveDay2();
            tsEntry.getSelectedDTLeaveDay3();
            tsEntry.getSelectedDTLeaveDay4();
            tsEntry.getSelectedDTLeaveDay5();
            tsEntry.getSelectedDTLeaveDay6();
            tsEntry.getSelectedDTLeaveDay7();
            tsEntry.getSelectedDTDay1();
            tsEntry.getSelectedDTDay2();
            tsEntry.getSelectedDTDay3();
            tsEntry.getSelectedDTDay4();
            tsEntry.getSelectedDTDay5();
            tsEntry.getSelectedDTDay6();
            tsEntry.getSelectedDTDay7();

            tsEntry.addNewTSEntry_Day1();
            tsEntry.addNewTSEntry_Day2();
            tsEntry.addNewTSEntry_Day3();
            tsEntry.addNewTSEntry_Day4();
            tsEntry.addNewTSEntry_Day5();
            tsEntry.addNewTSEntry_Day6();
            tsEntry.addNewTSEntry_Day7();

            tsEntry.cancelMobEditDay1();
            tsEntry.cancelMobEditDay2();
            tsEntry.cancelMobEditDay3();
            tsEntry.cancelMobEditDay4();
            tsEntry.cancelMobEditDay5();
            tsEntry.cancelMobEditDay6();
            tsEntry.cancelMobEditDay7();

            tsEntry.cancelEdit();
            tsEntry.chosenTSEId = tsEntryForDel.Id;
            tsEntry.deleteTSE();
            tsEntry.addNewTSEntry_Day3();

            tsEntry.saveSelectedEntryDay1();
            tsEntry.saveSelectedEntryDay2();
            tsEntry.saveSelectedEntryDay3();
            tsEntry.saveSelectedEntryDay4();
            tsEntry.saveSelectedEntryDay5();
            tsEntry.saveSelectedEntryDay6();
            tsEntry.saveSelectedEntryDay7();

           // tsEntry.submitTS();

        }
        test.stopTest();
    }
    static testMethod void testPortalTimesheetEntryMobile2() {
        createData();

        tc9_ti__ToCloudNineConfig__c tcCfg = testData.getTimecardsSettings();
        insert tcCfg;

        //create Timesheet and timesheet entries
        tc9_ti__Time_Sheet__c timesheet = testData.getATimesheet(plc.Id, emp.Id, Date.today().addDays(-7), Date.today(), 'New');
        insert timesheet;

        timesheet.tc9_ti__Rejection_Reason__c = 'test rejection';
        update timesheet;

        Attachment att = testData.getAttachment ('timesheet attachment', 'the body of the timesheet attachment', timesheet.Id);
        insert att;

        //create Timesheet Entries
        tsEntries = new List<tc9_ti__Time_Sheet_Entry__c>();

        for(Integer i=0;i<8;i++){
            Date workDate = Date.today().addDays(i+1);

            tse = testData.getATimesheetEntry(timesheet.Id, workDate,'08:00','17:00');

            tsEntries.add(tse);
        }
        insert tsEntries;

        tc9_ti__Time_Sheet_Entry__c tsEntryForDel = testData.getATimesheetEntry(timesheet.Id, Date.today(), '08:00', '17:00');
        insert tsEntryForDel;

        test.startTest();
        system.runAs(usr) {
            Portal_TimesheetEntry_Controller tsEntry = new Portal_TimesheetEntry_Controller();
            tsEntry.tsId = timesheet.Id;
            tsEntry.chosenAttId = att.Id;

            tsEntry.submitTS();

            tsEntry.resubmitTS();

        }
        test.stopTest();
    }

    static testMethod void testPortalTimesheetAllowances() {
        createData();

        tc9_ti__ToCloudNineConfig__c tcCfg = testData.getTimecardsSettings();
        insert tcCfg;

        //create Timesheet and timesheet entries
        tc9_ti__Time_Sheet__c timesheet = testData.getATimesheet(plc.Id, emp.Id, Date.today().addDays(-7), Date.today(), 'New');
        insert timesheet;

        timesheet.tc9_ti__Rejection_Reason__c = 'test rejection';
        update timesheet;

        //create Timesheet Entries

        alwEntries = new List<Adhoc_Allowances__c>();

        for(Integer i=0;i<8;i++){
            Date workDate = Date.today().addDays(i+1);

            //add adhoc allowance
            allowance = testData.getAnAdhocAllowance(payCode.Id, plc.Id, timesheet.Id, emp.Id, workDate);

            alwEntries.add(allowance);
        }
        insert alwEntries;


        Adhoc_Allowances__c alwToDel = testData.getAnAdhocAllowance(payCode.Id, plc.Id, timesheet.Id, emp.Id, Date.today());
        insert alwToDel;

        test.startTest();
        system.runAs(usr) {
            Portal_TimesheetEntry_Controller tsEntry = new Portal_TimesheetEntry_Controller();
            tsEntry.tsId = timesheet.Id;
            tsEntry.chosenALWId = allowance.Id;

            tsEntry.addNewAlw_Day1();
            tsEntry.addNewAlw_Day2();
            tsEntry.addNewAlw_Day3();
            tsEntry.addNewAlw_Day4();
            tsEntry.addNewAlw_Day5();
            tsEntry.addNewAlw_Day6();
            tsEntry.addNewAlw_Day7();

            tsEntry.getSelectedAlwDay1();
            tsEntry.getSelectedAlwDay2();
            tsEntry.getSelectedAlwDay3();
            tsEntry.getSelectedAlwDay4();
            tsEntry.getSelectedAlwDay5();
            tsEntry.getSelectedAlwDay6();
            tsEntry.getSelectedAlwDay7();

            tsEntry.cancelMobEditAlwDay1();
            tsEntry.cancelMobEditAlwDay2();
            tsEntry.cancelMobEditAlwDay3();
            tsEntry.cancelMobEditAlwDay4();
            tsEntry.cancelMobEditAlwDay5();
            tsEntry.cancelMobEditAlwDay6();
            tsEntry.cancelMobEditAlwDay7();
           // tsEntry.cancelEdit();
//            tsEntry.chosenALWId = alwToDel.Id;
//            tsEntry.deleteALW();

            //tsEntry.saveAllowances();


        }
        test.stopTest();
    }

    static testMethod void testPortalTimesheetLeaveEntry() {
        createData();

        tc9_ti__ToCloudNineConfig__c tcCfg = testData.getTimecardsSettings();
        insert tcCfg;

        //create Timesheet and timesheet entries
        tc9_ti__Time_Sheet__c timesheet = testData.getATimesheet(plc.Id, emp.Id, Date.today().addDays(-7), Date.today(), 'New');
        insert timesheet;

        timesheet.tc9_ti__Rejection_Reason__c = 'test rejection';
        update timesheet;

        //create Timesheet Entries
        tsEntries = new List<tc9_ti__Time_Sheet_Entry__c>();

        for(Integer i=0;i<8;i++){
            Date workDate = Date.today().addDays(i+1);

            tse = testData.getATimesheetEntry(timesheet.Id, workDate,'08:00','17:00');
            tse.tc9_ti__Type_of_Leave__c = 'Annual Leave';

            tsEntries.add(tse);
        }
        insert tsEntries;



        tc9_ti__Time_Sheet_Entry__c tsEntryForDel = testData.getATimesheetEntry(timesheet.Id, Date.today(), '08:00', '17:00');
        insert tsEntryForDel;

        test.startTest();
        system.runAs(usr) {
            Portal_TimesheetEntry_Controller tsEntry = new Portal_TimesheetEntry_Controller();
            tsEntry.tsId = timesheet.Id;
            tsEntry.chosenTSEId = tsEntries[0].Id;

            tsEntry.addNewTSLeaveEntry_Day1();
            tsEntry.addNewTSLeaveEntry_Day2();
            tsEntry.addNewTSLeaveEntry_Day3();
            tsEntry.addNewTSLeaveEntry_Day4();
            tsEntry.addNewTSLeaveEntry_Day5();
            tsEntry.addNewTSLeaveEntry_Day6();
            tsEntry.addNewTSLeaveEntry_Day7();

            tsEntry.saveLeave_Day1();
            tsEntry.saveLeave_Day2();
            tsEntry.saveLeave_Day3();
            tsEntry.saveLeave_Day4();
            tsEntry.saveLeave_Day5();
            tsEntry.saveLeave_Day6();
            tsEntry.saveLeave_Day7();


        }
        test.stopTest();
    }
}