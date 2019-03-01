/**
 * Created by Adelaide Greenaway on 31/10/17.
 *
 * Copyright © 2017 2cloudnine Pty Ltd - Strictly Confidential.
 * Not to be distributed without authorisation
 *
 * Agreement Wrapper for the Payee in the 2c9 Custom Portal
 * This wrapper is for Agreements that are specific to the Payee record
 * Test Class:
 */

public with sharing class Portal_PayeeAgreementWrapper {
    public tc9_p__Payee__c payee {get;set;}

    public echosign_dev1__SIGN_Agreement__c payeeAgreement {get;set;}

    public Portal_PayeeAgreementWrapper(tc9_p__Payee__c pye, echosign_dev1__SIGN_Agreement__c pAgreement){
        this.payee = pye;
        this.payeeAgreement = pAgreement;
        system.debug('payeeAgreement: '+payeeAgreement);
    }
}