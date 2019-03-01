/**
 * Created by Adelaide Greenaway on 21/10/17.
 *
 * Copyright © 2017 2cloudnine Pty Ltd - Strictly Confidential.
 * Not to be distributed without authorisation
 *
 * Profile Tax Details Controller for the 2c9 Custom Portal Tax Details Page
 * this controller will be used by the Tax Details page to:
 *  - allow a user to provide their TFN
 *  - allow a user to complete a Tax Declaration so they can be properly paid
 *
 * Test Class:
 */
public with sharing class Portal_ProfileTaxDetails_Controller extends Portal_Base_Controller{
    public Boolean hasTFN {get;set;}
    public String theTFN {get;set;}

    public Boolean ausResident {get;set;}
    public Boolean workingHol {get;set;}
    public Boolean claimTaxFree {get;set;}
    public Boolean otherTaxOffset {get;set;}
    public Boolean helpDebt {get;set;}
    public Boolean afsDebt {get;set;}
    public Boolean decComplete {get;set;}
    public Boolean declaration {get;set;}
    public Datetime decCompDate {get;set;}
    public String localDecCompDate {get;set;}

    public String hasTFNSelected {get;set;}
    public String tfnTypeSelected {get;set;}
    public String areYouSelection {get;set;}
    public String taxFreeSelect {get;set;}
    public String loanSelect {get;set;}
    public String debtSelect {get;set;}

    public tc9_p__Payee__c updatePayee {get;set;}

    public Portal_ProfileTaxDetails_Controller() {

        getTaxDetails();
    }

    public void getTaxDetails(){

        system.debug('currentPayee.tc9_p__Tax_File_Number__c: '+currentPayee.tc9_p__Tax_File_Number__c);
        system.debug('currentPayee.Has_Own_TFN__c: '+currentPayee.Has_Own_TFN__c);
        system.debug('currentPayee.tc9_p__Australian_Resident__c: '+currentPayee.tc9_p__Australian_Resident__c);
        system.debug('currentPayee.tc9_p__Claim_Tax_Free__c: '+currentPayee.tc9_p__Claim_Tax_Free__c);
        system.debug('currentPayee.tc9_p__Other_Tax_Offset__c: '+currentPayee.tc9_p__Other_Tax_Offset__c);
        system.debug('currentPayee.tc9_p__HELP_Debt__c: '+currentPayee.tc9_p__HELP_Debt__c);
        system.debug('currentPayee.tc9_p__Is_approved_working_holiday_maker__c: '+currentPayee.tc9_p__Is_approved_working_holiday_maker__c);
        system.debug('currentPayee.Portal_Tax_Declaration_Complete__c: '+currentPayee.Portal_Tax_Declaration_Complete__c);

        theTFN = currentPayee.tc9_p__Tax_File_Number__c;
        hasTFN = currentPayee.Has_Own_TFN__c;

        ausResident = currentPayee.tc9_p__Australian_Resident__c;
        claimTaxFree = currentPayee.tc9_p__Claim_Tax_Free__c;
        otherTaxOffset = currentPayee.tc9_p__Other_Tax_Offset__c;
        helpDebt = currentPayee.tc9_p__HELP_Debt__c;
        workingHol = currentPayee.tc9_p__Is_approved_working_holiday_maker__c;
        afsDebt = currentPayee.tc9_p__AFS_Debt__c;
        decComplete = currentPayee.Portal_Tax_Declaration_Complete__c;
        decCompDate = currentPayee.Portal_Tax_Declaration_Date__c;
        if(decCompDate != null){
            localDecCompDate = decCompDate.formatLong();
        }else{
            localDecCompDate = 'not declared';
        }

        tfnTypeSelected = currentPayee.No_TFN_Reason__c;

        system.debug('decComplete: '+decComplete);

        if(ausResident){
            areYouSelection = 'aus';
        }else if(workingHol){
            areYouSelection = 'workingHol';
        }else if(!ausResident && !workingHol){
            areYouSelection = 'foreign';
        }
    }

    public void loadSelectionDetails() {
        //default some selection values so we can properly capture and validate
        tfnTypeSelected = null;
        hasTFNSelected = null;

        if(theTFN == '111111111' || theTFN == '333333333' || theTFN == '444444444'){
            theTFN = null;
        }
        
        decCompDate = null;
        decComplete = false;
        declaration = false;

        toggleContent();
    }

    public PageReference Cancel(){
        //do nothing and return default view
        showContent = true;
        PageReference refreshPage = ApexPages.currentPage();
        refreshPage.setRedirect(true);
        return refreshPage;
    }

    public PageReference setDatetime(){
        decComplete = declaration;
        if(decComplete){
            Datetime now = Datetime.now();
            Integer offset = UserInfo.getTimeZone().getOffset(now);
            decCompDate = Datetime.now();
            localDecCompDate = decCompDate.formatLong();
            //system.debug('localDecCompDate: '+localDecCompDate);
        }else{
            decCompDate = null;
        }
        return null;
    }

    public PageReference Submit(){
        updatePayee = currentPayee;
        system.debug('Update TAX details');
        system.debug('updatedPayee:: '+updatePayee);

        try{
            if(hasTFNSelected == 'yes'){
                updatePayee.Has_Own_TFN__c = true;
                updatePayee.tc9_p__Tax_File_Number__c = theTFN;
            }else{
                updatePayee.Has_Own_TFN__c = false;
            }

            if(tfnTypeSelected =='newApp'){
                updatePayee.No_TFN_Reason__c = 'Separate Application made to ATO';
                theTFN = '111111111';
            }else if(tfnTypeSelected == 'under18'){
                updatePayee.No_TFN_Reason__c = 'Under 18';
                theTFN = '333333333';
            }else if(tfnTypeSelected == 'exemptClaim'){
                updatePayee.No_TFN_Reason__c = 'Receipt of Pension, Benefit or Allowance';
                theTFN = '444444444';
            }

            updatePayee.tc9_p__Tax_File_Number__c = theTFN;

            if(areYouSelection == 'ausres'){
                updatePayee.tc9_p__Australian_Resident__c = true;
            }else if(areYouSelection == 'forres'){
                updatePayee.tc9_p__Australian_Resident__c = false;
            }else if(areYouSelection == 'workhol'){
                updatePayee.tc9_p__Is_approved_working_holiday_maker__c = true;
            }

            if(taxFreeSelect == 'yes'){
                updatePayee.tc9_p__Claim_Tax_Free__c = true;
            }else if(taxFreeSelect == 'no'){
                updatePayee.tc9_p__Claim_Tax_Free__c = false;
            }

            if(loanSelect == 'yes'){
                updatePayee.tc9_p__HELP_Debt__c = true;
            }else{
                updatePayee.tc9_p__HELP_Debt__c = false;
            }

            if(debtSelect == 'yes'){
                updatePayee.tc9_p__AFS_Debt__c = true;
            }else{
                updatePayee.tc9_p__AFS_Debt__c = false;
            }

            updatePayee.Portal_Tax_Declaration_Complete__c = declaration;//decComplete;
            updatePayee.Portal_Tax_Declaration_Date__c = decCompDate;

            system.debug('Payee updated:: '+updatePayee);
            update updatePayee;

            showContent = true;
        }catch (Exception e){
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'There is an error submitting your Tax Details. Please contact your administrator or try again ');
            ApexPages.addMessage(errMsg);
            getTaxDetails();

            PageReference refreshTaxPage = new PageReference('/PortalProfileTaxDetails');
            refreshTaxPage.setRedirect(true);

            return refreshTaxPage;
//            return null;
            //Error = 'There is an error updating your super details. Please contact your administrator or try again '+e.getMessage();
        }
        getTaxDetails();

        PageReference refreshTaxPage = new PageReference('/PortalProfileTaxDetails');
        refreshTaxPage.setRedirect(true);

        return refreshTaxPage;
    }
}