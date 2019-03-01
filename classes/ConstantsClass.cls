/*
    Class      : ConstantsClass
    Test class : 
    Purpose    : Class to hold all constant variables

    Change History 
    ******************************************************************************************************************************************
         SCRUM        ModifiedBy        Date            Requested By                           Description                              Tag
    ******************************************************************************************************************************************
        SC-11478      Srinidhi.R      05/07/2016        Benoit Legalant                New Award Interpreter and legacy data
        SC-11220      Srinidhi.R      27/07/2016        Michelle Cole                  revert timesheet to new after transactions created before invoice/payrun
        SC-14030      Srinidhi.R      16/11/2016        Michelle Cole                  Replace temporary code for creating expense claim transactions
        SC-14935      Khushboo.B      04/04/2017        Michelle Cole                  Commented the expense claim error related maps
*/
global class ConstantsClass {
    
        public static final String SOURCE     = 'Time Cards';
        public static String TSSTATUSSUBMITTED   = 'Submitted';
        public static String TSSTATUSNEW     = 'New';
        public static String TSSTATUSREJECTED   = 'Rejected';
        public static String TSSTATUSAPPROVED   = 'Approved';
        public static String TSSTATUSFAILED   = 'Failed';
        public static String TSSTATUSPROCESSED   = 'Processed';
        public static String EXPSTATUSNEW     = 'New';
        public static String INVOICE_STATUS_YES = 'Yes'; 
        public static String TRANSACTIONSTATUSREADY = 'Ready';
        public static Set<String> DAYSOFWEEK   = new Set<String>{'MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY'};            
        
        //Static boolean to control the custom trigger functionality
        global static boolean Enable_Pay_Transaction_Trigger_flag = true;
        
        //Static boolean to control Payrun custom triggers
        global static boolean Is_TCS_Running_Payrun_Flag = false;
        
        //Static boolean to control Placement Trigger
        global static boolean Is_Occupation_Manually_Entered = true;
        
        //Static boolean to stop timesheet trigger
        public static boolean Is_Timesheet_Update_Allowed = true;      
        
        public static Boolean Is_New_Award_Interpreter_Flag = true;
        
        /*
         //Static boolean to check error
        public static map<Id,boolean> mapOfExpenseClaimAndError = new map<Id,boolean>();
        
        //Static boolean to get error
        public static map<Id,String> mapOfExpenseClaimAndErrorMsg = new map<Id,String>();
        
        public static Boolean Stop_Second_Execution = false;
        */
       
}