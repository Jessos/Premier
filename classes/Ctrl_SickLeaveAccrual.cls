/**
* @author Vignesh Damodharan
* @date 25/02/2014
* @description This is the controller for the Sick Leave Accrual Page
*/

/*
Change History 
*************************************************************************************************************************************************
    SCRUM         ModifiedBy      Date            Requested By            Description                              Tag
*************************************************************************************************************************************************
    SC-14579      Sethuraman        15/02/2017      JAcob Morton    Manual vs scheduler mode of execution          T01
*/
  

public class Ctrl_SickLeaveAccrual {
    public ts2__Placement__c Plc { get; set; }
    
    public Ctrl_SickLeaveAccrual(){
        Plc = new ts2__Placement__c();
        
        //default Ignore Previously selected to true
        Plc.tc9_ti__Is_timesheet_created__c = true;
    }
    
    
/**
* @author Vignesh Damodharan
* @date 25/02/2014
* @description This method initiates the Sick Leave Accrual batch class
* @param 
* @return PageReference
*/    
    public PageReference InvokeBatch(){
        
        ID batchprocessId;
        
        //Call the Sick Leave Accrual batch class if the start and end dates are not null
        if(Plc.ts2__End_Date__c != null && Plc.ts2__Start_Date__c != null){
            
            Batch_LeaveAccrual invokeBatchClass = new Batch_LeaveAccrual(Plc.ts2__Start_Date__c, Plc.ts2__End_Date__c, 'Manual'); //T01

            // Invoke the batch job.
            batchprocessId = Database.executeBatch(invokeBatchClass);   
            
            System.debug('Returned batch process ID: ' + batchProcessId);
        }else{
            
            //Intimate the user to select start and end dates
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, Label.ERROR_Sick_Leave_Dates_not_defined));
            return null;
        }
        
        //Intimate the user about the batch
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Sick Leave Ledger entries are being generated and will be available in a few minutes. Check Transactions field - Sick Pay Accrued Datestamp - for completion.'));
        
        return null;
    }
}