/*
    Class      : UtilClass
    Test class : 
    Created By : 2Cloudnine Ying Liu
    Purpose    : Utility class to hold generic methods    

    Change History 
    ******************************************************************************************************************************************
         SCRUM/CI       ModifiedBy        Date            Requested By                           Description                              Tag
    ******************************************************************************************************************************************
         Sc-10803       Khushboo.B      25/05/2016        Michelle Cole         Method to return Time entry format boolean based on the entry type on placement
         SC-11479       Khushboo.B      05/07/2016        Benoit Legalant       Adding invoice group by types static list
         SC-11771       Jagadeswary     30/09/2016        Lorelle Hargreaves    New Consolidated (Client) NZ Invoice & Credit Note
         SC-11611       Jagadeswary     05/10/2016        Michelle Cole         New Hiring Manager invoice group by
         SC-9582        Khushboo.B      23/12/2016        Michelle Cole         New Shift Record Type
         SC-17432       Jagadeswary     28/09/2017        Michelle              Update Invoice Link token and pdf generation for external security
         SC-14725       Jagadeswary     12/10/2017        David Levy            When I process invoice with a placement record type that has no Invoice Templates...
         SC-22090       Jagadeswary     07/05/2018        David Levy            CXC SAND & Dev2 PDF generation issues
*/
public class UtilClass1 {
    
    public static boolean isSiteUpdated = false;
    public static String PLACEMENT_MISSING = 'There is no placement in this timesheet';
    public static String AWARD_MISSING = 'There is no award master in this placement';
    public static String EXP = 'EXP';
    public static String ALW = 'ALW';
    // get all record type for the sObjectType
    
    // get record type Id for the sObjectType, and RecordTypeName
    public static Id getRecordTypeId(String sObjType, String RecordTypeName){
        system.debug('** ' + sObjType + ' - ' + RecordTypeName);
        List<RecordType> a = [Select Id from RecordType where SobjectType =: sObjType and  Name =: RecordTypeName ];
        if (a != null && a.size() > 0){
            return a[0].Id;
        }
        return null;
    }
    
     public static Id getTypeId_ByDeveloperName(String sObjType, String RecordTypeName){
        system.debug('** ' + sObjType + ' - ' + RecordTypeName);
        List<RecordType> a = [Select Id from RecordType where SobjectType =: sObjType and  DeveloperName =: RecordTypeName ];
        if (a != null && a.size() > 0){
            return a[0].Id;
        }
        return null;
    }
    
     public static String getAPIName(String pagename){
            List<ApexPage> page = [Select a.NamespacePrefix, a.Name From ApexPage a where name=:pagename];
            String s;
            if(page.size()==1){
                s= page.get(0).NamespacePrefix;
                if(s==null)
                    s='c__';
                else
                    s+='__';
            }
            else if(page.size()>1)
                s='tc9_ti__';
            else 
                s='c__';
            return s+pagename;
    }
    
    public static Boolean setEntryType(Boolean orgConf, String EntryType){
        if(EntryType != null && EntryType == 'Start/End Times'){
            return false;
        }
        else if(EntryType != null && EntryType == 'Total Hours'){
            return true;
        }
        return orgConf;
    }
       
    public static Integer getWeekDayNumber(String weekDay){
    if(weekDay == null) return 1;
        if(weekDay.equalsIgnoreCase('Sunday')) return 0;
        else if(weekDay.equalsIgnoreCase('Monday')) return 1;
        else if(weekDay.equalsIgnoreCase('Tuesday')) return 2;
        else if(weekDay.equalsIgnoreCase('Wednesday')) return 3;
        else if(weekDay.equalsIgnoreCase('Thursday')) return 4;
        else if(weekDay.equalsIgnoreCase('Friday')) return 5;
        else if(weekDay.equalsIgnoreCase('Saturday')) return 6;
        return 1; // default monday 
    }
    
        // get all record type for the sObjectType
    public static Map <String, Id> getRecordTypeMap_ByDeveloperName(String sObjectType){
        Map <String, Id> RecordTypeMap = new Map <String, Id>(); // stores the name and id for the Object type

        List<RecordType> rlist = [Select Id, DeveloperName from RecordType where SobjectType =: sObjectType ];
        for (RecordType a : rlist){
            RecordTypeMap.put(a.DeveloperName, a.id);
        }
        
        return RecordTypeMap;
    }
    
