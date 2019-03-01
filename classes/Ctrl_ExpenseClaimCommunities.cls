/*
        Class           :   Ctrl_ExpenseClaimCommunities.cls
        @Author         :   Srinidhi
        Scrum           :   SC-10800
           
*/
public with sharing class Ctrl_ExpenseClaimCommunities {
    
    public Id userId {get;set;}
    public Id contactId;
    
    public Integer currentSum {get;set;}
    
    public String EC_NEW_STATUS = 'New';
    public String EC_SUBMIT_STATUS = 'Submitted';
    public String EC_APPROVED_STATUS = 'Approved';
    public String EC_REJECTED_STATUS = 'Rejected';
    
    public User currentUser;
    
    public List<tc9_ti__Expense_Claim__c> allECListofCand;
    public List<tc9_ti__Expense_Claim__c> ExpenseClaimHistoryList {get;set;}
    public map<Id,placementWrapper> mapOfPlctToECCurrent;
    public map<Id,placementWrapper> mapOfECH;
    public List<placementWrapper> currentList {get;set;}
    public List<placementWrapper> ECHList {get;set;}
    public tc9_ti__ToCloudNineConfig__c conf {get;set;}
    public String Page_FillExpenseClaim {get;set;}
    public String Page_CommunityTSLandingPage {get;set;}
    public String Page_NewExpenseClaim {get;set;}

    public Ctrl_ExpenseClaimCommunities(){
        
        conf                    = tc9_ti__ToCloudNineConfig__c.getInstance();
        mapOfPlctToECCurrent    = new map<Id,placementWrapper>();
        mapOfECH                = new map<Id,placementWrapper>();
        currentList             = new List<placementWrapper>();
        ECHList                 = new List<placementWrapper>();
        currentSum              = 0;
        
        Page_FillExpenseClaim            = UtilClass1.getAPIName('FillExpenseClaimPage');
        Page_CommunityTSLandingPage      = UtilClass1.getAPIName('Communities_LandingPage_v2');
        Page_NewExpenseClaim             = UtilClass1.getAPIName('NewExpenseClaimPortalPage'); 

        userId                  = UserInfo.getUserId();
        System.debug('!@#userId:'+userId);
        
        if(userId!=null){
            currentUser = [Select FirstName, LastName, ContactId, Contact.FirstName, Contact.LastName from User where id =: userId limit 1];
            
            if(currentUser.ContactId != null){
                contactId = currentUser.ContactId;
                
                String strQuery  = ' SELECT Id, Name, tc9_ti__Claim_Date__c, tc9_ti__Placement__c, tc9_ti__Status__c, ';
                strQuery        += ' tc9_ti__Total_Expense_Claim_Value__c, tc9_ti__Placement__r.ts2__Job__c, tc9_ti__Placement__r.ts2__Job__r.Name, tc9_ti__Placement__r.ts2__Job__r.tc9_ti__Client_Name__c, tc9_ti__Placement__r.ts2__Job__r.ts2__Account__c, ';
                strQuery        += ' tc9_ti__Candidate__c, tc9_ti__Placement__r.Name, tc9_ti__Total_Tax_Amount__c  ';
                strQuery        += ' FROM tc9_ti__Expense_Claim__c ';
                strQuery        += ' WHERE tc9_ti__Candidate__c =: contactId ';
                strQuery        += ' AND ( tc9_ti__Status__c =: EC_NEW_STATUS OR tc9_ti__Status__c =: EC_SUBMIT_STATUS OR tc9_ti__Status__c =: EC_APPROVED_STATUS OR tc9_ti__Status__c =: EC_REJECTED_STATUS ) ';
                strQuery        += ' ORDER BY tc9_ti__Claim_Date__c ';
                System.debug('!@#$% strQuery '+strQuery);
                
                allECListofCand = Database.query(strQuery);
                
                System.debug('!@#$% allECListofCand '+allECListofCand);
                
                if(!allECListofCand.isEmpty()){
                    
                    Date thisDate = date.today();
                    
                    for(tc9_ti__Expense_Claim__c thisEC: allECListofCand){
                        if(thisEC.tc9_ti__Status__c.equals(EC_NEW_STATUS) || thisEC.tc9_ti__Status__c.equals(EC_REJECTED_STATUS)){
                            //if(thisEC.Start_Date__c <= thisDate){
                                //if(thisEC.Claim_Date__c >= thisDate){
                                    if(mapOfPlctToECCurrent.containsKey(thisEC.tc9_ti__Placement__c)){
                                        placementWrapper thisplctWRP = mapOfPlctToECCurrent.get(thisEC.tc9_ti__Placement__c);
                                        thisplctWRP.thisECList.add(thisEC);
                                        thisplctWRP.numOfEC++;
                                        mapOfPlctToECCurrent.put(thisEC.tc9_ti__Placement__c,thisplctWRP);
                                    }
                                    else{
                                        mapOfPlctToECCurrent.put(thisEC.tc9_ti__Placement__c, new placementWrapper(thisEC));
                                    }
                                //}
                            //}
                        }
                        else if(thisEC.tc9_ti__Status__c.equals(EC_APPROVED_STATUS) ||thisEC.tc9_ti__Status__c.equals(EC_SUBMIT_STATUS) ){
                            if(mapOfECH.containsKey(thisEC.tc9_ti__Placement__c)){
                                placementWrapper thisplctWRP = mapOfECH.get(thisEC.tc9_ti__Placement__c);
                                thisplctWRP.thisECList.add(thisEC);
                                thisplctWRP.numOfEC++;
                                mapOfECH.put(thisEC.tc9_ti__Placement__c,thisplctWRP);
                            }
                            else{
                                mapOfECH.put(thisEC.tc9_ti__Placement__c, new placementWrapper(thisEC));
                            }
                        }
                    }
                    if(mapOfPlctToECCurrent.size() > 0)
                        currentList = mapOfPlctToECCurrent.values();
                    
                    for(placementWrapper plcWrap : mapOfECH.values()){
                        if(ECHList.size()<= 100){
                            ECHList.add(plcWrap); 
                        }
                    } 
                        
                    for(placementWrapper thisWrp: currentList){
                        currentSum += thisWrp.numOfEC;
                    }
                    
                    currentList.sort();
                    ECHList.sort();
                }
                else{
                    //if No timesheets are there Booleans to put No records to be displayed
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No TimeSheets Available'));
                }
            }
        }
         
    }
    
    public class placementWrapper implements Comparable{
        
        public Integer numOfEC {get;set;}
        public String plctName {get;set;}
        public String clientName {get;set;}
        public String JobName {get;set;}
        public Date ClaimDate {get;set;}
        public List<tc9_ti__Expense_Claim__c> thisECList {get;set;}
        
        public placementWrapper(tc9_ti__Expense_Claim__c thisEC){
            plctName    = thisEC.tc9_ti__Placement__r.Name;
            clientName  = thisEC.tc9_ti__Placement__r.ts2__Job__r.tc9_ti__Client_Name__c;
            JobName     = thisEC.tc9_ti__Placement__r.ts2__Job__r.Name;
            ClaimDate   = thisEC.tc9_ti__Claim_Date__c;
            numOfEC     = 1;
            thisECList  = new List<tc9_ti__Expense_Claim__c>();
            thisECList.add(thisEC);
        }
        
        public Integer compareTo(Object wrapperObj){
            placementWrapper wrapper = (placementWrapper) wrapperObj;
            
            if(this.clientName > wrapper.clientName)
                return 1;
            else if(this.clientName < wrapper.clientName)
                return -1;
            
            if(this.plctName > wrapper.plctName)
                return 1;
            else if(this.plctName < wrapper.plctName)
                return -1;  
            
            if(this.ClaimDate > wrapper.ClaimDate)
                return 1;
            else if(this.ClaimDate < wrapper.ClaimDate)
                return -1;
            
            return 0;
        }
        
    }
        
}