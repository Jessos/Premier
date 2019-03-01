@isTest
private class TestAutoUpdateStatus{

static testMethod void TestAutoUpdateStatus() {
 list<contact> dummycon=new list<contact>();
Account acct = new Account(name='test account');
 insert acct;
 Contact ct = new Contact(AccountId=acct.Id,lastname='testing',firstname='apex', ts2__People_Status__c='Active');
 insert ct;
 task dummytask=new task(ActivityDate=system.Today()-128, WhoId=ct.id);
 insert dummytask;
 dummycon.add(ct);
 test.startTest();
 string quer='select id from contact limit 1';
AutoUpdateStatus dl = new AutoUpdateStatus (quer);
dl.start(null);
dl.execute(null,dummycon);
dl.finish(null);
test.stoptest();
}
}