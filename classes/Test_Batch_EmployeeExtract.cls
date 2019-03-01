@isTest
public class Test_Batch_EmployeeExtract{
        
  static testMethod void createData() {
      
             ToC9_TestDataDump testData = new ToC9_TestDataDump();
               tc9_ti__TaxID__c taxID  = testData.getTaxID();
            tc9_ti__Market__c market= testData.getMarket(taxID.Id);  
             Account accnt      = testData.getAClientAccount(market.Id);
            accnt.Invoice_Delivery_Temps__c = 'Email';
            accnt.tc9_ti__Invoice_Group_By__c ='Client';
            accnt.ts2__Invoice_Terms__c ='10';
            update accnt;
            
            Contact clientContact  = testData.getAClientContact(accnt.Id);
            
            
      Database.BatchableContext bc;
      Batch_EmployeeExtract ctrl = new Batch_EmployeeExtract();
      Batch_EmployeeExtract.EmployeeExtractWrapper ctrlWrap = new Batch_EmployeeExtract.EmployeeExtractWrapper(clientContact);
      ctrl.start(bc);
      ctrl.execute(bc,new List<Contact>{clientContact});
      ctrl.finish(bc);
      
  }
}