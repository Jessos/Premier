@istest
public class Test_utilforroundrobin{
@istest(seealldata=true)
static void test_utilforroundrobin(){

    ToC9_TestDataDump testDataDump = new ToC9_TestDataDump();
    
    //create a new tax record
    tc9_ti__TaxID__c testTax = testDataDump.getTaxID();
      
    //create a new market
    tc9_ti__Market__c testMarket = testDataDump.getMarket(testTax.Id);
    
     //create a new account
    Account testAccount = testDataDump.getAClientAccount(testMarket.Id);
    testAccount.Name = 'Premier Staffing, Inc';
    testAccount.BillingStreet = 'BillingStreet';
    testAccount.BillingCity = 'Melbourne';
    testAccount.BillingState = 'Victoria';
    testAccount.BillingPostalCode = '3000';
    testAccount.BillingCountry = 'Australia';
    testAccount.Phone = '1234567899';
    testAccount.Fax = '90000';
    testAccount.Website = 'www.test.com';
    update testAccount;
      
    //create a client contact
    Contact testContact = testDataDump.getAClientContact(testAccount.Id);
    testContact.Salutation  = 'Mr';
    testContact.email = 'test@testxx.com';
    update testContact;

list<contact>dummylist=new List<Contact>{testContact};
  dummylist[0].department_picklist__c='Finance';

  user dummycontact =[select id from user limit 1];

  dummylist[0].Admin_Manager__c=dummycontact.id;
  update dummylist;
    utilforroundrobin.AssignManagerToCandidatecontact(dummylist);
    utilforroundrobin.sendNewApplicationEmailscontact(dummylist);

}
}