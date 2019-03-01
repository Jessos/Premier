/*
        Class:              TestCtrl_CommunityTSPage.cls
        @Description:       Test class for TestCtrl_CommunityTSPage
*/
@isTest
public class TestCtrl_CommunityTSPage 
{
    static User u;
    static tc9_ti__Market__c market;
    static tc9_ti__TaxID__c tax;
    static Account accnt;
    static Contact con;
      static Contact emp;
    static User user1;
     private static tc9_ti__Time_Sheet__c ts;
     private static tc9_ti__Time_Sheet__c ts1;
     private static tc9_ti__Time_Sheet__c ts2;
       private static tc9_ti__Time_Sheet__c ts3;
        
    static testMethod void testCreateTimeSheetExt()
    {
        tc9_ti__ToCloudNineConfig__c custSetting     = new tc9_ti__ToCloudNineConfig__c();
        //custSetting.Week_Start_Day__c       = 'Monday';
        custSetting.tc9_ti__Auto_Create_Portal_User__c = true;
        custSetting.tc9_ti__Portal_Profile_Name__c = 'High Volume Customer Portal';
        insert custSetting;
        
         tc9_ti__Maximum_licence_limit__c l = new tc9_ti__Maximum_licence_limit__c();
        l.Name = 'High Volume Customer Portal';
        l.tc9_ti__Licence_Name__c = 'High Volume Customer Portal';
        l.tc9_ti__Maximum_licence_number__c = 10;
        insert l;
        
        TestDataDump testData   = new TestDataDump();
        tax                     = testData.getTaxID();
        market                  = testData.getMarket(tax.Id);   
        accnt                   = testData.getAClientAccount(market.Id);
        con                     = testData.getAClientContact(accnt.Id);
        
        user1                   = testData.getCustomerPortalUser(con);
        Date plcStartDate       = date.parse('07/23/2018');
        Date plcEndDate         = plcStartDate.addDays(12); 
        
        tc9_ti__Site__c sit             = testData.getASite('Test Site', 'http://www.test.com/');
      
     

     	 emp=new Contact();

        emp.AccountID   = accnt.Id;
        emp.Salutation = 'Ms';
        emp.FirstName  = 'Lane';
        emp.LastName = 'Jane';
        emp.Email      = 'Lane'+'@test.com';
        emp.Birthdate     = Date.parse('2/2/1982');
        emp.MailingStreet = '1 Spring Street';
        emp.MailingCity = 'Melbourne';
        emp.MailingState = 'Victoria';
        emp.MailingCountry = 'Australia';
        emp.MailingPostalCode = '3000';
        emp.State__c = 'AZ';
        emp.ts2__People_Status__c='On Premier Assignment';
        emp.I_9_Review_Status_is_Completed__c=True;
        emp.State__c='AL'; 
        insert emp;
        
        ts2__Job__c job1        = testData.getAJob(accnt.Id, con.Id, market.Id,sit.Id);
        ts2__Job__c job2       = testData.getAJob(accnt.Id, emp.Id, market.Id,sit.Id);
        
        //insert a public holiday calander
        tc9_ti__Public_Holiday_Calendar__c cal = testData.getPublicHolidayCal();
        
        //create a holidate entry
        testData.addHoliday(cal.Id,plcStartDate.addDays(7),plcStartDate.addDays(8));
        
        //insert a new award Master
        tc9_ti__Award_Master__c awrdMaster1 = testData.getAnAwardMaster(38.0, 15.0, 5.0, 5.0, 5.0, false);
        testData.createRules(awrdMaster1.Id);
        
        ts2__Placement__c plc   = testData.getAPlacement(job1, cal.Id, con.Id, plcStartDate, plcEndDate, awrdMaster1.Id, 'Temp'); //till next friday
        ts2__Placement__c plc1   = testData.getAPlacement(job2, cal.Id, con.Id, plcStartDate.addDays(2), plcEndDate, awrdMaster1.Id, 'Temp'); //till next friday
        
        plc = testData.getPlacementFields(plc.Id);
        system.debug('****' + [select id,username,CommunityNickname from user where CommunityNickname='client.test']);
        ApexPages.StandardController sc = new ApexPages.StandardController(plc);
      //  CreateTimeSheetExt controller = new CreateTimeSheetExt(sc);
      //  controller.create();
        
        plc1 = testData.getPlacementFields(plc1.Id);
        
        try{
        ts = testData.getATimesheet(plc.Id,con.Id,Date.today().addDays(-7), Date.today(), 'New');
        ts1 = testData.getATimesheet(plc.Id,con.Id,Date.today().addDays(-14), Date.today(), 'New');
        ts2 = testData.getATimesheet(plc.Id,con.Id,Date.today().addDays(-9), Date.today(), 'New');
        ts3 = testData.getATimesheet(plc.Id,con.Id,Date.today().addDays(-4), Date.today(), 'New');
        }
        catch(exception e){
        system.debug('exception :::' + e.getmessage());
        }
        system.debug('time ::: ' + ts);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(plc1);
      //  CreateTimeSheetExt controller1 = new CreateTimeSheetExt(sc1);
       // controller1.create();
        
        
        //get the timesheets created
        List<tc9_ti__Time_Sheet__c> tsList = [SELECT id,tc9_ti__End_Date__c,tc9_ti__Status__c,tc9_ti__Placement__c FROM tc9_ti__Time_Sheet__c where tc9_ti__Placement__c=:plc.Id order by tc9_ti__Start_Date__c];
        List<tc9_ti__Time_Sheet__c> tsList1 = [SELECT id,tc9_ti__End_Date__c,tc9_ti__Status__c,tc9_ti__Placement__c FROM tc9_ti__Time_Sheet__c where tc9_ti__Placement__c=:plc1.Id order by tc9_ti__Start_Date__c];
        /*Added for SC-17317*/
       // System.assertNotEquals(tsList.size(),0);
        /*End - Added for SC-17317*/

        //collect Ids
        Set<Id> tsIDs              = new Set<Id>();
        for(tc9_ti__Time_Sheet__c ts : tsList)
            tsIDs.add(ts.Id);

        
         Set<Id> tsIDs1              = new Set<Id>();
        for(tc9_ti__Time_Sheet__c ts : tsList1)
            tsIDs1.add(ts.Id);
        
        
        //get the timesheet entrys created
        List<tc9_ti__Time_Sheet_Entry__c> tseList = [SELECT id,tc9_ti__WorkDate__c,tc9_ti__Status__c,tc9_ti__StartTime__c,tc9_ti__EndTime__c,tc9_ti__Start__c,tc9_ti__End__c,tc9_ti__Time_Sheet__c FROM tc9_ti__Time_Sheet_Entry__c where tc9_ti__Time_Sheet__c in :tsIDs order by tc9_ti__WorkDate__c];
        List<tc9_ti__Time_Sheet_Entry__c> tseList1 = [SELECT id,tc9_ti__WorkDate__c,tc9_ti__Status__c,tc9_ti__StartTime__c,tc9_ti__EndTime__c,tc9_ti__Start__c,tc9_ti__End__c,tc9_ti__Time_Sheet__c FROM tc9_ti__Time_Sheet_Entry__c where tc9_ti__Time_Sheet__c in :tsIDs1 order by tc9_ti__WorkDate__c];
        
        
        //tsList.get(0).tc9_ti__Status__c = 'Approved';
        //tsList.get(0).tc9_ti__Generate_Transaction__c = '2';
        tsList.get(1).tc9_ti__Status__c = 'Approved';
        tsList.get(1).tc9_ti__Generate_Transaction__c = '2';
        tsList.get(2).tc9_ti__Status__c = 'Approved';
        tsList.get(2).tc9_ti__Generate_Transaction__c = '2';
        update tsList;
        
        System.debug('status:'+tsList.get(0));
        
        u = [select Id from User where ContactId =: con.Id];
        
        Test.StartTest();
        
        System.runAs(u)
        {
            Ctrl_CommunityTSPage c = new Ctrl_CommunityTSPage();
        }
        
        String label = NamespaceUtil1.getFieldDescribe(new ts2__Placement__c(), 'tc9_ti__AlternativeTimeSheetApprover__c').getDescribe().getLabel();
        String obj = NamespaceUtil1.getObjectLabel(new ts2__Placement__c());
        Test.stoptest();
    }
}