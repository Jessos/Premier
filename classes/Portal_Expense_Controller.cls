/**
 * Created by Adelaide Greenaway on 19/12/17.
 *
 * Copyright © 2017 2cloudnine Pty Ltd - Strictly Confidential.
 * Not to be distributed without authorisation
 *
 * Controller to support the 2c9 Expense Home Page
 *
 * The Expense Home Page is accessible to the user if:
 *  - At least one Placement exists that has timesheets generated;
 *  - 2c9 Portal Community User has been granted access to complete expenses for that Placement
 * Test Class:
 */

public class Portal_Expense_Controller extends Portal_Base_Controller{
    public List<tc9_ti__Expense_Claim__c> expClaims_AllList {get;set;}
    public List<tc9_ti__Expense_Claim__c> expClaims_NewList {get;set;}
    public List<tc9_ti__Expense_Claim__c> expClaims_ApprovedList {get;set;}
    public List<tc9_ti__Expense_Claim__c> expClaims_SubmittedList {get;set;}
    public List<tc9_ti__Expense_Claim__c> expClaims_RejectedList {get;set;}

    public List<tc9_ti__Expense_Claim__c> approvedExpClaimsToShow {get;set;}
    public List<tc9_ti__Expense_Claim__c> submittedExpClaimsToShow {get;set;}
    public List<tc9_ti__Expense_Claim__c> rejectedExpClaimsToShow {get;set;}
    public List<tc9_ti__Expense_Claim__c> newExpClaimsToShow {get;set;}

    public List<ts2__Placement__c> listOfPlc {get;set;}
    public String chosenPlcId {get;set;}

    public integer approved_counter = 0;
    public integer submitted_counter = 0;
    public integer rejected_counter = 0;
    public integer new_counter = 0;

    public integer limitsize;

    public integer approved_totalSize = 0;
    public integer submitted_totalSize = 0;
    public integer rejected_totalSize = 0;
    public integer new_totalSize = 0;

    public integer approvedTotalEntry {get;set;}
    public integer approvedfirstEntry {get;set;}
    public integer approvedlastEntry {get;set;}

    public integer submittedTotalEntry {get;set;}
    public integer submittedfirstEntry {get;set;}
    public integer submittedlastEntry {get;set;}

    public integer rejectedTotalEntry {get;set;}
    public integer rejectedfirstEntry {get;set;}
    public integer rejectedlastEntry {get;set;}

    public integer newTotalEntry {get;set;}
    public integer newfirstEntry {get;set;}
    public integer newlastEntry {get;set;}

    public Boolean approvedPageTurn {get;set;}
    public Boolean submittedPageTurn {get;set;}
    public Boolean rejectedPageTurn {get;set;}
    public Boolean newPageTurn {get;set;}

    public Boolean haveExpClaims {get;set;}
    public Boolean okToCreateNew {get;set;}

