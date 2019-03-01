/**
* @author Vignesh Damodharan
* @date 04/03/2014
* @description This is the controller for the Sick Leave Accrual Page
*/

public class Ctrl_SFHCOPeriodEndProcessing {
    
    //Ledger Wrapper
    public class LedgerWrapper{
        
        public SFHCO_Ledger__c ledger{get;set;}
        public Decimal stipend {get;set;}
        public boolean removeRecord {get;set;}
        
        public LedgerWrapper(SFHCO_Ledger__c ledger){
            this.ledger     = ledger;
            if(ledger.Stipend_Posted__c)
                this.stipend = ledger.Stipend__c;
            else{
                //Stipend capped at max of 100
                if(ledger.Benefit_Accrual__c > 100)
                    this.stipend = VALID_CAP;
                else
                    this.stipend = ledger.Benefit_Accrual__c;
                // this.stipend = 0; //TEMPORARY fix done by Dharshni 
                                     //as requested by ROB ( to set stipend to 0 in the page)
            }
            
        }
        
        public Decimal getAllocation(){
            return ledger.Benefit_Accrual__c - this.stipend ;
            // RS 150723 removed - this.stipend the folling from line above as short-term fix, backed out 150724
        }
        
        public String getStatus(){
            String status;
            if(ledger.Allocated_Timestamp__c != null)
                status = 'Allocation Posted';
            else if(ledger.Stipend_Posted__c)
                status = 'Stipend Posted';
            else
                status = 'New';
            return status;
        }
    }
    
    public Pay_Period__c oPayPeriod {get;set;}
    public List<LedgerWrapper> listOfSFHCOLedgersforPage {get;set;}
    public List<LedgerWrapper> listOfAllSFHCOLedgers {get;set;}
    public Integer nCurrentPageNumber {get;set;}
    public Integer nTotalPages {get;set;}
    public Integer nPageSize {get;set;}
    
    public final static Integer VALID_CAP = 100;
    private ApexPages.StandardController sc;
    private RecordType oStipend;
    public Id payId{get;set;}
    
    private map<Id,tc9_ti__Transaction__c> mapOfTransactionsToBeInserted;
    
    public Ctrl_SFHCOPeriodEndProcessing(ApexPages.StandardController sc){
        
        this.sc = sc;
        payId = ApexPages.currentPage().getParameters().get('id');
        //initialize
        Initialize();
        
    }

/**
* @author Vignesh Damodharan
* @date 04/03/2014
* @description 
* @param 
* @return PageReference
*/    
    private void Initialize(){
        
        nCurrentPageNumber  = 0;
        nTotalPages         = 0;
        nPageSize           = 50;
        
        mapOfTransactionsToBeInserted = new map<Id, tc9_ti__Transaction__c>();
        
        oStipend = [SELECT Id FROM RecordType WHERE sObjectType='tc9_ti__Transaction__c' AND DeveloperName =: 'Stipend' LIMIT 1];
    
        //get the PayPeriod
        oPayPeriod = [SELECT Id, End_Date__c, Start_Date__c, Benefit_Accrued__c, Calculate_Benefits__c FROM Pay_Period__c WHERE Id=: sc.getId()];
                
        listOfSFHCOLedgersforPage   = new List<LedgerWrapper>();
        listOfAllSFHCOLedgers       = new List<LedgerWrapper>();
        
        //get the list of Ledgers if any
        for(SFHCO_Ledger__c ledger : [SELECT Id, Exclude_Allocation__c, Allocated_Timestamp__c, Candidate_Name__c, 
                                      Last_90_Days_Hours__c, Hours_This_Pay_Period__c, Pay_Period__c, Name, 
                                      Stipend__c, Allocation_Amount__c, Is_Discarded__c,
                                      Stipend_Posted__c, Type__c, Start_Date__c, End_Date__c, 
                                      Average_Hours__c, Benefit_Accrual__c, Conversion_rate__c, Candidate__c 
                                      FROM SFHCO_Ledger__c 
                                      WHERE Pay_Period__c=: oPayPeriod.Id
                                      and Is_Discarded__c = false
                                      and Average_Hours__c >= 8
                                      ORDER BY Candidate__r.Name ASC]){           
            listOfAllSFHCOLedgers.add(new LedgerWrapper(ledger));
                                      }                     
        Paginate();
    }   
        
/**
* @author Vignesh Damodharan
* @date 04/03/2014
* @description 
* @param 
* @return PageReference
*/    
    public PageReference CreateStipends(){
        
         /*Boolean isMaxCapError = false;

        

        //Iterate and validate for max cap of $100

        for(SFHCO_Ledger__c iteratingLedger : listOfSFHCOLedgersforPage){

            if(iteratingLedger.Stipend__c > VALID_CAP){

                iteratingLedger.Stipend__c.addError('Stipend cannot exceed $'+VALID_CAP);

                isMaxCapError = true;               

            }

        }*/

        Savepoint sp = Database.setSavepoint();

        Boolean isMaxCapError = false;       
        
        try{
            //to fire the validation
            /***update listOfAllSFHCOLedgers;**/ //skipping this
        
            CreateTransactiosForSFHCOLedgers();
            
            Initialize();
            
            if(!isMaxCapError)
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Stipends have been posted for the candidates.'));
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDMLMessage(0)));
            isMaxCapError = true;
            Database.rollback(sp);
        }
        
        return null;
    }

