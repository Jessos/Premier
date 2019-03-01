/**
* @author Vignesh Damodharan
* @date 06/03/2014
* @description This is the controller for the Sick Leave Accrual Page
*/

public class Ctrl_CalculateSFHCOBenefits {
	
	private Pay_Period__c oPayPeriod;
	
	public Ctrl_CalculateSFHCOBenefits(){
		
		oPayPeriod = new Pay_Period__c();
		
		//Fetch the pay period id
		if(ApexPages.currentPage().getParameters().get('Id') != NULL){
        	
        	//get the parameter which determines the pay period
	        oPayPeriod = [SELECT Id, End_Date__c, Start_Date__c FROM Pay_Period__c WHERE Id=: ApexPages.currentPage().getParameters().get('Id')];
	        
		}else{
			//Intimate the user about the missing payroll id
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You need a payroll Id to calculate benefits.'));
		}
	}
	
	
/**
* @author Vignesh Damodharan
* @date 06/03/2014
* @description This method initiates the SFHCO Accrual batch class
* @param 
* @return PageReference
*/    
    public PageReference InvokeBatch(){
    	
    	ID batchprocessId;
    	
    	//Call the Sick Leave Accrual batch class if the start and end dates are not null
    	if(oPayPeriod.Start_Date__c != null && oPayPeriod.End_Date__c != null){
    		
    		Batch_SFHCO_Accrual invokeBatchClass = new Batch_SFHCO_Accrual(oPayPeriod.Start_Date__c, oPayPeriod.End_Date__c, oPayPeriod.Id);

    		// Invoke the batch job.
			batchprocessId = Database.executeBatch(invokeBatchClass);	
	    	
	    	System.debug('Returned batch process ID: ' + batchProcessId);
    	}else{
    		
    		//Intimate the user to select start and end dates
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, Label.ERROR_Sick_Leave_Dates_not_defined));
    		return null;
    	}
    	
    	//Intimate the user about the batch
    	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'SFHCO Ledgers are being generated and will be available in a few minutes.'));
    	
    	return null;
    }
}