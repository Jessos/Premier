/**
 * Created by Adelaide Greenaway on 2/11/17.
 *
 * Copyright © 2017 2cloudnine Pty Ltd - Strictly Confidential.
 * Not to be distributed without authorisation
 *
 * Profile Personal Details Controller for the 2c9 Custom Portal
 * this controller will be used by Portal Profile Personal Details page will check and get;
 *  - the users Contact details and emergency contact details
 *  - allow the Contact details to be updated (except for the Contact name and DOB)
 *
 * Test Class:
 */


public with sharing class Portal_ProfilePersonal_Controller extends Portal_Base_Controller{

    // Address details
    public String mobile {get;set;}
    public String email {get;set;}

    public String street {get;set;}
    public String city {get;set;}
    public String state {get;set;}
    public String postalcode {get;set;}
    public String country {get;set;}


    public String payeeEarnerType {get;set;}

    public String Error {get;set;}

    // Variables passed through from Component
    public Id recordId {get;set;}
    public String objName {get;set;}

    // Address one details
    public String streetOne {get;set;}
    public String cityOne {get;set;}
    public String stateOne {get;set;}
    public String postalcodeOne {get;set;}
    public String countryOne {get;set;}


    // CONSTRUCTOR
    public Portal_ProfilePersonal_Controller() {
        //default page to view only
        showContent = true;

        payeeEarnerType = currentPayee.tc9_p__Earner_Type__c;

        //get any already saved details to show on the page
        mobile = contractor.MobilePhone;
        email = contractor.Email;

        street = contractor.MailingStreet;
        city = contractor.MailingCity;
        state = contractor.MailingState;
        country = contractor.MailingCountry;
        postalcode = contractor.MailingPostalCode;

        system.debug('mobile: '+mobile+' email: '+email);
    }

    public void Submit(){
        system.debug('Save Updated Details');
        Contact updatedContact = contractor;
        try{
            updatedContact.MobilePhone = mobile;
            updatedContact.Email = email;
            updatedContact.MailingStreet = street;
            updatedContact.MailingCity = city;
            updatedContact.MailingState = state;
            updatedContact.MailingCountry = country;
            updatedContact.MailingPostalCode = postalcode;

            update updatedContact;

            //change back to view only
            showContent = true;
        }catch (Exception e){
            Error = 'There is an error updating your details. Please contact your administrator or try again '+e.getMessage();
        }
    }
    public void Cancel(){
        showContent = true;
    }

}