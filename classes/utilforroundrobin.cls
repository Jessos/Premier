public class utilforroundrobin{
  private static List<User> GetUserList(List<String> departmentList)
  {
    List<User> userList =  [SELECT id, name, Department,Last_Assign_Date__c FROM User 
              where Department in :departmentList
              and Available_for_Round_Robin_Assignment__c=true
              and isActive = true 
              order by Last_Assign_Date__c asc nulls first]; 
    return userList;
  }
    
  public static void AssignManagerToCandidatecontact(List<contact> appList){ 
    Set<Id> appIds = new Map<Id, contact>(appList).keySet(); 
    List<contact> appL = [Select Id, 
                          Department_picklist__c, 
                          Admin_Manager__c,
                          Sales_Manager__c, 
                          Technology_Manager__c,
                          Temp_Manager__c
                          from contact
                          where Id IN :appIds];

    List<String> departmentList = new List<String>();
    for(contact tmp : appL){
      departmentList.add(tmp.Department_picklist__c);
    }
    
    List<User> userList = GetUserList(departmentList);      
    List<User> updateList = new List<User>();
    Integer userAt = -1;
    string currentDepartment = '';
    for(contact app: appL){
      currentDepartment = app.Department_picklist__c;
      if(((currentDepartment == 'Administrative' || currentDepartment == 'Finance'))
          || (currentDepartment == 'Sales')
          || (currentDepartment == 'Technology')
          || (currentDepartment == 'Temporary'))
      {
        if(userList == null || userList.size() == 0)
        {
            if(updateList!= null && updateList.size()> 0)
            {
                update updateList;
                updateList = new List<User>();
            }

            userList = GetUserList(departmentList);
        }
        
        for(Integer i = 0;i<userList.size(); i++)
        {
          if(userList[i].Department == currentDepartment)
          {
            updateList.add(userList[i]);
            userList.remove(i);
            break;
          }
        }       
      }
    }

    if(updateList!= null && updateList.size()> 0)
    {
      update updateList;
    }
  }

  public static void sendNewApplicationEmailscontact(List<contact> applications){      
    System.debug('=======applications======='+applications);
    List<EmailTemplate> prEmail = [Select Id from EmailTemplate where DeveloperName='New_Application_Primary_Recruiter_for_contact' limit 1];
    List<EmailTemplate> cmEmail = [Select Id from EmailTemplate where DeveloperName='New_Application_Candidate_Manager_for_contact' limit 1];
    System.debug('=========prEmail ========='+prEmail );
    List<Messaging.Singleemailmessage> mailList = new List<Messaging.Singleemailmessage>();

    // Generate emails for Candidate Manager
    if(prEmail.size() > 0)
    {
      Set<Id> appIds = new Map<Id, contact>(applications).keySet();
      List<contact> appList = [Select Department_picklist__c,Id,Admin_Manager__c, 
                                                  Sales_Manager__c,Technology_Manager__c,
                                               Temp_Manager__c
                                          from contact where Id IN :appIds];
                                          System.debug('=======appList ======='+appList );       
      for(contact app : appList)
      {
        Id managerId = null;
        String department = app.Department_picklist__c;

        if(department == 'Administrative' || department == 'Finance')
        {
          managerId = app.Admin_Manager__c;
        }
        else if(department == 'Sales')
        {
          managerId = app.Sales_Manager__c;
        }
        else if(department == 'Technology')
        {
          managerId = app.Technology_Manager__c;
        }else if(department == 'Temporary')
        {
          managerId = app.Temp_Manager__c;
        }

        System.debug('======managerId======='+managerId);
        if(managerId!=null)
        {
          mailList.add(generateEmailcontact(cmEmail.get(0).Id, managerId, app.Id));
        }
      }
    }

    System.debug('============='+mailList);
    if (mailList.size() > 0)
    {
       Messaging.sendEmail(mailList);
    }
  }

  private static Messaging.SingleEmailMessage generateEmailcontact(Id templateId, Id userId, Id whatId){
    Messaging.SingleEmailMessage aMail = new Messaging.SingleEmailMessage();
    aMail.setTemplateId(templateId);
    aMail.setTargetObjectId(whatId);
    aMail.setSaveAsActivity(false);

    return aMail;
  }
}