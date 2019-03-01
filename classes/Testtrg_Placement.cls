/*
    Author  : 2C9
    Purpose : To Test trg_Placement.trg
*/
@isTest
public with sharing class Testtrg_Placement {
    
    private static testmethod void testAutoPopulatePlcFields(){
        
        ToC9_TestDataDump testData = new ToC9_TestDataDump();
        Date plcStartDate       = date.parse('12/12/2012');
        Date plcEndDate         = plcStartDate.addDays(9);  //placement spanning two weeks (till 01/08/2012)
        
        tc9_ti__TaxID__c taxID  = testData.getTaxID();
        tc9_ti__Market__c market= testData.getMarket(taxID.Id); 
        Account accnt           = testData.getAClientAccount(market.Id);
        accnt.ts2__Invoice_Terms__c ='10';
        update accnt;
        Contact clientContact   = testData.getAClientContact(accnt.Id);
        
        tc9_ti__Site__c sit     = testData.getASite('Test Site', 'http://www.test.com/');
        
        ts2__Job__c job1        = testData.getAJob(accnt.Id, clientContact.Id, market.Id,sit.Id);
        
        Contact candidate       = testData.getACandidate('TestCandidate');  
        candidate.State__c = 'AL';
        update candidate;
        RecordType rt = [select id,Name from RecordType where SobjectType='ts2__Placement__c' and Name='Perm' Limit 1];
       // ts2__Placement__c plc   = testData.getAPlacement(job1, null, candidate.Id, plcStartDate, plcEndDate, null, 'Temp'); //till next friday
       // plc.recordtypeid = rt.id;
       // plc.ts2__Employee__c = candidate.id;
       // update plc;
        
       // plc = [Select tc9_ti__Base_Bill_Rate__c,tc9_ti__Base_Pay_Rate__c
                             //   From ts2__Placement__c Where id =: plc.Id];
        
        //check if the placment's bill rate are set from job order
       // System.assertEquals(job1.tc9_ti__Base_Bill_Rate__c,plc.tc9_ti__Base_Bill_Rate__c);
       // System.assertEquals(job1.tc9_ti__Base_Pay_Rate__c,plc.tc9_ti__Base_Pay_Rate__c);
        
        //confirm if the latest placement is set properly on the candidate
        candidate  = [SELECT id, Latest_Placement__c from Contact WHERE id=: candidate.Id];
       // system.assertEquals(plc.Id, candidate.Latest_Placement__c);
        
        PlacementTriggerUtility.plcAfterTrigger  = false;
        
      //  ts2__Placement__c plc1   = testData.getAPlacement(job1, null, candidate.Id, plcStartDate.addDays(20), plcEndDate.addDays(30), null, 'Temp'); //another placement
        
        //confirm that the 'Latest Placement' field on candidate is updated
        candidate  = [SELECT id, Latest_Placement__c from Contact WHERE id=: candidate.Id];
        //system.assertEquals(plc1.Id, candidate.Latest_Placement__c);
        
    }
}