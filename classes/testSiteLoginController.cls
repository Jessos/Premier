@IsTest 
private class testSiteLoginController{

public static testmethod void method1(){
        // Instantiate a new controller with all parameters in the page
        SiteLoginController1 controller1 = new SiteLoginController1();
        
        controller1.username = 'test@salesforce.com';
        controller1.password = '1234'; 
                
        System.assertEquals(controller1.login(),null);                           
    }
}