/**
* @author Vignesh Damodharan
* @date 04/03/2014
* @description 
* @param 
* @return PageReference
*/    
    public void CreateTransactiosForSFHCOLedgers(){
        
        mapOfTransactionsToBeInserted = new map<Id, tc9_ti__Transaction__c>();
        list<SFHCO_Ledger__c> listOfSFHCOStipendsToBeUpdated = new List<SFHCO_Ledger__c>();
        
        set<Id> setOfContactIds                         = new set<Id>();
        set<Id> setOfPlacementIds                       = new set<Id>();
        map<Id,Id> mapOfContactIdToLatestPlacementId    = new map<Id,Id>();
        map<Id,List<Id>> mapOfContactIdToLidtOfTESIds   = new map<Id,List<Id>>();
        
        //Iterate and create SFHCO ledgers
        for(LedgerWrapper iteratingWrapper : listOfAllSFHCOLedgers){
            setOfContactIds.add(iteratingWrapper.ledger.Candidate__c);
        }
        
        System.debug('@@@ '+setOfContactIds);
        
        //get all the placements for the candidate using the timesheets
        for(tc9_ti__Time_Sheet__c itertingTimesheet :[SELECT Id, tc9_ti__Placement__c FROM tc9_ti__Time_Sheet__c 
                                                      WHERE tc9_ti__Candidate__c IN : setOfContactIds 
                                                      AND tc9_ti__Start_Date__c >=: oPayPeriod.Start_Date__c 
                                                      AND tc9_ti__End_Date__c <=: oPayPeriod.End_Date__c]){
                                                      
            setOfPlacementIds.add(itertingTimesheet.tc9_ti__Placement__c);
        }
        
        System.debug('@@@ '+setOfPlacementIds);
        
        //Iterate and check if the location is San Franscisco
        for(ts2__Placement__c iteratingPlacement : [SELECT Id, ts2__Employee__c FROM ts2__Placement__c 
                                                    WHERE Id IN :setOfPlacementIds 
                                                    AND ts2__Job__r.ts2__Location__c = 'San Francisco' ORDER BY ts2__End_Date__c DESC]){
            if(mapOfContactIdToLatestPlacementId.get(iteratingPlacement.ts2__Employee__c) == NULL){
                mapOfContactIdToLatestPlacementId.put(iteratingPlacement.ts2__Employee__c, iteratingPlacement.Id);
            }
        }
        
        System.debug('@@@ '+mapOfContactIdToLatestPlacementId);
        
        //Iterate and create SFHCO ledgers
        for(LedgerWrapper iteratingWrapper : listOfAllSFHCOLedgers){
            
            SFHCO_Ledger__c iteratingLedger = iteratingWrapper.ledger;           
            if(!iteratingLedger.Stipend_Posted__c && 
               iteratingWrapper.stipend != NULL && 
               mapOfContactIdToLatestPlacementId.get(iteratingLedger.Candidate__c) != NULL){
                
                tc9_ti__Transaction__c newTransaction       = new tc9_ti__Transaction__c();
                newTransaction.RecordTypeId                 = oStipend.Id;
                Decimal basePayRate                         = iteratingWrapper.stipend;
                newTransaction.tc9_ti__PayRate__c           = basePayRate;
                newTransaction.tc9_ti__Adjusted_PayRate__c  = basePayRate;
                newTransaction.tc9_ti__HoursActutal__c      = 1;
                newTransaction.tc9_ti__Multiplier__c        = 1;
                newTransaction.tc9_ti__Description__c       = 'Stipend Transaction';
                newTransaction.tc9_ti__Paycode__c           = 'Stipend';
                newTransaction.tc9_ti__EntryDate__c         = date.today();
                newTransaction.tc9_ti__Placement__c         = mapOfContactIdToLatestPlacementId.get(iteratingLedger.Candidate__c);
                newTransaction.SFHCO_Ledger__c              = iteratingLedger.Id;
                system.debug('** ' + newTransaction);
                
                //to link the transactions to the ledgers
                mapOfTransactionsToBeInserted.put(iteratingLedger.Id, newTransaction);          
            }else{
                System.debug('@@@ '+iteratingLedger.Stipend_Posted__c);
                System.debug('@@@ '+iteratingLedger.Stipend__c);
                System.debug('@@@ '+mapOfContactIdToLatestPlacementId.get(iteratingLedger.Candidate__c));
            }           
        }
        
        if(!mapOfTransactionsToBeInserted.values().isEmpty()){
            try{
                insert mapOfTransactionsToBeInserted.values();            
            }catch(DmlException e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDMLMessage(0))); 
            }
        }
        
        //Create SFHCO Ledgers
        CreateSFHCOLedgersForStipends();
    }

