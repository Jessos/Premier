/**
 * Created by Adelaide Greenaway on 2/03/2018.
 * This class contains unit test for validating the behaviour of the
 * Trialforce Portal Profile Controllers:
 *      Portal_ProfilePersonal_Controller
 *      Portal_ProfileBankDetails_Controller
 *      Portal_ProfileSuperDetails_Controller
 *      Portal_ProfileTaxDetails_Controller
 */
@isTest(SeeAllData=false)
private class Test_PortalProfile {
    private static Account acc;
    private static Contact emp;
    private static Profile prof;
    private static User usr;
    private static tc9_p__Payee__c payee;
    private static tc9_p__Payments_Configuration__c payconfig;
    private static Attachment att;
    private static tc9_p__Superannuation_Fund__c apraFund;

    private static Test_PortalDataFactory testData;


    private static void createData() {
        testData = new Test_PortalDataFactory();

        //create/setup Portal User
        acc = testData.getACandidateAccount('Test Account 4567');
        insert acc;
        emp = testData.getAnEmployeeContact(acc.Id, 'Jane', 'Lane');
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

        apraFund = testData.getAFundAPRA();
        insert apraFund;


    }

    static testMethod void testPortalPersonal() {
        createData();

        test.startTest();
        system.runAs(usr) {
            Portal_ProfilePersonal_Controller personal = new Portal_ProfilePersonal_Controller();

            personal.toggleContent();
            personal.Cancel();
            personal.city = 'Amsterdam';
            personal.street = 'street';
            personal.country = 'country';
            personal.postalcode = '111';
            personal.streetOne ='street';
            personal.cityOne = 'city 1';
            personal.stateOne = 'state1';
            personal.postalcodeOne = '1111';
            personal.countryOne = 'country1';
            //personal.phone = '1212121';
            personal.mobile = '123213123';
            personal.email = 'test.test@test.com';
            //personal.emerRelnship ='tester';
           // personal.emerName = 'emerName';
           // personal.emerNumber = '123214214';

            personal.Submit();
            system.assertEquals(personal.city, 'Amsterdam');

        }
        test.stopTest();
    }
    static testMethod void testPortalBankDetails() {
        createData();

        test.startTest();
        system.runAs(usr) {
            Portal_ProfileBankDetails_Controller bank = new Portal_ProfileBankDetails_Controller();

            bank.streetOne ='street';
            bank.cityOne = 'city 1';
            bank.stateOne = 'state1';
            bank.postalcodeOne = '1111';
            bank.countryOne = 'country1';
            bank.addBA2 = 'No';
            bank.getSelectedItem1 = 'percent1';
            bank.getSelectedItem2 = 'percent2';
            bank.getSelectedItem3 = 'No';
            bank.bankTypeSelected = 'International';
            bank.getCountries();
            bank.loadSelectionDetails();
            bank.Cancel();
            bank.submitAus_BankDetails();
            bank.submitCompany();
            bank.submitInt();
            bank.getIntCurrencies();

            system.assertEquals(bank.cityOne, 'city 1');

        }
        test.stopTest();
    }

    static testMethod void testPortalBankDetails2() {
        createData();
        payee.tc9_p__GST_Registered__c = false;
//        payee.tc9_p__Bank_Intl_Country__c = 'UK';
//        payee.tc9_p__Bank_Intl_Receiving_Currency__c = 'USD';
        payee.tc9_p__Bank_Account_2_Fixed_Amount__c = 6;
        payee.tc9_p__Bank_Account_1_Fixed_Amount__c = 2;
        payee.tc9_p__Bank_Account_1_Allocated_Percentage__c = null;
        payee.tc9_p__Bank_Account_2_Allocated_Percentage__c = null;
        update payee;

        test.startTest();
        system.runAs(usr) {
            Portal_ProfileBankDetails_Controller bank = new Portal_ProfileBankDetails_Controller();

            bank.streetOne ='street';
            bank.cityOne = 'city 1';
            bank.stateOne = 'state1';
            bank.postalcodeOne = '1111';
            bank.countryOne = 'country1';
            bank.addBA2 = 'Yes';
            bank.getSelectedItem1 = 'percent1';
            bank.bankAcc_1_AllocPc = 4;
            bank.getSelectedItem2 = 'percent2';
            bank.bankAcc_2_AllocPc = 96;
            bank.getSelectedItem3 = 'Yes';
            bank.bankTypeSelected = 'Australian';
            bank.getCountries();
            bank.loadSelectionDetails();
            bank.Cancel();
            bank.submitAus_BankDetails();
            bank.submitCompany();
            //bank.submitInt();
            bank.getIntCurrencies();

            bank.bankTypeSelected = 'International';
            bank.loadSelectionDetails();
            bank.submitInt();

            system.assertEquals(bank.bankTypeSelected, 'International');


        }
        test.stopTest();
    }

