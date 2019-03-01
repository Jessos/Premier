/*
        Class:              TestCtrl_FillTimeSheet_v2.cls
        @Description:       Test class for Ctrl_FillTimeSheet_v2.cls
*/
@isTest
public class TestCtrl_FillTimeSheet_v2
{
    static User u;
    static tc9_ti__Market__c market;
    static tc9_ti__TaxID__c tax;
    static Account accnt;
    static Contact con;
    static testmethod void testCtrl_FillTimeSheet() /*Modified method name Added for SC-17317*/
    {
        tc9_ti__ToCloudNineConfig__c custSetting    = tc9_ti__ToCloudNineConfig__c.getInstance();
        //custSetting.Week_Start_Day__c       = 'Tuesday';
        custSetting.tc9_ti__Auto_Create_Portal_User__c = false;
        custSetting.tc9_ti__Portal_Profile_Name__c = 'High Volume Customer Portal';
        insert custSetting;
           
        TestDataDump testData            = new TestDataDump();
        tax                             = testData.getTaxID();
        market                          = testData.getMarket(tax.Id);   
        accnt                           = testData.getAClientAccount(market.Id);
        con                             = testData.getAClientContact(accnt.Id);
        
        Date plcStartDate               = date.parse('07/07/2012');
        Date plcEndDate                 = plcStartDate.addDays(100); 
        
        tc9_ti__Site__c sit             = testData.getASite('Test Site', 'http://www.test.com/');
        
        ts2__Job__c job1                = testData.getAJob(accnt.Id, con.Id, market.Id,sit.Id);
        
        //insert a public holiday calander
        tc9_ti__Public_Holiday_Calendar__c cal  = testData.getPublicHolidayCal();
        
        //create a holidate entry
        testData.addHoliday(cal.Id,plcStartDate.addDays(7),plcStartDate.addDays(8));
        
        //insert a new award Master
        tc9_ti__Award_Master__c awrdMaster1     = testData.getAnAwardMaster(38.0, 15.0, 5.0, 5.0, 5.0, false);
        testData.createRules(awrdMaster1.Id);
        
        ts2__Placement__c plc           = testData.getAPlacement(job1, cal.Id, con.Id, plcStartDate, plcEndDate, awrdMaster1.Id, 'Temp'); //till next friday

        
        plc = testData.getPlacementFields(plc.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(plc);
        CreateTimeSheetExt controller   = new CreateTimeSheetExt(sc);
        controller.create();
        

        //get the timesheets created
        List<tc9_ti__Time_Sheet__c> tsList      = [SELECT id,tc9_ti__End_Date__c,tc9_ti__Status__c,tc9_ti__Placement__c FROM tc9_ti__Time_Sheet__c where tc9_ti__Placement__c=:plc.Id order by tc9_ti__Start_Date__c];
        System.debug('@tsList.size()'+tsList.size());
        
        //collect Ids
        Set<Id> tsIDs                   = new Set<Id>();
        for(tc9_ti__Time_Sheet__c ts : tsList)
            tsIDs.add(ts.Id);
       
       
        //get the timesheet entrys created
        List<tc9_ti__Time_Sheet_Entry__c> tseList = [SELECT id,tc9_ti__WorkDate__c,tc9_ti__Status__c,tc9_ti__StartTime__c,tc9_ti__EndTime__c,tc9_ti__Start__c,tc9_ti__End__c,tc9_ti__Time_Sheet__c FROM tc9_ti__Time_Sheet_Entry__c where tc9_ti__Time_Sheet__c in :tsIDs order by tc9_ti__WorkDate__c];

        
        
        //tsList.get(0).Status__c         = 'New';
        //tsList.get(1).Status__c         = 'Approved';
        //update tsList;
        
        System.debug('status:'+tsList.get(0));
        
        tc9_ti__Expense__c e                    = new tc9_ti__Expense__c(tc9_ti__Time_Sheet__c = tsList.get(0).Id,tc9_ti__Type__c='Test Type', tc9_ti__Date_Incurred__c= date.parse('07/25/2012'), tc9_ti__Title__c = 'Test expense', tc9_ti__Value__c = 100.00);

        insert e;
        Attachment a            		= new Attachment();
        a.Name                          = 'Test attachment';
        a.Body                          = Blob.valueOf('Unit Test Attachment Body');
        a.ParentId                      = e.Id;
        insert a;
            
        Test.StartTest();
        
        Integer ind                     = tseList.size();
        Test.setCurrentPage(Page.FillTimeSheet_Page_v2);
        ApexPages.currentPage().getParameters().put('tsId',tsList.get(0).id);
        ApexPages.currentPage().getParameters().put('entryNumber',''+ind);    
        ApexPages.currentPage().getParameters().put('list','OD') ;
        ApexPages.currentPage().getParameters().put('expNumber','1');
        ApexPages.currentPage().getParameters().put('actionToDo','attachSave');
        ApexPages.currentPage().getParameters().put('TSIndexOD','2');
        ApexPages.currentPage().getParameters().put('TSIndex','2');
        Ctrl_FillTimeSheet_v2 c         = new Ctrl_FillTimeSheet_v2();
        c.prev();
        c.next();
         ApexPages.currentPage().getParameters().put('TSIndexOD','0');
         ApexPages.currentPage().getParameters().put('TSIndex','0');
        /*Added for SC-17317*/
        System.assertEquals(c.listOfAttachmentsToBeDisplayed.size(),0);
        /*End - Added for SC-17317*/
        c.next();
        
        c.addExpense();
        c.saveEditDeleteExpense();
        c.addNewTSEntry();
        c.fillDown();
        c.deleteTSEntry();
        c.saveExpenses();
        
        ApexPages.currentPage().getParameters().put('list','TSH') ;

        ApexPages.currentPage().getParameters().put('entryNumber',''+String.valueOf(ind-2));   
        ApexPages.currentPage().getParameters().put('expNumber','1');
        ApexPages.currentPage().getParameters().put('actionToDo','edit');

        Ctrl_FillTimeSheet_v2 c1        = new Ctrl_FillTimeSheet_v2();
        c1.addExpense();
        c1.saveEditDeleteExpense();
        c1.fillDown();
        ApexPages.currentPage().getParameters().put('actionToDo','save');
        c1.saveEditDeleteExpense();
        c1.prevPage(tsList,1,'TSIndexTSH');
        c1.nextPage(tsList,1,'TSIndexTSH');
        c1.saveAll();
        tseList.get(0).tc9_ti__WorkDate__c = null;
        c1.saveTimeSheetEntries();
        c1.doSubmit();
        c1.toggleProjComponent();
        

        //c1.dummyCall();
     system.debug('tslint' +tsList);
      
        
        ApexPages.currentPage().getParameters().put('tsId',tsList.get(0).id);
        ApexPages.currentPage().getParameters().put('entryNumber','2');    
        ApexPages.currentPage().getParameters().put('list','CU') ;
        ApexPages.currentPage().getParameters().put('date','01/03/2015');
        ApexPages.currentPage().getParameters().put('expNumber','1');
       ApexPages.currentPage().getParameters().put('actionToDo','delete');
       tc9_ti__ToCloudNineConfig__c conf         = new tc9_ti__ToCloudNineConfig__c();
       conf.tc9_ti__Custom_Expense_Page_Name__c  = 'Test';
       conf.tc9_ti__Enable_Project_Codes__c = true;
       insert conf;
        conf.tc9_ti__X12_Hour_Timesheet_Format__c = true;
        Ctrl_FillTimeSheet_v2 c2         = new Ctrl_FillTimeSheet_v2();
        c2.projectCodeOption();
        c2.setUserTimesheetFormat();
        c2.fillDown();
        c2.verifydate();
        c2.addExpense();
        c2.saveEditDeleteExpense();
        c2.saveRejection();
        c2.saveTimesheetComment();
        c2.Approve();
        c2.closePopup();
        c2.showPopup();
        c2.logout();
        c2.deleteAttach();
        c2.SaveN();
      List<SelectOption>  reasons=c2.getBreakReasons();
        Test.stoptest();
    }
}