    public Portal_Expense_Controller(){

        initialisePageTurns();

        //lets get a list of the placements for this payee, we will need it if we need to create a new Exp Claim!
        listOfPlc = new List<ts2__Placement__c>();

        okToCreateNew = true;

        listOfPlc = [SELECT Id, Name, Payee__c, ts2__Client__r.Name, ts2__Job__r.Name, ts2__Start_Date__c, ts2__End_Date__c FROM ts2__Placement__c WHERE Payee__r.Id =: currentPayee.Id AND Expenses_Entry_Method__c != 'Not Available'];
        system.debug('listOfPlc'+listOfPlc);

        if(listOfPlc.size()>0){
            okToCreateNew = true;
        }else{
            okToCreateNew = false;
        }

        //let's get all expense claims for this payee for a 2 year period only
        expClaims_AllList = new List<tc9_ti__Expense_Claim__c>([SELECT Id, Name, tc9_ti__Placement__c, tc9_ti__Candidate__c,
                tc9_ti__Placement__r.Payee__c, tc9_ti__Status__c, tc9_ti__Claim_Date__c, tc9_ti__Approved_Date__c,
                tc9_ti__Placement__r.Name, tc9_ti__Placement__r.Account_Name__c, tc9_ti__Placement__r.ts2__Job__r.Name,
                tc9_ti__Description__c, tc9_ti__Rejection_Reason__c, tc9_ti__Total_Expense_Claim_Value__c, tc9_ti__Total_Number_of_Expenses__c,
                tc9_ti__Total_Tax_Amount__c,tc9_ti__Candidate_Notes__c, Total_Inc_Tax__c
        FROM tc9_ti__Expense_Claim__c
        WHERE tc9_ti__Placement__r.Payee__c =: currentPayee.Id
        AND tc9_ti__Placement__r.Expenses_Entry_Method__c != 'Not Available'
        AND tc9_ti__Claim_Date__c >= LAST_N_YEARS:2
        AND tc9_ti__Claim_Date__c <= NEXT_MONTH
        ORDER BY tc9_ti__Claim_Date__c DESC ]);

        //do we have any Exp Claims to show?
        if(expClaims_AllList.size() > 0){
            haveExpClaims = true;
        }else{
            haveExpClaims = false;
        }

        system.debug('expClaims_AllList: '+expClaims_AllList);

        //now lets get all the sublists for the tabs to display
        expClaims_ApprovedList = new List<tc9_ti__Expense_Claim__c>();
        expClaims_SubmittedList = new List<tc9_ti__Expense_Claim__c>();
        expClaims_RejectedList = new List<tc9_ti__Expense_Claim__c>();
        expClaims_NewList = new List<tc9_ti__Expense_Claim__c>();

        for(tc9_ti__Expense_Claim__c exp : expClaims_AllList){
            system.debug('exp: '+exp);
            if(exp.tc9_ti__Status__c == 'Approved'){
                expClaims_ApprovedList.add(exp);
            }
            if(exp.tc9_ti__Status__c == 'Submitted'){
                expClaims_SubmittedList.add(exp);
            }
            if(exp.tc9_ti__Status__c == 'Rejected'){
                expClaims_RejectedList.add(exp);
            }
            if(exp.tc9_ti__Status__c == 'New'){
                expClaims_NewList.add(exp);
            }
        }

        //sort these lists with earliest date at the top
        expClaims_ApprovedList.sort();
        expClaims_SubmittedList.sort();
        expClaims_RejectedList.sort();
        expClaims_NewList.sort();

        //paginate the lists
        approvedExpClaimsToShow = new List<tc9_ti__Expense_Claim__c>();
        submittedExpClaimsToShow = new List<tc9_ti__Expense_Claim__c>();
        rejectedExpClaimsToShow = new List<tc9_ti__Expense_Claim__c>();
        newExpClaimsToShow = new List<tc9_ti__Expense_Claim__c>();

        approved_totalSize = expClaims_ApprovedList.size();
        rejected_totalSize = expClaims_RejectedList.size();
        new_totalSize = expClaims_NewList.size();
        submitted_totalSize = expClaims_SubmittedList.size();

        approvedTotalEntry = approved_totalSize;
        approvedfirstEntry = 1;

        newTotalEntry = new_totalSize;
        newfirstEntry = 1;

        rejectedTotalEntry = rejected_totalSize;
        rejectedfirstEntry = 1;

        submittedTotalEntry = submitted_totalSize;
        submittedfirstEntry = 1;

        limitSize = 10;

        //Initial adding of expense claims to ExpClaimsToShow
        //check the total records are more than limitSize and assign the records

        //APPROVED
        if((approved_counter+limitSize) <= approved_totalSize){
            for(Integer i=0;i<limitSize;i++){
                approvedExpClaimsToShow.add(expClaims_ApprovedList.get(i));
            }
            approvedlastEntry = 10;
        }else{
            for(Integer i=0;i<approved_totalSize;i++){
                approvedExpClaimsToShow.add(expClaims_ApprovedList.get(i));
            }
            approvedlastEntry = approved_totalSize;
        }

        //NEW
        if((new_counter+limitSize) <= new_totalSize){
            for(Integer i=0;i<limitSize;i++){
                newExpClaimsToShow.add(expClaims_NewList.get(i));
            }
            newlastEntry=10;
        }else{
            for(Integer i=0;i<new_totalSize;i++){
                newExpClaimsToShow.add(expClaims_NewList.get(i));
            }
            newlastEntry=new_totalSize;
        }

        //REJECTED
        if((rejected_counter+limitSize) <= rejected_totalSize){
            for(Integer i=0;i<limitSize;i++){
                rejectedExpClaimsToShow.add(expClaims_RejectedList.get(i));
            }
            rejectedlastEntry=10;
        }else{
            for(Integer i=0;i<rejected_totalSize;i++){
                rejectedExpClaimsToShow.add(expClaims_RejectedList.get(i));
            }
            rejectedlastEntry=rejected_totalSize;
        }

        //SUBMITTED
        if((submitted_counter+limitSize) <= submitted_totalSize){
            for(Integer i=0;i<limitSize;i++){
                submittedExpClaimsToShow.add(expClaims_SubmittedList.get(i));
            }
            submittedlastEntry=10;
        }else{
            for(Integer i=0;i<submitted_totalSize;i++){
                submittedExpClaimsToShow.add(expClaims_SubmittedList.get(i));
            }
            submittedlastEntry=submitted_totalSize;
        }
    }