/**
* @author Vignesh Damodharan
* @date 04/03/2014
* @description 
* @param 
* @return PageReference
*/     
    public void CreateSFHCOLedgersForStipends(){
        
        list<SFHCO_Ledger__c> listOfSFHCOStipendsToBeInserted = new List<SFHCO_Ledger__c>();
        list<SFHCO_Ledger__c> listOfSFHCOStipendsToBeUpdated = new List<SFHCO_Ledger__c>();
        
        //Iterate and create SFHCO ledgers
        for(LedgerWrapper iteratingWrapper : listOfAllSFHCOLedgers){
            
            SFHCO_Ledger__c iteratingLedger = iteratingWrapper.ledger;
            
            if(!iteratingLedger.Stipend_Posted__c && iteratingWrapper.stipend != NULL){
                
                SFHCO_Ledger__c oSFHCOStipend   = new SFHCO_Ledger__c(); 
                oSFHCOStipend.SFHCO_Ledger__c   = iteratingLedger.Id;
                oSFHCOStipend.Name              = 'SFHCO Stipend - '+iteratingLedger.Candidate_Name__c + ' - ' +Datetime.now().format('dd/MM/YYYY');
                
                oSFHCOStipend.Type__c           = 'Stipend';
                oSFHCOStipend.Start_Date__c     = iteratingLedger.Start_Date__c;
                oSFHCOStipend.End_Date__c       = iteratingLedger.End_Date__c;
                oSFHCOStipend.Candidate__c      = iteratingLedger.Candidate__c;
                
                //negate and save
                oSFHCOStipend.Benefit_Accrual__c = -iteratingWrapper.stipend;
                
                //update tha allocation
                System.debug('@@@ '+iteratingLedger.Allocation_Amount__c);
                System.debug('@@@ '+iteratingLedger.Benefit_Accrual__c);
                System.debug('@@@ '+iteratingLedger.Stipend__c);
                
                SFHCO_Ledger__c iteratingLedgerUpdate       = new SFHCO_Ledger__c(id=iteratingLedger.Id);
                iteratingLedgerUpdate.Stipend__c            = iteratingWrapper.stipend;
                iteratingLedgerUpdate.Allocation_Amount__c  = (iteratingLedger.Benefit_Accrual__c - iteratingWrapper.stipend).setScale(2);
                iteratingLedgerUpdate.Stipend_Posted__c     = true;
                
                //update the Ledgers with the Transactions 
                if(mapOfTransactionsToBeInserted.get(iteratingLedger.Id) != NULL){
                    oSFHCOStipend.Transaction__c = mapOfTransactionsToBeInserted.get(iteratingLedger.Id).Id;
                }
                
                listOfSFHCOStipendsToBeInserted.add(oSFHCOStipend);
                listOfSFHCOStipendsToBeUpdated.add(iteratingLedgerUpdate);
            }           
        }
        
        if(!listOfSFHCOStipendsToBeInserted.isEmpty()){
            insert listOfSFHCOStipendsToBeInserted;         
        }       
        
        if(!listOfSFHCOStipendsToBeUpdated.isEmpty()){
            update listOfSFHCOStipendsToBeUpdated;          
        }
    }  
       
