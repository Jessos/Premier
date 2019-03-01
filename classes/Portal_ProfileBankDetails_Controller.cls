/**
 * Created by Adelaide Greenaway on 6/11/17.
 *
 * Copyright © 2017 2cloudnine Pty Ltd - Strictly Confidential.
 * Not to be distributed without authorisation
 *
 * Profile Bank Details Controller for the 2c9 Custom Portal
 * this controller will be used by Portal Profile Bank Details page will check and get;
 *  - the users Bank Details as per their Payee Record
 *  - allow the Bank details to be updated for up to 3 Domestic or 1 International Account
 *
 * Test Class:
 */

public with sharing class Portal_ProfileBankDetails_Controller extends Portal_Base_Controller{

    public String payeeEarnerType {get;set;}
    public String bankTypeSelected {get;set;}

    public String bankAcc_1_Name {get;set;}
    public String bankAcc_1_Number {get;set;}
    public String bankAcc_1_BSB {get;set;}
    public Decimal bankAcc_1_AllocPc {get;set;}
    public Decimal bankAcc_1_FixedAmt {get;set;}
    public Boolean bankAcc_1_PayEntireBal {get;set;}
    //public String searchTerm1 {get;set;}
    //public String selectedBSB1 {get;set;}
    public String getSelectedItem1 {get;set;}

    public String bankAcc_2_Name {get;set;}
    public String bankAcc_2_Number {get;set;}
    public String bankAcc_2_BSB {get;set;}
    public Decimal bankAcc_2_AllocPc {get;set;}
    public Decimal bankAcc_2_FixedAmt {get;set;}
    public Boolean bankAcc_2_PayRemaining {get;set;}
    //public String searchTerm2 {get;set;}
    //public String selectedBSB2 {get;set;}
    public String getSelectedItem2 {get;set;}
    public String addBA2 {get;set;}

    public String bankAcc_3_Name {get;set;}
    public String bankAcc_3_Number {get;set;}
    public String bankAcc_3_BSB {get;set;}
    public Decimal bankAcc_3_AllocPc {get;set;}
    public Decimal bankAcc_3_FixedAmt {get;set;}
    public Boolean bankAcc_3_PayRemaining {get;set;}
    public String searchTerm3 {get;set;}
    public String selectedBSB3 {get;set;}
    public String getSelectedItem3 {get;set;}

    public String intCountry {get;set;}
    public String intBankName {get;set;}
    public String intBankAddress {get;set;}
    public String intSwiftBIC {get;set;}
    public String intAccNumIBAN {get;set;}
    public String intRecipientName {get;set;}
    public String intRecipientAddress {get;set;}
    public String intCurrency {get;set;}

    public String ABN {get;set;}
    public String GSTreg {get;set;}
    public String busStreet {get;set;}
    public String busCity {get;set;}
    public String busState {get;set;}
    public String busCountry {get;set;}
    public String busPostCode {get;set;}

    // Address one details
    public String streetOne {get;set;}
    public String cityOne {get;set;}
    public String stateOne {get;set;}
    public String postalcodeOne {get;set;}
    public String countryOne {get;set;}

    public tc9_p__Payee__c updatedPayee;

    public Portal_ProfileBankDetails_Controller() {

        initialiseData();
        //default page to view only
        showContent = true;
    }

    public void initialiseData(){
        system.debug('currentPayee.Bank_Type_Selected__c: '+currentPayee.Bank_Type_Selected__c);

        payeeEarnerType = currentPayee.tc9_p__Earner_Type__c;
        if(currentPayee.Bank_Type_Selected__c != null){
            bankTypeSelected = currentPayee.Bank_Type_Selected__c;
        }else {
            bankTypeSelected = 'NONE';
        }
        system.debug('bankTypeSelected: '+bankTypeSelected);


        //get any already saved details to show on the page
        bankAcc_1_Name = currentPayee.tc9_p__Bank_Account_1_Name__c;
        bankAcc_1_Number = currentPayee.tc9_p__Bank_Account_1_Number__c;
        bankAcc_1_BSB = currentPayee.tc9_p__Bank_Account_1_Code__c;
        bankAcc_1_AllocPc = currentPayee.tc9_p__Bank_Account_1_Allocated_Percentage__c;
        bankAcc_1_FixedAmt = currentPayee.tc9_p__Bank_Account_1_Fixed_Amount__c;
        bankAcc_1_PayEntireBal = currentPayee.tc9_p__Bank_Account_1_Pay_Remaining_Balance__c;

        if(bankAcc_1_AllocPc != null){
            getSelectedItem1 = 'percent1';
        }else if(bankAcc_1_FixedAmt != null){
            getSelectedItem1 = 'fixed1';
        }else {
            getSelectedItem1 = null;
        }
        system.debug('getSelectedItem1: '+getSelectedItem1);

        bankAcc_2_Name = currentPayee.tc9_p__Bank_Account_2_Name__c;
        bankAcc_2_Number = currentPayee.tc9_p__Bank_Account_2_Number__c;
        bankAcc_2_BSB = currentPayee.tc9_p__Bank_Account_2_Code__c;
        bankAcc_2_AllocPc = currentPayee.tc9_p__Bank_Account_2_Allocated_Percentage__c;
        bankAcc_2_FixedAmt = currentPayee.tc9_p__Bank_Account_2_Fixed_Amount__c;
        bankAcc_2_PayRemaining = currentPayee.tc9_p__Bank_Account_2_Pay_Remaining_Balance__c;

        if(bankAcc_2_AllocPc != null){
            getSelectedItem2 = 'percent2';
        }else if(bankAcc_2_FixedAmt != null){
            getSelectedItem2 = 'fixed2';
        }else {
            getSelectedItem2 = null;
        }

        bankAcc_3_Name = currentPayee.tc9_p__Bank_Account_3_Name__c;
        bankAcc_3_Number = currentPayee.tc9_p__Bank_Account_3_Number__c;
        bankAcc_3_BSB = currentPayee.tc9_p__Bank_Account_3_Code__c;
        bankAcc_3_AllocPc = currentPayee.tc9_p__Bank_Account_3_Allocated_Percentage__c;
        bankAcc_3_FixedAmt = currentPayee.tc9_p__Bank_Account_3_Fixed_Amount__c;
        bankAcc_3_PayRemaining = currentPayee.tc9_p__Bank_Account_3_Pay_Remaining_Balance__c;

        //intCountry = currentPayee.tc9_p__Bank_Intl_Country__c;
        intBankName = currentPayee.tc9_p__Bank_Intl_Bank_Name__c;
        intBankAddress = currentPayee.tc9_p__Bank_Intl_Bank_Address__c;
        intSwiftBIC = currentPayee.tc9_p__Bank_Intl_SWIFT_BIC__c;
        intAccNumIBAN = currentPayee.tc9_p__Bank_Intl_Account_IBAN__c;
        intRecipientName = currentPayee.tc9_p__Bank_Intl_Recipient_Name__c;
        intRecipientAddress = currentPayee.tc9_p__Bank_Intl_Recipient_Address__c;

        if(currentPayee.tc9_p__Bank_Intl_Country__c != null) {
            intCountry = currentPayee.tc9_p__Bank_Intl_Country__c;
        }
        if(currentPayee.tc9_p__Bank_Intl_Receiving_Currency__c != null) {
            intCurrency = currentPayee.tc9_p__Bank_Intl_Receiving_Currency__c;
        }

        ABN = currentPayee.tc9_p__ABN__c;

        if(currentPayee.tc9_p__GST_Registered__c == true){
            GSTreg = 'Yes';
        }else if(currentPayee.tc9_p__GST_Registered__c == false){
            GSTreg = 'No';
        }else{
            GSTreg = 'Unknown';
        }

        busStreet = currentPayee.tc9_p__Business_Street__c;
        busCity = currentPayee.tc9_p__Business_City__c;
        busState = currentPayee.tc9_p__Business_State_Province__c;
        busCountry = currentPayee.tc9_p__Business_Country__c;
        busPostCode = currentPayee.tc9_p__Business_Zip_Postal_Code__c;

        system.debug('payeeEarnerType: '+payeeEarnerType+' bankAcc1: '+bankAcc_1_Name+' bankAcc2:'+bankAcc_2_Name);
        system.debug('bankAcc_1_BSB: '+bankAcc_1_BSB+' busStreet: '+busStreet+' busCity:'+busCity);

        //loadSelectionDetails();
        tc9_p__Payee__c updatedPayee = currentPayee;
    }

    public void loadSelectionDetails() {
        //lets get into/out of edit/read only mode
        toggleContent();
    }

    public void Cancel(){
        initialiseData();
        //clear any edit page selections
        loadSelectionDetails();
    }

    //on submit if Aust Bank Accounts
    public PageReference submitAus_BankDetails(){

        //code below is not required if we are not doing BSB lookup
        /*if(bankAcc_1_BSB != null){
            bankAcc_1_BSB = bankAcc_1_BSB.left(7);
            bankAcc_1_BSB = bankAcc_1_BSB.remove('-');
        }
        if(bankAcc_2_BSB != null){
            bankAcc_2_BSB = bankAcc_2_BSB.left(7);
            bankAcc_2_BSB = bankAcc_2_BSB.remove('-');
        }
        if(bankAcc_3_BSB != null){
            bankAcc_3_BSB = bankAcc_3_BSB.left(7);
            bankAcc_3_BSB = bankAcc_3_BSB.remove('-');
        }*/

        system.debug('bankAcc_1_AllocPc == '+bankAcc_1_AllocPc);
        system.debug('bankAcc_2_AllocPc == '+bankAcc_2_AllocPc);


        updatedPayee = currentPayee;
        //user have selected domestic so lets get that first
        updatedPayee.Bank_Type_Selected__c = 'Australian';

        //and clear any International details
        updatedPayee.tc9_p__Bank_Intl_Country__c = null;
        updatedPayee.tc9_p__Bank_Intl_Bank_Name__c = null;
        updatedPayee.tc9_p__Bank_Intl_Bank_Address__c = null;
        updatedPayee.tc9_p__Bank_Intl_SWIFT_BIC__c = null;
        updatedPayee.tc9_p__Bank_Intl_Account_IBAN__c = null;
        updatedPayee.tc9_p__Bank_Intl_Recipient_Name__c = null;
        updatedPayee.tc9_p__Bank_Intl_Recipient_Address__c = null;
        updatedPayee.tc9_p__Bank_Intl_Receiving_Currency__c = null;

//        //if this is a Company Page then lets save the Company Details too!
//        if(payeeEarnerType == 'PTY / LTD' || payeeEarnerType == 'Managed Company Contractor'){
//            getCompanyDetails();
//        }

        //We will always have Bank Account 1 so save that always
        updatedPayee.tc9_p__Bank_Account_1_Name__c = bankAcc_1_Name;
        updatedPayee.tc9_p__Bank_Account_1_Number__c = bankAcc_1_Number;
        updatedPayee.tc9_p__Bank_Account_1_Code__c = bankAcc_1_BSB;

        //if only BA 1 is chosen, make sure BA 2 and 3 are cleared and BA1 is set to pay entire balance
        if(addBA2 == 'No'){
            //BA 1 will have entire balance
            updatedPayee.tc9_p__Bank_Account_1_Pay_Remaining_Balance__c = true;
            updatedPayee.tc9_p__Bank_Account_1_Fixed_Amount__c = null;
            updatedPayee.tc9_p__Bank_Account_1_Allocated_Percentage__c = 100;
            system.debug('got this one 111--->'+updatedPayee.tc9_p__Bank_Account_1_Allocated_Percentage__c);

            //clear bank accounts 2 and 3
            updatedPayee.tc9_p__Bank_Account_2_Name__c = null;
            updatedPayee.tc9_p__Bank_Account_2_Number__c = null;
            updatedPayee.tc9_p__Bank_Account_2_Code__c = null;
            updatedPayee.tc9_p__Bank_Account_2_Allocated_Percentage__c = null;
            updatedPayee.tc9_p__Bank_Account_2_Fixed_Amount__c = null;
            updatedPayee.tc9_p__Bank_Account_2_Pay_Remaining_Balance__c = false;

            updatedPayee.tc9_p__Bank_Account_3_Name__c = null;
            updatedPayee.tc9_p__Bank_Account_3_Number__c = null;
            updatedPayee.tc9_p__Bank_Account_3_Code__c = null;
            updatedPayee.tc9_p__Bank_Account_3_Allocated_Percentage__c = null;
            updatedPayee.tc9_p__Bank_Account_3_Fixed_Amount__c = null;
            updatedPayee.tc9_p__Bank_Account_3_Pay_Remaining_Balance__c = false;
        }
        //Now we need to see what has been selected for BA 1 allocation and make sure we uncheck pay entire for BA1
        if(addBA2 == 'Yes'){
            updatedPayee.tc9_p__Bank_Account_1_Pay_Remaining_Balance__c = false;

            if(getSelectedItem1 == 'percent1') {
                updatedPayee.tc9_p__Bank_Account_1_Allocated_Percentage__c = bankAcc_1_AllocPc;
                updatedPayee.tc9_p__Bank_Account_1_Fixed_Amount__c = null;
                system.debug('bankAcc_1_AllocPc == '+bankAcc_1_AllocPc);
            }
            if(getSelectedItem1 == 'fixed1'){
                updatedPayee.tc9_p__Bank_Account_1_Allocated_Percentage__c = null;
                updatedPayee.tc9_p__Bank_Account_1_Fixed_Amount__c = bankAcc_1_FixedAmt;
                system.debug('bankAcc_1_FixedAmt == '+bankAcc_1_FixedAmt);
            }
            // we are good to capture Bank Account 2 details
            updatedPayee.tc9_p__Bank_Account_2_Name__c = bankAcc_2_Name;
            updatedPayee.tc9_p__Bank_Account_2_Number__c = bankAcc_2_Number;
            updatedPayee.tc9_p__Bank_Account_2_Code__c = bankAcc_2_BSB;

            // and we pay remaining balance to BA2
            updatedPayee.tc9_p__Bank_Account_2_Pay_Remaining_Balance__c = true;

            if(getSelectedItem1 == 'percent1'){
                updatedPayee.tc9_p__Bank_Account_2_Allocated_Percentage__c = 100 - bankAcc_1_AllocPc;
            }else {
                updatedPayee.tc9_p__Bank_Account_2_Allocated_Percentage__c = 100;
                system.debug('got this one');
            }
            system.debug('updatedPayee.tc9_p__Bank_Account_2_Allocated_Percentage__c'+updatedPayee.tc9_p__Bank_Account_2_Allocated_Percentage__c);
            updatedPayee.tc9_p__Bank_Account_3_Fixed_Amount__c = null;
        }
        //Now check if Bank Acc 3 is still in play
        // if yes then we will have pay remaining balance set to true for BA3
        //save Bank Acc 3 details, make sure we clear Bank 3 Fixed Amount and % just in case
        //and calculate Bank Acc 3 Alloc % based on the details captured for Bank Acc 1 and Bank Acc 2.
        if (getSelectedItem3 == 'Yes') {
            updatedPayee.tc9_p__Bank_Account_3_Pay_Remaining_Balance__c = true;
            updatedPayee.tc9_p__Bank_Account_3_Name__c = bankAcc_3_Name;
            updatedPayee.tc9_p__Bank_Account_3_Number__c = bankAcc_3_Number;
            updatedPayee.tc9_p__Bank_Account_3_Code__c = bankAcc_3_BSB;
            updatedPayee.tc9_p__Bank_Account_3_Fixed_Amount__c = null;

            if(getSelectedItem1 == 'percent1' && getSelectedItem2 == 'percent2'){
                updatedPayee.tc9_p__Bank_Account_3_Allocated_Percentage__c = 100.00 - bankAcc_1_AllocPc - bankAcc_2_AllocPc;
            }else if(getSelectedItem1 == 'percent1' && getSelectedItem2 != 'percent2'){
                updatedPayee.tc9_p__Bank_Account_3_Allocated_Percentage__c = 100.00 - bankAcc_1_AllocPc;
            }else if(getSelectedItem1 != 'percent1' && getSelectedItem2 == 'percent2'){
                updatedPayee.tc9_p__Bank_Account_3_Allocated_Percentage__c = 100.00 - bankAcc_2_AllocPc;
            }else {
                updatedPayee.tc9_p__Bank_Account_3_Allocated_Percentage__c = 100.00;
            }

            //set BA2 pay remaining to false and get its fixed on % amount instead
            updatedPayee.tc9_p__Bank_Account_2_Pay_Remaining_Balance__c = false;
            if (getSelectedItem2 == 'percent2') {
                updatedPayee.tc9_p__Bank_Account_2_Allocated_Percentage__c = bankAcc_2_AllocPc;
                updatedPayee.tc9_p__Bank_Account_2_Fixed_Amount__c = null;

            }
            if (getSelectedItem2 == 'fixed2') {
                updatedPayee.tc9_p__Bank_Account_2_Allocated_Percentage__c = null;
                updatedPayee.tc9_p__Bank_Account_2_Fixed_Amount__c = bankAcc_2_FixedAmt;
            }
        }
        if(getSelectedItem3 == 'No'){
            //just make sure Bank Acc 3 is all null
            updatedPayee.tc9_p__Bank_Account_3_Pay_Remaining_Balance__c = false;
            updatedPayee.tc9_p__Bank_Account_3_Name__c = null;
            updatedPayee.tc9_p__Bank_Account_3_Number__c = null;
            updatedPayee.tc9_p__Bank_Account_3_Code__c = null;
            updatedPayee.tc9_p__Bank_Account_3_Allocated_Percentage__c = null;
            updatedPayee.tc9_p__Bank_Account_3_Fixed_Amount__c = null;
        }
        //now we are ready to try and save
        try {
            update updatedPayee;
            system.debug('saved Aussie Bank Detail: '+updatedPayee);
            //change back to 'Australian' view only
            bankTypeSelected = 'Australian';
            showContent = true;
        }catch (Exception e){
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'There is an error updating your details. Please contact your administrator or try again ');
            ApexPages.addMessage(errMsg);
            return null;
        }

        PageReference refreshPage = ApexPages.currentPage();
        refreshPage.setRedirect(true);
        return refreshPage;
    }

    public PageReference submitCompany() {
        //if this is a Company Page then save the Company Details too!
        system.debug('Saving PTY DETAILS AUS');
        updatedPayee = currentPayee;
        updatedPayee.tc9_p__ABN__c = ABN;
        if(GSTreg == 'Yes'){
            updatedPayee.tc9_p__GST_Registered__c = true;
        }else if(GSTreg != 'Yes'){
            updatedPayee.tc9_p__GST_Registered__c = false;
        }
        updatedPayee.tc9_p__Business_Street__c = busStreet;
        updatedPayee.tc9_p__Business_City__c = busCity;
        updatedPayee.tc9_p__Business_State_Province__c = busState;
        updatedPayee.tc9_p__Business_Country__c = busCountry;
        updatedPayee.tc9_p__Business_Zip_Postal_Code__c = busPostCode;

        //now we are ready to try and save
        try {
            update updatedPayee;
            system.debug('saved Company Detail: '+updatedPayee);
            showContent = true;
        }catch (Exception e){
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'There is an error updating your details. Please contact your administrator or try again ');
            ApexPages.addMessage(errMsg);
            return null;
        }

        PageReference refreshPage = ApexPages.currentPage();
        refreshPage.setRedirect(true);
        return refreshPage;
    }


    //on select of a BSB Code
    //comment out for now as not in use
    /*  public void getBSB() {
        //this is doing something regarding the JSR and VF ActionFunction, just leave here for now
        system.debug('A. bankAcc_1_BSB: '+bankAcc_1_BSB);
        system.debug('B. bankAcc_2_BSB: '+bankAcc_2_BSB);
        system.debug('C. bankAcc_3_BSB: '+bankAcc_3_BSB);
    }*/

    public PageReference submitInt(){
        updatedPayee = currentPayee;

        //user have selected international so lets get that first
        updatedPayee.Bank_Type_Selected__c = 'International';

        //and clear any domestic details
        updatedPayee.tc9_p__Bank_Account_1_Name__c = null;
        updatedPayee.tc9_p__Bank_Account_1_Number__c = null;
        updatedPayee.tc9_p__Bank_Account_1_Code__c = null;
        updatedPayee.tc9_p__Bank_Account_1_Allocated_Percentage__c = null;
        updatedPayee.tc9_p__Bank_Account_1_Fixed_Amount__c = null;
        updatedPayee.tc9_p__Bank_Account_1_Pay_Remaining_Balance__c = false;

        updatedPayee.tc9_p__Bank_Account_2_Name__c = null;
        updatedPayee.tc9_p__Bank_Account_2_Number__c = null;
        updatedPayee.tc9_p__Bank_Account_2_Code__c = null;
        updatedPayee.tc9_p__Bank_Account_2_Allocated_Percentage__c = null;
        updatedPayee.tc9_p__Bank_Account_2_Fixed_Amount__c = null;
        updatedPayee.tc9_p__Bank_Account_2_Pay_Remaining_Balance__c = false;

        updatedPayee.tc9_p__Bank_Account_3_Name__c = null;
        updatedPayee.tc9_p__Bank_Account_3_Number__c = null;
        updatedPayee.tc9_p__Bank_Account_3_Code__c = null;
        updatedPayee.tc9_p__Bank_Account_3_Allocated_Percentage__c = null;
        updatedPayee.tc9_p__Bank_Account_3_Fixed_Amount__c = null;
        updatedPayee.tc9_p__Bank_Account_3_Pay_Remaining_Balance__c = false;

        //if this is a Company Page then lets save the Company Details too!
//        if(payeeEarnerType == 'PTY / LTD' || payeeEarnerType == 'Managed Company Contractor'){
//            getCompanyDetails();
//        }

        //get the international details
        updatedPayee.tc9_p__Bank_Intl_Country__c = intCountry;
        updatedPayee.tc9_p__Bank_Intl_Bank_Name__c = intBankName;
        updatedPayee.tc9_p__Bank_Intl_Bank_Address__c = intBankAddress;
        updatedPayee.tc9_p__Bank_Intl_SWIFT_BIC__c = intSwiftBIC;
        updatedPayee.tc9_p__Bank_Intl_Account_IBAN__c = intAccNumIBAN;
        updatedPayee.tc9_p__Bank_Intl_Recipient_Name__c = intRecipientName;
        updatedPayee.tc9_p__Bank_Intl_Recipient_Address__c = intRecipientAddress;
        updatedPayee.tc9_p__Bank_Intl_Receiving_Currency__c = intCurrency;
        updatedPayee.tc9_p__Bank_Intl_Pay_Entire_Balance__c = true;

        system.debug('updatedPayee'+updatedPayee);
        try{
            system.debug('International update');
            update updatedPayee;

            //change back to 'International' view only
            bankTypeSelected = 'International';
            showContent = true;

        }catch (Exception e){
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'There is an error updating your details. Please contact your administrator or try again ');
            ApexPages.addMessage(errMsg);
            return null;
            //Error = 'There is an error updating your bank details. Please contact your administrator or try again '+e.getMessage();
        }

        PageReference refreshPage = ApexPages.currentPage();
        refreshPage.setRedirect(true);
        return refreshPage;
    }

    public List<SelectOption> getCountries(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = tc9_p__Payee__c.tc9_p__Bank_Intl_Country__c.getDescribe();
        options.add(new SelectOption('','---None---'));
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f :ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return options;
    }

    public List<SelectOption> getIntCurrencies(){
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = tc9_p__Payee__c.tc9_p__Bank_Intl_Receiving_Currency__c.getDescribe();
        options.add(new SelectOption('','---None---'));
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f :ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return options;
    }


    //JS Remoting action called when searching for a bsb
    //comment out for now as not in use
