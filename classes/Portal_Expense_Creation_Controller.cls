/**
 * Created by Adelaide Greenaway on 2/1/18.
 *
 * Copyright © 2017 2cloudnine Pty Ltd - Strictly Confidential.
 * Not to be distributed without authorisation
 *
 * Controller to support the 2c9 Expense Creation / View Entry Page
 *
 * The Expense View Entry Page is accessible to the user if:
 *  - At least one Placement exists that has timesheets generated;
 *  - 2c9 Portal Community User has been granted access to complete expenses for that Placement
 * Test Class:
 */

global class Portal_Expense_Creation_Controller extends Portal_Base_Controller {

    public tc9_ti__Expense_Claim__c expClaim { get; set; }
    public List<tc9_ti__Expense__c> expenses { get; set; }
    public tc9_ti__Expense__c saveExp {get;set;}
    public tc9_ti__Expense__c selectExp {get;set;}
    public List<Attachment> expAttachments {get;set;}
    public Id expClaimID {get;set;}
    public String chosenExpId {get;set;}
    public String chosenAttId {get;set;}
    public String expType {get;set;}
    public String expNote {get;set;}
    public Date dateIncurred {get;set;}
    public Decimal preTaxAmount {get;set;}
   // public Boolean taxable {get;set;}
    public Decimal taxAmount {get;set;}
    public Decimal expTotal {get;set;}
    public Decimal selectedExpTotal {get;set;}
    public String expName {get;set;}
    public String expClaimName {get;set;}
    public String expStatus {get;set;}

    public Portal_Expense_Creation_Controller() {
 
 
    system.debug('STEP 1');

        expClaimID = System.currentPageReference().getParameters().get('Id');
        //let's get the expense claim and all its related expenses
        expClaim = [SELECT Id, Name, tc9_ti__Placement__c, tc9_ti__Candidate__c,
                tc9_ti__Placement__r.Payee__c, tc9_ti__Status__c, tc9_ti__Claim_Date__c, tc9_ti__Approved_Date__c, tc9_ti__Approver_Name__c,
                tc9_ti__Placement__r.Name, tc9_ti__Placement__r.Account_Name__c, tc9_ti__Placement__r.ts2__Job__r.Name,
                tc9_ti__Description__c, tc9_ti__Rejection_Reason__c, tc9_ti__Total_Expense_Claim_Value__c, tc9_ti__Total_Number_of_Expenses__c,
                tc9_ti__Total_Tax_Amount__c,tc9_ti__Candidate_Notes__c, Total_Inc_Tax__c,
                tc9_ti__Placement__r.tc9_ti__Expense_Claim_Approver1__c,
        (SELECT Id, Name, tc9_ti__Candidate_Notes__c, tc9_ti__Client_Notes__c, tc9_ti__Date_Incurred__c, tc9_ti__Expense_Claim__c, tc9_ti__Title__c,
                tc9_ti__Value__c, tc9_ti__Expense_Total_including_Tax__c, tc9_ti__Type__c, tc9_ti__Status__c, CurrencyIsoCode,
                tc9_ti__Tax_Amount__c, tc9_ti__Taxable__c FROM tc9_ti__Expenses__r)
        FROM tc9_ti__Expense_Claim__c
        WHERE Id = :expClaimID
        ];

//        system.debug('STEP 2');

        dateIncurred = Date.today();
        expNote = '';
        taxAmount = 0;
        //taxable = false;
        expType = '';
        preTaxAmount = 0;
        selectedExpTotal = 0;
        expName = '';
        chosenExpId=null;
        expClaimName = expClaim.Name;
        expStatus = expClaim.tc9_ti__Status__c;

//        system.debug('STEP 3');
        getExpenses();
//        system.debug('STEP 4');
    }

    public void getExpenses(){

        expenses = new List<tc9_ti__Expense__c>([SELECT Id, Name, tc9_ti__Candidate_Notes__c, tc9_ti__Client_Notes__c, tc9_ti__Date_Incurred__c, tc9_ti__Expense_Claim__c, tc9_ti__Title__c,
                tc9_ti__Value__c, tc9_ti__Expense_Total_including_Tax__c, tc9_ti__Type__c, tc9_ti__Status__c, CurrencyIsoCode,
                tc9_ti__Tax_Amount__c, tc9_ti__Taxable__c FROM tc9_ti__Expense__c WHERE tc9_ti__Expense_Claim__c =: expClaimID]);

        expTotal = expClaim.tc9_ti__Total_Expense_Claim_Value__c + expClaim.tc9_ti__Total_Tax_Amount__c;

        //get expense claim attachments
        expAttachments = [SELECT Id, Name, ParentId, Description
        FROM Attachment
        WHERE ParentId =: expClaimID];

//        system.debug('STEP 4A');
        //AND Description LIKE 'Portal Expense supporting attachment'];

    }

    public PageReference sumTotal(){
        system.debug('preTaxAmount ::: ' + preTaxAmount +++  'taxAmount:::' + taxAmount);
        if(preTaxAmount != null && taxAmount != null)
        selectedExpTotal = preTaxAmount + taxAmount;
        system.debug('TOTAL SUM UPDATE:'+selectedExpTotal);
        return null;
    }
    public PageReference addNewExp() {
        system.debug('add new expense');
        try{
            tc9_ti__Expense__c newExp = new tc9_ti__Expense__c();
            newExp.tc9_ti__Status__c = 'New';
            newExp.tc9_ti__Date_Incurred__c = Date.today();
            newExp.tc9_ti__Title__c = 'Please provide a description';
            newExp.tc9_ti__Value__c = 0;
            newExp.CurrencyIsoCode = expClaim.tc9_ti__Placement__r.CurrencyIsoCode;
            newExp.tc9_ti__Expense_Claim__c = expClaimID;
            insert newExp;

            chosenExpId = newExp.Id;
            expNote = '';

            getExpenses();
            PageReference refreshExpPage = new PageReference('/PortalExpenseViewEntry?id='+expClaimID);
            refreshExpPage.setRedirect(true);

            return refreshExpPage;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An error has occurred while creating a new Expense. Please contact your Administrator.'));
        }
        return null;
    }

    public PageReference cancelEdit(){
    system.debug('in canceledit');
        chosenExpId = null;
        dateIncurred = null;
        expName = null;
        expNote = null;

        taxAmount = null;
        //taxable = selectExp.tc9_ti__Taxable__c;
        expType = null;
        preTaxAmount = null;
        selectedExpTotal = null;

        getExpenses();
        return null;
    }

    public PageReference saveExpenses(){
        ApexPages.Message errMsg;
        String detailedErrorMsg;

        detailedErrorMsg = '';

        system.debug('update expenses: '+expenses);
        List<tc9_ti__Expense__c> entriesToUpdate = new List<tc9_ti__Expense__c>();

        try{
            for(tc9_ti__Expense__c exp: expenses){
                system.debug('exp: '+exp);
                entriesToUpdate.add(exp);
                system.debug('entriesToUpdate'+entriesToUpdate);
                if(exp.tc9_ti__Tax_Amount__c != null)
                exp.tc9_ti__Expense_Total_including_Tax__c = exp.tc9_ti__Value__c+exp.tc9_ti__Tax_Amount__c;
            }
            upsert entriesToUpdate;


            //getExpenses();
        } catch (Exception e) {
//            Error = 'There is an error updating your expense claim. Please contact your administrator or try again ' + e.getMessage();
            errMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'There is an error saving your expense claim: '+detailedErrorMsg+' Please contact your administrator or try again ');
           system.debug('error is ::: ' + e.getmessage());
            ApexPages.addMessage(errMsg);
            return null;
        }
        chosenExpId = null;
        PageReference refreshExpPage = new PageReference('/PortalExpenseViewEntry?id='+expClaimID);
        refreshExpPage.setRedirect(true);

        return refreshExpPage;
    }

    public PageReference selectToEdit(){
        system.debug('Got Selected: '+chosenExpId);
        selectExp = [SELECT Id, Name, tc9_ti__Date_Incurred__c, tc9_ti__Title__c, tc9_ti__Taxable__c, tc9_ti__Tax_Amount__c, tc9_ti__Type__c, tc9_ti__Value__c, tc9_ti__Expense_Total_including_Tax__c
            FROM tc9_ti__Expense__c
            WHERE Id =: chosenExpId];

        dateIncurred = selectExp.tc9_ti__Date_Incurred__c;
        expName = selectExp.Name;
        expNote = selectExp.tc9_ti__Title__c;

        taxAmount = selectExp.tc9_ti__Tax_Amount__c;
        if(taxAmount != null && taxAmount > 0 ){
            selectExp.tc9_ti__Taxable__c = true;
        }else{
            selectExp.tc9_ti__Taxable__c = false;
        }
        //taxable = selectExp.tc9_ti__Taxable__c;
        expType = selectExp.tc9_ti__Type__c;
        preTaxAmount = selectExp.tc9_ti__Value__c;
        selectedExpTotal = selectExp.tc9_ti__Expense_Total_including_Tax__c;

        system.debug('Got Selected dateIncurred: '+dateIncurred);
        system.debug('Got Selected expName: '+expName);
        system.debug('Got Selected expNote: '+expNote);
        system.debug('Got Selected taxAmount: '+taxAmount);
        //system.debug('Got Selected taxable: '+taxable);
        system.debug('Got Selected expType: '+expType);
        system.debug('Got Selected preTaxAmount: '+preTaxAmount);
        system.debug('Got Selected selectedExpTotal: '+selectedExpTotal);

        return null;
    }

    public PageReference saveMobExp(){
        system.debug('Save Selected: '+chosenExpId);
        saveExp = new tc9_ti__Expense__c();
        system.debug('update expenses: '+expenses);

        if(chosenExpId != null){
            saveExp.Id = chosenExpId;
            chosenExpId = null;
        }

        saveExp.tc9_ti__Date_Incurred__c = dateIncurred;
        saveExp.tc9_ti__Title__c = expNote;


        saveExp.tc9_ti__Tax_Amount__c = taxAmount;
        saveExp.tc9_ti__Type__c = expType;
        saveExp.tc9_ti__Value__c = preTaxAmount;
        if(taxAmount != null && taxAmount >0){
            saveExp.tc9_ti__Taxable__c = true;
        }else{
            saveExp.tc9_ti__Taxable__c = false;
        }
        //saveExp.tc9_ti__Taxable__c = taxable;
        saveExp.tc9_ti__Expense_Total_including_Tax__c = selectedExpTotal;

        system.debug('Save Selected dateIncurred: '+dateIncurred);
        system.debug('Save Selected expName: '+expName);
        system.debug('Save Selected expNote: '+expNote);
        system.debug('Save Selected taxAmount: '+taxAmount);
        //system.debug('Save Selected taxable: '+taxable);
        system.debug('Save Selected expType: '+expType);
        system.debug('Save Selected preTaxAmount: '+preTaxAmount);
        system.debug('Save Selected selectedExpTotal: '+selectedExpTotal);

        try{

            upsert saveExp;
            //getExpenses();
        } catch (Exception e) {
//            Error = 'There is an error updating your expense claim. Please contact your administrator or try again ' + e.getMessage();
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'There is an error saving your expense claim. Please contact your administrator or try again ');
            ApexPages.addMessage(errMsg);
            return null;
        }

        chosenExpId = null;
        PageReference refreshExpPage = new PageReference('/PortalExpenseViewEntry?id='+expClaimID);
        refreshExpPage.setRedirect(true);

        return refreshExpPage;
    }


    public PageReference submitExp(){
        List<tc9_ti__Expense__c> entriesToUpdate = new List<tc9_ti__Expense__c>();

        for(tc9_ti__Expense__c exp : [SELECT Id, tc9_ti__Expense_Claim__c, tc9_ti__Status__c FROM tc9_ti__Expense__c WHERE tc9_ti__Expense_Claim__c =: expClaimID]){
            exp.tc9_ti__Status__c = 'Submitted';
            entriesToUpdate.add(exp);
        }

        try{
            upsert entriesToUpdate;
            tc9_ti__Expense_Claim__c expC = new tc9_ti__Expense_Claim__c();
            expC.Id = expClaimID;
            expC.tc9_ti__Status__c = 'Submitted';
            upsert expC;
            //getExpenses();
        } catch (Exception e) {
//            Error = 'There is an error submitting your Expense Claim. Please contact your administrator or try again ' + e.getMessage();
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'There is an error submitting your expense claim. Please contact your administrator or try again ');
            ApexPages.addMessage(errMsg);
            return null;
        }
        PageReference refreshExpPage = new PageReference('/PortalExpenseViewEntry?id='+expClaimID);
        refreshExpPage.setRedirect(true);

        return refreshExpPage;
    }

    public PageReference resubmitExp(){
        List<tc9_ti__Expense__c> entriesToUpdate = new List<tc9_ti__Expense__c>();

        for(tc9_ti__Expense__c exp : [SELECT Id, tc9_ti__Expense_Claim__c, tc9_ti__Status__c FROM tc9_ti__Expense__c WHERE tc9_ti__Expense_Claim__c =: expClaimID]){
            exp.tc9_ti__Status__c = 'New';
            entriesToUpdate.add(exp);
        }
        try{
            upsert entriesToUpdate;
            tc9_ti__Expense_Claim__c expC = new tc9_ti__Expense_Claim__c();
            expC.Id = expClaimID;
            expC.tc9_ti__Status__c = 'New';
            upsert expC;
        } catch (Exception e) {
//            Error = 'There is an error reopening your Expense Claim for resubmission. Please contact your administrator or try again ' + e.getMessage();
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'There is an error reopening your expense claim. Please contact your administrator or try again ');
            ApexPages.addMessage(errMsg);
            return null;
        }
        PageReference refreshExpPage = new PageReference('/PortalExpenseViewEntry?id='+expClaimID);
        refreshExpPage.setRedirect(true);

        return refreshExpPage;
    }

    public PageReference deleteExp(){
        system.debug('Deleting this Exp:: '+chosenExpId);
        tc9_ti__Expense__c toDel = new tc9_ti__Expense__c(id=chosenExpId);
        try{
            delete toDel;
        } catch (Exception e) {
//            Error = 'There is an error reopening your Expense Claim for resubmission. Please contact your administrator or try again ' + e.getMessage();
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'There is an error reopening your expense claim. Please contact your administrator or try again ');
            ApexPages.addMessage(errMsg);
            return null;
        }
        getExpenses();

        PageReference refreshExpPage = new PageReference('/PortalExpenseViewEntry?id='+expClaimID);
        refreshExpPage.setRedirect(true);

        return refreshExpPage;
    }

    public PageReference deleteExpClaim() {
        system.debug('Deleting Expense Claim:: '+expClaimID);
        tc9_ti__Expense_Claim__c toDel = new tc9_ti__Expense_Claim__c(id=expClaimID);
        delete toDel;

        PageReference refreshExpPage = new PageReference('/PortalExpensesHome');
        refreshExpPage.setRedirect(true);

        return refreshExpPage;
    }

    public PageReference deleteAtt(){
        Attachment toDel = new Attachment(id=chosenAttId);
        delete toDel;
        getExpenses();
        return null;
    }
    public List<SelectOption> getTypes(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = tc9_ti__Expense__c.tc9_ti__Type__c.getDescribe();
        options.add(new SelectOption('','---None---'));
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f :ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return options;
    }

    //remote action to upload documentation and create Attachments
    @RemoteAction
    global static String doUploadAttachment(String parentId, String attachmentBody, String attachmentName, String attachmentId, String attachmentDesc) {
        return Portal_JSRemoting_FileUpload_Ctlr.doUploadAttachment(parentId, attachmentBody, attachmentName, attachmentId, attachmentDesc);
    }

}