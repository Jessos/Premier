/**
 * Created by Adelaide Greenaway on 15/11/17.
 *
 * Copyright © 2017 2cloudnine Pty Ltd - Strictly Confidential.
 * Not to be distributed without authorisation
 *
 * Profile Superannuation Details Controller for the 2c9 Custom Portal
 * this controller will be used by Portal Profile Superannuation Details page, will check and get;
 *  - the users Superannuation Details as per their Payee Record
 *  - allow the Superannuation details to be updated for only 1 Superannuation Account
 *
 * Test Class:
 */

public with sharing class Portal_ProfileSuperDetails_Controller extends Portal_Base_Controller{

    public String payeeEarnerType {get;set;}

    public String apraRSA_Fund {get;set;}
    public String apraRSA_FundName {get;set;}
    public String apraRSA_RecType {get;set;}

    public String smsfMemberNumber {get;set;}
    public String apraRSAMemberNumber {get;set;}
    public String smsfRecType {get;set;}

    public String empNomMemberNumber {get;set;}

    public String empNomFund {get;set;}
    public String empNomFundName {get;set;}

    public String superTypeSelected {get;set;}
    public String haveEmpNomNumber {get;set;}

    public String searchedFund {get;set;}
    public String selectedFund {get;set;}
    public String selectedBSB {get;set;}

    public String street {get;set;}
    public String city {get;set;}
    public String state {get;set;}
    public String postalcode {get;set;}
    public String country {get;set;}

    public String smsfFund {get;set;}
    public String smsfFundName {get;set;}
    public String smsfFundABN {get;set;}
    public String smsfFundESA {get;set;}
    public String smsfFundBSB {get;set;}
    public String smsfFundAccName {get;set;}
    public String smsfFundAccNum {get;set;}
    public String smsfFundPhone {get;set;}
    public String smsfFundEmail {get;set;}

    public tc9_p__Superannuation_Fund__c newFund;
    public List<Attachment> smsfAttachments {get;set;}
    public String chosenAttId {get;set;}

    public Boolean smsfFundTrusteeDec {get;set;}

    public tc9_p__Payee__c updatedPayee;

    public Portal_ProfileSuperDetails_Controller(){
        payeeEarnerType = currentPayee.tc9_p__Earner_Type__c;

        smsfRecType = [SELECT Id from RecordType where developerName = 'Self_Managed' LIMIT 1].Id;
        apraRSA_RecType = [SELECT Id from RecordType where developerName = 'APRA_and_RSA_Funds' LIMIT 1].Id;

        empNomFund = currentPayee.tc9_p__Payment_Entity__r.Default_Superannuation_Fund__c;
        empNomFundName = currentPayee.tc9_p__Payment_Entity__r.Default_Superannuation_Fund__r.tc9_p__Fund_Name__c;

        superTypeSelected = currentPayee.Fund_Option_Selected__c;
        system.debug('1. superTypeSelected: '+superTypeSelected);

            //update the variables as based on the Super Fund Option selected

            if(superTypeSelected == 'APRA/RSA' || superTypeSelected == 'apraRSA'){

            apraRSAMemberNumber = currentPayee.tc9_p__Super_Fund_1_Member_Number__c;
            apraRSA_Fund = currentPayee.tc9_p__Super_Fund_1__c;
            apraRSA_FundName = currentPayee.tc9_p__Super_Fund_1_Name__c;

            }else if(superTypeSelected == 'Employer Nominated' || superTypeSelected == 'empNom') {
                empNomMemberNumber = currentPayee.tc9_p__Super_Fund_1_Member_Number__c;
            }

            system.debug('2. apraRSAMemberNumber: '+apraRSAMemberNumber);
            system.debug('2. apraRSA_Fund: '+apraRSA_Fund);
            system.debug('2. apraRSA_FundName: '+apraRSA_FundName);

        if(superTypeSelected == 'SMSF'){
            system.debug('SUPER SELECTED IS SMSF');
            smsfMemberNumber = currentPayee.tc9_p__Super_Fund_1_Member_Number__c;

            smsfFund = currentPayee.tc9_p__Super_Fund_1__c;
            smsfFundName = currentPayee.tc9_p__Super_Fund_1__r.tc9_p__Fund_Name__c;
            smsfFundABN = currentPayee.tc9_p__Super_Fund_1__r.tc9_p__Fund_ABN__c;
            smsfFundESA = currentPayee.tc9_p__Super_Fund_1__r.tc9_p__Fund_Electronic_Service_Address__c;
            smsfFundBSB = currentPayee.tc9_p__Super_Fund_1__r.tc9_p__Fund_Branch__c;
            smsfFundAccName = currentPayee.tc9_p__Super_Fund_1__r.tc9_p__Fund_Account_Name__c;
            smsfFundAccNum = currentPayee.tc9_p__Super_Fund_1__r.tc9_p__Fund_Account_Number__c;
            smsfFundPhone = currentPayee.tc9_p__Super_Fund_1__r.tc9_p__Fund_Phone__c;
            smsfFundEmail = currentPayee.tc9_p__Super_Fund_1__r.tc9_p__Fund_Email__c;
            smsfFundTrusteeDec = currentPayee.tc9_p__Super_Fund_1__r.SMSF_Trustee_Dec__c;
            street = currentPayee.tc9_p__Super_Fund_1__r.tc9_p__Fund_Street__c;
            city = currentPayee.tc9_p__Super_Fund_1__r.tc9_p__Fund_City__c;
            state = currentPayee.tc9_p__Super_Fund_1__r.tc9_p__Fund_State_Province__c;
            postalcode = currentPayee.tc9_p__Super_Fund_1__r.tc9_p__Fund_Zip_Postal_Code__c;
            country = currentPayee.tc9_p__Super_Fund_1__r.tc9_p__Fund_Country__c;
        }
            system.debug('2. smsfMemberNumber: '+smsfMemberNumber);
            system.debug('2. smsfFundName: '+smsfFundName);
            system.debug('2. smsfFund: '+smsfFund);

        //get smsf attachments
        smsfAttachments = [SELECT Id, Name, ParentId, Description
                                            FROM Attachment
                                            WHERE ParentId =: currentPayee.Id
                                            AND Description LIKE 'SMSF'];
    }


    public void loadSelectionDetails() {
        //default some selection values so we can properly capture and validate
        superTypeSelected = null;
        haveEmpNomNumber = null;

        smsfFundTrusteeDec = false;

        toggleContent();
    }

    public PageReference saveSuper(){
        updatedPayee = currentPayee;

        if(superTypeSelected == 'empNom'){
            system.debug('Super update -- EMP NOM');

            updatedPayee.tc9_p__Super_Fund_1__c = empNomFund;
            updatedPayee.tc9_p__Super_Fund_1_Name__c = empNomFundName;
            if(haveEmpNomNumber == 'Yes'){
                updatedPayee.tc9_p__Super_Fund_1_Member_Number__c = empNomMemberNumber;
            }else if(haveEmpNomNumber == 'No'){
                updatedPayee.tc9_p__Super_Fund_1_Member_Number__c = '000000000';
            }
            updatedPayee.Fund_Option_Selected__c = 'Employer Nominated';
        }
        if(superTypeSelected == 'apraRSA') {
            system.debug('Super update --- APRA/RSA');

            tc9_p__Superannuation_Fund__c fundRecord = [
                    SELECT Id, Super_Search_Field__c, tc9_p__Fund_Name__c
                            FROM tc9_p__Superannuation_Fund__c
                            WHERE Id = :selectedFund];

            updatedPayee.tc9_p__Super_Fund_1__c = fundRecord.Id;
            updatedPayee.tc9_p__Super_Fund_1_Name__c = fundRecord.tc9_p__Fund_Name__c;
            updatedPayee.Fund_Option_Selected__c = 'APRA/RSA';
            updatedPayee.tc9_p__Super_Fund_1_Member_Number__c = apraRSAMemberNumber;
        }
        if(superTypeSelected == 'smsf'){
            //Create the SMSF Super Fund
            newFund = new tc9_p__Superannuation_Fund__c();

            system.debug('SMSF Save in progress');
            system.debug('smsfFundBSB:'+smsfFundBSB);
            system.debug('selectedBSB:'+selectedBSB);
            if(smsfFundBSB != null){
                smsfFundBSB = smsfFundBSB.left(7);
                smsfFundBSB = smsfFundBSB.remove('-');
            }
            newFund.tc9_p__Fund_Name__c = smsfFundName;
            newFund.tc9_p__Fund_ABN__c = smsfFundABN;
            newFund.tc9_p__Fund_Street__c = street;
            newFund.tc9_p__Fund_City__c = city;
            newFund.tc9_p__Fund_State_Province__c = state;
            newFund.tc9_p__Fund_Zip_Postal_Code__c = postalcode;
            newFund.tc9_p__Fund_Country__c = country;
            newFund.tc9_p__Fund_Electronic_Service_Address__c = smsfFundESA;
            newFund.tc9_p__Fund_Branch__c = smsfFundBSB;
            newFund.tc9_p__Fund_Account_Name__c = smsfFundAccName;
            newFund.tc9_p__Fund_Account_Number__c = smsfFundAccNum;
            newFund.tc9_p__Fund_Phone__c = smsfFundPhone;
            newFund.tc9_p__Fund_Email__c = smsfFundEmail;
            newFund.SMSF_Trustee_Dec__c = smsfFundTrusteeDec;
            newFund.tc9_p__Status__c = 'Active';
            newFund.RecordTypeId = smsfRecType;

            //check if this fund already exists based on the ABN
            List<tc9_p__Superannuation_Fund__c> fundRecord = [
                    SELECT Id, tc9_p__Fund_ABN__c, RecordTypeId, tc9_p__Fund_Name__c
                            FROM tc9_p__Superannuation_Fund__c
                            WHERE tc9_p__Fund_ABN__c = :smsfFundABN
                            AND RecordTypeId = :smsfRecType
                            AND tc9_p__Fund_Name__c LIKE :smsfFundName
                            LIMIT 1];

            if(fundRecord.size() > 0){
                newFund.Id = fundRecord[0].Id;
                system.debug('FOUND AN SMSF with same name and ABN!! --- fundRecord---'+fundRecord);
                //update newFund;
            }else{
                newFund.Id = null;
                //insert newFund;
            }

            //now we are ready to try and save
            try {
                system.debug('SMSF newFund : '+newFund);
                upsert newFund;
                system.debug('newFund.Id: '+newFund.Id);
            }catch (Exception e){
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'There is an error updating your details. Please contact your administrator or try again ');
                ApexPages.addMessage(errMsg);
                return null;
            }
                updatedPayee.tc9_p__Super_Fund_1__c = newFund.Id;
                updatedPayee.tc9_p__Super_Fund_1_Name__c = smsfFundName;
                updatedPayee.Fund_Option_Selected__c = 'SMSF';
                updatedPayee.tc9_p__Super_Fund_1_Member_Number__c = smsfMemberNumber;
            }
            updatedPayee.tc9_p__Super_Fund_1_Allocated_Percentage__c = 100;
            try {
                system.debug('Ready to update Payee');

                update updatedPayee;

                system.debug('Ready to update Payee --- updatedPayee: '+updatedPayee);

                showContent = true;
                system.debug('Super update --- superTypeSelected --- '+superTypeSelected+' empNomMemberNumber:'+empNomMemberNumber);
                system.debug('Super update --- superTypeSelected --- '+superTypeSelected+' apraRSAMemberNumber:'+empNomMemberNumber);
                system.debug('Super update --- superTypeSelected --- '+superTypeSelected+' empNomMemberNumber:'+empNomMemberNumber);

            }catch (Exception e){
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'There is an error updating your super details. Please contact your administrator or try again ');
                ApexPages.addMessage(errMsg);
                return null;
            }

        PageReference refreshPage = ApexPages.currentPage();
        refreshPage.setRedirect(true);
        return refreshPage;
    }

    public PageReference Cancel(){
        //do nothing and return default view
        showContent = true;
        PageReference refreshPage = ApexPages.currentPage();
        refreshPage.setRedirect(true);
        return refreshPage;
    }
    public PageReference deleteAtt(){
        Attachment toDel = new Attachment(id=chosenAttId);
        delete toDel;
        showContent = false;
        PageReference refreshExpPage = new PageReference('/PortalProfileSuperDetails');
        refreshExpPage.setRedirect(true);

        return refreshExpPage;
    }

    //on select of a fundCode
    public void getFund() {
        //this is doing something regarding the JSR and VF ActionFunction, just leave here for now
    }
    //on select of a BSB Code - currently not in use
