@istest
public class Test_WS_InviteTalent {
      static testmethod void testInviteTalent(){
        Test_PortalDataFactory testData1 =new Test_PortalDataFactory ();
        tc9_ti__ToCloudNineConfig__c config = new tc9_ti__ToCloudNineConfig__c();
        config.tc9_ti__Portal_Profile_Name__c = 'High Volume Customer Portal Custom';
        config.tc9_ti__Auto_Create_Portal_User__c = true;
        insert config;
        
        TestDataDump testData = new TestDataDump();
        Date plcStartDate       = Date.today();
        Date plcEndDate         = plcStartDate.addDays(12);
        
        tc9_ti__TaxID__c taxID          = testData.getTaxID();
        tc9_ti__Market__c market        = testData.getMarket(taxID.Id); 
        Account accnt           = testData.getAClientAccount(market.Id);
        Contact clientContact   = testData.getAClientContact(accnt.Id);
            
        tc9_ti__Site__c sit             = testData.getASite('Test Site', 'http://www.test.comxx/');
        
        ts2__Job__c job1        = testData.getAJob(accnt.Id, clientContact.Id, market.Id,sit.Id);
       
        //insert a public holiday calander
        tc9_ti__Public_Holiday_Calendar__c cal = testData.getPublicHolidayCal();
        
        //create a holidate entry
        testData.addHoliday(cal.Id,plcStartDate.addDays(7),plcStartDate.addDays(8));
        
        Contact candidate  = testData.getACandidate('TestCandidate');
        candidate.ts2__People_Status__c='On Premier Assignment';
        candidate.I_9_Review_Status_is_Completed__c=True;
        candidate.State__c='AL'; 
        update candidate;
        Profile prof = testData1.getProfileByName('High Volume Customer Portal Custom');
        //User usr = testData1.getAPortalUser(prof,candidate);getAUser
        User usr = testData1.getAUser(prof,'Jude','Rich');
        usr.IsActive=True;
        usr.Location__c = 'New York';
        insert usr; 
          
        //insert a new award Master
        tc9_ti__Award_Master__c awrdMaster1 = testData.getAnAwardMaster(38.0, 15.0, 5.0, 5.0, 5.0, false);
        //testData.createRules(awrdMaster1.Id);
        ts2__Placement__c plc   = testData.getAPlacement(job1, cal.Id, candidate.Id, plcStartDate, plcEndDate, awrdMaster1.Id, 'Temp'); //till next friday 
       Test.startTest();
         System.runAs(usr)
         {
                String returnmsg = WS_InviteTalent.sendInviteToTalent(plc.Id);/*return statement Added for SC-17317*/
        /*Added for SC-17317*/
        Boolean error = returnmsg.contains('ERROR');
        System.assertEquals(error,true); 
         }
      Test.stopTest();
        /*End - Added for SC-17317*/
        //System.assertEquals([SELECT count() from User WHERE contactId = :candidate.Id],1);
        
    }
    static testmethod void testInviteTalent2(){
        
        tc9_ti__ToCloudNineConfig__c config = new tc9_ti__ToCloudNineConfig__c();
        config.tc9_ti__Portal_Profile_Name__c = 'High Volume Customer Portal Custom';
        config.tc9_ti__Auto_Create_Portal_User__c = true;
        insert config;
        
        tc9_ti__Maximum_licence_limit__c l = new tc9_ti__Maximum_licence_limit__c();
        l.Name = 'High Volume Customer Portal Custom';
        l.tc9_ti__Licence_Name__c = 'High Volume Customer Portal Custom';
        l.tc9_ti__Maximum_licence_number__c = 10;
        insert l;
        
        TestDataDump testData = new TestDataDump();
        Date plcStartDate       = Date.today();
        Date plcEndDate         = plcStartDate.addDays(12);
        
        tc9_ti__TaxID__c taxID          = testData.getTaxID();
        tc9_ti__Market__c market        = testData.getMarket(taxID.Id); 
        Account accnt           = testData.getAClientAccount(market.Id);
        Contact clientContact   = testData.getAClientContact(accnt.Id);
            
        tc9_ti__Site__c sit             = testData.getASite('Test Site', 'http://www.test.comxx/');
        
        ts2__Job__c job1        = testData.getAJob(accnt.Id, clientContact.Id, market.Id,sit.Id);
        
        //insert a public holiday calander
        tc9_ti__Public_Holiday_Calendar__c cal = testData.getPublicHolidayCal();
        
        //create a holidate entry
        testData.addHoliday(cal.Id,plcStartDate.addDays(7),plcStartDate.addDays(8));
        
        Contact candidate       = testData.getACandidate('TestCandidate');
        candidate.ts2__People_Status__c='On Premier Assignment';
        candidate.I_9_Review_Status_is_Completed__c=True;
        candidate.State__c='AL'; 
        update candidate;        
        //insert a new award Master
        tc9_ti__Award_Master__c awrdMaster1 = testData.getAnAwardMaster(38.0, 15.0, 5.0, 5.0, 5.0, false);
        //testData.createRules(awrdMaster1.Id);
         
        ts2__Placement__c plc   = testData.getAPlacement(job1, cal.Id, candidate.Id, plcStartDate, plcEndDate, awrdMaster1.Id, 'Temp'); //till next friday
   
        
        WS_InviteTalent.sendInviteToTalent(plc.Id);
        
   //**     System.assertEquals([SELECT count() from User WHERE contactId = :candidate.Id],1);
        
    }
    static testmethod void testInviteTalentbatch(){
        Test_PortalDataFactory testData1 =new Test_PortalDataFactory ();
        tc9_ti__ToCloudNineConfig__c config = new tc9_ti__ToCloudNineConfig__c();
        config.tc9_ti__Portal_Profile_Name__c = 'High Volume Customer Portal';
        config.tc9_ti__Auto_Create_Portal_User__c = true;
        insert config;
        
        tc9_ti__Maximum_licence_limit__c l = new tc9_ti__Maximum_licence_limit__c();
        l.Name = 'High Volume Customer Portal Custom';
        l.tc9_ti__Licence_Name__c = 'High Volume Customer Portal';
        l.tc9_ti__Maximum_licence_number__c = 10;
        insert l;
        
        TestDataDump testData = new TestDataDump();
        Date plcStartDate       = Date.today();
        Date plcEndDate         = plcStartDate.addDays(12);
        
        tc9_ti__TaxID__c taxID          = testData.getTaxID();
        tc9_ti__Market__c market        = testData.getMarket(taxID.Id); 
        Account accnt           = testData.getAClientAccount(market.Id);
        Contact clientContact   = testData.getAClientContact(accnt.Id);
            
        tc9_ti__Site__c sit             = testData.getASite('Test Site', 'http://www.test.comxx/');
        
        sit.tc9_ti__Portal_Profile_Name__c = 'High Volume Customer Portal';
        update sit;
        
        ts2__Job__c job1        = testData.getAJob(accnt.Id, clientContact.Id, market.Id,sit.Id);
        
        //insert a public holiday calander
        tc9_ti__Public_Holiday_Calendar__c cal = testData.getPublicHolidayCal();
        
        //create a holidate entry
        testData.addHoliday(cal.Id,plcStartDate.addDays(7),plcStartDate.addDays(8));
        
        Contact candidate       = testData.getACandidate('TestCandidate');
        candidate.ts2__People_Status__c='On Premier Assignment';
        candidate.I_9_Review_Status_is_Completed__c=True;
        candidate.State__c='AL'; 
          candidate.Email = 'test@test.com';
        update candidate;                
        
        //insert a new award Master
        tc9_ti__Award_Master__c awrdMaster1 = testData.getAnAwardMaster(38.0, 15.0, 5.0, 5.0, 5.0, false);
        //testData.createRules(awrdMaster1.Id);
         
        ts2__Placement__c plc   = testData.getAPlacement(job1, cal.Id, candidate.Id, plcStartDate, plcEndDate, awrdMaster1.Id, 'Temp'); //till next friday
                
        
        //User usr = testData.getCustomerPortalUser(candidate);
        //insert usr;
        
        List<ts2__Placement__c> listOfPlc = new List<ts2__Placement__c>();
        listOfPlc.add(plc);       
        
        List<String> setOfprofiles = new List<String>();
        //setOfprofiles.add('High Volume Customer Portal Custom');
        
        tc9_ti__Debug_Header__c head = new tc9_ti__Debug_Header__c();
               Test.startTest(); 
     WS_InviteTalent.sendInviteToTalentForBatchLicenceLimit(listOfPlc,setOfprofiles,head);
        
        //System.assertEquals([SELECT count() from User WHERE contactId = :candidate.Id],1);
        setOfprofiles = new List<String>();
        config.tc9_ti__Portal_Profile_Name__c = '';
        update config; 
         
        sit.tc9_ti__Portal_Profile_Name__c = 'Silver Partner User';
        update sit;
        
        l.Name = 'Silver Partner User';
        l.tc9_ti__Licence_Name__c = 'Silver Partner';
        l.tc9_ti__Maximum_licence_number__c = 10;
        update l; 
        
        /* Contact candidate2       = testData.getACandidate('TestCandidate23');
        candidate2.ts2__People_Status__c='On Premier Assignment';
        candidate2.I_9_Review_Status_is_Completed__c=True;
        candidate2.State__c='AL'; 
          candidate2.Email = 'test@test.com';
         candidate2.LastName = 'Testing';
         update candidate2;*/  // commenting this due to duplicate issue in test class
         
         
     
        
        ts2__Job__c job2        = testData.getAJob(accnt.Id, clientContact.Id, market.Id,sit.Id);
        
      //  ts2__Placement__c plc   = testData.getAPlacement(job1, cal.Id, candidate.Id, plcStartDate, plcEndDate, awrdMaster1.Id, 'Temp'); //till next friday
                
      
         ts2__Placement__c plc2   = testData.getAPlacement(job2, cal.Id, candidate.Id, plcStartDate, plcEndDate, awrdMaster1.Id, 'Temp'); //till next friday
         plc.ts2__Employee__c= candidate.Id;
        
      
        listOfPlc = new List<ts2__Placement__c>();
        listOfPlc.add(plc2);       
        update listOfPlc;
        System.debug('&&& Site Portal name: '+ plc.ts2__Job__r.tc9_ti__Site__r.tc9_ti__Portal_Profile_Name__c);      
        
        setOfprofiles.add('Silver Partner User');
        setOfprofiles.add('High Volume Customer Portal Custom');
        
          Profile prof = testData1.getProfileByName('High Volume Customer Portal');
        //User usr = testData1.getAPortalUser(prof,candidate);getAUser
        User usr = testData1.getAUser(prof,'Jude','Rich');
        usr.IsActive=True;
        usr.Location__c = 'New York';
        usr.Email='test@testdata.com';
        insert usr; 
        
  
         System.runAs(usr)
         {
                  WS_InviteTalent.sendInviteToTalentForBatchLicenceLimit(listOfPlc,setOfprofiles,head);
        //Added for SC-17317
        List<tc9_ti__Debug_Log__c> listDebug = [Select id from tc9_ti__Debug_Log__c];
        System.assertNotEquals(listDebug.size(),0);
           //   End - Added for SC-17317
         }
      Test.stopTest();
      
       
        
    }
    static testmethod void testInviteTalentbatch2(){
        Test_PortalDataFactory testData1 =new Test_PortalDataFactory ();
        tc9_ti__ToCloudNineConfig__c config = new tc9_ti__ToCloudNineConfig__c();
        config.tc9_ti__Portal_Profile_Name__c = 'High Volume Customer Portal Custom';
        config.tc9_ti__Auto_Create_Portal_User__c = true;
        insert config;
        
        tc9_ti__Maximum_licence_limit__c l = new tc9_ti__Maximum_licence_limit__c();
        l.Name = 'High Volume Customer Portal Custom';
        l.tc9_ti__Licence_Name__c = 'High Volume Customer Portal';
        l.tc9_ti__Maximum_licence_number__c = 10;
        insert l;
        
        TestDataDump testData = new TestDataDump();
        Date plcStartDate       = Date.today();
        Date plcEndDate         = plcStartDate.addDays(12);
        
        tc9_ti__TaxID__c taxID          = testData.getTaxID();
        tc9_ti__Market__c market        = testData.getMarket(taxID.Id); 
        Account accnt           = testData.getAClientAccount(market.Id);
        Contact clientContact   = testData.getAClientContact(accnt.Id);
            
        tc9_ti__Site__c sit             = testData.getASite('Test Site', 'http://www.test.comxx/');
        
        sit.tc9_ti__Portal_Profile_Name__c = 'High Volume Customer Portal Custom';
        update sit;
        
        ts2__Job__c job1        = testData.getAJob(accnt.Id, clientContact.Id, market.Id,sit.Id);
        
        //insert a public holiday calander
        tc9_ti__Public_Holiday_Calendar__c cal = testData.getPublicHolidayCal();
        
        //create a holidate entry
        testData.addHoliday(cal.Id,plcStartDate.addDays(7),plcStartDate.addDays(8));
        
        Contact candidate       = testData.getACandidate('TestCandidate');
          candidate.ts2__People_Status__c='On Premier Assignment';
        candidate.I_9_Review_Status_is_Completed__c=True;
        candidate.State__c='AL'; 
          candidate.Email = 'test@test.com';
         candidate.LastName = 'Testing';
         update candidate;
        
        //insert a new award Master
        tc9_ti__Award_Master__c awrdMaster1 = testData.getAnAwardMaster(38.0, 15.0, 5.0, 5.0, 5.0, false);
        //testData.createRules(awrdMaster1.Id);
    
        ts2__Placement__c plc   = testData.getAPlacement(job1, cal.Id, candidate.Id, plcStartDate, plcEndDate, awrdMaster1.Id, 'Temp'); //till next friday
        System.debug('EmailId:'+plc.ts2__Employee__r.Email);
        plc.ts2__Employee__r = candidate;
        System.debug('plc:'+plc);
   
        List<ts2__Placement__c> listOfPlc = new List<ts2__Placement__c>();
        listOfPlc.add(plc);       
        update  listOfPlc;
        
        system.debug('plc :' +listOfPlc);
         
        List<String> setOfprofiles = new List<String>();
        setOfprofiles.add('High Volume Customer Portal Custom');
        setOfprofiles.add('High Volume Customer Portal');
        setOfprofiles.add('Silver Partner User');
        
        tc9_ti__Debug_Header__c head = new tc9_ti__Debug_Header__c();
        
        
          Profile prof = testData1.getProfileByName('High Volume Customer Portal');
        //User usr = testData1.getAPortalUser(prof,candidate);getAUser
        User usr = testData1.getAUser(prof,'Jude','Rich');
        usr.IsActive=True;
        usr.Location__c = 'New York';
        insert usr; 
        system.runAs(usr)
        {
                    WS_InviteTalent.sendInviteToTalentForBatchLicenceLimit(listOfPlc,setOfprofiles,head);
        }
        

        WS_InviteTalent.sendInviteToTalentForBatch(listOfPlc,setOfprofiles);
      //  WS_InviteTalent.sendInviteToTalent(null);
        WS_InviteTalent.sendInviteToTalent(String.valueOf(plc.Id));
        /*Added for SC-17317*/
        List<tc9_ti__Debug_Log__c> listDebug = [Select id from tc9_ti__Debug_Log__c];
        System.assertNotEquals(listDebug.size(),0);
        /*End - Added for SC-17317*/
    }
 static testmethod void testInviteTalentbatch3(){
        Test_PortalDataFactory testData1 =new Test_PortalDataFactory ();
        tc9_ti__ToCloudNineConfig__c config = new tc9_ti__ToCloudNineConfig__c();
        config.tc9_ti__Portal_Profile_Name__c = 'High Volume Customer Portal';
        config.tc9_ti__Auto_Create_Portal_User__c = true;
        insert config;
        
        tc9_ti__Maximum_licence_limit__c l = new tc9_ti__Maximum_licence_limit__c();
        l.Name = 'High Volume Customer Portal';
        l.tc9_ti__Licence_Name__c = 'High Volume Customer Portal';
        l.tc9_ti__Maximum_licence_number__c = 10;
        insert l;
        
        TestDataDump testData = new TestDataDump();
        Date plcStartDate       = Date.today();
        Date plcEndDate         = plcStartDate.addDays(12);
        
        tc9_ti__TaxID__c taxID          = testData.getTaxID();
        tc9_ti__Market__c market        = testData.getMarket(taxID.Id); 
        Account accnt           = testData.getAClientAccount(market.Id);
        Contact clientContact   = testData.getAClientContact(accnt.Id);
            
        tc9_ti__Site__c sit             = testData.getASite('Test Site', 'http://www.test.comxx/');
        
        sit.tc9_ti__Portal_Profile_Name__c = 'High Volume Customer Portal';
        update sit;
        
        ts2__Job__c job1        = testData.getAJob(accnt.Id, clientContact.Id, market.Id,sit.Id);
        
        //insert a public holiday calander
        tc9_ti__Public_Holiday_Calendar__c cal = testData.getPublicHolidayCal();
        
        //create a holidate entry
        testData.addHoliday(cal.Id,plcStartDate.addDays(7),plcStartDate.addDays(8));
        
        Contact candidate       = testData.getACandidate('TestCandidate');
          candidate.ts2__People_Status__c='On Premier Assignment';
        candidate.I_9_Review_Status_is_Completed__c=True;
        candidate.State__c='AL'; 
          candidate.Email = 'test@test.com';
         candidate.LastName = 'Testing';
         update candidate;
        
        //insert a new award Master
        tc9_ti__Award_Master__c awrdMaster1 = testData.getAnAwardMaster(38.0, 15.0, 5.0, 5.0, 5.0, false);
        //testData.createRules(awrdMaster1.Id);
    
        ts2__Placement__c plc   = testData.getAPlacement(job1, cal.Id, candidate.Id, plcStartDate, plcEndDate, awrdMaster1.Id, 'Temp'); //till next friday
        System.debug('EmailId:'+plc.ts2__Employee__r.Email);
        plc.ts2__Employee__r = candidate;
        System.debug('plc:'+plc);
   
        List<ts2__Placement__c> listOfPlc = new List<ts2__Placement__c>();
        listOfPlc.add(plc);       
        update  listOfPlc;
        
        system.debug('plc :' +listOfPlc);
         
        List<String> setOfprofiles = new List<String>();
       // setOfprofiles.add('High Volume Customer Portal Custom');
        setOfprofiles.add('High Volume Customer Portal');
        setOfprofiles.add('Silver Partner User');
        
        tc9_ti__Debug_Header__c head = new tc9_ti__Debug_Header__c();
        
        
          Profile prof = testData1.getProfileByName('High Volume Customer Portal');
        //User usr = testData1.getAPortalUser(prof,candidate);getAUser
        User usr = testData1.getAUser(prof,'Jude','Rich');
        usr.IsActive=True;
        usr.Location__c = 'New York';
        insert usr; 
        system.runAs(usr)
        {
                    WS_InviteTalent.sendInviteToTalentForBatchLicenceLimit(listOfPlc,setOfprofiles,head);
        }
        

        WS_InviteTalent.sendInviteToTalentForBatch(listOfPlc,setOfprofiles);
      //  WS_InviteTalent.sendInviteToTalent(null);
        WS_InviteTalent.sendInviteToTalent(String.valueOf(plc.Id));
        //Added for SC-17317
        List<tc9_ti__Debug_Log__c> listDebug = [Select id from tc9_ti__Debug_Log__c];
        System.assertNotEquals(listDebug.size(),0);
        //End - Added for SC-17317
    }
    
}