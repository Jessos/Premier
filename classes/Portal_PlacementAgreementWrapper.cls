/**
 * Created by Adelaide Greenaway on 31/10/17.
 *
 * Copyright © 2017 2cloudnine Pty Ltd - Strictly Confidential.
 * Not to be distributed without authorisation
 *
 * Agreement Wrapper for the Placements in the 2c9 Custom Portal
 * This wrapper is for Agreements that are specific to the Payee's Placement record
 * Test Class:
 */

public with sharing class Portal_PlacementAgreementWrapper {

    public Id placement {get;set;}
    public echosign_dev1__SIGN_Agreement__c plcAgreement {get;set;}

    public Portal_PlacementAgreementWrapper(Id plc, echosign_dev1__SIGN_Agreement__c pAgreement){
        this.placement = plc;
        this.plcAgreement = pAgreement;
    }

}