     public static String GetFormattedDate(Date theDate){
        
        String formattedDate = '';
        
        if(theDate.day() < 10){
            formattedDate = formattedDate+'0'+theDate.day()+'/';
        }else{
            formattedDate = formattedDate +theDate.day()+'/';
        }
        
        if(theDate.month() < 10){
            formattedDate = formattedDate+'0'+theDate.month();
        }
        else{
            formattedDate = formattedDate+''+theDate.month();
        }
        
        formattedDate = formattedDate+'/'+theDate.year();   
        
        return formattedDate;     
    }
    
 
    /*public static Map <String, Id> getRecordTypeMap(String sObjectType){
        Map <String, Id> RecordTypeMap = new Map <String, Id>(); // stores the name and id for the Object type

        List<RecordType> rlist = [Select Id, Name from RecordType where SobjectType =: sObjectType ];
        for (RecordType a : rlist){
            RecordTypeMap.put(a.name, a.id);
        }
        
        return RecordTypeMap;
    }
    
    
    
   public static Id getTypeId_ByRecordTypeId(String sObjType, String recTypeId){

        List<RecordType> a = [Select Name from RecordType where SobjectType =: sObjType and  Id =: recTypeId ];
        if (a != null && a.size() > 0){
            return a[0].Name;
        }
        return null;
    }
    
    public static Map<Id,RecordType> getTypeId_ByREcordTypeId(String sObjType){
        Map<Id,RecordType> returnMap = new Map<Id,Recordtype>([Select id,Name from RecordType where SobjectType =: sObjType]);
        
        return returnMap;
    }
   
    
    public static Map<String,String> getMapOfAPIName(List<String> pagenames){
        List<ApexPage> page = [Select a.NamespacePrefix, a.Name From ApexPage a where name in: pagenames];
        Map<String, String> mapOfpgToAPI = new Map<String,String>();
        String s = 'tc9_ti';
        for(ApexPage iPg : page){
            if(iPg.NamespacePrefix == s) {
                String pgName = s+'__'+iPg.Name;
                mapOfpgToAPI.put(iPg.Name, pgName);
            }
            else {
                mapOfpgToAPI.put(iPg.Name, iPg.Name);
            }
        }
        
        return mapOfpgToAPI; 
    }
    public static Pagereference getInternalUrlForInvoice(tc9_ti__Consolidated_Invoice__c conInvoice){
        
        if(conInvoice.tc9_ti__Invoice_template__r.tc9_ti__Page_Name__c == null || conInvoice.tc9_ti__link_token__c == null)
            return null;
        
        Pagereference returnPage = new Pagereference('/apex/'+UtilClass1.getAPIName(conInvoice.tc9_ti__Invoice_template__r.tc9_ti__Page_Name__c)+'?token='+conInvoice.tc9_ti__link_token__c);
        return returnPage;  
    }
   
    public static Map<String,String> getAPINameMap(List<String> pagenames){
            List<ApexPage> pages = [Select a.NamespacePrefix, a.Name From ApexPage a where name=:pagenames];
            Map<String,String> returnMap = new Map<String,String>();
            for(ApexPage p:pages){
                
                if(returnMap.containsKey(p.Name)){
                    if(returnMap.get(p.Name).startsWith('tc9_ti__'))
                        continue;
                    else
                        returnMap.put(p.Name,'tc9_ti__'+p.Name);
                }
                else{
                    if(p.NamespacePrefix!=null)
                        returnMap.put(p.Name,p.NamespacePrefix+'__'+p.Name);
                    else
                        returnMap.put(p.Name,p.Name);   
                }     
            }
            return returnMap;
    }
    
    //get field names from field set
    public static List<Schema.FieldSetMember> getFields(String objectName, String fieldSetName){
        return Schema.getGlobalDescribe().get(objectName).getDescribe().fieldSets.getMap().get(fieldSetName).getFields();
        //return null;
    }
    
   public static String getQuery(sObject obj, String fieldSetName){
        //start constructing query
        String queryString  = 'SELECT id, ';
        
        //get the particular fieldset for the object & query each field in the fieldset
        String objectName   = NamespaceUtil1.getObjectName(obj); 
        for(Schema.FieldSetMember f : getFields(objectName, fieldSetName))
            queryString += f.getFieldPath() + ', ';
            
        //complete query
        queryString += ' CreatedDate ';
        
        return queryString;
    }
    
    //get rounded value of a given decimal number
    public static Decimal getRoundedNumber(Decimal value, Integer places){
        if(value==null)
            return value;
        return value.setScale(places);
    }
    
    
    
    //calculate t he difference between the two date time in hours
    public static Decimal timeDifference(DateTime startTime, DateTime endTime){
        
        Decimal dt1 = startTime.getTime() / 1000/60;
        Decimal dt2 = endTime.getTime() / 1000/60;
        return ((dt2-dt1)/60.00).setScale(2);
        
    }
    
   

    public static Map<String, String> getCreditTypeMapping(){
        
        //store mapping between normal & credit invoice types
        Map<String, String> recTypeMapping  = new Map<String, String>();
        recTypeMapping.put('Temp','Credit_Temp');
        recTypeMapping.put('Perm','Credit_Perm');
        recTypeMapping.put('Shift','Credit_Shift');
        recTypeMapping.put('Fee','Credit_Fee');
        return recTypeMapping;
        
    }
    
    
    
    public static String getNumericString(String entryString){
        String numericString = '';
        integer strLength = entryString.length();
        for(integer i =0;i<entryString.length();i++){
            String s= entryString.mid(i,1);
            if(s.isNumeric()){
                numericString +=s;
            }
        }    
        return numericString;    
    }
    public static String formatAccNumber(String bsb,String accNum,String accSuffix){
        String returnString='';
        if(bsb.length()>=6){
            String str = getNumericString(bsb);
            String accSuf ='';
            if(accSuffix.length()>=3)
                accSuf = getNumericString(accSuffix).substring(0,3); 
            else
                accSuf = accSuffix; 
            returnString = str.substring(0,2)+'-'+str.substring(2,6)+'-'+getNumericString(accNum)+'-'+accSuf; 
        }
        
        return returnString;
    }
    */
    
     
    public static String Namespace = 'tc9_ti__';
    
