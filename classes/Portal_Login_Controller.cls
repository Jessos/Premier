/**
 * Created by Adelaide Greenaway on 10/01/18.
 *
 * Copyright © 2017 2cloudnine Pty Ltd - Strictly Confidential.
 * Not to be distributed without authorisation
 *
 * Login Controller for the 2c9 Custom Portal
 * An apex page controller that exposes the site login functionality
 *
 * Test Class:
 */

global with sharing class Portal_Login_Controller {
    global String username {get; set;}
    global String password {get; set;}
//    global Boolean showMenu {get;set;}

    global PageReference login() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        system.debug('startURL: '+startUrl);
        return Site.login(username, password, startUrl);
    }

    global Portal_Login_Controller () {
//        showMenu = false;
    }
}