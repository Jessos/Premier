global class Batch_EmployeeExtract implements Database.Batchable<Contact>, Database.Stateful{
    
    public List<EmployeeExtractWrapper> wrapList;
    private String dateFormat = 'yyyy-MM-dd';
    private DateTime processedDateTime;
    public Integer empNum; 
     
    public class EmployeeExtractWrapper{
        public Contact employee;
        public String gender;
        public String maritalStatus;
        public String fedFilingStatus;
        public String ethnicBackground;
        public String empStatus;
        public String empType;
        public String stateFillingStatus1;
        
        private void setStateFillingStatus(String stateFillingStatus){
            if(stateFillingStatus == 'Single' || stateFillingStatus == 'Married Filing Separately' || stateFillingStatus == 'Qualifying Widow(er) with Dependent Child')
                this.stateFillingStatus1 = 'S';
            else if(stateFillingStatus == 'Married Filing Jointly')
                this.stateFillingStatus1 = 'M';
            else if(stateFillingStatus == 'Head of Household')
                this.stateFillingStatus1 = 'H';
            /*else if(stateFillingStatus == 'Married Filing Separately')  // edited because of rough mapping would suffice ....
                this.stateFillingStatus1 = 'T';
            else if(stateFillingStatus == 'Qualifying Widow(er) with Dependent Child')
                this.stateFillingStatus1 = 'W'; */
            else
                this.stateFillingStatus1 = '';
        }
        
        private void setMaritalStatusVal(String filingStatus){
            if(filingStatus == 'Single')
                this.maritalStatus  = 'S';
            else if(filingStatus == 'Married Filing Jointly')
                this.maritalStatus  = 'M';
            else if(filingStatus == 'Married Filing Separately')
                this.maritalStatus  = 'D';
            else if(filingStatus == 'Qualifying Widow(er) with Dependent Child')
                this.maritalStatus  = 'W';
            else if(filingStatus == 'Domestic Partner')
                this.maritalStatus  = 'P';
            else
                this.maritalStatus = '';
        }
        
        private void setFedFilingStatus(String filingStatus){
            if(filingStatus == 'Single')
                this.fedFilingStatus = 'S';
            else if(filingStatus == 'Married Filing Jointly' || filingStatus == 'Married Filing Separately')
                this.fedFilingStatus = 'M';
            else if(filingStatus == 'Head of Household')
                this.fedFilingStatus = 'H';
            else
                this.fedFilingStatus = '';
        }
        
        private void setEthnicBackground(String eeoRace){
            if(eeoRace == 'White')
                this.ethnicBackground = 'W';
            else if(eeoRace == 'Black or African American')
                this.ethnicBackground = 'B';    
            else if(eeoRace == 'Hispanic or Latino')
                this.ethnicBackground = 'H';    
            else if(eeoRace == 'Native Hawaiian or Other Pacific Islander')
                this.ethnicBackground = 'N';
            else if(eeoRace == 'Asian')
                this.ethnicBackground = 'A';
            else if(eeoRace == 'American Indian or Native Alaskan')
                this.ethnicBackground = 'I';
            else if(eeoRace == 'Two or More Races')
                this.ethnicBackground = 'T';
            else
                this.ethnicBackground = '';
        }
        
        //wrapper constructor
        public EmployeeExtractWrapper(Contact cont){
            
            this.employee = cont;
            
            //state tax filing
            setStateFillingStatus(employee.State_1_Filing_Status__c);
            
            //gender
            if(employee.ts2__EEO_Gender__c == 'Male')
                this.gender = 'M';
            else if(employee.ts2__EEO_Gender__c == 'Female')
                this.gender = 'F';
            if(this.gender == null)
                this.gender = '';
                
            //marital status
            setMaritalStatusVal(employee.Fed_Filing_Status__c);
            setFedFilingStatus(employee.Fed_Filing_Status__c);
            
            //ethnic background
            setEthnicBackground(employee.ts2__EEO_Race__c);
            
            //empStatus
            this.empStatus  = 'A';
            this.empType    = 'W2';
        }
    }
    
    //constructor
    public Batch_EmployeeExtract(){
        wrapList = new List<EmployeeExtractWrapper>();
        processedDateTime = DateTime.now();
    }
    
    //start
    global List<Contact> start(Database.BatchableContext bc){
        String queryStr = ' SELECT id, Emp_Num__c, ts2__Social_Security__c, FirstName, LastName, Paycom_Employee_Number__c, Home_Department__c, ' +
                          ' Latest_Placement__c, Latest_Placement__r.ts2__Job__r.Name,  Latest_Placement__r.tc9_ti__Base_Pay_Rate__c, ' +
                          ' MailingStreet, MailingCity, MailingState, MailingPostalCode, HomePhone, Email, ' +
                          ' ts2__EEO_Gender__c, Birthdate, ts2__EEO_Race__c,  ' +
                          ' DateHired__c, Premier_Term_Date__c, StateTaxFiling1__c, First_Day_Worked__c, ' + 
                          ' Fed_Filing_Status__c, FedTaxExemptions__c, FederalFilingExtras__c, ' +
                          ' State_1_Filing_Status__c, StateTaxExemptions__c, StateFilingExtras__c, ' +
                          ' CheckDeliveryMethod__c, ' +
                          ' First_Extracted__c, Last_Extracted__c, Include_In_Paycom__c, Ready_For_Paycom__c, '+
                          ' First_Placement__r.WorkSite_State__c, Street__c, City__c, State__c, Zip__c  '+
                          ' FROM Contact ' +
                          //' Where First_Extracted__c != null '+
                          ' WHERE Ready_For_Paycom__c = true '+
                          ' AND (First_Extracted__c = null OR Include_In_Paycom__c = true) '+
                          ' order by Name ';
                          //' limit 10';
        return Database.query(queryStr);
    }
    
    //execute
    global void execute(Database.BatchableContext bc, List<Contact> employees){
        
        //get the last extracted contact
        Integer empNumber = 0;
        List<Contact> latestExtractedContact = new List<Contact>();
        latestExtractedContact = [SELECT Paycom_Employee_Number__c FROM Contact where Paycom_Employee_Number__c!=null order by Paycom_Employee_Number__c desc limit 1];
        
        if(latestExtractedContact != null && !latestExtractedContact.isEmpty())        
            empNumber = Integer.valueOf(latestExtractedContact.get(0).Paycom_Employee_Number__c == null ? 0 : latestExtractedContact.get(0).Paycom_Employee_Number__c);
        
        for(Contact emp : employees){
            
            //set empNumber
            if(emp.Paycom_Employee_Number__c == null)
                emp.Paycom_Employee_Number__c = ++empNumber;
            
            //add to extract wrapper
            wrapList.add(new EmployeeExtractWrapper(emp));
            
            //update fields
            if(emp.First_Extracted__c == null)
                emp.First_Extracted__c = processedDateTime;
            else
                emp.Last_Extracted__c  = processedDateTime;
            
            //reset force inclusion
            emp.Include_In_Paycom__c   = false;
        }
        
        update employees;
    }
    
    global void finish(Database.BatchableContext bc){
        
        String bodyCSV = '';
        /*
        bodyCSV += 'Employee Code, Social Security #, Clock Sequence #, Last Name, First Name, Future Field, '; //6 fields
        bodyCSV += 'Street Address, City, State, Zipcode, Home Phone #, e-mail, '; // 6 fields
        bodyCSV += 'Gender, Marital Status, Birth Date, Ethnic Background, '; //4 fields
        bodyCSV += 'Employee Status, Hire Date, Termination Date, Employee Type, Part-Time/Full-Time, '; // 5 fields
        bodyCSV += 'Position, EEOC Class, Home Department, Pay Type, Pay Frequency, Pay Period Salary, '; // 6 fields
        bodyCSV += 'Hourly Rate_1, Hourly Rate_2, Hourly Rate_3, Hourly Rate_4, Hourly Rate_5, '; // 5 fields
        bodyCSV += 'Enrolled in Retirement Plan, Workers Compensation Code, Hire Act Field, Tax Profile Declaration, '; // 4 fields
        bodyCSV += 'Live State, Work State, SUI State, '; // 3 fields
        bodyCSV += 'Federal Filing Status, Federal # Exemption, Federal Additional $, Federal Additional %, Block Federal Tax, '; //5 fields
        bodyCSV += 'Live State Filing Status, Live State # Exemptions, Live State Exempt Amount, Live State Estimated Deductions, '; // 4 fields
        bodyCSV += 'Live State Additional $, Live State Additional %, Block Live State Tax, ' ; //3 fields
        bodyCSV += 'Work State Filing Status, Work State # Exemptions, Work State Exempt Amount, Work State Estimated Deductions, '; //4 fields
        bodyCSV += 'Work State Additional $, Work State Additional %, Block Work State Tax, '; // 3 fields
        bodyCSV += 'EIC (earned income credit) Filing Status, '; //1 field
        bodyCSV += 'Employee Local Tax Code 1, Employee Local Tax Code 2, Employee Local Tax Code 3, Employee Local Tax Code 4, Employee Local Tax Code 5, Employee Local Tax Code 6, '; //6 fields
        bodyCSV += 'Employ(er) Local Tax Code 1, Employ(er) Local Tax Code 2, Employ(er) Local Tax Code 3, Employ(er) Local Tax Code 4, Employ(er) Local Tax Code 5, Employ(er) Local Tax Code 6, ';// 6 fields
        bodyCSV += 'Net Direct Deposit Enabled, Net Direct Deposit Routing Code, Net Direct Deposit Account Code, Net Direct Deposit Account Type,  '; // 4 fields
        bodyCSV += 'Direct Deposit Distributions Enabled, Direct Deposit Distribution 1 Routing Code, Direct Deposit Distribution 1 Account Code, Direct Deposit Distribution 1 Account Type, Direct Deposit Distribution 1 Amount, Direct Deposit Distribution 1 Percentage, '; //6 fields
        bodyCSV += 'Direct Deposit Distribution 2 Routing Code, Direct Deposit Distribution 2 Account Code, Direct Deposit Distribution 2 Account Type, Direct Deposit Distribution 2 Amount, Direct Deposit Distribution 2 Percentage, '; // 5 fields
        bodyCSV += 'Direct Deposit Distribution 3 Routing Code, Direct Deposit Distribution 3 Account Code, Direct Deposit Distribution 3 Account Type, Direct Deposit Distribution 3 Amount, Direct Deposit Distribution 3 Percentage, '; // 5 fields
        bodyCSV += 'Direct Deposit Distribution 4 Routing Code, Direct Deposit Distribution 4 Account Code, Direct Deposit Distribution 4 Account Type, Direct Deposit Distribution 4 Amount, Direct Deposit Distribution 4 Percentage, '; // 5 fields
        bodyCSV += 'Custom Field 01, Custom Field 02, Custom Field 03, Custom Field 04, Custom Field 05, Custom Field 06, Custom Field 07, Custom Field 08, Custom Field 09, Custom Field 10, Custom Field 11, Custom Field 12, Custom Field 13, Custom Field 14, '; //14 fields
        bodyCSV += 'New Hire Flag, Exempt Status, Labor Allocation Defaults, '; //3 fields
        bodyCSV += 'Future Field, Future Field, Future Field, Future Field, Future Field, Future Field, Future Field '; //7 fields
        */
        Boolean firtTime = true;
        for(EmployeeExtractWrapper wrap : wrapList){
            if(!firtTime)
                bodyCSV += '\n';
            firtTime = false;
            // removeUnrequired (string, allowChars, allownumbers, allowspace, allowEmptyString, exceptionCharacters, stringLength) //
            
            bodyCSV += removeUnrequired('' + wrap.employee.Paycom_Employee_Number__c, false, true, false, false, null , 4) +',';  //1.Emp Code    - changed from alpha nemric to numeric
            bodyCSV += removeUnrequired(wrap.employee.ts2__Social_Security__c, false, true, false, false, null, 9)+','; //2.SSN
            bodyCSV += ',';                                                     //3.Clock Sequence
            bodyCSV += removeUnrequired(wrap.employee.LastName,true, false, true, false, '-',20) +',';      //4.LastName
            bodyCSV += removeUnrequired(wrap.employee.FirstName,true, true, true, false, '-',15)+',';       //5.FirstName
            bodyCSV += ',';                                                                                 //6.Future Field
            bodyCSV += removeUnrequired(wrap.employee.Street__c ,true, true, true, false, null,60)+',';  //7.Street Address
            bodyCSV += removeUnrequired(wrap.employee.City__c ,true, true, true, false, null,40)+',';    //8.City Address
            bodyCSV += removeUnrequired(wrap.employee.State__c ,true, false, false, false, null, 2)+','; //9.State
            bodyCSV += removeUnrequired(wrap.employee.Zip__c , false, true, false, false, null, 9)+','; //10.Postal Code
            bodyCSV += removeUnrequired(wrap.employee.HomePhone, false, true, false, true, null, 10)+',';         //11.Home Phone
            bodyCSV += checkEmail(wrap.employee.Email)+',';                         //12.Email
            bodyCSV += wrap.gender+',';                                             //13.gender
            bodyCSV += wrap.maritalStatus +',';                                     //14.marital status
            bodyCSV += getUSFormattedDate(wrap.employee.Birthdate)+',';             //15.BirthDate
            bodyCSV += wrap.ethnicBackground +',';                                  //16.ethnic background
            bodyCSV += 'A'+',';                                                     //17.employee status
            bodyCSV += getUSFormattedDate(wrap.employee.First_Day_Worked__c)+',';          //18.hire date   //changed from hired date to First work date
            bodyCSV += getUSFormattedDate(wrap.employee.Premier_Term_Date__c)+',';  //19.Termination date
            bodyCSV += 'W2' +',';       //20.Emp type
            bodyCSV += ''   +',';       //21.Part-Time/Full-Time
            bodyCSV +=  +',';   //removeNull(wrap.employee.Latest_Placement__r.ts2__Job__r.Name)  +',';    //22.Position
            bodyCSV += ''   +',';       //23.EEOC Class
            bodyCSV += removeNull(wrap.employee.Home_Department__c)  +',';          //24.Home Department
            bodyCSV += 'H'  +',';       //25.Pay Type
            bodyCSV += 'W'  +',';       //26.Pay Frequency
            bodyCSV += '0'  +',';       //27.Pay Period Salary
            bodyCSV += removeNull(wrap.employee.Latest_Placement__r.tc9_ti__Base_Pay_Rate__c)  +','; //28.Hourly Rate-1
            bodyCSV += ''  +',';        //29.Hourly Rate-2
            bodyCSV += ''  +',';        //30.Hourly Rate-3
            bodyCSV += ''  +',';        //31.Hourly Rate-4
            bodyCSV += ''  +',';        //32.Hourly Rate-5
            bodyCSV += ''  +',';        //33.Enrolled in Retirement Plan
            bodyCSV += ''  +',';    //TBDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD            //34.Workers Compensation Code
            bodyCSV += 'T'  +',';       //35.Hire Act Field
            bodyCSV += ''  +',';        //36.Tax Profile Description
            bodyCSV += removeUnrequired(wrap.employee.State__c , true, false, false, true, null, 2)+',';         //37.Live State
            bodyCSV += removeUnrequired(wrap.employee.First_Placement__r.WorkSite_State__c, true, false, false, true, null, 2)+',';//38.Work State
            bodyCSV += removeUnrequired(wrap.employee.First_Placement__r.WorkSite_State__c, true, false, false, true, null, 2)+',';//39.SUI State
            bodyCSV += wrap.fedFilingStatus  +',';                                  //40.Federal Filing Status
            bodyCSV += removeNull(wrap.employee.FedTaxExemptions__c) +',';                      //41.Federal Exemptions
            bodyCSV += removeNull(wrap.employee.FederalFilingExtras__c)  +',';                  //42.Federal Additional $
            bodyCSV += '0' +',';        //43.Federal Additional %
            bodyCSV += ''  +',';        //44.Block Federal Tax
            bodyCSV += wrap.stateFillingStatus1 +',';              //45.Live State Filing Status
            bodyCSV += removeNull(wrap.employee.StateTaxExemptions__c)  +',';       //46.Live State # Exemptions
            bodyCSV += ''  +',';        //47.Live State Exempt Amount
            bodyCSV += ''  +',';        //48.Live State Estimated Deductions
            bodyCSV += removeNull(wrap.employee.StateFilingExtras__c)  +',';        //49.Live State Additional $
            bodyCSV += '0'  +',';       //50.Live State Additional %
            bodyCSV += ''  +',';        //51.Block Live State Tax
            bodyCSV += ''  +',';                              //52.Work State Filing Status
            bodyCSV += removeNull(wrap.employee.StateTaxExemptions__c) +',';        //53.Work State # Exemptions
            bodyCSV += ''  +',';        //54.Work State Exempt Amount
            bodyCSV += ''  +',';        //55.Work State Estimated Deductions
            bodyCSV += removeNull(wrap.employee.StateFilingExtras__c)  +',';        //56.Work State Additional $
            bodyCSV += ''  +',';       //57.Work State Additional %
            bodyCSV += ''  +',';       //58.Block Work State Tax
            bodyCSV += ''  +',';       //59.EIC
            bodyCSV += ',,,,,,,,,,,,';  //60-71.Work State # Exemptions
            bodyCSV += ',';             //72.Net Direct Deposit Enabled
            bodyCSV += ',,,';           //73-75.Net Direct Deposit Enabled
            bodyCSV += ',';             //76.Direct Deposit Distributions Enabled
            bodyCSV += ',,,,,';         //77-81.Net Direct Deposit Enabled
            bodyCSV += ',,,,,';         //82-86.Net Direct Deposit Enabled
            bodyCSV += ',,,,,';         //87-91.Net Direct Deposit Enabled
            bodyCSV += ',,,,,';         //92-96.Net Direct Deposit Enabled
            bodyCSV += removeNull(wrap.employee.CheckDeliveryMethod__c) +',';   //97.Custom Field
            bodyCSV += ',,,';           //98-100.Custom Fields
            bodyCSV += ',,,,,,,,,,';    //101-110.Custom Fields
            bodyCSV += 'T' +',';        //111. New Hire
            bodyCSV += ',, , , , , , , ';     //112-120.Custom Fields
        }
        
        Document doc=new Document();
        doc.Name='EmployeeExtract_'+DateTime.now();
        doc.body=Blob.valueOf(bodycsv);
          
        //Selecting the folder where the document has to be stored 
        id folderid=[SELECT id,name from folder where developerName='Employee_Extract'].id;
        doc.FolderId =folderid;
        doc.Contenttype = 'Text/csv';
        doc.Type='csv'; 
        insert doc;
        
    }
    
    private String checkEmail(String emailString){
        if(emailString == null)
            emailString = '';
        return emailString;
    }
    
    private String getUSFormattedDate(Date dat){
        if(dat == null)
            return '';
        
        DateTime dT     = dat;
        
        Date d = date.valueOf(dT);
        String dateStr = String.valueOf(d);
        system.debug('dateeeee '+dateStr);
        return dateStr;
    }
    
    private String removeNull(String actualString){
        if(actualString == null)
            return '';
        return actualString;
    }
    
    private String removeNull(Decimal actualValue){
        if(actualValue == null)
            return '';
        return ''+actualValue;
    }
    /*
    private String mapOfSMH(String pickListValue){
        if(pickListValue == 'Single' || pickListValue == 'Married Filing Separately' || pickListValue == 'Qualifying Widow(er) with Dependent Child')
            return 'S';
        else if(pickListValue == 'Married Filing Jointly')
            return 'M';
        else if(pickListValue == 'Head of Household')
            return 'N';
        else 
            return '';
    }
    */
    //trim strings based on requirement
    private String removeUnrequired(String actualString, boolean chars, boolean numbers, boolean spaces, boolean empty, String exceptions, Integer stringSize){
        
        if(actualString == null){
            if(spaces)
                return ' ';
            else
                return '';
        }
        
        String regex = '[^';    //except the following, remove all
        if(chars)               //retain characters
            regex += 'A-Za-z';
        if(numbers)             //retain numbers
            regex += '0-9';
        if(spaces)              //retain spaces
            regex += ' ';
        if(exceptions != null)  //retain these exception characters (spcl chars)
            regex+= exceptions;
        regex += ']+';          //one or more occurrence
        
        //remove unnecessary characters
        actualString = actualString.replaceAll(regex,'');
        
        //trim characters
        if(actualString.length() <= stringSize)
            return actualString;
        else
            return actualString.subString(0, stringSize);
    }
    
    //webservice method to initiate employee extract for paycom
    webservice static void startEmployeeExtract(){
        Database.executeBatch(new Batch_EmployeeExtract());
    }
}