//    @RemoteAction
//    public static List<String> searchBSB(String searchTerm) {
//
//        List<String> bsbs = new List<String>();
//
//        StaticResource sr = [SELECT id, body FROM StaticResource WHERE Name = 'BSBdirectory'];
//
//        //This text file contains (as at 13/11/17) 14,850 rows, which is too big to be searched over in a
//        //single operation, therefore the contents have been broken up to workaround the error "Regex too complicated"
//        //If the Static resource is updated then this code will also require review and update to check that all strings
//        //used in substringBetween are still valid and that contents4 doesn't exceed the limit of 4,348 rows.
//        String contents = sr.body.toString();
//        String contents1 = contents.substringBetween('012-002','063-998');//4348 rows
//        String contents2 = contents.substringBetween('063-994','342-017');//4344 rows
//        String contents3 = contents.substringBetween('342-016','762-595');//4348 rows
//        String contents4 = contents.substringBetween('762-594','TRAILER');//1810 rows
//
//
//        for (String line : contents1.split('\n')) {
//            if (line.contains(searchTerm)) {
//                bsbs.add(line);
//            }
//        }
//        for(String line : contents2.split('\n')){
//            if(line.contains(searchTerm)){
//                bsbs.add(line);
//            }
//        }
//        for(String line : contents3.split('\n')){
//            if(line.contains(searchTerm)){
//                bsbs.add(line);
//            }
//        }
//        for(String line : contents4.split('\n')){
//            if(line.contains(searchTerm)){
//                bsbs.add(line);
//            }
//        }
//        return bsbs;
//
//    }
}