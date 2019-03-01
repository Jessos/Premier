/**
 * An apex page controller that exposes the site forgot password functionality
 */

public with sharing class Portal_ForgotPassword_Controller {
    public String username {get; set;}
    //public Boolean showMenu {get;set;}

    public Portal_ForgotPassword_Controller() {
        //showMenu = false;
    }

    public PageReference forgotPassword() {

        boolean success = Site.forgotPassword(username);
        PageReference pr = Page.PortalPasswordConfirm;
        pr.setRedirect(true);

        if (success) {
            return pr;
        }
        return null;
    }

}