/**
* @author Vignesh Damodharan
* @date 06/03/2014
* @description To generate SFHCO Accrual Records for Contacts(Candidates)
* @Modified for : Changed the name to US Format
* @Modified on  : 30/05/2014
* Modified RS 2c9 24/01/15 Transaction Date >= Eligibility date (was >)
**/

/*---------------------------------- Logic ----------------------------------------------
    This Batch class runs every month and generates SFHCO Accrual Records for Contacts(Candidates) based on
        - Create Monthly SFHCO Ledger Accrual Entries based on the transaction done last months(hours logged)
        - Contact's eligibility
        - associate to the Pay Period
        - Max Cap of $ 100 per employee
  ---------------------------------- Logic ----------------------------------------------*/
  
global class Batch_SFHCO_Accrual implements Database.Batchable<sObject>, Database.Stateful{
    
    global SFHCO_Settings__c  SFHCOSettings  = SFHCO_Settings__c.getInstance();
    global Map<String, Decimal> mapOfUniqueContactStringToHoursAccrued  = new Map<String, Decimal>();
    global Map<String, Decimal> mapOfUniqueContactStringToHoursAccruedLastThreeMonths   = new Map<String, Decimal>();
    global Map<Id,String> mapOfContactIdToName = new Map<Id,String>();
    global Map<Id,Set<Id>> mapOfContactToTimesheets = new Map<Id,Set<Id>>();
    global Decimal nTotalDays = 0;
    global String strQuery;
    global String strPayrollId;
    
    global Date fromDate;
    global Date toDate;
    global Date cappedDate;
    global Id stipendId;
    
    global final static String VALID_TRANSACTION_UNIT = 'Hours';
    global final static Integer VALID_CAP = 100;
    global final static Integer VALID_DATE_RANGE_CAP = 90;
    
    global Batch_SFHCO_Accrual(Date fromDate , Date toDate, Id strPayrollId){
        
        //Initialization
        this.fromDate           = fromDate;
        this.toDate             = toDate;
        this.strPayrollId       = strPayrollId;
        
        //set the no of days
        nTotalDays = fromDate.daysBetween(toDate);
        
        //Capped Date to get the last 3 month hours     
        cappedDate = toDate.addDays(-VALID_DATE_RANGE_CAP);
        
        System.debug('@@ '+nTotalDays);
        System.debug('@@ '+cappedDate);
        
        stipendId = [SELECT Id FROM RecordType WHERE sObjectType='tc9_ti__Transaction__c' AND DeveloperName =: 'Stipend' LIMIT 1].Id;
        System.debug('@@ '+stipendId);
        
        //If the date range goes to 90+ days, use from Date else Capped Date
        if(nTotalDays >= VALID_DATE_RANGE_CAP){
            //build the query
            strQuery = 'SELECT Name, tc9_ti__Unit__c, tc9_ti__Time_Sheet__r.Job_Name__c, tc9_ti__Time_Sheet__r.tc9_ti__Status__c, tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c, tc9_ti__Time_Sheet__r.tc9_ti__Candidate__r.Name, tc9_ti__Time_Sheet__c, tc9_ti__Time_Sheet_Entry__r.tc9_ti__Status__c, tc9_ti__Time_Sheet_Entry__r.tc9_ti__Time_Sheet__c, tc9_ti__Time_Sheet_Entry__r.Id, tc9_ti__Time_Sheet_Entry__c, tc9_ti__HoursActutal__c, tc9_ti__EntryDate__c, Id, Employee__c, SFHCO_Accrued_Datestamp__c, tc9_ti__Placement__r.ts2__Employee__r.SFHCO_Eligibilty_Date__c FROM tc9_ti__Transaction__c';
            strQuery += ' WHERE tc9_ti__Placement__r.ts2__Employee__r.Opted_Out_of_Benefits__c = false';
            strQuery += ' AND tc9_ti__Placement__r.ts2__Job__r.ts2__Location__c = \'San Francisco\'';
            strQuery += ' AND tc9_ti__EntryDate__c >=:fromDate';
            strQuery += ' AND tc9_ti__EntryDate__c <=:toDate';
            strQuery += ' AND RecordTypeId !=: stipendId';
            strQuery += ' AND tc9_ti__Time_Sheet_Entry__r.tc9_ti__Type_Of_Leave__c = null' ;           
        }else{
            //build the query
            strQuery = 'SELECT Name, tc9_ti__Unit__c, tc9_ti__Time_Sheet__r.Job_Name__c, tc9_ti__Time_Sheet__r.tc9_ti__Status__c, tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c, tc9_ti__Time_Sheet__r.tc9_ti__Candidate__r.Name, tc9_ti__Time_Sheet__c, tc9_ti__Time_Sheet_Entry__r.tc9_ti__Status__c, tc9_ti__Time_Sheet_Entry__r.tc9_ti__Time_Sheet__c, tc9_ti__Time_Sheet_Entry__r.Id, tc9_ti__Time_Sheet_Entry__c, tc9_ti__HoursActutal__c, tc9_ti__EntryDate__c, Id, Employee__c, SFHCO_Accrued_Datestamp__c, tc9_ti__Placement__r.ts2__Employee__r.SFHCO_Eligibilty_Date__c FROM tc9_ti__Transaction__c';
            strQuery += ' WHERE tc9_ti__Placement__r.ts2__Employee__r.Opted_Out_of_Benefits__c = false';
            strQuery += ' AND tc9_ti__Placement__r.ts2__Job__r.ts2__Location__c = \'San Francisco\'';
            strQuery += ' AND tc9_ti__EntryDate__c >=:cappedDate';
            strQuery += ' AND tc9_ti__EntryDate__c <=:toDate';
            strQuery += ' AND RecordTypeId != :stipendId';   
            strQuery += ' AND tc9_ti__Time_Sheet_Entry__r.tc9_ti__Type_Of_Leave__c = null' ;         
        }
        
        System.debug('@@ '+strQuery);       
    }   
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator(strQuery);
    }
   
    global void execute(Database.BatchableContext BC, List<tc9_ti__Transaction__c> listOfTransactions){
        
        Set<Id> setOfContactIds = new Set<Id>();
        List<tc9_ti__Transaction__c> listOfTransactionsToBeUpdated = new List<tc9_ti__Transaction__c>();
        
        listOfTransactions = [SELECT Name, tc9_ti__Unit__c, tc9_ti__Time_Sheet__r.Job_Name__c, tc9_ti__Time_Sheet__r.tc9_ti__Status__c, 
                                     tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c, tc9_ti__Time_Sheet__r.tc9_ti__Candidate__r.Name,  tc9_ti__Time_Sheet__r.tc9_ti__Candidate__r.LastName, tc9_ti__Time_Sheet__r.tc9_ti__Candidate__r.FirstName, tc9_ti__Time_Sheet__c, 
                                     tc9_ti__Time_Sheet_Entry__r.tc9_ti__Status__c, tc9_ti__Time_Sheet_Entry__r.tc9_ti__Time_Sheet__c, SFHCO_Accrued_Datestamp__c, 
                                     tc9_ti__Time_Sheet_Entry__r.Id, tc9_ti__Time_Sheet_Entry__c, tc9_ti__HoursActutal__c, tc9_ti__EntryDate__c, Id, Employee__c, 
                                     tc9_ti__Placement__r.ts2__Employee__r.SFHCO_Eligibilty_Date__c 
                              FROM tc9_ti__Transaction__c WHERE Id IN: listOfTransactions];
        
        //Iterate and create a map of ContactId::ContactName and hoursActual map
        for(tc9_ti__Transaction__c iteratingTransaction : listOfTransactions){
            
            System.debug('Iterating for :: '+iteratingTransaction.Name);


            Decimal nHoursActual = 0;
            Decimal nHoursActualForThreeMonths = 0;
            
            //Create a unique string for key in map 
            String uniqueId = iteratingTransaction.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c + '::' + iteratingTransaction.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__r.Name;
            System.debug('@@@ uniqueId:'+uniqueId);
                
            //If the entry is made after the eligible date and not stamped and is a valid transaction UPDATED RS 01/24/15 greater than or equal to also line 142
            if(iteratingTransaction.tc9_ti__EntryDate__c >= iteratingTransaction.tc9_ti__Placement__r.ts2__Employee__r.SFHCO_Eligibilty_Date__c && 
               iteratingTransaction.SFHCO_Accrued_Datestamp__c == NULL &&
               iteratingTransaction.tc9_ti__Unit__c == VALID_TRANSACTION_UNIT){
                
                System.debug(iteratingTransaction.Name +' is Eligible!');
                
                //fetch the actuals if already in map
                if(mapOfUniqueContactStringToHoursAccrued.get(uniqueId)!= NULL){
                    nHoursActual = mapOfUniqueContactStringToHoursAccrued.get(uniqueId);
                }
                
                //add the hours if > 0 and falls within the selected Date range
                if(iteratingTransaction.tc9_ti__HoursActutal__c != NULL && 
                iteratingTransaction.tc9_ti__HoursActutal__c > 0 &&
                iteratingTransaction.tc9_ti__EntryDate__c >= fromDate && 
                iteratingTransaction.tc9_ti__EntryDate__c <= toDate){
                    nHoursActual += iteratingTransaction.tc9_ti__HoursActutal__c;
                //only add timesheets into the collection that we know we've added time for        
                if (mapOfContactToTimesheets.containsKey(iteratingTransaction.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c)) {
                    mapOfContactToTimesheets.get(iteratingTransaction.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c).add(iteratingTransaction.tc9_ti__Time_Sheet_Entry__r.tc9_ti__Time_Sheet__c);
                } else{
                    mapOfContactToTimesheets.put(iteratingTransaction.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c, new Set<Id>{iteratingTransaction.tc9_ti__Time_Sheet_Entry__r.tc9_ti__Time_Sheet__c});
                }
                }
                
                //put in the map with updated actuals
                if(nHoursActual > 0){
                    mapOfUniqueContactStringToHoursAccrued.put(uniqueId, nHoursActual);
                }
                
                if(iteratingTransaction.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__r.LastName != null){
                    mapOfContactIdToName.put(iteratingTransaction.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c,iteratingTransaction.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__r.LastName+', '+ iteratingTransaction.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__r.FirstName);
                }
                //Timestamp the Transactions
                iteratingTransaction.SFHCO_Accrued_Datestamp__c = Datetime.now();
                listOfTransactionsToBeUpdated.add(iteratingTransaction);
            }
            
            if(iteratingTransaction.tc9_ti__EntryDate__c >= iteratingTransaction.tc9_ti__Placement__r.ts2__Employee__r.SFHCO_Eligibilty_Date__c && 
               iteratingTransaction.tc9_ti__Unit__c == VALID_TRANSACTION_UNIT){
                
                System.debug(iteratingTransaction.Name +' is Eligible for last 3 months! ');
                
                //fetch the actuals if already in map
                if(mapOfUniqueContactStringToHoursAccruedLastThreeMonths.get(uniqueId)!= NULL){
                    nHoursActualForThreeMonths = mapOfUniqueContactStringToHoursAccruedLastThreeMonths.get(uniqueId);
                }
                
                //add the hours if > 0
                if(iteratingTransaction.tc9_ti__HoursActutal__c != NULL && 
                iteratingTransaction.tc9_ti__HoursActutal__c > 0 ){
                    nHoursActualForThreeMonths += iteratingTransaction.tc9_ti__HoursActutal__c;
                }
                
                if(nHoursActualForThreeMonths > 0){
                    mapOfUniqueContactStringToHoursAccruedLastThreeMonths.put(uniqueId, nHoursActualForThreeMonths);
                }
            }
            
            setOfContactIds.add( iteratingTransaction.tc9_ti__Time_Sheet__r.tc9_ti__Candidate__c);          
        }
        
        if(!listOfTransactionsToBeUpdated.isEmpty()){
            update listOfTransactionsToBeUpdated;
        }
        
        System.debug('mapOfUniqueContactStringToHoursAccrued :'+mapOfUniqueContactStringToHoursAccrued);
    }

    global void finish(Database.BatchableContext BC){
        
        List<SFHCO_Ledger__c> listOfSFHCOLedgersToBeInserted = new List<SFHCO_Ledger__c>();
        
        Pay_Period__c oPayPeriod = [SELECT Id, Name, End_Date__c, Start_Date__c, Benefit_Accrued__c, Calculate_Benefits__c FROM Pay_Period__c WHERE Id=: strPayrollId];
        
        System.debug('@@@ mapOfUniqueContactStringToHoursAccrued :'+mapOfUniqueContactStringToHoursAccrued);
        
        //Iterate and create leave ledgers for the contacts
        for(String iteratingUniqueContactId : mapOfUniqueContactStringToHoursAccrued.keyset()){
            
            String iteratingContactId   = '';
            String iteratingContactName = '';
            Integer timesheetListSize = 0;
                    
            iteratingContactId      = iteratingUniqueContactId.substring(0, iteratingUniqueContactId.indexOf('::'));
            iteratingContactName    = iteratingUniqueContactId.substring(iteratingUniqueContactId.indexOf('::')+2, iteratingUniqueContactId.length());
            
            System.debug('iteratingContactId :: '+iteratingContactId);
            System.debug('iteratingContactName :: '+iteratingContactName);
            
            SFHCO_Ledger__c iteratingSFHCOLedger = new SFHCO_Ledger__c();
                
            if(mapOfUniqueContactStringToHoursAccrued.get(iteratingUniqueContactId) != NULL){
                
                //total hours for last 3 months
                if(mapOfUniqueContactStringToHoursAccruedLastThreeMonths.get(iteratingUniqueContactId) != NULL){
                    iteratingSFHCOLedger.Last_90_Days_Hours__c = mapOfUniqueContactStringToHoursAccruedLastThreeMonths.get(iteratingUniqueContactId);
                }

                //Since mandatory fields, no null check
                //total hours
                iteratingSFHCOLedger.Hours_This_Pay_Period__c = mapOfUniqueContactStringToHoursAccrued.get(iteratingUniqueContactId);
                
                //link to pay period
                iteratingSFHCOLedger.Pay_Period__c = strPayrollId;                
            
                iteratingSFHCOLedger.Name = 'SFHCO Accrual - '+mapOfContactIdToName.get(iteratingContactId) + ' - ' +oPayPeriod.Name;
                iteratingSFHCOLedger.Candidate__c = iteratingContactId;
                
                iteratingSFHCOLedger.Stipend_Posted__c = false;
                iteratingSFHCOLedger.Type__c = 'Accrual';
                iteratingSFHCOLedger.Start_Date__c = fromDate;
                iteratingSFHCOLedger.End_Date__c = toDate;
                
                //Average - hours/no of days
                //DG 23/10/2015 - Changed the average hours calculation as per SC-9813 to divide by number of related timesheets instead
                //iteratingSFHCOLedger.Average_Hours__c = (mapOfUniqueContactStringToHoursAccrued.get(iteratingUniqueContactId) / nTotalDays) * 7;

                if (mapOfContactToTimesheets.get(iteratingContactId).size() > 0) {
                    timesheetListSize = mapOfContactToTimesheets.get(iteratingContactId).size();
                } else {
                    timesheetListSize = 1;
                }
                iteratingSFHCOLedger.Average_Hours__c = (mapOfUniqueContactStringToHoursAccrued.get(iteratingUniqueContactId) / timesheetListSize);

                //benefit accrual = hours * rate
                if(SFHCOSettings.Dollar_Rate__c != NULL){
                    iteratingSFHCOLedger.Benefit_Accrual__c = mapOfUniqueContactStringToHoursAccrued.get(iteratingUniqueContactId) * SFHCOSettings.Dollar_Rate__c;
                    
                    //Set the $ rate at which the accrual is recorded
                    iteratingSFHCOLedger.Conversion_rate__c = SFHCOSettings.Dollar_Rate__c;
                }
                iteratingSFHCOLedger.Stipend__c = 0;
                iteratingSFHCOLedger.Allocation_Amount__c = 0;
                
                /*//Stipend capped at max of 100
                if(iteratingSFHCOLedger.Benefit_Accrual__c > 100){
                    iteratingSFHCOLedger.Stipend__c = VALID_CAP;
                }
                else{
                    iteratingSFHCOLedger.Stipend__c = iteratingSFHCOLedger.Benefit_Accrual__c;
                }
                
                iteratingSFHCOLedger.Allocation_Amount__c = iteratingSFHCOLedger.Benefit_Accrual__c - iteratingSFHCOLedger.Stipend__c; 
                */
                listOfSFHCOLedgersToBeInserted.add(iteratingSFHCOLedger);                        
                
                
            }
        }
        
        System.debug('listOfSFHCOLedgersToBeInserted :: '+listOfSFHCOLedgersToBeInserted);
        
        if(!listOfSFHCOLedgersToBeInserted.isEmpty()){
            insert listOfSFHCOLedgersToBeInserted;
        }
        
        AsyncApexJob bJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        mail.setTargetObjectId(userInfo.getuserId()); 
        mail.setSaveAsActivity(false); 
        mail.setSubject('SFHCO Accrual batch is now Complete');
        
        String body = 'Hi , <br/> ';
        body += 'The SFHCO Accrual batch is complete.<br/><br/>Further details about the executed batch job are given below<br/><br/>'; 
        if(bJob != null){
            body += 'Number of Total Batches - ';
            body += String.valueOf(bJob.TotalJobItems) + '<br/>';
            body += 'Number of Success Batches - ';
            body += String.valueOf(bJob.TotalJobItems - bJob.NumberOfErrors) + '<br/>';
            body += 'Number of Failed Batches - ';
            body += String.valueOf(bJob.NumberOfErrors) + '<br/>';          
        }       
        mail.setHtmlBody(body);  
        Messaging.SendEmail(new Messaging.SingleEmailMessage[] { mail });          
    }
}