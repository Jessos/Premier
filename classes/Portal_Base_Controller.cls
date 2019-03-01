/**
 * Created by Adelaide Greenaway on 30/10/17.
 *
 * Copyright © 2017 2cloudnine Pty Ltd - Strictly Confidential.
 * Not to be distributed without authorisation
 *
 * Base Controller for the 2c9 Custom Portal
 * this base controller will be used by other portal pages and will check and get;
 *  - a valid User and Contact record to successfully run the portal session.
 *  - a Primary Payee that will be represented throughout the Portal session.
 * 
 * Test Class:
 */
//public without sharing class Portal_Base_Controller{
public virtual class Portal_Base_Controller {

    private Id userId = UserInfo.getUserId();
    protected String sessionId = UserInfo.getSessionId();

    public User currentUser {get;set;}
    public Contact contractor {get;set;}
    public tc9_p__Payee__c currentPayee {get;set;}
    public Boolean showContent {get;set;}
    public Boolean showConfirmation {get;set;}
    public Boolean showError {get;set;}
    public Boolean showMenu {get;set;}
    public String Error {get;set;}
    public Attachment portalAvatar {get;set;}
    public customTFPortalSettings__c settings {get;set;}

    public Portal_Base_Controller(){

        //get out portal custom settings - we will need them
        settings = customTFPortalSettings__c.getInstance();
        
        currentUser();
        currentContractor();
        currentPayee();
        //default to view only for each page
        showContent = true;
        //default to show no messages
        showConfirmation = false;
        showError = false;
        showMenu = true;

//        String pageName =ApexPages.currentPage().getUrl();
//        pageName = pageName.split('apex/')[1];
//        if(pageName == 'PortalLogin' || pageName == 'PortalForgotPassword' || pageName == 'PortalPasswordConfirm'){
//            showMenu = false;
//        }
//        system.debug('pageName'+pageName);
    }

     public void currentUser(){
    //protected void currentUser(){
        currentUser = [SELECT Id, FirstName, LastName, ContactId, Contact.FirstName,  Contact.LastName
                FROM User
                WHERE Id =: userId LIMIT 1];

        system.debug('currentUser: '+currentUser);

    }

    public void currentContractor(){
     //protected void currentContractor(){
        if(currentUser.ContactId != null){
            contractor = [SELECT Id, FirstName, LastName, Birthdate, Email, Salutation,
                    tc9_p__pr_emergencyContact1_Name__c, tc9_p__pr_emergencyContact1_ContactNumber__c, tc9_p__pr_emergencyContact1_Relationship__c,
                    Phone, MobilePhone, HomePhone, Available_Sick_Leave_Balance__c, Sick_Pay_Eligibility_Date__c,
                    MailingAddress, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode,
                    Personal_Details_Provided__c, EMP_NUM__c,
                    (SELECT Id, Name FROM Attachments WHERE Name LIKE 'portalAvatar%')
                    FROM Contact
                    WHERE Id =: currentUser.ContactId];
            if(contractor.Attachments.size()>0){
                system.debug('in if');
                portalAvatar = contractor.Attachments[0];
                system.debug('portal avatar :: ' + portalAvatar.Id);
            }else{
            system.debug('in else');
                portalAvatar = null;//'No Photo Provided';
            }
            
            //system.debug('portal avatar :: ' + portalAvatar.Id);
            system.debug('contractor: '+contractor);
       }
    }

    public void currentPayee(){
    //protected void currentPayee(){
        if(currentUser.ContactId != null){
            currentPayee = [SELECT Id, tc9_p__Earner_Type__c, tc9_p__Contact__c, tc9_p__Status__c, tc9_p__Primary_Record__c,
                    TFN_Provided__c, Super_Details_Provided__c, Bank_Details_Provided__c,
                    tc9_p__Contact__r.Personal_Details_Provided__c,
                    tc9_p__Bank_Account_1_Name__c, tc9_p__Bank_Account_1_Number__c, tc9_p__Bank_Account_1_Code__c,
                    tc9_p__Bank_Account_1_Allocated_Percentage__c, tc9_p__Bank_Account_1_Fixed_Amount__c,
                    tc9_p__Bank_Account_1_Pay_Remaining_Balance__c,
                    tc9_p__Bank_Account_2_Name__c, tc9_p__Bank_Account_2_Number__c, tc9_p__Bank_Account_2_Code__c,
                    tc9_p__Bank_Account_2_Allocated_Percentage__c, tc9_p__Bank_Account_2_Fixed_Amount__c,
                    tc9_p__Bank_Account_2_Pay_Remaining_Balance__c,
                    tc9_p__Bank_Account_3_Name__c, tc9_p__Bank_Account_3_Number__c, tc9_p__Bank_Account_3_Code__c,
                    tc9_p__Bank_Account_3_Allocated_Percentage__c, tc9_p__Bank_Account_3_Fixed_Amount__c,
                    tc9_p__Bank_Account_3_Pay_Remaining_Balance__c,
                    tc9_p__Bank_Intl_Country__c, tc9_p__Bank_Intl_Bank_Name__c, tc9_p__Bank_Intl_Bank_Address__c,
                    tc9_p__Bank_Intl_SWIFT_BIC__c, tc9_p__Bank_Intl_Account_IBAN__c, tc9_p__Bank_Intl_Recipient_Name__c,
                    tc9_p__Bank_Intl_Recipient_Address__c, Bank_Type_Selected__c, tc9_p__Bank_Intl_Receiving_Currency__c,
                    Fund_Option_Selected__c, tc9_p__Super_Fund_1__c, tc9_p__Super_Fund_1_Name__c, tc9_p__Super_Fund_1_Member_Number__c,
                    tc9_p__Super_Fund_1_Fixed_Amount__c, tc9_p__Super_Fund_1_Allocated_Percentage__c,
                    tc9_p__Super_Fund_1__r.tc9_p__Fund_Name__c,
                    tc9_p__Super_Fund_1__r.tc9_p__Fund_ABN__c,
                    tc9_p__Super_Fund_1__r.tc9_p__Fund_Electronic_Service_Address__c,
                    tc9_p__Super_Fund_1__r.tc9_p__Fund_Branch__c,
                    tc9_p__Super_Fund_1__r.tc9_p__Fund_Account_Name__c,
                    tc9_p__Super_Fund_1__r.tc9_p__Fund_Account_Number__c,
                    tc9_p__Super_Fund_1__r.tc9_p__Fund_Phone__c,
                    tc9_p__Super_Fund_1__r.tc9_p__Fund_Email__c,
                    tc9_p__Super_Fund_1__r.SMSF_Trustee_Dec__c,
                    tc9_p__Super_Fund_1__r.tc9_p__Fund_Street__c,
                    tc9_p__Super_Fund_1__r.tc9_p__Fund_City__c,
                    tc9_p__Super_Fund_1__r.tc9_p__Fund_State_Province__c,
                    tc9_p__Super_Fund_1__r.tc9_p__Fund_Zip_Postal_Code__c,
                    tc9_p__Super_Fund_1__r.tc9_p__Fund_Country__c,
                    tc9_p__Payment_Entity__c,
                    tc9_p__Payment_Entity__r.Default_Superannuation_Fund__c,
                    tc9_p__Payment_Entity__r.Default_Superannuation_Fund__r.Name,
                    tc9_p__Payment_Entity__r.Default_Superannuation_Fund__r.tc9_p__Fund_ABN__c,
                    tc9_p__Payment_Entity__r.Default_Superannuation_Fund__r.tc9_p__Fund_Name__c,
                    tc9_p__Payment_Entity__r.Default_Superannuation_Fund__r.tc9_p__Unique_Superannuation_Identifier__c,
                    tc9_p__Payment_Entity__r.Default_Superannuation_Fund__r.tc9_p__Fund_Phone__c,
                    tc9_p__Payment_Entity__r.Default_Superannuation_Fund__r.customFund_Website__c,
                    tc9_p__Tax_File_Number__c, Has_Own_TFN__c, tc9_p__Australian_Resident__c,
                    tc9_p__Claim_Tax_Free__c, tc9_p__Other_Tax_Offset__c, tc9_p__HELP_Debt__c,
                    tc9_p__Is_approved_working_holiday_maker__c, Portal_Tax_Declaration_Complete__c,
                    tc9_p__AFS_Debt__c, Portal_Tax_Declaration_Date__c, No_TFN_Reason__c,
                    tc9_p__ABN__c, tc9_p__GST_Registered__c, tc9_p__Business_Street__c, tc9_p__Business_City__c,
                    tc9_p__Business_State_Province__c, tc9_p__Business_Country__c,tc9_p__Business_Zip_Postal_Code__c,
                    Use_2c9_Portal_Agreement_Logic__c,
                    (Select Id, name from Attachments order by lastmodifieddate desc)
                    FROM tc9_p__Payee__c
                    WHERE tc9_p__Contact__c =: contractor.Id
                    AND tc9_p__Status__c = 'Active'
                    AND tc9_p__Primary_Record__c = true];

            system.debug('payee: '+currentPayee);
//            agreementRequired = false;
//            if(currentPayee.Use_2c9_Portal_Agreement_Logic__c == true && ){
//                agreementRequired = true;
//            }else{
//                agreementRequired = false;
//            }

        }
    }

    public PageReference toggleContent(){
        if(showContent){
            showContent = false;
        }else{
            showContent = true;
        }
        //system.debug('showContent: '+showContent);
        return null;
    }
}