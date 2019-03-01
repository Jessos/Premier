/**
	Author 	: 2C9 Dharshni
	Purpose : To populate the "Paycom earning code" field of transaction
			  Copies the "Paycom earning code" from related PaycodeMaster__c record based on paycode code
	Test method : PayrollExtraction_cntrl 
**/

trigger trg_Transaction on tc9_ti__Transaction__c (before insert, before update) {
	
	//collect paycodes
	Set<String> paycodes = new Set<String>();
	for(tc9_ti__Transaction__c tran : Trigger.new){
		if(tran.tc9_ti__Paycode__c != null && (Trigger.isInsert || (Trigger.isUpdate && tran.tc9_ti__Paycode__c != Trigger.oldMap.get(tran.Id).tc9_ti__Paycode__c)))
			paycodes.add(tran.tc9_ti__Paycode__c);
	}
	
	//get paycode records & group by paycode code
	Map<String, tc9_ti__PayCodeMaster__c> paycodeMap = new Map<String, tc9_ti__PayCodeMaster__c>();
	for(tc9_ti__PayCodeMaster__c paycode : [SELECT id, Name, Paycom_Earning_Code__c, tc9_ti__Paycode__c 
											FROM   tc9_ti__PayCodeMaster__c
											WHERE  tc9_ti__Paycode__c in : paycodes]){
		paycodeMap.put(paycode.tc9_ti__Paycode__c, paycode);										
	}
	
	//assign the paycode earning code
	for(tc9_ti__Transaction__c tran : Trigger.new){
		if(paycodeMap.containsKey(tran.tc9_ti__Paycode__c) && (Trigger.isInsert || (Trigger.isUpdate && tran.tc9_ti__Paycode__c != Trigger.oldMap.get(tran.Id).tc9_ti__Paycode__c))){
			tc9_ti__PayCodeMaster__c paycode = paycodeMap.get(tran.tc9_ti__Paycode__c);
			tran.Paycom_Earning_Code__c = paycode.Paycom_Earning_Code__c;
		}
	}
}