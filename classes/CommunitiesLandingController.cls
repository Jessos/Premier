/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class CommunitiesLandingController {
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
     String communityUrl = 'https://jsdev-premiertalent-jsdev.cs65.force.com/timesheets';
        String customHomePage = '/apex/PortalHome';
        if (UserInfo.getUserType().equals('Guest')) {
            return new PageReference(communityUrl + '/login?startURL=' + EncodingUtil.urlEncode(customHomePage, 'UTF-8'));
        }else {
            return Network.communitiesLanding();
        }
        //return Network.communitiesLanding();
    }
    
    public CommunitiesLandingController() {}
}