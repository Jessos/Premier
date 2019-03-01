/**
 * Created by Adelaide Greenaway on 15/01/2018.
 * Test classes to cover the Portal Test Data Factory
 */

@isTest
public class Test_PortalDataFactoryTEST {

    static testMethod void Test_PortalDataFactoryTEST()
    {

//        String startTime = '01:10';
//        String endTime = '10:10';

        //Test.startTest();

        Test_PortalDataFactory testData = new Test_PortalDataFactory();

        //get a Profile
        Profile myPrf = testData.getProfileByName('System Administrator');

        //create an Internal User
        User mySysAdminUser = testData.getAUser(myPrf, 'Deanna', 'Troi');
        insert mySysAdminUser;
        
        //Test.stopTest();
        
        //create a Candidate/Employee Account and Contact
        Account myEmpAccount = testData.getACandidateAccount('Candidates');
        insert myEmpAccount;

        Contact myEmpCon = testData.getAnEmployeeContact(myEmpAccount.Id, 'Princess', 'Bubblegum');
        insert myEmpCon;
        
        System.runAs(mySysAdminUser ) {

        Test.startTest();

        //get a Community Profile
        Profile commProfile = testData.getProfileByName('Jobseeker Portal Profile');

        //create a Portal User
        User myPortalUser = testData.getAPortalUser(commProfile, myEmpCon);
        insert myPortalUser;

        //create 2c9 Timecards Config Custom Setting
        tc9_ti__ToCloudNineConfig__c toC9cfg = testData.timecardsCustomSetting('Monday',true,true);
        insert toC9cfg;

        //create tax Id record
        tc9_ti__TaxID__c taxId = testData.getTaxID();
        insert taxId;

        //create an Award Master
        tc9_ti__Award_Master__c awardMaster = testData.getAnAward();
        insert awardMaster;

        //create a Market
        tc9_ti__Market__c market = testData.getMarket(taxId.Id);
        insert market;

        //create a Site
        tc9_ti__Site__c site = testData.getASite('The Employee Portal','http://2cloud9trialforce.force.com/ThePortal');
        insert site;

        //create a Payment Term
        tc9_ti__PaymentTerm__c pt = testData.getAPaymentTerm();
        insert pt;

        //create a Payment Entity
        Account pe = testData.getAPaymentEntity();
        insert pe;

        //create a Billing Entity
        Account be = testData.getABillingEntity();
        insert be;

            
        
        //create a Billing Entity/Client Contact
        Contact invCon = testData.getAClientContact(be.Id);
        invCon.ts2__People_Status__c='On Premier Assignment';
        invCon.I_9_Review_Status_is_Completed__c=True;
        invCon.State__c='AL';  
        insert invCon;

        //create a Client Account
        Account clientAcc = testData.getAClientAccount(market.Id, be.Id, invCon.Id, 'Monday', pt.Id);
        insert clientAcc;

        //create a Super Fund
        tc9_p__Superannuation_Fund__c testFundSMSF = testData.getAFundSMSF();
        insert testFundSMSF;

        //create a Super Fund
        tc9_p__Superannuation_Fund__c testFundAPRA = testData.getAFundAPRA();
        insert testFundAPRA;

        //create a Public Holiday Calendar
        tc9_ti__Public_Holiday_Calendar__c phCal = testData.getPublicHolidayCal('2018');
        insert phCal;

        //create a Pay Code
        tc9_ti__PayCodeMaster__c payCodeMaster = testData.getAPaycode('testPC','Payment');
        insert payCodeMaster;

        //create a Payee
        tc9_p__Payee__c payee = testData.getAPayee(myEmpCon, 'PAYG', true, true);
        insert payee;

        //create a Job
        ts2__Job__c job = testData.getAJob(clientAcc.Id,myEmpCon.Id,market.Id,site.Id);
        insert job;

 		ts2__Application__c app=new ts2__Application__c(ts2__Job__c=job.Id,ts2__Candidate_Contact__c=invCon.Id);
        insert app;
            
         
        //create a Placement	
        ts2__Placement__c plc = testData.getAPlacement(job, phCal.Id, myEmpCon.Id, payee.Id, Date.today(),Date.today().addDays(50),awardMaster.Id, true, true);
   		 plc.ts2__Employee__c=invCon.Id;
   		 plc.ts2__Related_Application__c=app.Id;
         insert plc;

        //create a Timesheet
        tc9_ti__Time_Sheet__c timesheet = testData.getATimesheet(plc.Id,myEmpCon.Id,Date.today(),Date.today().addDays(7),'New');
        insert timesheet;

        //create Timesheet Entries
        List<tc9_ti__Time_Sheet_Entry__c> tseList = new List<tc9_ti__Time_Sheet_Entry__c>();

        for(Integer i=0;i<8;i++){
            Date workDate = Date.today().addDays(i+1);

            tc9_ti__Time_Sheet_Entry__c tse = testData.getATimesheetEntry(timesheet.Id, workDate,'08:00','17:00');

            tseList.add(tse);
        }
        insert tseList;
        system.debug('tseList:: '+tseList);

        customTFPortalSettings__c cust=testData.getCustomTFPortalSettings (true);
        tc9_ti__ToCloudNineConfig__c config=testData.getTimecardsSettings();
        Test.stopTest();
        
        
        }
        }
}