//    public void getBSB() {
        //this is doing something regarding the JSR and VF ActionFunction, just leave here for now
//    }

    //JS Remoting action called when searching for a superfund
    @RemoteAction
    public static List<tc9_p__Superannuation_Fund__c> searchFund(String searchTerm) { //List<String> searchFund(String searchTerm) {

        Id fundRecType;
        List<tc9_p__Superannuation_Fund__c> fundList = new List<tc9_p__Superannuation_Fund__c>();

        if(String.isNotEmpty(searchTerm)){
            fundRecType = [SELECT Id from RecordType where developerName = 'APRA_and_RSA_Funds' LIMIT 1].Id;

            String statusActive = 'Active';
            searchTerm = '%'+searchTerm+'%';

            fundList = Database.query('SELECT id, Super_Search_Field__c, RecordTypeId, tc9_p__Fund_Name__c, tc9_p__Unique_Superannuation_Identifier__c, tc9_p__Fund_Street__c, tc9_p__Fund_Email__c, tc9_p__Fund_ABN__c FROM tc9_p__Superannuation_Fund__c WHERE RecordTypeId =:fundRecType AND tc9_p__Status__c =:statusActive AND Super_Search_Field__c LIKE :searchTerm');
        }
        return fundList;
    }

    //JS Remoting action called when searching for a bsb - currently not in use
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
//    }
    //remote action to upload documentation and create Attachments
    @RemoteAction
    public static String doUploadAttachment(String parentId, String attachmentBody, String attachmentName, String attachmentId, String attachmentDesc) {
        system.debug('got here!!');
        return Portal_JSRemoting_FileUpload_Ctlr.doUploadAttachment(parentId, attachmentBody, attachmentName, attachmentId, attachmentDesc);
    }
}