    public void initialisePageTurns(){

        newPageTurn = true;

        approvedPageTurn = false;
        rejectedPageTurn = false;
        submittedPageTurn = false;

    }

    public PageReference setupNewExpClaim(){

        PageReference goToSelectExpClaim = new PageReference('/PortalExpClaimPlc');
        goToSelectExpClaim.setRedirect(true);

        return goToSelectExpClaim;
    }
    public PageReference createNew(){
        system.debug('createNew');
        system.debug('chosenPlcId: '+chosenPlcId);
        tc9_ti__Expense_Claim__c newExp = new tc9_ti__Expense_Claim__c();
        newExp.tc9_ti__Candidate__c = currentPayee.tc9_p__Contact__c;
        newExp.tc9_ti__Claim_Date__c = Date.today();
        newExp.tc9_ti__Placement__c = chosenPlcId;
        try{
            insert newExp;
        }catch (Exception e){
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'There is an error creating a new expense claim. Please contact your administrator or try again ');
            ApexPages.addMessage(errMsg);
            return null;
        }

        system.debug('newExp:'+newExp);
        PageReference createExpPage = new PageReference('/PortalExpenseViewEntry?id='+newExp.Id);
        createExpPage.setRedirect(true);

        return createExpPage;
    }

    public void nextApproved(){
        approvedExpClaimsToShow.clear();
        approved_counter = approved_counter+limitsize;

        approvedPageTurn = true;

        newPageTurn = false;
        rejectedPageTurn = false;
        submittedPageTurn = false;

        approvedfirstEntry=approvedlastEntry+1;
        //APPROVED
        if((approved_counter + limitSize) <= approved_totalSize){
            for(Integer i=approved_counter;i<(approved_counter+limitSize);i++){
                approvedExpClaimsToShow.add(expClaims_ApprovedList.get(i));
            }
            approvedlastEntry=(approvedfirstEntry-1)+limitsize;
        } else{
            for(Integer i=approved_counter;i<approved_totalSize;i++){
                approvedExpClaimsToShow.add(expClaims_ApprovedList.get(i));
            }
            approvedlastEntry=approved_totalSize;
        }
    }

    public void previousApproved(){
        approvedExpClaimsToShow.clear();
        approved_counter = approved_counter-limitsize;

        approvedPageTurn = true;

        newPageTurn = false;
        rejectedPageTurn = false;
        submittedPageTurn = false;

        for(Integer i=approved_counter;i<(approved_counter+limitSize); i++){
            approvedExpClaimsToShow.add(expClaims_ApprovedList.get(i));
        }
        approvedfirstEntry=approved_counter+1;
        approvedlastEntry=approved_counter+limitsize;
    }

    public Boolean getDisableNextApproved(){
        if((approved_counter + limitSize) >= approved_totalSize )
            return true ;
        else
            return false ;
    }

    public Boolean getDisablePreviousApproved(){
        if(approved_counter == 0)
            return true ;
        else
            return false ;
    }

    public void nextNew(){
        newExpClaimsToShow.clear();
        new_counter = new_counter+limitsize;

        newfirstEntry=newlastEntry+1;

        newPageTurn = true;

        approvedPageTurn = false;
        rejectedPageTurn = false;
        submittedPageTurn = false;

        //NEW
        if((new_counter + limitSize) <= new_totalSize){
            for(Integer i=new_counter;i<(new_counter+limitSize);i++){
                newExpClaimsToShow.add(expClaims_NewList.get(i));
            }
            newlastEntry=(newfirstEntry-1)+limitsize;
        } else{
            for(Integer i=new_counter;i<new_totalSize;i++){
                newExpClaimsToShow.add(expClaims_NewList.get(i));
            }
            newlastEntry=new_totalSize;
        }
    }

    public void previousNew(){
        newExpClaimsToShow.clear();
        new_counter = new_counter-limitsize;

        newPageTurn = true;

        approvedPageTurn = false;
        rejectedPageTurn = false;
        submittedPageTurn = false;

        for(Integer i=new_counter;i<(new_counter+limitSize); i++){
            newExpClaimsToShow.add(expClaims_NewList.get(i));
        }
        newfirstEntry=new_counter+1;
        newlastEntry=new_counter+limitsize;
    }

    public Boolean getDisableNextNew(){

        if((new_counter + limitSize) >= new_totalSize )
            return true ;
        else
            return false ;
    }

    public Boolean getDisablePreviousNew(){
        if(new_counter == 0)
            return true ;
        else
            return false ;
    }

    public void nextRejected(){
        rejectedExpClaimsToShow.clear();
        rejected_counter = rejected_counter+limitsize;

        rejectedfirstEntry=rejectedlastEntry+1;

        rejectedPageTurn = true;

        approvedPageTurn = false;
        newPageTurn = false;
        submittedPageTurn = false;

        //REJECTED
        if((rejected_counter + limitSize) <= rejected_totalSize){
            for(Integer i=rejected_counter;i<(rejected_counter+limitSize);i++){
                rejectedExpClaimsToShow.add(expClaims_RejectedList.get(i));
            }
            rejectedlastEntry=(rejectedfirstEntry-1)+limitsize;
        } else{
            for(Integer i=rejected_counter;i<rejected_totalSize;i++){
                rejectedExpClaimsToShow.add(expClaims_RejectedList.get(i));
            }
            rejectedlastEntry=rejected_totalSize;
        }
    }

    public void previousRejected(){
        rejectedExpClaimsToShow.clear();
        rejected_counter = rejected_counter-limitsize;

        rejectedPageTurn = true;

        approvedPageTurn = false;
        newPageTurn = false;
        submittedPageTurn = false;

        for(Integer i=rejected_counter;i<(rejected_counter+limitSize); i++){
            rejectedExpClaimsToShow.add(expClaims_RejectedList.get(i));
        }
        rejectedfirstEntry=rejected_counter+1;
        rejectedlastEntry=rejected_counter+limitsize;
    }

    public Boolean getDisableNextRejected(){
        if((rejected_counter + limitSize) >= rejected_totalSize )
            return true ;
        else
            return false ;
    }

    public Boolean getDisablePreviousRejected(){
        if(rejected_counter == 0)
            return true ;
        else
            return false ;
    }

    public void nextSubmitted(){
        submittedExpClaimsToShow.clear();
        submitted_counter = submitted_counter+limitsize;

        submittedfirstEntry=submittedlastEntry+1;

        submittedPageTurn = true;

        approvedPageTurn = false;
        newPageTurn = false;
        rejectedPageTurn = false;

        //SUBMITTED
        if((submitted_counter + limitSize) <= submitted_totalSize){
            for(Integer i=submitted_counter;i<(submitted_counter+limitSize);i++){
                submittedExpClaimsToShow.add(expClaims_SubmittedList.get(i));
            }
            submittedlastEntry=(submittedfirstEntry-1)+limitsize;
        } else{
            for(Integer i=submitted_counter;i<submitted_totalSize;i++){
                submittedExpClaimsToShow.add(expClaims_SubmittedList.get(i));
            }
            submittedlastEntry=submitted_totalSize;
        }
    }

    public void previousSubmitted(){
        submittedExpClaimsToShow.clear();
        submitted_counter = submitted_counter-limitsize;

        submittedPageTurn = true;
        
        approvedPageTurn = false;
        newPageTurn = false;
        submittedPageTurn = false;

        for(Integer i=submitted_counter;i<(submitted_counter+limitSize); i++){
            submittedExpClaimsToShow.add(expClaims_SubmittedList.get(i));
        }
    }

    public Boolean getDisableNextSubmitted(){
        if((submitted_counter + limitSize) >= submitted_totalSize )
            return true ;
        else
            return false ;
    }

    public Boolean getDisablePreviousSubmitted(){
        if(submitted_counter == 0)
            return true ;
        else
            return false ;
    }
}