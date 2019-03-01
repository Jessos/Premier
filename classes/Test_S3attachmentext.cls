@isTest
public class Test_S3attachmentext{
@isTest(SeeAllData=true)
public static void tests3aattach(){
    Task_Attachment__c dummys3object=new Task_Attachment__c(File_Name__c='test-111');
    insert dummys3object;
    
    ApexPages.CurrentPage().getParameters().put('id', dummys3object.id);
   
    S3attachmentext dummycontroller=new S3attachmentext();
     System.assertequals(dummycontroller.urlforopen,null);
    dummycontroller.openfile();




} 

}