/**
* @author Vignesh Damodharan
* @date 04/03/2014
* @description 
* @param 
* @return PageReference
*/    
    public PageReference PeriodReport(){
        
        /*Report oReport = [SELECT Id FROM Report WHERE DeveloperName = 'SFHCO_Period_Report' LIMIT 1];*/
        
        Pagereference page = new Pagereference('/apex/SFHCOReport?Id='+sc.getId());
        
        return page ;
    }        

/**
* @author Vignesh Damodharan
* @date 04/03/2014
* @description 
* @param 
* @return PageReference
*/    
    
    public PageReference CreateAllocationBatch(){
        
        list<SFHCO_Ledger__c> listOfSFHCOStipendsToBeInserted = new List<SFHCO_Ledger__c>();
        list<SFHCO_Ledger__c> listOfSFHCOStipendsToBeUpdated = new List<SFHCO_Ledger__c>();
        
        //Iterate and create SFHCO ledgers
        for(LedgerWrapper iteratingWrapper : listOfAllSFHCOLedgers){
            
            SFHCO_Ledger__c iteratingLedger = iteratingWrapper.ledger;
            
            if(iteratingLedger.Stipend_Posted__c && 
               iteratingLedger.Stipend__c != NULL &&
               iteratingLedger.Allocated_Timestamp__c == NULL &&
               !iteratingLedger.Exclude_Allocation__c){
                
                SFHCO_Ledger__c oSFHCOStipend   = new SFHCO_Ledger__c(); 
                oSFHCOStipend.SFHCO_Ledger__c   = iteratingLedger.Id;
                oSFHCOStipend.Name              = 'SFHCO Allocation - '+iteratingLedger.Candidate_Name__c + ' - ' +Datetime.now().format('dd/MM/YYYY');
                
                oSFHCOStipend.Type__c           = 'Allocation';
                oSFHCOStipend.Start_Date__c     = iteratingLedger.Start_Date__c;
                oSFHCOStipend.End_Date__c       = iteratingLedger.End_Date__c;
                oSFHCOStipend.Candidate__c      = iteratingLedger.Candidate__c;
                
                //negate and save
                oSFHCOStipend.Benefit_Accrual__c = -iteratingLedger.Allocation_Amount__c;
                
                iteratingLedger.Allocated_Timestamp__c = Datetime.now();
                
                listOfSFHCOStipendsToBeInserted.add(oSFHCOStipend);
                listOfSFHCOStipendsToBeUpdated.add(iteratingLedger);
            }           
        }
        
        if(!listOfSFHCOStipendsToBeInserted.isEmpty()){
            insert listOfSFHCOStipendsToBeInserted;         
        }       
        
        if(!listOfSFHCOStipendsToBeUpdated.isEmpty()){
            update listOfSFHCOStipendsToBeUpdated;          
        }       
        return null;
    }    
    
    //remove all selected ledger records, and create balancing negative ledger entry for it
    public void removeLedgerRecord(){
        
        List<LedgerWrapper> ledgersToBeRetained = new List<LedgerWrapper>();
        List<LedgerWrapper> ledgersToBeRemoved  = new List<LedgerWrapper>();
        
        try{
            //get rows to be retained
            for(LedgerWrapper wrap : listOfAllSFHCOLedgers){
                system.debug('***' + wrap.removeRecord);
                if(wrap.removeRecord == null || !wrap.removeRecord){
                    ledgersToBeRetained.add(wrap);
                }else{
                    ledgersToBeRemoved.add(wrap);
                }
            }
            negateDiscardedLedgers(ledgersToBeRemoved);
            listOfAllSFHCOLedgers.clear();
            listOfAllSFHCOLedgers.addAll(ledgersToBeRetained);
            BindData(nCurrentPageNumber);
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDMLMessage(0)));
        }
        
    } 
    
    private void negateDiscardedLedgers(List<LedgerWrapper> removedWrappers){
        
        list<SFHCO_Ledger__c> listOfSFHCOStipendsToBeUpserted = new List<SFHCO_Ledger__c>();
        
        for(LedgerWrapper iteratingWrapper : removedWrappers){
            
            SFHCO_Ledger__c iteratingLedger = iteratingWrapper.ledger;
            
            //create negating record
            SFHCO_Ledger__c oSFHCOStipend   = new SFHCO_Ledger__c(); 
            oSFHCOStipend.SFHCO_Ledger__c   = iteratingLedger.Id;
            oSFHCOStipend.Name              = 'SFHCO Allocation - '+iteratingLedger.Candidate_Name__c + ' - ' +Datetime.now().format('dd/MM/YYYY');
            
            oSFHCOStipend.Type__c           = 'Accrual';
            oSFHCOStipend.Start_Date__c     = iteratingLedger.Start_Date__c;
            oSFHCOStipend.End_Date__c       = iteratingLedger.End_Date__c;
            oSFHCOStipend.Candidate__c      = iteratingLedger.Candidate__c;
            
            //negate and save            
            oSFHCOStipend.Benefit_Accrual__c = -iteratingLedger.Benefit_Accrual__c;
           
            iteratingLedger.Is_Discarded__c        = true;
            
            listOfSFHCOStipendsToBeUpserted.add(oSFHCOStipend);
            listOfSFHCOStipendsToBeUpserted.add(iteratingLedger);
        }
        
        if(!listOfSFHCOStipendsToBeUpserted.isEmpty())
            upsert listOfSFHCOStipendsToBeUpserted;
    }
    
