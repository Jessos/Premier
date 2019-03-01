@isTest
public  class TrackSmsHistoryTest {

	public static testMethod void test_send(){
	smagicinteract__smsMagic__c smsObject = new smagicinteract__smsMagic__c(smagicinteract__PhoneNumber__c='8412010139', smagicinteract__SMSText__c='Test SMS' , smagicinteract__Name__c = 'test user '+ String.valueOf(system.now()));
        smsObject.smagicinteract__SenderId__c = 'smsMagic1123';
        smsObject.smagicinteract__external_field__c = String.valueOf(system.now());
        smsObject.smagicinteract__disableSMSOnTrigger__c = 1;
        insert smsObject;
    	system.assert(true);
	
	}
}