    static testMethod void testPortalSuperDetailsAPRA() {
        createData();

       /* test.startTest();
        system.runAs(usr) {
            Portal_ProfileSuperDetails_Controller superDetails = new Portal_ProfileSuperDetails_Controller();

            superDetails.empNomMemberNumber = '12321231';
            superDetails.searchedFund = apraFund.Id;//'AMP TEST';
            superDetails.selectedFund = apraFund.Id;//'AMP TEST';


            superDetails.loadSelectionDetails();
            superDetails.getFund();

            superDetails.superTypeSelected = 'apraRSA';
            superDetails.saveSuper();

        system.assertEquals(superDetails.superTypeSelected, 'apraRSA');

        }
        test.stopTest();*/
    }
    static testMethod void testPortalSuperDetailsEmpNom() {
        createData();

        payee.Fund_Option_Selected__c = 'Employer Nominated';
        update payee;

        test.startTest();
        system.runAs(usr) {
            Portal_ProfileSuperDetails_Controller superDetails = new Portal_ProfileSuperDetails_Controller();

            superDetails.loadSelectionDetails();
            superDetails.getFund();

            superDetails.empNomMemberNumber = '12321231';
            superDetails.superTypeSelected = 'empNom';
            superDetails.haveEmpNomNumber = 'No';
            superDetails.saveSuper();

            superDetails.haveEmpNomNumber = 'Yes';
            superDetails.saveSuper();

//            system.assertEquals(superDetails.superTypeSelected, 'empNom');
        }
        test.stopTest();
    }
    static testMethod void testPortalSuperDetailsSMSF() {
        createData();
        payee.Fund_Option_Selected__c = 'SMSF';
        update payee;

        Id smsfFundRTId;
        smsfFundRTId = [SELECT Id from RecordType where developerName = 'Self_Managed' LIMIT 1].Id;

        test.startTest();
        system.runAs(usr) {
            Portal_ProfileSuperDetails_Controller superDetails = new Portal_ProfileSuperDetails_Controller();

            superDetails.loadSelectionDetails();
            superDetails.getFund();

            superDetails.smsfFundName = 'My SMSF TESTING FUND';
            superDetails.smsfFundABN = '45004189708';

            superDetails.street = '1 Smith Street';
            superDetails.city = 'Melbourne';
            superDetails.state = 'Victoria';
            superDetails.postalcode = '3000';
            superDetails.country = 'Australia';

            superDetails.smsfFundESA = 'asdftest';
            superDetails.smsfFundBSB ='111111';
            superDetails.smsfFundAccName = 'test Acc Name';
            superDetails.smsfFundAccNum = '12341234';
            superDetails.smsfFundPhone = '12312312321';
            superDetails.smsfFundEmail = 'smsftest@test.com';
            superDetails.smsfFundTrusteeDec = true;
            superDetails.chosenAttId = att.Id;
            superDetails.superTypeSelected = 'smsf';
            superDetails.smsfRecType = smsfFundRTId;
            superDetails.chosenAttId = att.Id;

            superDetails.saveSuper();
            superDetails.Cancel();
            //superDetails.DeleteAtt();
//            system.assertEquals(superDetails.superTypeSelected, 'SMSF');
        }
        test.stopTest();
    }
    static testMethod void testPortalTaxDetails1() {
        createData();

        test.startTest();
        system.runAs(usr) {
            Portal_ProfileTaxDetails_Controller taxDetails = new Portal_ProfileTaxDetails_Controller();

            taxDetails.LoadSelectionDetails();
            taxDetails.Cancel();

            taxDetails.decComplete = true;
            taxDetails.hasTFNSelected = 'Yes';
            taxDetails.areYouSelection = 'ausres';
            taxDetails.taxFreeSelect = 'Yes';
            taxDetails.loanSelect = 'Yes';
            taxDetails.debtSelect = 'Yes';


            taxDetails.setDatetime();
            taxDetails.Submit();

//            system.assertEquals(superDetails.superTypeSelected, 'APRA/RSA');

        }
        test.stopTest();
    }
    static testMethod void testPortalTaxDetails2() {
        createData();
        payee.tc9_p__Australian_Resident__c = false;
        payee.tc9_p__Is_approved_working_holiday_maker__c = true;
        update payee;

        test.startTest();
        system.runAs(usr) {
            Portal_ProfileTaxDetails_Controller taxDetails = new Portal_ProfileTaxDetails_Controller();

            taxDetails.LoadSelectionDetails();
            taxDetails.Cancel();

            taxDetails.decComplete = true;
            taxDetails.hasTFNSelected = 'No';
            taxDetails.tfnTypeSelected = 'newApp';
            taxDetails.areYouSelection = 'workhol';
            taxDetails.taxFreeSelect = 'No';
            taxDetails.loanSelect = 'No';
            taxDetails.debtSelect = 'No';

            taxDetails.setDatetime();
            taxDetails.Submit();

//            system.assertEquals(superDetails.superTypeSelected, 'APRA/RSA');

        }
        test.stopTest();
    }
    static testMethod void testPortalTaxDetails3() {
        createData();
        payee.tc9_p__Australian_Resident__c = false;
        payee.tc9_p__Is_approved_working_holiday_maker__c = false;
        update payee;

        test.startTest();
        system.runAs(usr) {
            Portal_ProfileTaxDetails_Controller taxDetails = new Portal_ProfileTaxDetails_Controller();

            taxDetails.LoadSelectionDetails();
            taxDetails.Cancel();

            taxDetails.decComplete = false;
            taxDetails.hasTFNSelected = 'No';
            taxDetails.tfnTypeSelected = 'under18';
            taxDetails.areYouSelection = 'forres';
            taxDetails.taxFreeSelect = 'No';
            taxDetails.loanSelect = 'No';
            taxDetails.debtSelect = 'No';

            taxDetails.setDatetime();
            taxDetails.Submit();

            taxDetails.LoadSelectionDetails();
            taxDetails.tfnTypeSelected = 'exemptClaim';
            taxDetails.Submit();

//            system.assertEquals(superDetails.superTypeSelected, 'APRA/RSA');

        }
        test.stopTest();
    }
}