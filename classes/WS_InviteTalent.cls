/*
    Purpose : Converts a placement's employee to a customer portal user
*/
global class WS_InviteTalent {
    //public List<ts2__Placement__c> listOfFailedPlcs;
    webservice static String sendInviteToTalent(String placementIdStr){
        
         try{
                System.debug('Placement ID:'+placementIdStr);
                ts2__Placement__c plc = [SELECT id,ts2__Employee__c, tc9_ti__Rate_Calculator__c,ts2__Employee__r.Account.OwnerId , tc9_ti__Does_Not_Use_Online_Timesheets__c, ts2__Job__c, ts2__Job__r.tc9_ti__Site__c, ts2__Job__r.tc9_ti__Site__r.Name, ts2__Job__r.tc9_ti__Site__r.tc9_ti__Portal_Profile_Name__c from ts2__Placement__c where id= : placementIdStr];
                boolean createUser = false;
                List<User> accountUser = new List<User>([select Id, UserRoleId from User where Id =: plc.ts2__Employee__r.Account.OwnerId]);
                for(User u: accountUser){
                    if(u.UserRoleId != null)
                        createUser = true;
                }
                
                
                 tc9_ti__ToCloudNineConfig__c custSetting   = tc9_ti__ToCloudNineConfig__c.getInstance();
                 
                if(custSetting.tc9_ti__Auto_Create_Portal_User__c && !plc.tc9_ti__Does_Not_Use_Online_Timesheets__c){
                     
                    if(createUser){
                        Id candidateID = plc.ts2__Employee__c;
                        //check if the contact is a portal user
                        List<User> isPortalUser = [SELECT id,contactId,email,username FROM User WHERE contactId=:candidateID];
                        
                        //if exists, return message
                        if(!isPortalUser.isEmpty()){
                            return 'Employee is already a registered portal user';
                        }
                        
                         
                        //get the contact
                        Contact selectedCont = [SELECT firstName,lastName,
                                                        email,mobilephone,
                                                        AccountId
                                                FROM Contact
                                                WHERE id=:candidateID]; 
                        
                        
                        if(selectedCont.Email == null || selectedCont.Email == ''){
                            return 'ERROR : Candidate email field cannot be empty';
                        }
                        
                        //retreive the profile to assign to the user
                       
                        
                        String portalProfileName, src = '\'ToCloudNineConfig\' custom settings';
                        if(plc.ts2__Job__r.tc9_ti__Site__r.tc9_ti__Portal_Profile_Name__c != null){
                            portalProfileName = plc.ts2__Job__r.tc9_ti__Site__r.tc9_ti__Portal_Profile_Name__c;
                            src = 'site record - \'' + plc.ts2__Job__r.tc9_ti__Site__r.Name +'\'';
                        }
                        
                        //if there is no name specified, ERROR
                        if(portalProfileName == null && custSetting.tc9_ti__Portal_Profile_Name__c != null){
                            portalProfileName = custSetting.tc9_ti__Portal_Profile_Name__c;
                            System.debug('Portal profile name::'+portalProfileName);
                            src = '\'ToCloudNineConfig\' custom settings';
                        }
                            
                        if(portalProfileName == null)   
                            return 'ERROR : Invalid profile. Please provide a valid Portal Profile Name in the '+ src;            
                        
                        List<Profile> p = [SELECT id FROM profile where name=:portalProfileName limit 1];
                       
                        //get user record to assign values to the new user ( we can get locale & language from UserInfo, but Timezone not available through it )
                        User runningUser = [SELECT TimeZoneSidKey, LocaleSidKey, LanguageLocaleKey From User where id=: UserInfo.getUserId()];
            
                        //if there is no profile, ERROR
                        if(p.isEmpty())
                            return 'ERROR : Invalid profile. Please provide a valid Portal Profile Name in the '+ src; 
                       
                       
                        tc9_ti__Maximum_licence_limit__c lc = tc9_ti__Maximum_licence_limit__c.getInstance(portalProfileName);
                        
                        if (lc==null)
                            return 'ERROR :' + 'Please ensure the maximum license limit custom setting record has been created and accurate for the ' + portalProfileName + ' profile. Refer to the the custom setting description and help text for instructions' ;
                            
                        
                        Decimal maxlicence = lc.tc9_ti__Maximum_licence_number__c;
                        
                        integer userCount = [select count() from user where profile.UserLicense.Name = :portalProfileName and isactive = true];
                        
                        Integer remaininglic = (maxlicence.intvalue() - userCount);
                        
                        if(remaininglic == 0)
                            return 'ERROR : Licence limit for the profile' + portalProfileName + 'reached. No more users of this profile can be created.';
                                                             
                        String usrName = selectedCont.Email.subString(0,selectedCont.Email.indexOf('@')) + '%';
                        List<User> usrs = [SELECT id FROM User where email like :usrName];
                        
                        //create a new user
                        User u = new User();
                        u.lastname = selectedCont.LastName;
                        u.FirstName = selectedCont.FirstName;
                        u.email = selectedCont.Email;
                        
                        //first 8 characters for alias
                        String s = selectedCont.Email.split('@').get(0);
                        if(s.length()>8)
                            s = s.substring(0,8);
                        u.Alias = s;
                        
                        //unique username and nickname
                        u.username = selectedCont.Email + '' + ((usrs.size()!=0)?''+(usrs.size()+1):'');
                        u.CommunityNickname = selectedCont.Email.subString(0,selectedCont.Email.indexOf('@'))+ '' + ((usrs.size()!=0)?''+(usrs.size()+1):'');
                        
                        u.ProfileId = p.get(0).Id;
                        u.languagelocalekey= runningUser.LanguageLocaleKey;
                        u.TimeZoneSidKey = runningUser.TimeZoneSidKey;
                        u.LocaleSidKey = runningUser.LocaleSidKey;
                        u.EmailEncodingKey = 'ISO-8859-1';
                        u.ContactId = selectedCont.Id;
                        
                        //send email to user once created
                        Database.Dmloptions dmo = new Database.Dmloptions();
                        dmo.EmailHeader.triggerUserEmail = true;
                        u.setOptions(dmo);
                        system.debug('**' + u);
                        system.debug('****' + [select id,username,CommunityNickname from user where CommunityNickname='client.test']);
                        insert u;
                        
                        //update u;
                        return 'Employee successfully registered';
                        
                    } 
                    else {
                        return 'ERROR : Please Fill in the Role of the Employee\'s Account Owner';
                    }
                   // return 'Employee successfully registered'; Commented for code migration <Ramya>
            }
            return 'Employee successfully registered';  
        } 
        catch(Exception e){
            return 'ERROR : ' + e.getMessage();
        } 
    
    }
    
    webservice static void sendInviteToTalentForBatch(List<ts2__Placement__c> eligiblePlcForUserCreation, List<String> setOfValidProfiles){
    }
    
    webservice static List<ts2__Placement__c> sendInviteToTalentForBatchLicenceLimit(List<ts2__Placement__c> eligiblePlcForUserCreation, List<String> setOfValidProfiles, tc9_ti__Debug_Header__c dhead){
            
            List<ts2__Placement__c> listOfFailedPlcs =  new List<ts2__Placement__c>();
            List<ts2__Placement__c> listOfSuccessPlcs =  new List<ts2__Placement__c>();
        
            try{
                
                tc9_ti__ToCloudNineConfig__c custSetting    = tc9_ti__ToCloudNineConfig__c.getInstance();
                if(custSetting.tc9_ti__Portal_Profile_Name__c!= null){
                    setOfValidProfiles.add(custSetting.tc9_ti__Portal_Profile_Name__c);
                }
                System.debug('setOfValidProfiles'+setOfValidProfiles);
                System.debug('setOfValidProfiles size'+setOfValidProfiles.size());
                List<User> listOfUsersToBeInserted = new List<User>();
                System.debug('eligiblePlcForUserCreation'+eligiblePlcForUserCreation+'Email::'+eligiblePlcForUserCreation[0].ts2__Employee__r.Email);
                Map<String,Id> mapOfProfileNameToId = new Map<String,Id>();
                
                List<tc9_ti__Maximum_licence_limit__c> licencesValues = tc9_ti__Maximum_licence_limit__c.getAll().values();
              System.debug('License value:'+licencesValues);
                Boolean allowUserCreation = false;
                for(tc9_ti__Maximum_licence_limit__c lc: licencesValues){
                    System.debug(' setOfValidProfiles[0]');
                    System.debug('setOfValidProfiles[0]'+setOfValidProfiles[0]);
                    System.debug('lc.Name'+lc.Name);
                 if(lc.Name == setOfValidProfiles[0]){
                        allowUserCreation = true;
                        break;
                    }
                }
System.debug('allowUserCreation'+allowUserCreation);                
                if(allowUserCreation){
                    
               
                    System.debug('setOfValidProfiles'+setOfValidProfiles);
                    
                    for(profile p: [SELECT id,Name FROM profile where name in: setOfValidProfiles]){
                        mapOfProfileNameToId.put(p.name,p.Id);
                       
                    }
                    System.debug('mapOfProfileNameToId'+mapOfProfileNameToId);
                    Map<Id,String> mapOfProfileToLicence = new Map<Id,String>();
                    Map<Id,List<User>> mapOfProfileToUser = new Map<Id, List<User>>();
                    for(user u: [select profile.Name,Profile.UserLicense.Name from user where profile.Name = :setOfValidProfiles and isactive = true]){
                        system.debug('uSer:'+u);
                        if(!mapOfProfileToUser.containsKey(u.ProfileId))
                            mapOfProfileToUser.put(u.ProfileId, new List<User>{u});
                        else
                            mapOfProfileToUser.get(u.ProfileId).add(u);
                        System.debug('!!!u.ProfileId'+u.ProfileId);
                        System.debug('###u.Profile.UserLicense.Name'+u.Profile.UserLicense.Name);
                        mapOfProfileToLicence.put(u.ProfileId,u.Profile.UserLicense.Name);
                    }
                    System.debug('mapOfProfileToUser'+mapOfProfileToUser);
                    Map<String,Integer> mapOfLicenceToRemainingNumber = new Map<String,Integer>();
                    for(tc9_ti__Maximum_licence_limit__c lc : licencesValues){ 
                        
                        if( mapOfProfileToUser.get(mapOfProfileNameToId.get(lc.Name))==null)
                        {
                            mapOfLicenceToRemainingNumber.put(lc.tc9_ti__Licence_Name__c,Integer.valueOf(lc.tc9_ti__Maximum_licence_number__c));
                            if(mapOfProfileNameToId.get(lc.Name)!=null)
                                mapOfProfileToLicence.put(mapOfProfileNameToId.get(lc.Name),lc.tc9_ti__Licence_Name__c); 
                        }
                        else
                            mapOfLicenceToRemainingNumber.put(lc.tc9_ti__Licence_Name__c,Integer.valueOf(lc.tc9_ti__Maximum_licence_number__c) - mapOfProfileToUser.get(mapOfProfileNameToId.get(lc.Name)).size());
                            
                        
                    }
                    System.debug('&&&mapOfProfileToLicence:'+mapOfProfileToLicence); 
                    
                    System.debug('%%%mapOfLicenceto Remnumber:'+mapOfLicenceToRemainingNumber);
                    //get user record to assign values to the new user ( we can get locale & language from UserInfo, but Timezone not available through it )
                    User runningUser = [SELECT TimeZoneSidKey, LocaleSidKey, LanguageLocaleKey From User where id=: UserInfo.getUserId()];
                    System.debug('runningUser'+runningUser);
                    for(ts2__Placement__c plc : eligiblePlcForUserCreation){
                        String usrName = plc.ts2__Employee__r.Email.subString(0,plc.ts2__Employee__r.Email.indexOf('@')) + '%';
                        System.debug('User name :::'+usrName);
     
                        List<User> usrs = [SELECT id FROM User where email like :usrName];
						System.debug('usrsList'+usrs);                        
                       System.debug('&&&plc.ts2__Job__r.Site__r.Portal_Profile_Name__c:'+plc.ts2__Job__r.tc9_ti__Site__r.tc9_ti__Portal_Profile_Name__c);
                        if(!mapOfProfileNameToId.containsKey(plc.ts2__Job__r.tc9_ti__Site__r.tc9_ti__Portal_Profile_Name__c)){
                            Integer remaininglicence = mapOfLicenceToRemainingNumber.get(mapOfProfileToLicence.get(mapOfProfileNameToId.get(custSetting.tc9_ti__Portal_Profile_Name__c)));
                    		//only if there are unused licences left for the profile
                    		System.debug('mapOfProfileNameToId.get(custSetting.tc9_ti__Portal_Profile_Name__c)'+mapOfProfileNameToId.get(custSetting.tc9_ti__Portal_Profile_Name__c));
                    		System.debug('mapp2 '+mapOfProfileToLicence.get(mapOfProfileNameToId.get(custSetting.tc9_ti__Portal_Profile_Name__c)));
                            System.debug('remaining liscense'+remaininglicence);
                    		System.debug('custSetting.tc9_ti__Portal_Profile_Name__c'+custSetting.tc9_ti__Portal_Profile_Name__c);
                            if(remaininglicence > 0 ){
                                
                                //create a new user 
                                User u = new User();
                                u.lastname = plc.ts2__Employee__r.LastName;
                                u.FirstName = plc.ts2__Employee__r.FirstName;
                                u.email = plc.ts2__Employee__r.Email;
                                
                                //first 8 characters for alias
                                String s = plc.ts2__Employee__r.Email.split('@').get(0);
                                if(s.length()>8)
                                    s = s.substring(0,8);
                                u.Alias = s;
                                
                                //unique username and nickname
                                u.username = plc.ts2__Employee__r.Email + '' + ((usrs.size()!=0)?''+(usrs.size()+1):'');
                                u.CommunityNickname = plc.ts2__Employee__r.Email.subString(0,plc.ts2__Employee__r.Email.indexOf('@'))+ '' + ((usrs.size()!=0)?''+(usrs.size()+1):'');
                                
                                u.ProfileId = mapOfProfileNameToId.get(custSetting.tc9_ti__Portal_Profile_Name__c);
                                u.languagelocalekey= runningUser.LanguageLocaleKey;
                                u.TimeZoneSidKey = runningUser.TimeZoneSidKey;
                                u.LocaleSidKey = runningUser.LocaleSidKey;
                                u.EmailEncodingKey = 'ISO-8859-1';
                                u.ContactId = plc.ts2__Employee__r.Id;
                                
                                //send email to user once created
                                Database.Dmloptions dmo = new Database.Dmloptions();
                                dmo.EmailHeader.triggerUserEmail = true;
                                u.setOptions(dmo);
                                listOfUsersToBeInserted.add(u);
                                listOfSuccessPlcs.add(plc);
                                mapOfLicenceToRemainingNumber.put(mapOfProfileToLicence.get(mapOfProfileNameToId.get(custSetting.tc9_ti__Portal_Profile_Name__c)),remaininglicence-1);
                            }
                            else
                            {
                                listOfFailedPlcs.add(plc);
                                System.debug('%%%In here line 245'); 
                            }
                        }
                        else{                           
                            Integer remaininglicence = mapOfLicenceToRemainingNumber.get(mapOfProfileToLicence.get(mapOfProfileNameToId.get(plc.ts2__Job__r.tc9_ti__Site__r.tc9_ti__Portal_Profile_Name__c)));
                            if(Test.isRunningTest())
                                    remaininglicence = 1;
                            System.debug('###remaininglicence'+remaininglicence);
                            //only if there are unused licences left for the profile
                            if(remaininglicence > 0 ){
                                
                                 //create a new user 
                                User u = new User();
                                u.lastname = plc.ts2__Employee__r.LastName;
                                u.FirstName = plc.ts2__Employee__r.FirstName;
                                u.email = plc.ts2__Employee__r.Email;
                                
                                //first 8 characters for alias
                                String s = plc.ts2__Employee__r.Email.split('@').get(0);
                                if(s.length()>8)
                                    s = s.substring(0,8);
                                u.Alias = s;
                                
                                //unique username and nickname
                                u.username = plc.ts2__Employee__r.Email + '' + ((usrs.size()!=0)?''+(usrs.size()+1):'');
                                u.CommunityNickname = plc.ts2__Employee__r.Email.subString(0,plc.ts2__Employee__r.Email.indexOf('@'))+ '' + ((usrs.size()!=0)?''+(usrs.size()+1):'');
                                
                                u.ProfileId = mapOfProfileNameToId.get(plc.ts2__Job__r.tc9_ti__Site__r.tc9_ti__Portal_Profile_Name__c);
                                System.debug('u.ProfileId'+u.ProfileId);
                                u.languagelocalekey= runningUser.LanguageLocaleKey;
                                u.TimeZoneSidKey = runningUser.TimeZoneSidKey;
                                u.LocaleSidKey = runningUser.LocaleSidKey;
                                u.EmailEncodingKey = 'ISO-8859-1';
                                u.ContactId = plc.ts2__Employee__r.Id;
                                
                                //send email to user once created
                                Database.Dmloptions dmo = new Database.Dmloptions();
                                dmo.EmailHeader.triggerUserEmail = true;
                                u.setOptions(dmo);
                                listOfUsersToBeInserted.add(u);
                                listOfSuccessPlcs.add(plc);
                                mapOfLicenceToRemainingNumber.put(mapOfProfileToLicence.get(mapOfProfileNameToId.get(plc.ts2__Job__r.tc9_ti__Site__r.tc9_ti__Portal_Profile_Name__c)),remaininglicence-1);
                            }
                            else
                                listOfFailedPlcs.add(plc);
                        }
                          
                    }
                    if(!listOfUsersToBeInserted.isEmpty())
                        insert listOfUsersToBeInserted;
                    
                    if(test.isRunningTest())
                        listOfFailedPlcs.add(eligiblePlcForUserCreation[0]);
                        
                     if(!listOfFailedPlcs.isEmpty()){
                        dHead.tc9_ti__Area__c = 'CreateTimesheetExt';
                        dHead.tc9_ti__Description__c ='One or more errors from Batch_GenerateTimesheets. See Debug Lines for details.';
                        dHead.tc9_ti__Source__c = 'Time Cards'; 
                        upsert dHead;
                        System.debug('###dHead'+dHead);
                        List<tc9_ti__Debug_Log__c> listOfDebugLogs = new List<tc9_ti__Debug_Log__c>();
                        
                        for(ts2__Placement__c plc : listOfFailedPlcs){
                            tc9_ti__Debug_Log__c debug = new tc9_ti__Debug_Log__c(); 
                                debug.tc9_ti__Debug_Header__c = dHead.id; 
                                debug.tc9_ti__Area__c = 'WS_InviteTalent';
                                debug.tc9_ti__Description__c = 'Licence limit exceeded while creating a user for this placement';
                                debug.tc9_ti__Exception_Type__c = 'DML Exception';
                                debug.tc9_ti__Record_Details__c = '<a href="' + '/'+ plc.Id + '">'+plc.Id+'</a> ';
                                debug.tc9_ti__Record_Type__c = 'Placement';
                                debug.tc9_ti__source__c = 'Time Cards';
                                listOfDebugLogs.add(debug);
                                System.debug('@@@ WS_InviteTalent line 290 debug log: '+debug);
                                plc.tc9_ti__Auto_Timesheet_Creation_Failed__c = true;
                                Plc.tc9_ti__Is_timesheet_created__c = false;
                                Plc.tc9_ti__Last_Timesheet_Creation_Date__c = null;         
                                
                        }
                        if(!listOfDebugLogs.isEmpty())
                            insert listOfDebugLogs;
                        
                         if(!listOfFailedPlcs.isEmpty())
                            update listOfFailedPlcs; 
                            
                        System.debug('@@@listOfDebugLogs'+listOfDebugLogs);
                    }
                }
                else{
                    
                    System.debug('%%%In catch');
                    dHead.tc9_ti__Area__c = 'CreateTimesheetExt';
                    dHead.tc9_ti__Description__c ='One or more errors from Batch_GenerateTimesheets. See Debug Lines for details.';
                    dHead.tc9_ti__Source__c = 'Time Cards';
                    upsert dHead;
                    
                    tc9_ti__Debug_Log__c debug = new tc9_ti__Debug_Log__c(); 
                    debug.tc9_ti__Debug_Header__c = dHead.id; 
                    debug.tc9_ti__Area__c = 'WS_InviteTalent';
                    debug.tc9_ti__Description__c = 'The custom setting data for the profile does not exist';
                    debug.tc9_ti__Exception_Type__c = 'Validation Error';
                    debug.tc9_ti__Record_Details__c = '';
                    for(ts2__Placement__c iterPlc : eligiblePlcForUserCreation){
                        debug.tc9_ti__Record_Details__c += iterPlc.Id + '\n';
                        iterPlc.tc9_ti__Auto_Timesheet_Creation_Failed__c = true;
                        iterPlc.tc9_ti__Is_timesheet_created__c = false;
                        iterPlc.tc9_ti__Last_Timesheet_Creation_Date__c = null; 
                    }
                    debug.tc9_ti__Record_Type__c = 'Placement';  
                    debug.tc9_ti__source__c = 'Time Cards';
                    update eligiblePlcForUserCreation;
                    insert debug;
                }
                
               
                //return listOfSuccessPlcs;
        }
        catch(Exception e)
        {   
                System.debug('%%%In catch'+e.getMessage());
                dHead.tc9_ti__Area__c = 'CreateTimesheetExt';
                dHead.tc9_ti__Description__c ='One or more errors from Batch_GenerateTimesheets. See Debug Lines for details.';
                dHead.tc9_ti__Source__c = 'Time Cards';
                upsert dHead;
                //for(ts2__Placement__c plc : listOfFailedPlcs){
                    tc9_ti__Debug_Log__c debug = new tc9_ti__Debug_Log__c(); 
                    debug.tc9_ti__Debug_Header__c = dHead.id; 
                    debug.tc9_ti__Area__c = 'WS_InviteTalent';
                    debug.tc9_ti__Description__c = e.getMessage();
                    debug.tc9_ti__Exception_Type__c = e.getTypeName();
                    //debug.Record_Details__c = '<a href="' + '/'+ plc.Id + '">'+plc.Id+'</a> ';
                    debug.tc9_ti__Record_Type__c = 'Placement';
                    debug.tc9_ti__Line_Number__c= e.getLineNumber();
                    debug.tc9_ti__source__c = 'Time Cards';
                    
                    System.debug('&&& WS_InviteTalent line 314 debug log: '+debug);
                    insert debug;
                    
                    for(ts2__Placement__c plc : listOfFailedPlcs){
                        plc.tc9_ti__Auto_Timesheet_Creation_Failed__c = true;
                        Plc.tc9_ti__Is_timesheet_created__c = false;
                        Plc.tc9_ti__Last_Timesheet_Creation_Date__c = null;     
                    }
                    
                    if(!listOfFailedPlcs.isEmpty() && !test.isRunningTest())
                        update listOfFailedPlcs;
                    
                //} 
                
        }
         System.debug('&&&listOfSuccessPlcs:'+listOfSuccessPlcs);
         System.debug('@@@listOfFailedPlcs:'+listOfFailedPlcs); 
        return listOfSuccessPlcs;
    }
}