    //Transaction record type
    public static String TRAN_TIMESHEET_REC_TYPE = 'Timesheet Entry';
    public static String TRAN_TIMESHEET_REC_TYPE_DEVName = 'Timesheet_Entry';
    public static Id TRAN_TIMESHEET_REC_TYPE_ID;
    
    public static String TRAN_ALLOWANCE_REC_TYPE = 'Allowance';
    public static Id TRAN_ALLOWANCE_REC_TYPE_ID;
    
    public static String TRAN_EXPENSE_REC_TYPE = 'Expense';
    public static Id TRAN_EXPENSE_REC_TYPE_ID;
    
    public static String TRAN_DEDUCTION_REC_TYPE = 'Deduction';
    public static Id TRAN_DEDUCTION_REC_TYPE_ID;
    
    //Award Master record type
    public static String AWARD_US_REC_TYPE = 'United_States';
    public static Id AWARD_US_REC_TYPE_ID;
    
    public static String AWARD_AUS_REC_TYPE = 'Australia';
    public static Id AWARD_AUS_REC_TYPE_ID;
    
    public static String AWARD_DAILY_REC_TYPE = 'Daily_Rates';
    public static Id AWARD_DAILY_REC_TYPE_ID;
    
    public static String AWARD_SHIFT_TIME_REC_TYPE = 'Shift_Time';
    public static Id AWARD_SHIFT_TIME_REC_TYPE_ID;
    
    public static String AWARD_SHIFT_END_TIME_REC_TYPE = 'Shift_End_Time';
    
    public static String FEE_RETAINER_REC_TYPE = 'Retainer_Fee';

    public static String CON_INVOICE_BILL2ACCOUNT_REC_TYPE = 'Bill_To_Account';
    public static String CON_INVOICE_BILL2CONTACT_REC_TYPE = 'Bill_To_Contact';
    public static String CON_INVOICE_CLIENT_REC_TYPE = 'Client';
    public static String CON_INVOICE_HIRING_MANAGER_REC_TYPE = 'Hiring_Manager';
    public static String CON_INVOICE_JOB_REC_TYPE = 'Job';
    public static String CON_INVOICE_PO_NUM_REC_TYPE = 'PO_Number';
    public static String CON_INVOICE_Placement_REC_TYPE = 'Placement';
    
    public static Set <String> invoiceGroupByList = new Set<String> {'Placement','Bill To Account','Bill To Contact', 'Client', 'Hiring Manager (Invoice Client)','Hiring Manager (Invoice Hiring Manager)', 'PO Number', 'Job'};
    
}