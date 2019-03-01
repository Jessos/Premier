/**
 * Created by Adelaide Greenaway on 1/03/2018.
 * This class contains unit test for validating the behaviour of the
 * Trialforce Portal Login, Portal Forgot and Change Password controllers:
 *      Portal_Login_Controller
 *      ChangePasswordController
 *      Portal_ForgotPassword_Controller
 */

@isTest
private class Test_PortalLogin {
    private static Account acc;
    private static Contact emp;
    private static Profile prof;
    private static User usr;
    private static tc9_p__Payee__c payee;

    private static void createData() {
        Test_PortalDataFactory testData = new Test_PortalDataFactory();

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
    }

    static testMethod void testPortalLogin(){
        createData();

        test.startTest();

        system.runAs(usr){
            Portal_Login_Controller loginUser = new Portal_Login_Controller();

            System.assertEquals(loginUser.login(),null);
        }

        test.stopTest();
    }

    static testMethod  void testChangePassword (){
        createData();

        test.startTest();
        system.runAs(usr) {
            ChangePasswordController chgPwd = new ChangePasswordController();
            chgPwd.oldPassword = '123456';
            chgPwd.newPassword = 'qwerty1';
            chgPwd.verifyNewPassword = 'qwerty1';

            System.assertEquals(chgPwd.changePassword(), null);
        }

        test.stopTest();
    }

    static testMethod void testPortalForgotPassword(){
        createData();

        test.startTest();

        system.runAs(usr) {
            Portal_ForgotPassword_Controller forgotPwd = new Portal_ForgotPassword_Controller();
            forgotPwd.username = usr.Username;
            system.debug('username:: ' + forgotPwd.username);

            System.assertEquals(forgotPwd.forgotPassword(), null);
        }

        test.stopTest();
    }

}