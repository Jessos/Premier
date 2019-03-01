public class ManageRRUsers {

   public List<UserWrapper> availableUsers{get;set;}
   public List<UserWrapper> selectedUsers{get;set;}
   
   public String availableDepartment{get;set;}
   public String unavailableDepartment{get;set;}
   
   List<String> departmentList;
   
   public ManageRRUsers()
   {
      availableDepartment  = 'ALL';
      unavailableDepartment= 'ALL';
      
      departmentList     = new List<String>();
      departmentList.add('East Bay Administrative');
      departmentList.add('East Bay Contract/Temp');
      departmentList.add('East Bay Sales');
      departmentList.add('San Francisco Administrative');
      departmentList.add('San Francisco Contract/Temp');
      departmentList.add('San Francisco Sales');
    //  departmentList.add('Silicon Valley Administrative');
    //  departmentList.add('Silicon Valley Contract/Temp');
    //  departmentList.add('Silicon Valley Sales');
      departmentList.add('Technology');
      departmentList.add('Finance');
      
      filter();
   }
   
   public void filter()
   {
      availableUsers       = new List<UserWrapper>();
      selectedUsers     = new List<UserWrapper>();
      List<User> users  = [Select Id, Name, Department, Available_for_Round_Robin_Assignment__c, Last_Assign_Date__c from User where IsActive=true and  Department IN :departmentList order by Name];
      for(User u : users)
      {
         if(u.Available_for_Round_Robin_Assignment__c==true)
         {
            if(unavailableDepartment=='ALL' || unavailableDepartment==u.Department)
            {
               selectedUsers.add(new UserWrapper(u));
            }
         }else
         {
            if(availableDepartment=='ALL' || availableDepartment==u.Department)
            {
               availableUsers.add(new UserWrapper(u));
            }
         }
      }
   }
   
   public void addRemoveUsers()
   {
      List<User> userToUpdate = new List<User>();
      for(UserWrapper uw : availableUsers)
      {
         if(uw.selected==true)
         {
            uw.usr.Available_for_Round_Robin_Assignment__c = true;
            userToUpdate.add(uw.usr);
         }
      }
      for(UserWrapper uw : selectedUsers)
      {
         if(uw.selected==true)
         {
            uw.usr.Available_for_Round_Robin_Assignment__c = false;
            userToUpdate.add(uw.usr);
         }
      }
      update userToUpdate;
      filter();
   }
   
   public List<SelectOption> getDepartments()
   {
      List<SelectOption> options = new List<SelectOption>();
      options.add(new SelectOption('ALL','ALL'));
      for(String s : departmentList)
      {
         options.add(new SelectOption(s, s));
      }
      return options;
   }
   
   public class UserWrapper
   {
      public boolean selected{get;set;}
      public User usr{get;set;}
      
      public UserWrapper(User u)
      {
         this.usr          = u;
         this.selected     = false;
      }
   }
   /*// Test method
   private static testMethod void testController()
   {
      PageReference pageRef = new PageReference('/apex/ManageRRUsers');
      Test.setCurrentPage(pageRef);
      
      ManageRRUsers controller = new ManageRRUsers();
      controller.getDepartments();
      controller.addRemoveUsers();
   }*/
}