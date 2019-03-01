public with sharing class bat_TaskAttachemntViewCtrl {

    public List<Task_Attachment__c> TaskAtts { get; set; }
    public bat_TaskAttachemntViewCtrl(ApexPages.StandardController controller) {
        Id taskId= controller.getId();
        TaskAtts = [SELECT Id,File_Name__c, File_Location__c from Task_Attachment__c where Task_Id__c = :taskId];
        
    }

}