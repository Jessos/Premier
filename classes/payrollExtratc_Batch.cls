/**
Author  : 2C9 Dharshni
Purpose : To create a payroll extract csv file from unprocessed transactions that satisfy the input criteria

/***********************************Initial CSV file structure******************
EMP NUM  - Employee info.
Division - 1
Department - 1000 if Temp Placement and 1100 if Payroll Placement
Name - Employee Name
H01-REGULAR - Sum of Reg Paycode            
H02-O/TIME - Sum of OT Paycode
H24-SFHOURS - Sum of DT Paycode
$07-SALARY - ''
$08-OTHER - ''
$13-BONUS - ''
$14-COMMIS$ - ''
$82-DRAW  - ''
Rate - Base pay rate for Placement
Check - ''

/******************************** Changed to support PAYCOM - 11/12/2014 *********************************************
EMP NUM - Employee Info
Paycom earning code
Hours_Or_Amount
Temporary_Rate
Distribution_Dept_Code
Tax_Profile_Override
Labor_Allocation
More info : SC-2635 
//SM - Fixed code for C-007892 on 12/8/2016  

**/
global class payrollExtratc_Batch implements Database.batchable<tc9_ti__Transaction__c>, Database.Stateful{
    
    public Map<Id,String> Map_Of_RecordtypeId_to_Name;
    private Map<Id,List<csvRowWrapper>> csv_rows_groupedBy_Employee;
    
    //date filters
    public  Date fromDate;
    public  Date toDate;
    public  String payrollExtractStatus = 'New';
    Map<String,Integer> seqMap = new Map<String, Integer>();
    Integer sequence =1;
    List<Id> employeeIds = new List<Id>();
    //date values for previous extracts
    public Date fromDate_prev;
    public Date toDate_prev;
    public Map<Id,Contact> Map_Of_EmployeeId_to_Employee = new Map<Id,Contact>();
    
    //constructor definition
    public payrollExtratc_Batch(Date fromDateParam,Date toDateParam)
    {
        Map_Of_RecordtypeId_to_Name = new Map<Id,String>();
        csv_rows_groupedBy_Employee = new Map<Id,List<csvRowWrapper>>();
        for(RecordType placementRT : [Select r.SobjectType, r.DeveloperName, r.Name From RecordType r where r.SobjectType = 'ts2__Placement__c' and (DeveloperName = 'Temp' or DeveloperName = 'Payroll')])
        {
            Map_Of_RecordtypeId_to_Name.put(placementRT.Id,placementRT.DeveloperName);
        }
        
        fromDate = fromDateParam;
        toDate   = toDateParam; 
        system.debug('from date--'+fromDate+'to date--'+toDate);
    }
    //inner wrapper class
    public class csvRowWrapper
    {
        public Id employeeId;
        public String emp_department;
        public Map<String, Double> paycode_hours;
        public Decimal base_pay_rate = 0; 
        public String plc_department;
        public String plc_RecType; 
        public String plc_RecordType;
        public Date week_StDt;
        public Date week_EndDt;
        public Integer seq;
        public String cc1;
        public String cc2;
        public String cc3;
        //constructor definition
        public csvRowWrapper(Id emploId,String parcc1 ,String parcc2 ,String parcc3, String placementRecordTypeName, Decimal rate, String plcDept, String plcRecType, Date weekStDt, Date weekEndDt, Integer seq){
            this.employeeId = emploId;
            this.cc1 = parcc1;
            this.cc2 = parcc2;
            this.cc3 = parcc3;
            if(plcRecType =='Temp')
                this.plc_RecType = '2100 ';
            else if(plcRecType =='Payroll')
                this.plc_RecType = '2200';
            else if(plcRecType =='VMS')
                this.plc_RecType = '2300';
            else if(plcRecType =='Corporate')
                this.plc_RecType = '1300';

            if(plcRecType =='Temp')
                this.plc_RecordType = '21000';
            else if(plcRecType =='Payroll' || plcRecType =='VMS')
                this.plc_RecordType = '22000';

            if(placementRecordTypeName == 'Temp')
                this.emp_department = '1000';
            else if(placementRecordTypeName == 'Payroll')
                this.emp_department = '1100';
            else
                this.emp_department = '';
            
            
            if(plcDept  == 'San Francisco')
                plc_department = '100';
            else if(plcDept == 'East Bay')
               plc_department = '200';
            else if(plcDept == 'Silicon Valley')
                plc_department = '300';
            else if(plcDept == 'New York')
                plc_department = '400';
            else if(plcDept == 'HQ')
                 plc_department = '999';

            if(rate == null)
                rate = 0;
            this.base_pay_rate = rate.setScale(2);
            this.paycode_hours = new Map<String, Double>(); 
            this.week_StDt = weekStDt;
            this.week_EndDt = weekEndDt;

            this.seq = seq;
        }
        
        public void addHours(String paycode, Decimal hours){
            
            //if(paycode == null || hours == null)
            //return;
            if(hours == null)
                hours = 0;
            hours = hours.setScale(2);
            
            if(paycode == null)
                paycode = '';
            
            if(this.paycode_hours.containsKey(paycode))
                hours += this.paycode_hours.get(paycode);
            this.paycode_hours.put(paycode, hours);
        }
    }
    
    global List<tc9_ti__Transaction__c> start(Database.batchableContext batchableContext)
    {
        system.debug('from date--'+fromDate+'to date--'+toDate);
        system.debug('from date--'+fromDate_prev+'to date--'+toDate_prev);
        String prevDateString = '';
        String queryString  = 'Select  t.tc9_ti__Placement__r.RecordtypeId, t.tc9_ti__Placement__r.Department__c, t.tc9_ti__Placement__r.Location__c,t.tc9_ti__Time_Sheet__r.tc9_ti__Start_Date__c, t.tc9_ti__Time_Sheet__r.tc9_ti__End_Date__c, t.tc9_ti__Paycode__c, tc9_ti__HoursActutal__c, t.tc9_ti__Placement__r.tc9_ti__Base_Pay_Rate__c, t.tc9_ti__Placement__c, t.Paycom_Earning_Code__c, tc9_ti__Adjusted_PayRate__c, tc9_ti__Multiplier__c, ';
        queryString += 't.tc9_ti__Placement__r.CC1__c,t.tc9_ti__Placement__r.CC2__c,t.tc9_ti__Placement__r.CC3__c, ';
        queryString += 't.tc9_ti__Placement__r.ts2__Employee__r.EMP_NUM__c,t.tc9_ti__Placement__r.ts2__Employee__c,t.tc9_ti__EntryDate__c,t.Payroll_Extract_First_Run__c,t.Payroll_Extract_Last_Run__c,t.Payroll_Extract_Status__c From tc9_ti__Transaction__c t';
        queryString += ' where t.tc9_ti__Placement__c != null and t.tc9_ti__Placement__c != \'\' and t.Paycom_Earning_Code__c != null ';
        Boolean masterDatesPresent = false;
        Boolean prevDatesPresent = false;
        
        if(fromDate != null && toDate != null)
        {
            queryString += ' and ((t.tc9_ti__EntryDate__c >= :fromDate and t.tc9_ti__EntryDate__c <= :toDate and t.Payroll_Extract_Status__c = :payrollExtractStatus)';
            masterDatesPresent = true; 
        }
        else if(fromDate != null)
        {
            queryString += ' and ((t.tc9_ti__EntryDate__c >= :fromDate and t.Payroll_Extract_Status__c = :payrollExtractStatus)';
            masterDatesPresent = true;
        }
        if(fromDate_prev != null && toDate_prev != null)
        {
            prevDateString += '  (t.Payroll_Extract_First_Run__c >= :fromDate_prev and t.tc9_ti__EntryDate__c <= :toDate_prev)'; 
            prevDatesPresent = true;
        }
        else if(fromDate_prev != null)
        {
            prevDateString += '  (t.Payroll_Extract_First_Run__c >= :fromDate_prev) ';
            prevDatesPresent = true;
        }
        
        //if the master dates are not present then we need to alter the query accordingly
        if(masterDatesPresent && prevDatesPresent)
            queryString += ' or '+prevDateString;
        else if(prevDatesPresent)
            queryString += ' and '+prevDateString;                      
        else
            queryString += prevDateString;
        
        if(masterDatesPresent)
            queryString += ')';
        
        system.debug('query--'+queryString);            
        return Database.Query(queryString);      
    }
    
    global void execute(Database.BatchableContext batchableContext, List<tc9_ti__Transaction__c> scope) 
    {
        List<tc9_ti__Transaction__c> transactionRecords = scope;
        //map-variable to hold the grouping information Employee to transactionRecords
        Map<Id,List<tc9_ti__Transaction__c>> Map_Of_Employee_to_Ttransaction = new Map<Id,List<tc9_ti__Transaction__c>>();
        list<tc9_ti__Transaction__c> list_transactions = new list<tc9_ti__Transaction__c>();
       
        System.debug('scope size=='+scope.size());
        system.debug('map of transaction records '+csv_rows_groupedBy_Employee);
         //using the map of Employee to Transaction data, we create the necessary map of Employee to List of csv Wrapper
        for(tc9_ti__Transaction__c eachTransaction : transactionRecords)//Map_Of_Employee_to_Ttransaction.get(employeeId))
        {
            //get employee number
            string employee_number = eachTransaction.tc9_ti__Placement__r.ts2__Employee__r.EMP_NUM__c;
            String cc1 = eachTransaction.tc9_ti__Placement__r.CC1__c;
            String cc2 = eachTransaction.tc9_ti__Placement__r.CC2__c;
            String cc3 = eachTransaction.tc9_ti__Placement__r.CC3__c;

            System.debug('Transaction id: ' + eachTransaction+'employee_number=='+employee_number);
            
            if((employee_number != null) && (!employee_number.trim().equals('')))
            {
                //get employee id
                Id employeeId = eachTransaction.tc9_ti__Placement__r.ts2__Employee__c;
                employeeIds.add(employeeId);
                decimal adjPayrate  = eachTransaction.tc9_ti__Adjusted_PayRate__c;
                decimal payMult     = eachTransaction.tc9_ti__Multiplier__c;
                Date endTxnDt     = eachTransaction.tc9_ti__Time_Sheet__r.tc9_ti__End_Date__c;
                if(adjPayrate == null)adjPayrate= 0;
                if(payMult    == null)payMult   = 0;
               
                boolean isSameEndDt = false;
                System.debug('*** For employee Id'+employeeId+'*****');
                //if rows already added for the employee
                if(csv_rows_groupedBy_Employee.containsKey(employeeId))
                {
                    List<csvRowWrapper> csvRowsTemp  = csv_rows_groupedBy_Employee.get(employeeId);     
                    List<csvRowWrapper> freshCSVRows = new List<csvRowWrapper>();
                    boolean isFound = false;
                  
                    Date endDt = null;
                    for(csvRowWrapper csvRowRec : csvRowsTemp)
                    {   
                        System.debug('csvRowRec.week_EndDt=='+csvRowRec.week_EndDt+'endTxnDt=='+endTxnDt);
                        endDt = csvRowRec.week_EndDt;
                        //if the pay rate is same then we simply add the details to this particular record
                        if(csvRowRec.week_EndDt == endTxnDt)
                        {
                            isSameEndDt = true;
                            //break;
                        }

                        if(isSameEndDt && csvRowRec.base_pay_rate != null && csvRowRec.base_pay_rate.setScale(2) == ((adjPayrate * payMult).setScale(2)))//if the payrate is already present then we add to the
                        {
                            csvRowRec.addHours(eachTransaction.Paycom_Earning_Code__c, eachTransaction.tc9_ti__HoursActutal__c);
                            isFound = true;
                            break;
                        }
                        System.debug('added hours so far=='+csvRowRec);
                        
                    }
                    System.debug('isFound=='+isFound);
                    
                    if(!isSameEndDt)
                    {
                        System.debug(' is not same end dt');
                        if(seqMap.containsKey(employeeId))
                        {
                            System.debug('sequence ****'+seqMap.get(employeeId)+'for employeeId=='+employeeId);
                            sequence = seqMap.get(employeeId)+1;
                            seqMap.put(employeeId, sequence);
                        }
                        else
                        {
                            sequence = 1;
                            seqMap.put(employeeId, sequence);
                        }
                        System.debug('1111 seq =='+sequence+'for employeeId=='+employeeId);
                    }else
                    {
                        System.debug('same end dt');
                        if(seqMap.containsKey(employeeId))
                            sequence = seqMap.get(employeeId);

                        System.debug('2222 seq =='+sequence+'for employeeId=='+employeeId);
                        seqMap.put(employeeId, sequence);
                    }
                    
                    if(!isFound )// this loop handles the case where the base rate is different and hence we create a new record
                    {
                        String placementRecordType = '';
                        if(Map_Of_RecordtypeId_to_Name.containsKey(eachTransaction.tc9_ti__Placement__r.RecordtypeId) && Map_Of_RecordtypeId_to_Name.get(eachTransaction.tc9_ti__Placement__r.RecordtypeId) != null)
                            placementRecordType = Map_Of_RecordtypeId_to_Name.get(eachTransaction.tc9_ti__Placement__r.RecordtypeId);
                        //commented this one!!
                        sequence = seqMap.get(employeeId);
                        /*
                        if(seqMap.containsKey(employeeId))
                        {
                            System.debug('sequence &&&&'+seqMap.get(employeeId)+'for employeeId=='+employeeId);
                            sequence = seqMap.get(employeeId)+1;
                            seqMap.put(employeeId, sequence);
                        }
                        else
                        {
                            sequence = 1;
                            seqMap.put(employeeId, sequence);
                        }*/
                        /****************/
                        //create new row - with the rate & paycode hours/*
                        csvRowWrapper newRow   = new csvRowWrapper(employeeId,cc1 ,cc2 ,cc3, placementRecordType, adjPayrate * payMult,  eachTransaction.tc9_ti__Placement__r.Location__C, placementRecordType, eachTransaction.tc9_ti__Time_Sheet__r.tc9_ti__Start_Date__c, endTxnDt, sequence);
                        newRow.addHours(eachTransaction.Paycom_Earning_Code__c, eachTransaction.tc9_ti__HoursActutal__c);
                        
                        //add row to the list
                        csvRowsTemp.add(newRow);
                         System.debug('isNOTFound newRow======='+newRow);
                    }

                    csv_rows_groupedBy_Employee.put(employeeId,csvRowsTemp);
                }
                else // If the Map does not contain the transaction info at all then we include it in the map
                {
                    System.debug('***** In ELSE *****');
                    String placementRecordType = '';                    
                    if(Map_Of_RecordtypeId_to_Name.containsKey(eachTransaction.tc9_ti__Placement__r.RecordtypeId) && Map_Of_RecordtypeId_to_Name.get(eachTransaction.tc9_ti__Placement__r.RecordtypeId) != null)
                        placementRecordType = Map_Of_RecordtypeId_to_Name.get(eachTransaction.tc9_ti__Placement__r.RecordtypeId);
                    
                    //create new row - with the rate & paycode hours
                    sequence = 1;
                    seqMap.put(employeeId, sequence);
                    System.debug('000 seq =='+sequence+'for eemployeeId=='+employeeId);
                    csvRowWrapper newRow    = new csvRowWrapper(employeeId,cc1 ,cc2 ,cc3, placementRecordType, adjPayrate * payMult, eachTransaction.tc9_ti__Placement__r.Location__C, placementRecordType, eachTransaction.tc9_ti__Time_Sheet__r.tc9_ti__Start_Date__c, endTxnDt, sequence);
                    newRow.addHours(eachTransaction.Paycom_Earning_Code__c, eachTransaction.tc9_ti__HoursActutal__c);
                    System.debug('newRow=='+newRow);
                    System.debug('*** First time put For employee Id'+employeeId+'*****');

                    csv_rows_groupedBy_Employee.put(employeeId,new List<csvRowWrapper>{newRow});
                }
                
                //change transaction status
                if(eachTransaction.Payroll_Extract_First_Run__c == null)
                    eachTransaction.Payroll_Extract_First_Run__c = DateTime.Now();
                else
                    eachTransaction.Payroll_Extract_Last_Run__c = DateTime.Now();
                eachTransaction.Payroll_Extract_Status__c = 'Exported';
                
                list_transactions.add(eachTransaction);                    
            }
        }
        
        if(list_transactions != null && list_transactions.size()>0)
            update list_transactions;
        
        //Since we need information from the Employee such as employee Number and name, we  query for the required Employee records
        for(Contact employeeRecord : [Select Id, Name, EMP_NUM__c from Contact where Id in  :employeeIds])
        {
            Map_Of_EmployeeId_to_Employee.put(employeeRecord.Id,employeeRecord);
        } 
    }
    global void finish(Database.BatchableContext batchableContext)
    {
        system.debug('map size--'+csv_rows_groupedBy_Employee.keyset().size());         
        system.debug('map ITSELF--'+csv_rows_groupedBy_Employee); 
        
        String bodyCSV = '';
        bodyCSV += 'Emp Num,';//A
        bodyCSV += 'Employee Name,';//B
        bodyCSV += 'Wage,';//C
        bodyCSV += 'Paycode,';//D
        bodyCSV += 'Hours,';//E
        bodyCSV += 'Amount,';//F
        bodyCSV += 'Rate,';//G
        bodyCSV += 'Rate Code,'; //H
        bodyCSV += 'CC1,'; //I
        bodyCSV += 'CC2,'; //J 
        bodyCSV += 'CC3,'; //K 
        bodyCSV += 'CC4,'; //L
        bodyCSV += 'CC5,'; //M
        bodyCSV += 'Job Code,'; //N
        bodyCSV += 'Shift,'; //O
        bodyCSV += 'Begin Date,'; //P
        bodyCSV += 'End Date,'; //Q
        bodyCSV += 'WCC,'; //R
        bodyCSV += 'TCode1,'; //S
        bodyCSV += 'TCode2,'; //T
        bodyCSV += 'TCode3,'; //U
        bodyCSV += 'TCode4,'; //V
        bodyCSV += 'Sequence,'; //W
        bodyCSV += 'CheckType,'; //X
        bodyCSV += 'CheckNumber'; //Y
        //bodyCSV += 'Dept,';    SC-2635
        //bodyCSV += 'Tax Profile,';
        //bodyCSV += 'Labor Allocation';
                  
        
        for(Id employeeId : csv_rows_groupedBy_Employee.keyset())
        {
            Contact employeeRec    = Map_Of_EmployeeId_to_Employee.get(employeeId);
            for(csvRowWrapper csvRow : csv_rows_groupedBy_Employee.get(employeeId))
            {
                String s= String.valueOf(employeeRec.EMP_NUM__c);
                if(s == null || s== '')
                    continue;
                
                for(String paycode : csvRow.paycode_hours.KeySet()){
                    bodyCSV +=  '\n'+s+','; //A
                    bodyCSV += employeeRec.Name +',';//B
                    bodyCSV += ((csvRow.base_pay_rate!=null && csvRow.base_pay_rate>=0)?'E':'D') +',';//C
                    bodyCSV += paycode +',';//D
                    bodyCSV += csvRow.paycode_hours.get(paycode)+',';//E
                    bodyCSV += ' ,';//F
                    bodyCSV += csvRow.base_pay_rate+',';//G
                    bodyCSV += ' ,';//H
                    bodyCSV += (csvRow.cc1!=null?csvRow.cc1:'')+','; //I
                    bodyCSV += (csvRow.cc2!=null?csvRow.cc2:'')+','; //J
                    bodyCSV += (csvRow.cc3!=null?csvRow.cc3:'')+','; //k
                    bodyCSV += ' ,'; //L
                    bodyCSV += ' ,'; //M
                    bodyCSV += ' ,'; //N
                    bodyCSV += ' ,'; //O
                    bodyCSV += csvRow.week_StDt!=null? csvRow.week_StDt.format()+',':',';//P
                    bodyCSV += csvRow.week_EndDt!=null?csvRow.week_EndDt.format() +',':','; //Q
                    bodyCSV += ' ,'; //R
                    bodyCSV += ' ,'; //S
                    bodyCSV += ' ,'; //T
                    bodyCSV += ' ,'; //U
                    bodyCSV += ' ,'; //V
                    bodyCSV += csvRow.seq+' ,'; //W
                    bodyCSV += ' ,'; //X
                    bodyCSV += ' '; //Y


                }
            }
        }
        
        system.debug('**' + bodyCSV);
        Document doc=new Document();
        doc.Name='PayrollExtract_'+DateTime.now();
        doc.body=Blob.valueOf(bodycsv);
        
        //Selecting the folder where the document has to be stored 
        id folderid=[SELECT id,name from folder where developerName='Payroll_Extracts'].id;
        doc.FolderId =folderid;
        doc.Contenttype = 'Text/csv';
        doc.Type='csv'; 
        insert doc;
        
    }       
}