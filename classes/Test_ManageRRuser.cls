// Test method
 @Istest
Public class Test_ManageRRuser{
@IsTest(SeeAllData = true) 
    static  void ManageRRUsers (){  
      PageReference pageRef = new PageReference('/apex/ManageRRUsers');
      Test.setCurrentPage(pageRef);
      
      ManageRRUsers controller = new ManageRRUsers();
      controller.getDepartments();
      controller.addRemoveUsers();
   }
   }