/******************************************************  Pagination Methods  *****************************************************************/

    // showing previouse btn
    public Boolean getPreviousBtnVisibility(){
        return (nCurrentPageNumber > 1);
    }
    
    // showing next btn
    public Boolean getNextBtnVisibility(){
        return ((nCurrentPageNumber * nPageSize) < listOfAllSFHCOLedgers.size());
    }
    
    // action for click next button
    public PageReference nextBtnClick() {
        BindData(nCurrentPageNumber + 1);
        return null;
    }
    
    // action for click previouse button
    public PageReference previousBtnClick() {
        BindData(nCurrentPageNumber - 1);
        return null;
    }
    
    // showing current page number
    public Integer getPageNumber(){
        return nCurrentPageNumber;
    }
    
    //get all page Size
    public Integer getPageSize(){
        return nPageSize;
    }
    
    // showing total page number
    public Integer getTotalPageNumber(){
        if (nTotalPages == 0 && listOfSFHCOLedgersforPage !=null){
            nTotalPages = listOfAllSFHCOLedgers.size() / nPageSize;
            system.debug(listOfAllSFHCOLedgers.size());
            Integer mod = listOfAllSFHCOLedgers.size() - (nTotalPages * nPageSize);
            if (mod > 0 || nTotalPages==0)
                nTotalPages++;
        }
        return nTotalPages;
    }
    
    // based on the newPageIndex to showing set of records in listOfSFHCOLedgersforPage
    private void BindData(Integer newPageIndex){
        system.debug('***************B MAP***********' + listOfAllSFHCOLedgers.size() );
        system.debug('***************B MAP***********' + listOfAllSFHCOLedgers );
        try{
            listOfSFHCOLedgersforPage.clear();     
            Transient Integer counter = 0;
            Transient Integer min = 0;
            Transient Integer max = 0;
            if (newPageIndex > nCurrentPageNumber){
                min = nCurrentPageNumber * nPageSize;
                max = newPageIndex * nPageSize;
            }
            else{
                max = newPageIndex * nPageSize;
                min = max - nPageSize;
            }
            
            for(LedgerWrapper a : listOfAllSFHCOLedgers ){
                counter++;
                system.debug(counter+' - '+min+' - '+max);
                if (counter > min && counter <= max){
                    listOfSFHCOLedgersforPage.add(a);
                    system.debug(counter+' - '+min+' - '+max);
                }
            }
            system.debug('******Refresh ***********' + listOfSFHCOLedgersforPage);
            system.debug('******Refresh ***********' + listOfSFHCOLedgersforPage.size());
            nCurrentPageNumber = newPageIndex;
            system.debug(nCurrentPageNumber);            
        }
        catch(Exception ex){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,ex.getMessage()));
        }
    }
    
    private void Paginate(){
        nTotalPages = 0;
        getTotalPageNumber();
        BindData(1);    
    }
    
    /******************************************************  Pagination Methods  *****************************************************************/      
}