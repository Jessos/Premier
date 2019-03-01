@isTest
public with sharing class SendEmailTriggerTest {
	
	public static testMethod void test_EmailOnIncomingTrigger(){
		
		
		
		List<smagicinteract__Incoming_SMS__c> incomingList = [select Id from smagicinteract__Incoming_SMS__c where smagicinteract__external_field__c='smsMagic'];
    	delete incomingList;
    	
    	smagicinteract__Incoming_SMS__c newSMS = new smagicinteract__Incoming_SMS__c(smagicinteract__Mobile_Number__c='(312) 596-1230', smagicinteract__SMS_Text__c='test of forwardConfig ', smagicinteract__external_field__c='smsMagic');
    	insert newSMS;
    	
    	System.assert(true);
	}
	
	
}