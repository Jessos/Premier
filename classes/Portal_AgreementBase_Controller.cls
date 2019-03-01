/**
 * Created by Adelaide Greenaway on 30/10/17.
 *
 * Copyright © 2017 2cloudnine Pty Ltd - Strictly Confidential.
 * Not to be distributed without authorisation
 *
 * Base controller for 2c9 Custom Portal Assignments and 2c9 Custom Portal Home
 *
 * Logic for Payee and Placement Agreements depending on whether logic and visibility is enabled
 *
 * Test Class:
 */

public virtual class Portal_AgreementBase_Controller extends Portal_Base_Controller{

    public Map<Id, tc9_p__Payee__c> mapOfPayee {get;set;}
    public List<ts2__Placement__c> listOfAgreeLogicPlc {get;set;}

    public List<Portal_PayeeAgreementWrapper> incompletePayeeAgreementWrapperList {get;set;}
    public List<Portal_PayeeAgreementWrapper> completePayeeAgreementWrapperList {get;set;}

    public List<Portal_PlacementAgreementWrapper> incompletePlcAgreementWrapperList {get;set;}
    public List<Portal_PlacementAgreementWrapper> completePlcAgreementWrapperList {get;set;}

    public Boolean payeeAgreementsExist {get;set;}
    public Boolean plcAgreementsExist {get;set;}

    public Boolean agreeOutstanding {get;set;}
    public Boolean stopTSEntryPayee {get;set;}

    public Portal_AgreementBase_Controller() {

        //initialise agreement existence to false
        payeeAgreementsExist = false;
        plcAgreementsExist = false;
        stopTSEntryPayee = true;
        agreeOutstanding = false;

        //customTFPortalSettings__c settings = customTFPortalSettings__c.getInstance();

        //initialise the ability to access timesheets
        if (settings.Use_Echosign__c == false) {
            stopTSEntryPayee = false;
        }
        if (settings.Use_Echosign__c == true) {
            if (currentPayee.Use_2c9_Portal_Agreement_Logic__c == true) {
                //stop them from completing all timesheets!
                stopTSEntryPayee = true;
            }else{
                stopTSEntryPayee = false;
            }
            getAgreements();
        }
    }

    public void getAgreements(){

        //initialise agreement logic map for Placements
        listOfAgreeLogicPlc = new List<ts2__Placement__c>();

        //initialise the wrapper lists
        incompletePayeeAgreementWrapperList = new List<Portal_PayeeAgreementWrapper>();
        completePayeeAgreementWrapperList  = new List<Portal_PayeeAgreementWrapper>();

        incompletePlcAgreementWrapperList = new List<Portal_PlacementAgreementWrapper>();
        completePlcAgreementWrapperList = new List<Portal_PlacementAgreementWrapper>();
        //stopTSEntryPayee = false;

        //get the Payee map so we can do stuff
        mapOfPayee = new Map<Id, tc9_p__Payee__c>([SELECT Id, tc9_p__Contact__c, tc9_p__Status__c, tc9_p__Primary_Record__c,
                Use_2c9_Portal_Agreement_Logic__c, x2c9_Portal_Payee_Agreement_Visible__c, x2c9_Portal_Payee_Agreement_Status__c
                FROM tc9_p__Payee__c
                WHERE tc9_p__Contact__c =: contractor.Id
                AND tc9_p__Status__c = 'Active'
                AND tc9_p__Primary_Record__c = true]);

        for(tc9_p__Payee__c payee : mapOfPayee.values()){
            //If we have set the Payee Agreement to Visible, let's go ahead and find any Agreements
            if(payee.x2c9_Portal_Payee_Agreement_Visible__c == true){

                // Do we have existing agreements, if so, notify the user to what is outstanding and
                // put them in complete or incomplete lists for Payee and Placement level Agreements

                //Check if agreements exist at all for the payee on their payee record
                List<echosign_dev1__SIGN_Agreement__c> lstPayeeAgreement =
                        new List<echosign_dev1__SIGN_Agreement__c> ([SELECT Id, Name, echosign_dev1__Document__c, echosign_dev1__Status__c, echosign_dev1__SignedPDF__c,
                                            Placement__c, Payee__c, Current_Signing_URL__c
                                            FROM echosign_dev1__SIGN_Agreement__c
                                            WHERE Payee__r.Id =: payee.Id
                                            AND echosign_dev1__Status__c NOT IN ('Cancelled / Declined')]);

                //For this Contractors Payee, list the complete and incomplete eSign Agreements on the Payee and the Payee's Placement records
                if(!lstPayeeAgreement.isEmpty()) {
                    payeeAgreementsExist = true;
                    for (echosign_dev1__SIGN_Agreement__c doc : lstPayeeAgreement) {
                        if (doc.echosign_dev1__Status__c != 'Signed') {
                            incompletePayeeAgreementWrapperList.add(new Portal_PayeeAgreementWrapper(payee, doc));
                        }
                        if (doc.echosign_dev1__Status__c == 'Signed') {
                            completePayeeAgreementWrapperList.add(new Portal_PayeeAgreementWrapper(payee, doc));
                        }
                    }
                }else{
                    payeeAgreementsExist = false;
                }

                if(incompletePayeeAgreementWrapperList.size() > 0){
                    // we have at least one outstanding payee agreement
                    agreeOutstanding = true;
                    if (currentPayee.Use_2c9_Portal_Agreement_Logic__c == true) {
                        //stop them from completing all timesheets!
                        stopTSEntryPayee = true;
                    }else{
                        stopTSEntryPayee = false;
                    }
                }
                if(incompletePayeeAgreementWrapperList.size() <= 0){
                    agreeOutstanding = false;
                    stopTSEntryPayee = false;
                }
            }

            //Check if agreements exist for placements that are specific to this Payee
            List<echosign_dev1__SIGN_Agreement__c> lstAgreement =
                    new List<echosign_dev1__SIGN_Agreement__c> ([SELECT Id, Name, echosign_dev1__Document__c, echosign_dev1__Status__c, echosign_dev1__SignedPDF__c,
                                        Placement__c, Payee__c, Placement__r.Payee__c, Current_Signing_URL__c,
                                        Placement__r.Use_2c9_Portal_Agreement_Logic__c, Placement__r.x2c9_Portal_Placement_Agreement_Visible__c,
                                        Placement__r.x2c9_Portal_Placement_Agreement_Status__c, Placement__r.Name, Placement__r.ts2__Start_Date__c,
                                        Placement__r.ts2__End_Date__c, Placement__r.ts2__Client__r.Name,
                                        Placement__r.ts2__Job__r.Name
                                        FROM echosign_dev1__SIGN_Agreement__c
                                        WHERE Placement__r.Payee__c =: payee.id
                                        AND echosign_dev1__Status__c NOT IN ('Cancelled / Declined')]);

            if(!lstAgreement.isEmpty()) {
                plcAgreementsExist = true;

                for (echosign_dev1__SIGN_Agreement__c doc : lstAgreement) {
                    //Only make visible the Placements that are set to Visible
                    if(doc.Placement__r.x2c9_Portal_Placement_Agreement_Visible__c == true) {
                        if (doc.echosign_dev1__Status__c != 'Signed') {
                            Id plcmt = doc.Placement__r.Id;
                            //add these agreements to the incomplete collection wrapper
                            incompletePlcAgreementWrapperList.add(new Portal_PlacementAgreementWrapper(plcmt, doc));
                            agreeOutstanding = true;

                            //we need to deal with the agreement logic on a placement by placement basis
                            if (doc.Placement__r.Use_2c9_Portal_Agreement_Logic__c == true)
                                listOfAgreeLogicPlc.add(doc.Placement__r);

                            system.debug('listOfAgreeLogicPlc: '+listOfAgreeLogicPlc);
                        }
                        if (doc.echosign_dev1__Status__c == 'Signed') {
                            Id plcmt = doc.Placement__r.Id;
                            //add these agreements to the incomplete collection wrapper
                            completePlcAgreementWrapperList.add(new Portal_PlacementAgreementWrapper(plcmt, doc));
                        }
                    }
                }
                system.debug('lstAgreement: '+lstAgreement);
            }else{
                plcAgreementsExist = false;
            }

            system.debug('plcAgreementsExist: '+plcAgreementsExist+'payeeAgreementsExist: '+payeeAgreementsExist);
            system.debug('incompletePayeeAgreementWrapperList: '+incompletePayeeAgreementWrapperList);
            system.debug('completePayeeAgreementWrapperList: '+completePayeeAgreementWrapperList);
            system.debug('incompletePlcAgreementWrapperList: '+incompletePlcAgreementWrapperList);
            system.debug('completePlcAgreementWrapperList: '+completePlcAgreementWrapperList);

        }
    }
}