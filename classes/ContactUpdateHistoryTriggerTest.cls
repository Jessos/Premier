@isTest
private class ContactUpdateHistoryTriggerTest {
    static testMethod void myUnitTest() {
        
        Account newAccount = new Account (name='XYZ Organization',
                                                    BillingCity ='TestCity',
                                                    BillingCountry ='TestCountry',
                                                    BillingStreet ='TestStreet',
                                                    BillingPostalCode ='t3stcd3'
      );

        Contact c = new Contact();
        c.LastName = 'Test_ken';
        c.AccountId = newAccount.id;
        c.PayrollNumber__c = '0';
        c.EMP_NUM__c = '1234';
        insert c;
        
        Test.startTest();
        c.PayrollNumber__c = '1';
        update c;
      Test.stopTest();
    }

}