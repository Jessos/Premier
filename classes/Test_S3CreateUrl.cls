@isTest
public class Test_S3CreateUrl{   
    static testMethod void verify_class(){
    
    list<S3_Archive_Settings__c > Archivelist = new list<S3_Archive_Settings__c >();
    Task_Attachment__c  taskassign = new Task_Attachment__c(File_name__c='fgh',S3_Bucket__c='68547'); 
    insert taskassign ;
    S3_Archive_Settings__c Archeive=new S3_Archive_Settings__c(Name='S31',API_Key__c='s3_public_key',Value__c ='djfjgj');
    Archivelist.add(Archeive);
   // insert Archeive;
    
    S3_Archive_Settings__c NewArcheive=new S3_Archive_Settings__c(Name='S32',API_Key__c='s3_secret_key',Value__c ='fjgj');
    Archivelist.add(NewArcheive);
    insert Archivelist;
    
    
    // Task_Attachment__c attachment = [select File_name__c,S3_Bucket__c from Task_Attachment__c where Id = :pageId];
  //  S3CreateUrl controller = new S3CreateUrl();
    //string pageId;
   S3CreateUrl.createSignedGetUrl(taskassign.id);

    
      }
    }