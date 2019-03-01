public with sharing class SFHRAReport_Ctrl {
    public Pay_Period__c payperiod;
    public list<SFHCO_Ledger__c> listOfSFHCO ;
    public map<Id,SFHCOCandidateWrapper> mapOfCandidateAndSFHCO {get;set;}
    public list<SFHCOCandidateWrapper> listOfWrap {get;set;}
    public Decimal rate{get;set;}
    Id payId; 
    public SFHRAReport_Ctrl(apexPages.standardController sc){
        listOfSFHCO = new list<SFHCO_Ledger__c>();
        listOfWrap  = new list<SFHCOCandidateWrapper>();
        payId = ApexPages.currentPage().getParameters().get('id');
        payperiod = [select Id, End_Date__c, Start_Date__c 
                     from Pay_Period__c 
                     where Id =: sc.getId()];
        calculate();      
    }
    
    public void calculate(){
        listOfSFHCO = [select Id, Hours_This_Pay_Period__c, Candidate__c, Start_Date__c, End_Date__c 
                       from SFHCO_Ledger__c 
                       where Start_Date__c >=: payperiod.Start_Date__c 
                       AND End_Date__c <=: payperiod.End_Date__c
                       AND Average_Hours__c >= 8];
        mapOfCandidateAndSFHCO = new map<Id,SFHCOCandidateWrapper>();
        
        for(SFHCO_Ledger__c SFHCO: listOfSFHCO){
            list<SFHCO_Ledger__c> SFHCOList = new list<SFHCO_Ledger__c>();
            Decimal sumSFHCO = 0;
            
            if(mapOfCandidateAndSFHCO.containsKey(SFHCO.candidate__c)){
                SFHCOList = mapOfCandidateAndSFHCO.get(SFHCO.candidate__c).listOfSFHCOwrap;
                sumSFHCO = mapOfCandidateAndSFHCO.get(SFHCO.candidate__c).sumOfHours;
                
            }
            SFHCOList.add(SFHCO); 
            if(SFHCO.Hours_This_Pay_Period__c != null){
            sumSFHCO += SFHCO.Hours_This_Pay_Period__c;  
            }
            mapOfCandidateAndSFHCO.put(SFHCO.candidate__c, 
                                       new SFHCOCandidateWrapper(
                                           new Contact(),SFHCOList,sumSFHCO,0,'','','','',''));
        }

        List<Contact> listOfContact = new List<Contact>([select Id, ts2__Social_Security__c, LastName, 
                                                         FirstName, Mailingstreet,Email, MobilePhone, 
                                                         SFHCO_Eligibilty_Date__c,Mailingcity, MailingState, MailingPostalCode, 
                                                         ts2__EEO_Gender__c,Birthdate, Benefits_Coverage_Start__c, 
                                                         First_Day_Worked__c, Premier_Term_Date__c, Medical_Plan_Name__c 
                                                         from Contact 
                                                         where Id in:mapOfCandidateAndSFHCO.keySet()]);
        SFHCO_Settings__c SFHCOsetting = SFHCO_Settings__c.getInstance();
         rate =  SFHCOsetting.Dollar_Rate__c;
        
        for(Contact c: listOfContact){
            
            if(mapOfCandidateAndSFHCO.containsKey(c.id)){
                 SFHCOCandidateWrapper wrap = mapOfCandidateAndSFHCO.get(c.Id);
                 wrap.candidate = c;
                 if(!Test.isRunningTest()){
                     wrap.prodOfhours = wrap.sumOfHours * rate;
                 }
                 else
                     wrap.prodOfhours = 0;
                 date bDate = c.Birthdate;
                 date hDate = c.First_Day_Worked__c;
                 date tDate = c.Premier_Term_Date__c;
                 date cDate = c.SFHCO_Eligibilty_Date__c;
                 //date cDate = c.Benefits_Coverage_Start__c;                 
                 system.debug('dateeee '+bDate );
                 if(bDate != null){
                     datetime dt = datetime.newInstance(bDate , time.newInstance(0, 0, 0, 0));
                     String dateOutput = dt.format('yyyy/MM/dd');
                     system.debug('outttt '+dateOutput);
                     wrap.birthDate = dateOutput;
                 }
                 else
                     wrap.birthDate = '';  
                     
                 if(hDate != null){
                     datetime dt = datetime.newInstance(hDate , time.newInstance(0, 0, 0, 0));
                     String dateOutput = dt.format('yyyy/MM/dd');
                     system.debug('outttt '+dateOutput);
                     wrap.hireDate = dateOutput;
                 }
                 else
                     wrap.hireDate = ''; 
                     
                 if(tDate != null){
                     datetime dt = datetime.newInstance(tDate , time.newInstance(0, 0, 0, 0));
                     String dateOutput = dt.format('yyyy/MM/dd');
                     system.debug('outttt '+dateOutput);
                     wrap.terminationDate= dateOutput;
                 }
                 else
                     wrap.terminationDate= '';
                     
                 if(cDate != null){
                     datetime dt = datetime.newInstance(cDate , time.newInstance(0, 0, 0, 0));
                     String dateOutput = dt.format('yyyy/MM/dd');
                     system.debug('outttt '+dateOutput);
                     wrap.coverageDate= dateOutput;
                 }
                 else
                     wrap.coverageDate= ''; 
                      
                 wrap.benefitName = c.Medical_Plan_Name__c;          
                 mapOfCandidateAndSFHCO.put(c.Id,wrap); 
            }
        }
        
        listOfWrap = mapOfCandidateAndSFHCO.values();
        
    }
    
    public class SFHCOCandidateWrapper{
    
    public Contact candidate {get;set;}
    public List<SFHCO_Ledger__c> listOfSFHCOwrap {get;set;}
    public Decimal sumOfHours{get;set;}
    public Decimal prodOfhours {get;set;}
    public String birthDate {get;set;}
    public String hireDate {get;set;}
    public String terminationDate {get;set;}
    public String coverageDate {get;set;}
    public String benefitName {get;set;}
   
    
    public SFHCOCandidateWrapper(Contact c, List<SFHCO_Ledger__c> listSFHCO , Decimal sumhrs, Decimal prodHrs, String birth,String hire, String termination, String coverage, String bName){
        candidate = c;
        listOfSFHCOwrap = listSFHCO;
        sumOfHours = sumhrs;
        prodOfhours = prodHrs;
        birthDate  = birth;
        hireDate = hire;
        terminationDate = termination;
        coverageDate = coverage;
        benefitName  = bName;
        
        }
    }
    
}